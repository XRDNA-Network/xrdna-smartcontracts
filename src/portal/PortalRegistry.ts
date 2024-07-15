import { AddressLike, Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/portal/IPortalRegistry.sol/IPortalRegistry.json";
import {abi as proxyABI} from '../../artifacts/contracts/base-types/BaseProxy.sol/BaseProxy.json';
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";
import { AllLogParser } from "../AllLogParser";
import { BaseAccess } from "../base-types/BaseAccess";
import { IWrapperOpts } from "../interfaces/IWrapperOpts";



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

export class PortalRegistry extends BaseAccess {
    static get abi() {
        return  [
            ...abi,
            ...proxyABI
        ]
    }
    
    private con: Contract;

    constructor(opts: IWrapperOpts) {
        super(opts);
        this.con = new Contract(this.address, abi, this.admin);
        this.logParser.addAbi(this.address, abi);
    }

    getContract(): Contract {
        return this.con;
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
