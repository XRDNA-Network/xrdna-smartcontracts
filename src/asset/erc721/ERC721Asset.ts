import { AddressLike,  ethers } from "ethers";
import {abi} from "../../../artifacts/contracts/asset/instance/erc721/IERC721Asset.sol/IERC721Asset.json";
import {abi as proxyABI} from '../../../artifacts/contracts/base-types/entity/IEntityProxy.sol/IEntityProxy.json'
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { BaseAsset } from "../BaseAsset";
import { IWrapperOpts } from "../../interfaces/IWrapperOpts";


export type ERC721InitData = {
   baseURI: string;
}

export type ERC721MintResult = {
    tokenId: bigint;
    receipt: ethers.TransactionReceipt;
}


export class ERC721Asset extends BaseAsset {

    static get abi() {
        return [
            ...abi,
            ...proxyABI
        ]
    }
    
    static encodeInitData(data: ERC721InitData): string {
        return ethers.AbiCoder.defaultAbiCoder().encode([
            'tuple(string baseURI)'
        ], [data]);
    }

    readonly con: ethers.Contract;
    
    constructor(opts: IWrapperOpts) {
        super(opts);
        this.con = new ethers.Contract(this.address, abi, this.admin);
        this.logParser.addAbi(this.address, abi);
    }

    async balanceOf(account: AddressLike): Promise<bigint> {
        return await  RPCRetryHandler.withRetry(()=>this.con.balanceOf(account));
    }

    async tokenURI(tokenId: bigint): Promise<string> {
        return await  RPCRetryHandler.withRetry(()=>this.con.tokenURI(tokenId));
    }

    async ownerOf(tokenId: bigint): Promise<string> {
        return await  RPCRetryHandler.withRetry(()=>this.con.ownerOf(tokenId));
    }

}
