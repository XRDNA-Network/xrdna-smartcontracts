import { AddressLike, Contract, Provider, ethers } from "ethers";
import {abi} from "../../artifacts/contracts/experience/Experience.sol/Experience.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";
import { AllLogParser } from "../AllLogParser";


export interface IExperienceOpts {
    address: string;
    portalId: bigint;
    provider: Provider;
    logParser: AllLogParser;
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


export class Experience {
    static get abi() {
        return abi;
    }
    
    private con: Contract;
    readonly address: string;
    readonly portalId: bigint;
    readonly logParser: AllLogParser;
    private provider: Provider;

    constructor(opts: IExperienceOpts) {
        this.address = opts.address;
        this.provider = opts.provider;
        this.portalId = opts.portalId;
        this.con = new Contract(this.address, abi, this.provider);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, abi);

    }

    static encodeInitData(data: IExperienceInitData): string {
        const ifc = new ethers.Interface(abi);
        return `0x${ifc.encodeFunctionData("encodeInitData", [data]).substring(10)}`;
    }


    async company(): Promise<AddressLike> {
        return await RPCRetryHandler.withRetry(() => this.con.company());
    }

    async vectorAddress(): Promise<VectorAddress> {
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
        return await RPCRetryHandler.withRetry(() => this.con.isActive());
    }

}