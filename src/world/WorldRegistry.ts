import { AddressLike, Provider, Signer, ethers } from "ethers";
import {abi as WorldRegistryABI} from "../../artifacts/contracts/world/WorldRegistry.sol/WorldRegistry.json";
import {abi as WorldABI} from "../../artifacts/contracts/world/World.sol/World.json";
import { IWorldInfo } from "./IWorldInfo";
import { LogParser } from "../LogParser";
/**
 * Typescript proxy for WorldRegistry deployed contract.
 */
export interface IWorldRegistryOpts {
    address: string;
    admin: Provider | Signer;
}

export class WorldRegistry {
    private address: string;
    private admin: Provider | Signer;
    private registry: ethers.Contract;
    private worldIfc: ethers.Interface;

    constructor(opts: IWorldRegistryOpts) {
        this.address = opts.address;
        this.admin = opts.admin;
        this.registry = new ethers.Contract(this.address, WorldRegistryABI, this.admin);
        this.worldIfc = new ethers.Interface(WorldABI);
    }

    async createWorld(props: {
        registrarSigner: Signer,
        registrarId: bigint,
        owner: AddressLike,
        details: IWorldInfo,
        tokensToOwner: boolean,
        tokens?: bigint
    }) {
        

        const {registrarId, registrarSigner, owner, details, tokensToOwner} = props;
        //const initData = encodeWorldInfo(details);
        let initData = await this.worldIfc.encodeFunctionData("encodeInfo", [details]);
        initData = `0x${initData.substring(10)}`;
        const t = await (this.registry.connect(registrarSigner) as any).register(registrarId, owner, initData, tokensToOwner, {
            value: props.tokens
        });
        const r = await t.wait();
        const parse = new LogParser(WorldRegistryABI, this.address);
        const logs = parse.parseLogs(r);
        const args = logs.get("WorldRegistered");
        if(!args) {
            throw new Error("World not created");
        }
        const addr = args[0];
        return {receipt: r, worldAddress: addr};
    }

    async lookupWorldAddress(name: string) {
        const addr = await this.registry.worldsByName(name.toLowerCase());
        return addr;
    }

}