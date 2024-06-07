import { AssetFactory, AssetRegistry, ERC20Asset, ERC20InitData, ERC721Asset } from "../../../src";
import { IBasicDeployArgs, IDeployable } from "../IDeployable";
import { IAssetStack, IERC20CreationRequest, IERC721CreationRequest } from "./IAssetStack";
import {AssetType} from '../../../src/';
import { ethers } from "hardhat";
import {StackFactory, StackCreatorFn, StackType} from '../StackFactory';
import { IAvatarStack } from "../avatar/IAvatarStack";
import { IExperienceStack } from "../experience/IExperienceStack";
import { Company } from "../../../src/company/Company";
import { throwError } from "../../utils";
import { Signer } from "ethers";


export interface IAssetStackArgs extends IBasicDeployArgs {

}

export class AssetStackImpl implements IAssetStack, IDeployable {

    assetFactory!: AssetFactory;
    assetFactoryAddress!: string;
    assetRegistry!: AssetRegistry;
    assetRegistryAddress!: string;
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
        const Factory = await ethers.getContractFactory("AssetFactory");
        const factory = await Factory.deploy(args.admin.getAddress(), [args.admin.getAddress()]);
        const t = await factory.deploymentTransaction()?.wait();
        this.assetFactoryAddress = t?.contractAddress || "";
        this.assetFactory = new AssetFactory({
            address: this.assetFactoryAddress,
            admin: args.admin
        });
    }

    async _deployRegistry(args: IAssetStackArgs) {
        const Reg = await ethers.getContractFactory("AssetRegistry");
        const assetRegistry = await Reg.deploy(args.admin, [args.admin], this.assetFactoryAddress);
        const t = await assetRegistry.deploymentTransaction()?.wait();
        this.assetRegistryAddress = t?.contractAddress || "";
        this.assetRegistry = new AssetRegistry({
            address: this.assetRegistryAddress,
            admin: args.admin
        });

        await this.assetFactory.setAuthorizedRegistry(this.assetRegistryAddress);
    }

    async _deployMasterAssets() {
        const avatarStack: IAvatarStack = this.factory(StackType.AVATAR);
        const experienceStack:IExperienceStack = this.factory(StackType.EXPERIENCE);

        const cArgs = {
            assetFactory: this.assetFactory.address,
            assetRegistry: this.assetRegistry.address,
            avatarRegistry: avatarStack.getAvatarRegistry().address,
            experienceRegistry: experienceStack.getExperienceRegistry().address
        }
        const ERC20 = await ethers.getContractFactory("NonTransferableERC20Asset");
        const masterERC20 = await ERC20.deploy(cArgs);
        let t = await masterERC20.deploymentTransaction()?.wait();
        const erc20Address = t?.contractAddress || "";

        const ERC721 = await ethers.getContractFactory("NonTransferableERC721Asset");
        const masterERC721 = await ERC721.deploy(cArgs);
        t = await masterERC721.deploymentTransaction()?.wait();
        const erc721Address = t?.contractAddress || "";

        await this.assetFactory.setERC20Implementation(erc20Address);
        await this.assetFactory.setERC721Implementation(erc721Address);
    }

}