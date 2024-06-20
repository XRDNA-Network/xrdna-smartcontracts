import { AddressLike, Provider, Signer, TransactionReceipt, TransactionResponse, ethers } from "ethers";
import {abi as WorldABI} from "../../artifacts/contracts/world/World.sol/World.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";
import { LogNames } from "../LogNames";
import { Avatar } from "../avatar/Avatar";
import { ISupportsSigners } from "../interfaces/ISupportsSigners";
import { ISupportsVector } from "../interfaces";
import { IUpgradeResult, IUpgradeable } from "../interfaces/IUpgradeable";
import { ISupportsHooks } from "../interfaces/ISupportsHooks";
import { ISupportsFunds } from "../interfaces/ISupportsFunds";
import { AllLogParser } from "../AllLogParser";

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
}

export interface ICompanyRegistrationResult {
    companyAddress: AddressLike;
    vectorAddress: VectorAddress;
    receipt: TransactionReceipt;
}

export interface IWorldAvatarRegistrationRequest {
    //whether to send tokens to the avatar owner account or contract address
    sendTokensToAvatarOwner: boolean;

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



export class World implements ISupportsSigners, 
                              ISupportsVector, 
                              IUpgradeable,
                              ISupportsHooks,
                              ISupportsFunds {

    static get abi() {
        return WorldABI;
    }
    
    readonly address: string;
    readonly admin: Provider | Signer;
    private world: ethers.Contract;
    readonly logParser: AllLogParser;

    constructor(opts: IWorldOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.world = new ethers.Contract(this.address, WorldABI, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, WorldABI);
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
        return await RPCRetryHandler.withRetry(() => this.world.getName());
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

    async version(): Promise<bigint> {
        return await RPCRetryHandler.withRetry(() => this.world.version());
    }

    async registerCompany(request: ICompanyRegistrationRequest, tokens?: bigint): Promise<ICompanyRegistrationResult> {
        
        const t = await RPCRetryHandler.withRetry(() => this.world.registerCompany({
            owner: request.owner,
            sendTokensToCompanyOwner: request.sendTokensToCompanyOwner,
            name: request.name,
            initData: "0x"
        }, {
            value: tokens
        }));
        const receipt = await t.wait();
        if(!receipt.status) {
            throw new Error(`Transaction failed: ${receipt.transactionHash}`);
        }
        const logs = this.logParser.parseLogs(receipt);
        const regs = logs.get(LogNames.WorldRegisteredCompany);
        if (!regs || regs.length === 0) {
            throw new Error("CompanyRegistered event not found in logs");
        }
        const reg = regs[0];
        return {
            companyAddress: reg.args[0],
            vectorAddress: reg.args[1],
            receipt
        };
    }

    async registerAvatar(request: IWorldAvatarRegistrationRequest, tokens?: bigint): Promise<IAvatarRegistrationResult> {
        const enc = Avatar.encodeInitData({
            appearanceDetails: request.appearanceDetails,
            canReceiveTokensOutsideOfExperience: request.canReceiveTokensOutsideOfExperience
        });
        const t = await RPCRetryHandler.withRetry(() => this.world.registerAvatar({
            avatarOwner: request.avatarOwner,
            defaultExperience: request.defaultExperience,
            initData: enc,
            sendTokensToAvatarOwner: request.sendTokensToAvatarOwner,
            username: request.username
        }, {value: tokens}));
        const receipt = await t.wait();
        if(!receipt.status) {
            throw new Error(`Transaction failed: ${receipt.transactionHash}`);
        }
        const logs = this.logParser.parseLogs(receipt);
        const regs = logs.get(LogNames.WorldRegisteredAvatar);
        if (!regs || regs.length === 0) {
            throw new Error("WorldRegisteredAvatar event not found in logs");
        }
        const reg = regs[0];
        return {
            avatarAddress: reg.args[0],
            receipt
        };
    }

    async upgrade(newWorldInitData: string): Promise<IUpgradeResult> {

        const t = await RPCRetryHandler.withRetry(() => this.world.upgrade(newWorldInitData));
        const receipt = await t.wait();
        if(!receipt.status) {
            throw new Error(`Transaction failed: ${receipt.transactionHash}`);
        }
        const logs = this.logParser.parseLogs(receipt);
        const ups = logs.get(LogNames.WorldUpgraded);
        if (!ups || ups.length === 0) {
            throw new Error("WorldUpgraded event not found in logs");
        }
        return {
            receipt,
            newImplementationAddress: ups[0].args[1]
        };
    }

    async getImplementation(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.world.getImplementation());
    }

    async setHook(hook: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.world.setHook(hook));
    }

    async removeHook(): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.world.removeHook());
    }

    async getHook(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.world.hook());
    }

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