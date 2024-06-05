import { Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/avatar/AvatarRegistry.sol/AvatarRegistry.json";
import { RPCRetryHandler } from "../RPCRetryHandler";

export interface IAvatarRegistryOpts {
    address: string;
    admin: Provider | Signer;
}

export interface IAvatarRegistrationRequest {
    sendTokensToAvatarOwner: boolean;
    avatarOwner: string;
    defaultExperience: string;
    username: string;
    initData: string;
}

export class AvatarRegistry {
    private con: Contract;
    private address: string;
    private admin: Provider | Signer;

    constructor(opts: IAvatarRegistryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.con = new Contract(this.address, abi, this.admin);
    }

    async isAvatar(avatar: string): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isAvatar(avatar));
    }

    async findByUsername(username: string): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.findByUsername(username));
    }

    async nameAvailable(name: string): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.nameAvailable(name));
    }

    async registerAvatar(req: IAvatarRegistrationRequest): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.registerAvatar(req));
    }
}