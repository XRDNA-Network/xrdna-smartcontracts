import { ERC721AssetFactory, ERC721AssetRegistry } from "../../../../src";

export interface IERC721AssetStack  {
    getEC721Factory(): ERC721AssetFactory;
    getERC721Registry(): ERC721AssetRegistry;
}