import { Contract } from "ethers";
import {ignition, ethers} from 'hardhat';
import { XRDNASigners } from "../src";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai";
import { Signer } from "ethers";
import ExtensionExampleModule from "../ignition/modules/example/ExtensionExample.module";

describe("RegistrarExample", () => {

    let extContract: Contract;
    let facContract: Contract;
    let signers: HardhatEthersSigner[];
    let registrarOwner: Signer;
    before(async () => {
        const xrdna = new XRDNASigners(ethers.provider);
        const mod = await ignition.deploy(ExtensionExampleModule);
        const addy = await mod.extensionExample.getAddress();
        signers = await ethers.getSigners();

        registrarOwner = xrdna.testingConfig.registrarRegistryAdmin;

        const {abi} = require('../artifacts/generated/abi/ExtensionExampleABI.json');
        console.log("Using abi", abi);
        extContract = new Contract(addy, abi, xrdna.testingConfig.registrarRegistryAdmin);


    });

    
    it("Should add signers", async () => {
       const t = await  extContract.addSigners([signers[9].address]);
       const r = await t.wait();
       expect(r.status).to.be.equal(1);
       //console.log(r);

       const is = await extContract.isSigner(signers[9].address);
       expect(is).to.be.true;

       const owner = await extContract.owner(); 
         expect(owner).to.be.equal(await registrarOwner.getAddress());
    });
   
    
});