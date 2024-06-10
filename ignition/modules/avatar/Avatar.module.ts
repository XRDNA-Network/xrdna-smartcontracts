import { buildModule } from "@nomicfoundation/ignition-core";
import AvatarFactoryModule from "./AvatarFactory.module";
import AvatarRegistryModule from "./AvatarRegistry.module";
import CompanyRegistryModule from "../company/CompanyRegistry.module";
import ExperienceRegistryModule from "../experience/ExperienceRegistry.module";
import PortalRegistryModule from "../portal/PortalRegistry.module";
import AvatarProxyModule from './AvatarProxy.module';
import NTAssetMasterModule from "../asset/NTAssetMaster.module";



export default buildModule("Avatar", (m) => {
    
    const proxy = m.useModule(AvatarProxyModule);
    const companyReg = m.useModule(CompanyRegistryModule);
    const expReg = m.useModule(ExperienceRegistryModule);
    const portalReg = m.useModule(PortalRegistryModule);
    const assets = m.useModule(NTAssetMasterModule);

    const args = {
        avatarFactory: proxy.avatarFactory,
        avatarRegistry: proxy.avatarRegistry,
        experienceRegistry: expReg.experienceRegistry,
        portalRegistry: portalReg.portalRegistry,
        companyRegistry: companyReg.companyRegistry
    }
    const master = m.contract("Avatar", [args], {
        after: [proxy.avatarFactory, 
                proxy.avatarRegistry, 
                expReg.experienceRegistry,
                portalReg.portalRegistry,
                companyReg.companyRegistry,
                assets.erc20Master,
                assets.erc721Master
            ]
    });
    m.call(proxy.avatarFactory, "setImplementation", [master]);
    return {
        avatarMasterCopy: master,
        avatarRegistry: proxy.avatarRegistry,
        avatarFactory: proxy.avatarFactory,
    }
});