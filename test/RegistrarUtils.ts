import { ethers } from "hardhat";
import { AddressLike } from "ethers";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import {abi as RegistrarRegistryABI} from "../artifacts/contracts/RegistrarRegistry.sol/RegistrarRegistry.json";


export class RegistrarUtils  {
    registry: any = null;
    registryAddress: string = "";

    static registrarAt(props: {
        address: string,
        admin: HardhatEthersSigner
    }): RegistrarUtils {
        const {address, admin} = props; 
        const utils = new RegistrarUtils();
        utils.registry = new ethers.Contract(address, RegistrarRegistryABI, admin);
        utils.registryAddress = address;
        return utils;
    }

    async deployRegistry(props: {
        registrarAdmin: HardhatEthersSigner, 
        signers: AddressLike[]
    }) {
        if(this.registry) {
            return;
        }

        const {signers} = props;
        const Registry = await ethers.getContractFactory("RegistrarRegistry");
        const registry = await Registry.deploy(signers);
        const t = await registry.deploymentTransaction()?.wait();
        this.registryAddress = t?.contractAddress || "";
        console.log("Registry deployed at", this.registryAddress);
        this.registry = registry;
    }

    async registerRegistrar(props: {
        admin: HardhatEthersSigner, signer: string, tokens?: bigint
    }) {
        if(!this.registry) {
            throw new Error("Registry not deployed");
        }
        const {admin, signer, tokens} = props;

        const t = await (this.registry.connect(admin) as any).register(signer, {
            value: tokens
        });
        const r = await t.wait();
        const id = r.logs[0].args[0];
        return {receipt: r, registrarId: id};
    }

    async addSigners(props: {
        signer: HardhatEthersSigner, 
        registrarId: bigint, 
        addies: string[]
    }) {
        if(!this.registry) {
            throw new Error("Registry not deployed");
        }
        const {signer, registrarId, addies} = props;
        const t = await (this.registry.connect(signer) as any).addSigners(registrarId, addies);
        const r = await t.wait();
        return r;
    }

    async removeSigners(props: {
        signer: HardhatEthersSigner, 
        registrarId: bigint, 
        addies: string[]
    }) {
        if(!this.registry) {
            throw new Error("Registry not deployed");
        }
        const {signer, registrarId, addies} = props;
        const t = await (this.registry.connect(signer) as any).removeSigners(registrarId, addies);
        const r = await t.wait();
        return r;
    }

    async isRegistrar(props: {
        registrarId: bigint, signer: string
    }) {
        if(!this.registry) {
            throw new Error("Registry not deployed");
        }
        const {registrarId, signer} = props;
        const r = await this.registry.isRegistrar(registrarId, signer);
        return r;
    }
}

