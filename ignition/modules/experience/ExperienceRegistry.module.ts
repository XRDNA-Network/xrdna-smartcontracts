import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {config} from "../config";
import PortalRegistryModule from "../portal/PortalRegistry.module";
import CompanyRegistryModule from "../company/CompanyRegistry.module";
import ExperienceFactoryModule from "./ExperienceFactory.module";

export default buildModule("ExperienceRegistry", (m) => {
    
    const admins = config.experienceRegistryAdmins;

    const fac = m.useModule(ExperienceFactoryModule);
    const pReg = m.useModule(PortalRegistryModule);
    const cReg = m.useModule(CompanyRegistryModule);
    const acct = m.getAccount(0);

    const args = {
        mainAdmin: acct,
        compRegistry: cReg.companyRegistry,
        portRegistry: pReg.portalRegistry,
        experienceFactory: fac.experienceFactory,
        admins
    }
    const Registry = m.contract("ExperienceRegistry", [args], {
        after: [fac.experienceFactory, cReg.companyRegistry, pReg.portalRegistry]
    });
    m.call(fac.experienceFactory, "setAuthorizedRegistry", [Registry]);
    return {experienceRegistry: Registry};
});