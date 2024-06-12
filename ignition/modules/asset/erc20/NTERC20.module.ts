import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import AvatarRegistryModule from "../../avatar/AvatarRegistry.module";
import NTAssetProxyModule from "./NTERC20Proxy.module";
import CompanyRegistryModule from "../../company/CompanyRegistry.module";

const VERSION = 1;
export default buildModule("NTERC20Asset", (m) => {
    
    const proxy = m.useModule(NTAssetProxyModule);
    const avatarRegistry = m.useModule(AvatarRegistryModule);
    const companyRegistry = m.useModule(CompanyRegistryModule);

    const args = {
        assetFactory: proxy.erc20Factory,
        assetRegistry: proxy.erc20Registry,
        avatarRegistry: avatarRegistry.avatarRegistry,
        companyRegistry: companyRegistry.companyRegistry
    }
    
    const afterSet = [
        proxy.erc20Factory, 
        proxy.erc20Registry, 
        avatarRegistry.avatarRegistry, 
        companyRegistry.companyRegistry
    ]
    const masterERC20 = m.contract("NTERC20Asset", [args], {
        after: afterSet
    });
    m.call(proxy.erc20Factory, "setImplementation", [masterERC20, VERSION]);
    return {
        erc20Registry: proxy.erc20Registry,
        erc20Factory: proxy.erc20Factory,
        companyRegistry: companyRegistry.companyRegistry,
        avatarRegistry: avatarRegistry.avatarRegistry,
        erc20Master: masterERC20
    }
});