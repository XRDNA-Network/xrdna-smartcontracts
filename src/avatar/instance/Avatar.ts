import { AddressLike, Provider, Signer, TransactionReceipt, TransactionResponse, ethers } from "ethers";
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { VectorAddress } from "../../VectorAddress";
import { AllLogParser } from "../../AllLogParser";
import { Version } from "../../Version";
import {abi as cABI} from '../../../artifacts/contracts/avatar/instance/IAvatar.sol/IAvatar.json';
import { RegistrationTerms } from "../../RegistrationTerms";
import { LogNames } from "../../LogNames";
import { ERC721Asset } from "../../asset";

export interface IAvatarOpts {
    address: string;
    admin: Signer | Provider;
    logParser: AllLogParser;
}


export interface IAvatarJumpRequest {
    portalId: bigint
    agreedFee: bigint,
    destinationCompanySignature: string,
}

export interface IAvatarJumpResult {
    receipt: TransactionReceipt;
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
        return  cABI
    }
    
    readonly address: string;
    readonly admin: Provider | Signer;
    private con: ethers.Contract;
    readonly logParser: AllLogParser;

    constructor(opts: IAvatarOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        const abi = Avatar.abi;
        if(!abi || abi.length === 0) {
            throw new Error("Invalid ABI");
        }
        this.con = new ethers.Contract(this.address, abi, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, abi);
    }

    async owner(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.owner());
    }

    async addSigners(signers: string[]): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.addSigners(signers));
    }

    async removeSigners(signers: string[]): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeSigners(signers));
    }

    async isSigner(address: string): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isSigner(address));
    }

    async getVectorAddress(): Promise<VectorAddress> {
        return await RPCRetryHandler.withRetry(() => this.con.getBaseVector());
    }

    async getName(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.name());
    }

    async withdraw(amount: bigint): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.withdraw(amount));
    }

    async addFunds(amount: bigint): Promise<TransactionResponse> {
        if(!this.admin || !this.admin.sendTransaction) {
            throw new Error("Cannot add funds without an admin signer");
        }
        return await RPCRetryHandler.withRetry(() => this.admin.sendTransaction!({
            to: this.address,
            value: amount
        }));
    }

    async getBalance(): Promise<bigint> {
        const p: Provider = this.admin.provider || this.admin as Provider;
        if(!p) {
            throw new Error("Cannot get balance without a provider");
        }
        return await RPCRetryHandler.withRetry(() => p.getBalance(this.address));
    }

    async version(): Promise<Version> {
        const r = await RPCRetryHandler.withRetry(() => this.con.version());
        return {
            major: r[0],
            minor: r[1],
        } as Version;
    }

    async location(): Promise<AddressLike> {
        return await RPCRetryHandler.withRetry(() => this.con.location());
    }

    async setCanReceiveTokensOutsideOfExperience(canReceive: boolean): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setCanReceiveTokensOutsideOfExperience(canReceive));
    }

    async canReceiveTokensOutsideOfExperience(): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.canReceiveTokensOutsideOfExperience());
    }

    async setAppearanceDetails(bytes: string) : Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setAppearanceDetails(bytes));
    }

    async appearanceDetails(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.appearanceDetails());
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

    async canAddWearable(wearable: IWearable): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.canAddWearable(wearable));
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

    async getWearableURI(wearable: IWearable): Promise<string> {
        const p = this.admin.provider || this.admin as Provider;
        if(!p) {
            throw new Error("No provider available to get URI with");
        }

        const erc721 = new ERC721Asset({
            address: wearable.asset.toString(),
            provider: p,
            logParser: this.logParser
        });
        return await erc721.tokenURI(wearable.tokenId);
    }

    async getCompanySigningNonce(company: string): Promise<bigint> {
        return await RPCRetryHandler.withRetry(() => this.con.companySigningNonce(company));
    }

    async getAvatarSigningNonce(): Promise<bigint> {
        return await RPCRetryHandler.withRetry(() => this.con.avatarOwnerSigningNonce());
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
            connectionDetails: jump[0].args[2].toString(),
            fee: jump[0].args[1],
            destination: jump[0].args[0],
            receipt: r
        } as IAvatarJumpResult;

    }
}