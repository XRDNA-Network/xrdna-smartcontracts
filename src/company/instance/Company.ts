import { Provider, Signer, TransactionResponse, ethers } from "ethers";
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { VectorAddress } from "../../VectorAddress";
import { AllLogParser } from "../../AllLogParser";
import { Version } from "../../Version";
import {abi as cABI} from '../../../artifacts/contracts/company/instance/ICompany.sol/ICompany.json';
import { RegistrationTerms } from "../../RegistrationTerms";

/**
 * Typescript proxy for World instance
 */
export interface ICompanyOpts {
    address: string;
    admin: Signer | Provider;
    logParser: AllLogParser;
}

export class Company {

    static get abi() {
        return  cABI
    }
    
    readonly address: string;
    readonly admin: Provider | Signer;
    private company: ethers.Contract;
    readonly logParser: AllLogParser;

    constructor(opts: ICompanyOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        const abi = Company.abi;
        if(!abi || abi.length === 0) {
            throw new Error("Invalid ABI");
        }
        this.company = new ethers.Contract(this.address, abi, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, abi);
    }

    async owner(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.company.owner());
    }

    async addSigners(signers: string[]): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.company.addSigners(signers));
    }

    async removeSigners(signers: string[]): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.company.removeSigners(signers));
    }

    async isSigner(address: string): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.company.isSigner(address));
    }

    async getVectorAddress(): Promise<VectorAddress> {
        return await RPCRetryHandler.withRetry(() => this.company.getBaseVector());
    }

    async getName(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.company.name());
    }

    async withdraw(amount: bigint): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.company.withdraw(amount));
    }

    async addFunds(amount: bigint): Promise<TransactionResponse> {
        if(!this.admin || !this.admin.sendTransaction) {
            throw new Error("Cannot add funds without an admin signer");
        }
        return await RPCRetryHandler.withRetry(() => this.admin.sendTransaction!({
            to: this.address,
            value: amount
        }));
    }

    async getBalance(): Promise<bigint> {
        const p: Provider = this.admin.provider || this.admin as Provider;
        if(!p) {
            throw new Error("Cannot get balance without a provider");
        }
        return await RPCRetryHandler.withRetry(() => p.getBalance(this.address));
    }

    async version(): Promise<Version> {
        const r = await RPCRetryHandler.withRetry(() => this.company.version());
        return {
            major: r[0],
            minor: r[1],
        } as Version;
    }
}