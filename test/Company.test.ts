
import { ethers } from "hardhat";
import { Company } from "../src/company/Company";
import { IAvatarRegistrationResult, ICompanyRegistrationResult, World } from "../src/world";
import { HardhatTestKeys } from "./HardhatTestKeys";
import { IEcosystem, StackFactory, StackType } from "./test_stack/StackFactory"
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai";
import { ERC20, TestERC20, TestERC721 } from "../typechain-types";
import { AvatarStackImpl } from "./test_stack/avatar/AvatarStackImpl";
import { Experience } from "../src/experience";
import { ExperienceStackImpl } from "./test_stack/experience/ExperienceStackImpl";
import {abi as BaseAssetABI} from "../artifacts/contracts/asset/BaseAsset.sol/BaseAsset.json"
import { IERC20AssetStack } from "./test_stack/asset/erc20/IERC20AssetStack";
import { AllLogParser, ChainIds, CreateERC20AssetResult, CreateERC721AssetResult, ERC20Asset, ERC20AssetRegistry, ERC20InitData, ERC721Asset, ERC721AssetRegistry, MultiAssetRegistry } from "../src";
import { IERC721AssetStack } from "./test_stack/asset/erc721/IERC721AssetStack";
import { IMultiAssetRegistryStack } from "./test_stack/asset/IMultiAssetRegistryStack";
import exp from "constants";
import { PortalStackImpl } from "./test_stack/portal/PortalStackImpl";
import { IWorldStack } from "./test_stack/world/IWorldStack";


