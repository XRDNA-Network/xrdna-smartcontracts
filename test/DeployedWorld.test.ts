import { ethers } from "hardhat";
import { WorldUtils } from "./world/WorldUtils";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { RegistrarRegistry, VectorAddress, World, WorldRegistry } from "../src";
import { expect } from "chai";
import { ZeroAddress } from "ethers";


//deployed to local network
const RegistrarRegistryAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
const WorldFactoryAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
const WorldRegistryAddress = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";
const WorldImplementationAddress = "0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9";

describe("World Registration", () => {

    let signers: HardhatEthersSigner[];
    let registrarAdmin: HardhatEthersSigner;
    let registrarSigner: HardhatEthersSigner;
    let worldFactoryAdmin: HardhatEthersSigner;
    let worldRegistryAdmin: HardhatEthersSigner;
    let worldOwner: HardhatEthersSigner;
    let registrarId: bigint = 1n;
    let registrarRegistry: RegistrarRegistry;
    let worldRegistry: WorldRegistry;

    
    before(async () => {

        signers = await ethers.getSigners();
        registrarAdmin = signers[0];
        registrarSigner = signers[0];
        worldFactoryAdmin = signers[0];
        worldRegistryAdmin = signers[0];
        worldOwner = signers[1];


        registrarRegistry = new RegistrarRegistry({
            address: RegistrarRegistryAddress,
            admin: registrarAdmin
        });
        worldRegistry = new WorldRegistry({
            address: WorldRegistryAddress,
            admin: worldRegistryAdmin
        });

        const isRegistered = await registrarRegistry.isSignerForRegistrar({
            registrarId: 1n,
            signer: registrarSigner.address
        });
        if(isRegistered) {
            return;
        }
        const r = await registrarRegistry.registerRegistrar({
            defaultSigner: registrarSigner.address,
            tokens: BigInt("1000000000000000000")
        });
        const regId = r?.registrarId;
        if(!regId) {
            throw new Error("Registrar not registered");
        }
        registrarId = regId;
    });

    async function getDeployedWorldAddress() {
        return await worldRegistry.lookupWorldAddress("tEsTwOrLd");
    }

    it("Should register a world", async () => {
        const a = await getDeployedWorldAddress();
        if(a !== ZeroAddress) {
            console.log("World already registered at", a);
            return;
        }

        const r = await worldRegistry.createWorld({
            registrarSigner,
            registrarId,
            owner: worldOwner.address,
            tokensToOwner: false,
            details: {
                baseVector: {
                x: "1",
                y: "1",
                z: "1",
                t: 0n,
                p: 0n,
                p_sub: 0n
            } as VectorAddress,
            name: "TestWorld",
            },
            tokens: BigInt("1000000000000000000")
        });
        
        expect(r).to.not.be.undefined;

        expect(r?.worldAddress).to.not.be.undefined;
        expect(r?.worldAddress).to.not.equal("0x0000000000000000000000000000000000000000000000000000000000000000");
        
        //should be able to lookup world by name
        const addr = await worldRegistry.lookupWorldAddress("tEsTwOrLd");
        expect(addr).to.not.be.undefined;
        expect(addr).to.equal(r?.worldAddress);
        console.log("World registered at", r?.worldAddress);

    });

    it("Should allow signers to be added", async () => {
        const addy = await getDeployedWorldAddress();
        const w = new World({
            address: addy,
            admin: worldOwner
        });
        const t = await w.addSigners([signers[8].address]);
        expect(t).to.not.be.undefined;
        const r = await t.wait();
        expect(r).to.not.be.undefined;
        expect(r?.status).to.equal(1);
        const is = await w.isSigner(signers[8].address);
        expect(is).to.equal(true);

    });

    it("Should not allow signers to be added by non-owner", async () => {
        let fail = false;
        try {
            const addy = await getDeployedWorldAddress();
            const w = new World({
                address: addy,
                admin: signers[9]
            });
            const r = await w.addSigners( [signers[9].address] );
            if(r) {
                fail = true;
            }
        } catch(e:any) {
            expect(e.message).to.not.be.undefined;
            if(e.message.indexOf("AccessControlUnauthorizedAccount") < 0) {
                throw e;
            }
        }
    });

    it("Should remove signers", async () => {
        const address = await getDeployedWorldAddress();
        const w = new World({
            address,
            admin: worldOwner
        });

        const b4 = await w.isSigner( signers[8].address );
        expect(b4).to.equal(true);

        const t = await w.removeSigners( [signers[8].address] );
        expect(t).to.not.be.undefined;
        const r = await t.wait();
        expect(r).to.not.be.undefined;
        expect(r!.status).to.equal(1);
        const is = await w.isSigner( signers[8].address );
        expect(is).to.equal(false);
    });

    it("Should not allow non-signer to withdraw funds", async () => {
        let fail = false;
        try {
            const addy = await getDeployedWorldAddress();
            const w = new World({
                address: addy,
                admin: signers[9]
            });
            const r = await w.withdraw( BigInt("1000000000000000000") );
            if(r) {
                fail = true;
            }
        } catch(e:any) {
            expect(e.message).to.not.be.undefined;
            if(e.message.indexOf("AccessControlUnauthorizedAccount") < 0) {
                throw e;
            }
        }
    });

    it("Should allow owner to withdraw funds", async () => {
        const addy = await getDeployedWorldAddress();
        const txn = await signers[0].sendTransaction({
            to: addy,
            value: BigInt("1000000000000000000")
        });
        const receipt = await txn.wait();
        expect(receipt).to.not.be.undefined;
        expect(receipt!.status).to.equal(1);

        const b4 = await ethers.provider.getBalance(worldOwner.address);
        
        const w = new World({
            address: addy,
            admin: worldOwner
        });
        const t = await w.withdraw( BigInt("1000000000000000000") );
        expect(t).to.not.be.undefined;
        const r = await t.wait();
        expect(r).to.not.be.undefined;
        expect(r!.status).to.equal(1);
        const after = await ethers.provider.getBalance(worldOwner.address);
        expect(after).to.be.greaterThan(b4);
    });
});