import { AddressLike } from "ethers";
import { IWrapperOpts } from "../../interfaces/IWrapperOpts";
import { VectorAddress } from "../../VectorAddress";
import { BaseRemovableRegistry } from "./BaseRemovableRegistry";
import { RPCRetryHandler } from "../../RPCRetryHandler";

export abstract class BaseVectoredRegistry extends BaseRemovableRegistry {
        
    constructor(opts: IWrapperOpts) {
        super(opts);
    }

    /**
     * Get the entity address for the given vector.
     */
    async getEntityByVector(vector: VectorAddress): Promise<AddressLike>{
        return RPCRetryHandler.withRetry(() => this.getContract().getEntityByVector(vector));
    }
}