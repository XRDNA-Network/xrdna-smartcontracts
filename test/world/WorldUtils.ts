import { WorldFactoryUtils } from "./WorldFactoryUtils";
import { WorldRegistryUtils } from "./WorldRegistryUtils";
import { RegistrarUtils } from "../RegistrarUtils";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { throwError } from "../utils";
import { abi as WorldABI } from "../../artifacts/contracts/world/World.sol/World.json";


export class WorldUtils {
    registrarUtils: RegistrarUtils | null = null;
    worldFactoryUtils: WorldFactoryUtils | null = null;
    worldRegistryUtils: WorldRegistryUtils | null = null;
    worldImplAddress: string = "";
    worldImpl: any = null;

    static masterWorldAt(props: {
        registrarAdmin: HardhatEthersSigner,
        registrarAddress: string,
        worldFactoryAdmin: HardhatEthersSigner,
        worldFactoryAddress: string,
        worldRegistryAdmin: HardhatEthersSigner,
        worldRegistryAddress: string,
        address: string,
    }): WorldUtils {
        const utils = new WorldUtils();
        const impl = new ethers.Contract(props.address, WorldABI, ethers.provider);
        utils.worldImpl = impl;
        utils.worldImplAddress = props.address;

        utils.registrarUtils = RegistrarUtils.registrarAt({
            address: props.registrarAddress,
            admin: props.registrarAdmin
        });

        utils.worldFactoryUtils = WorldFactoryUtils.factoryAt({
            address: props.worldFactoryAddress,
            admin: props.worldFactoryAdmin
        });

        utils.worldRegistryUtils = WorldRegistryUtils.worldRegistryAt({
            address: props.worldRegistryAddress,
            admin: props.worldRegistryAdmin,
            regUtils: utils.registrarUtils,
            facUtils: utils.worldFactoryUtils
        });
        utils.worldRegistryUtils.setMasterWorld(impl);
        return utils;
    }

    async deployWorldMaster(props: {
        registrarAdmin: HardhatEthersSigner,
        registrarSigner: HardhatEthersSigner,
        worldFactoryAdmin: HardhatEthersSigner,
        worldRegistryAdmin: HardhatEthersSigner,
    }) {
        if(this.worldFactoryUtils) {
            return;
        }

        //first deploy registrar
        this.registrarUtils = new RegistrarUtils();
        await this.registrarUtils.deployRegistry({
            registrarAdmin: props.registrarAdmin,
            signers: [props.registrarSigner.address]
        });

        this.worldFactoryUtils = new WorldFactoryUtils();
        await this.worldFactoryUtils.deployFactory({
            admins: [props.worldFactoryAdmin]
        });

        this.worldRegistryUtils = new WorldRegistryUtils(this.registrarUtils, this.worldFactoryUtils);
        await this.worldRegistryUtils.deployWorldRegistry({
            admin: props.worldRegistryAdmin
        });


        const impl = await ethers.getContractFactory("World");
        const t = await impl.deploy(this.worldFactoryUtils.factoryAddress || throwError("WorldFactory  not deployed"), this.worldRegistryUtils.worldRegistryAddress || throwError("WorldRegistry not deployed"));
        const r = await t.deploymentTransaction()?.wait();
        this.worldImplAddress = r?.contractAddress || "";
        this.worldImpl = t;
        this.worldRegistryUtils.setMasterWorld(this.worldImpl);
        await this.worldFactoryUtils.setImplementation(this.worldImplAddress);
    }

    async addSigners(props: {
        worldSigner: HardhatEthersSigner,
        newSigners: string[],
        worldName: string
    }) {
        const addy = await this.worldRegistryUtils?.lookupWorldAddress(props.worldName);
        if(!addy) {
            throw new Error("World not found");
        }
        const con = new ethers.Contract(addy, this.worldImpl.interface, props.worldSigner);
        const t = await con.addSigners(props.newSigners);
        const r = await t.wait();
        return r;
    }

    async removeSigners(props: {
        worldSigner: HardhatEthersSigner,
        signers: string[],
        worldName: string
    }) {
        const addy = await this.worldRegistryUtils?.lookupWorldAddress(props.worldName);
        if(!addy) {
            throw new Error("World not found");
        }
        const con = new ethers.Contract(addy, this.worldImpl.interface, props.worldSigner);
        const t = await con.removeSigners(props.signers);
        const r = await t.wait();
        return r;
    }

    async isSigner(props: {
        address: string,
        worldName: string
    }) {
        const addy = await this.worldRegistryUtils?.lookupWorldAddress(props.worldName);
        if(!addy) {
            throw new Error("World not found");
        }
        const con = new ethers.Contract(addy, this.worldImpl.interface, ethers.provider);
        const is = await con.isSigner(props.address);
        return is;
    }

    async withdraw(props: {
        worldSigner: HardhatEthersSigner,
        worldName: string,
        amount: bigint
    }) {
        const addy = await this.worldRegistryUtils?.lookupWorldAddress(props.worldName);
        if(!addy) {
            throw new Error("World not found");
        }
        const con = new ethers.Contract(addy, this.worldImpl.interface, props.worldSigner);
        const t = await con.withdraw(props.amount);
        const r = await t.wait();
        return r;
    }
}