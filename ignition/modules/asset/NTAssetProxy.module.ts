import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import AssetRegistryModule from "./AssetRegistry.module";
import AssetFactoryModule from "./AssetFactory.module";

export default buildModule("NTAssetsProxies", (m) => {
    
    const reg = m.useModule(AssetRegistryModule);
    const fac = m.useModule(AssetFactoryModule);

    const args = {
        factory: fac.assetFactory,
        registry: reg.assetRegistry,
    }
    
    const afterSet = [
        fac.assetFactory, 
        reg.assetRegistry, 
    ]
    const masterERC20 = m.contract("NTERC20Proxy", [args], {
        after: afterSet
    });
    const masterERC721 = m.contract("NTERC721Proxy", [args], {
        after: afterSet
    });
    m.call(fac.assetFactory, "setERC20ProxyImplementation", [masterERC20]);
    m.call(fac.assetFactory, "setERC721ProxyImplementation", [masterERC721]);
    return {
        assetRegistry: reg.assetRegistry,
        assetFactory: fac.assetFactory,
        erc20ProxyMaster: masterERC20, 
        erc721ProxyMaster: masterERC721}
});