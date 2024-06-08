import { ethers, ignition } from "hardhat";
import { IBasicDeployArgs, IDeployable } from "../IDeployable";
import { CompanyFactory } from "../../../src/company/CompanyFactory";
import { CompanyRegistry } from "../../../src/company/CompanyRegistry";
import { ICompanyStack, ICreateCompanyRequest } from "./ICompanyStack";
import { StackFactory, StackType } from "../StackFactory";
import { AssetType, ERC20Asset, ERC20InitData, ERC721Asset } from "../../../src";
import { Company } from "../../../src/company/Company";
import CompanyFactoryModule from "../../../ignition/modules/company/CompanyFactory.module";
import CompanyRegistryModule from "../../../ignition/modules/company/CompanyRegistry.module";
import CompanyModule from "../../../ignition/modules/company/Company.module";
import { IAssetStack, IERC20CreationRequest, IERC721CreationRequest } from "../asset/IAssetStack";
import { throwError } from "../../utils";
import { IWorldStackDeployment } from "../world/WorldStackImpl";



export class CompanyStackImpl implements ICompanyStack, IDeployable {
    
    companies: Map<string, any> = new Map();
    masterCompanyAddress!: string;
    assets: Map<bigint, any> = new Map();
    
    constructor(readonly factory: StackFactory, readonly world: IWorldStackDeployment) {  }

    getCompanyFactory(): CompanyFactory {
        return this.world.companyFactory;
    }

    getCompanyRegistry(): CompanyRegistry {
       return this.world.companyRegistry;
    }


    async createERC20Asset(request: IERC20CreationRequest): Promise<ERC20Asset> {
        const a = this.assets.get(AssetType.ERC20);
        if(a) {
            return a;
        }

        const initData: ERC20InitData = {
            issuer: request.issuer.address,
            name: request.name,
            symbol: request.symbol,
            decimals: request.decimals,
            originChainAddress: request.originalChainAddress,
            originChainId: request.originalChainId,
            totalSupply: request.totalSupply
        }
        const ar = await this.factory.getStack<IAssetStack>(StackType.ASSET);
        const t = await ar.getAssetRegistry().registerAsset(AssetType.ERC20, initData);
        const asset = new ERC20Asset({
            address: t.assetAddress.toString() || throwError("Asset contract address not found"),
            provider: ethers.provider
        });
        this.assets.set(AssetType.ERC20, asset);
        return asset;
        
    }

    async createERC721Asset(request: IERC721CreationRequest): Promise<ERC721Asset> {
        const a = this.assets.get(AssetType.ERC721);
        if(a) {
            return a;
        }
        
        const initData = {
            issuer: request.issuer.address,
            originChainAddress: request.originChainAddress,
            originChainId: request.originChainId,
            name: request.name,
            symbol: request.symbol,
            baseURI: request.baseURI
        }
        const ar = await this.factory.getStack<IAssetStack>(StackType.ASSET);
        const t = await ar.getAssetRegistry().registerAsset(AssetType.ERC721, initData);
        const asset = new ERC721Asset({
            address: t.assetAddress.toString() || throwError("Contract address not found"),
            provider: ethers.provider
        });
        this.assets.set(AssetType.ERC721, asset);
        return asset;
    }

    async deploy(): Promise<void> {
        
    }

    async createCompany(req: ICreateCompanyRequest): Promise<Company> {
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
}