import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import AssetRegistryModule from "./AssetRegistry.module";
import AssetFactoryModule from "./AssetFactory.module";
import AvatarRegistryModule from "../avatar/AvatarRegistry.module";
import ExperienceRegistryModule from "../experience/ExperienceRegistry.module";
import CompanyModule from "../company/Company.module";

export default buildModule("NTAssets", (m) => {
    
    const reg = m.useModule(AssetRegistryModule);
    const fac = m.useModule(AssetFactoryModule);
    const avatarRegistry = m.useModule(AvatarRegistryModule);
    const experienceRegistry = m.useModule(ExperienceRegistryModule);

    const args = {
        assetFactory: fac.assetFactory,
        assetRegistry: reg.assetRegistry,
        avatarRegistry: avatarRegistry.avatarRegistry,
        experienceRegistry: experienceRegistry.experienceRegistry
    }
    
    const afterSet = [
        fac.assetFactory, 
        reg.assetRegistry, 
        avatarRegistry.avatarRegistry, 
        experienceRegistry.experienceRegistry
    ]
    const masterERC20 = m.contract("NonTransferableERC20Asset", [args], {
        after: afterSet
    });
    const masterERC721 = m.contract("NonTransferableERC721Asset", [args], {
        after: afterSet
    });
    m.call(fac.assetFactory, "setERC20Implementation", [masterERC20]);
    m.call(fac.assetFactory, "setERC721Implementation", [masterERC721]);
    return {
        assetRegistry: reg.assetRegistry,
        assetFactory: fac.assetFactory,
        experienceRegistry: experienceRegistry.experienceRegistry,
        avatarRegistry: avatarRegistry.avatarRegistry,
        erc20Master: masterERC20, 
        erc721Master: masterERC721}
});