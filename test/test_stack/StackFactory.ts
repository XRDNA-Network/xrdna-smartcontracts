import { Signer, ZeroAddress } from "ethers";
import { ERC20AssetStackImpl } from "./asset/erc20/ERC20AssetStackImpl";
import { ERC721AssetStackImpl } from "./asset/erc721/ERC721AssetStackImpl";
import { AvatarStackImpl } from "./avatar/AvatarStackImpl";
import { PortalStackImpl } from "./portal/PortalStackImpl";
import { ExperienceStackImpl } from "./experience/ExperienceStackImpl";
import { WorldStackImpl } from "./world/WorldStackImpl";
import { CompanyStackImpl } from "./company/CompanyStackImpl";
import { RegistrarStackImpl} from "./registrar/RegistrarStackImpl";
import { ethers, network } from "hardhat";
import { AllLogParser, CreateERC20AssetResult, CreateERC721AssetResult, DeploymentAddressConfig, ERC20InitData, IWorldRegistration, VectorAddress, World, mapJsonToDeploymentAddressConfig, signVectorAddress } from "../../src";
import { Company } from "../../src/company/Company";
import { Experience } from "../../src/experience";
import { Avatar } from "../../src/avatar/Avatar";
import { IPortalInfo } from "../../src/portal";
import { IERC20AssetStack } from "./asset/erc20/IERC20AssetStack";
import { IERC721AssetStack } from "./asset/erc721/IERC721AssetStack";
import { MultiAssetRegistryStackImpl } from "./asset/MultiAssetRegistryStackImpl";
import { XRDNASigners } from "../../src";
import HardhatDeployment from '../../ignition/deployments/chain-55555/deployed_addresses.json';

export interface IEcosystem {
        world: World,
        world2: World,
        company: Company,
        company2: Company,
        experience: Experience,
        experience2: Experience,
        portalForExperience: IPortalInfo,
        portalForExperience2: IPortalInfo,
        avatar: Avatar,
        testERC20: CreateERC20AssetResult,
        testERC721: CreateERC721AssetResult
    }

export enum StackType {
    REGISTRAR = "REGISTRAR",
    ERC20 = "ERC20",
    ERC721 = "ERC721",
    MULTI_ASSET = "MULT_ASSET",
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
    companyRegistryAdmin: Signer;
    experienceRegistryAdmin: Signer;
    portalRegistryAdmin: Signer;
    registrarAdmin: Signer;
    registrarSigner: Signer;
    worldRegistryAdmin: Signer;
    vectorAuthority: Signer;
}

export interface IEntityOwners {
    avatarOwner: Signer;
    companyOwner: Signer;
    worldOwner: Signer;
}

export class StackFactory {
    stacksByType: Map<string, any> = new Map();
    registrarId?: bigint;
    world?: World;
    readonly admins: IStackAdmins;
    readonly logParser: AllLogParser;
    constructor(readonly owners: IEntityOwners) {
        const xrdna = new XRDNASigners(ethers.provider);
        const config = xrdna.testingConfig;
        this.admins = {
            assetRegistryAdmin: config.assetRegistryAdmin,
            avatarRegistryAdmin: config.avatarRegistryAdmin,
            companyRegistryAdmin: config.companyRegistryAdmin,
            experienceRegistryAdmin: config.experienceRegistryAdmin,
            portalRegistryAdmin: config.portalRegistryAdmin,
            registrarAdmin: config.registrarRegistryAdmin,
            registrarSigner: config.registrarRegistryAdmin,
            worldRegistryAdmin: config.worldRegistryAdmin,
            vectorAuthority: config.vectorAddressAuthority
        }
        const depConfig: DeploymentAddressConfig = mapJsonToDeploymentAddressConfig(HardhatDeployment);
        this.logParser = new AllLogParser(depConfig);
    }


    async init(): Promise<{world: World, worldRegistration: IWorldRegistration}> {

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

        const erc20Stack = new ERC20AssetStackImpl(this, worldDeployment);
        await erc20Stack.deploy();
        this.stacksByType.set(StackType.ERC20, erc20Stack);

        const erc721Stack = new ERC721AssetStackImpl(this, worldDeployment);
        await erc721Stack.deploy();
        this.stacksByType.set(StackType.ERC721, erc721Stack);

        const multiAssetStack = new MultiAssetRegistryStackImpl(this, worldDeployment);
        //no deploy needed
        this.stacksByType.set(StackType.MULTI_ASSET, multiAssetStack);

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

        const sig = await signVectorAddress(baseVector, this.registrarId, this.admins.worldRegistryAdmin);
        const worldRegistration = {
            baseVector,
            name: "Test World",
            initData: "0x",
            vectorAuthoritySignature: sig,
            oldWorld: ZeroAddress,
            owner: await this.owners.worldOwner.getAddress(),
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
            admin: this.owners.worldOwner,
            logParser: this.logParser
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

    async getEcosystem(): Promise<IEcosystem> {
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

        const sig = await signVectorAddress(baseVector, this.registrarId!, this.admins.worldRegistryAdmin);
        const worldRegistration = {
            baseVector,
            name: "Test World 2",
            initData: "0x",
            vectorAuthoritySignature: sig,
            oldWorld: ZeroAddress,
            owner: await this.owners.worldOwner.getAddress(),
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
            admin: this.owners.worldOwner,
            logParser: this.logParser
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
            admin: this.admins.companyRegistryAdmin,
            logParser: this.logParser
        });
        const company2 = new Company({
            address: await company2Registration.companyAddress.toString(),
            admin: this.admins.companyRegistryAdmin,
            logParser: this.logParser
        });
        const erc20InitData: ERC20InitData = {
            originChainAddress:  USDC,
            issuer: company.address,
            originChainId: 1n,
            decimals: 6,
            name: "Test ERC20 Asset",
            symbol: "TEST20",
            maxSupply: 100000000000000000000n
        }
        const erc721InitData = {
            issuer: company.address,
            originChainAddress: BAYC,
            name: "Bored Ape Yacht Club",
            symbol: "BAYC",
            baseURI: "https://boredapeyachtclub.com",
            originChainId: 1n

        }
        const erc20Registry = this.getStack<IERC20AssetStack>(StackType.ERC20).getERC20Registry();
        const testERC20 = await erc20Registry.registerAsset(erc20InitData)
        
        const erc721Registry = this.getStack<IERC721AssetStack>(StackType.ERC721).getERC721Registry();
        const testERC721 = await erc721Registry.registerAsset(erc721InitData)

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
            provider: ethers.provider,
            logParser: this.logParser
        });
        const experience2 = new Experience({
            address: expRes2.experienceAddress.toString(),
            portalId: expRes2.portalId,
            provider: ethers.provider,
            logParser: this.logParser
        });
        
        const avatarRegistration = await this.world.registerAvatar({
            sendTokensToAvatarOwner: false,
            avatarOwner: this.owners.avatarOwner.getAddress(),
            defaultExperience: experience.address,
            username: "Test Avatar",
            appearanceDetails: "0x",
            canReceiveTokensOutsideOfExperience: false,
        }, ethers.parseEther("1.0"));

        const avatar = new Avatar({
            address: avatarRegistration.avatarAddress.toString(),
            admin: this.owners.avatarOwner,
            logParser: this.logParser
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