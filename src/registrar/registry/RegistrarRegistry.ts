import { Provider, Signer, TransactionResponse, ethers } from "ethers";
import { LogNames } from "../../LogNames";
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { AllLogParser } from "../../AllLogParser";
import { RegistrationTerms } from "../../RegistrationTerms";
import {abi as ABI} from '../../../artifacts/contracts/registrar/registry/IRegistrarRegistry.sol/IRegistrarRegistry.json';
import {abi as proxyABI} from '../../../artifacts/contracts/base-types/BaseProxy.sol/BaseProxy.json';

/**
 * Typescript proxy for RegistrarRegistry deployed contract.
 */
export interface IRegistrarRegistryOpts {
    address: string;
    admin: Provider | Signer;
    logParser: AllLogParser;
}

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

export class RegistrarRegistry {
    static get abi() {
        return [
            ...ABI,
            ...proxyABI
        ]
    }
    
    readonly address: string;
    private admin: Provider | Signer;
    private registry: ethers.Contract;
    private logParser: AllLogParser;

    constructor(opts: IRegistrarRegistryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        const abi = RegistrarRegistry.abi;
        if(!abi || abi.length === 0) {
            throw new Error("Invalid ABI");
        }
        this.registry = new ethers.Contract(this.address, abi, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, abi);
    }

    async registerRegistrarNoRemoval(props: IRegisterNonRemovableArgs): Promise<IRegistrationResult> {
        if(!this.registry) {
            throw new Error("Registry not deployed");
        }
        
        const t = await RPCRetryHandler.withRetry(() => this.registry.createRegistrarNoRemoval({
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

    async getEntityTerms(entity: string): Promise<RegistrationTerms> {
        if(!this.registry) {
            throw new Error("Registry not deployed");
        }
        const terms = await RPCRetryHandler.withRetry(() => this.registry.getEntityTerms(entity));
        return {
            coveragePeriodDays: terms[0],
            gracePeriodDays: terms[1],
            fee: terms[2]
        } as RegistrationTerms;
    }

    async setTerms(terms: RegistrationTerms): Promise<TransactionResponse> {
        if(!this.registry) {
            throw new Error("Registry not deployed");
        }
        return await RPCRetryHandler.withRetry(() => this.registry.setTerms(terms));
    }

    async getTerms(): Promise<RegistrationTerms> {
        if(!this.registry) {
            throw new Error("Registry not deployed");
        }
        const terms = await RPCRetryHandler.withRetry(() => this.registry.getTerms());
        return {
            coveragePeriodDays: terms[0],
            gracePeriodDays: terms[1],
            fee: terms[2]
        } as RegistrationTerms;
    }

    async isSigner(signer: string): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.registry.isSigner(signer) );
    }
    
    async addSigners(signers: string[]): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.registry.addSigners(signers));
    }

    async owner(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.registry.owner());
    }

    async removeSigners(signers: string[]): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.registry.removeSigners(signers));
    }
}

