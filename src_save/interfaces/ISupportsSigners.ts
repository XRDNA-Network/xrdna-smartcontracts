import { TransactionResponse } from "ethers";

/**
 * Interface for classes that support adding, removing, and verifying signers on-chain.
 */
export interface ISupportsSigners {

    /**
     * Adds a signer to the contract.
     * @param signer The address of the signer to add.
     */
    addSigners(signers: string[]): Promise<TransactionResponse>;

    /**
     * Removes a signer from the contract.
     * @param signer The address of the signer to remove.
     */
    removeSigners(signer: string[]): Promise<TransactionResponse>;

    /**
     * Verifies that a signer is valid.
     * @param signer The address of the signer to verify.
     * @returns True if the signer is valid, false otherwise.
     */
    isSigner(signer: string): Promise<boolean>;
}