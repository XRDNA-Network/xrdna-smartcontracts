import { AddressLike, Provider, Signer, TransactionResponse, ethers } from "ethers";
import {abi} from "../../artifacts/contracts/asset/NonTransferableERC721Asset.sol/NonTransferableERC721Asset.json";
import { LogParser } from "../LogParser";
import { LogNames } from "../LogNames";
import { RPCRetryHandler } from "../RPCRetryHandler";

export interface IERC721Opts {
    address: string;
    admin: Signer;
}

export type ERC721InitData = {
    issuer: AddressLike;
    originChainAddress: AddressLike;
    name: string;
    symbol: string;
    baseURI: string;
    originChainId: bigint;
}

export type ERC721MintResult = {
    tokenId: bigint;
    receipt: ethers.TransactionReceipt;
}

export class ERC721Asset {

    static encodeInitData(data: ERC721InitData): string {
        const ifc = new ethers.Interface(abi);
        const s = ifc.encodeFunctionData("encodeInitData", [data]);
        return `0x${s.substring(10)}`;
    }

    readonly address: string;
    readonly admin: Provider | Signer;
    readonly asset: ethers.Contract;
    
    private logParser: LogParser;
    constructor(opts: IERC721Opts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.asset = new ethers.Contract(this.address, abi, this.admin);
        this.logParser = new LogParser(abi, this.address);
    }

    async name(): Promise<string> {
        return await  RPCRetryHandler.withRetry(()=>this.asset.name());
    }

    async symbol(): Promise<string> {
        return await  RPCRetryHandler.withRetry(()=>this.asset.symbol());
    }

    async balanceOf(account: AddressLike): Promise<bigint> {
        return await  RPCRetryHandler.withRetry(()=>this.asset.balanceOf(account));
    }

    async tokenURI(tokenId: bigint): Promise<string> {
        return await  RPCRetryHandler.withRetry(()=>this.asset.tokenURI(tokenId));
    }

    async ownerOf(tokenId: bigint): Promise<string> {
        return await  RPCRetryHandler.withRetry(()=>this.asset.ownerOf(tokenId));
    }

    async decimals(): Promise<number> {
        return await  RPCRetryHandler.withRetry(()=>this.asset.decimals());
    }

    async addHook(address: AddressLike): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.asset.addHook(address));
    }

    async removeHook(address: AddressLike): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.asset.removeHook(address));
    }
}