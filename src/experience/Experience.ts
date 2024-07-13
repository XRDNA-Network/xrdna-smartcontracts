import { AddressLike, Contract, Provider, ethers } from "ethers";
import {abi} from "../../artifacts/contracts/experience/instance/IExperience.sol/IExperience.json";
import {abi as proxyABI} from '../../artifacts/contracts/base-types/entity/IEntityProxy.sol/IEntityProxy.json';
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";
import { AllLogParser } from "../AllLogParser";
import { IExperienceInfo } from "./IExperienceInfo";
import { IWrapperOpts } from "../interfaces/IWrapperOpts";
import { BaseRemovableEntity } from "../base-types/entity/BaseRemovableEntity";


export interface IExperienceOpts extends IWrapperOpts {
    portalId: bigint;
}

export interface IExperienceInitData {
    entryFee: bigint;
    connectionDetails: string;
}

export interface IJumpEntryRequest {
    sourceWorld: AddressLike;
    sourceCompany: AddressLike;
    avatar: AddressLike;
}

export class Experience extends BaseRemovableEntity {
    static get abi() {
        return  [
            ...abi,
            ...proxyABI
        ]
    }
    
    private con: Contract;
    readonly portalId: bigint;

    constructor(opts: IExperienceOpts) {
        super(opts);
        this.portalId = opts.portalId;
        this.con = new Contract(this.address, abi, this.admin);
        this.logParser.addAbi(this.address, abi);
    }

    getContract(): Contract {
        return this.con;
    }

    static encodeInitData(data: IExperienceInitData): string {
        const ifc = new ethers.Interface(abi);
        return `0x${ifc.encodeFunctionData("encodeInitData", [data]).substring(10)}`;
    }

    async entryFee(): Promise<bigint> {
        return await RPCRetryHandler.withRetry(() => this.con.entryFee());
    }

    async connectionDetails(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.connectionDetails());
    }

    async company(): Promise<AddressLike> {
        return await RPCRetryHandler.withRetry(() => this.con.company());
    }

    async getVectorAddress(): Promise<VectorAddress> {
        const r = await RPCRetryHandler.withRetry(() => this.con.vectorAddress());
        return {
            x: r[0],
            y: r[1],
            z: r[2],
            t: r[3],
            p: r[4],
            p_sub: r[5]
        } as VectorAddress;
    }

    async isActive(): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isEntityActive());
    }

    async getExperienceInfo(address: string): Promise<IExperienceInfo> {
        const r = await RPCRetryHandler.withRetry(() => this.con.getExperienceInfo(address));
        return {
            company: r[0],
            world: r[1],
            experience: address,
            portalId: r[2]
        } as IExperienceInfo;
    }

}
