import { Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/company/CompanyRegistry.sol/CompanyRegistry.json";
import { RPCRetryHandler } from "../RPCRetryHandler";

export interface ICompanyRegistryOpts {
    address: string;
    admin: Provider | Signer;
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

    async upgradeCompany(initData: string): Promise<TransactionResponse>{
        return await RPCRetryHandler.withRetry(() => this.con.upgradeCompany(initData));
    }
}