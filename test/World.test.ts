import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { TestStack } from "./TestStack";
import {ethers} from 'hardhat';
import { ICompanyRegistrationRequest, RegistrationTerms, World, signTerms } from "../src";
import { expect } from "chai";


describe("World", () => {

    let stack: TestStack;
    let signers: HardhatEthersSigner[];
    let world: World | null = null;
    before(async () => {
        signers = await ethers.getSigners();
        stack = new TestStack();
        await stack.init();
    });

    it("Should create a world", async () => {
        world = await stack.createWorld(signers[3]);
        expect(world).to.not.be.null;
        const owner = await world.owner();
        expect(owner).to.equal(signers[3].address);
        const isSigner = await world.isSigner(signers[3].address);
        expect(isSigner).to.be.true;
    });

    it("Should register a company", async () => {
        const owner = signers[4];
        const terms: RegistrationTerms = {
            fee: 0n,
            coveragePeriodDays: 0n,
            gracePeriodDays: 30n
        };
        const expiration = BigInt(Math.ceil(Date.now() / 1000) + 60);
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

    });
});