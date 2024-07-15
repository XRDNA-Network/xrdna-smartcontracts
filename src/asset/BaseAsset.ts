import { AddressLike, Provider, ethers } from "ethers";
import { AllLogParser } from "../AllLogParser";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { BaseRemovableEntity } from "../base-types/entity/BaseRemovableEntity";


export interface AssetCheckArgs {
    asset: AddressLike;
    world: AddressLike;
    company: AddressLike;
    experience: AddressLike;
    avatar: AddressLike;
}

export abstract class BaseAsset extends BaseRemovableEntity {

    /**
     * Get the company contract address that issues this asset
     * @returns the address of the Company contract allowed to mint the asset
     */
    async issuer(): Promise<string> {
        return await  RPCRetryHandler.withRetry(()=>this.getContract().issuer());
    }

    /**
     * Returns the address of the origin asset
     */
    async originAddress(): Promise<string> {
        return await  RPCRetryHandler.withRetry(()=>this.getContract().originAddress());
    }

    /**
     * Returns the chain id of the origin asset
     */
    async originChainId(): Promise<bigint> {
        return await  RPCRetryHandler.withRetry(()=>this.getContract().originAddress());
    }


    /**
     * Returns the name of the token.
     */
    async name(): Promise<string> {
        return RPCRetryHandler.withRetry(() => this.getContract().name());
    }

    /**
     * Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    async symbol(): Promise<string> {
        return RPCRetryHandler.withRetry(() => this.getContract().symbol());
    }

    /**
     * Checks if the asset can be viewed based on the world/company/experience/avatar
     */
    async canViewAsset(args: AssetCheckArgs): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.getContract().canViewAsset(args));
    }

    /**
     * Checks if the asset can be used based on the world/company/experience/avatar
     */
    async canUseAsset(args: AssetCheckArgs): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.getContract().canUseAsset(args));
    }

}
