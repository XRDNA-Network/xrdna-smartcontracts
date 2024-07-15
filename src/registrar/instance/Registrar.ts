import { AddressLike, Provider, Signer, TransactionResponse, ethers } from "ethers";
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { AllLogParser } from "../../AllLogParser";
import { RegistrationTerms } from "../../RegistrationTerms";
import { VectorAddress } from "../../VectorAddress";
import { LogNames } from "../../LogNames";
import {abi as ABI} from '../../../artifacts/contracts/registrar/instance/IRegistrar.sol/IRegistrar.json';
import {abi as proxyABI} from '../../../artifacts/contracts/base-types/entity/IEntityProxy.sol/IEntityProxy.json';
import { BaseRemovableEntity } from "../../base-types/entity/BaseRemovableEntity";
import { IWrapperOpts } from "../../interfaces/IWrapperOpts";


export interface IWorldRegistration {
    sendTokensToOwner: boolean;
    owner: AddressLike;
    baseVector: VectorAddress;
    terms: RegistrationTerms;
    ownerTermsSignature: string;
    expiration: bigint;
    name: string;
    vectorAuthoritySignature: string;
    tokens?: bigint;
}

export interface IWorldRegistrationResult {
    receipt: ethers.TransactionReceipt;
    worldAddress: string;
}

export class Registrar extends BaseRemovableEntity {
    private con: ethers.Contract;

    static get abi() {
        return [
            ...ABI,
            ...proxyABI
        ]
    }
    

    constructor(opts: IWrapperOpts) {
        super(opts);
        const abi = Registrar.abi;
        if(!abi || abi.length === 0) {
            throw new Error("ABI not found");
        }
        this.con = new ethers.Contract(this.address, abi, this.admin);
        this.logParser.addAbi(this.address.toLowerCase(), abi);
    }

    getContract(): ethers.Contract {
        return this.con;
    }

    async registerWorld(args: IWorldRegistration): Promise<IWorldRegistrationResult> {
        const {sendTokensToOwner, owner, baseVector, terms, ownerTermsSignature, expiration, name, vectorAuthoritySignature, tokens} = args;
       
        const t = await RPCRetryHandler.withRetry(() => this.con.registerWorld({
            sendTokensToOwner,
            owner,
            baseVector,
            name,
            initData: "0x",
            vectorAuthoritySignature,
            ownerTermsSignature,
            expiration,
            terms
        }, {
            value: tokens
        }));
        const r = await t.wait();
        const logs = this.logParser.parseLogs(r);
        const adds = logs.get(LogNames.RegistryAddedEntity);
        if(!adds || adds.length === 0) {
            throw new Error("World not created");
        }
        const addr = adds[0].args[0];
        return {receipt: r, worldAddress: addr};
    }

    async deactivateWorld(world: AddressLike, reason: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.deactivateWorld(world, reason));
    }

    /**
     * Reactivates a world contract. Must be called by a registrar signer
     */
    async reactivateWorld(world:AddressLike): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.reactivateWorld(world));
    }

    /**
     * Removes a world contract. Must be called by a registrar signer
     */
    async removeWorld(world: AddressLike, reason: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeWorld(world, reason));
    }


    async withdraw(amount: bigint): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.withdraw(amount));
    }

}

    