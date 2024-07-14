import { AddressLike, Contract, Provider, Signer, TransactionResponse, ethers } from "ethers";
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { AllLogParser } from "../../AllLogParser";
import {abi as WorldRegistryABI} from '../../../artifacts/contracts/world/registry/IWorldRegistry.sol/IWorldRegistry.json';
import {abi as proxyABI} from '../../../artifacts/contracts/base-types/BaseProxy.sol/BaseProxy.json';
import { BaseRegistry } from "../../base-types/registry/BaseRegistry";
import { IWrapperOpts } from "../../interfaces/IWrapperOpts";
/**
 * Typescript proxy for WorldRegistry deployed contract.
 */
export interface IWorldRegistryOpts {
    address: string;
    admin: Provider | Signer;
    logParser: AllLogParser;
}


export class WorldRegistry extends BaseRegistry {
    static get abi() {
        return [
            ...WorldRegistryABI,
            ...proxyABI
        ]
    }
    
    private con: Contract;

    constructor(opts: IWrapperOpts) {
        super(opts);
        const abi = WorldRegistry.abi;
        if(!abi || abi.length === 0) {
            throw new Error("Invalid ABI");
        }
        this.con = new Contract(this.address, abi, this.admin);
        this.logParser.addAbi(this.address, abi);
    }

    getContract(): Contract {
        return this.con;
    }

    async lookupWorldAddress(name: string): Promise<string> {
        const addr = await RPCRetryHandler.withRetry(() => this.getEntityByName(name.toLowerCase()));
        return addr;
    }

    async isWorld(address: AddressLike): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isRegistered(address));
    }

    async  isVectorAddressAuthority(address: AddressLike): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isVectorAddressAuthority(address));
    }

    async addVectorAddressAuthority(authority: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(()=>this.con.addVectorAddressAuthority(authority));
    }

    async removeVectorAddressAuthority(authority: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() =>this.con.removeVectorAddressAuthority(authority));
    }
}