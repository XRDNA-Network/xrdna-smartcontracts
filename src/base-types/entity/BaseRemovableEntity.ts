import { AddressLike } from "ethers";
import { BaseEntity } from "./BaseEntity";
import { RPCRetryHandler } from "../../RPCRetryHandler";


export abstract class BaseRemovableEntity extends BaseEntity {


    /**
     * Get the authority that sets the registration terms for an entity
     */
    async termsOwner(): Promise<AddressLike> {
        return RPCRetryHandler.withRetry(() => this.getContract().termsOwner());
    }

    /**
     * Check whether the entity is active
     
     */
    async isEntityActive(): Promise<boolean> {
        return RPCRetryHandler.withRetry(() => this.getContract().isEntityActive());
    }

    /**
     * Check whether the entity is removed
     */
    async isRemoved(): Promise<boolean> {
        return RPCRetryHandler.withRetry(() => this.getContract().isRemoved());
    }
}