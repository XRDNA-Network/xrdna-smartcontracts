import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import AssetFactoryModule from "./ERC20Factory.module";
import {config} from '../../config';

export default buildModule("ERC20AssetRegistry", (m) => {
    
    const fac = m.useModule(AssetFactoryModule);
    const acct = m.getAccount(0);
    const Registry = m.contract("ERC20AssetRegistry", [acct, config.assetRegistryAdmins, fac.erc20Factory], {
        after: [fac.erc20Factory]
    });
    m.call(fac.erc20Factory, "setAuthorizedRegistry", [Registry]);
    return {assetRegistry: Registry};
});