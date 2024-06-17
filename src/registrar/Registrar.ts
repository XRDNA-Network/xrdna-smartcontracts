import { Provider, Signer, TransactionResponse, ethers } from "ethers";
import {abi as RegistryABI} from "../../artifacts/contracts/RegistrarRegistry.sol/RegistrarRegistry.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { AllLogParser } from "../AllLogParser";

/**
 * Typescript wrapper around regstirar functionality
 */
export interface IRegistrarOpts {
    registrarRegistryAddress: string;
    admin: Provider | Signer;
    registrarId: bigint;
    logParser: AllLogParser;
}

export class Registrar {
    private address: string;
    private admin: Provider | Signer;
    readonly registrarId: bigint;
    private registry: ethers.Contract;
    readonly logParser: AllLogParser;

    constructor(opts: IRegistrarOpts) {
        this.address = opts.registrarRegistryAddress;
        this.admin = opts.admin;
        this.registrarId = opts.registrarId;
        this.registry = new ethers.Contract(this.address, RegistryABI, this.admin);
        this.logParser = opts.logParser;
    }

    async addSigners(signers: string[]): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(()=>this.registry.addSigners(this.registrarId, signers));
    }

    async removeSigners(signers: string[]): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(()=>this.registry.removeSigners(this.registrarId, signers));
    }

}

    