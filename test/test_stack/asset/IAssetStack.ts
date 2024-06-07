import { AddressLike } from "ethers";
import { AssetFactory, AssetRegistry, ERC20Asset, ERC721Asset } from "../../../src";
import { Company } from "../../../src/company/Company";

export interface IERC20CreationRequest {
    issuer: Company;
    name: string;
    symbol: string;
    decimals: number;
    originalChainAddress: AddressLike;
    originalChainId: bigint;
    totalSupply: bigint;
}

export interface IERC721CreationRequest {
    issuer: Company;
    originChainAddress: AddressLike;
    originChainId: bigint;
    name: string;
    symbol: string;
    baseURI: string;
}

export interface IAssetStack  {
    
    getAssetFactory(): AssetFactory;
    getAssetRegistry(): AssetRegistry;
    createERC20Asset(request: IERC20CreationRequest): Promise<ERC20Asset>;
    createERC721Asset(request: IERC721CreationRequest): Promise<ERC721Asset>;
}