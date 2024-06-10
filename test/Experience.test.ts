import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { IWorldRegistrationResult, World, ICompanyRegistrationResult, AssetRegistry, CreateAssetResult, IAvatarRegistrationResult, AssetType } from "../src";

import { StackFactory, StackType } from "./test_stack/StackFactory";
import { AssetStackImpl } from "./test_stack/asset/AssetStackImpl";
import { AvatarStackImpl } from "./test_stack/avatar/AvatarStackImpl";
import { ExperienceStackImpl } from "./test_stack/experience/ExperienceStackImpl";
import { Company } from "../src/company/Company";
import { CompanyFactory } from "../src/company/CompanyFactory";
import { TestERC20, TestERC721 } from "../typechain-types";
import { Experience, ExperienceRegistry } from "../src/experience";
import {abi as BaseAssetABI} from "../artifacts/contracts/asset/BaseAsset.sol/BaseAsset.json";
import { expect } from "chai";

describe('Experience', () => {
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
    let experienceRegistry: ExperienceRegistry
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
        experienceRegistry = experienceStack.getExperienceRegistry();
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
            admin: companyOwner
        });

        avatar = await world.registerAvatar({
            sendTokensToAvatarOwner: false,
            avatarOwner: userSigner.address,
            defaultExperience: experience.address,
            username: "Test Avatar",
            appearanceDetails: "0x",
            canReceiveTokensOutsideOfExperience: false
        });
        
    });

    it('should register an experience', async () => {
        expect(experience).to.not.be.undefined;
        const isExperience = await experienceRegistry.isExperience(experience.address)
        expect(isExperience).to.be.true;
    })

   

})