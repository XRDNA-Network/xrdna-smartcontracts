import { AddressLike, TransactionResponse } from "ethers";
import { BaseRemovableRegistry } from "../base-types/registry/BaseRemovableRegistry";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { Bytes } from "../types";
import { LogNames } from "../LogNames";

export interface CreateAssetArgs {
    //the address allowed to mint/burn the asset
    issuer: AddressLike;

    //the address of the asset on the origin chain
    originAddress: AddressLike;

    //the chain id of the origin chain
    originChainId: bigint;

    //name of the asset
    name: string;

    //its symbol
    symbol: string;

    //extra init data interpreted by the concrete asset implementation
    initData: Bytes;
}



export abstract class BaseAssetRegistry extends BaseRemovableRegistry {

    async assetExists(originAddress: AddressLike, chainId: bigint): Promise<boolean> {
        return RPCRetryHandler.withRetry(() => this.getContract().assetExists(originAddress, chainId));
    }

    async deactivateAsset(asset: AddressLike, reason: string): Promise<TransactionResponse>{
        return RPCRetryHandler.withRetry(() => this.getContract().deactivateAsset(asset, reason));
    }

    /**
     * Reactivates an asset in the registry. Only callable by the registry admin
     */
    async reactivateAsset(asset: AddressLike): Promise<TransactionResponse>  {
        return RPCRetryHandler.withRetry(() => this.getContract().reactivateAsset(asset));
    }

    /**
     * Removes an asset from the registry. Only callable by the registry admin AFTER
        * the grace period has expired.
     */
    async removeAsset(asset: AddressLike, reason: string): Promise<TransactionResponse> {
        return RPCRetryHandler.withRetry(() => this.getContract().removeAsset(asset, reason));
    }
}