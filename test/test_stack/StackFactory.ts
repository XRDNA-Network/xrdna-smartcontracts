import { Signer, ZeroAddress } from "ethers";
import { AssetStackImpl } from "./asset/AssetStackImpl";
import { AvatarStackImpl } from "./avatar/AvatarStackImpl";
import { PortalStackImpl } from "./portal/PortalStackImpl";
import { ExperienceStackImpl } from "./experience/ExperienceStackImpl";
import { WorldStackImpl } from "./world/WorldStackImpl";
import { CompanyStackImpl } from "./company/CompanyStackImpl";
import { RegistrarStackImpl} from "./registrar/RegistrarStackImpl";
import { ethers, network } from "hardhat";
import { AssetType, CreateAssetResult, IWorldRegistration, VectorAddress, World, signVectorAddress } from "../../src";
import { Company } from "../../src/company/Company";
import { Experience } from "../../src/experience";
import { Avatar } from "../../src/avatar/Avatar";
import { TestERC20, TestERC721 } from "../../typechain-types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";

export enum StackType {
    REGISTRAR = "REGISTRAR",
    ASSET = "ASSET",
    WORLD = "WORLD",
    AVATAR = "AVATAR",
    COMPANY = "COMPANY",
    EXPERIENCE = "EXPERIENCE",
    PORTAL = "PORTAL"
}


export interface IStackAdmins {
    assetRegistryAdmin: Signer;
    avatarRegistryAdmin: Signer;
    companyRegistryAdmin: Signer;
    experienceRegistryAdmin: Signer;
    portalRegistryAdmin: Signer;
    registrarAdmin: Signer;
    registrarSigner: Signer;
    worldRegistryAdmin: Signer;
    worldOwner: Signer;
}

export class StackFactory {
    stacksByType: Map<string, any> = new Map();
    registrarId?: bigint;
    world: World;
    constructor(readonly admins: IStackAdmins, readonly userSigner: HardhatEthersSigner) {}


    async init(): Promise<{world: World, worldRegistration: IWorldRegistration}> {

        //registrar admin is XRDNA signer
        await network.provider.request({
            method: "hardhat_impersonateAccount",
            params: ["0x28ba8a72cc5d3eafdbd27929b658e446c697148b"],
        });
        const t = await this.admins.registrarAdmin.sendTransaction({
            to: "0x28ba8a72cc5d3eafdbd27929b658e446c697148b",
            value: ethers.parseEther("100.0")
        });
        const r = await t.wait();
        if(!r!.status) {
            throw new Error("Failed to fund registrar admin");
        }
        this.admins.registrarAdmin = await ethers.getSigner("0x28ba8a72cc5d3eafdbd27929b658e446c697148b");
        this.admins.registrarSigner = this.admins.registrarAdmin;

        const world = new WorldStackImpl(this);
        const worldDeployment = await world.deploy();
        this.stacksByType.set(StackType.WORLD, world);

        const wr = world.getWorldRegistry();
        const authorizedVectorSigner = this.admins.worldRegistryAdmin;
        const txn = await wr.addVectorAddressAuthority(await authorizedVectorSigner.getAddress());
        const vaR = await txn.wait();
        if(!vaR || !vaR.status) {
            throw new Error("Failed to add vector address authority");
        }

        const assetStack = new AssetStackImpl(this, worldDeployment);
        await assetStack.deploy();
        this.stacksByType.set(StackType.ASSET, assetStack);

        const avatarStack = new AvatarStackImpl(this, worldDeployment);
        await avatarStack.deploy();
        this.stacksByType.set(StackType.AVATAR, avatarStack);

        const companyStack = new CompanyStackImpl(this, worldDeployment);
        await companyStack.deploy();
        this.stacksByType.set(StackType.COMPANY, companyStack);

        const experienceStack = new ExperienceStackImpl(this, worldDeployment);
        await experienceStack.deploy();
        this.stacksByType.set(StackType.EXPERIENCE, experienceStack);

        const portalStack = new PortalStackImpl(this, worldDeployment);
        await portalStack.deploy();
        this.stacksByType.set(StackType.PORTAL, portalStack);
        const portalRegistry = portalStack.getPortalRegistry();
        await portalRegistry.setExperienceRegistry(experienceStack.getExperienceRegistry().address);
    
        const registrarStack = new RegistrarStackImpl(this, worldDeployment);
        await registrarStack.deploy();
        this.stacksByType.set(StackType.REGISTRAR, registrarStack);

        const reg = registrarStack.getRegistrarRegistry();
        const res = await reg.registerRegistrar({
            defaultSigner: await this.admins.registrarSigner.getAddress(),
            tokens: BigInt("1000000000000000000")
        });
        const regId = res?.registrarId;
        if(!regId) {
            throw new Error("Registrar not registered");
        }
        this.registrarId = regId;

        const baseVector = {
            x: "1",
            y: "1",
            z: "1",
            t: 0n,
            p: 0n,
            p_sub: 0n
        } as VectorAddress;

        const sig = await signVectorAddress(baseVector, this.admins.worldRegistryAdmin);
        const worldRegistration = {
            baseVector,
            name: "Test World",
            initData: "0x",
            vectorAuthoritySignature: sig,
            oldWorld: ZeroAddress,
            owner: await this.admins.worldOwner.getAddress(),
            registrarId: this.registrarId,
            sendTokensToWorldOwner: false
        };
        const wRes = await wr.createWorld({
            registrarSigner: this.admins.registrarSigner,
            details: worldRegistration,
            tokens: ethers.parseEther("1.0")
        });
        if(!wRes.receipt.status) {
            throw new Error("Create world txn failed status 0");
        }
        if(!wRes.worldAddress) {
            throw new Error("Failed to create world");
        }
        this.world = new World({
            address: wRes.worldAddress,
            admin: this.admins.worldOwner
        });
        return {
            world: this.world,
            worldRegistration
        }
    }

