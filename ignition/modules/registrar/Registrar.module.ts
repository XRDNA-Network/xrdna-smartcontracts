import { buildModule } from "@nomicfoundation/ignition-core";
import RegistrarProxyModule from "./RegistrarProxy.module";
import WorldRegistryModule from "../world/WorldRegistry.module";
import LibrariesModule from "../libraries/Libraries.module";

const VERSION = 1;
export default buildModule("Registrar", (m) => {
    
    const proxy = m.useModule(RegistrarProxyModule);
    const wReg = m.useModule(WorldRegistryModule);
    const libs = m.useModule(LibrariesModule);

    const args = {
        registrarFactory: proxy.registrarFactory,
        registrarRegistry: proxy.registrarRegistry,
        worldRegistry: wReg.worldRegistry
    }

    
    const master = m.contract("Registrar", [args], {
        
        libraries: {
            LibHooks: libs.LibHooks,
            LibRegistration: libs.LibRegistration
        },
        after: [
            proxy.registrarFactory,
            proxy.registrarRegistry, 
            wReg.worldRegistry
        ]
    });
    
    m.call(proxy.registrarFactory, "setImplementation", [master, VERSION]);
    
    return {
        registrarRegistry: proxy.registrarRegistry,
        registrarFactory: proxy.registrarFactory,
        registrarMasterCopy: master
    }
});