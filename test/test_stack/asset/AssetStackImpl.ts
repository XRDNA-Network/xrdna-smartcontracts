import { AssetFactory, AssetRegistry, ERC20Asset, ERC721Asset } from "../../../src";
import { IBasicDeployArgs, IDeployable } from "../IDeployable";
import { IAssetStack } from "./IAssetStack";
import {AssetType} from '../../../src/';
import { ethers } from "hardhat";


export interface IAssetStackArgs extends IBasicDeployArgs {

}

export class AssetStackImpl implements IAssetStack, IDeployable {

    assetFactory!: AssetFactory;
    assetFactoryAddress!: string;
    assetRegistry!: AssetRegistry;
    assetRegistryAddress!: string;
    assets: Map<typeof AssetType, any> = new Map();

    getAssetFactory(): AssetFactory {
        this._checkDeployed();
        return this.assetFactory;
    }

    getAssetRegistry(): AssetRegistry {
        this._checkDeployed();
        return this.assetRegistry;
    }

    createERC20Asset(): ERC20Asset {
        this._checkDeployed();
        throw new Error("Method not implemented.");
    }

    createERC721Asset(): ERC721Asset {
        this._checkDeployed();
        throw new Error("Method not implemented.");
    }
    
    async deploy(args: IAssetStackArgs): Promise<void> {
        await this._deployFactory(args);
        await this._deployRegistry(args);
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

}