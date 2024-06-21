import { ethers } from "hardhat";
import { IDeployable } from "../IDeployable";
import { CompanyFactory } from "../../../src/company/CompanyFactory";
import { CompanyRegistry } from "../../../src/company/CompanyRegistry";
import { ICompanyStack, ICreateCompanyRequest, IERC20CreationRequest, IERC721CreationRequest } from "./ICompanyStack";
import { StackFactory, StackType } from "../StackFactory";
import { ERC20Asset, ERC20InitData, ERC721Asset } from "../../../src";
import { Company } from "../../../src/company/Company";
import { throwError } from "../../utils";
import { IWorldStackDeployment } from "../world/WorldStackImpl";
import { IERC20AssetStack } from "../asset/erc20/IERC20AssetStack";
import { IERC721AssetStack } from "../asset/erc721/IERC721AssetStack";


const AssetType = {
    ERC20: 1n,
    ERC721: 2n
}

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
            issuer: request.issuer,
            name: request.name,
            symbol: request.symbol,
            decimals: request.decimals,
            originChainAddress: request.originChainAddress,
            originChainId: request.originChainId,
            totalSupply: request.totalSupply
        }
        const ar = await this.factory.getStack<IERC20AssetStack>(StackType.ERC20);
        const t = await ar.getERC20Registry().registerAsset(initData);
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
            issuer: request.issuer,
            originChainAddress: request.originChainAddress,
            originChainId: request.originChainId,
            name: request.name,
            symbol: request.symbol,
            baseURI: request.baseURI
        }
        const ar = await this.factory.getStack<IERC721AssetStack>(StackType.ERC721);
        const t = await ar.getERC721Registry().registerAsset(initData);
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
            name: req.name,
            sendTokensToCompanyOwner: req.sendTokensToCompanyOwner
        });

        const company = new Company({
            address: companyRegResult.companyAddress.toString(),
            admin: await ethers.getImpersonatedSigner(req.owner)
        });
        
        this.companies.set(company.address, company);
        return company;
        
    }
}