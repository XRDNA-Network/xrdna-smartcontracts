import { AddressLike, Contract, Provider, Signer, TransactionResponse, ethers } from "ethers";
import {abi} from "../../artifacts/contracts/avatar/Avatar.sol/Avatar.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";
import { LogParser } from "../LogParser";
import { LogNames } from "../LogNames";
import { AllLogParser } from "../AllLogParser";


export interface IAvatarOpts {
    address: string;
    admin: Provider | Signer;
    logParser: AllLogParser;
}

export interface IAvatarJumpRequest {
    portalId: bigint
    agreedFee: bigint,
    destinationCompanySignature: string,
}

export interface IAvatarJumpResult {
    receipt: TransactionResponse;
    destination: AddressLike;
    connectionDetails: string;
    fee: bigint;
}

export interface IWearable  {
    asset: AddressLike;
    tokenId: bigint;
}

export interface IAvatarInitData {
    canReceiveTokensOutsideOfExperience: boolean;
    appearanceDetails: string;
}

export class Avatar {
    static get abi() {
        return abi;
    }
    
    private con: Contract;
    readonly address: string;
    private admin: Provider | Signer;
    readonly logParser: AllLogParser;

    constructor(opts: IAvatarOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.con = new Contract(this.address, abi, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, abi);
    }

    static encodeInitData(data: IAvatarInitData): string {
        const ifc = new ethers.Interface(abi);
        return `0x${ifc.encodeFunctionData("encodeInitData", [data]).substring(10)}`;
    }

    async location(): Promise<AddressLike> {
        return await RPCRetryHandler.withRetry(() => this.con.location());
    }

    async getWearables(): Promise<IWearable[]> {
        const r = await RPCRetryHandler.withRetry(() => this.con.getWearables());
        return r.map((w: any) => {
            return {
                asset: w[0],
                tokenId: w[1]
            } as IWearable;
        });
    }

    async setCanReceiveTokensOutsideOfExperience(canReceive: boolean): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setCanReceiveTokensOutsideOfExperience(canReceive));
    }

    async setLocation(location: VectorAddress): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setLocation(location));
    }

    async setAppearanceDetails(bytes: string) : Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setAppearanceDetails(bytes));
    }

    async jump(req: IAvatarJumpRequest, tokens?: bigint): Promise<IAvatarJumpResult> {
        const t =  await RPCRetryHandler.withRetry(() => this.con.jump(req, {
            value: tokens
        }));
        const r = await t.wait();
        if(!r.status) {
            throw new Error("Jump transaction failed with status 0");
        }
        const logs = this.logParser.parseLogs(r);
        const jump = logs.get(LogNames.JumpSuccess);
        if(!jump || jump.length === 0) {
            throw new Error("Jump failed");
        }
        return {
            connectionDetails: jump[0].args[2],
            fee: jump[0].args[1],
            destination: jump[0].args[0],
            receipt: r
        } as IAvatarJumpResult;

    }

    async addWearable(wearable: IWearable): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.addWearable(wearable));
    }

    async removeWearable(wearable: IWearable): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeWearable(wearable));
    }

    async isWearing(wearable: IWearable): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isWearing(wearable));
    }

    async addSigner(signer: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.addSigner(signer));
    }

    async removeSigner(signer: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeSigner(signer));
    }

    async setHook(hook: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setHook(hook));
    }

    async removeHook(): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeHook());
    }

    async withdraw(amount: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.withdraw(amount));
    }

    async upgrade(newVersion: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.upgrade(newVersion));
    }

    async getCompanySigningNonce(company: string): Promise<bigint> {
        return await RPCRetryHandler.withRetry(() => this.con.companySigningNonce(company));
    }

    async getAvatarSigningNonce(): Promise<bigint> {
        return await RPCRetryHandler.withRetry(() => this.con.avatarOwnerSigningNonce());
    }

    async tokenBalance(): Promise<bigint> {
        return await RPCRetryHandler.withRetry(() => this.admin.provider!.getBalance(this.address));
    }

    async signJumpRequest(props: {
        nonce: bigint;
        portalId: bigint;
        fee: bigint;
    }): Promise<string> {
        const enc = ethers.AbiCoder.defaultAbiCoder().encode(["uint256", "uint256", "uint256"], [props.portalId, props.fee, props.nonce]);
        const hashed = ethers.keccak256(enc);
        return await RPCRetryHandler.withRetry(() => (this.admin as Signer).signMessage(ethers.getBytes(hashed)));
    }

    getDelegateContract(props: {signer: Signer}): Contract {
        return new Contract(this.address, abi, props.signer);
    }
}