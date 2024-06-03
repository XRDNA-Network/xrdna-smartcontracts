import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import AssetRegistryModule from "./AssetRegistry.module";
import AssetFactoryModule from "./AssetFactory.module";

export default buildModule("NTAssets", (m) => {
    
    const reg = m.useModule(AssetRegistryModule);
    const fac = m.useModule(AssetFactoryModule);
    
    const masterERC20 = m.contract("NonTransferableERC20Asset", [fac.assetFactory, reg.assetRegistry], {
        after: [fac.assetFactory, reg.assetRegistry]
    });
    const masterERC721 = m.contract("NonTransferableERC721Asset", [fac.assetFactory, reg.assetRegistry], {
        after: [fac.assetFactory, reg.assetRegistry]
    });
    m.call(fac.assetFactory, "setERC20Implementation", [masterERC20]);
    m.call(fac.assetFactory, "setERC721Implementation", [masterERC721]);
    return {erc20Master: masterERC20, erc721Master: masterERC721}
});