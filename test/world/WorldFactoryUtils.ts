import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { abi as WorldFactoryABI } from "../../artifacts/contracts/world/WorldFactory.sol/WorldFactory.json";


export class WorldFactoryUtils {
    factory: any = null;
    factoryAddress: string | null = null; 
    factoryAdmin: HardhatEthersSigner | null = null;

    static factoryAt(props: {
        address: string,
        admin: HardhatEthersSigner
    }): WorldFactoryUtils {
        const {address, admin} = props; 
        const utils = new WorldFactoryUtils();
        utils.factory = new ethers.Contract(address, WorldFactoryABI, admin);
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
        const Factory = await ethers.getContractFactory("WorldFactory");
        const registry = await Factory.deploy(props.admins.map(a => a.address));
        const t = await registry.deploymentTransaction()?.wait();
        this.factoryAddress = t?.contractAddress || "";
        console.log("WorldFactory deployed at", this.factoryAddress);
        this.factory = registry;

    }

    async setWorldRegistry(worldRegistryAddress: string) {
        if(!this.factory) {
            throw new Error("WorldFactory not deployed");
        }
        const t = await this.factory.connect(this.factoryAdmin).setWorldRegistry(worldRegistryAddress);
        await t.wait();
    }

    async setImplementation(implAddress: string) {
        if(!this.factory) {
            throw new Error("WorldFactory not deployed");
        }
        const t = await this.factory.connect(this.factoryAdmin).setImplementation(implAddress);
        await t.wait();
    }
}