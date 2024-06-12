
import { ethers } from "hardhat";
import { Company } from "../src/company/Company";
import { IAvatarRegistrationResult, ICompanyRegistrationResult, World } from "../src/world";
import { HardhatTestKeys } from "./HardhatTestKeys";
import { StackFactory, StackType } from "./test_stack/StackFactory"
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai";
import { ERC20, TestERC20, TestERC721 } from "../typechain-types";
import { AvatarStackImpl } from "./test_stack/avatar/AvatarStackImpl";
import { Experience } from "../src/experience";
import { ExperienceStackImpl } from "./test_stack/experience/ExperienceStackImpl";
import {abi as BaseAssetABI} from "../artifacts/contracts/asset/BaseAsset.sol/BaseAsset.json"
import { IERC20AssetStack } from "./test_stack/asset/erc20/IERC20AssetStack";
import { CreateERC20AssetResult, CreateERC721AssetResult, ERC20Asset, ERC20AssetRegistry, ERC721Asset, ERC721AssetRegistry, MultiAssetRegistry } from "../src";
import { IERC721AssetStack } from "./test_stack/asset/erc721/IERC721AssetStack";
import { IMultiAssetRegistryStack } from "./test_stack/asset/IMultiAssetRegistryStack";
import exp from "constants";
import { PortalStackImpl } from "./test_stack/portal/PortalStackImpl";


