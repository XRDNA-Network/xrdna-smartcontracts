import { AddressLike, Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../../artifacts/contracts/asset/erc20/ERC20AssetFactory.sol/ERC20AssetFactory.json";
import { RPCRetryHandler } from "../../RPCRetryHandler";

export interface IERC20AssetFactoryOpts {
    admin: Provider | Signer;
    address: string;
}

export class ERC20AssetFactory {
    private admin: Provider | Signer;
    readonly address: string;
    private con: Contract;
    constructor(opts: IERC20AssetFactoryOpts) {
        this.admin = opts.admin;
        this.address = opts.address;
        this.con = new Contract(this.address, abi, this.admin);
    }

    async setImplementation(impl: AddressLike): Promise<TransactionResponse> {
       return await RPCRetryHandler.withRetry(()=>this.con.setERC20Implementation(impl));
    }

    async setAuthorizedRegistry(registry: AddressLike): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(()=>this.con.setAuthorizedRegistry(registry));
    }

}