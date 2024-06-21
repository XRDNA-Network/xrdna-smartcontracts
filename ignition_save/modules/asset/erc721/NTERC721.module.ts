import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import AvatarRegistryModule from "../../avatar/AvatarRegistry.module";
import NTAssetProxyModule from "./NTERC721Proxy.module";
import CompanyRegistryModule from "../../company/CompanyRegistry.module";
import LibHooksModule from "../../libraries/Libraries.module";

const VERSION = 1;
export default buildModule("NTERC721Asset", (m) => {
    
    const proxy = m.useModule(NTAssetProxyModule);
    const avatarRegistry = m.useModule(AvatarRegistryModule);
    const companyRegistry = m.useModule(CompanyRegistryModule);
    const libs = m.useModule(LibHooksModule);

    const args = {
        assetFactory: proxy.erc721Factory,
        assetRegistry: proxy.erc721Registry,
        avatarRegistry: avatarRegistry.avatarRegistry,
        companyRegistry: companyRegistry.companyRegistry
    }
    
    const afterSet = [
        proxy.erc721Factory, 
        proxy.erc721Registry, 
        avatarRegistry.avatarRegistry, 
        companyRegistry.companyRegistry
    ]
    const masterERC = m.contract("NTERC721Asset", [args], {
        libraries: {
            LibHooks: libs.LibHooks
        },
        after: afterSet
    });
    m.call(proxy.erc721Factory, "setImplementation", [masterERC, VERSION]);
    return {
        erc721Registry: proxy.erc721Registry,
        erc721Factory: proxy.erc721Factory,
        companyRegistry: companyRegistry.companyRegistry,
        avatarRegistry: avatarRegistry.avatarRegistry,
        erc721Master: masterERC
    }
});