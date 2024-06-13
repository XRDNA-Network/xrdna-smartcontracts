import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import AssetFactoryModule from "./ERC20Factory.module";
import {XRDNASigners} from '../../../../src';
import {network} from 'hardhat';

export default buildModule("ERC20AssetRegistry", (m) => {
    
    const fac = m.useModule(AssetFactoryModule);
    const xrdna = new XRDNASigners();
    const deployConfig = xrdna.deployment[network.config.chainId || 55555];
    const acct = deployConfig.assetRegistryAdmin;
    const others = deployConfig.assetRegistryOtherAdmins;
    const Registry = m.contract("ERC20AssetRegistry", [acct, others, fac.erc20Factory], {
        after: [fac.erc20Factory]
    });
    m.call(fac.erc20Factory, "setAuthorizedRegistry", [Registry]);
    return {assetRegistry: Registry};
});