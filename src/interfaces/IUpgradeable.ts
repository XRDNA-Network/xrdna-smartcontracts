import { TransactionReceipt } from "ethers";

export interface IUpgradeResult {
    receipt: TransactionReceipt;
    newWorldAddress: string;
}

export interface IUpgradeable {

    /**
     * Upgrades the contract to a new implementation.
     * @param initData The encoded initialization data to initialize the new instance.
     */
    upgrade(initData: string): Promise<IUpgradeResult>;

    /** 
     * Gets the current version of the upgradeable contract.
    */
    version(): Promise<bigint>;

    /**
     * Gets the address of the current implementation.
     * @returns The address of the current implementation.
     */
    getImplementation(): Promise<string>;
}