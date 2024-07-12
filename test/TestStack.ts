import { RegistrarRegistry, XRDNASigners, AllLogParser, mapJsonToDeploymentAddressConfig, Registrar, signTerms, World, DeploymentAddressConfig, signVectorAddress, VectorAddress, Company, RegistrationTerms, Avatar, Experience, IWorldRegistration, WorldRegistry, CompanyRegistry, AvatarRegistry, ERC20AssetRegistry, ERC721AssetRegistry, ERC20Asset, ERC20InitData, ERC20CreateArgs, ERC721Asset, ERC721InitData, ERC721CreateArgs, IPortalInfo, CreateERC20AssetResult, CreateERC721AssetResult, ICompanyRegistrationRequest, PortalRegistry, ExperienceRegistry } from "../src";
import {ethers, ignition} from 'hardhat';
import TestModule from "../ignition/modules/Test.module";

import HardhatDeployment from '../ignition/deployments/chain-55555/deployed_addresses.json';
import { Signer } from "ethers";


const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const BAYC = "0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D";


export interface IEcosystem {
    registrar: Registrar,
    registrarOwner: Signer,
    world: World,
    worldOwner: Signer,
    world2: World,
    world2Owner: Signer,
    company: Company,
    companyOwner: Signer,
    company2: Company,
    company2Owner: Signer,
    experience: Experience,
    experience2: Experience,
    portalForExperience: IPortalInfo,
    portalForExperience2: IPortalInfo,
    avatar: Avatar,
    avatarOwner: Signer,
    erc20: ERC20Asset,
    erc721: ERC721Asset
}

export class TestStack {

    registrarRegistry?: RegistrarRegistry;
    registrarRegistryOwner?: Signer;
    worldRegistry?: WorldRegistry;
    worldRegistryOwner?: Signer;
    companyRegistry?: CompanyRegistry;
    companyRegistryOwner?: Signer;
    portalRegistry?: PortalRegistry;
    portalRegistryOwner?: Signer;
    experienceRegistry?: ExperienceRegistry;
    experienceRegistryOwner?: Signer;
    avatarRegistry?: AvatarRegistry;
    avatarRegistryOwner?: Signer;
    erc20Registry?: ERC20AssetRegistry;
    erc20RegistryOwner?: Signer;
    erc721Registry?: ERC721AssetRegistry;
    erc721RegistryOwner?: Signer;
    xrdnaSigners: XRDNASigners;
    
    registrar?: Registrar;
    world?: World;
    avatarV2Address?: string;
    logParser?: AllLogParser;

    async init() {
        const xrdna = new XRDNASigners(ethers.provider);
        this.xrdnaSigners = xrdna;
        const mod = await ignition.deploy(TestModule);
        const registryAddr = await mod.registrarRegistryProxy.getAddress();
        this.avatarV2Address = await mod.avatarV2.getAddress();

        this.registrarRegistryOwner = xrdna.testingConfig.registrarRegistryAdmin;
        this.avatarRegistryOwner = xrdna.testingConfig.avatarRegistryAdmin;
        this.companyRegistryOwner = xrdna.testingConfig.companyRegistryAdmin;
        this.experienceRegistryOwner = xrdna.testingConfig.experienceRegistryAdmin;
        this.erc20RegistryOwner = xrdna.testingConfig.assetRegistryAdmin;
        this.erc721RegistryOwner = xrdna.testingConfig.assetRegistryAdmin;
        this.portalRegistryOwner = xrdna.testingConfig.portalRegistryAdmin;
        this.worldRegistryOwner = xrdna.testingConfig.worldRegistryAdmin;

        const signerConfig = mapJsonToDeploymentAddressConfig(HardhatDeployment);
        this.logParser =  new AllLogParser(signerConfig);

        this.registrarRegistry = new RegistrarRegistry({
            address: registryAddr,
            admin: this.registrarRegistryOwner,
            logParser: this.logParser
        });

        const worldAddr = await mod.worldRegistryProxy.getAddress();
        this.worldRegistry = new WorldRegistry({
            address: worldAddr,
            admin: this.registrarRegistryOwner,
            logParser: this.logParser
        });

        const companyAddr = await mod.companyRegistryProxy.getAddress();
        this.companyRegistry = new CompanyRegistry({
            address: companyAddr,
            admin: this.registrarRegistryOwner,
            logParser: this.logParser
        });

        const avatarAddr = await mod.avatarRegistryProxy.getAddress();
        this.avatarRegistry = new AvatarRegistry({
            address: avatarAddr,
            admin: this.registrarRegistryOwner,
            logParser: this.logParser
        });

        const expRegAddr = await mod.experienceRegistryProxy.getAddress();
        this.experienceRegistry = new ExperienceRegistry({
            address: expRegAddr,
            admin: this.registrarRegistryOwner,
            logParser: this.logParser
        });

        const erc20Addr = await mod.erc20RegistryProxy.getAddress();
        this.erc20Registry = new ERC20AssetRegistry({
            address: erc20Addr,
            admin: this.registrarRegistryOwner,
            logParser: this.logParser
        });

        const erc721Addr = await mod.erc721RegistryProxy.getAddress();
        this.erc721Registry = new ERC721AssetRegistry({
            address: erc721Addr,
            admin: this.registrarRegistryOwner,
            logParser: this.logParser
        });
        const portalAddr = await mod.portalRegistryProxy.getAddress();
        this.portalRegistry = new PortalRegistry({
            address: portalAddr,
            admin: this.registrarRegistryOwner,
            logParser: this.logParser
        });
    }

