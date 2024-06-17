import { AddressLike, Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/portal/PortalRegistry.sol/PortalRegistry.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";
import { AllLogParser } from "../AllLogParser";


export interface IPortalRegistryOpts {
    address: string;
    admin: Provider | Signer;
    logParser: AllLogParser;
}

export interface IAddPortalRequest {
    destination: AddressLike
    fee: bigint
}

export interface IPortalInfo {
    destination: AddressLike
    condition: AddressLike
    fee: bigint
    active: boolean
}

export class PortalRegistry {
    static get abi() {
        return abi;
    }
    
    private con: Contract;
    readonly address: string;
    private admin: Provider | Signer;
    readonly logParser: AllLogParser;

    constructor(opts: IPortalRegistryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.con = new Contract(this.address, abi, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, abi);
    }


    async setExperienceRegistry(reg: AddressLike): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setExperienceRegistry(reg));
    }

   async getPortalInfoById(id: bigint): Promise<IPortalInfo> {
        const r = await RPCRetryHandler.withRetry(() => this.con.getPortalInfoById(id));
        return {
            destination: r[0],
            condition: r[1],
            fee: r[2]
        } as IPortalInfo;
    }

    async getPortalInfoByAddress(addr: AddressLike): Promise<IPortalInfo> {
        return await RPCRetryHandler.withRetry(() => this.con.getPortalInfoByAddress(addr));
    }

    async getPortalInfoByVectorAddress(vector: VectorAddress): Promise<IPortalInfo> {
        return await RPCRetryHandler.withRetry(() => this.con.getPortalInfoByVectorAddress(vector));
    }

    async getIdForExperience(experience: AddressLike): Promise<bigint> {
        return await RPCRetryHandler.withRetry(() => this.con.getIdForExperience(experience));
    }

    async getIdForVectorAddress(vector: VectorAddress): Promise<bigint> {
        return await RPCRetryHandler.withRetry(() => this.con.getIdForVectorAddress(vector));
    }

}
