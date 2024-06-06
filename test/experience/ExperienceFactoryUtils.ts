import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { abi as ExperienceFactoryABI } from "../../artifacts/contracts/experience/ExperienceFactory.sol/ExperienceFactory.json";


export class ExperienceFactoryUtils {
    factory: any = null;
    factoryAddress: string | null = null;
    factoryAdmin: HardhatEthersSigner | null = null;

    static factoryAt(props: {
        address: string,
        admin: HardhatEthersSigner
    }): ExperienceFactoryUtils {
        const {address, admin} = props; 
        const utils = new ExperienceFactoryUtils();
        utils.factory = new ethers.Contract(address, ExperienceFactoryABI, admin);
        utils.factoryAddress = address;
        return utils;
    }

    async deployFactory(props: {
        admins: HardhatEthersSigner[]
    }) {
        if(this.factory) {
            return;
        }

        this.factoryAdmin = props.admins[0];
        const Factory = await ethers.getContractFactory("ExperienceFactory");
        const registry = await Factory.deploy(this.factoryAdmin, props.admins.map(a => a.address));
        const t = await registry.deploymentTransaction()?.wait();
        this.factoryAddress = t?.contractAddress || "";
        console.log("ExperienceFactory deployed at", this.factoryAddress);
        this.factory = registry;
    }

    async setExperienceRegistry(experienceRegistryAddress: string) {
        if(!this.factory) {
            throw new Error("ExperienceFactory not deployed");
        }
        const t = await this.factory.connect(this.factoryAdmin).setExperienceRegistry(experienceRegistryAddress);
        await t.wait();
    }

    async setImplementation(implAddress: string) {
        if(!this.factory) {
            throw new Error("ExperienceFactory not deployed");
        }
        const t = await this.factory.connect(this.factoryAdmin).setImplementation(implAddress);
        await t.wait();
    }
}