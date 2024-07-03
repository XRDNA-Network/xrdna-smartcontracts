import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {abi as ABI} from '../../../../artifacts/contracts/world/interfaces/IWorld.sol/IWorld.json';
import {abi as pABI} from '../../../../artifacts/contracts/world/instance/WorldProxy.sol/WorldProxy.json';
import WorldProxyModule from "./WorldProxy.module";
import WorldRegistryModule from "../registry/WorldRegistry.module";
import LibrariesModule from "../../Libraries.module";

export const abi = [
    ...ABI,
    ...pABI
]

export default buildModule("WorldModule", (m) => {

    const proxy = m.useModule(WorldProxyModule).worldProxy;
    const wReg = m.useModule(WorldRegistryModule);
    const libs = m.useModule(LibrariesModule);

    //make sure to use proxy addresses, not implementation addresses
    const args = {
        owningRegistry: wReg.worldRegistryProxy
    }
    const r = m.contract("World", [args], {
        libraries: {
            LibAccess: libs.LibAccess,
            LibWorld: libs.LibWorld,
        },
        after: [
            libs.LibAccess,
            libs.LibRegistrar,
            wReg.worldRegistry
        ]
    });
    const data = m.encodeFunctionCall(wReg.worldRegistry, "setEntityImplementation", [r]);
    m.send("setEntityImplementation", wReg.worldRegistryProxy, 0n, data);
    return {
        world: r,
        worldProxy: proxy
    }
});