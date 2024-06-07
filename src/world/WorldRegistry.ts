import { AddressLike, Provider, Signer, TransactionResponse, ethers } from "ethers";
import {abi as WorldRegistryABI} from "../../artifacts/contracts/world/v0.2/WorldRegistry0_2.sol/WorldRegistry0_2.json";
import {abi as WorldABI} from "../../artifacts/contracts/world/v0.2/World0_2.sol/World0_2.json";
import { IWorldInfo } from "./IWorldInfo";
import { LogParser } from "../LogParser";
import { LogNames } from "../LogNames";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";
/**
 * Typescript proxy for WorldRegistry deployed contract.
 */
export interface IWorldRegistryOpts {
    address: string;
    admin: Provider | Signer;
}

export interface IWorldRegistration {
    sendTokensToWorldOwner: boolean;
    oldWorld: AddressLike;
    owner: AddressLike;
    baseVector: VectorAddress;
    name: string;
    registrarId: bigint;
    initData: string;
    vectorAuthoritySignature: string;
}

export interface IWorldRegistrationResult {
    receipt: ethers.TransactionReceipt;
    worldAddress: string;
}

export class WorldRegistry {
    readonly address: string;
    private admin: Provider | Signer;
    private registry: ethers.Contract;
    private worldIfc: ethers.Interface;

    constructor(opts: IWorldRegistryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.registry = new ethers.Contract(this.address, WorldRegistryABI, this.admin);
        this.worldIfc = new ethers.Interface(WorldABI);
    }

    async createWorld(props: {
        registrarSigner: Signer,
        details: IWorldRegistration,
        tokens?: bigint
    }): Promise<IWorldRegistrationResult> {
        

        const {registrarSigner, details} = props;
        const t = await RPCRetryHandler.withRetry(() => (this.registry.connect(registrarSigner) as any).register(details, {
            value: props.tokens
        }));

        const r = await t.wait();
        const parse = new LogParser(WorldRegistryABI, this.address);
        const logs = parse.parseLogs(r);
        const args = logs.get(LogNames.WorldRegistered);
        if(!args) {
            throw new Error("World not created");
        }
        const addr = args[0];
        return {receipt: r, worldAddress: addr};
    }

    async lookupWorldAddress(name: string): Promise<string> {
        const addr = await RPCRetryHandler.withRetry(() => this.registry.getWorldByName(name.toLowerCase()));
        return addr;
    }

    async isWorld(address: AddressLike): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.registry.isWorld(address));
    }

    async  isVectorAddressAuthority(address: AddressLike): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.registry.isVectorAddressAuthority(address));
    }

    async addVectorAddressAuthority(authority: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(()=>this.registry.addVectorAddressAuthority(authority));
    }

    async removeVectorAddressAuthority(authority: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() =>this.registry.removeVectorAddressAuthority(authority));
    }

    async upgradeWorld(world: AddressLike): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.registry.upgradeWorld(world, ""));
    }
}