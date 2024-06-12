import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import AvatarRegistryModule from "../../avatar/AvatarRegistry.module";
import ExperienceRegistryModule from "../../experience/ExperienceRegistry.module";
import NTAssetProxyModule from "./NTERC721Proxy.module";

const VERSION = 1;
export default buildModule("NTERC721Asset", (m) => {
    
    const proxy = m.useModule(NTAssetProxyModule);
    const avatarRegistry = m.useModule(AvatarRegistryModule);
    const experienceRegistry = m.useModule(ExperienceRegistryModule);

    const args = {
        assetFactory: proxy.erc721Factory,
        assetRegistry: proxy.erc721Registry,
        avatarRegistry: avatarRegistry.avatarRegistry,
        experienceRegistry: experienceRegistry.experienceRegistry
    }
    
    const afterSet = [
        proxy.erc721Factory, 
        proxy.erc721Registry, 
        avatarRegistry.avatarRegistry, 
        experienceRegistry.experienceRegistry
    ]
    const masterERC = m.contract("NTERC721Asset", [args], {
        after: afterSet
    });
    m.call(proxy.erc721Factory, "setImplementation", [masterERC, VERSION]);
    return {
        erc721Registry: proxy.erc721Registry,
        erc721Factory: proxy.erc721Factory,
        experienceRegistry: experienceRegistry.experienceRegistry,
        avatarRegistry: avatarRegistry.avatarRegistry,
        erc721Master: masterERC
    }
});