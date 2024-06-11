import { AddressLike, Provider, Signer, TransactionResponse, ethers } from "ethers";
import { RPCRetryHandler } from "../RPCRetryHandler";
import {abi} from "../../artifacts/contracts/asset/MultiAssetRegistry.sol/MultiAssetRegistry.json";

export interface IMultiAssetRegistryOpts {
    address: string;
    admin: Provider | Signer;
}

export class MultiAssetRegistry {
    private admin: Provider | Signer;
    readonly address: string;
    private con: ethers.Contract;
    constructor(opts: IMultiAssetRegistryOpts) {
        this.admin = opts.admin;
        this.address = opts.address;
        this.con = new ethers.Contract(this.address, abi, this.admin);
    }

    async isRegisteredAsset(assetAddress: AddressLike): Promise<boolean> {
        return await  RPCRetryHandler.withRetry(()=>this.con.isRegisteredAsset(assetAddress));
    }

    async addRegistry(registry: AddressLike): Promise<TransactionResponse> {
        return await  RPCRetryHandler.withRetry(()=>this.con.registerRegistry(registry));
    }
}