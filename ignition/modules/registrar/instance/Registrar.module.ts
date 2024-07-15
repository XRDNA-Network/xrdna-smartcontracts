import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import RegistrarRegistryModule from "../registry/RegistrarRegistry.module";
import RegistrarRegistryProxyModule from "../registry/RegistrarRegistryProxy.module";
import WorldRegistryProxyModule from "../../world/registry/WorldRegistryProxy.module";

export default buildModule("RegistrarModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const regReg = m.useModule(RegistrarRegistryModule).registrarRegistry;
        const regRegProxy = m.useModule(RegistrarRegistryProxyModule).registrarRegistryProxy;
        const worldRegProxy = m.useModule(WorldRegistryProxyModule).worldRegistryProxy;
        
        const args = {
            registrarRegistry: regRegProxy,
            worldRegistry: worldRegProxy
        }
        
        const fe = m.contract("Registrar", [args], {
            libraries: {
                LibAccess: libs.LibAccess
            },
            after: [
                regRegProxy,
                worldRegProxy,
                libs.LibAccess
            ]
        });
        const data = m.encodeFunctionCall(regReg, "setEntityImplementation", [fe]);
        m.send("setRegistrarEntityImplementation", regRegProxy, 0n, data);
        return {
            registrar: fe
        }
});