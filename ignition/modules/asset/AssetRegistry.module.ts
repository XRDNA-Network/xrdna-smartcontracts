import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import AssetFactoryModule from "./AssetFactory.module";
import {config} from '../config';

export default buildModule("AssetRegistry", (m) => {
    
    const fac = m.useModule(AssetFactoryModule);
    const acct = m.getAccount(0);
    const Registry = m.contract("AssetRegistry", [acct, config.assetRegistryAdmins, fac.assetFactory], {
        after: [fac.assetFactory]
    });
    m.call(fac.assetFactory, "setAuthorizedRegistry", [Registry]);
    return {assetRegistry: Registry};
});