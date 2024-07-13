import { AddressLike, Contract, Provider, Signer, TransactionResponse } from "ethers";
import { AllLogParser } from "../AllLogParser";
import { IWrapperOpts } from "../interfaces/IWrapperOpts";
import { Bytes32 } from "../types";
import { RPCRetryHandler } from "../RPCRetryHandler";




export abstract class BaseAccess {
    readonly address: string;
    readonly admin: Provider | Signer;
    readonly logParser: AllLogParser;
    constructor(opts: IWrapperOpts) {
        this.address = opts.address;
        this.admin = opts.signerOrProvider;
        this.logParser = opts.logParser;
    }

    abstract getContract(): Contract;

    async hasRole(role: Bytes32, account: AddressLike): Promise<boolean> {
        return RPCRetryHandler.withRetry(() => this.getContract().hasRole(role, account));
    }

    async grantRole(role: Bytes32, account: AddressLike): Promise<TransactionResponse> {
        return RPCRetryHandler.withRetry(() => this.getContract().grantRole(role, account));
    }

    async revokeRole(role: Bytes32, account: AddressLike): Promise<TransactionResponse> {
        return RPCRetryHandler.withRetry(() => this.getContract().revokeRole(role, account));
    }

    async addSigners(signers: AddressLike[]): Promise<TransactionResponse> {
        return RPCRetryHandler.withRetry(() => this.getContract().addSigners(signers));
    }

    async removeSigners(signers: AddressLike[]): Promise<TransactionResponse> {
        return RPCRetryHandler.withRetry(() => this.getContract().removeSigners(signers));
    }

    async isSigner(account: AddressLike): Promise<boolean> {
        return RPCRetryHandler.withRetry(() => this.getContract().isSigner(account));
    }

    async isAdmin(account: AddressLike): Promise<boolean> {
        return RPCRetryHandler.withRetry(() => this.getContract().isAdmin(account));
    }

    async  owner(): Promise<AddressLike>{
        return RPCRetryHandler.withRetry(() => this.getContract().owner());
    }

    async changeOwner(newOwner: AddressLike): Promise<TransactionResponse> {
        return RPCRetryHandler.withRetry(() => this.getContract().changeOwner(newOwner));
    }
}