import { Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/avatar/AvatarFactory.sol/AvatarFactory.json";
import { RPCRetryHandler } from "../RPCRetryHandler";

export interface IAvatarFactoryOpts {
    address: string;
    admin: Provider | Signer;
}

export class AvatarFactory {
    private con: Contract;
    private address: string;
    private admin: Provider | Signer;

    constructor(opts: IAvatarFactoryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.con = new Contract(this.address, abi, this.admin);
    }

    async setAvatarRegistry(registry: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setAvatarRegistry(registry));
    }

    async setAvatarImplementation(impl: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setAvatarImplementation(impl));
    }

    async createAvatar(owner: string, defaultExperience: string, initData: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.createAvatar(owner, defaultExperience, initData));
    }

    async isAvatarClone(query: string): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isAvatarClone(query));
    }

}