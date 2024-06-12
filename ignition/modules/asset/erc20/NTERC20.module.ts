import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import AvatarRegistryModule from "../../avatar/AvatarRegistry.module";
import ExperienceRegistryModule from "../../experience/ExperienceRegistry.module";
import NTAssetProxyModule from "./NTERC20Proxy.module";

export default buildModule("NTERC20Assets", (m) => {
    
    const proxy = m.useModule(NTAssetProxyModule);
    const avatarRegistry = m.useModule(AvatarRegistryModule);
    const experienceRegistry = m.useModule(ExperienceRegistryModule);

    const args = {
        assetFactory: proxy.erc20Factory,
        assetRegistry: proxy.erc20Registry,
        avatarRegistry: avatarRegistry.avatarRegistry,
        experienceRegistry: experienceRegistry.experienceRegistry
    }
    
    const afterSet = [
        proxy.erc20Factory, 
        proxy.erc20Registry, 
        avatarRegistry.avatarRegistry, 
        experienceRegistry.experienceRegistry
    ]
    const masterERC20 = m.contract("NTERC20Asset", [args], {
        after: afterSet
    });
    m.call(proxy.erc20Factory, "setImplementation", [masterERC20]);
    return {
        erc20Registry: proxy.erc20Registry,
        erc20Factory: proxy.erc20Factory,
        experienceRegistry: experienceRegistry.experienceRegistry,
        avatarRegistry: avatarRegistry.avatarRegistry,
        erc20Master: masterERC20
    }
});