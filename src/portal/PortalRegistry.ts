import { Contract, Provider, Signer, TransactionResponse } from "ethers";
import {abi} from "../../artifacts/contracts/portal/PortalRegistry.sol/PortalRegistry.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";


export interface IPortalRegistryOpts {
    address: string;
    admin: Provider | Signer;
}

export interface IAddPortalRequest {
    destination: string
    fee: string
}

export interface IPortalInfo {
    destination: string
    condition: string
    fee: string
}

export class PortalRegistry {
    private con: Contract;
    private address: string;
    private admin: Provider | Signer;

    constructor(opts: IPortalRegistryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.con = new Contract(this.address, abi, this.admin);
    }

    async setExperienceRegistry(registry: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setExperienceRegistry(registry));
    }

    async setAvatarRegistry(registry: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setAvatarRegistry(registry));
    }

   async getPortalInfoById(id: string): Promise<IPortalInfo> {
        return await RPCRetryHandler.withRetry(() => this.con.getPortalInfoById(id));
    }

    async getPortalInfoByAddress(addr: string): Promise<IPortalInfo> {
        return await RPCRetryHandler.withRetry(() => this.con.getPortalInfoByAddress(addr));
    }

    async getPortalInfoByVectorAddress(vector: VectorAddress): Promise<IPortalInfo> {
        return await RPCRetryHandler.withRetry(() => this.con.getPortalInfoByVectorAddress(vector));
    }

    async getIdForExperience(experience: string): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.getIdForExperience(experience));
    }

    async getIdForVectorAddress(vector: VectorAddress): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.getIdForVectorAddress(vector));
    }
 
    async addPortal(req: IAddPortalRequest): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.addPortal(req));
    }

    async jumpRequest(portalId: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.jumpRequest(portalId));
    }

    async addCondition(condition: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.addCondition(condition));
    }

    async removeCondition(): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeCondition());
    }

    async changePortalFee(newFee: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.changePortalFee(newFee));
    }

    async upgradeRegistry(newRegistry: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.upgradeRegistry(newRegistry));
    }

}