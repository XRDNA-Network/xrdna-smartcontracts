import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import WorldRegistryModule from "./WorldRegistry.module";
import WorldFactoryModule from "./WorldFactory.module";

export default buildModule("World", (m) => {
    
    const reg = m.useModule(WorldRegistryModule);
    const fac = m.useModule(WorldFactoryModule);
    
    const master = m.contract("World", [fac.worldFactory, reg.worldRegistry], {
        after: [fac.worldFactory, reg.worldRegistry]
    });
    m.call(fac.worldFactory, "setImplementation", [master]);
    return {worldMaster: master}
   
});