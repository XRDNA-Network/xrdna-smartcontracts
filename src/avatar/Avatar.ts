import { Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/avatar/Avatar.sol/Avatar.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";


export interface IAvatarOpts {
    address: string;
    admin: Provider | Signer;
}

export interface IAvatarJumpRequest {
    portalId: string
    agreedFee: string,
    destinationCompanySignature: string,
}

export interface IDelegatedAvatarJumpRequest {
    portalId: string,
    agreedFee: string,
    avatarOwnerSignature: string,
}

export interface IWearable  {
    asset: string;
    tokenId: bigint;
}

export class Avatar {
    private con: Contract;
    private address: string;
    private admin: Provider | Signer;

    constructor(opts: IAvatarOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.con = new Contract(this.address, abi, this.admin);
    }

    async location(): Promise<VectorAddress> {
        return await RPCRetryHandler.withRetry(() => this.con.location());
    }

    async getWearables(): Promise<IWearable[]> {
        return await RPCRetryHandler.withRetry(() => this.con.getWearables());
    }

    async setCanReceiveTokensOutsideOfExperience(canReceive: boolean): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setCanReceiveTokensOutsideOfExperience(canReceive));
    }

    async setLocation(location: VectorAddress): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setLocation(location));
    }

    async setAppearanceDetails(bytes: string) : Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setAppearanceDetails(bytes));
    }

    async jump(req: IAvatarJumpRequest): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.jump(req));
    }

    async delegateJump(req: IDelegatedAvatarJumpRequest): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.delegateJump(req));
    }

    async addWearable(wearable: IWearable): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.addWearable(wearable));
    }

    async removeWearable(wearable: IWearable): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeWearable(wearable));
    }

    async isWearing(wearable: IWearable): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isWearing(wearable));
    }

    async addSigner(signer: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.addSigner(signer));
    }

    async removeSigner(signer: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeSigner(signer));
    }

    async setHook(hook: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setHook(hook));
    }

    async removeHook(): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeHook());
    }

    async withdraw(amount: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.withdraw(amount));
    }

    async upgrade(newVersion: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.upgrade(newVersion));
    }
}