import { VectorAddress } from "../VectorAddress";

export interface ISupportsVector {

    /**
     * Gets the vector address for the contract.
     * @returns The base vector for the contract.
     */
    getVectorAddress(): Promise<VectorAddress>;
}