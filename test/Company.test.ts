
import { ethers } from "hardhat";
import { Company } from "../src/company/Company";
import { IAvatarRegistrationResult, ICompanyRegistrationResult, IWorldRegistrationResult, World, WorldRegistry } from "../src/world";
import { HardhatTestKeys } from "./HardhatTestKeys";
import { IStackAdmins, StackFactory, StackType } from "./test_stack/StackFactory"
import { CompanyStackImpl } from "./test_stack/company/CompanyStackImpl";
import { WorldStackImpl } from "./test_stack/world/WorldStackImpl";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { AssetRegistry, AssetType, CreateAssetResult, ERC20Asset, ERC721Asset, VectorAddress, signVectorAddress } from "../src";
import { expect } from "chai";
import { CompanyFactory } from "../src/company/CompanyFactory";
import { AssetStackImpl } from "./test_stack/asset/AssetStackImpl";
import { ERC20, ERC20__factory, TestERC20, TestERC721 } from "../typechain-types";
import { BaseContract } from "ethers";
import { Avatar } from "../src/avatar/Avatar";
import { AvatarStackImpl } from "./test_stack/avatar/AvatarStackImpl";
import { Experience } from "../src/experience";
import { ExperienceStackImpl } from "./test_stack/experience/ExperienceStackImpl";
import { ExperienceInfoStruct } from "../typechain-types/contracts/experience/ExperienceRegistry";
import {abi as BaseAssetABI} from "../artifacts/contracts/asset/BaseAsset.sol/BaseAsset.json"
import exp from "constants";


