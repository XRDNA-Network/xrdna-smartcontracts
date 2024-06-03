import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import AssetFactoryModule from "./AssetFactory.module";
import {config} from '../config';

export default buildModule("WorldRegistry", (m) => {
    
    const fac = m.useModule(AssetFactoryModule);
    
    const Registry = m.contract("AssetRegistry", [config.assetRegistryAdmins, fac.assetFactory], {
        after: [fac.assetFactory]
    });
    m.call(fac.assetFactory, "setAssetRegistry", [Registry]);
    return {assetRegistry: Registry};
});