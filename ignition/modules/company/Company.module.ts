import { buildModule } from "@nomicfoundation/ignition-core";
import AssetRegistryModule from "../asset/AssetRegistry.module";
import AvatarRegistryModule from "../avatar/AvatarRegistry.module";
import ExperienceModule from "../experience/Experience.module";
import CompanyProxyModule from './CompanyProxy.module';



export default buildModule("Company", (m) => {
    
    const proxy = m.useModule(CompanyProxyModule);
    const assetReg = m.useModule(AssetRegistryModule);
    const avatarReg = m.useModule(AvatarRegistryModule);
    const exp = m.useModule(ExperienceModule);

    const args = {
        companyFactory: proxy.companyFactory,
        companyRegistry: proxy.companyRegistry,
        experienceRegistry: exp.experienceRegistry,
        assetRegistry: assetReg.assetRegistry,
        avatarRegistry: avatarReg.avatarRegistry
    }
    const master = m.contract("Company", [args], {
        after: [proxy.companyFactory, 
                proxy.companyRegistry, 
                exp.experienceRegistry,
                assetReg.assetRegistry,
                avatarReg.avatarRegistry]
    });
    m.call(proxy.companyFactory, "setImplementation", [master]);
    return {
        companyRegistry: proxy.companyRegistry,
        companyFactory: proxy.companyFactory,
        experienceRegistry: exp.experienceRegistry,
        experienceFactory: exp.experienceFactory,
        assetRegistry: assetReg.assetRegistry,
        avatarRegistry: avatarReg.avatarRegistry,
        companyMasterCopy: master
    }
});