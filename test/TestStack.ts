import { RegistrarRegistry, XRDNASigners, AllLogParser, mapJsonToDeploymentAddressConfig, Registrar, signTerms, World, DeploymentAddressConfig, signVectorAddress, VectorAddress } from "../src";
import {ethers, ignition} from 'hardhat';
import DeployAllModule from "../ignition/modules/DeployAll.module";

import HardhatDeployment from '../ignition/deployments/chain-55555/deployed_addresses.json';
import { Signer } from "ethers";

export class TestStack {

    registrarRegistry?: RegistrarRegistry;
    xrdnaSigners: XRDNASigners;
    registrarRegistryOwner?: Signer;
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

        const expiration = BigInt(Math.ceil(Date.now() / 1000) + 60);
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
        
        return new Registrar({
            registrarAddress: addr,
            admin: owner,
            logParser: this.logParser!
        });
    }

    async createWorld(owner: Signer,  tokens?: bigint, registrar?: Registrar): Promise<World> {
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

        const expiration = BigInt(Math.ceil(Date.now() / 1000) + 60);
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
        
        return new World({
            address: r.worldAddress,
            admin: owner,
            logParser: this.logParser!
        });
    }
}