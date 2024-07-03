import { Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../../artifacts/contracts/company/registry/ICompanyRegistry.sol/ICompanyRegistry.json";
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { AllLogParser } from "../../AllLogParser";

export interface ICompanyRegistryOpts {
    address: string;
    admin: Provider | Signer;
    logParser: AllLogParser;
}

export class CompanyRegistry {
    static get abi() {
        return abi;
    }
    
    private con: Contract;
    private address: string;
    private admin: Provider | Signer;
    readonly logParser: AllLogParser;

    constructor(opts: ICompanyRegistryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        const abi = CompanyRegistry.abi;
        if(!abi || abi.length === 0) {
            throw new Error("Invalid ABI");
        }
        this.con = new Contract(this.address, abi, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, abi);
    }

    async isRegisteredCompany(company: string): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isRegistered(company));
    }

}