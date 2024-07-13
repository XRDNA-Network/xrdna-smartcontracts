import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { TestStack } from "./TestStack";
import {ethers} from 'hardhat';
import { Company, Experience, ICompanyRegistrationRequest, IWorldRegistration, RegistrationTerms, World, signTerms } from "../src";
import { expect } from "chai";
import { time } from "@nomicfoundation/hardhat-network-helpers";



describe("World", () => {

    let stack: TestStack;
    let signers: HardhatEthersSigner[];
    let world: World | null = null;
    let worldRegistration: IWorldRegistration | null = null;
    let worldOwner: HardhatEthersSigner;
    let company: Company | null = null;
    let experience: Experience | null = null;
    before(async () => {
        signers = await ethers.getSigners();
        stack = new TestStack();
        await stack.init();
    });

    it("Should create a world", async () => {
        worldOwner = signers[3];
        const {world: w, registration} = await stack.createWorld({
            owner: worldOwner, tokens: ethers.parseEther('2.0')
        });
        world = w; 
        worldRegistration = registration;
        expect(world).to.not.be.null;
        const owner = await world.owner();
        expect(owner).to.equal(worldOwner.address);
        const isSigner = await world.isSigner(worldOwner.address);
        expect(isSigner).to.be.true;

        const bal = await ethers.provider.getBalance(world.address);
        expect(bal).to.equal(ethers.parseEther('2.0'));
    });

    it("Should not allow duplicate registration", async () => {
        let fail = false;
        try {
        
            const reg = stack.registrar!;
            const r = await reg.registerWorld(worldRegistration!);
            if(r) {
                fail = true;
            }
        } catch(e:any) {
            expect(e.message).to.not.be.undefined;
            if(e.message.indexOf("name already registered") < 0) {
                throw e;
            }
        }
        if(fail) {
            throw new Error("Duplicate registration should not have been allowed");
        }
    });

    
    it("Should allow signers to be added", async () => {
        
        const t = await world!.addSigners([signers[8].address]);
        const r = await t.wait();
        expect(r).to.not.be.undefined;
        expect(r!.status).to.equal(1);
        const is = await world!.isSigner(signers[8].address);
        expect(is).to.equal(true);

    });

    
    it("Should not allow signers to be added by non-owner", async () => {
        let fail = false;
        try {
            const fakeWorld = new World({
                address: world!.address,
                signerOrProvider: signers[0],
                logParser: stack.logParser!
            });
            const r = await fakeWorld.addSigners([signers[9].address]);
            if(r) {
                fail = true;
            }
        } catch(e:any) {
            expect(e.message).to.not.be.undefined;
            if(e.message.indexOf("restricted to admins") < 0) {
                throw e;
            }
        }
    });

    it("Should remove signers", async () => {
        const b4 = await world!.isSigner(signers[8].address);
        expect(b4).to.equal(true);

        const t = await world!.removeSigners([signers[8].address]);
        const r = await t.wait();
        expect(r).to.not.be.undefined;
        expect(r!.status).to.equal(1);
        const is = await world!.isSigner(signers[8].address);
        expect(is).to.equal(false);
    });

    it("Should not allow non-owner to withdraw funds", async () => {
        let fail = false;
        try {
            const fakeWorld = new World({
                address: world!.address,
                signerOrProvider: signers[9],
                logParser: stack.logParser!
            });
            const r = await fakeWorld.withdraw(ethers.parseEther("1.0"));
            if(r) {
                fail = true;
            }
        } catch(e:any) {
            expect(e.message).to.not.be.undefined;
            if(e.message.indexOf("restricted to owner") < 0) {
                throw e;
            }
        }
    });

    it("Should allow owner to withdraw funds", async () => {
        const b4 = await ethers.provider.getBalance(worldOwner!.address);
        const t = await world!.withdraw(ethers.parseEther("1.0"));
        const r  = await t.wait();
        expect(r).to.not.be.undefined;
        expect(r!.status).to.equal(1);
        const after = await ethers.provider.getBalance(worldOwner!.address);
        expect(after).to.be.greaterThan(b4);
    });


    it("Should register a company", async () => {
        const owner = signers[4];
        const terms: RegistrationTerms = {
            fee: 0n,
            coveragePeriodDays: 0n,
            gracePeriodDays: 30n
        };
        const expiration = BigInt(Math.ceil(Date.now() / 1000) + 300);
        const termsSign = await signTerms({
            terms,
            signer: owner,
            termsOwner: world!.address,
            expiration
        });
        const req = {
            sendTokensToCompanyOwner: false,
            owner: await owner.getAddress(),
            name: 'Test Company',
            terms,
            ownerTermsSignature: termsSign,
            expiration
        }

        const r = await world!.registerCompany(req);
        expect(r).to.not.be.null;
        expect(r.receipt.status).to.equal(1);
        expect(r.companyAddress).to.not.be.null;
        company = new Company({
            address: r.companyAddress.toString(),
            signerOrProvider: owner,
            logParser: stack.logParser!
        });

        const eR = await company!.addExperience({
            connectionDetails: "https://myexperience.com/test",
            entryFee: ethers.parseEther('0.1'),
            name: 'Test Experience',
        });
        expect(eR).to.not.be.null;
        expect(eR.receipt.status).to.equal(1);
        expect(eR.experienceAddress).to.not.be.null;
        expect(eR.portalId).to.not.be.null;
        experience = new Experience({
            address: eR.experienceAddress.toString(),
            portalId: eR.portalId,
            signerOrProvider: ethers.provider,
            logParser: stack.logParser!
        });

        //make sure vector for world didn't change after creating company
        const vector = await world!.getVectorAddress();
        expect(vector.p).is.equal(0);
        expect(vector.p_sub).is.equal(0);
    });

    

    it("Should register an avatar", async () => {
        const owner = signers[5];
        const req = {
            sendTokensToOwner: false,
            avatarOwner: await owner.getAddress(),
            username: 'testMe',
            defaultExperience: experience!.address,
            canReceiveTokensOutsideOfExperience: false,
            appearanceDetails: "https://myavatar.com/testMe"
        }

        const r = await world!.registerAvatar(req);
        expect(r).to.not.be.null;
        expect(r.receipt.status).to.equal(1);
        expect(r.avatarAddress).to.not.be.null;

    });


    it("Should deactivate a company", async () => {
        const t = await world!.deactivateCompany(company!.address, "Testing");
        const r = await t.wait();
        expect(r).to.not.be.undefined;
        expect(r!.status).to.equal(1);
        const a = await company!.isActive();
        expect(a).to.equal(false);
    });


    it("Should reactivate a company", async () => {
        const t = await world!.reactivateCompany(company!.address);
        const r = await t.wait();
        expect(r).to.not.be.undefined;
        expect(r!.status).to.equal(1);
        const a = await company!.isActive();
        expect(a).to.equal(true);
    });

    it("Should remove a company", async () => {
        //first deactivate
        const t = await world!.deactivateCompany(company!.address, "Testing");
        const r = await t.wait();
        expect(r).to.not.be.undefined;
        expect(r!.status).to.equal(1);
        const a = await company!.isActive();
        expect(a).to.equal(false);

        //simulate grace period elapases so we can remove
        await time.increase(86400 * 31); //31 days

        //now remove
        const t2 = await world!.removeCompany(company!.address, "Testing 2");
        const r2 = await t2.wait();
        expect(r2).to.not.be.undefined;
        expect(r2!.status).to.equal(1);

        const reg = stack.companyRegistry!;
        const isReg = await reg.isRegisteredCompany(company!.address);
        expect(isReg).to.equal(false);

    });
});