    async initEcosystem(): Promise<IEcosystem> {
        const signers = await ethers.getSigners();
        const registrar = await this.createRegistrar(signers[1]);
        const {world, registration} = await this.createWorld({
            owner: signers[2], registrar
        });
        const {world: world2} = await this.createWorld({
            owner: signers[3], 
            registrar, 
            tokens: ethers.parseEther("1"), 
            name: 'Test World 2'
        });
        const company = await this.createCompany({
            owner: signers[4], 
            world, 
            registrar, 
            tokens: ethers.parseEther("1"), 
            name: 'Test Company'
        });
        const company2 = await this.createCompany({
            owner: signers[5], 
            world, 
            registrar, 
            tokens: ethers.parseEther("1"), 
            name: 'Test Company 2'
        });
        const exp = await company.addExperience({
            connectionDetails: 'https://myapi.com/experience',
            entryFee: 0n,
            name: 'Test Experience'
        });
        const exp2 = await company2.addExperience({
            connectionDetails: 'https://myapi.com/experience2',
            entryFee: ethers.parseEther("0.1"),
            name: 'Test Experience 2'
        });
        if(!exp || !exp.experienceAddress || !exp.portalId) {
            throw new Error('Experience not created');
        }
        if(!exp2 || !exp2.experienceAddress || !exp2.portalId) {
            throw new Error('Experience2 not created');
        }

        const experience = new Experience({
            address: exp.experienceAddress.toString(),
            provider: ethers.provider,
            logParser: this.logParser!,
            portalId: exp.portalId
        });
        const experience2 = new Experience({
            address: exp2.experienceAddress.toString(),
            provider: ethers.provider,
            logParser: this.logParser!,
            portalId: exp2.portalId
        });
        
        const portalForExperience = await this.portalRegistry?.getPortalInfoById(exp.portalId);
        const portalForExperience2 = await this.portalRegistry?.getPortalInfoById(exp2.portalId);
        
        const avatar = await this.createAvatar({
            owner: signers[6], 
            startingLocation: experience, 
            world, 
            registrar, 
            tokens: ethers.parseEther("1")
        });
        const testERC20 = await this.createERC20(company);
        const testERC721 = await this.createERC721(company);
        return {
            registrar,
            registrarOwner: signers[1],
            world,
            worldOwner: signers[2],
            world2,
            world2Owner: signers[3],
            company,
            companyOwner: signers[4],
            company2,
            company2Owner: signers[5],
            experience,
            experience2,
            portalForExperience: portalForExperience!,
            portalForExperience2: portalForExperience2!,
            avatar,
            avatarOwner: signers[6],
            erc20: testERC20,
            erc721: testERC721
        }

    }

    async createRegistrar(owner: Signer): Promise<Registrar> {
        if (!this.registrarRegistry) {
            throw new Error('RegistrarRegistry not initialized');
        }

        const regTerms = {
            fee: 0n,
            coveragePeriodDays: 0n,
            gracePeriodDays: 30n
        };

        const expiration = BigInt(Math.ceil(Date.now() / 1000) + 300);
        const sig = await signTerms({
            signer: owner,
            terms: regTerms,
            termsOwner: this.registrarRegistry!.address,
            expiration
        });
        
        const t = await this.registrarRegistry.registerRemovableRegistrar({
            owner: await owner.getAddress(),
            name: "TestRegistrar",
            sendTokensToOwner: true,
            tokens: ethers.parseEther("0.01"),
            terms: regTerms,
            expiration,
            ownerTermsSignature: sig
        });
        const r = await t.receipt;
        if(!r || !r.status) {
            throw new Error('Transaction failed');
        }
        const logMap = this.logParser!.parseLogs(r);
        const adds = logMap.get("RegistryAddedEntity");
        if(!adds || adds.length !== 1) {
            throw new Error('No entity added');
        }
        const addr = adds![0].args[0];
        if(!addr) {
            throw new Error('No address');
        }
        
        this.registrar = new Registrar({
            registrarAddress: addr,
            admin: owner,
            logParser: this.logParser!
        });
        return this.registrar;
    }

