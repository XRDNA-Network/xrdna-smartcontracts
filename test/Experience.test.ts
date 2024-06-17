import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { ethers } from "hardhat";
import {  World, ICompanyRegistrationResult, IAvatarRegistrationResult } from "../src";

import { StackFactory, StackType } from "./test_stack/StackFactory";
import { AvatarStackImpl } from "./test_stack/avatar/AvatarStackImpl";
import { ExperienceStackImpl } from "./test_stack/experience/ExperienceStackImpl";
import { Company } from "../src/company/Company";
import { Experience, ExperienceRegistry } from "../src/experience";
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
    let world: World;
    let companyInfo: ICompanyRegistrationResult
    let userSigner: HardhatEthersSigner;
    let avatarStack: AvatarStackImpl
    let experience: Experience
    let experienceStack: ExperienceStackImpl
    let experienceRegistry: ExperienceRegistry
    let avatar: IAvatarRegistrationResult
    let avatarOwner: HardhatEthersSigner
    before(async () => {
        signers = await ethers.getSigners();
        
        worldOwner = signers[1];
        companyOwner = signers[2];
        avatarOwner = signers[3];
        stack = new StackFactory({
            worldOwner: worldOwner,
            companyOwner: companyOwner,
            avatarOwner: avatarOwner,
        });
        const {world:w, worldRegistration: wr} = await stack.init();
        world = w;
        experienceStack = stack.getStack(StackType.EXPERIENCE);
        experienceRegistry = experienceStack.getExperienceRegistry();
        // register an avatar
        avatarStack = stack.getStack(StackType.AVATAR);
       
        companyInfo = await world.registerCompany({
            sendTokensToCompanyOwner: false,
            owner: companyOwner.address,
            name: "Test Company"
        })
        
        company = new Company({
            address: await companyInfo.companyAddress.toString(),
            admin: companyOwner,
            logParser: stack.logParser
        });
        
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
            provider: ethers.provider,
            logParser: stack.logParser
        });

        avatar = await world.registerAvatar({
            sendTokensToAvatarOwner: false,
            avatarOwner: avatarOwner.address,
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