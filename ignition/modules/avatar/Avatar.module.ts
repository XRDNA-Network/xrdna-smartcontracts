import { buildModule } from "@nomicfoundation/ignition-core";
import CompanyRegistryModule from "../company/CompanyRegistry.module";
import ExperienceRegistryModule from "../experience/ExperienceRegistry.module";
import PortalRegistryModule from "../portal/PortalRegistry.module";
import AvatarProxyModule from './AvatarProxy.module';
import NTAssetMasterModule from "../asset/MultiAssetRegistry.module";


const VERSION = 1;
export default buildModule("Avatar", (m) => {
    
    const proxy = m.useModule(AvatarProxyModule);
    const companyReg = m.useModule(CompanyRegistryModule);
    const expReg = m.useModule(ExperienceRegistryModule);
    const portalReg = m.useModule(PortalRegistryModule);
    const assets = m.useModule(NTAssetMasterModule);
    const libLinkedList = m.library("LibLinkedList");

    const args = {
        avatarFactory: proxy.avatarFactory,
        avatarRegistry: proxy.avatarRegistry,
        experienceRegistry: expReg.experienceRegistry,
        portalRegistry: portalReg.portalRegistry,
        companyRegistry: companyReg.companyRegistry,
        multiAssetRegistry: assets.multiAssetRegistry
    }
    const master = m.contract("Avatar", [args], {
        libraries: {
            LibLinkedList: libLinkedList
        },
        after: [proxy.avatarFactory, 
                proxy.avatarRegistry, 
                expReg.experienceRegistry,
                portalReg.portalRegistry,
                companyReg.companyRegistry,
                assets.erc20Master,
                assets.erc721Master
            ]
    });
    m.call(proxy.avatarFactory, "setImplementation", [master, VERSION]);
    return {
        avatarMasterCopy: master,
        avatarRegistry: proxy.avatarRegistry,
        avatarFactory: proxy.avatarFactory,
    }
});