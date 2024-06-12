import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { StackFactory } from "./test_stack/StackFactory";
import { Company } from "../src/company/Company";
import { World } from "../src";
import { ethers } from "hardhat";
import { expect } from "chai";

describe('JumpTest', () => {
    let signers: HardhatEthersSigner[];
    let registrarAdmin:HardhatEthersSigner
    let registrarSigner:HardhatEthersSigner
    let worldRegistryAdmin:HardhatEthersSigner
    let worldOwner:HardhatEthersSigner
    let companyOwner:HardhatEthersSigner
    let avatarOwner:HardhatEthersSigner
    let stack: StackFactory;
    let world: World;
    let ecosystem: any;
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
            avatarOwner,
            companyRegistryAdmin: signers[0],
            experienceRegistryAdmin: signers[0],
            portalRegistryAdmin: signers[0],
            registrarAdmin,
            registrarSigner,
            worldRegistryAdmin,
            worldOwner
        });
        const {world:w, worldRegistration: wr} = await stack.init();
        world = w;
        ecosystem = await stack.getEcosystem();
    });

    it("Should jump between worlds and experiences", async () => {
        
        const {experience, experience2, portalForExperience2, company2, avatar} = ecosystem;
        const nonce = await avatar.getCompanySigningNonce(company2.address);
        const current = await avatar.location();
        expect(current).to.be.not.null;
        expect(current.toString().toLowerCase()).to.be.equal(experience.address.toLowerCase());
        const b4Bal = await avatar.tokenBalance();
        expect(b4Bal).to.be.not.null;
        expect(b4Bal.toString()).to.be.not.equal("0");
        const sig = await company2.signJumpRequest({
            fee: portalForExperience2.fee,
            nonce,
            portalId: experience2.portalId
        })
        const res = await avatar.jump({
            agreedFee: portalForExperience2.fee,
            destinationCompanySignature: sig,
            portalId: experience2.portalId
        });
        expect(res).to.be.not.null;
        expect(res.destination.toString().toLowerCase()).to.be.equal(experience2.address.toLowerCase());
        expect(res.connectionDetails).to.be.not.null;
        const loc = await avatar.location();
        expect(loc).to.be.not.null;
        expect(loc.toString().toLowerCase()).to.be.equal(experience2.address.toLowerCase());
        const afterBal = await avatar.tokenBalance();
        expect(afterBal).to.be.not.null;
        expect(afterBal.toString()).to.be.equal( (b4Bal - portalForExperience2.fee).toString());
    });

    it("Should allow a delegated jump from company", async () => {
        
        const {experience, experience2, portalForExperience, company, avatar} = ecosystem;
        const nonce = await avatar.getAvatarSigningNonce();
        const current = await avatar.location();
        expect(current).to.be.not.null;
        expect(current.toString().toLowerCase()).to.be.equal(experience2.address.toLowerCase());
        const aB4 = await avatar.tokenBalance();
        const b4Bal = await company.tokenBalance();
        expect(b4Bal).to.be.not.null;
        expect(b4Bal.toString()).to.be.not.equal("0");
        const sig = await avatar.signJumpRequest({
            fee: portalForExperience.fee,
            nonce,
            portalId: experience.portalId
        });
        const res = await company.payForAvatarJump({
            portalId: experience.portalId,
            agreedFee: portalForExperience.fee,
            avatarOwnerSignature: sig,
            avatar
        });
        expect(res).to.be.not.null;
        expect(res.destination.toString().toLowerCase()).to.be.equal(experience.address.toLowerCase());
        const aAfter = await avatar.tokenBalance();
        const afterBal = await company.tokenBalance();
        expect(afterBal).to.be.not.null;
        expect(afterBal.toString()).to.be.equal( (b4Bal - portalForExperience.fee).toString());
        expect(aAfter).to.be.not.null;
        expect(aAfter.toString()).to.be.equal(aB4.toString());
    });
});