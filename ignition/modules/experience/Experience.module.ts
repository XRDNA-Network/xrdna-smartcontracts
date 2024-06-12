import { buildModule } from "@nomicfoundation/ignition-core";
import PortalRegistryModule from "../portal/PortalRegistry.module";
import ExperienceProxyModule from './ExperienceProxy.module';

export default buildModule("Experience", (m) => {
    
    const proxy = m.useModule(ExperienceProxyModule);
    const portalReg = m.useModule(PortalRegistryModule);

    const args = {
        experienceFactory: proxy.experienceFactory,
        portalRegistry: portalReg.portalRegistry,
        experienceRegistry: proxy.experienceRegistry,
    }
    const master = m.contract("Experience", [args], {
        after: [proxy.experienceFactory, 
                proxy.experienceRegistry, 
                portalReg.portalRegistry]
    });
    m.call(proxy.experienceFactory, "setImplementation", [master]);
    return {
        experienceRegistry: proxy.experienceRegistry,
        experienceFactory: proxy.experienceFactory,
        experienceMasterCopy: master
    }
});