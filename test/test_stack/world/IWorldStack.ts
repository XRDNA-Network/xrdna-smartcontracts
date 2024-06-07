import { Signer } from "ethers";
import { World, WorldFactory, WorldRegistry } from "../../src";

export interface IWorldStack {

    worldFactory: WorldFactory;
    worldRegistry: WorldRegistry;
    world: World;

}