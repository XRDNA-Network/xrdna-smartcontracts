import { Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/company/CompanyRegistry.sol/CompanyRegistry.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";

export interface ICompanyRegistryOpts {
    address: string;
    admin: Provider | Signer;
}

export interface ICompanyRegistrationRequest {
    owner: string;
    vector: VectorAddress;
    initData: string;
    name: string;
}

export class CompanyRegistry {
    private con: Contract;
    private address: string;
    private admin: Provider | Signer;

    constructor(opts: ICompanyRegistryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.con = new Contract(this.address, abi, this.admin);
    }

    async setCompanyFactory(factory: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setCompanyFactory(factory));
    }

    async setWorldRegistry(registry: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setWorldRegistry(registry));
    }

    async isRegisteredCompany(company: string): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isRegisteredCompany(company));
    }

    async registerCompany(req: ICompanyRegistrationRequest): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.registerCompany(req.owner, req.vector, req.initData, req.name));
    }

    async upgradeCompany(initData: string): Promise<TransactionResponse>{
        return await RPCRetryHandler.withRetry(() => this.con.upgradeCompany(initData));
    }
}