describe('Company', () => {
    let stack: StackFactory;
    
    let mintedERC721TokenId: bigint;
    let ecosystem: IEcosystem
    before(async () => {
        const signers = await ethers.getSigners();
       

        stack = new StackFactory({
            registrarOwner: signers[1],
            worldOwner: signers[0],
            companyOwner: signers[1],
            avatarOwner: signers[2],
        });

        const {world, worldRegistration} = await stack.init();
        ecosystem = await stack.getEcosystem();
        
    });

    it('should register a company', async () => {
        const {company} = ecosystem
        expect(company).to.not.be.undefined;
        const name = await company.name()
        expect(name).to.equal("Test Company".toLowerCase());
    });

    it('should retrieve the owner of a company', async () => {
        const {company} = ecosystem
        const companyOwner = stack.admins.companyRegistryAdmin
        const owner = await company.owner();
        expect(owner).to.equal(await companyOwner.getAddress());
    })
    it('should retrieve the world of a company', async () => {
        const {company, world} = ecosystem
        const w = await company.world();
        expect(w).to.equal(world.address);
    })
    it('should retrieve vector of a company', async () => {
        const {company} = ecosystem
        const v = await company.getVectorAddress();
        expect(v).to.not.be.undefined;
        expect(v.p).to.be.greaterThan(0);
    })

    it('should add a signer to a company', async () => {
        const {company} = ecosystem
        const signer = HardhatTestKeys[4];
        const result = await company.addSigners([signer.address]);
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
    })
    it('should check if a signer is in a company', async () => {
        const {company} = ecosystem
        const signer = HardhatTestKeys[4];
        const isSigner = await company.isSigner(signer.address);
        expect(isSigner).to.be.true;
    })

    it('should remove a signer from a company', async () => {
        const {company} = ecosystem
        const signer = HardhatTestKeys[4];
        const result = await company.removeSigners([signer.address]);
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
        const isSigner = await company.isSigner(signer.address);
        expect(isSigner).to.be.false;
    })
    // ------------------- Asset tests -------------------
    it('should be able to mint an ERC20 asset', async () => {
        const {company, testERC20, testERC721, avatar} = ecosystem
        const asset = testERC20.assetAddress.toString();
        const to = avatar.address.toString();
        const amount = ethers.parseEther("10.0").toString();
        const result = await company.canMint(asset, to, amount);
        expect(result).to.be.true;
    })
    it('should be able to mint an ERC721 asset', async () => {
        const {company, testERC20, testERC721, avatar} = ecosystem
        const asset = testERC721.assetAddress.toString();
        const to = avatar.address.toString();
        const tokenId = 1n;
        const result = await company.canMint(asset, to, tokenId);
        expect(result).to.be.true;
    })
    
    it('should mint an erc20 asset', async () => {
        const {company, testERC20, avatar} = ecosystem
        const asset = testERC20.assetAddress.toString();
        const to = avatar.address.toString();
        const amount = ethers.parseEther("10.0");
        const r = await company.mintERC20(asset, to, amount);
        expect(r.receipt.status).to.equal(1);
        expect(r.amount).to.be.greaterThan(0);
        const erc20 = new ERC20Asset({address: asset, provider: ethers.provider, logParser: stack.logParser})
        const balance = await erc20.balanceOf(to);
        expect(balance).to.equal(amount);
    })
    
    it('should mint an erc721 asset', async () => {
        const {company, testERC721, avatar} = ecosystem
        const asset = testERC721.assetAddress.toString();
        const to = avatar.address.toString();
        const r = await company.mintERC721(asset, to);
        expect(r.receipt.status).to.equal(1);
        expect(r.tokenId).to.be.greaterThan(0);
        mintedERC721TokenId = r.tokenId;
        const assetCon = new ERC721Asset({address: asset, provider: ethers.provider, logParser: stack.logParser})
        const owner = await assetCon.ownerOf(r.tokenId);
        const balance = await assetCon.balanceOf(to);
        expect(owner).to.equal(to);
        expect(balance).to.equal(1);

    })
    it('should revoke an erc20 asset', async () => {
        const {company, testERC20, avatar} = ecosystem
        const asset = testERC20.assetAddress.toString();
        const to = avatar.address.toString();
        const amount = ethers.parseEther("10.0");
        const result = await company.revoke(asset, to, amount);
        const r = await result.wait();
        expect(r?.status).to.equal(1);
        const assetCon = new ERC20Asset({address: asset, provider: ethers.provider, logParser: stack.logParser})
        const balance = await assetCon.balanceOf(to);
        expect(balance).to.equal(0);
    })
    it('should revoke an erc721 asset', async () => {
        const {company, testERC721, avatar} = ecosystem
        const asset = testERC721.assetAddress.toString();
        const to = avatar.address.toString();
        const tokenId = mintedERC721TokenId;
        const result = await company.revoke(asset, to, tokenId);
        const r = await result.wait();
        expect(r?.status).to.equal(1);
        const assetCon = new ERC721Asset({address: asset, provider: ethers.provider, logParser: stack.logParser})
        const balance = await assetCon.balanceOf(to);
        expect(balance).to.equal(0);
    })
    // ------------------- Hook tests -------------------
    it('should add a hook tocompany', async () => {
        const {company} = ecosystem
        //use another contract as hook since on chain checks that it's a contract
        const wStack = stack.getStack<IWorldStack>(StackType.WORLD);
        const wReg = wStack.getWorldRegistry();
        const hook = wReg.address;
        const result = await company.setHook(hook);
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
        const hookAddr = await company.getHook();
        expect(hookAddr.toLowerCase()).to.equal(hook.toLowerCase());
       
    })
    it('should remove a hook from company', async () => {
        const {company} = ecosystem
        const result = await company.removeHook();
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
        const hookAddr = await company.getHook();
        const ZeroAddress = '0x' + '0'.repeat(40);
        expect(hookAddr).to.equal(ZeroAddress);
    })
    // ------------------- Experience tests -------------------
    it('should add experience to a company', async () => {
        const {company, experience} = ecosystem
        const expAddress = experience.address;
        const experienceRegistry = await stack.getStack<ExperienceStackImpl>(StackType.EXPERIENCE).getExperienceRegistry();
        const isExp = await experienceRegistry.isExperience(expAddress);
        const {portalId} = await experienceRegistry.getExperienceInfo(expAddress);
        expect(isExp).to.be.true;
        const owns = await company.companyOwnsDestinationPortal(portalId);
        expect(owns).to.be.true;
        const expInstance = new Experience({
            address: expAddress,
            portalId: portalId,
            provider: ethers.provider,
            logParser: stack.logParser
        });
        const vector = await expInstance.vectorAddress();
        expect(vector.p).to.be.greaterThan(0);
        expect(vector.p_sub).to.be.greaterThan(0);
    })

   

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
    it('should change portal fee for a company', async () => {
        const {company, experience} = ecosystem
        const fee = ethers.parseEther("0.1").toString();
        const result = await company.changeExperiencePortalFee(experience.address, fee);
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
        const prStack = stack.getStack<PortalStackImpl>(StackType.PORTAL);
        const portalRegistry = prStack.getPortalRegistry();
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
            expect(e.message).to.contain('experience name already exists')
        }
    })
    // --------------------Asset Hook tests --------------------
    it('should add an asset hook to a company', async () => {
        const {company, testERC20, testERC721} = ecosystem
        //simulate hook with another contract
        const wStack = stack.getStack<IWorldStack>(StackType.WORLD);
        const wReg = wStack.getWorldRegistry();
        const hook = wReg.address;
        const erc20Result = await company.addAssetHook(testERC20.assetAddress.toString(), hook);
        const erc20R = await erc20Result.wait();
        expect(erc20Result).to.not.be.undefined;
        expect(erc20R?.status).to.equal(1);

        const erc20 = new ERC20Asset({address: testERC20.assetAddress.toString(), provider: ethers.provider, logParser: stack.logParser})
        const hookAddr = await erc20.hook();
        expect(hookAddr.toLowerCase()).to.equal(hook.toLowerCase());

        const erc721Result = await company.addAssetHook(testERC721.assetAddress.toString(), hook);
        const erc721R = await erc721Result.wait();
        expect(erc721Result).to.not.be.undefined;
        expect(erc721R?.status).to.equal(1);


        const erc721 = new ERC721Asset({address: testERC721.assetAddress.toString(), provider: ethers.provider, logParser: stack.logParser})
        const hookAddr2 = await erc721.hook();
        expect(hookAddr2.toLowerCase()).to.equal(hook.toLowerCase());
    })
    it('should remove an asset hook from an asset', async () => {
        const {company, testERC20, testERC721} = ecosystem
        const result = await company.removeAssetHook(testERC20.assetAddress.toString());
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
        const erc20 = new ERC20Asset({address: testERC20.assetAddress.toString(), provider: ethers.provider, logParser: stack.logParser})
        const hookAddr = await erc20.hook();
        const ZeroAddress = '0x' + '0'.repeat(40);
        expect(hookAddr).to.equal(ZeroAddress);

        const result2 = await company.removeAssetHook(testERC721.assetAddress.toString());
        const r2 = await result2.wait();
        expect(result2).to.not.be.undefined;
        expect(r2?.status).to.equal(1);
        const erc721 = new ERC721Asset({address: testERC721.assetAddress.toString(), provider: ethers.provider, logParser: stack.logParser})
        const hookAddr2 = await erc721.hook();
        expect(hookAddr2).to.equal(ZeroAddress);
    })
    // -------------------- withdraw tests --------------------
    it('should withdraw tokens from a company', async () => {
        const {company} = ecosystem
        await stack.admins.registrarAdmin.sendTransaction({
            to: company.address,
            value: ethers.parseEther("1.0")
        });
        const balBefore = await company.tokenBalance();
        const result = await company.withdraw(balBefore);
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
        const balAfter = await ethers.provider.getBalance(company.address);
        expect(balAfter).to.equal(0);
    })

    it("Should remove experience from a company", async () => {
        const {company, experience} = ecosystem
        const result = await company.removeExperience(experience.address);
        const r = await result.wait();
        expect(r).to.not.be.undefined;
        expect(r!.status).to.equal(1);
        const expRegistry = await stack.getStack<ExperienceStackImpl>(StackType.EXPERIENCE).getExperienceRegistry();
        const isExp = await expRegistry.isExperience(experience.address);
        expect(isExp).to.be.false;
        expect(await experience.isActive()).to.be.false;
        const logParser = stack.logParser
        const logs = await logParser.parseLogs(r!);
        const expRemoved = logs.get("PortalRemoved");
        expect(expRemoved).to.not.be.undefined;
        expect(expRemoved!.length).to.equal(1);
        const expLog = expRemoved![0];
        expect(expLog.args[1]).to.equal(experience.address);
    });

    it('should reregister an experience', async () => {
        const {company, experience} = ecosystem
        const expReg = await stack.getStack<ExperienceStackImpl>(StackType.EXPERIENCE).getExperienceRegistry();
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
            logParser: stack.logParser
        });
        const vector = await expInstance.vectorAddress();
        expect(vector.p).to.be.greaterThan(0);
        expect(vector.p_sub).to.be.greaterThan(0);
        isExp = await expReg.isExperience(expInstance.address);
        expect(isExp).to.be.true;
    })

    

    // -------------------- upgrade tests --------------------
    /*it('should upgrade a company', async () => {
        const initData = "0x";
        const result = await company.upgrade(initData);
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
    })
        */

    // -------------------- Company Scenario --------------------
    
    
});


