import { AddressLike, Provider, ethers } from "ethers";
import {abi} from "../../../artifacts/contracts/asset/erc721/NTERC721Asset.sol/NTERC721Asset.json";
import { LogParser } from "../../LogParser";
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { AllLogParser } from "../../AllLogParser";
import { BaseAsset } from "../BaseAsset";

export interface IERC721Opts {
    address: string;
    provider: Provider;
    logParser: AllLogParser;
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

export class ERC721Asset extends BaseAsset {

    static get abi() {
        return abi;
    }
    
    static encodeInitData(data: ERC721InitData): string {
        const ifc = new ethers.Interface(abi);
        const s = ifc.encodeFunctionData("encodeInitData", [data]);
        return `0x${s.substring(10)}`;
    }

    readonly address: string;
    readonly provider: Provider;
    readonly asset: ethers.Contract;
    readonly logParser: AllLogParser;
    
    constructor(opts: IERC721Opts) {
        super();
        this.address = opts.address;
        this.provider = opts.provider;
        this.asset = new ethers.Contract(this.address, abi, this.provider);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, abi);
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
    async hook(): Promise<string> {
        return await  RPCRetryHandler.withRetry(()=>this.asset.hook());
    }
}
