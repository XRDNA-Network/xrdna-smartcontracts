import { AddressLike, Provider, Signer, TransactionResponse, ethers } from "ethers";
import {abi} from "../../artifacts/contracts/registrar/Registrar.sol/Registrar.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { AllLogParser } from "../AllLogParser";
import { RegistrationTerms } from "../RegistrationTerms";
import { VectorAddress } from "../VectorAddress";
import { LogNames } from "../LogNames";

/**
 * Typescript wrapper around regstirar functionality
 */
export interface IRegistrarOpts {
    registrarAddress: string;
    admin: Provider | Signer;
    logParser: AllLogParser;
}


export interface IRegistrarInitArgs {
    owner: string;
    worldRegistrationTerms: RegistrationTerms;
}


export interface IWorldRegistration {
    sendTokensToWorldOwner: boolean;
    owner: AddressLike;
    baseVector: VectorAddress;
    name: string;
    initData: string;
    vectorAuthoritySignature: string;
    companyTerms: RegistrationTerms;
    avatarTerms: RegistrationTerms;
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

    static encodeInitArgs(args: IRegistrarInitArgs): string {
        return ethers.AbiCoder.defaultAbiCoder().encode(
            [
                "address",
                "tuple(uint256,uint256,uint256)",
            ],
            [args.owner, args.worldRegistrationTerms]
        );
    }

    constructor(opts: IRegistrarOpts) {
        this.address = opts.registrarAddress;
        this.admin = opts.admin;
        this.con = new ethers.Contract(this.address, abi, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, abi);
    }

    async addSigners(signers: string[]): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(()=>this.con.addSigners(signers));
    }

    async removeSigners(signers: string[]): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(()=>this.con.removeSigners(signers));
    }

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

}

    