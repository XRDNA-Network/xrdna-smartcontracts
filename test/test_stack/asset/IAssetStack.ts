import { AssetFactory, AssetRegistry, ERC20Asset, ERC721Asset } from "../../../src";

export interface IAssetStack  {
    
    getAssetFactory(): AssetFactory;
    getAssetRegistry(): AssetRegistry;
    createERC20Asset(): ERC20Asset;
    createERC721Asset(): ERC721Asset;
}