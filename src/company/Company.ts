import { AddressLike, Contract, LogDescription, Provider, Signer, TransactionReceipt, TransactionResponse, ethers } from "ethers";
import {abi} from "../../artifacts/contracts/company/Company.sol/Company.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";
import { LogParser } from "../LogParser";
import { LogNames } from "../LogNames";
import { Experience } from "../experience";
import { Avatar } from "../avatar/Avatar";
import { ERC20Asset, ERC721Asset } from "../asset";
import { ISupportsFunds, ISupportsHooks, ISupportsSigners, ISupportsVector, IUpgradeResult, IUpgradeable } from "../interfaces";
import { AllLogParser } from "../AllLogParser";
import { ISupportsActive } from "../interfaces/ISupportsActive";

export interface ICompanyOpts {
    address: string;
    admin: Provider | Signer;
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

export interface IDelegatedAvatarJumpRequest {
    portalId: bigint,
    agreedFee: bigint,
    avatarOwnerSignature: string,
    avatar: Avatar;
}

export interface IDelegatedAvatarJumpResult {
    receipt: TransactionReceipt;
    destination: AddressLike;
    connectionDetails: string;
    fee: bigint;
}

export interface IMintERC20Result {
    receipt: TransactionReceipt;
    amount: bigint;
}

export interface IMintERC721Result {
    receipt: TransactionReceipt;
    tokenId: bigint;
}

export class Company implements ISupportsFunds,
                                ISupportsHooks,
                                ISupportsSigners,
                                ISupportsVector,
                                IUpgradeable, 
                                ISupportsActive {
    static get abi() {
        return abi;
    }
    
    private con: Contract;
    readonly address: string;
    private admin: Provider | Signer;
    readonly logParser: AllLogParser;

    constructor(opts: ICompanyOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.con = new Contract(this.address, abi, this.admin);
        this.logParser = opts.logParser;
        this.logParser.addAbi(this.address, abi);
    }
    
    ////////////////////////////////////////////////////////////////////////
    // General information
    ////////////////////////////////////////////////////////////////////////
    async owner(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.owner());
    }

