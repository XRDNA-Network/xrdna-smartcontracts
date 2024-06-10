import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import AvatarRegistryModule from "../avatar/AvatarRegistry.module";
import ExperienceRegistryModule from "../experience/ExperienceRegistry.module";
import NTAssetProxyModule from "./NTAssetProxy.module";

export default buildModule("NTAssets", (m) => {
    
    const proxies = m.useModule(NTAssetProxyModule);
    const avatarRegistry = m.useModule(AvatarRegistryModule);
    const experienceRegistry = m.useModule(ExperienceRegistryModule);

    const args = {
        assetFactory: proxies.assetFactory,
        assetRegistry: proxies.assetRegistry,
        avatarRegistry: avatarRegistry.avatarRegistry,
        experienceRegistry: experienceRegistry.experienceRegistry
    }
    
    const afterSet = [
        proxies.assetFactory, 
        proxies.assetRegistry, 
        avatarRegistry.avatarRegistry, 
        experienceRegistry.experienceRegistry
    ]
    const masterERC20 = m.contract("NonTransferableERC20Asset", [args], {
        after: afterSet
    });
    const masterERC721 = m.contract("NonTransferableERC721Asset", [args], {
        after: afterSet
    });
    m.call(proxies.assetFactory, "setERC20Implementation", [masterERC20]);
    m.call(proxies.assetFactory, "setERC721Implementation", [masterERC721]);
    return {
        assetRegistry: proxies.assetRegistry,
        assetFactory: proxies.assetFactory,
        experienceRegistry: experienceRegistry.experienceRegistry,
        avatarRegistry: avatarRegistry.avatarRegistry,
        erc20Master: masterERC20, 
        erc721Master: masterERC721}
});