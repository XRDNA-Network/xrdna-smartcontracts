import { buildModule } from "@nomicfoundation/ignition-core";
import CompanyFactoryModule from "./CompanyFactory.module";
import CompanyRegistryModule from "./CompanyRegistry.module";
import ExperienceRegistryModule from "../experience/ExperienceRegistry.module";
import AssetRegistryModule from "../asset/AssetRegistry.module";
import AvatarRegistryModule from "../avatar/AvatarRegistry.module";



export default buildModule("Company", (m) => {
    
    const reg = m.useModule(CompanyRegistryModule);
    const fac = m.useModule(CompanyFactoryModule);
    const expReg = m.useModule(ExperienceRegistryModule);
    const assetReg = m.useModule(AssetRegistryModule);
    const avatarReg = m.useModule(AvatarRegistryModule);

    const args = {
        companyFactory: fac.companyFactory,
        companyRegistry: reg.companyRegistry,
        experienceRegistry: expReg.experienceRegistry,
        assetRegistry: assetReg.assetRegistry,
        avatarRegistry: avatarReg.avatarRegistry
    }
    const master = m.contract("Company", [args], {
        after: [fac.companyFactory, 
                reg.companyRegistry, 
                expReg.experienceRegistry,
                assetReg.assetRegistry,
                avatarReg.avatarRegistry]
    });
    m.call(fac.companyFactory, "setImplementation", [master]);
    return {companyMasterCopy: master}
});