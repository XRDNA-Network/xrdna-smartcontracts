import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import RegistrarRegistryProxyModule from "../registry/RegistrarRegistryProxy.module";
import RegistrarRegistryModule from "../registry/RegistrarRegistry.module";
import RegistrarModule from "./Registrar.module";

export default buildModule("RegistrarProxyModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const proxy = m.useModule(RegistrarRegistryProxyModule).registrarRegistryProxy;
        const reg = m.useModule(RegistrarRegistryModule).registrarRegistry;
        const registrar = m.useModule(RegistrarModule).registrar;
        
        const rr = m.contract("RegistrarProxy", [proxy], {
            after: [
                proxy,
                registrar,
                libs.LibAccess
            ]
        });
        const data = m.encodeFunctionCall(reg, "setProxyImplementation", [rr]);
        m.send("setProxyImplementation", proxy, 0n, data);
        return {
            registrarProxy: rr
        }
});