    async name(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.name());
    }

    async world(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.world());
    }

    async getVectorAddress(): Promise<VectorAddress> {
        const t = await RPCRetryHandler.withRetry(() => this.con.vectorAddress());
        return {
            x: t[0],
            y: t[1],
            z: t[2],
            t: t[3],
            p: t[4],
            p_sub: t[5]
        } as VectorAddress;    
    }

    
    ////////////////////////////////////////////////////////////////////////
    // ISupportsSigners interface
    ////////////////////////////////////////////////////////////////////////
    async isSigner(address: string): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isSigner(address));
    }

    async addSigners(signers: string[]): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.addSigners(signers));
    }

    async removeSigners(signers: string[]): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeSigners(signers));
    }

    
    ////////////////////////////////////////////////////////////////////////
    // Minting interface
    ////////////////////////////////////////////////////////////////////////
    async canMint(asset: string, to: string, amount: bigint): Promise<boolean> {
        const data = ethers.AbiCoder.defaultAbiCoder().encode(["uint256"], [amount]);
        return await RPCRetryHandler.withRetry(() => this.con.canMint(asset, to, data));
    }

    async mintERC20(asset: string, to: string, amount: bigint): Promise<IMintERC20Result> {
        const data = ethers.AbiCoder.defaultAbiCoder().encode(["uint256"], [amount]);
        const t = await RPCRetryHandler.withRetry(() => this.con.mint(asset, to, data));
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

    async revoke(asset: string, holder: string, amountOrTokenId: bigint): Promise<TransactionResponse> {
        const data = ethers.AbiCoder.defaultAbiCoder().encode(["uint256"], [amountOrTokenId]);
        return await RPCRetryHandler.withRetry(() => this.con.revoke(asset, holder, data));
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
    // ISupportsFunds interface
    ////////////////////////////////////////////////////////////////////////
    async withdraw(amount: bigint): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.withdraw(amount));
    }

    async addFunds(amount: bigint): Promise<TransactionResponse> {
       if(!this.admin.sendTransaction) {
            throw new Error("Cannot add funds without a signer");
        }
        return await RPCRetryHandler.withRetry(() => this.admin.sendTransaction!({
            to: this.address,
            value: amount
        }));
    }

    async getBalance(): Promise<bigint> {
        const p = this.admin.provider || this.admin as Provider;
        if(!p) {
            throw new Error("Cannot get balance without a provider");
        }
        return await RPCRetryHandler.withRetry(() => p.getBalance(this.address));
    }


    ////////////////////////////////////////////////////////////////////////
    // ISupportsHooks interface
    ////////////////////////////////////////////////////////////////////////
    async setHook(hook: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setHook(hook));
    }

    async removeHook() {
        return await RPCRetryHandler.withRetry(() => this.con.removeHook());
    }

    async getHook(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.hook());
    }


    ////////////////////////////////////////////////////////////////////////
    // Experience related functions
    ////////////////////////////////////////////////////////////////////////
    async addExperience(exp: IAddExperienceArgs): Promise<IAddExperienceResult> {
        const init = Experience.encodeInitData({
            entryFee: exp.entryFee,
            connectionDetails: exp.connectionDetails
        });
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

    async removeExperience(address: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeExperience(address));
    }
    
    async upgradeExperience(address: string, initData: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.upgradeExperience(address, initData));
    }

    async addExperienceCondition(exp: string, condition: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.addExperienceCondition(exp, condition));
    }

    async removeExperienceCondition(exp: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeExperienceCondition(exp));
    }

    async addExperienceHook(exp: string, hook: string): Promise<TransactionResponse> {  
        return await RPCRetryHandler.withRetry(() => this.con.addExperienceHook(exp, hook));
    }

    async removeExperienceHook(exp: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeExperienceHook(exp));
    }

    async changeExperiencePortalFee(exp: string, fee: bigint): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.changeExperiencePortalFee(exp, fee));
    }

    async companyOwnsDestinationPortal(portalId: bigint): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.companyOwnsDestinationPortal(portalId));
    }


    ////////////////////////////////////////////////////////////////////////
    // Asset related functions
    ////////////////////////////////////////////////////////////////////////
    async upgradeAsset(address: string, initData: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.upgradeAsset(address, initData));
    }

    async addAssetHook(asset: AddressLike, hook: AddressLike): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.addAssetHook(asset, hook));
    }
    async removeAssetHook(asset: AddressLike ): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeAssetHook(asset));
    }


    ////////////////////////////////////////////////////////////////////////
    // Avatar related functions
    ////////////////////////////////////////////////////////////////////////
    async signJumpRequest(props: {
        nonce: bigint;
        portalId: bigint;
        fee: bigint;
    }): Promise<string> {
        const enc = ethers.AbiCoder.defaultAbiCoder().encode(["uint256", "uint256", "uint256"], [props.portalId, props.fee, props.nonce]);
        const hashed = ethers.keccak256(enc);
        return await RPCRetryHandler.withRetry(() => (this.admin as Signer).signMessage(ethers.getBytes(hashed)));
    }

    async payForAvatarJump(req: IDelegatedAvatarJumpRequest, tokens?: bigint): Promise<IDelegatedAvatarJumpResult> {
        const t = await RPCRetryHandler.withRetry(() => this.con.delegateJumpForAvatar({
            avatar: req.avatar.address,
            portalId: req.portalId,
            agreedFee: req.agreedFee,
            avatarOwnerSignature: req.avatarOwnerSignature
        }, {
            value: tokens
        }));
        const r = await t.wait();
        if(!r.status) {
            throw new Error("Transaction failed with status 0");
        }
        const parser = req.avatar.logParser;
        const logs = parser.parseLogs(r);
        const jumps = logs.get(LogNames.JumpSuccess);
        if(!jumps || jumps.length === 0) {
            throw new Error("JumpSuccess log not found");
        }
        const jump = jumps[0];
        return {
            receipt: r,
            destination: jump.args[0],
            fee: jump.args[1],
            connectionDetails: jump.args[2]
        } as IDelegatedAvatarJumpResult;

    }

   

    async isActive(): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isActive());
    }
}