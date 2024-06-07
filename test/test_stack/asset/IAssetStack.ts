import { AssetFactory, AssetRegistry, ERC20Asset, ERC721Asset } from "../../../src";
import { Company } from "../../../src/company/Company";

export interface IAssetStack  {
    
    getAssetFactory(): AssetFactory;
    getAssetRegistry(): AssetRegistry;
    createERC20Asset(issuingCompany: Company): ERC20Asset;
    createERC721Asset(issuingCompany: Company): ERC721Asset;
}