describe('Company', () => {
    let signers: HardhatEthersSigner[];
    let registrarAdmin:HardhatEthersSigner
    let registrarSigner:HardhatEthersSigner
    let worldRegistryAdmin:HardhatEthersSigner
    let worldOwner:HardhatEthersSigner
    let companyOwner:HardhatEthersSigner
    let avatarOwner:HardhatEthersSigner
    let stack: StackFactory;
    let company: Company;
    let world: World;
    let companyInfo: ICompanyRegistrationResult
    let erc20Stack: IERC20AssetStack;
    let erc20Registry: ERC20AssetRegistry;
    let erc721Stack: IERC721AssetStack;
    let erc721Registry: ERC721AssetRegistry;
    let multiAssetRegistry: MultiAssetRegistry;
    let testERC20Asset: TestERC20;
    let testERC721Asset: TestERC721;
    let testERC20: CreateERC20AssetResult;
    let testERC721: CreateERC721AssetResult;
    let avatarStack: AvatarStackImpl
    let experience: Experience
    let experienceStack: ExperienceStackImpl
    let avatar: IAvatarRegistrationResult
    let mintedERC721TokenId: bigint;
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
        erc20Stack = stack.getStack(StackType.ERC20);
        erc721Stack = stack.getStack(StackType.ERC721);
        experienceStack = stack.getStack(StackType.EXPERIENCE);
        // register an avatar
        avatarStack = stack.getStack(StackType.AVATAR);
        const avatarRegistry = await avatarStack.getAvatarRegistry();
        const TestERC20Asset = await ethers.getContractFactory("TestERC20", companyOwner)
        const TestERC721Asset = await ethers.getContractFactory("TestERC721", companyOwner)
        const dep2 = await TestERC721Asset.deploy("Test ERC721 Asset", "TEST721")
        const dep = await TestERC20Asset.deploy("Test ERC20 Asset", "TEST20")
        testERC20Asset = await dep.waitForDeployment() as TestERC20;
        testERC721Asset = await dep2.waitForDeployment() as TestERC721;
        
        
        erc20Registry = await erc20Stack.getERC20Registry();
        erc721Registry = await erc721Stack.getERC721Registry();
        multiAssetRegistry = await stack.getStack<IMultiAssetRegistryStack>(StackType.MULTI_ASSET).getMultiAssetRegistry();
        
        companyInfo = await world.registerCompany({
            sendTokensToCompanyOwner: false,
            owner: companyOwner.address,
            name: "Test Company"
        })
        
        
        company = new Company({
            address: await companyInfo.companyAddress.toString(),
            admin: companyOwner,
            
        })
        const erc20InitData = {
            originChainAddress: await testERC20Asset.getAddress(),
            issuer: company.address,
            originChainId: 1n,
            totalSupply: ethers.parseEther('1000000'),
            decimals: 18,
            name: "Test ERC20 Asset",
            symbol: "TEST20"
        }
        const erc721InitData = {
            issuer: company.address,
            originChainAddress: await testERC721Asset.getAddress(),
            name: "Test ERC721 Asset",
            symbol: "TEST721",
            baseURI: "https://test.com/",
            originChainId: 1n
        }

        testERC20 = await erc20Registry.registerAsset(erc20InitData)
        const isERC20Registered = await multiAssetRegistry.isRegisteredAsset(testERC20.assetAddress.toString())
        if (!isERC20Registered) {
            throw new Error("ERC20 asset not registered")
        }

        testERC721 = await erc721Registry.registerAsset(erc721InitData)
        const isERC721Registered = await multiAssetRegistry.isRegisteredAsset(testERC721.assetAddress.toString())
        if (!isERC721Registered) {
            throw new Error("ERC721 asset not registered")
        }

        const erc20Contract = new ethers.Contract(testERC20.assetAddress.toString(), BaseAssetABI, companyOwner)
        const erc20issuer = await erc20Contract.issuer()
        const erc721Contract = new ethers.Contract(testERC721.assetAddress.toString(), BaseAssetABI, companyOwner)
        const erc721issuer = await erc721Contract.issuer()
        if (erc20issuer !== company.address) {
            throw new Error("ERC20 issuer not correct")
        }
        if (erc721issuer !== company.address) {
            throw new Error("ERC721 issuer not correct")
        }
        
        const expRes = await company.addExperience({
            name: "Test Experience",
            connectionDetails: "0x",
            entryFee: 0n,
        });
        expect(expRes).to.not.be.undefined;
        expect(expRes.experienceAddress).to.not.be.undefined;
        expect(expRes.portalId).to.not.be.undefined;
        

        experience = new Experience({
            address: expRes.experienceAddress.toString(),
            portalId: expRes.portalId,
            provider: ethers.provider
        });
        
        avatar = await world.registerAvatar({
            sendTokensToAvatarOwner: false,
            avatarOwner: avatarOwner.address,
            defaultExperience: experience.address,
            username: "Test Avatar",
            appearanceDetails: "0x",
            canReceiveTokensOutsideOfExperience: false,
        });
        
    });

    it('should register a company', async () => {
        expect(company).to.not.be.undefined;
        const name = await company.name()
        expect(name).to.equal("Test Company".toLowerCase());
    });

    it('should retrieve the owner of a company', async () => {
        const owner = await company.owner();
        expect(owner).to.equal(companyOwner.address);
    })
    it('should retrieve the world of a company', async () => {
        const w = await company.world();
        expect(w).to.equal(world.address);
    })
    it('should retrieve vector of a company', async () => {
        const v = await company.vectorAddress();
        expect(v).to.not.be.undefined;
        // created experience above, so p_sub should be greater than 0
        const nextPSub = await company.nextPSub();
        expect(nextPSub).to.be.greaterThan(0);
    })

    it('should add a signer to a company', async () => {
        const signer = HardhatTestKeys[4];
        const result = await company.addSigner(signer.address);
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
    })
    it('should check if a signer is in a company', async () => {
        const signer = HardhatTestKeys[4];
        const isSigner = await company.isSigner(signer.address);
        expect(isSigner).to.be.true;
    })

    it('should remove a signer from a company', async () => {
        const signer = HardhatTestKeys[4];
        const result = await company.removeSigner(signer.address);
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
        const isSigner = await company.isSigner(signer.address);
        expect(isSigner).to.be.false;
    })
    // ------------------- Asset tests -------------------
    it('should be able to mint an ERC20 asset', async () => {
        const asset = testERC20.assetAddress.toString();
        const to = avatar.avatarAddress.toString();
        const amount = ethers.parseEther("10.0").toString();
        const result = await company.canMint(asset, to, amount);
        expect(result).to.be.true;
    })
    it('should be able to mint an ERC721 asset', async () => {
        const asset = testERC721.assetAddress.toString();
        const to = avatar.avatarAddress.toString();
        const tokenId = "1";
        const result = await company.canMint(asset, to, tokenId);
        expect(result).to.be.true;
    })
    
    it('should mint an erc20 asset', async () => {
        const asset = testERC20.assetAddress.toString();
        const to = avatar.avatarAddress.toString();
        const amount = ethers.parseEther("10.0");
        const r = await company.mintERC20(asset, to, amount);
        expect(r.receipt.status).to.equal(1);
        expect(r.amount).to.be.greaterThan(0);
        const erc20 = new ERC20Asset({address: asset, provider: ethers.provider})
        const balance = await erc20.balanceOf(to);
        expect(balance).to.equal(amount);
    })
    
    it('should mint an erc721 asset', async () => {
        const asset = testERC721.assetAddress.toString();
        const to = avatar.avatarAddress.toString();
        const r = await company.mintERC721(asset, to);
        expect(r.receipt.status).to.equal(1);
        expect(r.tokenId).to.be.greaterThan(0);
        mintedERC721TokenId = r.tokenId;
        const assetCon = new ERC721Asset({address: asset, provider: ethers.provider})
        const owner = await assetCon.ownerOf(r.tokenId);
        const balance = await assetCon.balanceOf(to);
        expect(owner).to.equal(to);
        expect(balance).to.equal(1);

    })
    it('should revoke an erc20 asset', async () => {
        const asset = testERC20.assetAddress.toString();
        const to = avatar.avatarAddress.toString();
        const amount = ethers.parseEther("10.0");
        const result = await company.revoke(asset, to, amount);
        const r = await result.wait();
        expect(r?.status).to.equal(1);
        const assetCon = new ERC20Asset({address: asset, provider: ethers.provider})
        const balance = await assetCon.balanceOf(to);
        expect(balance).to.equal(0);
    })
    it('should revoke an erc721 asset', async () => {
        const asset = testERC721.assetAddress.toString();
        const to = avatar.avatarAddress.toString();
        const tokenId = mintedERC721TokenId;
        const result = await company.revoke(asset, to, tokenId);
        const r = await result.wait();
        expect(r?.status).to.equal(1);
        const assetCon = new ERC721Asset({address: asset, provider: ethers.provider})
        const balance = await assetCon.balanceOf(to);
        expect(balance).to.equal(0);
    })
    // ------------------- Hook tests -------------------
    it('should add a hook tocompany', async () => {
        //declare hook as a variable that equals a random 20 byte evm address
        const hook = ethers.hexlify(ethers.randomBytes(20));
        const result = await company.setHook(hook);
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
        const hookAddr = await company.hook();
        expect(hookAddr.toLowerCase()).to.equal(hook.toLowerCase());
       
    })
    it('should remove a hook from company', async () => {
        const result = await company.removeHook();
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
        const hookAddr = await company.hook();
        const ZeroAddress = '0x' + '0'.repeat(40);
        expect(hookAddr).to.equal(ZeroAddress);
    })
    // ------------------- Experience tests -------------------
    it('should add experience to a company', async () => {
        const expAddress = experience.address;
        const experienceRegistry = await experienceStack.getExperienceRegistry();
        const isExp = await experienceRegistry.isExperience(expAddress);
        expect(isExp).to.be.true;
    })

    it('should add experience condition to a company', async () => {
        
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
    // --------------------Asset Hook tests --------------------
    it('should add an asset hook to a company', async () => {
        const hook = ethers.hexlify(ethers.randomBytes(20));
        const erc20Result = await company.addAssetHook(testERC20.assetAddress.toString(), hook);
        const erc20R = await erc20Result.wait();
        expect(erc20Result).to.not.be.undefined;
        expect(erc20R?.status).to.equal(1);

        const erc20 = new ERC20Asset({address: testERC20.assetAddress.toString(), provider: ethers.provider})
        const hookAddr = await erc20.hook();
        expect(hookAddr.toLowerCase()).to.equal(hook.toLowerCase());

        const erc721Result = await company.addAssetHook(testERC721.assetAddress.toString(), hook);
        const erc721R = await erc721Result.wait();
        expect(erc721Result).to.not.be.undefined;
        expect(erc721R?.status).to.equal(1);


        const erc721 = new ERC721Asset({address: testERC721.assetAddress.toString(), provider: ethers.provider})
        const hookAddr2 = await erc721.hook();
        expect(hookAddr2.toLowerCase()).to.equal(hook.toLowerCase());
    })
    it('should remove an asset hook from an asset', async () => {
        const result = await company.removeAssetHook(testERC20.assetAddress.toString());
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
        const erc20 = new ERC20Asset({address: testERC20.assetAddress.toString(), provider: ethers.provider})
        const hookAddr = await erc20.hook();
        const ZeroAddress = '0x' + '0'.repeat(40);
        expect(hookAddr).to.equal(ZeroAddress);

        const result2 = await company.removeAssetHook(testERC721.assetAddress.toString());
        const r2 = await result2.wait();
        expect(result2).to.not.be.undefined;
        expect(r2?.status).to.equal(1);
        const erc721 = new ERC721Asset({address: testERC721.assetAddress.toString(), provider: ethers.provider})
        const hookAddr2 = await erc721.hook();
        expect(hookAddr2).to.equal(ZeroAddress);
    })
    // -------------------- withdraw tests --------------------
    it('should withdraw tokens from a company', async () => {
        registrarSigner.sendTransaction({
            to: company.address,
            value: ethers.parseEther("1.0")
        });
        const result = await company.withdraw(ethers.parseEther("1.0").toString());
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
        const bal = await ethers.provider.getBalance(company.address);
        expect(bal).to.equal(0);
    })

    // -------------------- upgrade tests --------------------
    it('should upgrade a company', async () => {
        const initData = "0x";
        const result = await company.upgrade(initData);
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
    })
    
});

