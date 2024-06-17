import { Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/avatar/AvatarFactory.sol/AvatarFactory.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { AllLogParser } from "../AllLogParser";

export interface IAvatarFactoryOpts {
    address: string;
    admin: Provider | Signer;
    logParser: AllLogParser;
}

export class AvatarFactory {
    static get abi() {
        return abi;
    }
    
    private con: Contract;
    readonly address: string;
    private admin: Provider | Signer;
    readonly logParser: AllLogParser;

    constructor(opts: IAvatarFactoryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.con = new Contract(this.address, abi, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, abi);
    }

    async setAvatarImplementation(impl: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setAvatarImplementation(impl));
    }

    async createAvatar(owner: string, defaultExperience: string, initData: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.createAvatar(owner, defaultExperience, initData));
    }

}