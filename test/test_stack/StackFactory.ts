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
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { IPortalInfo } from "../../src/portal";

export enum StackType {
    REGISTRAR = "REGISTRAR",
    ASSET = "ASSET",
    WORLD = "WORLD",
    AVATAR = "AVATAR",
    COMPANY = "COMPANY",
    EXPERIENCE = "EXPERIENCE",
    PORTAL = "PORTAL"
}

const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const BAYC = "0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D";

export interface IStackAdmins {
    assetRegistryAdmin: Signer;
    avatarRegistryAdmin: Signer;
    avatarOwner: Signer;
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
    world?: World;
    constructor(readonly admins: IStackAdmins) {}


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
        world2: World,
        company: Company,
        company2: Company,
        experience: Experience,
        experience2: Experience,
        portalForExperience: IPortalInfo,
        portalForExperience2: IPortalInfo,
        avatar: Avatar,
        testERC20: CreateAssetResult,
        testERC721: CreateAssetResult}> {
        if (!this.world) {
            throw new Error("World not initialized");
        }

        const baseVector = {
            x: "2",
            y: "2",
            z: "2",
            t: 0n,
            p: 0n,
            p_sub: 0n
        } as VectorAddress;

        const sig = await signVectorAddress(baseVector, this.admins.worldRegistryAdmin);
        const worldRegistration = {
            baseVector,
            name: "Test World 2",
            initData: "0x",
            vectorAuthoritySignature: sig,
            oldWorld: ZeroAddress,
            owner: await this.admins.worldOwner.getAddress(),
            registrarId: this.registrarId!,
            sendTokensToWorldOwner: false
        };
        const wr = this.getStack<WorldStackImpl>(StackType.WORLD).getWorldRegistry();
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
        const world2 = new World({
            address: wRes.worldAddress,
            admin: this.admins.worldOwner
        });

        const companyRegistration = await this.world.registerCompany({
            sendTokensToCompanyOwner: false,
            owner: await this.admins.companyRegistryAdmin.getAddress(),
            name: "Test Company",
        }, ethers.parseEther("1.0"));
        const company2Registration = await this.world.registerCompany({
            sendTokensToCompanyOwner: false,
            owner: await this.admins.companyRegistryAdmin.getAddress(),
            name: "Test Company 2",
        }, ethers.parseEther("1.0"));
        const company = new Company({
            address: await companyRegistration.companyAddress.toString(),
            admin: this.admins.companyRegistryAdmin
        });
        const company2 = new Company({
            address: await company2Registration.companyAddress.toString(),
            admin: this.admins.companyRegistryAdmin
        });
        const erc20InitData = {
            originChainAddress:  USDC,
            issuer: company.address,
            originChainId: 1n,
            totalSupply: ethers.parseEther('1000000'),
            decimals: 6,
            name: "Test ERC20 Asset",
            symbol: "TEST20"
        }
        const erc721InitData = {
            issuer: company.address,
            originChainAddress: BAYC,
            name: "Bored Ape Yacht Club",
            symbol: "BAYC",
            baseURI: "https://boredapeyachtclub.com",
            originChainId: 1n
        }
        const assetRegistry = this.getStack<AssetStackImpl>(StackType.ASSET).getAssetRegistry();
        const testERC20 = await assetRegistry.registerAsset(AssetType.ERC20, erc20InitData)
        const testERC721 = await assetRegistry.registerAsset(AssetType.ERC721, erc721InitData)

        const expRes = await company.addExperience({
            name: "Test Experience",
            connectionDetails: ethers.hexlify(Buffer.from("https://example.com")),
            entryFee: 0n,
        });
        const expRes2 = await company2.addExperience({
            name: "Test Experience 2",
            connectionDetails: ethers.hexlify(Buffer.from("https://example2.com")),
            entryFee: ethers.parseEther("0.1"),
        });
        const experience = new Experience({
            address: expRes.experienceAddress.toString(),
            portalId: expRes.portalId,
            provider: ethers.provider
        });
        const experience2 = new Experience({
            address: expRes2.experienceAddress.toString(),
            portalId: expRes2.portalId,
            provider: ethers.provider
        });
        
        const avatarRegistration = await this.world.registerAvatar({
            sendTokensToAvatarOwner: false,
            avatarOwner: this.admins.avatarOwner.getAddress(),
            defaultExperience: experience.address,
            username: "Test Avatar",
            appearanceDetails: "0x",
            canReceiveTokensOutsideOfExperience: false,
        }, ethers.parseEther("1.0"));

        const avatar = new Avatar({
            address: avatarRegistration.avatarAddress.toString(),
            admin: this.admins.avatarOwner
        });

        const pr = this.getStack<PortalStackImpl>(StackType.PORTAL).getPortalRegistry();
        const portalForExperience = await pr.getPortalInfoById(expRes.portalId);
        const portalForExperience2 = await pr.getPortalInfoById(expRes2.portalId);

        return {
            world: this.world,
            world2,
            company,
            company2,
            experience,
            experience2,
            portalForExperience,
            portalForExperience2,
            avatar,
            testERC20,
            testERC721
        }
    }
}