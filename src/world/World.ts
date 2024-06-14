import { AddressLike, Provider, Signer, TransactionReceipt, TransactionResponse, ethers } from "ethers";
import {abi as WorldABI} from "../../artifacts/contracts/world/v0.2/WorldV2.sol/WorldV2.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";
import { LogParser } from "../LogParser";
import { LogNames } from "../LogNames";
import { Avatar } from "../avatar/Avatar";
import { ISupportsSigners } from "../interfaces/ISupportsSigners";
import { ISupportsVector } from "../interfaces";
import { IUpgradeResult, IUpgradeable } from "../interfaces/IUpgradeable";
import { ISupportsHooks } from "../interfaces/ISupportsHooks";
import { ISupportsFunds } from "../interfaces/ISupportsFunds";

/**
 * Typescript proxy for World instance
 */
export interface IWorldOpts {
    address: string;
    admin: Signer | Provider;
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

export interface IAvatarRegistrationRequest {
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
    readonly address: string;
    readonly admin: Provider | Signer;
    private world: ethers.Contract;
    private parser: LogParser;

    constructor(opts: IWorldOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.world = new ethers.Contract(this.address, WorldABI, this.admin);
        this.parser = new LogParser(WorldABI, this.address);
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
        const logs = this.parser.parseLogs(receipt);
        const args = logs.get(LogNames.CompanyRegistered);
        if (!args) {
            throw new Error("CompanyRegistered event not found in logs");
        }
        return {
            companyAddress: args[0],
            vectorAddress: args[1],
            receipt
        };
    }

    async registerAvatar(request: IAvatarRegistrationRequest, tokens?: bigint): Promise<IAvatarRegistrationResult> {
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
        const logs = this.parser.parseLogs(receipt);
        const args = logs.get(LogNames.AvatarRegistered);
        if (!args) {
            throw new Error("AvatarRegistered event not found in logs");
        }
        return {
            avatarAddress: args[0],
            receipt
        };
    }

    async upgrade(newWorldInitData: string): Promise<IUpgradeResult> {

        const t = await RPCRetryHandler.withRetry(() => this.world.upgrade(newWorldInitData));
        const receipt = await t.wait();
        if(!receipt.status) {
            throw new Error(`Transaction failed: ${receipt.transactionHash}`);
        }
        const logs = this.parser.parseLogs(receipt);
        const args = logs.get(LogNames.WorldUpgraded);
        if (!args) {
            throw new Error("WorldUpgraded event not found in logs");
        }
        return {
            receipt,
            newWorldAddress: args[1]
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
}