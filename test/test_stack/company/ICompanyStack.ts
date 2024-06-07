import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { Company } from "../../../src/company/Company";
import { CompanyFactory } from "../../../src/company/CompanyFactory";
import { CompanyRegistry } from "../../../src/company/CompanyRegistry";
import { World } from "../../../src";


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
    }