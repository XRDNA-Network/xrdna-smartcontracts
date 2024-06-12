import { WorldFactory, WorldRegistry } from "../../../src";

export interface IWorldStack {

    getWorldFactory(): WorldFactory;
    getWorldRegistry(): WorldRegistry;

}