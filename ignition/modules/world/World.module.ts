import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import WorldRegistryModule0_2 from "./WorldRegistry.module";
import WorldFactoryModule0_2 from "./WorldFactory.module";
import AvatarRegistryModule from "../avatar/AvatarRegistry.module";
import CompanyRegistryModule from '../company/CompanyRegistry.module';

export default buildModule("World0_2", (m) => {
    
    const reg = m.useModule(WorldRegistryModule0_2);
    const fac = m.useModule(WorldFactoryModule0_2);
    const avatarReg = m.useModule(AvatarRegistryModule);
    const companyReg = m.useModule(CompanyRegistryModule);
    const args = {
        worldFactory: fac.worldFactory,
        worldRegistry: reg.worldRegistry,
        companyRegistry: companyReg.companyRegistry,
        avatarRegistry: avatarReg.avatarRegistry
    }
    const master = m.contract("World0_2", [args], {
        after: [fac.worldFactory, reg.worldRegistry, avatarReg.avatarRegistry, companyReg.companyRegistry]
    });
    m.call(fac.worldFactory, "setImplementation", [master]);
    return {worldMasterCopy: master}
});