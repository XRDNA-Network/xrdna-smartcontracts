import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import AssetRegistryModule from "./ERC721Registry.module";
import AssetFactoryModule from "./ERC721Factory.module";

export default buildModule("NTERC721Proxy", (m) => {
    
    const reg = m.useModule(AssetRegistryModule);
    const fac = m.useModule(AssetFactoryModule);

    const args = {
        factory: fac.erc721Factory,
        registry: reg.assetRegistry,
    }
    
    const afterSet = [
        fac.erc721Factory, 
        reg.assetRegistry, 
    ]
    const masterERC20 = m.contract("NTERC721Proxy", [args], {
        after: afterSet
    });
    m.call(fac.erc721Factory, "setProxyImplementation", [masterERC20]);
    return {
        erc721Registry: reg.assetRegistry,
        erc721Factory: fac.erc721Factory,
        erc721ProxyMaster: masterERC20,}
});