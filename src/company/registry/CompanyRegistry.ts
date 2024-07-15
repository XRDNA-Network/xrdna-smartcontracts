import { Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../../artifacts/contracts/company/registry/ICompanyRegistry.sol/ICompanyRegistry.json";
import {abi as proxyABI} from '../../../artifacts/contracts/base-types/BaseProxy.sol/BaseProxy.json';
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { AllLogParser } from "../../AllLogParser";
import { BaseVectoredRegistry } from "../../base-types/registry/BaseVectoredRegistry";
import { IWrapperOpts } from "../../interfaces/IWrapperOpts";


export class CompanyRegistry extends BaseVectoredRegistry {
    static get abi() {
        return [
            ...abi,
            ...proxyABI
        ]
    }
    
    private con: Contract;

    constructor(opts: IWrapperOpts) {
        super(opts);
        const abi = CompanyRegistry.abi;
        if(!abi || abi.length === 0) {
            throw new Error("Invalid ABI");
        }
        this.con = new Contract(this.address, abi, this.admin);
        this.logParser.addAbi(this.address, abi);
    }

    getContract(): Contract {
        return this.con;
    }

    async isRegisteredCompany(company: string): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isRegistered(company));
    }

}