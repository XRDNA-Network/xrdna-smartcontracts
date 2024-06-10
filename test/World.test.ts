import { ethers } from "hardhat";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { IWorldRegistration, World } from "../src";
import { expect } from "chai";
import { IWorldStack } from "./test_stack/world/IWorldStack";
import { StackFactory, StackType } from "./test_stack/StackFactory";
import { Signer } from "ethers";
import { Company } from "../src/company/Company";
import { Experience } from "../src/experience";

describe("World Registration", () => {

    let signers: HardhatEthersSigner[];
    let worldStack: IWorldStack;
    let registrarAdmin: Signer;
    let registrarSigner: Signer;
    let worldRegistryAdmin: HardhatEthersSigner;
    let worldOwner: HardhatEthersSigner;
    let worldRegistration: IWorldRegistration;
    let companyOwner: HardhatEthersSigner;
    let avatarOwner: HardhatEthersSigner;
    let stack: StackFactory;
    let world: World;
    let company: Company;
    let experience: Experience;
    
    before(async () => {
        
        signers = await ethers.getSigners();
        
        registrarAdmin = signers[0];
        registrarSigner = signers[0];
        worldRegistryAdmin = signers[0];
        worldOwner = signers[1];
        companyOwner = signers[2];
        avatarOwner = signers[3];
        stack = new StackFactory({
            assetRegistryAdmin: signers[0],
            avatarRegistryAdmin: signers[0],
            companyRegistryAdmin: signers[0],
            experienceRegistryAdmin: signers[0],
            portalRegistryAdmin: signers[0],
            registrarAdmin,
            registrarSigner,
            worldRegistryAdmin,
            worldOwner
        });
        const {world: w, worldRegistration: wr} = await stack.init();
        world = w;
        worldRegistration = wr;
        //reset the registrar admins since those are linked to XRDNA signer
        registrarAdmin = stack.admins.registrarAdmin;
        registrarSigner = stack.admins.registrarSigner;
        worldStack = stack.getStack<IWorldStack>(StackType.WORLD);
        
    });

    it("Should register a world", async () => {
        
        expect(world).to.not.be.undefined;
        console.log("World deployed at: ", world.address);
    });

    
    it("Should not allow duplicate registration", async () => {
        let fail = false;
        try {
        
            const worldReg = worldStack.getWorldRegistry();
            const r = await worldReg.createWorld({
                registrarSigner,
                details: worldRegistration,
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
        if(fail) {
            throw new Error("Duplicate registration should not have been allowed");
        }
    });

    
    it("Should allow signers to be added", async () => {
        
        const t = await world.addSigners([signers[8].address]);
        const r = await t.wait();
        expect(r).to.not.be.undefined;
        expect(r!.status).to.equal(1);
        const is = await world.isSigner(signers[8].address);
        expect(is).to.equal(true);

    });

    
    it("Should not allow signers to be added by non-owner", async () => {
        let fail = false;
        try {
            const fakeWorld = new World({
                address: world.address,
                admin: signers[0]
            });
            const r = await fakeWorld.addSigners([signers[9].address]);
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
        const b4 = await world.isSigner(signers[8].address);
        expect(b4).to.equal(true);

        const t = await world.removeSigners([signers[8].address]);
        const r = await t.wait();
        expect(r).to.not.be.undefined;
        expect(r!.status).to.equal(1);
        const is = await world.isSigner(signers[8].address);
        expect(is).to.equal(false);
    });

    it("Should not allow non-signer to withdraw funds", async () => {
        let fail = false;
        try {
            const fakeWorld = new World({
                address: world.address,
                admin: signers[9]
            });
            const r = await fakeWorld.withdraw(BigInt("1000000000000000000"));
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
        const t = await world.withdraw(ethers.parseEther("1.0"));
        const r  = await t.wait();
        expect(r).to.not.be.undefined;
        expect(r!.status).to.equal(1);
        const after = await ethers.provider.getBalance(worldOwner.address);
        expect(after).to.be.greaterThan(b4);
    });

    ///////////////////////////////////////////////////////////////////////
    // Company registration through world
    ///////////////////////////////////////////////////////////////////////
    it("Should register a company", async () => {
        const res = await world.registerCompany({
            initData: "0x",
            name: "My Company",
            owner: companyOwner.address,
            sendTokensToCompanyOwner: false
        }, ethers.parseEther("1.0"));
        expect(res).to.not.be.undefined;
        expect(res.receipt.status).to.equal(1);
        expect(res.companyAddress).to.not.be.undefined;
        expect(res.vectorAddress).to.not.be.undefined;
        company = new Company({
            address: res.companyAddress.toString(),
            admin: companyOwner
        });
        const r = await company.addExperience({
            name: "My Experience",
            entryFee: ethers.parseEther("0.1"),
            connectionDetails: "0x"
        });
            
        expect(r).to.not.be.undefined;
        expect(r.receipt.status).to.equal(1);
        expect(r.experienceAddress).to.not.be.undefined;
        experience = new Experience({
            address: r.experienceAddress.toString(),
            portalId: r.portalId,
            admin: companyOwner
        });

    });

    it("Should not allow  a duplicate company", async () => {
        try {
           await world.registerCompany({
                initData: "0x",
                name: "My Company",
                owner: companyOwner.address,
                sendTokensToCompanyOwner: false
            }, ethers.parseEther("1.0"));
            throw new Error("Should not have allowed creation");
        } catch(e:any) {
            expect(e.message).to.not.be.undefined;
            if(e.message.indexOf("company name already taken") < 0) {
                throw e;
            }
        }
    });

    ///////////////////////////////////////////////////////////////////////
    // Avatar registration through world
    ///////////////////////////////////////////////////////////////////////
    it("Should register an avatar", async () => {
        const res = await world.registerAvatar({
            avatarOwner,
            defaultExperience: experience.address,
            appearanceDetails: "0x",
            canReceiveTokensOutsideOfExperience: false,
            sendTokensToAvatarOwner: false,
            username: "myavatar"
        });
        expect(res).to.not.be.undefined;
        expect(res.receipt.status).to.equal(1);
        expect(res.avatarAddress).to.not.be.undefined;
    });

    it("Should not allow duplicate avatar", async () => {
        try {
            await world.registerAvatar({
                avatarOwner,
                defaultExperience: experience.address,
                appearanceDetails: "0x",
                canReceiveTokensOutsideOfExperience: false,
                sendTokensToAvatarOwner: false,
                username: "myavatar"
            });
            throw new Error("Should not have allowed creation");
        } catch(e:any) {
            expect(e.message).to.not.be.undefined;
            if(e.message.indexOf("username already exists") < 0) {
                throw e;
            }
        }
    });
    
});