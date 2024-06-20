import { Provider, Signer, TransactionResponse, ethers } from "ethers";
import {abi as RegistrarRegistryABI} from "../../artifacts/contracts/registrar/RegistrarRegistry.sol/RegistrarRegistry.json";
import { LogParser } from "../LogParser";
import { LogNames } from "../LogNames";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { AllLogParser } from "../AllLogParser";
import { RegistrationTerms } from "../RegistrationTerms";

/**
 * Typescript proxy for RegistrarRegistry deployed contract.
 */
export interface IRegistrarRegistryOpts {
    address: string;
    admin: Provider | Signer;
    logParser: AllLogParser;
}

export interface IRegisterProps {
    owner: string;
    name: string;
    sendTokensToRegistrarOwner: boolean;
    worldRegistrationTerms: RegistrationTerms;
    tokens?: bigint;
}

export interface IRegistrationResult {
    receipt: ethers.TransactionReceipt;
    registrarAddress: string;
}

export class RegistrarRegistry {
    static get abi() {
        return RegistrarRegistryABI;
    }
    
    readonly address: string;
    private admin: Provider | Signer;
    private registry: ethers.Contract;
    private logParser: AllLogParser;

    constructor(opts: IRegistrarRegistryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.registry = new ethers.Contract(this.address, RegistrarRegistryABI, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, RegistrarRegistryABI);
    }

    async registerRegistrar(props: IRegisterProps): Promise<IRegistrationResult> {
        if(!this.registry) {
            throw new Error("Registry not deployed");
        }
        const {tokens} = props;
        const args = {
            owner: props.owner,
            name: props.name,
            sendTokensToOwner: props.sendTokensToRegistrarOwner,
            worldRegistrationTerms: props.worldRegistrationTerms
        };
        const t = await RPCRetryHandler.withRetry(() =>this.registry.register(args, {
            value: tokens
        }));
        const r = await t.wait();
        
        const logMap = this.logParser.parseLogs(r);
        
        const adds = logMap.get(LogNames.RegistryAddedRegistrar);
        if(!adds || adds.length === 0) {
            throw new Error("Registrar not added");
        }
        const addr = adds[0].args[0];
        return {receipt: r, registrarAddress: addr};
    }
    
}

