import { Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../../artifacts/contracts/avatar/registry/IAvatarRegistry.sol/IAvatarRegistry.json";
import {abi as proxyABI} from '../../../artifacts/contracts/base-types/BaseProxy.sol/BaseProxy.json';
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { AllLogParser } from "../../AllLogParser";
import { BaseRegistry } from "../../base-types/registry/BaseRegistry";
import { IWrapperOpts } from "../../interfaces/IWrapperOpts";


export class AvatarRegistry extends BaseRegistry {
    static get abi() {
        return [
            ...abi,
            ...proxyABI
        ]
    }
    
    private con: Contract;

    constructor(opts: IWrapperOpts) {
        super(opts);
        const abi = AvatarRegistry.abi;
        if(!abi || abi.length === 0) {
            throw new Error("Invalid ABI");
        }
        this.con = new Contract(this.address, abi, this.admin);
        this.logParser.addAbi(this.address, abi);
    }

    getContract(): Contract {
        return this.con;
    }

    async isRegisteredAvatar(avatar: string): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isRegistered(avatar));
    }

}