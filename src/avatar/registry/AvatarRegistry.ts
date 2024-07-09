import { Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../../artifacts/contracts/avatar/registry/IAvatarRegistry.sol/IAvatarRegistry.json";
import {abi as proxyABI} from '../../../artifacts/contracts/base-types/BaseProxy.sol/BaseProxy.json';
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { AllLogParser } from "../../AllLogParser";

export interface IAvatarRegistryOpts {
    address: string;
    admin: Provider | Signer;
    logParser: AllLogParser;
}

export class AvatarRegistry {
    static get abi() {
        return [
            ...abi,
            ...proxyABI
        ]
    }
    
    private con: Contract;
    private address: string;
    private admin: Provider | Signer;
    readonly logParser: AllLogParser;

    constructor(opts: IAvatarRegistryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        const abi = AvatarRegistry.abi;
        if(!abi || abi.length === 0) {
            throw new Error("Invalid ABI");
        }
        this.con = new Contract(this.address, abi, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, abi);
    }

    async isRegisteredAvatar(avatar: string): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isRegistered(avatar));
    }

}