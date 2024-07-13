import { AddressLike, TransactionResponse } from "ethers";
import { IWrapperOpts } from "../../interfaces/IWrapperOpts";
import { BaseRegistry } from "./BaseRegistry"
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { RegistrationTerms } from "../../RegistrationTerms";
import { Bytes } from "../../types";



export abstract class BaseRemovableRegistry extends BaseRegistry {

    constructor(opts: IWrapperOpts) {
        super(opts);
    }

    /**
     * Returns the terms for the given entity address
     */
    async getEntityTerms(addr: AddressLike): Promise<RegistrationTerms> {
        const r = await RPCRetryHandler.withRetry(() => this.getContract().getEntityTerms(addr));
        return {
            coveragePeriodDays: r[0],
            gracePeriodDays: r[1],
            fee: r[2]
        } as RegistrationTerms;
    }

    /**
     * Returns whether an entity can be deactivated. Entities can only be deactivated
     * if they are either expired or within the grace period
     */
    async canBeDeactivated(addr: AddressLike): Promise<boolean> {
        return RPCRetryHandler.withRetry(() => this.getContract().canBeDeactivated(addr));
    }

    /**
     * Returns whether an entity can be removed. Entities can only be removed if they are
     * outside the grace period
     */
    async canBeRemoved(addr: AddressLike): Promise<boolean> {
        return RPCRetryHandler.withRetry(() => this.getContract().canBeRemoved(addr));
    }

    /**
     * Enforces deactivation of an entity. Can be called by anyone but will only
     * succeed if the entity is inside the grace period
     */
    async enforceDeactivation(addr: AddressLike): Promise<TransactionResponse> {
        return RPCRetryHandler.withRetry(() => this.getContract().enforceDeactivation(addr));
    }

    /**
     * Enforces removal of an entity. Can be called by anyone but will only
     * succeed if it is outside the grace period
     */
    async enforceRemoval(e: AddressLike): Promise<TransactionResponse> {
        return RPCRetryHandler.withRetry(() => this.getContract().enforceRemoval(e));
    }

    /**
     * Returns the last renewal timestamp in seconds for the given address.
     */
    async getLastRenewal(addr: AddressLike): Promise<bigint> {
        return RPCRetryHandler.withRetry(() => this.getContract().getLastRenewal(addr));
    }

    /**
     * Returns the expiration timestamp in seconds for the given address.
     */
    async getExpiration(addr: AddressLike): Promise<bigint> {
        return RPCRetryHandler.withRetry(() => this.getContract().getExpiration(addr));
    }

    /**
     * Check whether an address is expired.
     */
    async isExpired(addr: AddressLike): Promise<boolean> {
        return RPCRetryHandler.withRetry(() => this.getContract().isExpired(addr));
    }

    /**
     * Check whether an address is in the grace period.
     */
    async isInGracePeriod(addr: AddressLike): Promise<boolean> {
        return RPCRetryHandler.withRetry(() => this.getContract().isInGracePeriod(addr));
    }

    /**
     * Renew an entity by paying the renewal fee.
     */
    async renewEntity(addr: AddressLike, tokens: bigint): Promise<TransactionResponse> {
        return RPCRetryHandler.withRetry(() => this.getContract().renewEntity(addr, {
            value: tokens
        }));
    }

   
}