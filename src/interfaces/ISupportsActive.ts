
export interface ISupportsActive {

    /**
     * Checks if the contract is active.
     */
    isActive(): Promise<boolean>;
}