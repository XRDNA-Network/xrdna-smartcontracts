import { AddressLike, Contract, Provider,ethers } from "ethers";
import {abi} from "../../../artifacts/contracts/asset/instance/erc20/IERC20Asset.sol/IERC20Asset.json";
import {abi as proxyABI} from '../../../artifacts/contracts/base-types/entity/IEntityProxy.sol/IEntityProxy.json'
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { AllLogParser } from "../../AllLogParser";
import { BaseAsset } from "../BaseAsset";
import { IWrapperOpts } from "../../interfaces/IWrapperOpts";


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

    
    readonly con: Contract;
    constructor(opts: IWrapperOpts) {
        super(opts);
        this.con = new ethers.Contract(this.address, abi, this.admin);
        this.logParser.addAbi(this.address, abi);
    }

    getContract(): Contract {
        return this.con;
    }


    async totalSupply(): Promise<bigint> {
        return await  RPCRetryHandler.withRetry(()=>this.con.totalSupply());
    }

    async balanceOf(account: AddressLike): Promise<bigint> {
        return await  RPCRetryHandler.withRetry(()=>this.con.balanceOf(account));
    }

    async decimals(): Promise<number> {
        return await  RPCRetryHandler.withRetry(()=>this.con.decimals());
    }

    async canMint(to: AddressLike, amt: bigint): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.getContract().canMint(to, amt));
    }

}
