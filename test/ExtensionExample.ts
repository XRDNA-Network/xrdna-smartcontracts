import { Contract } from "ethers";
import {ignition, ethers} from 'hardhat';
import {abi as RegABI} from '../artifacts/contracts/registrar/RegistrarExample.sol/RegistrarExample.json'
import {abi as SignersABI} from '../artifacts/contracts/interfaces/common/ISupportsSigners.sol/ISupportsSigners.json'
import {abi as FundsABI} from '../artifacts/contracts/interfaces/common/ISupportsFunds.sol/ISupportsFunds.json'
import {abi as OwnerABI} from '../artifacts/contracts/interfaces/common/ISupportsOwner.sol/ISupportsOwner.json'
import {abi as FactoryABI} from '../artifacts/contracts/registrar/RegistrarFactory.sol/RegistrarFactory.json'
import { XRDNASigners } from "../src";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai";
import { Signer } from "ethers";
import ExtensionExampleModule from "../ignition/ExtensionExample.module";

describe("RegistrarExample", () => {

    let extContract: Contract;
    let facContract: Contract;
    let signers: HardhatEthersSigner[];
    let registrarOwner: Signer;
    before(async () => {
        const xrdna = new XRDNASigners(ethers.provider);
        const mod = await ignition.deploy(ExtensionExampleModule);
        const addy = await mod.extensionExample.getAddress();
        const fAddy = await mod.factory.getAddress();
        signers = await ethers.getSigners();

        registrarOwner = xrdna.testingConfig.registrarRegistryAdmin;

        extContract = new Contract(addy, [
            //...RegABI,
            ...SignersABI,
            ...FundsABI,
            ...OwnerABI,
        ], xrdna.testingConfig.registrarRegistryAdmin);

        facContract = new Contract(fAddy, [
            ...FactoryABI
        ], xrdna.testingConfig.registrarRegistryAdmin);

    });

    /*
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
    */

        
    it("Factory should initialize", async () => {
        const args = {
            sendTokensToOwner: true,

            //globally unique name of the registrar
            name: "Test Registrar",

            //the owner to assign to the registrar contract and transfer
            //any initial tokens to if required
            owner: await registrarOwner.getAddress(),

            //the registration terms for the registrar
            worldRegistrationTerms: {
                fee: 0n,

                coveragePeriod: 0,

                gracePeriod: 0,
            }
        }
        const t = await facContract.initRegistrar(args, extContract.getAddress());
        const r = await t.wait();
        expect(r.status).to.be.equal(1);
        //console.log(r);
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