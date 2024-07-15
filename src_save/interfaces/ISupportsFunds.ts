import { TransactionResponse } from "ethers";

export interface ISupportsFunds {

    /**
     * Gets the balance of the contract.
     * @returns The balance of the contract.
     */
    getBalance(): Promise<bigint>;

    /**
     * Adds funds to the contract.
     * @param amount The amount to add.
     */
    addFunds(amount: bigint): Promise<TransactionResponse>;

    /**
     * Removes funds from the contract.
     * @param amount The amount to remove.
     */
    withdraw(amount: bigint): Promise<TransactionResponse>;
}