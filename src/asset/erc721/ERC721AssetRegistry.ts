import { AddressLike, Contract, TransactionReceipt } from "ethers";
import {abi} from "../../../artifacts/contracts/asset/registry/IAssetRegistry.sol/IAssetRegistry.json";
import {abi as proxyABI} from '../../../artifacts/contracts/base-types/BaseProxy.sol/BaseProxy.json';
import { ERC721Asset, ERC721InitData } from "./ERC721Asset";
import { LogNames } from "../../LogNames";
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { BaseAssetRegistry } from "../BaseAssetRegistry";
import { IWrapperOpts } from "../../interfaces/IWrapperOpts";


export type CreateERC721AssetResult = {
    receipt: TransactionReceipt;
    assetAddress: AddressLike;
}


export type ERC721CreateArgs = {
    name: string;
    issuer: AddressLike;
    originChainId: bigint;
    originChainAddress: AddressLike;
    symbol: string;
    initData: ERC721InitData;
}

export class ERC721AssetRegistry extends BaseAssetRegistry {
    static get abi() {
        return  [
            ...abi,
            ...proxyABI
        ]
    }
    
    private con: Contract;
    constructor(opts: IWrapperOpts) {
        super(opts);
        this.con = new Contract(this.address, abi, this.admin);
        this.logParser.addAbi(this.address, abi);
    }

    getContract(): Contract {
        return this.con;
    }

    async registerAsset(cArgs: ERC721CreateArgs): Promise<CreateERC721AssetResult> {
        let encoded = ERC721Asset.encodeInitData(cArgs.initData as ERC721InitData);
               
        const args = {
            name: cArgs.name,
            issuer: cArgs.issuer,
            originChainId: cArgs.originChainId,
            originAddress: cArgs.originChainAddress,
            symbol: cArgs.symbol,
            initData: encoded
        };

        const t = await  RPCRetryHandler.withRetry(()=>this.con.registerAsset(args));
        const r = await t.wait();
        if(!r.status) {
            throw new Error("Asset txn failed with status 0");
        }
        const logMap = this.logParser.parseLogs(r);

        const logs = logMap.get(LogNames.RegistryAddedEntity);
        if(!logs || logs.length === 0) {
            throw new Error("Asset not created");
        }
        const addr = logs[0].args[0];
        return {receipt: r, assetAddress: addr};
    }
}