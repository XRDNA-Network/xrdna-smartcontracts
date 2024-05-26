import { Provider, Signer, TransactionResponse, ethers } from "ethers";
import {abi as WorldABI} from "../../artifacts/contracts/world/World.sol/World.json";

/**
 * Typescript proxy for World instance
 */
export interface IWorldOpts {
    address: string;
    admin: Signer;
}

export class World {
    private address: string;
    private admin: Provider | Signer;
    private world: ethers.Contract;

    constructor(opts: IWorldOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.world = new ethers.Contract(this.address, WorldABI, this.admin);
    }

    async addSigners(signers: string[]): Promise<TransactionResponse> {
        return await this.world.addSigners(signers);
    }

    async removeSigners(signers: string[]): Promise<TransactionResponse> {
        return await this.world.removeSigners(signers);
    }

    async isSigner(address: string): Promise<boolean> {
        return await this.world.isSigner(address);
    }

    async withdraw(amount: bigint): Promise<TransactionResponse> {
        return await this.world.withdraw(amount);
    }
}