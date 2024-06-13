
import { ethers } from "hardhat";
import { HardhatTestKeys } from "./HardhatTestKeys";
import { expect } from "chai";
import { IRegistrarStack } from "./test_stack/registrar/IRegistrarStack";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { StackFactory, StackType } from "./test_stack/StackFactory";
import { Registrar } from "../src";

describe("RegistrarRegistry", () => {
    
        async function deployRegistry() {
            const w = new ethers.Wallet(HardhatTestKeys[0].key, ethers.provider);
            const Registry = await ethers.getContractFactory("RegistrarRegistry");
            const registry = await Registry.deploy([HardhatTestKeys[1].address]);
            return registry;
        }

        let signers: HardhatEthersSigner[];
        let registrarAdmin: HardhatEthersSigner;
        let registrarSigner: HardhatEthersSigner;
        let registrar: Registrar;
        let stack: StackFactory;
        before(async () => {
            signers = await ethers.getSigners();
        
            registrarAdmin = signers[0];
            registrarSigner = signers[9];
            stack = new StackFactory({
                companyOwner: signers[1],
                worldOwner: signers[1],
                avatarOwner: signers[1],
            });
            await stack.init();
            
        })

        it("should register", async () => {
            const b4Bal = await ethers.provider.getBalance(registrarSigner.address);
            const reg = stack.getStack<IRegistrarStack>(StackType.REGISTRAR);
            const registry = reg.getRegistrarRegistry();
            const r = await registry.registerRegistrar({
                defaultSigner:registrarSigner.address,
                tokens: ethers.parseEther("1")
            });
            expect(r).to.not.be.null;
            expect(r.registrarId).to.be.greaterThan(0);
            expect(r.receipt.status).to.equal(1);
            registrar = new Registrar({
                registrarRegistryAddress: registry.address,
                admin: registrarSigner,
                registrarId: r.registrarId
            });
            
            const afterBal = await ethers.provider.getBalance(registrarSigner.address);
            if(afterBal <= b4Bal) {
                throw new Error("Balance not updated");
            }
        });

        it("should add signers", async () => {
            await registrar.addSigners([signers[3].address]);
            const registry = stack.getStack<IRegistrarStack>(StackType.REGISTRAR).getRegistrarRegistry();
            const t = await registry.isSignerForRegistrar({
                registrarId: registrar.registrarId, 
                signer: signers[3].address
            });
            expect(t).to.equal(true);
        });

        it("Should remove signers", async () => {

            await registrar.removeSigners([signers[2].address]);
            const registry = stack.getStack<IRegistrarStack>(StackType.REGISTRAR).getRegistrarRegistry();;
            
            const r2 = await registry.isSignerForRegistrar({
                registrarId: registrar.registrarId, 
                signer: signers[2].address
            });
            expect(r2).to.equal(false);
            const r3 = await registry.isSignerForRegistrar({
                registrarId: registrar.registrarId, signer: signers[3].address
            });
            expect(r3).to.equal(true);
        });
});