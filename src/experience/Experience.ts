import { AddressLike, Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/experience/Experience.sol/Experience.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";


export interface IExperienceOpts {
    address: string;
    admin: Provider | Signer;
}

export interface IJumpEntryRequest {
    sourceWorld: AddressLike;
    sourceCompany: AddressLike;
    avatar: AddressLike;
}


export class Experience {
    private con: Contract;
    readonly address: string;
    private admin: Provider | Signer;

    constructor(opts: IExperienceOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.con = new Contract(this.address, abi, this.admin);

    }

    async addHook(hook: AddressLike): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.addHook(hook));
    }

    async removeHook(hook: AddressLike): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeHook(hook));
    }


    async company(): Promise<AddressLike> {
        return await RPCRetryHandler.withRetry(() => this.con.company());
    }

    async vectorAddress(): Promise<VectorAddress> {
        return await RPCRetryHandler.withRetry(() => this.con.vectorAddress());
    }

}