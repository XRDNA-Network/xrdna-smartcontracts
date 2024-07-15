import { AddressLike, Provider, Signer, TransactionResponse, ethers } from "ethers";
import { LogNames } from "../../LogNames";
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { AllLogParser } from "../../AllLogParser";
import { RegistrationTerms } from "../../RegistrationTerms";
import {abi as ABI} from '../../../artifacts/contracts/registrar/registry/IRegistrarRegistry.sol/IRegistrarRegistry.json';
import {abi as proxyABI} from '../../../artifacts/contracts/base-types/BaseProxy.sol/BaseProxy.json';
import { BaseRemovableRegistry } from "../../base-types/registry/BaseRemovableRegistry";
import { IWrapperOpts } from "../../interfaces/IWrapperOpts";
import { Bytes } from "../../types";


export interface IRegisterRemovableArgs {
    owner: string;
    name: string;
    sendTokensToOwner: boolean;
    terms: RegistrationTerms;
    ownerTermsSignature: string;
    expiration: bigint;
    tokens?: bigint;
}

export interface IRegisterNonRemovableArgs {
    owner: string;
    name: string;
    sendTokensToOwner: boolean;
    tokens?: bigint;
}

export interface IRegistrationResult {
    receipt: ethers.TransactionReceipt;
    registrarAddress: string;
}


export interface  ChangeEntityTermsArgs {
    //the entity whose terms are changing
    entity: AddressLike;

    //signature of one of the entity's signers authorizing the change
    entitySignature: Bytes;

    //expiration for the signature
    expiration: bigint;

    //new terms
    terms: RegistrationTerms;
}

export class RegistrarRegistry extends BaseRemovableRegistry {
    static get abi() {
        return [
            ...ABI,
            ...proxyABI
        ]
    }
    
    private registry: ethers.Contract;

    constructor(opts: IWrapperOpts) {
        super(opts);
        const abi = RegistrarRegistry.abi;
        if(!abi || abi.length === 0) {
            throw new Error("Invalid ABI");
        }
        this.registry = new ethers.Contract(this.address, abi, this.admin);
        this.logParser.addAbi(this.address, abi);
    }

    getContract(): ethers.Contract {
        return this.registry;
    }

    async registerRegistrarNoRemoval(props: IRegisterNonRemovableArgs): Promise<IRegistrationResult> {
        if(!this.registry) {
            throw new Error("Registry not deployed");
        }
        
        const t = await RPCRetryHandler.withRetry(() => this.registry.createNonRemovableRegistrar({
            owner: props.owner,
            name: props.name,
            sendTokensToOwner: props.sendTokensToOwner,
            initData: "0x",
            ownerTermsSignature: "0x",
            expiration: 0n,
            terms: {
                fee: 0n,
                coveragePeriodDays: 0n,
                gracePeriodDays: 0n
            }
        }, {
            value: props.tokens
        }));
        const r = await t.wait();   
        const logMap = this.logParser.parseLogs(r);
        const adds = logMap.get(LogNames.RegistryAddedEntity);
        if(!adds || adds.length === 0) {
            throw new Error("Registrar not added");
        }
        const addr = adds[0].args[0];
        return {receipt: r, registrarAddress: addr};
    }

    async registerRemovableRegistrar(props: IRegisterRemovableArgs): Promise<IRegistrationResult> {
        if(!this.registry) {
            throw new Error("Registry not deployed");
        }
        
        const t = await RPCRetryHandler.withRetry(() => this.registry.createRemovableRegistrar({
            owner: props.owner,
            name: props.name,
            sendTokensToOwner: props.sendTokensToOwner,
            initData: "0x",
            ownerTermsSignature: props.ownerTermsSignature,
            expiration: props.expiration,
            terms: props.terms
        }, {
            value: props.tokens
        }));
        const r = await t.wait();   
        const logMap = this.logParser.parseLogs(r);
        const adds = logMap.get(LogNames.RegistryAddedEntity);
        if(!adds || adds.length === 0) {
            throw new Error("Registrar not added");
        }
        const addr = adds[0].args[0];
        return {receipt: r, registrarAddress: addr};
    }

    async withdraw(amount: bigint): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.registry.withdraw(amount));
    }

     /**
     * Change the terms for an entity. Can only be called by the entity's terms owner.
     */
     async changeEntityTerms(args: ChangeEntityTermsArgs): Promise<TransactionResponse>{
        return RPCRetryHandler.withRetry(() => this.getContract().changeEntityTerms(args));
    }
}

