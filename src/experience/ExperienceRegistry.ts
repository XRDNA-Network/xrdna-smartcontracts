import { AddressLike, Contract, ethers, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/experience/registry/IExperienceRegistry.sol/IExperienceRegistry.json";
import {abi as proxyABI} from '../../artifacts/contracts/base-types/BaseProxy.sol/BaseProxy.json';
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";
import { AllLogParser } from "../AllLogParser";
import { IExperienceInfo } from "./IExperienceInfo";
import { BaseVectoredRegistry } from "../base-types/registry/BaseVectoredRegistry";
import { IWrapperOpts } from "../interfaces/IWrapperOpts";


export class ExperienceRegistry extends BaseVectoredRegistry {
    static get abi() {
        return [
            ...abi,
            ...proxyABI
        ];
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

    async isExperience(exp: AddressLike): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isRegistered(exp));
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