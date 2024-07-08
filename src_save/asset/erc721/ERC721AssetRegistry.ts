import { AddressLike, Contract, Provider, Signer, TransactionReceipt, TransactionResponse } from "ethers";
import {abi} from "../../../artifacts/contracts/asset/erc721/ERC721AssetRegistry.sol/ERC721AssetRegistry.json";
import { ERC721Asset, ERC721InitData } from "./ERC721Asset";
import { LogParser } from "../../LogParser";
import { LogNames } from "../../LogNames";
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { isPromise } from "util/types";
import { AllLogParser } from "../../AllLogParser";

export interface IERC721AssetRegistryOpts {
    admin: Provider | Signer;
    address: string;
    logParser: AllLogParser;
}

export type CreateERC721AssetResult = {
    receipt: TransactionReceipt;
    assetAddress: AddressLike;
}

export class ERC721AssetRegistry {
    static get abi() {
        return abi;
    }
    
    private admin: Provider | Signer;
    readonly address: string;
    private con: Contract;
    private logParser: AllLogParser;
    constructor(opts: IERC721AssetRegistryOpts) {
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

    async registerAsset(initData: ERC721InitData): Promise<CreateERC721AssetResult> {
        let encoded = ERC721Asset.encodeInitData(initData as ERC721InitData);
               
        const t = await  RPCRetryHandler.withRetry(()=>this.con.registerAsset(encoded));
        const r = await t.wait();
        if(!r.status) {
            throw new Error("Asset txn failed with status 0");
        }
        const logMap = this.logParser.parseLogs(r);

        const logs = logMap.get(LogNames.ERC721AssetCreated);
        if(!logs || logs.length === 0) {
            throw new Error("Asset not created");
        }
        const addr = logs[0].args[0];
        return {receipt: r, assetAddress: addr};
    }
}