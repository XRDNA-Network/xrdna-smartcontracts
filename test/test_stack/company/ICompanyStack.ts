import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { Company } from "../../../src/company/Company";
import { CompanyFactory } from "../../../src/company/CompanyFactory";
import { CompanyRegistry } from "../../../src/company/CompanyRegistry";

export interface ICompanyStack  {
        getCompanyFactory(): CompanyFactory;
        getCompanyRegistry(): CompanyRegistry;
        createCompany(): Promise<Company>;
    }