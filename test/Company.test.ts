import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { IEcosystem, TestStack } from "./TestStack";
import {ethers} from 'hardhat';
import { Avatar, Company, ERC20Asset, ERC721Asset, Experience, ICompanyRegistrationRequest, RegistrationTerms, World, signTerms } from "../src";
import { expect } from "chai";
import { time } from "@nomicfoundation/hardhat-network-helpers";


describe("Company", () => {

    let stack: TestStack;
    let ecosystem: IEcosystem;
    let signers: HardhatEthersSigner[];
    let mintedERC721TokenId: bigint = 0n;
    before(async () => {
        signers = await ethers.getSigners();
        stack = new TestStack();
        await stack.init();
        ecosystem = await stack.initEcosystem();
    });

    it("Should register company with funding", async () => {
        expect(ecosystem.company).to.not.be.undefined;
        const bal = await ecosystem.company.getBalance();
        expect(bal).to.be.greaterThan(0);
    });


    it('should retrieve the owner of a company', async () => {
        const owner = await ecosystem.company!.owner();
        expect(owner).to.equal(await ecosystem.companyOwner.getAddress());
    })
    it('should retrieve the world of a company', async () => {
        const w = await ecosystem.company.world();
        expect(w).to.equal(ecosystem.world.address);
    })
    it('should retrieve vector of a company', async () => {
        const v = await ecosystem.company.getVectorAddress();
        expect(v).to.not.be.undefined;
        expect(v.p).to.be.greaterThan(0);
    })

    it('should add a signer to a company', async () => {
        const signer = signers[5];
        const result = await ecosystem.company.addSigners([signer.address]);
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
    })
    it('should check if a signer is in a company', async () => {
        const signer = signers[5];
        const isSigner = await ecosystem.company.isSigner(signer.address);
        expect(isSigner).to.be.true;
    })

    it('should remove a signer from a company', async () => {
        const signer = signers[5];
        const result = await ecosystem.company.removeSigners([signer.address]);
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
        const isSigner = await ecosystem.company.isSigner(signer.address);
        expect(isSigner).to.be.false;
    })
    // ------------------- Asset tests -------------------
    it('should be able to mint an ERC20 asset', async () => {
        const asset = ecosystem.erc20.address.toString();
        const to = ecosystem.avatar.address.toString();
        const amount = ethers.parseEther("10.0").toString();
        const result = await ecosystem.company.canMintERC20(asset, to, amount);
        expect(result).to.be.true;
    })
    it('should be able to mint an ERC721 asset', async () => {
        const {company, erc721, avatar} = ecosystem
        const asset = erc721.address.toString();
        const to = avatar.address.toString();
        const result = await company.canMintERC721(asset, to);
        expect(result).to.be.true;
    })
    
    it('should mint an erc20 asset', async () => {
        const {company, erc20, avatar} = ecosystem
        const asset = erc20.address.toString();
        const to = avatar.address.toString();
        const amount = ethers.parseEther("10.0");
        const r = await company.mintERC20(asset, to, amount);
        expect(r.receipt.status).to.equal(1);
        expect(r.amount).to.be.greaterThan(0);
        const balance = await erc20.balanceOf(to);
        expect(balance).to.equal(amount);
    })
    
    it('should mint an erc721 asset', async () => {
        const {company, erc721, avatar} = ecosystem
        const asset = erc721.address.toString();
        const to = avatar.address.toString();
        const r = await company.mintERC721(asset, to);
        expect(r.receipt.status).to.equal(1);
        expect(r.tokenId).to.be.greaterThan(0);
        mintedERC721TokenId = r.tokenId;
        const assetCon = new ERC721Asset({address: asset, provider: ethers.provider, logParser: stack.logParser!})
        const owner = await assetCon.ownerOf(r.tokenId);
        const balance = await assetCon.balanceOf(to);
        expect(owner).to.equal(to);
        expect(balance).to.equal(1);

    })
    it('should revoke an erc20 asset', async () => {
        const {company, erc20, avatar} = ecosystem
        const asset = erc20.address.toString();
        const to = avatar.address.toString();
        const amount = ethers.parseEther("10.0");
        const result = await company.revokeERC20(asset, to, amount);
        const r = await result.wait();
        expect(r?.status).to.equal(1);
        const balance = await erc20.balanceOf(to);
        expect(balance).to.equal(0);
    })
    it('should revoke an erc721 asset', async () => {
        const {company, erc721, avatar} = ecosystem
        const asset = erc721.address.toString();
        const to = avatar.address.toString();
        const tokenId = mintedERC721TokenId;
        const result = await company.revokeERC721(asset, to, tokenId);
        const r = await result.wait();
        expect(r?.status).to.equal(1);
        const balance = await erc721.balanceOf(to);
        expect(balance).to.equal(0);
    })
   
    // ------------------- Experience tests -------------------
    it('should add experience to a company', async () => {
        const {company, experience} = ecosystem
        const expAddress = experience.address;
        const experienceRegistry = stack.experienceRegistry;
        const isExp = await experienceRegistry!.isExperience(expAddress);
        const {portalId} = await experienceRegistry!.getExperienceInfo(expAddress);
        expect(isExp).to.be.true;
        const vector = await experience.vectorAddress();
        expect(vector.p).to.be.greaterThan(0);
        expect(vector.p_sub).to.be.greaterThan(0);
    })

   
    /*
    it('should add experience condition to a company', async () => {
        const {company, experience} = ecosystem
        
        const condition = ethers.hexlify(ethers.randomBytes(20));
        const result = await company.addExperienceCondition(experience.address, condition);
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
        const prStack = stack.getStack<PortalStackImpl>(StackType.PORTAL);
        const portalRegistry = prStack.getPortalRegistry();
        const portalInfo = await portalRegistry.getPortalInfoById(experience.portalId);
        expect(portalInfo.condition.toString().toLowerCase()).to.equal(condition.toLowerCase());
    })
    it('should remove experience condition from a company', async () => {
        const {company, experience} = ecosystem
        const result = await company.removeExperienceCondition(experience.address);
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
        const prStack = stack.getStack<PortalStackImpl>(StackType.PORTAL);
        const portalRegistry = prStack.getPortalRegistry();
        const portalInfo = await portalRegistry.getPortalInfoById(experience.portalId);
        const ZeroAddress = '0x' + '0'.repeat(40);
        expect(portalInfo.condition).to.equal(ZeroAddress);
    })
        */
    it('should change portal fee for a company', async () => {
        const {company, experience} = ecosystem
        const fee = ethers.parseEther("0.1").toString();
        const result = await company.changeExperiencePortalFee(experience.address, fee);
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
        const portalRegistry = stack.portalRegistry!;
        const portalInfo = await portalRegistry.getPortalInfoById(experience.portalId);
        expect(portalInfo.fee.toString()).to.equal(fee);
    })
    it('should not allow duplicate experience registration', async () => {
        const {company, experience} = ecosystem

        try {
            await company.addExperience({
                name: await experience.name(),
                connectionDetails: await experience.connectionDetails(),
                entryFee: await experience.entryFee()
            });
        } catch (e) {
            expect(e.message).to.contain('name already registered')
        }
    })
    
    // -------------------- withdraw tests --------------------
    it('should withdraw tokens from a company', async () => {
        const {company} = ecosystem
        await company.addFunds(ethers.parseEther("1.0"));
        
        const balBefore = await company.getBalance();
        const result = await company.withdraw(balBefore);
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
        const balAfter = await ethers.provider.getBalance(company.address);
        expect(balAfter).to.equal(0);
    })

    it("Should remove experience from a company", async () => {
        const {company, experience} = ecosystem
        await company.deactivateExperience(experience.address, "Testing");
        await time.increase(86400 * 31); // 31 days

        const result = await company.removeExperience(experience.address, "Testing");
        const r = await result.wait();
        expect(r).to.not.be.undefined;
        expect(r!.status).to.equal(1);
        const expRegistry = stack.experienceRegistry!;
        const isExp = await expRegistry.isExperience(experience.address);
        expect(isExp).to.be.false;
        expect(await experience.isActive()).to.be.false;
        const logParser = stack.logParser!;
        const logs = await logParser.parseLogs(r!);
        const expRemoved = logs.get("PortalRemoved");
        expect(expRemoved).to.not.be.undefined;
        expect(expRemoved!.length).to.equal(1);
        const expLog = expRemoved![0];
        expect(expLog.args[1]).to.equal(experience.address);
    });

    it('should reregister an experience', async () => {
        const {company, experience} = ecosystem
        const expReg = stack.experienceRegistry!;
        let isExp = await expReg.isExperience(experience.address);
        expect(isExp).to.be.false;
        const expRes = await company.addExperience({
            name: await experience.name(),
            connectionDetails: await experience.connectionDetails(),
            entryFee: await experience.entryFee(),
        });
        expect(expRes).to.not.be.undefined;
        expect(expRes.experienceAddress).to.not.be.undefined;
        expect(expRes.portalId).to.not.be.undefined;
        
        const expInstance = new Experience({
            address: expRes.experienceAddress.toString(),
            portalId: expRes.portalId,
            provider: ethers.provider,
            logParser: stack.logParser!
        });
        const vector = await expInstance.vectorAddress();
        expect(vector.p).to.be.greaterThan(0);
        expect(vector.p_sub).to.be.greaterThan(0);
        isExp = await expReg.isExperience(expInstance.address);
        expect(isExp).to.be.true;
    })

});