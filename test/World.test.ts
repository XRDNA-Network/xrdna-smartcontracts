import { ethers } from "hardhat";
import { WorldUtils } from "./world/WorldUtils";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { VectorAddress } from "../src";
import { expect } from "chai";

describe("World Registration", () => {

    let signers: HardhatEthersSigner[];
    let worldUtils: WorldUtils;
    let registrarAdmin: HardhatEthersSigner;
    let registrarSigner: HardhatEthersSigner;
    let worldFactoryAdmin: HardhatEthersSigner;
    let worldRegistryAdmin: HardhatEthersSigner;
    let worldOwner: HardhatEthersSigner;
    let registrarId: bigint;
    
    before(async () => {
        worldUtils = new WorldUtils();
        signers = await ethers.getSigners();
        registrarAdmin = signers[0];
        registrarSigner = signers[1];
        worldFactoryAdmin = signers[2];
        worldRegistryAdmin = signers[3];
        worldOwner = signers[4];
        await worldUtils.deployWorldMaster({
            registrarAdmin,
            registrarSigner,
            worldFactoryAdmin,
            worldRegistryAdmin
        });

        const r = await worldUtils.registrarUtils?.registerRegistrar({
            admin: registrarAdmin,
            signer: registrarSigner.address,
            tokens: BigInt("1000000000000000000")
        });
        const regId = r?.registrarId;
        if(!regId) {
            throw new Error("Registrar not registered");
        }
        registrarId = regId;
    });


    it("Should register a world", async () => {
        
        const r = await worldUtils.worldRegistryUtils?.createWorld({
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
        const addr = await worldUtils.worldRegistryUtils?.lookupWorldAddress("tEsTwOrLd");
        expect(addr).to.not.be.undefined;
        expect(addr).to.equal(r?.worldAddress);
        console.log("World registered at", r?.worldAddress);

        
    });

    it("Should not allow duplicate registration", async () => {
        let fail = false;
        try {
            const r = await worldUtils.worldRegistryUtils?.createWorld({
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
                name: "tEsTwOrLd", //case should be ignored
                },
            });
            if(r) {
                fail = true;
            }
        } catch(e:any) {
            expect(e.message).to.not.be.undefined;
            if(e.message.indexOf("name already in use") < 0) {
                throw e;
            }
        }
    });

    it("Should allow signers to be added", async () => {
        const r = await worldUtils.addSigners({
            worldSigner: worldOwner,
            newSigners: [signers[8].address],
            worldName: "tEsTwOrLd"
        });
        expect(r).to.not.be.undefined;
        expect(r.status).to.equal(1);
        const is = await worldUtils.isSigner({
            address: signers[8].address,
            worldName: "tEsTwOrLd"
        });
        expect(is).to.equal(true);

    });

    it("Should not allow signers to be added by non-owner", async () => {
        let fail = false;
        try {
            const r = await worldUtils.addSigners({
                worldSigner: signers[9],
                newSigners: [signers[9].address],
                worldName: "tEsTwOrLd"
            });
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
        const b4 = await worldUtils.isSigner({
            address: signers[8].address,
            worldName: "tEsTwOrLd"
        });
        expect(b4).to.equal(true);

        const r = await worldUtils.removeSigners({
            worldSigner: worldOwner,
            signers: [signers[8].address],
            worldName: "tEsTwOrLd"
        });
        expect(r).to.not.be.undefined;
        expect(r.status).to.equal(1);
        const is = await worldUtils.isSigner({
            address: signers[8].address,
            worldName: "tEsTwOrLd"
        });
        expect(is).to.equal(false);
    });

    it("Should not allow non-signer to withdraw funds", async () => {
        let fail = false;
        try {
            const r = await worldUtils.withdraw({
                worldSigner: signers[9],
                worldName: "tEsTwOrLd",
                amount: BigInt("1000000000000000000")
            });
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
        const b4 = await ethers.provider.getBalance(worldOwner.address);
        const r = await worldUtils.withdraw({
            worldSigner: worldOwner,
            worldName: "tEsTwOrLd",
            amount: BigInt("1000000000000000000")
        });
        expect(r).to.not.be.undefined;
        expect(r.status).to.equal(1);
        const after = await ethers.provider.getBalance(worldOwner.address);
        expect(after).to.be.greaterThan(b4);
    });
});