    async createWorld(props: {
        owner: Signer,  
        registrar?: Registrar, 
        tokens?: bigint, 
        name?: string
    }): Promise<{
        world: World,
        registration: IWorldRegistration}> {
        const admin = this.xrdnaSigners.testingConfig.registrarRegistryAdmin;
        let {registrar, owner, tokens, name} = props;

        if(!registrar) {
            registrar = await this.createRegistrar(admin);
        }

        const vectorAuth = this.xrdnaSigners.testingConfig.vectorAddressAuthority;

        const regTerms = {
            fee: 0n,
            coveragePeriodDays: 0n,
            gracePeriodDays: 30n
        };

        const expiration = BigInt(Math.ceil(Date.now() / 1000) + 300);
        const termsSig = await signTerms({
            signer: owner,
            terms: regTerms,
            termsOwner: registrar.address,
            expiration
        });

        const baseVector = {
            x: Math.random().toString(),
            y: "1",
            z: "1",
            t: 0n,
            p: 0n,
            p_sub: 0n
        } as VectorAddress;

        const vectorSig = await signVectorAddress(baseVector, registrar.address, vectorAuth);
        const worldRegistration = {
            sendTokensToOwner: false,
            owner: owner.getAddress(),
            baseVector,
            name: name || 'Test World',
            terms: regTerms,
            ownerTermsSignature: termsSig,
            expiration,
            vectorAuthoritySignature: vectorSig,
            tokens
        };

        const r = await registrar.registerWorld(worldRegistration);
        if(!r || !r.receipt || !r.worldAddress) {
            throw new Error('World not created');
        }
        
        this.world = new World({
            address: r.worldAddress,
            admin: owner,
            logParser: this.logParser!
        });
        return {
            world: this.world,
            registration: worldRegistration
        }
    }

    async createCompany(props:  {
        owner: Signer, 
        world?: World, 
        registrar?: Registrar, 
        tokens?: bigint, 
        name?: string
    }): Promise<Company> {
        let {owner, world, registrar, tokens, name} = props;
        if(!world) {
            const r  = await this.createWorld({
                owner, registrar, tokens
            });
            world = r.world;
        }

        const terms: RegistrationTerms = {
            fee: 0n,
            coveragePeriodDays: 0n,
            gracePeriodDays: 30n
        };
        const expiration = BigInt(Math.ceil(Date.now() / 1000) + 300);
        const termsSign = await signTerms({
            terms,
            signer: owner,
            termsOwner: world!.address,
            expiration
        });
        const req: ICompanyRegistrationRequest = {
            sendTokensToCompanyOwner: false,
            owner: await owner.getAddress(),
            name: name || 'Test Company',
            terms,
            ownerTermsSignature: termsSign,
            expiration
        }  

        const r = await world!.registerCompany(req, tokens);
        if(!r || !r.receipt || !r.companyAddress) {
            throw new Error('Company not created');
        }
        return new Company({
            address: r.companyAddress.toString(),
            admin: owner,
            logParser: this.logParser!
        });
    }

    async createAvatar(props: {
        owner: Signer, 
        startingLocation: Experience, 
        world?: World, 
        registrar?: Registrar, 
        tokens?: bigint
    }): Promise<Avatar>  {
        let {owner, startingLocation, world, registrar, tokens} = props;
        if(!world) {
            const r = await this.createWorld({
                owner, registrar, tokens
            });
            world = r.world;
        }
        const req = {
            sendTokensToOwner: false,
            avatarOwner: await owner.getAddress(),
            username: 'testMe',
            defaultExperience: startingLocation.address,
            canReceiveTokensOutsideOfExperience: false,
            appearanceDetails: "https://myavatar.com/testMe",
        }

        const r = await world!.registerAvatar(req, tokens);
        if(!r || !r.receipt || !r.avatarAddress) {
            throw new Error('Avatar not created');
        }

        return new Avatar({
            address: r.avatarAddress.toString(),
            admin: owner,
            logParser: this.logParser!
        });

    }

    async createERC20(company: Company): Promise<ERC20Asset> {
        const initData: ERC20InitData = {
            decimals: 18,
            maxSupply: ethers.MaxUint256,
        }
        const args: ERC20CreateArgs = {
            name: 'USDC',
            issuer: company.address,
            originChainId: 1n,
            originChainAddress: USDC,
            symbol: 'USDC',
            initData
        }
        const r = await this.erc20Registry!.registerAsset(args);
        if(!r || !r.receipt || !r.assetAddress) {
            throw new Error('Asset not created');
        }
        return new ERC20Asset({
            address: r.assetAddress.toString(),
            provider: ethers.provider,
            logParser: this.logParser!
        });
    }

    async createERC721(company: Company): Promise<ERC721Asset> {
        const initData: ERC721InitData = {
            baseURI: 'https://myapi.com/erc721/',
        };
        const args: ERC721CreateArgs = {
            name: 'Bores Apes Yacht Club',
            issuer: company.address,
            originChainId: 1n,
            originChainAddress: BAYC,
            symbol: 'BAYC',
            initData
        }
        const r = await this.erc721Registry!.registerAsset(args);
        if(!r || !r.receipt || !r.assetAddress) {
            throw new Error('Asset not created');
        }
        return new ERC721Asset({
            address: r.assetAddress.toString(),
            provider: ethers.provider,
            logParser: this.logParser!
        });
    }
}