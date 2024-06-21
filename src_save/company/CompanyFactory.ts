import { Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/company/CompanyFactory.sol/CompanyFactory.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";
import { AllLogParser } from "../AllLogParser";

export interface ICompanyFactoryOpts {
    address: string;
    admin: Provider | Signer;
    logParser: AllLogParser;
}

export interface ICreateCompanyArgs {
    owner: string;
    world: string
    vector: VectorAddress;
    initData: string;
    name: string;
}

export class CompanyFactory {
    static get abi() {
        return abi;
    }
    
    private con: Contract;
    private address: string;
    private admin: Provider | Signer;
    readonly logParser: AllLogParser;

    constructor(opts: ICompanyFactoryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.con = new Contract(this.address, abi, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, abi);
    }

    async createCompany(req: ICreateCompanyArgs): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.createCompany(req.owner, req.world, req.vector, req.initData, req.name));
    }

    async setAuthorizedRegistry(registry: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setAuthorizedRegistry(registry));
    }

    async setImplementation(impl: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setImplementation(impl));
    }
}