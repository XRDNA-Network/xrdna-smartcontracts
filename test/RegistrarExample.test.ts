import { Contract } from "ethers";
import {ignition, ethers} from 'hardhat';
import { AllLogParser, XRDNASigners, mapJsonToDeploymentAddressConfig, signTerms } from "../src";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai";
import { Signer } from "ethers";
import DeployAllModule from "../ignition/modules/DeployAll.module";
import {RegistrarRegistry, Registrar} from '../src';

import HardhatDeployment from '../ignition/deployments/chain-55555/deployed_addresses.json';

describe("RegistrarExample", () => {

    let signers: HardhatEthersSigner[];
    let registrarOwner: Signer;
    let registrarRegistry: RegistrarRegistry;
    let registrarRegistryOwner: Signer;
    let logParser: AllLogParser;
    before(async () => {
        const xrdna = new XRDNASigners(ethers.provider);
        const mod = await ignition.deploy(DeployAllModule);
        const registryAddr = await mod.registrarRegistry.getAddress();
        const worldAddr = await mod.world.getAddress();
        const worldRegistryAddr = await mod.worldRegistry.getAddress();
        const registrarAddr = await mod.registrar.getAddress();

        console.log(`RegistrarRegistry: ${registryAddr}`);
        console.log(`World: ${worldAddr}`);
        console.log(`WorldRegistry: ${worldRegistryAddr}`);
        console.log(`Registrar: ${registrarAddr}`);

        signers = await ethers.getSigners();
        registrarRegistryOwner = xrdna.testingConfig.registrarRegistryAdmin;
        registrarOwner = signers[3];
        const depConfig = mapJsonToDeploymentAddressConfig(HardhatDeployment);
        logParser =  new AllLogParser(depConfig);

        registrarRegistry = new RegistrarRegistry({
            address: registryAddr,
            admin: registrarRegistryOwner,
            logParser
        });
    });

    
    it("Should add signers", async () => {
       const t = await  registrarRegistry.addSigners([signers[9].address]);
       const r = await t.wait();
       expect(r).to.be.not.undefined;
       expect(r!.status).to.be.equal(1);

       const is = await registrarRegistry.isSigner(signers[9].address);
       expect(is).to.be.true;

       const owner = await registrarRegistry.owner(); 
        expect(owner).to.be.equal(await registrarRegistryOwner.getAddress());
    });

    it("Should register registrar", async () => {
        const regTerms = {
            fee: 0n,
            coveragePeriodDays: 0n,
            gracePeriodDays: 30n
        };

        const expiration = BigInt(Math.ceil(Date.now() / 1000) + 60);

        const sig = await signTerms({
            signer: registrarOwner,
            terms: regTerms,
            termsOwner: registrarRegistry.address,
            expiration
        });
        
        const t = await registrarRegistry.registerRemovableRegistrar({
            owner: await registrarOwner.getAddress(),
            name: "TestRegistrar",
            sendTokensToOwner: true,
            tokens: ethers.parseEther("0.01"),
            terms: regTerms,
            expiration,
            ownerTermsSignature: sig
        });
        const r = await t.receipt;
        expect(r).to.be.not.undefined;
        expect(r.status).to.be.equal(1);
        const logMap = logParser.parseLogs(r);
        const adds = logMap.get("RegistryAddedEntity");
        expect(adds).to.be.not.undefined;
        expect(adds!.length).to.be.equal(1);
        const addr = adds![0].args[0];
        expect(addr).to.be.not.undefined;
        
        const registrar = new Registrar({
            registrarAddress: addr,
            admin: registrarOwner,
            logParser
        });
        const owner = await registrar.owner();
        expect(owner).to.be.equal(await registrarOwner.getAddress());
        const isSigner = await registrar.isSigner(await registrarOwner.getAddress());
        expect(isSigner).to.be.true
    });
    
   
    
});