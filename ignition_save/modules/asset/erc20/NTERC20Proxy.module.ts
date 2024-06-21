import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import AssetRegistryModule from "./ERC20Registry.module";
import AssetFactoryModule from "./ERC20Factory.module";

export default buildModule("NTERC20Proxy", (m) => {
    
    const reg = m.useModule(AssetRegistryModule);
    const fac = m.useModule(AssetFactoryModule);

    const args = {
        factory: fac.erc20Factory,
        registry: reg.assetRegistry,
    }
    
    const afterSet = [
        fac.erc20Factory, 
        reg.assetRegistry, 
    ]
    const masterERC20 = m.contract("NTERC20Proxy", [args], {
        after: afterSet
    });
    m.call(fac.erc20Factory, "setProxyImplementation", [masterERC20]);
    return {
        erc20Registry: reg.assetRegistry,
        erc20Factory: fac.erc20Factory,
        erc20ProxyMaster: masterERC20,}
});