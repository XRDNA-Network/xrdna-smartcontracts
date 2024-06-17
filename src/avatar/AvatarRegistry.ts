import { Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/avatar/AvatarRegistry.sol/AvatarRegistry.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { AllLogParser } from "../AllLogParser";

export interface IAvatarRegistryOpts {
    address: string;
    admin: Provider | Signer;
    logParser: AllLogParser;
}

export interface IAvatarRegistrationRequest {
    sendTokensToAvatarOwner: boolean;
    avatarOwner: string;
    defaultExperience: string;
    username: string;
    initData: string;
}

export class AvatarRegistry {
    static get abi() {
        return abi;
    }
    
    private con: Contract;
    readonly address: string;
    private admin: Provider | Signer;
    readonly logParser: AllLogParser;

    constructor(opts: IAvatarRegistryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.con = new Contract(this.address, abi, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, abi);
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