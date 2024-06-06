import { buildModule } from "@nomicfoundation/ignition-core";
import ExperienceFactoryModule from "./ExperienceFactory.module";
import ExperienceRegistryModule from "./ExperienceRegistry.module";
import PortalRegistryModule from "../portal/PortalRegistry.module";




export default buildModule("Experience", (m) => {
    
    const reg = m.useModule(ExperienceRegistryModule);
    const fac = m.useModule(ExperienceFactoryModule);
    const portalReg = m.useModule(PortalRegistryModule);

    const args = {
        experienceFactory: fac.experienceFactory,
        portalRegistry: portalReg.portalRegistry,
        experienceRegistry: reg.experienceRegistry,
    }
    const master = m.contract("Experience", [args], {
        after: [fac.experienceFactory, 
                reg.experienceRegistry, 
                portalReg.portalRegistry]
    });
    m.call(fac.experienceFactory, "setImplementation", [master]);
    return {experienceMasterCopy: master}
});