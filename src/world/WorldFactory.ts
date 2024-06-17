import { Signer, TransactionResponse, ethers } from "ethers";
import {abi as WorldFactoryABI} from "../../artifacts/contracts/world/v0.2/WorldFactoryV2.sol/WorldFactoryV2.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { AllLogParser } from "../AllLogParser";

/**
 * Typescript proxy for WorldFactory deployed contract
 */
export interface IWorldFactoryOpts {
    address: string;
    admin: Signer;
    logParser: AllLogParser;
}

export class WorldFactory {
    static get abi() {
        return WorldFactoryABI;
    }
    
    readonly address: string;
    readonly logParser: AllLogParser;
    private admin: Signer;
    private factory: ethers.Contract;

    constructor(opts: IWorldFactoryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.factory = new ethers.Contract(this.address, WorldFactoryABI, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, WorldFactoryABI);
    }

    /**
     * Set the World master implementation address to use when creating new World 
     * instances. This can only be called by the factory admin and is used to 
     * change the implementation of all new World creations. Existing worlds 
     * will need to go through their Registrar to upgrade to the new implementation.
     * 
     * @param implAddress 
     */
    async setImplementation(implAddress: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() =>  this.factory.setImplementation(implAddress));
    }
}