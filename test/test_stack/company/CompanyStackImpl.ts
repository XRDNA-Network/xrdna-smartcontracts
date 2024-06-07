import { ethers, ignition } from "hardhat";
import { IBasicDeployArgs, IDeployable } from "../IDeployable";
import { CompanyFactory, ICreateCompanyArgs } from "../../../src/company/CompanyFactory";
import { CompanyRegistry } from "../../../src/company/CompanyRegistry";
import { ICompanyStack, ICreateCompanyRequest } from "./ICompanyStack";
import { StackCreatorFn, StackType } from "../StackFactory";
import { WorldRegistry } from "../../../src";
import { IWorldStack } from "../world/IWorldStack";
import { CompanyConstructorArgsStruct } from "../../../typechain-types/contracts/company/Company.sol/Company";
import { Company } from "../../../src/company/Company";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { HardhatTestKeys } from "../../HardhatTestKeys";
import CompanyFactoryModule from "../../../ignition/modules/company/CompanyFactory.module";
import CompanyRegistryModule from "../../../ignition/modules/company/CompanyRegistry.module";
import CompanyModule from "../../../ignition/modules/company/Company.module";


export interface ICompanyStackArgs extends IBasicDeployArgs{
    
    
}


export class CompanyStackImpl implements ICompanyStack, IDeployable {
    companyFactory!: CompanyFactory;
    companyFactoryAddress!: string;
    companyRegistry!: CompanyRegistry;
    companyRegistryAddress!: string;
    companies: Map<string, any> = new Map();
    masterCompanyAddress!: string;
    
    constructor(readonly factory: StackCreatorFn) {
        
        
    }
    getCompanyFactory(): CompanyFactory {
        this._checkDeployed();
        return this.companyFactory;
    }

    getCompanyRegistry(): CompanyRegistry {
        this._checkDeployed();
        return this.companyRegistry;
    }

    async deploy(args: ICompanyStackArgs): Promise<void> {
        await this._deployFactory(args);
        await this._deployRegistry(args);
        await this._deployMasterCompany();
    }

    _checkDeployed() {
        if (!this.companyFactory || !this.companyRegistry || !this.masterCompanyAddress) {
            throw new Error("CompanyStack not deployed");
        }
    }

    async createCompany(req: ICreateCompanyRequest): Promise<Company> {
        this._checkDeployed();
        const world = req.world;
        
        const companyRegResult = await world.registerCompany({
            owner: req.owner,
            initData: req.initData,
            name: req.name
        });

        const company = new Company({
            address: companyRegResult.company.toString(),
            admin: await ethers.getImpersonatedSigner(req.owner)
        });
        
        this.companies.set(company.address, company);
        return company;
        
    }

    async _deployFactory(args: ICompanyStackArgs) {
        if(this.companyFactory) {
            return;
        }
        const {companyFactory} = await ignition.deploy(CompanyFactoryModule);
        const address  = await companyFactory.getAddress();

        this.companyFactory = new CompanyFactory({
            address,
            admin: args.admin
        });
    }

    async _deployRegistry(args: ICompanyStackArgs) {
        if(this.companyRegistry) {
            return;
        }
        const {companyRegistry} = await ignition.deploy(CompanyRegistryModule);
        const address = await companyRegistry.getAddress();
        this.companyRegistry = new CompanyRegistry({
            address,
            admin: args.admin
        });

        await this.companyFactory.setAuthorizedRegistry(address);

    }

    async _deployMasterCompany() {

        const {companyMasterCopy} = await ignition.deploy(CompanyModule);
        this.masterCompanyAddress = await companyMasterCopy.getAddress();
        await this.companyFactory.setImplementation(this.masterCompanyAddress);
        
    }
}