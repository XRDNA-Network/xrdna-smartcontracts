import { AddressLike, Provider, Signer, TransactionResponse, ethers } from "ethers";
import { RPCRetryHandler } from "../RPCRetryHandler";
import {abi} from "../../artifacts/contracts/asset/IMultiAssetRegistry.sol/IMultiAssetRegistry.json";
import { AllLogParser } from "../AllLogParser";

export interface IMultiAssetRegistryOpts {
    address: string;
    admin: Provider | Signer;
    logParser: AllLogParser;
}

export class MultiAssetRegistry {
    static get abi() {
        return abi;
    }
    
    private admin: Provider | Signer;
    readonly address: string;
    readonly logParser: AllLogParser;
    private con: ethers.Contract;
    constructor(opts: IMultiAssetRegistryOpts) {
        this.admin = opts.admin;
        this.address = opts.address;
        this.con = new ethers.Contract(this.address, abi, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, abi);
    }

    async isRegisteredAsset(assetAddress: AddressLike): Promise<boolean> {
        return await  RPCRetryHandler.withRetry(()=>this.con.isRegistered(assetAddress));
    }

    async addRegistry(registry: AddressLike): Promise<TransactionResponse> {
        return await  RPCRetryHandler.withRetry(()=>this.con.registerRegistry(registry));
    }
}