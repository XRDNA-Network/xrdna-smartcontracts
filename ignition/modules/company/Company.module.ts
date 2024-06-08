import { buildModule } from "@nomicfoundation/ignition-core";
import CompanyFactoryModule from "./CompanyFactory.module";
import CompanyRegistryModule from "./CompanyRegistry.module";
import ExperienceRegistryModule from "../experience/ExperienceRegistry.module";
import AssetRegistryModule from "../asset/AssetRegistry.module";
import AvatarRegistryModule from "../avatar/AvatarRegistry.module";
import WorldModule from "../world/World.module";
import ExperienceModule from "../experience/Experience.module";



export default buildModule("Company", (m) => {
    
    const reg = m.useModule(CompanyRegistryModule);
    const fac = m.useModule(CompanyFactoryModule);
    const assetReg = m.useModule(AssetRegistryModule);
    const avatarReg = m.useModule(AvatarRegistryModule);
    const exp = m.useModule(ExperienceModule);

    const args = {
        companyFactory: fac.companyFactory,
        companyRegistry: reg.companyRegistry,
        experienceRegistry: exp.experienceRegistry,
        assetRegistry: assetReg.assetRegistry,
        avatarRegistry: avatarReg.avatarRegistry
    }
    const master = m.contract("Company", [args], {
        after: [fac.companyFactory, 
                reg.companyRegistry, 
                exp.experienceRegistry,
                assetReg.assetRegistry,
                avatarReg.avatarRegistry]
    });
    m.call(fac.companyFactory, "setImplementation", [master]);
    return {
        companyRegistry: reg.companyRegistry,
        companyFactory: fac.companyFactory,
        experienceRegistry: exp.experienceRegistry,
        experienceFactory: exp.experienceFactory,
        assetRegistry: assetReg.assetRegistry,
        avatarRegistry: avatarReg.avatarRegistry,
        companyMasterCopy: master
    }
});