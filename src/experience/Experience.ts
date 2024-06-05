import { Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/experience/Experience.sol/Experience.json";
import { RPCRetryHandler } from "../RPCRetryHandler";


export interface IExperienceOpts {
    address: string;
    admin: Provider | Signer;
}


export class Experience {
    private con: Contract;
    private address: string;
    private admin: Provider | Signer;

    constructor(opts: IExperienceOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.con = new Contract(this.address, abi, this.admin);
    }

    async addHook(hook: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.addHook(hook));
    }

    async removeHook(hook: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeHook(hook));
    }
    async company(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.company());
    }

    async vectorAddress(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.vectorAddress());
    }

    async entering(request: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.entering(request));
    }

}