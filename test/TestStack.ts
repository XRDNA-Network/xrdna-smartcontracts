import { RegistrarRegistry, XRDNASigners, AllLogParser, mapJsonToDeploymentAddressConfig, Registrar, signTerms, World, DeploymentAddressConfig, signVectorAddress, VectorAddress, Company, RegistrationTerms, Avatar, Experience, IWorldRegistration, WorldRegistry, CompanyRegistry, AvatarRegistry, ERC20AssetRegistry, ERC721AssetRegistry } from "../src";
import {ethers, ignition} from 'hardhat';
import DeployAllModule from "../ignition/modules/DeployAll.module";

import HardhatDeployment from '../ignition/deployments/chain-55555/deployed_addresses.json';
import { Signer } from "ethers";

export class TestStack {

    registrarRegistry?: RegistrarRegistry;
    worldRegistry?: WorldRegistry;
    companyRegistry?: CompanyRegistry;
    avatarRegistry?: AvatarRegistry;
    erc20Registry?: ERC20AssetRegistry;
    erc721Registry?: ERC721AssetRegistry;
    xrdnaSigners: XRDNASigners;
    registrarRegistryOwner?: Signer;
    registrar?: Registrar;
    world?: World;
    logParser?: AllLogParser;

    async init() {
        const xrdna = new XRDNASigners(ethers.provider);
        this.xrdnaSigners = xrdna;
        const mod = await ignition.deploy(DeployAllModule);
        const registryAddr = await mod.registrarRegistry.getAddress();

        this.registrarRegistryOwner = xrdna.testingConfig.registrarRegistryAdmin;
        const signerConfig = mapJsonToDeploymentAddressConfig(HardhatDeployment);
        this.logParser =  new AllLogParser(signerConfig);

        this.registrarRegistry = new RegistrarRegistry({
            address: registryAddr,
            admin: this.registrarRegistryOwner,
            logParser: this.logParser
        });

        const worldAddr = await mod.worldRegistry.getAddress();
        this.worldRegistry = new WorldRegistry({
            address: worldAddr,
            admin: this.registrarRegistryOwner,
            logParser: this.logParser
        });

        const companyAddr = await mod.companyRegistry.getAddress();
        this.companyRegistry = new CompanyRegistry({
            address: companyAddr,
            admin: this.registrarRegistryOwner,
            logParser: this.logParser
        });

        const avatarAddr = await mod.avatarRegistry.getAddress();
        this.avatarRegistry = new AvatarRegistry({
            address: avatarAddr,
            admin: this.registrarRegistryOwner,
            logParser: this.logParser
        });

        const erc20Addr = await mod.erc20Registry.getAddress();
        this.erc20Registry = new ERC20AssetRegistry({
            address: erc20Addr,
            admin: this.registrarRegistryOwner,
            logParser: this.logParser
        });

        const erc721Addr = await mod.erc721Registry.getAddress();
        this.erc721Registry = new ERC721AssetRegistry({
            address: erc721Addr,
            admin: this.registrarRegistryOwner,
            logParser: this.logParser
        });
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

    async createWorld(owner: Signer,  registrar?: Registrar, tokens?: bigint, ): Promise<{
        world: World,
        registration: IWorldRegistration}> {
        const admin = this.xrdnaSigners.testingConfig.registrarRegistryAdmin;
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
            x: "1",
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
            name: 'Test World',
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

    async createCompany(owner: Signer, world?: World, registrar?: Registrar, tokens?: bigint): Promise<Company> {
        if(!world) {
            const r  = await this.createWorld(owner, registrar, tokens);
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
        const req = {
            sendTokensToCompanyOwner: false,
            owner: await owner.getAddress(),
            name: 'Test Company',
            terms,
            ownerTermsSignature: termsSign,
            expiration
        }  

        const r = await world!.registerCompany(req);
        if(!r || !r.receipt || !r.companyAddress) {
            throw new Error('Company not created');
        }
        return new Company({
            address: r.companyAddress.toString(),
            admin: owner,
            logParser: this.logParser!
        });
        
    }

    async createAvatar(owner: Signer, startingLocation: Experience, world?: World, registrar?: Registrar, tokens?: bigint): Promise<Avatar>  {
        if(!world) {
            const r = await this.createWorld(owner, registrar, tokens);
            world = r.world;
        }
        const req = {
            sendTokensToOwner: false,
            avatarOwner: await owner.getAddress(),
            username: 'testMe',
            defaultExperience: startingLocation.address,
            canReceiveTokensOutsideOfExperience: false,
            appearanceDetails: "https://myavatar.com/testMe"
        }

        const r = await world!.registerAvatar(req);
        if(!r || !r.receipt || !r.avatarAddress) {
            throw new Error('Avatar not created');
        }

        return new Avatar({
            address: r.avatarAddress.toString(),
            admin: owner,
            logParser: this.logParser!
        });

    }
}