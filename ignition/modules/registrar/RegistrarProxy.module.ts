import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import RegistrarFactoryModule from "./RegistrarFactory.module";
import RegistrarRegistryModule from "./RegistrarRegistry.module";

export default buildModule("RegistrarProxy", (m) => {
    
    const reg = m.useModule(RegistrarRegistryModule);
    const fac = m.useModule(RegistrarFactoryModule);
    
    
    const args = {
        factory: fac.registrarFactory,
        registry: reg.registrarRegistry
    }
    const master = m.contract("RegistrarProxy", [args], {
        after: [
            fac.registrarFactory, 
            reg.registrarRegistry
        ]
    });
    m.call(fac.registrarFactory, "setProxyImplementation", [master]);
    return {
        registrarProxyMasterCopy: master,
        registrarRegistry: reg.registrarRegistry,
        registrarFactory: fac.registrarFactory
    }
});