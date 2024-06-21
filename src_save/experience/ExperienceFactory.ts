import { AddressLike, Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/experience/ExperienceFactory.sol/ExperienceFactory.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";
import { AllLogParser } from "../AllLogParser";


export interface IExperienceFactoryOpts {
    address: string;
    admin: Provider | Signer;
    logParser: AllLogParser;
}

export class ExperienceFactory {
    static get abi() {
        return abi;
    }
    
    private con: Contract;
    readonly address: string;
    readonly logParser: AllLogParser;
    private admin: Provider | Signer;

    constructor(opts: IExperienceFactoryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.con = new Contract(this.address, abi, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, abi);
    }

    async setImplementation(impl: AddressLike): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setImplementation(impl));
    }

    async createExperience(owner: AddressLike, vectorAddress: VectorAddress, initData: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.createExperience(owner, vectorAddress, initData));
    }

}