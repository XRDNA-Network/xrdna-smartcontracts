import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { Company } from "../../../src/company/Company";
import { CompanyFactory } from "../../../src/company/CompanyFactory";
import { CompanyRegistry } from "../../../src/company/CompanyRegistry";
import { ERC20Asset, ERC721Asset, World } from "../../../src";
import { AddressLike } from "ethers";


export interface ICreateCompanyRequest {
    owner: string;
    world: World;
    initData: string;
    name: string;
    sendTokensToCompanyOwner: boolean;

}

export interface IERC20CreationRequest {
    originChainAddress: AddressLike;
    issuer: AddressLike;
    decimals: number;
    originChainId: bigint;
    totalSupply: bigint;
    name: string;
    symbol: string;
}

export interface IERC721CreationRequest {
    issuer: AddressLike;
    originChainAddress: AddressLike;
    originChainId: bigint;
    name: string;
    symbol: string;
    baseURI: string;
}
export interface ICompanyStack  {
        getCompanyFactory(): CompanyFactory;
        getCompanyRegistry(): CompanyRegistry;
        createCompany(ICreateCompanyRequest): Promise<Company>;

        createERC20Asset(request: IERC20CreationRequest): Promise<ERC20Asset>;
        createERC721Asset(request: IERC721CreationRequest): Promise<ERC721Asset>;
    }