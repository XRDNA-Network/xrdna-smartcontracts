import { AddressLike, Provider, Signer, TransactionResponse, ethers } from "ethers";
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { AllLogParser } from "../../AllLogParser";
import {abi as WorldRegistryABI} from '../../../artifacts/contracts/world/registry/IWorldRegistry.sol/IWorldRegistry.json';
import {abi as proxyABI} from '../../../artifacts/contracts/base-types/BaseProxy.sol/BaseProxy.json';
/**
 * Typescript proxy for WorldRegistry deployed contract.
 */
export interface IWorldRegistryOpts {
    address: string;
    admin: Provider | Signer;
    logParser: AllLogParser;
}


export class WorldRegistry {
    static get abi() {
        return [
            ...WorldRegistryABI,
            ...proxyABI
        ]
    }
    
    readonly address: string;
    readonly logParser: AllLogParser;
    private admin: Provider | Signer;
    private registry: ethers.Contract;

    constructor(opts: IWorldRegistryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        const abi = WorldRegistry.abi;
        if(!abi || abi.length === 0) {
            throw new Error("Invalid ABI");
        }
        this.registry = new ethers.Contract(this.address, abi, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, abi);
    }

    async lookupWorldAddress(name: string): Promise<string> {
        const addr = await RPCRetryHandler.withRetry(() => this.registry.getEntityByName(name.toLowerCase()));
        return addr;
    }

    async isWorld(address: AddressLike): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.registry.isRegistered(address));
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
}