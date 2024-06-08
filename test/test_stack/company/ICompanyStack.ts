import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { Company } from "../../../src/company/Company";
import { CompanyFactory } from "../../../src/company/CompanyFactory";
import { CompanyRegistry } from "../../../src/company/CompanyRegistry";
import { ERC20Asset, ERC721Asset, World } from "../../../src";
import { IERC20CreationRequest, IERC721CreationRequest } from "../asset/IAssetStack";


export interface ICreateCompanyRequest {
    owner: string;
    world: World;
    initData: string;
    name: string;

}
export interface ICompanyStack  {
        getCompanyFactory(): CompanyFactory;
        getCompanyRegistry(): CompanyRegistry;
        createCompany(ICreateCompanyRequest): Promise<Company>;

        createERC20Asset(request: IERC20CreationRequest): Promise<ERC20Asset>;
        createERC721Asset(request: IERC721CreationRequest): Promise<ERC721Asset>;
    }