import { AddressLike, Provider, Signer, TransactionReceipt, TransactionResponse, ethers } from "ethers";
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { VectorAddress, argsToVectorAddress } from "../../VectorAddress";
import { LogNames } from "../../LogNames";
import { AllLogParser } from "../../AllLogParser";
import { Version } from "../../Version";
import { IUpgradeResult } from "../../interfaces/IUpgradeable";
import {abi as WorldABI} from '../../../artifacts/contracts/world/instance/IWorld.sol/IWorld.json';
import { RegistrationTerms } from "../../RegistrationTerms";

/**
 * Typescript proxy for World instance
 */
export interface IWorldOpts {
    address: string;
    admin: Signer | Provider;
    logParser: AllLogParser;
}

export interface ICompanyRegistrationRequest {
    sendTokensToCompanyOwner: boolean;
    owner: AddressLike;
    name: string;
    terms: RegistrationTerms;
    ownerTermsSignature: string;
    expiration: bigint;
}

export interface ICompanyRegistrationResult {
    companyAddress: AddressLike;
    vectorAddress: VectorAddress;
    receipt: TransactionReceipt;
}

export interface IWorldAvatarRegistrationRequest {
    //whether to send tokens to the avatar owner account or contract address
    sendTokensToOwner: boolean;

    //the addres sof the avatar owner
    avatarOwner: AddressLike;

    //the address of the default experience contract where the new avatar will start
    defaultExperience: AddressLike;

    //the username of the new avatar, must be globally unique, case-insensitive
    username: string;

    //initialization data to pass to the avatar contract
    canReceiveTokensOutsideOfExperience: boolean;
    appearanceDetails: string;
}

export interface IAvatarRegistrationResult {
    avatarAddress: AddressLike;
    receipt: TransactionReceipt;
}

export class World {

    static get abi() {
        return  WorldABI
    }
    
    readonly address: string;
    readonly admin: Provider | Signer;
    private world: ethers.Contract;
    readonly logParser: AllLogParser;

    constructor(opts: IWorldOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        const abi = World.abi;
        if(!abi || abi.length === 0) {
            throw new Error("Invalid ABI");
        }
        this.world = new ethers.Contract(this.address, abi, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, abi);
    }

    async owner(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.world.owner());
    }

    async addSigners(signers: string[]): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.world.addSigners(signers));
    }

    async removeSigners(signers: string[]): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.world.removeSigners(signers));
    }

    async isSigner(address: string): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.world.isSigner(address));
    }

    async getVectorAddress(): Promise<VectorAddress> {
        return await RPCRetryHandler.withRetry(() => this.world.getBaseVector());
    }

    async getName(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.world.name());
    }

    async withdraw(amount: bigint): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.world.withdraw(amount));
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
        const r = await RPCRetryHandler.withRetry(() => this.world.version());
        return {
            major: r[0],
            minor: r[1],
        } as Version;
    }

    
    async registerCompany(request: ICompanyRegistrationRequest, tokens?: bigint): Promise<ICompanyRegistrationResult> {
        
        const t = await RPCRetryHandler.withRetry(() => this.world.registerCompany({
            owner: request.owner,
            sendTokensToOwner: request.sendTokensToCompanyOwner,
            name: request.name,
            terms: request.terms,
            ownerTermsSignature: request.ownerTermsSignature,
            initData: "0x",
            expiration: request.expiration
        }, {
            value: tokens
        }));
        const receipt = await t.wait();
        if(!receipt.status) {
            throw new Error(`Transaction failed: ${receipt.transactionHash}`);
        }
        const logs = this.logParser.parseLogs(receipt);
        const regs = logs.get(LogNames.WorldAddedCompany);
        if (!regs || regs.length === 0) {
            throw new Error("CompanyRegistered event not found in logs");
        }
        const reg = regs[0];
        const vector = argsToVectorAddress(reg.args[2]);
        return {
            companyAddress: reg.args[0],
            vectorAddress: vector,
            receipt
        };
    }

    /*
    async setHook(hook: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.world.setHook(hook));
    }

    async removeHook(): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.world.removeHook());
    }

    async getHook(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.world.hook());
    }
        */

    async deactivateCompany(address: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.world.deactivateCompany(address));
    }

    async reactivateCompany(address: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.world.reactivateCompany(address));
    }

    async removeCompany(address: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.world.removeCompany(address));
    }
    
}