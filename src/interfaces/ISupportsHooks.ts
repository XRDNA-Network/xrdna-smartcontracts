import { TransactionResponse } from "ethers";

export interface ISupportsHooks {
    /**
     * Gets the hook for the contract.
     * @returns The hook for the contract.
     */
    getHook(): Promise<string>;

    /**
     * Sets the hook for the contract.
     * @param hook The hook to set.
     */
    setHook(hook: string): Promise<TransactionResponse>;

    /**
     * Removes the hook for the contract.
     */
    removeHook(): Promise<TransactionResponse>;
}