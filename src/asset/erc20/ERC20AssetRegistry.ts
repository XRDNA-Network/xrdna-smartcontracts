import { AddressLike, Contract, TransactionReceipt } from "ethers";
import {abi} from "../../../artifacts/contracts/asset/registry/IAssetRegistry.sol/IAssetRegistry.json";
import {abi as proxyABI} from '../../../artifacts/contracts/base-types/BaseProxy.sol/BaseProxy.json';
import { ERC20Asset, ERC20InitData } from "./ERC20Asset";
import { LogNames } from "../../LogNames";
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { BaseAssetRegistry } from "../BaseAssetRegistry";
import { IWrapperOpts } from "../../interfaces/IWrapperOpts";


export type CreateERC20AssetResult = {
    receipt: TransactionReceipt;
    assetAddress: AddressLike;
}

export type ERC20CreateArgs = {
    name: string;
    issuer: AddressLike;
    originChainId: bigint;
    originChainAddress: AddressLike;
    symbol: string;
    initData: ERC20InitData;
}

export class ERC20AssetRegistry extends BaseAssetRegistry {

    static get abi() {
        return [
            ...abi,
            ...proxyABI
        ]
    }
    
    private con: Contract;
    constructor(opts: IWrapperOpts) {
        super(opts);
        this.con = new Contract(this.address, abi, this.admin);
    }

    getContract(): Contract {
        return this.con;
    }

    async isRegisteredAsset(assetAddress: AddressLike): Promise<boolean> {
        return await  RPCRetryHandler.withRetry(()=>this.con.isRegistered(assetAddress));
    }

    async registerAsset(cArgs: ERC20CreateArgs): Promise<CreateERC20AssetResult> {
        let encoded = ERC20Asset.encodeInitData(cArgs.initData as ERC20InitData);
        let args = {
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
        if(!logs || logs.length == 0) {
            throw new Error("Asset not created");
        }
        const addr = logs[0].args[0];
        return {receipt: r, assetAddress: addr};
    }
}