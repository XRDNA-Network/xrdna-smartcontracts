import { AddressLike, Provider, Signer, TransactionResponse, ethers } from "ethers";
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { AllLogParser } from "../../AllLogParser";
import { RegistrationTerms } from "../../RegistrationTerms";
import { VectorAddress } from "../../VectorAddress";
import { LogNames } from "../../LogNames";
import {abi as ABI} from '../../../artifacts/contracts/registrar/instance/IRegistrar.sol/IRegistrar.json';


/**
 * Typescript wrapper around regstirar functionality
 */
export interface IRegistrarOpts {
    registrarAddress: string;
    admin: Provider | Signer;
    logParser: AllLogParser;
}


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

export class Registrar {
    readonly address: string;
    private admin: Provider | Signer;
    private con: ethers.Contract;
    readonly logParser: AllLogParser;

    static encodeInitData(args: RegistrationTerms): string {
        return ethers.AbiCoder.defaultAbiCoder().encode(
            [
                "tuple(uint256 fee,uint256 coveragePeriodDays,uint256 gracePeriodDays)",
            ],
            [args]
        );
    }

    static get abi() {
        return ABI;
    }
    

    constructor(opts: IRegistrarOpts) {
        this.address = opts.registrarAddress;
        this.admin = opts.admin;
        const abi = Registrar.abi;
        if(!abi || abi.length === 0) {
            throw new Error("ABI not found");
        }
        this.con = new ethers.Contract(this.address, abi, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address.toLowerCase(), abi);
    }

    async addSigners(signers: string[]): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(()=>this.con.addSigners(signers));
    }

    async removeSigners(signers: string[]): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(()=>this.con.removeSigners(signers));
    }

    async isSigner(signer: string): Promise<boolean> {
        return await RPCRetryHandler.withRetry(()=>this.con.isSigner(signer));
    }

    async owner(): Promise<string> {
        return await RPCRetryHandler.withRetry(()=>this.con.owner());
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

    /*
    async registerWorld(props: {
        details: IWorldRegistration,
        tokens?: bigint
    }): Promise<IWorldRegistrationResult> {
        

        const {details} = props;
        
        
        const t = await RPCRetryHandler.withRetry(() => this.con.registerWorld(details, {
            value: props.tokens
        }));

        const r = await t.wait();
        const logs = this.logParser.parseLogs(r);
        const adds = logs.get(LogNames.WorldRegistered);
        if(!adds || adds.length === 0) {
            throw new Error("World not created");
        }
        const addr = adds[0].args[0];
        return {receipt: r, worldAddress: addr};
    }
        */

}

    