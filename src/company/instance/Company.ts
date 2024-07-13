import { AddressLike, Provider, Signer, TransactionReceipt, TransactionResponse, ethers } from "ethers";
import { RPCRetryHandler } from "../../RPCRetryHandler";
import { VectorAddress } from "../../VectorAddress";
import { Version } from "../../Version";
import {abi as cABI} from '../../../artifacts/contracts/company/instance/ICompany.sol/ICompany.json';
import {abi as proxyABI} from '../../../artifacts/contracts/base-types/entity/IEntityProxy.sol/IEntityProxy.json';
import { LogNames } from "../../LogNames";
import { ERC20Asset, ERC721Asset } from "../../asset";
import { Avatar } from "../../avatar";
import { BaseRemovableEntity } from "../../base-types/entity/BaseRemovableEntity";
import { IWrapperOpts } from "../../interfaces/IWrapperOpts";


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

export class Company extends BaseRemovableEntity {

    static get abi() {
        return  [
            ...cABI,
            ...proxyABI
        ]
    }
    
    private con: ethers.Contract;

    constructor(opts: IWrapperOpts) {
        super(opts);
        const abi = Company.abi;
        if(!abi || abi.length === 0) {
            throw new Error("Invalid ABI");
        }
        this.con = new ethers.Contract(this.address, abi, this.admin);
        this.logParser.addAbi(this.address, abi);
    }

    getContract(): ethers.Contract {
        return this.con;
    }

    async isActive(): Promise<boolean> {
        return super.isEntityActive();
    }

    async world(): Promise<AddressLike> {
        return await RPCRetryHandler.withRetry(() => this.con.world());
    }

    async getVectorAddress(): Promise<VectorAddress> {
        return await RPCRetryHandler.withRetry(() => this.con.vectorAddress());
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


    async changeExperiencePortalFee(exp: string, fee: bigint): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.changeExperiencePortalFee(exp, fee));
    }

    async addExperienceCondition(exp: string, condition: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.addExperienceCondition(exp, condition));
    }

    async removeExperienceCondition(exp: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeExperienceCondition(exp));
    }


    async canMintERC20(asset: string, to: string, amount: bigint): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.canMintERC20(asset, to, amount));
    }

    async canMintERC721(asset: string, to: string): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.canMintERC721(asset, to));
    }

    async mintERC20(asset: string, to: string, amount: bigint): Promise<IMintERC20Result> {
        const t = await RPCRetryHandler.withRetry(() => this.con.mintERC20(asset, to, amount));
        const r = await t.wait();
        if(!r.status) {
            throw new Error("Transaction failed with status 0");
        }
        const erc20 = new ERC20Asset({address: asset, signerOrProvider: this.admin as Provider, logParser: this.logParser});

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
        const t = await RPCRetryHandler.withRetry(() => this.con.mintERC721(asset, to));
        const r = await t.wait();
        if(!r.status) {
            throw new Error("Transaction failed with status 0");
        }

        const erc721 = new ERC721Asset({address: asset.toString(), signerOrProvider: this.admin as Provider, logParser: this.logParser});

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
        return await RPCRetryHandler.withRetry(() => this.con.revokeERC20(asset, holder, amount));
    }

    async revokeERC721(asset: string, holder: string, tokenId: bigint): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.revokeERC721(asset, holder, tokenId));
    }

    async setERC721BaseURI(asset: string, uri: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setERC721BaseURI(asset, uri));
    }

    async addAssetCondition(asset: AddressLike, condition: AddressLike): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.addAssetCondition(asset, condition));
    }

    async removeAssetCondition(asset: AddressLike): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeAssetCondition(asset));
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
    
}