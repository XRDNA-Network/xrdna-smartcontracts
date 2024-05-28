import {
    time,
    loadFixture,
  } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { ethers } from "hardhat";
import { HardhatTestKeys } from "./HardhatTestKeys";
import { expect } from "chai";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { RegistrarUtils } from "./RegistrarUtils";

describe("RegistrarRegistry", () => {
    
        async function deployRegistry() {
            const w = new ethers.Wallet(HardhatTestKeys[0].key, ethers.provider);
            const Registry = await ethers.getContractFactory("RegistrarRegistry");
            const registry = await Registry.deploy([HardhatTestKeys[1].address]);
            return registry;
        }

        let regUtils: RegistrarUtils;
        before(async () => {
            regUtils = new RegistrarUtils();
            await regUtils.deployRegistry({
                registrarAdmin: (await ethers.getSigners())[0],
                signers: [HardhatTestKeys[1].address]
            });
        })


        
    
        it("should register", async () => {
            const signers = await ethers.getSigners();
            const b4Bal = await ethers.provider.getBalance(signers[2].address);
            const {receipt: r} = await regUtils.registerRegistrar({
                admin: signers[0], 
                signer: signers[2].address, 
                tokens: ethers.parseEther("1")
            });
            expect(r.logs.length).to.equal(1);
            expect(r.logs[0].args[0]).to.equal(1n);
            expect(r.logs[0].args[2]).to.be.greaterThan(0n);
            const afterBal = await ethers.provider.getBalance(signers[2].address);
            if(afterBal <= b4Bal) {
                throw new Error("Balance not updated");
            }
        });

        it("should add signers", async () => {
            const signers = await ethers.getSigners();
            const id = 1n;
            const r2 = await regUtils.addSigners({
                signer: signers[2], 
                registrarId: id, 
                addies: [signers[3].address]
            });
            expect(r2.logs.length).to.equal(1);
            expect(r2.logs[0].args[0]).to.equal(1n);
            expect(r2.logs[0].args[1].length).to.equal(1);
            expect(r2.logs[0].args[1][0]).to.equal(signers[3].address);
        });

        it("Should remove signers", async () => {
            const signers = await ethers.getSigners();
            await regUtils.removeSigners({
                signer: signers[2], 
                registrarId: 1n, 
                addies: [signers[2].address]
            });
            const r2 = await regUtils.isRegistrar({
                registrarId: 1n, signer: signers[2].address
            });
            expect(r2).to.equal(false);
            const r3 = await regUtils.isRegistrar({
                registrarId: 1n, signer: signers[3].address
            });
            expect(r3).to.equal(true);
        });
});