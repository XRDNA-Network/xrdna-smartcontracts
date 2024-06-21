import { AddressLike, Contract, Provider, Signer, TransactionReceipt, TransactionResponse, ethers } from "ethers";
import {abi} from "../../artifacts/contracts/avatar/Avatar.sol/Avatar.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { LogNames } from "../LogNames";
import { AllLogParser } from "../AllLogParser";
import { ISupportsFunds, ISupportsHooks, IUpgradeResult, IUpgradeable } from "../interfaces";
import { ERC721Asset } from "../asset";


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

export class Avatar implements ISupportsFunds, ISupportsHooks, IUpgradeable {

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

    ////////////////////////////////////////////////////////////////////////
    // Wearables related methods
    ////////////////////////////////////////////////////////////////////////
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


    ////////////////////////////////////////////////////////////////////////
    // ISupportsHooks interface
    ////////////////////////////////////////////////////////////////////////
    async setHook(hook: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setHook(hook));
    }

    async removeHook(): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeHook());
    }

    async getHook(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.hook());
    }


    ////////////////////////////////////////////////////////////////////////
    // ISupportsFunds interface
    ////////////////////////////////////////////////////////////////////////
    async withdraw(amount: bigint): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.withdraw(amount));
    }

    async addFunds(amount: bigint): Promise<TransactionResponse> {
        if(!this.admin.sendTransaction) {
            throw new Error("Admin must be a signer");
        }
        return await RPCRetryHandler.withRetry(() => this.admin.sendTransaction!({
            to: this.address,
            value: amount
        }));
    }

    async getBalance(): Promise<bigint> {
        const p = this.admin.provider || this.admin as Provider;
        if(!p) {
            throw new Error("No provider set");
        }
        return await RPCRetryHandler.withRetry(() => p.getBalance(this.address));
    }

    async tokenBalance(): Promise<bigint> {
        return await RPCRetryHandler.withRetry(() => this.admin.provider!.getBalance(this.address));
    }

    ////////////////////////////////////////////////////////////////////////
    // IUpgradeable interface
    ////////////////////////////////////////////////////////////////////////
    async upgrade(initData: string): Promise<IUpgradeResult> {
        const t = await RPCRetryHandler.withRetry(() => this.con.upgrade(initData));
        const r = await t.wait();
        if(!r.status) {
            throw new Error("Transaction failed with status 0");
        }
        const logs = this.logParser.parseLogs(r);
        const upgrades = logs.get(LogNames.CompanyUpgraded);
        if(!upgrades || upgrades.length === 0) {
            throw new Error("CompanyUpgraded log not found");
        }
        return {
            receipt: r,
            newImplementationAddress: upgrades[0].args[1]
        };
    }

    async version(): Promise<bigint> {
        return await RPCRetryHandler.withRetry(() => this.con.version());
    }

    async getImplementation(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.getImplementation());
    }

    

    ////////////////////////////////////////////////////////////////////////
    // Jump related methods
    ////////////////////////////////////////////////////////////////////////
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