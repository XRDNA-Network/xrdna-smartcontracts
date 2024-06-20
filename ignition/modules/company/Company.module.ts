import { buildModule } from "@nomicfoundation/ignition-core";
import AssetRegistryModule from "../asset/MultiAssetRegistry.module";
import AvatarRegistryModule from "../avatar/AvatarRegistry.module";
import ExperienceModule from "../experience/Experience.module";
import CompanyProxyModule from './CompanyProxy.module';
import LibHooksModule from '../libraries/Libraries.module';


const VERSION = 1;
export default buildModule("Company", (m) => {
    
    const proxy = m.useModule(CompanyProxyModule);
    const assetReg = m.useModule(AssetRegistryModule);
    const avatarReg = m.useModule(AvatarRegistryModule);
    const exp = m.useModule(ExperienceModule);
    const libs = m.useModule(LibHooksModule);

    const args = {
        companyFactory: proxy.companyFactory,
        companyRegistry: proxy.companyRegistry,
        experienceRegistry: exp.experienceRegistry,
        multiAssetRegistry: assetReg.multiAssetRegistry,
        avatarRegistry: avatarReg.avatarRegistry
    }
    const master = m.contract("Company", [args], {
        libraries: {
            LibHooks: libs.LibHooks
        },
        after: [proxy.companyFactory, 
                proxy.companyRegistry, 
                exp.experienceRegistry,
                assetReg.multiAssetRegistry,
                avatarReg.avatarRegistry]
    });
    m.call(proxy.companyFactory, "setImplementation", [master, VERSION]);
    return {
        companyRegistry: proxy.companyRegistry,
        companyFactory: proxy.companyFactory,
        experienceRegistry: exp.experienceRegistry,
        experienceFactory: exp.experienceFactory,
        multiAssetRegistry: assetReg.multiAssetRegistry,
        avatarRegistry: avatarReg.avatarRegistry,
        companyMasterCopy: master
    }
});