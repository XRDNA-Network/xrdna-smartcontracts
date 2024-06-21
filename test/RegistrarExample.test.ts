import { Contract } from "ethers";
import {ignition, ethers} from 'hardhat';
import RegistrarExampleModule from '../ignition/RegistrarExample.module';
import {abi as RegABI} from '../artifacts/contracts/registrar/RegistrarExample.sol/RegistrarExample.json'
import {abi as SignersABI} from '../artifacts/contracts/interfaces/common/ISupportsSigners.sol/ISupportsSigners.json'
import {abi as FundsABI} from '../artifacts/contracts/interfaces/common/ISupportsFunds.sol/ISupportsFunds.json'
import {abi as OwnerABI} from '../artifacts/contracts/interfaces/common/ISupportsOwner.sol/ISupportsOwner.json'
import {abi as RegistrarFactoryABI} from '../artifacts/contracts/registrar/RegistrarFactory.sol/RegistrarFactory.json'
import {abi as RegInitABI} from '../artifacts/contracts/interfaces/registrar/IRegistrarInit.sol/IRegistrarInit.json';
import { XRDNASigners } from "../src";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai";
import { Signer } from "ethers";

describe("RegistrarExample", () => {

    let regContract: Contract;
    let facContract: Contract;
    let signers: HardhatEthersSigner[];
    let registrarOwner: Signer;
    before(async () => {
        const xrdna = new XRDNASigners(ethers.provider);
        const mod = await ignition.deploy(RegistrarExampleModule);
        const addy = await mod.registrarExample.getAddress();
        const facAddy = await mod.factory.getAddress();
        signers = await ethers.getSigners();

        registrarOwner = xrdna.testingConfig.registrarRegistryAdmin;

        regContract = new Contract(addy, [
            //...RegABI,
            ...SignersABI,
            ...FundsABI,
            ...OwnerABI,
            ...RegInitABI
        ], xrdna.testingConfig.registrarRegistryAdmin);

        facContract = new Contract(facAddy, [
            ...RegistrarFactoryABI
        ], xrdna.testingConfig.registrarRegistryAdmin);
        
    });

    /*
    it("Should add signers", async () => {
       const t = await  regContract.addSigners([signers[9].address]);
       const r = await t.wait();
       expect(r.status).to.be.equal(1);
       //console.log(r);

       const is = await regContract.isSigner(signers[9].address);
       expect(is).to.be.true;

       const owner = await regContract.owner(); 
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
        const ifc = regContract.interface;
        const enc = ifc.encodeFunctionData("init", [args]);
        console.log("Selector", enc.substring(0, 10));
        const t = await regContract.init(args);
        //const t = await facContract.simpleInitRegistrar(await registrarOwner.getAddress(), regContract.getAddress());
        const r = await t.wait();
        expect(r.status).to.be.equal(1);
        //console.log(r);
    });
});