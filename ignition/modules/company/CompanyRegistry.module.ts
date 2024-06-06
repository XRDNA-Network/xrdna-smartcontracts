import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {config} from "../config";
import CompanyFactoryModule from "./CompanyFactory.module";
import WorldRegistryModule0_2 from "../world/WorldRegistry.module";

export default buildModule("CompanyRegistry", (m) => {
    
    const admins = config.companyRegistryAdmins;

    const fac = m.useModule(CompanyFactoryModule);
    const wReg = m.useModule(WorldRegistryModule0_2);
    const acct = m.getAccount(0);

    const args = {
        mainAdmin: acct,
        admins,
        companyFactory: fac.companyFactory,
        worldRegistry: wReg.worldRegistry
    }
    const Registry = m.contract("CompanyRegistry", [args], {
        after: [fac.companyFactory, wReg.worldRegistry]
    });
    return {companyRegistry: Registry};
});