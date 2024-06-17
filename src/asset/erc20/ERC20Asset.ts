import { AddressLike, Provider,ethers } from "ethers";
import {abi} from "../../../artifacts/contracts/asset/erc20/NTERC20Asset.sol/NTERC20Asset.json";
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { LogParser } from "../../LogParser";
import { AllLogParser } from "../../AllLogParser";

export interface IERC20Opts {
    address: string;
    provider: Provider;
    logParser: AllLogParser;
}

export type ERC20InitData = {
    originChainAddress: AddressLike;
    issuer: AddressLike;
    originChainId: bigint;
    decimals: number;
    name: string;
    symbol: string;
    maxSupply: bigint;
}

export class ERC20Asset {

    static encodeInitData(data: ERC20InitData): string {
        const ifc = new ethers.Interface(abi);
        const s = ifc.encodeFunctionData("encodeInitData", [data]);
        return `0x${s.substring(10)}`;
    }

    static get abi() {
        return abi;
    }

    readonly address: string;
    readonly provider: Provider;
    readonly asset: ethers.Contract;
    readonly logParser: AllLogParser;

    

    constructor(opts: IERC20Opts) {
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

    async hook(): Promise<string> {
        return await  RPCRetryHandler.withRetry(()=>this.asset.hook());
    }

}