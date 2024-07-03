import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {abi as ABI} from '../../../../artifacts/contracts/world/instance/WorldProxy.sol/WorldProxy.json';
import WorldRegistryModule from "../registry/WorldRegistry.module";
import LibrariesModule from "../../Libraries.module";

export const abi = ABI;

export default buildModule("WorldProxyModule", (m) => {

    const wReg = m.useModule(WorldRegistryModule);
    const libs = m.useModule(LibrariesModule);

    //use proxy address, not implementation
    const args = {
        owningRegistry: wReg.worldRegistryProxy
    }
    const proxy = m.contract("WorldProxy", [args], {
        after: [
            wReg.worldRegistry
        ]
    });
    const data = m.encodeFunctionCall(wReg.worldRegistry, "setProxyImplementation", [proxy]);
    m.send("setProxyImplementation", wReg.worldRegistryProxy, 0n, data);
    return {
        worldProxy: proxy
    }
});