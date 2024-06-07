import { Signer } from "ethers";
import { World, WorldFactory, WorldRegistry } from "../../../src";

export interface IWorldStack {

    getWorldFactory(): WorldFactory;
    getWorldRegistry(): WorldRegistry;
    createWorld(): World;

}