import { Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/company/CompanyFactory.sol/CompanyFactory.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";

export interface ICompanyFactoryOpts {
    address: string;
    admin: Provider | Signer;
}

export interface ICreateCompanyArgs {
    owner: string;
    world: string
    vector: VectorAddress;
    initData: string;
    name: string;
}

export class CompanyFactory {
    private con: Contract;
    private address: string;
    private admin: Provider | Signer;

    constructor(opts: ICompanyFactoryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.con = new Contract(this.address, abi, this.admin);
    }

    async createCompany(req: ICreateCompanyArgs): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.createCompany(req.owner, req.world, req.vector, req.initData, req.name));
    }
}