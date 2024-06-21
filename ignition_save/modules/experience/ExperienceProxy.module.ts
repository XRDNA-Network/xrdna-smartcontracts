import { buildModule } from "@nomicfoundation/ignition-core";
import ExperienceFactoryModule from "./ExperienceFactory.module";
import ExperienceRegistryModule from "./ExperienceRegistry.module";
import PortalRegistryModule from "../portal/PortalRegistry.module";




export default buildModule("ExperienceProxy", (m) => {
    
    const reg = m.useModule(ExperienceRegistryModule);
    const fac = m.useModule(ExperienceFactoryModule);

    const args = {
        factory: fac.experienceFactory,
        registry: reg.experienceRegistry,
    }
    const master = m.contract("ExperienceProxy", [args], {
        after: [fac.experienceFactory, 
                reg.experienceRegistry]
    });
    m.call(fac.experienceFactory, "setProxyImplementation", [master]);
    return {
        experienceRegistry: reg.experienceRegistry,
        experienceFactory: fac.experienceFactory,
        experienceProxyMasterCopy: master
    }
});