import { AddressLike, Contract, Provider, Signer, TransactionReceipt, TransactionResponse, ethers } from "ethers";
import {abi} from "../../artifacts/contracts/company/Company.sol/Company.json";
import { RPCRetryHandler } from "../RPCRetryHandler";
import { VectorAddress } from "../VectorAddress";
import { LogParser } from "../LogParser";
import { LogNames } from "../LogNames";
import { Experience } from "../experience";
import { Avatar } from "../avatar/Avatar";
import { ERC20Asset, ERC721Asset } from "../asset";

export interface ICompanyOpts {
    address: string;
    admin: Provider | Signer;
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

export class Company {
    private con: Contract;
    readonly address: string;
    private admin: Provider | Signer;
    private parser: LogParser;

    constructor(opts: ICompanyOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.con = new Contract(this.address, abi, this.admin);
        this.parser = new LogParser(abi, this.address);
    }
    
    async owner(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.owner());
    }

    async name(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.name());
    }

    async world(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.world());
    }

    async hook(): Promise<string> {
        return await RPCRetryHandler.withRetry(() => this.con.hook());
    }

    async nextPSub(): Promise<bigint> {
        return await RPCRetryHandler.withRetry(() => this.con.nextPsub());
    }

    async vectorAddress(): Promise<VectorAddress> {
        return await RPCRetryHandler.withRetry(() => this.con.vectorAddress());
    }

    async isSigner(address: string): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.isSigner(address));
    }

    async canMint(asset: string, to: string, amount: string): Promise<boolean> {
        const data = ethers.AbiCoder.defaultAbiCoder().encode(["uint256"], [amount]);
        return await RPCRetryHandler.withRetry(() => this.con.canMint(asset, to, data));
    }

    async upgraded(): Promise<boolean> {
        return await RPCRetryHandler.withRetry(() => this.con.upgraded());
    }

    async addSigner(signer: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.addSigners([signer]));
    }

    async removeSigner(signer: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeSigners([signer]));
    }

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
        const logs = this.parser.parseLogs(r);
        const args = logs.get(LogNames.ExperienceAdded);
        if(!args) {
            throw new Error("ExperienceAdded log not found");
        }
        return {
            receipt: r,
            experienceAddress: args[0],
            portalId: args[1]
        };
    }

    async mintERC20(asset: string, to: string, amount: bigint): Promise<IMintERC20Result> {
        const data = ethers.AbiCoder.defaultAbiCoder().encode(["uint256"], [amount]);
        const t = await RPCRetryHandler.withRetry(() => this.con.mint(asset, to, data));
        const r = await t.wait();
        if(!r.status) {
            throw new Error("Transaction failed with status 0");
        }

        const erc20 = new ERC20Asset({address: asset, provider: this.admin as Provider});
        const logs = erc20.logParser.parseLogs(r);
        const args = logs.get(LogNames.Transfer);
        if(!args) {
            throw new Error("Transfer log not found");
        }
        return {
            receipt: r,
            amount: args[2]
        };
    }

    async mintERC721(asset: AddressLike, to: AddressLike): Promise<IMintERC721Result> {
        const data = ethers.AbiCoder.defaultAbiCoder().encode(["uint256"], [0]);
        const t = await RPCRetryHandler.withRetry(() => this.con.mint(asset, to, data));
        const r = await t.wait();
        if(!r.status) {
            throw new Error("Transaction failed with status 0");
        }

        const erc721 = new ERC721Asset({address: await asset.valueOf().toString(), provider: this.admin as Provider});

        const logs = erc721.logParser.parseLogs(r);
        const args = logs.get(LogNames.Transfer);
        if(!args) {
            throw new Error("Transfer log not found");
        }
        return {
            receipt: r,
            tokenId: args[2]
        };
    }

    async revoke(asset: string, holder: string, amountOrTokenId: bigint): Promise<TransactionResponse> {
        const data = ethers.AbiCoder.defaultAbiCoder().encode(["uint256"], [amountOrTokenId]);
        return await RPCRetryHandler.withRetry(() => this.con.revoke(asset, holder, data));
    }

    async upgrade(initData: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.upgrade(initData));
    }

    async upgradeComplete(nextVersion: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.upgradeComplete(nextVersion));
    }   

    async withdraw(amount: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.withdraw(amount));
    }

    async setHook(hook: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.setHook(hook));
    }

    async removeHook() {
        return await RPCRetryHandler.withRetry(() => this.con.removeHook());
    }
    
    async addExperienceCondition(exp: string, condition: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.addExperienceCondition(exp, condition));
    }

    async removeExperienceCondition(exp: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeExperienceCondition(exp));
    }

    async changeExperiencePortalFee(exp: string, fee: string): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.changeExperiencePortalFee(exp, fee));
    }

    async addAssetHook(asset: AddressLike, hook: AddressLike): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.addAssetHook(asset, hook));
    }
    async removeAssetHook(asset: AddressLike ): Promise<TransactionResponse> {
        return await RPCRetryHandler.withRetry(() => this.con.removeAssetHook(asset));
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
        const args = logs.get(LogNames.JumpSuccess);
        if(!args) {
            throw new Error("JumpSuccess log not found");
        }
        return {
            receipt: r,
            destination: args[0],
            fee: args[1],
            connectionDetails: args[2]
        } as IDelegatedAvatarJumpResult;

    }

    async tokenBalance(): Promise<bigint> {
        return await RPCRetryHandler.withRetry(() => this.admin.provider!.getBalance(this.address));
    }

}