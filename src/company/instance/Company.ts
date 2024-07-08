import { AddressLike, Provider, Signer, TransactionReceipt, TransactionResponse, ethers } from "ethers";
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { VectorAddress } from "../../VectorAddress";
import { AllLogParser } from "../../AllLogParser";
import { Version } from "../../Version";
import {abi as cABI} from '../../../artifacts/contracts/company/instance/ICompany.sol/ICompany.json';
import { LogNames } from "../../LogNames";
import { ERC20Asset, ERC721Asset } from "../../asset";

/**
 * Typescript proxy for World instance
 */
export interface ICompanyOpts {
    address: string;
    admin: Signer | Provider;
    logParser: AllLogParser;
}

export interface IAddExperienceArgs {
    name: string,
    entryFee: bigint;
    connectionDetails: string;
}

export interface IAddExperienceResult {
    receipt: TransactionReceipt;
    experienceAddress: AddressLike;
    portalId: bigint;
}


export interface IMintERC20Result {
    receipt: TransactionReceipt;
    amount: bigint;
}

export interface IMintERC721Result {
    receipt: TransactionReceipt;
    tokenId: bigint;
}

export class Company {

    static get abi() {
        return  cABI
    }
    
    readonly address: string;
    readonly admin: Provider | Signer;
    private con: ethers.Contract;
    readonly logParser: AllLogParser;

    constructor(opts: ICompanyOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        const abi = Company.abi;
        if(!abi || abi.length === 0) {
            throw new Error("Invalid ABI");
        }
        this.con = new ethers.Contract(this.address, abi, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, abi);
    }

    async isActive(): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isEntityActive());
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

    async addExperience(exp: IAddExperienceArgs): Promise<IAddExperienceResult> {

        const init = ethers.AbiCoder.defaultAbiCoder().encode([
            'tuple(uint256 entryFee, bytes connectionDetails)'
        ],[{
            entryFee: exp.entryFee,
            connectionDetails: Buffer.from(exp.connectionDetails)
        }]);
        const t = await RPCRetryHandler.withRetry(() => this.con.addExperience({
            name: exp.name,
            initData: init
        }));
        const r = await t.wait();
        if(!r.status) {
            throw new Error("Transaction failed with status 0");
        }
        const logs = this.logParser.parseLogs(r);
        const adds = logs.get(LogNames.CompanyAddedExperience);
        if(!adds || adds.length === 0) {
            throw new Error("ExperienceAdded log not found for company: " + this.address);
        }
        return {
            receipt: r,
            experienceAddress: adds[0].args[0],
            portalId: adds[0].args[1]
        };
    }

    async deactivateExperience(address: string, reason: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.deactivateExperience(address, reason));
    }

    async reactivateExperience(address: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.reactivateExperience(address));
    }

    async removeExperience(address: string, reason: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeExperience(address, reason));
    }


    async canMintERC20(asset: string, to: string, amount: bigint): Promise<boolean> {
        const data = ethers.AbiCoder.defaultAbiCoder().encode(["uint256"], [amount]);
        return await RPCRetryHandler.withRetry(() => this.con.canMintERC20(asset, to, data));
    }

    async canMintERC721(asset: string, to: string): Promise<boolean> {
        const data = ethers.AbiCoder.defaultAbiCoder().encode(["uint256"], [0]);
        return await RPCRetryHandler.withRetry(() => this.con.canMintERC721(asset, to, data));
    }

    async mintERC20(asset: string, to: string, amount: bigint): Promise<IMintERC20Result> {
        const data = ethers.AbiCoder.defaultAbiCoder().encode(["uint256"], [amount]);
        const t = await RPCRetryHandler.withRetry(() => this.con.mintERC20(asset, to, data));
        const r = await t.wait();
        if(!r.status) {
            throw new Error("Transaction failed with status 0");
        }
        const erc20 = new ERC20Asset({address: asset, provider: this.admin as Provider, logParser: this.logParser});

        const logs = erc20.logParser.parseLogs(r);
        const xfers = logs.get(LogNames.ERC20Minted);
        if(!xfers || xfers.length === 0) {
            throw new Error("ERC20Minted log not found");
        }
        return {
            receipt: r,
            amount: xfers[0].args[1]
        };
    }

    async mintERC721(asset: AddressLike, to: AddressLike): Promise<IMintERC721Result> {
        const data = ethers.AbiCoder.defaultAbiCoder().encode(["uint256"], [0]);
        const t = await RPCRetryHandler.withRetry(() => this.con.mint(asset, to, data));
        const r = await t.wait();
        if(!r.status) {
            throw new Error("Transaction failed with status 0");
        }

        const erc721 = new ERC721Asset({address: asset.toString(), provider: this.admin as Provider, logParser: this.logParser});

        const logs = erc721.logParser.parseLogs(r);
        const xfers = logs.get(LogNames.ERC721Minted);
        if(!xfers || xfers.length === 0) {
            throw new Error("ERC20Minted log not found for company:"+this.address);
        }
        return {
            receipt: r,
            tokenId: xfers[0].args[1]
        };
    }

    async revokeERC20(asset: string, holder: string, amount: bigint): Promise<TransactionResponse> {
        const data = ethers.AbiCoder.defaultAbiCoder().encode(["uint256"], [amount]);
        return await RPCRetryHandler.withRetry(() => this.con.revokeERC20(asset, holder, data));
    }

    async revokeERC721(asset: string, holder: string, tokenId: bigint): Promise<TransactionResponse> {
        const data = ethers.AbiCoder.defaultAbiCoder().encode(["uint256"], [tokenId]);
        return await RPCRetryHandler.withRetry(() => this.con.revokeERC721(asset, holder, data));
    }
    
}