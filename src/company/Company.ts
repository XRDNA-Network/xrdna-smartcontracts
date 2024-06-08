import { AddressLike, Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/company/Company.sol/Company.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";

export interface ICompanyOpts {
    address: string;
    admin: Provider | Signer;
}

export interface IAddExperienceArgs {
    name: string,
    initData: string,
}

export class Company {
    private con: Contract;
    readonly address: string;
    private admin: Provider | Signer;

    constructor(opts: ICompanyOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.con = new Contract(this.address, abi, this.admin);
    }
    
    async owner(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.owner());
    }

    async name(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.name());
    }

    async world(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.world());
    }

    async vectorAddress(): Promise<VectorAddress> {
        return await RPCRetryHandler.withRetry(() => this.con.vectorAddress());
    }

    async isSigner(address: string): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isSigner(address));
    }

    async canMint(asset: string, to: string, amount: string): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.canMint(asset, to, amount));
    }

    async upgraded(): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.upgraded());
    }

    async addSigner(signer: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.addSigner(signer));
    }

    async removeSigner(signer: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeSigner(signer));
    }

    async addExperience(exp: IAddExperienceArgs): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.addExperience(exp));
    }

    async mint(asset: string, to: string, amount: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.mint(asset, to, amount));
    }

    async revoke(asset: string, holder: string, amountOrTokenId: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.revoke(asset, holder, amountOrTokenId));
    }

    async upgrade(initData: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.upgrade(initData));
    }

    async upgradeComplete(nextVersion: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.upgradeComplete(nextVersion));
    }   

    async withdraw(amount: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.withdraw(amount));
    }

    async setHook(hook: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setHook(hook));
    }

    async removeHook() {
        return await RPCRetryHandler.withRetry(() => this.con.removeHook());
    }
    
    async addExperienceCondition(exp: string, condition: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.addExperienceCondition(exp, condition));
    }

    async removeExperienceCondition(exp: string, condition: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeExperienceCondition(exp, condition));
    }

    async addAssetHook(asset: AddressLike, hook: AddressLike): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.addAssetHook(asset, hook));
    }
    async removeAssetHook(asset: AddressLike ): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeAssetHook(asset));
    }
}