import { AssetFactory, AssetRegistry, ERC20Asset, ERC20InitData, ERC721Asset } from "../../../src";
import { IBasicDeployArgs, IDeployable } from "../IDeployable";
import { IAssetStack, IERC20CreationRequest, IERC721CreationRequest } from "./IAssetStack";
import {AssetType} from '../../../src/';
import { ignition } from "hardhat";
import {StackCreatorFn} from '../StackFactory';
import { throwError } from "../../utils";
import { Signer } from "ethers";
import AssetFactoryModule from '../../../ignition/modules/asset/AssetFactory.module';
import AssetRegistryModule from "../../../ignition/modules/asset/AssetRegistry.module";
import NTAssetMasterModule from "../../../ignition/modules/asset/NTAssetMaster.module";


export interface IAssetStackArgs extends IBasicDeployArgs {

}

export class AssetStackImpl implements IAssetStack, IDeployable {

    assetFactory!: AssetFactory;
    assetRegistry!: AssetRegistry;
    admin!: Signer;
    assets: Map<bigint, any> = new Map();

    constructor(readonly factory: StackCreatorFn) {
        
    }

    getAssetFactory(): AssetFactory {
        this._checkDeployed();
        return this.assetFactory;
    }

    getAssetRegistry(): AssetRegistry {
        this._checkDeployed();
        return this.assetRegistry;
    }

    async createERC20Asset(request: IERC20CreationRequest): Promise<ERC20Asset> {
        this._checkDeployed();
        const a = this.assets.get(AssetType.ERC20);
        if(a) {
            return a;
        }

        const initData: ERC20InitData = {
            issuer: request.issuer.address,
            name: request.name,
            symbol: request.symbol,
            decimals: request.decimals,
            originChainAddress: request.originalChainAddress,
            originChainId: request.originalChainId,
            totalSupply: request.totalSupply
        }
        const t = await this.assetRegistry.registerAsset(AssetType.ERC20, initData);
        const asset = new ERC20Asset({
            address: t.assetAddress.toString() || throwError("Contract address not found"),
            admin: this.admin
        });
        this.assets.set(AssetType.ERC20, asset);
        return asset;
        
    }

    async createERC721Asset(request: IERC721CreationRequest): Promise<ERC721Asset> {
        this._checkDeployed();
        const a = this.assets.get(AssetType.ERC721);
        if(a) {
            return a;
        }
        
        const initData = {
            issuer: request.issuer.address,
            originChainAddress: request.originChainAddress,
            originChainId: request.originChainId,
            name: request.name,
            symbol: request.symbol,
            baseURI: request.baseURI
        }
        const t = await this.assetRegistry.registerAsset(AssetType.ERC721, initData);
        const asset = new ERC721Asset({
            address: t.assetAddress.toString() || throwError("Contract address not found"),
            admin: this.admin
        });
        this.assets.set(AssetType.ERC721, asset);
        return asset;
    }
    
    async deploy(args: IAssetStackArgs): Promise<void> {
        if(this.assetFactory && this.assetRegistry) {
            return;
        }
        this.admin = args.admin;
        await this._deployFactory(args);
        await this._deployRegistry(args);
        await this._deployMasterAssets();
    }

    _checkDeployed() {
        if (!this.assetFactory || !this.assetRegistry) {
            throw new Error("AssetStack not deployed");
        }
    }

    async _deployFactory(args: IAssetStackArgs) {
        if(this.assetFactory) {
            return;
        }
        const {assetFactory} = await ignition.deploy(AssetFactoryModule);
        const address  = await assetFactory.getAddress();

        this.assetFactory = new AssetFactory({
            address,
            admin: args.admin
        });
    }

    async _deployRegistry(args: IAssetStackArgs) {
        if(this.assetRegistry) {
            return;
        }
        const {assetRegistry} = await ignition.deploy(AssetRegistryModule);
        const address = await assetRegistry.getAddress();
        this.assetRegistry = new AssetRegistry({
            address,
            admin: args.admin
        });

        await this.assetFactory.setAuthorizedRegistry(address);
    }

    async _deployMasterAssets() {
        const {erc20Master, erc721Master} = await ignition.deploy(NTAssetMasterModule);
        await this.assetFactory.setERC20Implementation(await erc20Master.getAddress());
        await this.assetFactory.setERC721Implementation(await erc721Master.getAddress());
        
    }

}