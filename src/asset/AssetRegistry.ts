import { Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/asset/AssetRegistry.sol/AssetRegistry.json";
import { ERC20Asset, ERC20InitData } from "./ERC20Asset";
import { LogParser } from "../LogParser";
import { LogNames } from "../LogNames";
import { AssetType } from "./AssetFactory";
import { ERC721Asset, ERC721InitData } from "./ERC721Asset";
import { RPCRetryHandler } from "../RPCRetryHandler";

export interface IAssetRegistryOpts {
    admin: Provider | Signer;
    address: string;
}

export type CreateAssetResult = {
    receipt: TransactionResponse;
    assetAddress: string;
}

export class AssetRegistry {
    private admin: Provider | Signer;
    private address: string;
    private con: Contract;
    private logParser: LogParser;
    constructor(opts: IAssetRegistryOpts) {
        this.admin = opts.admin;
        this.address = opts.address;
        this.con = new Contract(this.address, abi, this.admin);
        this.logParser = new LogParser(abi, this.address);
    }

    async setAssetFactory(impl: string): Promise<TransactionResponse> {
       return await  RPCRetryHandler.withRetry(()=>this.con.setAssetFactory(impl));
    }

    async isRegisteredAsset(assetAddress: string): Promise<boolean> {
        return await  RPCRetryHandler.withRetry(()=>this.con.isRegisteredAsset(assetAddress));
    }

    async registerAsset(assetType: bigint, initData: ERC20InitData | ERC721InitData): Promise<CreateAssetResult> {
        let encoded: string;
        switch(assetType) {
            case AssetType.ERC20: {
                encoded = ERC20Asset.encodeInitData(initData as ERC20InitData);
                break;
            }
            case AssetType.ERC721: {
                encoded = ERC721Asset.encodeInitData(initData as ERC721InitData);
                break;
            }
            default: {
                throw new Error("Invalid asset type");
            }
        }
        const t = await  RPCRetryHandler.withRetry(()=>this.con.registerAsset(assetType, encoded));
        const r = await t.wait();
        if(!r.status) {
            throw new Error("Asset txn failed with status 0");
        }
        const logMap = this.logParser.parseLogs(r);

        const args = logMap.get(LogNames.AssetCreated);
        if(!args) {
            throw new Error("Asset not created");
        }
        const addr = args[0];
        return {receipt: r, assetAddress: addr};
    }

    async addAssetCondition(props: {
        assetIssuer: Signer,
        assetAddress: string, 
        condition: string
    }): Promise<TransactionResponse> {
        return await  RPCRetryHandler.withRetry(()=>(this.con.connect(props.assetIssuer) as any).addAssetCondition(props.assetAddress, props.condition));
    }

    async removeAssetCondition(props: {
        assetAddress: string, 
        condition: string,
        assetIssuer: Signer
    }): Promise<TransactionResponse> {
        return await  RPCRetryHandler.withRetry(()=>(this.con.connect(props.assetIssuer) as any).removeAssetCondition(props.assetAddress, props.condition));
    }

    async canViewAsset(props: {
        assetAddress: string,
        worldAddress: string,
        companyAddress: string,
        experienceAddress: string
    }): Promise<boolean> {
        return await  RPCRetryHandler.withRetry(()=>this.con.canViewAsset(props.assetAddress, props.worldAddress, props.companyAddress, props.experienceAddress));
    }

    async canUseAsset(props: {
        assetAddress: string,
        worldAddress: string,
        companyAddress: string,
        experienceAddress: string
    }): Promise<boolean> {
        return await  RPCRetryHandler.withRetry(()=>this.con.canUseAsset(props.assetAddress, props.worldAddress, props.companyAddress, props.experienceAddress));
    }

    async upgradeAsset(props: {
        assetAddress: string, 
        assetType: bigint, 
        initData: ERC20InitData | ERC721InitData,
        assetIssuer: Signer
    }): Promise<CreateAssetResult> {
        let encoded: string;
        const {assetAddress, assetType, initData} = props;
        switch(assetType) {
            case AssetType.ERC20: {
                encoded = ERC20Asset.encodeInitData(initData as ERC20InitData);
                break;
            }
            case AssetType.ERC721: {
                encoded = ERC721Asset.encodeInitData(initData as ERC721InitData);
                break;
            }
            default: {
                throw new Error("Invalid asset type");
            }
        }
        const t = await  RPCRetryHandler.withRetry(()=>(this.con.connect(props.assetIssuer) as any).upgradeAsset(assetAddress, assetType, encoded));
        const r = await t.wait();
        if(!r.status) {
            throw new Error("Asset upgrade txn failed with status 0");
        }
        const logMap = this.logParser.parseLogs(r);

        const args = logMap.get(LogNames.AssetCreated);
        if(!args) {
            throw new Error("Asset not created");
        }
        const addr = args[0];
        return {receipt: r, assetAddress: addr};
    }
}