import { ethers } from "hardhat";
import { IBasicDeployArgs, IDeployable } from "../IDeployable";
import { CompanyFactory } from "../../../src/company/CompanyFactory";
import { CompanyRegistry } from "../../../src/company/CompanyRegistry";
import { ICompanyStack } from "./ICompanyStack";
import { StackCreatorFn, StackType } from "../StackFactory";
import { WorldRegistry } from "../../../src";
import { IWorldStack } from "../world/IWorldStack";
import { CompanyConstructorArgsStruct } from "../../../typechain-types/contracts/company/Company.sol/Company";
import { Company } from "../../../src/company/Company";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { HardhatTestKeys } from "../../HardhatTestKeys";


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

    async createCompany(): Promise<Company> {
        this._checkDeployed();
        const worldStack = this.factory(StackType.WORLD) as IWorldStack;
        const world = worldStack.createWorld();
        const owner = await ethers.getImpersonatedSigner(HardhatTestKeys[10].address)
        const companyRegResult = await world.registerCompany({
            owner: await owner.getAddress(),
            initData: "",
            name: "Test Company"
        });

        const company = new Company({
            address: companyRegResult.company.toString(),
            admin: owner
        });
        
        this.companies.set(company.address, company);
        return company;
        
    }

    async _deployFactory(args: ICompanyStackArgs) {
        if(this.companyFactory) {
            return;
        }
        const Factory = await ethers.getContractFactory("CompanyFactory");
        const factory = await Factory.deploy(args.admin.getAddress(), [args.admin.getAddress()]);
        const t = await factory.deploymentTransaction()?.wait();
        this.companyFactoryAddress = t?.contractAddress || "";
        this.companyFactory = new CompanyFactory({
            address: this.companyFactoryAddress,
            admin: args.admin
        });
    }

    async _deployRegistry(args: ICompanyStackArgs) {
        if(this.companyRegistry) {
            return;
        }
        const worldStack: IWorldStack = this.factory(StackType.WORLD)
        const Registry = await ethers.getContractFactory("CompanyRegistry");
        const registry = await Registry.deploy({
            mainAdmin: args.admin.getAddress(),
            companyFactory: this.companyFactoryAddress,
            worldRegistry: worldStack.getWorldRegistry().address,
            admins: [args.admin.getAddress()]
        
        });
        const t = await registry.deploymentTransaction()?.wait();
        this.companyRegistryAddress = t?.contractAddress || "";
        this.companyRegistry = new CompanyRegistry({
            address: this.companyRegistryAddress,
            admin: args.admin
        });

        await this.companyFactory.setAuthorizedRegistry(this.companyRegistryAddress);

    }

    async _deployMasterCompany() {

        const experienceStack = this.factory(StackType.EXPERIENCE);
        const assetStack = this.factory(StackType.ASSET);
        const avatarStack = this.factory(StackType.AVATAR);


        const cArgs: CompanyConstructorArgsStruct = {
            companyFactory: this.companyFactoryAddress,
            companyRegistry: this.companyRegistryAddress,
            experienceRegistry: experienceStack.getExperienceRegistry().address,
            assetRegistry: assetStack.getAssetRegistry().address,
            avatarRegistry: avatarStack.getAvatarRegistry().address
        }
        const Company = await ethers.getContractFactory("Company");
        const company = await Company.deploy(cArgs);
        const t = await company.deploymentTransaction()?.wait();
        const companyAddress = t?.contractAddress || "";
        await this.companyFactory.setImplementation(companyAddress);
        this.masterCompanyAddress = companyAddress;
    }



}