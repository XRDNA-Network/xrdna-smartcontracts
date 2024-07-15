import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import WorldRegistryProxyModule from "../registry/WorldRegistryProxy.module";
import WorldRegistryModule from "../registry/WorldRegistry.module";
import WorldModule from "./World.module";

export default buildModule("WorldProxyModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const proxy = m.useModule(WorldRegistryProxyModule).worldRegistryProxy;
        const reg = m.useModule(WorldRegistryModule).worldRegistry;
        const world = m.useModule(WorldModule).world;
        
        const rr = m.contract("WorldProxy", [proxy], {
            after: [
                proxy,
                world,
                libs.LibAccess
            ]
        });
        const data = m.encodeFunctionCall(reg, "setProxyImplementation", [rr]);
        m.send("setProxyImplementation", proxy, 0n, data);
        return {
            worldProxy: rr
        }
});