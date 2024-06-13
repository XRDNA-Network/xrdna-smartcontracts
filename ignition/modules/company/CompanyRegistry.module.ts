import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {XRDNASigners} from '../../../src';
import {network} from 'hardhat';
import CompanyFactoryModule from "./CompanyFactory.module";
import WorldRegistryModule0_2 from "../world/WorldRegistry.module";

export default buildModule("CompanyRegistry", (m) => {
    
   
    const xrdna = new XRDNASigners();
    const config = xrdna.deployment[network.config.chainId || 55555];
    const acct = config.companyRegistryAdmin;
    const admins = config.companyRegistryOtherAdmins;
    const fac = m.useModule(CompanyFactoryModule);
    const wReg = m.useModule(WorldRegistryModule0_2);

    const args = {
        mainAdmin: acct,
        admins,
        companyFactory: fac.companyFactory,
        worldRegistry: wReg.worldRegistry
    }
    const Registry = m.contract("CompanyRegistry", [args], {
        after: [fac.companyFactory, wReg.worldRegistry]
    });
    m.call(fac.companyFactory, "setAuthorizedRegistry", [Registry]);
    return {companyRegistry: Registry};
});