import { AddressLike, Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../../artifacts/contracts/asset/erc20/ERC20AssetRegistry.sol/ERC20AssetRegistry.json";
import { ERC20Asset, ERC20InitData } from "./ERC20Asset";
import { LogNames } from "../../LogNames";
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { isPromise } from "util/types";
import { AllLogParser } from "../../AllLogParser";

export interface IERC20AssetRegistryOpts {
    admin: Provider | Signer;
    address: string;
    logParser: AllLogParser;
}

export type CreateERC20AssetResult = {
    receipt: TransactionResponse;
    assetAddress: AddressLike;

}

export class ERC20AssetRegistry {

    static get abi() {
        return abi;
    }
    
    private admin: Provider | Signer;
    readonly address: string;
    private con: Contract;
    private logParser: AllLogParser;
    constructor(opts: IERC20AssetRegistryOpts) {
        if(isPromise(opts.address)) {
            throw new Error("Cannot pass address promise to AssetRegistry");
        }
        this.admin = opts.admin;
        this.address = opts.address;
        this.con = new Contract(this.address, abi, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, abi);
    }

    async isRegisteredAsset(assetAddress: AddressLike): Promise<boolean> {
        return await  RPCRetryHandler.withRetry(()=>this.con.isRegisteredAsset(assetAddress));
    }

    async assetExists(originAddress: AddressLike, originChainId: bigint): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.assetExists(originAddress, originChainId));
    }

    async registerAsset(initData: ERC20InitData): Promise<CreateERC20AssetResult> {
        let encoded = ERC20Asset.encodeInitData(initData as ERC20InitData);
               
        const t = await  RPCRetryHandler.withRetry(()=>this.con.registerAsset(encoded));
        const r = await t.wait();
        if(!r.status) {
            throw new Error("Asset txn failed with status 0");
        }
        const logMap = this.logParser.parseLogs(r);

        const logs = logMap.get(LogNames.ERC20AssetCreated);
        if(!logs || logs.length == 0) {
            throw new Error("Asset not created");
        }
        const addr = logs[0].args[0];
        return {receipt: r, assetAddress: addr};
    }
}