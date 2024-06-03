import { Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/asset/AssetFactory.sol/AssetFactory.json";
import { RPCRetryHandler } from "../RPCRetryHandler";

export interface IAssetFactoryOpts {
    admin: Provider | Signer;
    address: string;
}

export const AssetType = {
    ERC20: 1n,
    ERC721: 2n
}

export class AssetFactory {
    private admin: Provider | Signer;
    private address: string;
    private con: Contract;
    constructor(opts: IAssetFactoryOpts) {
        this.admin = opts.admin;
        this.address = opts.address;
        this.con = new Contract(this.address, abi, this.admin);
    }

    async setERC20Implementation(impl: string): Promise<TransactionResponse> {
       return await RPCRetryHandler.withRetry(()=>this.con.setERC20Implementation(impl));
    }

    async setERC721Implementation(impl: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(()=>this.con.setERC721Implementation(impl));
    }

    async setAssetRegistry(registry: string): Promise<TransactionResponse> {
        return await  RPCRetryHandler.withRetry(()=>this.con.setAssetRegistry(registry));
    }
}