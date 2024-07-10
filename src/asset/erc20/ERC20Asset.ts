import { AddressLike, Provider,ethers } from "ethers";
import {abi} from "../../../artifacts/contracts/asset/instance/erc20/IERC20Asset.sol/IERC20Asset.json";
import {abi as proxyABI} from '../../../artifacts/contracts/base-types/entity/IEntityProxy.sol/IEntityProxy.json'
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { AllLogParser } from "../../AllLogParser";
import { BaseAsset } from "../BaseAsset";

export interface IERC20Opts {
    address: string;
    provider: Provider;
    logParser: AllLogParser;
}

export type ERC20InitData = {
    decimals: number;
    maxSupply: bigint;
}

export class ERC20Asset extends BaseAsset {

    static encodeInitData(data: ERC20InitData): string {
        return ethers.AbiCoder.defaultAbiCoder().encode([
            'tuple(uint8 decimals,uint256 maxSupply)'
        ], [data]);
    }

    static get abi() {
        return [
            ...abi,
            ...proxyABI
        ]
    }

    readonly address: string;
    readonly provider: Provider;
    readonly asset: ethers.Contract;
    readonly logParser: AllLogParser;

    

    constructor(opts: IERC20Opts) {
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
