import { Contract } from "ethers";
import {ignition, ethers} from 'hardhat';
import { XRDNASigners } from "../src";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai";
import { Signer } from "ethers";
import DeployAllModule from "../ignition/modules/DeployAll.module";
import {abi as proxyABI} from "../ignition/modules/example/ExampleProxy.module";
import {abi as exABI} from '../ignition/modules/example/Example.module';

describe("Example", () => {

    let example: Contract;
    let signers: HardhatEthersSigner[];
    let exampleOwner: Signer;
    before(async () => {
        const xrdna = new XRDNASigners(ethers.provider);
        const mod = await ignition.deploy(DeployAllModule);
        const addy = await mod.exampleProxy.getAddress();
        signers = await ethers.getSigners();

        exampleOwner = signers[0];

        example = new Contract(addy, [
            ...proxyABI,
            ...exABI
        ], exampleOwner);


    });

    
    it("Should add signers", async () => {
       const t = await  example.addSigners([signers[9].address]);
       const r = await t.wait();
       expect(r.status).to.be.equal(1);
       //console.log(r);

       const is = await example.isSigner(signers[9].address);
       expect(is).to.be.true;

       const owner = await example.owner(); 
         expect(owner).to.be.equal(await exampleOwner.getAddress());
    });

    it("Should not let non-admin add signer", async () => {
        const c = new Contract(await example.getAddress(), example.interface, signers[9]);
        let ok = false;
        try {
            const t = await c.addSigners([signers[8].address]);
            const r = await t.wait();
            
        } catch (e:any) {
            if(e.message.indexOf("not an admin") < 0) {
                throw e;
            }
            ok = true;
        }
        if(!ok) {
            throw new Error("Should have failed");
        }
    });
   
    
});