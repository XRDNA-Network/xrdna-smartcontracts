import { AddressLike } from "ethers";
import { AssetFactory, AssetRegistry, ERC20Asset, ERC721Asset } from "../../../src";
import { Company } from "../../../src/company/Company";


export interface IAssetStack  {
    
    getAssetFactory(): AssetFactory;
    getAssetRegistry(): AssetRegistry;
}