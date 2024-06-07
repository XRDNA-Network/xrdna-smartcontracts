import { AddressLike, Provider, Signer, TransactionResponse, ethers } from "ethers";
import {abi} from "../../artifacts/contracts/asset/NonTransferableERC20Asset.sol/NonTransferableERC20Asset.json";
import { RPCRetryHandler } from "../RPCRetryHandler";

export interface IERC20Opts {
    address: string;
    admin: Signer;
}

export type ERC20InitData = {
    originChainAddress: AddressLike;
    issuer: AddressLike;
    originChainId: bigint;
    totalSupply: bigint;
    decimals: number;
    name: string;
    symbol: string;
}

export class ERC20Asset {

    readonly address: string;
    readonly admin: Provider | Signer;
    readonly asset: ethers.Contract;

    static encodeInitData(data: ERC20InitData): string {
        const ifc = new ethers.Interface(abi);
        const s = ifc.encodeFunctionData("encodeInitData", [data]);
        return `0x${s.substring(10)}`;
    }

    constructor(opts: IERC20Opts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.asset = new ethers.Contract(this.address, abi, this.admin);
    }

    async addHook(address: AddressLike): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.asset.addHook(address));
    }

    async removeHook(address: AddressLike): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.asset.removeHook(address));
    }

    async name(): Promise<string> {
        return await  RPCRetryHandler.withRetry(()=>this.asset.name());
    }

    async symbol(): Promise<string> {
        return await  RPCRetryHandler.withRetry(()=>this.asset.symbol());
    }

    async upgraded(): Promise<boolean> {
        return await  RPCRetryHandler.withRetry(()=>this.asset.upgraded());
    }

    async totalSupply(): Promise<bigint> {
        return await  RPCRetryHandler.withRetry(()=>this.asset.totalSupply());
    }

    async balanceOf(account: AddressLike): Promise<bigint> {
        return await  RPCRetryHandler.withRetry(()=>this.asset.balanceOf(account));
    }

    async decimals(): Promise<number> {
        return await  RPCRetryHandler.withRetry(()=>this.asset.decimals());
    }

}