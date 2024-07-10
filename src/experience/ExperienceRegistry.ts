import { AddressLike, Contract, ethers, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/experience/registry/IExperienceRegistry.sol/IExperienceRegistry.json";
import {abi as proxyABI} from '../../artifacts/contracts/base-types/BaseProxy.sol/BaseProxy.json';
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";
import { AllLogParser } from "../AllLogParser";

export interface IExperienceRegistryOpts {
    address: string;
    admin: Provider | Signer;
    logParser: AllLogParser;
}

export interface IExperienceInfo {
    company: string;
    world: string;
    experience: string;
    portalId: bigint;
}

export class ExperienceRegistry {
    static get abi() {
        return [
            ...abi,
            ...proxyABI
        ];
    }
    
    private con: Contract;
    readonly address: string;
    readonly logParser: AllLogParser;
    private admin: Provider | Signer;

    constructor(opts: IExperienceRegistryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.con = new Contract(this.address, abi, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, abi);
    }

    async isExperience(exp: AddressLike): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isRegistered(exp));
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

    async getExperienceByName(name: string): Promise<IExperienceInfo> {
        const addr = await RPCRetryHandler.withRetry(() => this.con.getEntityByName(name));
        if(addr === ethers.ZeroAddress) {
            throw new Error("No experience found");
        }
        const r = await RPCRetryHandler.withRetry(() => this.con.getExperienceInfo(addr));
        return {
            company: r[0],
            world: r[1],
            experience: addr,
            portalId: r[2]
        } as IExperienceInfo;
    }

    async getExperienceByVector(vector: VectorAddress): Promise<IExperienceInfo> {
        const addr = await RPCRetryHandler.withRetry(() => this.con.getEntityByVector(vector));
        if(addr === ethers.ZeroAddress) {
            throw new Error("No experience found");
        }
        const r = await RPCRetryHandler.withRetry(() => this.con.getExperienceInfo(addr));
        return {
            company: r[0],
            world: r[1],
            experience: addr,
            portalId: r[3]
        } as IExperienceInfo;
    }
}