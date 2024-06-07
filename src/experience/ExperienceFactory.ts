import { Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/experience/ExperienceFactory.sol/ExperienceFactory.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";


export interface IExperienceFactoryOpts {
    address: string;
    admin: Provider | Signer;
}

export class ExperienceFactory {
    private con: Contract;
    private address: string;
    private admin: Provider | Signer;

    constructor(opts: IExperienceFactoryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.con = new Contract(this.address, abi, this.admin);
    }

    async setImplementation(impl: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setImplementation(impl));
    }

    async createExperience(owner: string, vectorAddress: VectorAddress, initData: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.createExperience(owner, vectorAddress, initData));
    }

    async isExperienceClone(query: string): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isExperienceClone(query));
    }
}