    getStack<T>(type: StackType): T {
        const stack = this.stacksByType.get(type);
        if(stack) {
            return stack;
        }
        throw new Error(`Stack not found: ${type}`);
    }

    async getEcosystem(): Promise<{
        world: World,
        company: Company,
        experience: Experience,
        avatar: Avatar,
        testERC20: CreateAssetResult,
        testERC721: CreateAssetResult}> {
        
        const companyRegistration = await this.world.registerCompany({
            sendTokensToCompanyOwner: false,
            owner: await this.admins.companyRegistryAdmin.getAddress(),
            name: "Test Company",
            initData: "0x"
        });
        const company = new Company({
            address: await companyRegistration.companyAddress.toString(),
            admin: this.admins.companyRegistryAdmin
        });
        const TestERC20Asset = await ethers.getContractFactory("TestERC20", this.admins.companyRegistryAdmin)
        const TestERC721Asset = await ethers.getContractFactory("TestERC721", this.admins.companyRegistryAdmin)
        const dep2 = await TestERC721Asset.deploy("Test ERC721 Asset", "TEST721")
        const dep = await TestERC20Asset.deploy("Test ERC20 Asset", "TEST20")
        const testERC20Asset = await dep.waitForDeployment() as TestERC20;
        const testERC721Asset = await dep2.waitForDeployment() as TestERC721;
        const erc20InitData = {
            originChainAddress: await testERC20Asset.getAddress(),
            issuer: company.address,
            originChainId: 1n,
            totalSupply: ethers.parseEther('1000000'),
            decimals: 18,
            name: "Test ERC20 Asset",
            symbol: "TEST20"
        }
        const erc721InitData = {
            issuer: company.address,
            originChainAddress: await testERC721Asset.getAddress(),
            name: "Test ERC721 Asset",
            symbol: "TEST721",
            baseURI: "https://test.com/",
            originChainId: 1n
        }
        const assetRegistry = this.getStack<AssetStackImpl>(StackType.ASSET).getAssetRegistry();
        const testERC20 = await assetRegistry.registerAsset(AssetType.ERC20, erc20InitData)
        const testERC721 = await assetRegistry.registerAsset(AssetType.ERC721, erc721InitData)

        const expRes = await company.addExperience({
            name: "Test Experience",
            connectionDetails: "0x",
            entryFee: 0n,
        });
        const experience = new Experience({
            address: expRes.experienceAddress.toString(),
            portalId: expRes.portalId,
            admin: this.admins.experienceRegistryAdmin
        });
        
        const avatarRegistration = await this.world.registerAvatar({
            sendTokensToAvatarOwner: false,
            avatarOwner: this.userSigner.address,
            defaultExperience: experience.address,
            username: "Test Avatar",
            appearanceDetails: "0x",
            canReceiveTokensOutsideOfExperience: false,
        });

        const avatar = new Avatar({
            address: avatarRegistration.avatarAddress.toString(),
            admin: this.userSigner
        });

        return {
            world: this.world,
            company,
            experience,
            avatar,
            testERC20,
            testERC721
        }
    }



    
    /*
    static async getStack<T extends IBasicDeployArgs>(type: StackType, args: T): Promise<any> {
        const stack = StackFactory.stacksByType.get(type);
        if(stack) {
            return stack;
        }
        switch (type) {
            case StackType.REGISTRAR: {
                
                const r = new RegistrarStackImpl(StackFactory.getStack, args);
                await r.deploy(args);
                StackFactory.stacksByType.set(type, r);
                return r;
            }
            case StackType.ASSET: {
                const a = new AssetStackImpl(StackFactory.getStack);
                await a.deploy(args);
                StackFactory.stacksByType.set(type, a);
                return a;
            }
            case StackType.WORLD: {
                const w = new WorldStackImpl(StackFactory.getStack);
                await w.deploy(args);
                StackFactory.stacksByType.set(type, w);
                return w;
            }
                
            case StackType.AVATAR: {
                const a = new AvatarStackImpl(StackFactory.getStack);
                await a.deploy(args);
                StackFactory.stacksByType.set(type, a);
                return a;
            }

            case StackType.PORTAL: {
                const p = new PortalStackImpl(StackFactory.getStack);
                await p.deploy(args);
                StackFactory.stacksByType.set(type, p);
                return p;
            
            }
            case StackType.EXPERIENCE: {
                const e = new ExperienceStackImpl(StackFactory.getStack);
                await e.deploy(args);
                StackFactory.stacksByType.set(type, e);
                return e;
            }
            case StackType.COMPANY:
                const c = new CompanyStackImpl(StackFactory.getStack);
                await c.deploy(args);
                StackFactory.stacksByType.set(type, c);
                return c
            default:
                throw new Error(`Unsupported stack type: ${type}`);
        }
    }
    */
}