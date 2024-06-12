import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import AssetFactoryModule from "./ERC721Factory.module";
import {config} from '../../config';

export default buildModule("ERC721AssetRegistry", (m) => {
    
    const fac = m.useModule(AssetFactoryModule);
    const acct = m.getAccount(0);
    const Registry = m.contract("ERC721AssetRegistry", [acct, config.assetRegistryAdmins, fac.erc721Factory], {
        after: [fac.erc721Factory]
    });
    m.call(fac.erc721Factory, "setAuthorizedRegistry", [Registry]);
    return {assetRegistry: Registry};
});