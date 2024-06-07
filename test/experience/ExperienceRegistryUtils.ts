import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { RegistrarUtils } from "../RegistrarUtils";
import {abi as ExperienceRegistryABI} from "../../artifacts/contracts/experience/ExperienceRegistry.sol/ExperienceRegistry.json";
import { ExperienceFactoryUtils } from "./ExperienceFactoryUtils";


export class ExperienceRegistryUtils {
    experienceRegistry: any = null;
    experienceRegistryAddress: string | null = null;
    masterExperience: any = null;

    static experienceRegistryAt(props: {
        address: string,
        vectorAuthority: string,
        admin: HardhatEthersSigner,
        regUtils: RegistrarUtils,
        facUtils: ExperienceFactoryUtils
    }): ExperienceRegistryUtils {
        const {admin, address, regUtils, facUtils} = props; 
        const utils = new ExperienceRegistryUtils(regUtils, facUtils);
        utils.experienceRegistry = new ethers.Contract(address, ExperienceRegistryABI, admin);
        utils.experienceRegistryAddress = address;
        return utils;
    }

    constructor(
        readonly regUtils: RegistrarUtils,
        readonly facUtils: ExperienceFactoryUtils
    ) {
    }

    async deployExperienceRegistry(props: {
        admins: HardhatEthersSigner[],
        vectorAddressAuthority: string
    }) {
        if(this.experienceRegistry) {
            return;
        }

        const ExperienceRegistry = await ethers.getContractFactory("ExperienceRegistry");
        const experienceRegistry = await ExperienceRegistry.deploy(props.vectorAddressAuthority, props.admins.map(a => a.address), this.facUtils.factoryAddress || throwError("ExperienceFactory not deployed"));
        const t = await experienceRegistry.deploymentTransaction()?.wait();
        this.experienceRegistryAddress = t?.contractAddress || "";
        console.log("ExperienceRegistry deployed at", this.experienceRegistryAddress);
        this.experienceRegistry = experienceRegistry;
        await this.facUtils.setExperienceRegistry(this.experienceRegistryAddress);
    }
}