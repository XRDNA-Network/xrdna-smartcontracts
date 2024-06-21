import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {XRDNASigners} from '../../../src';
import {network} from 'hardhat';
import PortalRegistryModule from "../portal/PortalRegistry.module";
import CompanyRegistryModule from "../company/CompanyRegistry.module";
import ExperienceFactoryModule from "./ExperienceFactory.module";
import WorldRegistryModule from "../world/WorldRegistry.module";

export default buildModule("ExperienceRegistry", (m) => {
    
    
    const xrdna = new XRDNASigners();
    const config = xrdna.deployment[network.config.chainId || 55555];
    const acct = config.experienceRegistryAdmin;
    const admins = config.experienceRegistryOtherAdmins;
    
    const fac = m.useModule(ExperienceFactoryModule);
    const pReg = m.useModule(PortalRegistryModule);
    const wReg = m.useModule(WorldRegistryModule);

    const args = {
        mainAdmin: acct,
        worldRegistry: wReg.worldRegistry,
        portRegistry: pReg.portalRegistry,
        experienceFactory: fac.experienceFactory,
        admins
    }
    const Registry = m.contract("ExperienceRegistry", [args], {
        after: [
            fac.experienceFactory, 
            wReg.worldRegistry, 
            pReg.portalRegistry]
    });
    m.call(fac.experienceFactory, "setAuthorizedRegistry", [Registry]);
    m.call(pReg.portalRegistry, "setExperienceRegistry", [Registry]);
    return {experienceRegistry: Registry};
});