import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {XRDNASigners} from '../../../src';
import {network} from 'hardhat';
import PortalRegistryModule from "../portal/PortalRegistry.module";
import CompanyRegistryModule from "../company/CompanyRegistry.module";
import ExperienceFactoryModule from "./ExperienceFactory.module";

export default buildModule("ExperienceRegistry", (m) => {
    
    
    const xrdna = new XRDNASigners();
    const config = xrdna.deployment[network.config.chainId || 55555];
    const acct = config.experienceRegistryAdmin;
    const admins = config.experienceRegistryOtherAdmins;
    
    const fac = m.useModule(ExperienceFactoryModule);
    const pReg = m.useModule(PortalRegistryModule);
    const cReg = m.useModule(CompanyRegistryModule);

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