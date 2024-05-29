import { ethers } from "hardhat";
import { RegistrarUtils } from "../RegistrarUtils";
import { WorldFactoryUtils } from "./WorldFactoryUtils";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { throwError } from "../utils";
import { AddressLike } from "ethers";
import { IWorldInfo } from "../../src";
import { abi as WorldRegistryABI } from "../../artifacts/contracts/world/WorldRegistry.sol/WorldRegistry.json";
import { LogParser } from "../../src";


export class WorldRegistryUtils {
    worldRegistry: any = null;
    worldRegistryAddress: string | null = null;
    masterWorld: any = null;

    static worldRegistryAt(props: {
        address: string,
        vectorAuthority: string,
        admin: HardhatEthersSigner,
        regUtils: RegistrarUtils,
        facUtils: WorldFactoryUtils
    }): WorldRegistryUtils {
        const {admin, address, regUtils, facUtils} = props; 
        const utils = new WorldRegistryUtils(regUtils, facUtils);
        utils.worldRegistry = new ethers.Contract(address, WorldRegistryABI, admin);
        utils.worldRegistryAddress = address;
        return utils;
    }

    constructor(
        readonly regUtils: RegistrarUtils,
        readonly facUtils: WorldFactoryUtils
    ) {
    }

    async deployWorldRegistry(props: {
        admin: HardhatEthersSigner,
        vectorAddressAuthority: string
    }) {
        if(this.worldRegistry) {
            return;
        }

        const WorldRegistry = await ethers.getContractFactory("WorldRegistry");
        const worldRegistry = await WorldRegistry.deploy(props.vectorAddressAuthority, this.regUtils.registryAddress, this.facUtils.factoryAddress || throwError("WorldFactory not deployed"), props.admin.address);
        const t = await worldRegistry.deploymentTransaction()?.wait();
        this.worldRegistryAddress = t?.contractAddress || "";
        console.log("WorldRegistry deployed at", this.worldRegistryAddress);
        this.worldRegistry = worldRegistry;
        await this.facUtils.setWorldRegistry(this.worldRegistryAddress);
    }

    async setMasterWorld(world: any) {
        this.masterWorld = world;
    }

    async createWorld(props: {
        registrarSigner: HardhatEthersSigner,
        registrarId: bigint,
        owner: AddressLike,
        details: IWorldInfo,
        tokensToOwner: boolean,
        tokens?: bigint
    }) {
        if(!this.worldRegistry) {
            throw new Error("WorldRegistry not deployed");
        }

        const {registrarId, registrarSigner, owner, details, tokensToOwner} = props;
        //const initData = encodeWorldInfo(details);
        let initData = await this.masterWorld.interface.encodeFunctionData("encodeInfo", [details]);
        initData = `0x${initData.substring(10)}`;
        const t = await this.worldRegistry.connect(registrarSigner).register(registrarId, owner, initData, tokensToOwner, {
            value: props.tokens
        });
        const r = await t.wait();
        const parse = new LogParser(WorldRegistryABI, this.worldRegistryAddress || throwError("WorldRegistry not deployed"));
        const logs = parse.parseLogs(r);
        const args = logs.get("WorldRegistered");
        if(!args) {
            throw new Error("World not created");
        }
        const addr = args[0];
        return {receipt: r, worldAddress: addr};
    }

    async lookupWorldAddress(name: string) {
        if(!this.worldRegistry) {
            throw new Error("WorldRegistry not deployed");
        }

        const addr = await this.worldRegistry.worldsByName(name.toLowerCase());
        return addr;
    }
}