import { buildModule } from "@nomicfoundation/ignition-core";
import AvatarFactoryModule from "./AvatarFactory.module";
import AvatarRegistryModule from "./AvatarRegistry.module";
import CompanyRegistryModule from "../company/CompanyRegistry.module";
import ExperienceRegistryModule from "../experience/ExperienceRegistry.module";
import PortalRegistryModule from "../portal/PortalRegistry.module";



export default buildModule("Avatar", (m) => {
    
    const reg = m.useModule(AvatarRegistryModule);
    const fac = m.useModule(AvatarFactoryModule);
    const companyReg = m.useModule(CompanyRegistryModule);
    const expReg = m.useModule(ExperienceRegistryModule);
    const portalReg = m.useModule(PortalRegistryModule);

    const args = {
        avatarFactory: fac.avatarFactory,
        avatarRegistry: reg.avatarRegistry,
        experienceRegistry: expReg.experienceRegistry,
        portalRegistry: portalReg.portalRegistry,
        companyRegistry: companyReg.companyRegistry
    }
    const master = m.contract("Avatar", [args], {
        after: [fac.avatarFactory, 
                reg.avatarRegistry, 
                expReg.experienceRegistry,
                portalReg.portalRegistry,
                companyReg.companyRegistry]
    });
    m.call(fac.avatarFactory, "setImplementation", [master]);
    return {avatarMasterCopy: master}
});