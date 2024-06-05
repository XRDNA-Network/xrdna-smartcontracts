import { Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/experience/ExperienceRegistry.sol/ExperienceRegistry.json";
import { RPCRetryHandler } from "../RPCRetryHandler";

export interface IExperienceRegistryOpts {
    address: string;
    admin: Provider | Signer;
}

export class ExperienceRegistry {
    private con: Contract;
    private address: string;
    private admin: Provider | Signer;

    constructor(opts: IExperienceRegistryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.con = new Contract(this.address, abi, this.admin);
    }

    async setCompanyRegistry(registry: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setCompanyRegistry(registry));
    }

    async setPortalRegistry(registry: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setPortalRegistry(registry));
    }

    async isExperience(exp: string): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isExperience(exp));
    }

    async getExperienceByVector(vector: string): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.getExperienceByVector(vector));
    }

    async registerExperience(bytes: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.registerExperience(bytes));
    }
}