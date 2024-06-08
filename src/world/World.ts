import { AddressLike, Provider, Signer, TransactionReceipt, TransactionResponse, ethers } from "ethers";
import {abi as WorldABI} from "../../artifacts/contracts/world/v0.2/World0_2.sol/World0_2.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";
import { LogParser } from "../LogParser";
import { LogNames } from "../LogNames";

/**
 * Typescript proxy for World instance
 */
export interface IWorldOpts {
    address: string;
    admin: Signer;
}

export interface ICompanyRegistrationRequest {
    owner: AddressLike;
    name: string;
    initData: string;
}

export interface ICompanyRegistrationResult {
    company: AddressLike;
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
    initData: string;
}

export interface IAvatarRegistrationResult {
    avatar: AddressLike;
    receipt: TransactionReceipt;
}

export interface IUpgradeResult {
    receipt: TransactionReceipt;
    newWorldAddress: string;
}

export class World {
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

    async getBaseVector(): Promise<VectorAddress> {
        return await RPCRetryHandler.withRetry(() => this.world.getBaseVector());
    }

    async getName(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.world.getName());
    }

    async withdraw(amount: bigint): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.world.withdraw(amount));
    }

    async version(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.world.version());
    }

    async _onlyV2(): Promise<void> {
        try {
            const v = await this.version();
            if(v && v != '0.2') {
                throw new Error(`Unsupported version number: ${v}`);
            }
        } catch (e:any) {
            throw new Error(`This function only supported in V2 contracts: ${e.message}`);
        }
    }

    async registerCompany(request: ICompanyRegistrationRequest): Promise<ICompanyRegistrationResult> {
        await this._onlyV2();

        const t = await RPCRetryHandler.withRetry(() => this.world.registerCompany(request));
        const receipt = await t.wait();
        if(!receipt.status) {
            throw new Error(`Transaction failed: ${receipt.transactionHash}`);
        }
        const logs = this.parser.parseLogs(receipt);
        const args = logs[LogNames.CompanyRegistered];
        if (!args) {
            throw new Error("CompanyRegistered event not found in logs");
        }
        return {
            company: args[0],
            vectorAddress: args[1],
            receipt
        };
    }

    async registerAvatar(request: IAvatarRegistrationRequest): Promise<IAvatarRegistrationResult> {
        await this._onlyV2();

        const t = await RPCRetryHandler.withRetry(() => this.world.registerAvatar(request));
        const receipt = await t.wait();
        if(!receipt.status) {
            throw new Error(`Transaction failed: ${receipt.transactionHash}`);
        }
        const logs = this.parser.parseLogs(receipt);
        const args = logs[LogNames.AvatarRegistered];
        if (!args) {
            throw new Error("AvatarRegistered event not found in logs");
        }
        return {
            avatar: args[0],
            receipt
        };
    }

    async upgrade(newWorldInitData: string): Promise<IUpgradeResult> {
        await this._onlyV2();

        const t = await RPCRetryHandler.withRetry(() => this.world.upgrade(newWorldInitData));
        const receipt = await t.wait();
        if(!receipt.status) {
            throw new Error(`Transaction failed: ${receipt.transactionHash}`);
        }
        const logs = this.parser.parseLogs(receipt);
        const args = logs[LogNames.WorldUpgraded];
        if (!args) {
            throw new Error("WorldUpgraded event not found in logs");
        }
        return {
            receipt,
            newWorldAddress: args[1]
        };
    }

    async setHook(hook: AddressLike): Promise<TransactionResponse> {
        await this._onlyV2();
        return await RPCRetryHandler.withRetry(() => this.world.setHook(hook));
    }

    async removeHook(): Promise<TransactionResponse> {
        await this._onlyV2();
        return await RPCRetryHandler.withRetry(() => this.world.removeHook());
    }
}