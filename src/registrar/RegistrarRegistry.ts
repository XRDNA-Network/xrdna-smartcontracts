import { Provider, Signer, ethers } from "ethers";
import {abi as RegistrarRegistryABI} from "../../artifacts/contracts/RegistrarRegistry.sol/RegistrarRegistry.json";
import { LogParser } from "../LogParser";

/**
 * Typescript proxy for RegistrarRegistry deployed contract.
 */
export interface IRegistrarRegistryOpts {
    address: string;
    admin: Provider | Signer;
}

export interface IRegisterProps {
    defaultSigner: string;
    tokens?: bigint;
}

export interface IRegistrationResult {
    receipt: ethers.TransactionReceipt;
    registrarId: bigint;
}

export class RegistrarRegistry {
    private address: string;
    private admin: Provider | Signer;
    private registry: ethers.Contract;
    private logParser: LogParser;

    constructor(opts: IRegistrarRegistryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.registry = new ethers.Contract(this.address, RegistrarRegistryABI, this.admin);
        this.logParser = new LogParser(RegistrarRegistryABI, this.address);
    }

    async registerRegistrar(props: IRegisterProps): Promise<IRegistrationResult> {
        if(!this.registry) {
            throw new Error("Registry not deployed");
        }
        const {defaultSigner, tokens} = props;

        const t = await this.registry.register(defaultSigner, {
            value: tokens
        });
        const r = await t.wait();
        const logMap = this.logParser.parseLogs(r);
        const args = logMap.get("RegistrarAdded");
        if(!args) {
            throw new Error("Registrar not added");
        }
        const id = args[0];
        return {receipt: r, registrarId: id};
    }

    

    async isSignerForRegistrar(props: {
        registrarId: bigint, signer: string
    }): Promise<boolean> {
        if(!this.registry) {
            throw new Error("Registry not deployed");
        }
        const {registrarId, signer} = props;
        const r = await this.registry.isRegistrar(registrarId, signer);
        return r;
    }

    
}