describe('Company', () => {
    let signers: HardhatEthersSigner[];
    let registrarAdmin:HardhatEthersSigner
    let registrarSigner:HardhatEthersSigner
    let worldRegistryAdmin:HardhatEthersSigner
    let worldOwner:HardhatEthersSigner
    let companyOwner:HardhatEthersSigner
    let stack: StackFactory;
    let company: Company;
    let companyFactory: CompanyFactory
    let worldStack: IWorldRegistrationResult;
    let world: World;
    let companyInfo: ICompanyRegistrationResult
    let userSigner: HardhatEthersSigner;
    let assetStack: AssetStackImpl
    let assetRegistry: AssetRegistry
    let testERC20Asset: TestERC20;
    let testERC721Asset: TestERC721
    let testERC20: CreateAssetResult
    let testERC721: CreateAssetResult
    let avatarStack: AvatarStackImpl
    let experience: Experience
    let experienceStack: ExperienceStackImpl
    let avatar: IAvatarRegistrationResult
    before(async () => {
        signers = await ethers.getSigners();
        
        registrarAdmin = signers[0];
        registrarSigner = signers[0];
        worldRegistryAdmin = signers[0];
        worldOwner = signers[1];
        companyOwner = signers[2];
        userSigner = signers[3];
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
        const {world:w, worldRegistration: wr} = await stack.init();
        world = w;
        assetStack = stack.getStack(StackType.ASSET);
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
        
        
        assetRegistry = await assetStack.getAssetRegistry()
        
        companyInfo = await world.registerCompany({
            sendTokensToCompanyOwner: false,
            owner: companyOwner.address,
            name: "Test Company",
            initData: "0x"
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

        testERC20 = await assetRegistry.registerAsset(AssetType.ERC20, erc20InitData)
        const isERC20Registered = await assetRegistry.isRegisteredAsset(testERC20.assetAddress.toString())
        if (!isERC20Registered) {
            throw new Error("ERC20 asset not registered")
        }

        testERC721 = await assetRegistry.registerAsset(AssetType.ERC721, erc721InitData)
        const isERC721Registered = await assetRegistry.isRegisteredAsset(testERC721.assetAddress.toString())
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
        
        // encode the experience init data struct as bytes
       const expInitDataStruct = {
            name: "TestExperience",
            fee: 0n,
            // 32 0 bytes 
            connectionDetails: "0x",
       }

       const expInitDataBytes = ethers.AbiCoder.defaultAbiCoder().encode(
              ['tuple(string name, uint256 fee, bytes connectionDetails)'],
              [expInitDataStruct]
         )

        
        const experienceTxn = await company.addExperience({
            name: "Test Experience",
            initData: expInitDataBytes
        })
        const expR = await experienceTxn.wait();
        const logs = expR?.logs!;
        const expAdded = logs[2]
        const experienceAddress = '0x' + expAdded.topics[1].slice(26)
        console.log('experience address', experienceAddress)
        experience = new Experience({
            address: experienceAddress,
            admin: companyOwner
        })    

        const avatarInitDataStruct = {
            username: "Test Avatar",
            canReceiveTokensOutsideOfExperience: false,
            appearanceDetails: "0x",
        }

        const avatarInitDataBytes = ethers.AbiCoder.defaultAbiCoder().encode(
            ['tuple(string username, bool canReceiveTokensOutsideOfExperience, bytes appearanceDetails)'],
            [avatarInitDataStruct]
        )
        
        avatar = await world.registerAvatar({
            sendTokensToAvatarOwner: false,
            avatarOwner: userSigner.address,
            defaultExperience: experienceAddress,
            username: "Test Avatar",
            initData: avatarInitDataBytes
        })
        
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
    })
    // ------------------- Asset tests -------------------
    it('should be able to mint an ERC20 asset', async () => {
        const asset = testERC20.assetAddress.toString();
        const to = avatar.avatar.toString();
        const amount = ethers.parseEther("10.0").toString();
        const result = await company.canMint(asset, to, amount);
        expect(result).to.be.true;
    })
    it('should be able to mint an ERC721 asset', async () => {
        const asset = testERC721.assetAddress.toString();
        const to = avatar.avatar.toString();
        const tokenId = "1";
        const result = await company.canMint(asset, to, tokenId);
        expect(result).to.be.true;
    })
    it('should mint an erc20 asset', async () => {
        const asset = testERC20.assetAddress.toString();
        const to = avatar.avatar.toString();
        const amount = ethers.parseEther("10.0").toString();
        const result = await company.mint(asset, to, amount);
        const r = await result.wait();
        expect(r?.status).to.equal(1);
    })
    it('should mint an erc721 asset', async () => {
        const asset = testERC721.assetAddress.toString();
        const to = avatar.avatar.toString();
        const tokenId = "1";
        const result = await company.mint(asset, to, tokenId);
        const r = await result.wait();
        expect(r?.status).to.equal(1);
    })
    it('should revoke an erc20 asset', async () => {
        const asset = testERC20.assetAddress.toString();
        const to = userSigner.address;
        const amount = ethers.parseEther("10.0").toString();
        const result = await company.revoke(asset, to, amount);
        const r = await result.wait();
        expect(r?.status).to.equal(1);
    })
    it('should revoke an erc721 asset', async () => {
        const asset = testERC721.assetAddress.toString();
        const to = userSigner.address;
        const tokenId = "1";
        const result = await company.revoke(asset, to, tokenId);
        const r = await result.wait();
        expect(r?.status).to.equal(1);
    })
    // ------------------- Hook tests -------------------
    it('should add a hook tocompany', async () => {
        //declare hook as a variable that equals a random 20 byte evm address
        const hook = ethers.hexlify(ethers.randomBytes(20));
        const result = await company.setHook(hook);
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
       
    })
    it('should remove a hook from company', async () => {
        const result = await company.removeHook();
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
    })
    // ------------------- Experience tests -------------------
    it('should add experience to a company', async () => {
        expect(experience).to.not.be.undefined;
        expect(experience.address).to.not.be.undefined;
    })

    it('should add experience condition to a company', async () => {
        
        const condition = ethers.hexlify(ethers.randomBytes(20));
        const result = await company.addExperienceCondition(experience.address, condition);
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
    })
    it('should remove experience condition from a company', async () => {
        const result = await company.removeExperienceCondition(experience.address);
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
    })
    // --------------------Asset Hook tests --------------------
    it('should add an asset hook to a company', async () => {
        const hook = ethers.hexlify(ethers.randomBytes(20));
        const result = await company.setHook(hook);
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
    })
    it('should remove an asset hook from a company', async () => {
        const result = await company.removeHook();
        const r = await result.wait();
        expect(result).to.not.be.undefined;
        expect(r?.status).to.equal(1);
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
    })
    
});

