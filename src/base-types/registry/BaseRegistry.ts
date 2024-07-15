import { AddressLike, TransactionResponse } from "ethers";
import { IWrapperOpts } from "../../interfaces/IWrapperOpts";
import { BaseAccess } from "../BaseAccess";
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { Version } from "../../Version";


export abstract class BaseRegistry extends BaseAccess {
    
    constructor(opts: IWrapperOpts) {
        super(opts);
    }

    async setEntityImplementation(entityImplementation: AddressLike): Promise<TransactionResponse> {
        const t = await  await RPCRetryHandler.withRetry(() => this.getContract().setEntityImplementation(entityImplementation));
        const r = await t.wait();
        const logs = this.logParser.parseLogs(r);
        const set = logs.get("RegistryEntityImplementationSet");
        if(!set || set.length == 0) {
            throw new Error("Entity implementation not set");
        }
        return t;
    }

    /**
     *  Get the entity implementation contract for the registry.
     */
    async getEntityImplementation(): Promise<AddressLike> {
        return RPCRetryHandler.withRetry(() => this.getContract().getEntityImplementation());
    }

    /**
     * Set the proxy implementation contract for the registry. All registries clone their entity
     * proxies. This is the base contract that is cloned.
     */
    async setProxyImplementation( proxyImplementation: AddressLike): Promise<TransactionResponse> {
        return RPCRetryHandler.withRetry(() => this.getContract().setProxyImplementation(proxyImplementation));
    }

    /**
     * Get the proxy implementation contract for the registry.
     */
    async getProxyImplementation(): Promise<AddressLike> {
        return RPCRetryHandler.withRetry(() => this.getContract().getProxyImplementation());
    }

    /**
     * Get the version for the entity logic contract. This can be used to detect if an 
     * upgrade is available.
     */
    async getEntityVersion(): Promise<Version>{
        const r = await RPCRetryHandler.withRetry(() => this.getContract().getEntityVersion());
        return {
            major: r[0],
            minor: r[1],
        } as Version;
    }


    /**
     * @dev Check if an entity is registered in this registry.
     */
    async isRegistered(addr: AddressLike): Promise<boolean> {
        return RPCRetryHandler.withRetry(() => this.getContract().isRegistered(addr));
    }

    /**
     * Get an entity by name.
     */
    async getEntityByName(name: string): Promise<AddressLike> {
        return RPCRetryHandler.withRetry(() => this.getContract().getEntityByName(name));
    }
}