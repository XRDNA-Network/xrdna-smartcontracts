import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { Experience, Registrar, World } from "../src";
import { ethers } from "hardhat";
// import {ethers } from "ethers"
import { expect } from "chai";
import {abi as TestConditionAbi, bytecode as bytecode} from "../artifacts/contracts/test/TestCondition.sol/TestCondition.json";
import { IEcosystem, TestStack } from "./TestStack";
import { time } from "@nomicfoundation/hardhat-network-helpers";

describe('JumpTest', () => {
    
    let stack: TestStack;
    let ecosystem: IEcosystem;
    let signers: HardhatEthersSigner[];
    before(async () => {
        signers = await ethers.getSigners();
        stack = new TestStack();
        await stack.init();
        ecosystem = await stack.initEcosystem();
    });

    it("Should jump between worlds and experiences", async () => {
        
        const {experience, experience2, portalForExperience2, company2, avatar} = ecosystem;
        const nonce = await avatar.getCompanySigningNonce(company2.address);
        const current = await avatar.location();
        expect(current).to.be.not.null;
        expect(current.toString().toLowerCase()).to.be.equal(experience.address.toLowerCase());
        const companyBal = await company2.getBalance();
        const b4Bal = await avatar.getBalance();
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
        const afterBal = await avatar.getBalance();
        const afterCompanyBal = await company2.getBalance();
        expect(afterBal).to.be.not.null;
        expect(afterBal.toString()).to.be.equal( (b4Bal - portalForExperience2.fee).toString());
        expect(afterCompanyBal).to.be.not.null;
        expect(afterCompanyBal.toString()).to.be.equal( (companyBal + portalForExperience2.fee).toString());
    });

    it("Should allow a delegated jump from company", async () => {
        
        const {experience, experience2, portalForExperience, company, avatar} = ecosystem;
        const nonce = await avatar.getAvatarSigningNonce();
        const current = await avatar.location();
        expect(current).to.be.not.null;
        expect(current.toString().toLowerCase()).to.be.equal(experience2.address.toLowerCase());
        const aB4 = await avatar.getBalance();
        const b4Bal = await company.getBalance();
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
        const aAfter = await avatar.getBalance();
        const afterBal = await company.getBalance();
        expect(afterBal).to.be.not.null;
        expect(afterBal.toString()).to.be.equal( (b4Bal - portalForExperience.fee).toString());
        expect(aAfter).to.be.not.null;
        expect(aAfter.toString()).to.be.equal(aB4.toString());
    });
    it('should not allow a jump with unagreed upon fee', async () => {
        const {experience, experience2, portalForExperience2, company2, avatar} = ecosystem;
        const nonce = await avatar.getCompanySigningNonce(company2.address);
        const current = await avatar.location();
        expect(current).to.be.not.null;
        expect(current.toString().toLowerCase()).to.be.equal(experience.address.toLowerCase());
        const b4Bal = await avatar.getBalance();
        expect(b4Bal).to.be.not.null;
        expect(b4Bal.toString()).to.be.not.equal("0");
        const sig = await company2.signJumpRequest({
            fee: portalForExperience2.fee,
            nonce,
            portalId: experience2.portalId
        })
        try {
            await avatar.jump({
                agreedFee: 0n,
                destinationCompanySignature: sig,
                portalId: experience2.portalId
            })
        
        } catch (e) {
            expect(e.message).to.be.equal("VM Exception while processing transaction: reverted with reason string 'Avatar: company signer is not authorized'")
        }
        expect(await avatar.location()).to.be.equal(experience.address);
       
    })

    it('should not allow a jump to a different portal Id than agreed', async () => {
        const {experience, experience2, portalForExperience2, company2, avatar} = ecosystem;
        const nonce = await avatar.getCompanySigningNonce(company2.address);
        const current = await avatar.location();
        expect(current).to.be.not.null;
        expect(current.toString().toLowerCase()).to.be.equal(experience.address.toLowerCase());
        const b4Bal = await avatar.getBalance();
        expect(b4Bal).to.be.not.null;
        expect(b4Bal.toString()).to.be.not.equal("0");
        const sig = await company2.signJumpRequest({
            fee: portalForExperience2.fee,
            nonce,
            portalId: experience2.portalId
        })
        try {
            await avatar.jump({
                agreedFee: portalForExperience2.fee,
                destinationCompanySignature: sig,
                portalId: experience.portalId
            })
        
        } catch (e) {
            expect(e.message).to.be.equal("VM Exception while processing transaction: reverted with reason string 'Avatar: company signer is not authorized'")
        }
        expect(await avatar.location()).to.be.equal(experience.address);
       
    })

    it('should not allow a delegate jump with unauthorized signer', async () => {
        const {experience, experience2, portalForExperience, company, avatar} = ecosystem;
        const nonce = 100n;
        const current = await avatar.location();
        expect(current).to.be.not.null;
        expect(current.toString().toLowerCase()).to.be.equal(experience.address.toLowerCase());
        const aB4 = await avatar.getBalance();
        const b4Bal = await company.getBalance();
        expect(b4Bal).to.be.not.null;
        expect(b4Bal.toString()).to.be.not.equal("0");
        const sig = await avatar.signJumpRequest({
            fee: portalForExperience.fee,
            nonce,
            portalId: experience2.portalId
        });
        try {
            await company.payForAvatarJump({
                portalId: experience.portalId,
                agreedFee: portalForExperience.fee,
                avatarOwnerSignature: sig,
                avatar
            });
        } catch (e) {
            expect(e.message).to.be.equal("VM Exception while processing transaction: reverted with reason string 'Avatar: avatar signer is not owner'")
        }
        expect(await avatar.location()).to.be.equal(experience.address);
    })
    it('should only allow jumps with signer passing condition', async () => {
        const {experience, experience2, portalForExperience2, avatar, company, company2} = ecosystem;
        const Condition = new ethers.ContractFactory(TestConditionAbi, bytecode, ecosystem.companyOwner)
        const condition = await (await Condition.deploy()).waitForDeployment();

        const expT = await company2.addExperienceCondition(experience2.address, await condition.getAddress());
        expect(expT).to.be.not.null;
        const expR = await expT.wait();
        if (!expR) {
            throw new Error("Transaction failed with status 0");
        }
        expect(expR.status).to.be.equal(1);
        const nonce = await avatar.getCompanySigningNonce(company2.address);
        const current = await avatar.location();
        expect(current).to.be.not.null;
        expect(current.toString().toLowerCase()).to.be.equal(experience.address.toLowerCase());
        const companyBal = await company2.getBalance();
        const b4Bal = await avatar.getBalance();
        expect(b4Bal).to.be.not.null;
        expect(b4Bal.toString()).to.be.not.equal("0");
        const sig = await company2.signJumpRequest({
            fee: portalForExperience2.fee,
            nonce,
            portalId: experience2.portalId
        })
        try {
            const res = await avatar.jump({
                agreedFee: portalForExperience2.fee,
                destinationCompanySignature: sig,
                portalId: experience2.portalId
            });
        } catch (e) {
            expect(e.message).to.be.equal("VM Exception while processing transaction: reverted with reason string 'PortalRegistry: portal jump conditions not met'")
        }

        // Add jumper to pass condition
        const allowJump = await condition.setCanJump(avatar.address, true);
        expect(allowJump).to.be.not.null;
        const allowJumpR = await allowJump.wait();
        if (!allowJumpR) {
            throw new Error("Transaction failed with status 0");
        }
        expect(allowJumpR.status).to.be.equal(1);
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
        const afterBal = await avatar.getBalance();
        const afterCompanyBal = await company2.getBalance();
        expect(afterBal).to.be.not.null;
        expect(afterBal.toString()).to.be.equal( (b4Bal - portalForExperience2.fee).toString());
        expect(afterCompanyBal).to.be.not.null;
        expect(afterCompanyBal.toString()).to.be.equal( (companyBal + portalForExperience2.fee).toString());

       
    });

    it('should not allow jump with unpaid portal fee', async () => {
        const {experience, experience2, portalForExperience, company2, company, avatar} = ecosystem;
        const fee = await experience.entryFee();
        const nonce = await avatar.getCompanySigningNonce(company.address);
        const current = await avatar.location();
        expect(current).to.be.not.null;
        expect(current.toString().toLowerCase()).to.be.equal(experience2.address.toLowerCase());
    
        const b4Bal = await avatar.getBalance();
        expect(b4Bal).to.be.not.null;
        expect(b4Bal.toString()).to.be.not.equal("0");
        expect(b4Bal).to.be.lessThan(ethers.parseEther('100'));
        const sig = await company.signJumpRequest({
            fee: portalForExperience.fee,
            nonce,
            portalId: experience.portalId
        })
        const changeFeeTxn = await company.changeExperiencePortalFee(experience.address, ethers.parseEther('100'));
        const changeFeeR = await changeFeeTxn.wait();
        if (!changeFeeR) {
            throw new Error("Transaction failed with status 0");
        }
        expect(changeFeeR.status).to.be.equal(1);
        try {
            const res = await avatar.jump({
                agreedFee: portalForExperience.fee,
                destinationCompanySignature: sig,
                portalId: experience.portalId
            });
        } catch (e) {
            expect(e.message).to.contain('Avatar: agreed fee does not match portal fee')
        }
            
        const loc = await avatar.location();
        expect(loc).to.be.not.null;
        expect(loc.toString().toLowerCase()).to.be.equal(experience2.address.toLowerCase());
        const changeFeeBackTxn = await company.changeExperiencePortalFee(experience.address, fee);
        const changeFeeBackR = await changeFeeBackTxn.wait();
        if (!changeFeeBackR) {
            throw new Error("Transaction failed with status 0");
        }
        expect(changeFeeBackR.status).to.be.equal(1);
        
    })

    it('should not charge avatar more than agreed fee', async () => {
        const {experience, experience2, portalForExperience2, company2, company, avatar} = ecosystem;
        const startingFee = await experience.entryFee()
        // change fee to zero, sign jump request, change fee to high number, try to jump
        const changeFeeTxn = await company.changeExperiencePortalFee(experience.address, 0n);
        const nonce = await avatar.getCompanySigningNonce(company.address);
        const current = await avatar.location();
        expect(current).to.be.not.null;
        expect(current.toString().toLowerCase()).to.be.equal(experience2.address.toLowerCase());
        const b4Bal = await avatar.getBalance();
    
        expect(b4Bal).to.be.not.null;
        expect(b4Bal.toString()).to.be.not.equal("0");
        const sig = await company.signJumpRequest({
            fee: 0n,
            nonce,
            portalId: experience.portalId
        })
        // charge high fee after signing
        const chargeHighFeeTxn = await company.changeExperiencePortalFee(experience.address, b4Bal);
        const chargeHighFeeR = await chargeHighFeeTxn.wait();
        if (!chargeHighFeeR) {
            throw new Error("Transaction failed with status 0");
        }
        expect(chargeHighFeeR.status).to.be.equal(1);
        try {
            await avatar.jump({
                agreedFee: 0n,
                destinationCompanySignature: sig,
                portalId: experience.portalId
            })
            
        } catch (e) {
            expect(e.message).to.contain('Avatar: agreed fee does not match portal fee')
        }
        
        
        const loc = await avatar.location();
        expect(loc).to.be.not.null;
        expect(loc.toString().toLowerCase()).to.be.equal(experience2.address.toLowerCase());
        const afterBal = await avatar.getBalance();
        expect(afterBal).to.equal(b4Bal);
        const chargeBackTxn = await company.changeExperiencePortalFee(experience.address, startingFee);
        const chargeBackR = await chargeBackTxn.wait();
        if (!chargeBackR) {
            throw new Error("Transaction failed with status 0");
        }
        expect(chargeBackR.status).to.be.equal(1);


    })

    it('should allow jump to new experience if current experience is deactivated', async () => {
        const {experience, experience2, portalForExperience, company, company2, avatar} = ecosystem;
        const nonce = await avatar.getCompanySigningNonce(company.address);
        const current = await avatar.location();
        expect(current).to.be.not.null;
        expect(current.toString().toLowerCase()).to.be.equal(experience2.address.toLowerCase());
        const companyBal = await company.getBalance();
        const b4Bal = await avatar.getBalance();
        expect(b4Bal).to.be.not.null;
        expect(b4Bal.toString()).to.be.not.equal("0");
        const sig = await company.signJumpRequest({
            fee: portalForExperience.fee,
            nonce,
            portalId: experience.portalId
        })
        // company deactivates experience
        const deactivateT = await company2.deactivateExperience(current.toString(), "TESTING");
        const deactivateR = await deactivateT.wait();
        if (!deactivateR) {
            throw new Error("Transaction failed with status 0");
        }
        expect(deactivateR.status).to.be.equal(1);

    
        const res = await avatar.jump({
            agreedFee: portalForExperience.fee,
            destinationCompanySignature: sig,
            portalId: experience.portalId
        });

        expect(res).to.be.not.null;
        expect(res.destination.toString().toLowerCase()).to.be.equal(experience.address.toLowerCase());
        expect(res.connectionDetails).to.be.not.null;
   
        const loc = await avatar.location();
        expect(loc).to.be.not.null;
        expect(loc.toString().toLowerCase()).to.be.equal(experience.address.toLowerCase());
        const afterBal = await avatar.getBalance();
        const afterCompanyBal = await company.getBalance();
        expect(afterBal).to.be.not.null;
        expect(afterBal.toString()).to.be.equal(b4Bal.toString())
        expect(afterCompanyBal).to.be.not.null;
        expect(afterCompanyBal.toString()).to.be.equal( (companyBal).toString());
    });

    it('should not allow jump into deactivated experience', async () => {
        // creates a new experience, signs jump request, deactivates experience, tries to jump
        const {experience, company, avatar} = ecosystem;
        const experience3R = await company.addExperience({
            name: "Test Experience 3",
            connectionDetails: "0x",
            entryFee: 0n
        });
        
        const experience3 = new Experience({
            address: experience3R.experienceAddress.toString(),
            signerOrProvider: ethers.provider,
            portalId: experience3R.portalId,
            logParser: stack.logParser!
        });

        const portalRegistry = stack.portalRegistry!;
        const portalForExperience3 = await portalRegistry.getPortalInfoById(experience3.portalId);


        const nonce = await avatar.getCompanySigningNonce(company.address);
        const current = await avatar.location();
        expect(current).to.be.not.null;
        expect(current.toString().toLowerCase()).to.be.equal(experience.address.toLowerCase());
        const companyBal = await company.getBalance();
        const b4Bal = await avatar.getBalance();
        expect(b4Bal).to.be.not.null;
        expect(b4Bal.toString()).to.be.not.equal("0");
        const sig = await company.signJumpRequest({
            fee: portalForExperience3.fee,
            nonce,
            portalId: experience3.portalId
        })
        const expReg = stack.experienceRegistry!;
        const isActiveBefore = await experience3.isActive();
        expect(isActiveBefore).to.be.true;
        // company deactivates experience
        const deactivateT = await company.deactivateExperience(experience3.address, "TEST");
        const deactivateR = await deactivateT.wait();
        if (!deactivateR) {
            throw new Error("Transaction failed with status 0");
        }
        expect(deactivateR.status).to.be.equal(1);

        // test view functions
        const isActiveAfter = await experience3.isActive();
        expect(isActiveAfter).to.be.false;

        let jumpFailed = false;
        try {

            const res = await avatar.jump({
                agreedFee: portalForExperience3.fee,
                destinationCompanySignature: sig,
                portalId: experience3.portalId
            });

        } catch (e) {
            jumpFailed = true;
            expect(e.message).to.be.equal("VM Exception while processing transaction: reverted with reason string 'PortalRegistry: destination portal is not active'")
        }
        if(!jumpFailed) {
            throw new Error("Jump should have failed");
        }
   
        const loc = await avatar.location();
        expect(loc).to.be.not.null;
        expect(loc.toString().toLowerCase()).to.be.equal(experience.address.toLowerCase());
        const afterBal = await avatar.getBalance();
        const afterCompanyBal = await company.getBalance();
        expect(afterBal).to.be.not.null;
        expect(afterBal.toString()).to.be.equal(b4Bal.toString())
        expect(afterCompanyBal).to.be.not.null;
        expect(afterCompanyBal.toString()).to.be.equal( (companyBal).toString());
    })

    


})
