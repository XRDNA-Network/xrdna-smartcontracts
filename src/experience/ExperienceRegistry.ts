import { AddressLike, Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/experience/ExperienceRegistry.sol/ExperienceRegistry.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";

export interface IExperienceRegistryOpts {
    address: string;
    admin: Provider | Signer;
}

export interface IExperienceInfo {
    company: string;
    world: string;
    experience: string;
    portalId: bigint;
}

export class ExperienceRegistry {
    private con: Contract;
    readonly address: string;
    private admin: Provider | Signer;

    constructor(opts: IExperienceRegistryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.con = new Contract(this.address, abi, this.admin);
    }

    async isExperience(exp: AddressLike): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isExperience(exp));
    }

    async getExperienceByVector(vector: VectorAddress): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.getExperienceByVector(vector));
    }

    async registerExperience(bytes: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.registerExperience(bytes));
    }

    async getExperienceInfo(address: string): Promise<IExperienceInfo> {
        const r = await RPCRetryHandler.withRetry(() => this.con.experiencesByAddress(address));
        return {
            company: r[0],
            world: r[1],
            experience: r[2],
            portalId: r[3]
        } as IExperienceInfo;
    }
}