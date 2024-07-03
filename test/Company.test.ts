import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { TestStack } from "./TestStack";
import {ethers} from 'hardhat';
import { Company, ICompanyRegistrationRequest, RegistrationTerms, World, signTerms } from "../src";
import { expect } from "chai";


describe("Company", () => {

    let stack: TestStack;
    let signers: HardhatEthersSigner[];
    let world: World | null = null;
    let company: Company | null = null;
    before(async () => {
        signers = await ethers.getSigners();
        stack = new TestStack();
        await stack.init();
        world = await stack.createWorld(signers[3]);
        if(!world) {
            throw new Error('World not created');
        }
        company = await stack.createCompany(signers[4], world);
        if(!company) {
            throw new Error('Company not created');
        }
    });


    it("Should add an experience", async () => {
        const req = {
            name: 'Test Experience',
            entryFee: 0n,
            connectionDetails: 'localhost:1234'
        };

        const r = await company!.addExperience(req);
        expect(r).to.not.be.null;
        expect(r.receipt.status).to.equal(1);
        expect(r.experienceAddress).to.not.be.null;
        expect(r.portalId).to.be.greaterThan(0);

    });

});