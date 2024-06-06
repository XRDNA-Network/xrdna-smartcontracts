import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import WorldFactoryModule0_2 from "./WorldFactory.module";
import {config} from '../config';

export default buildModule("WorldRegistry0_2", (m) => {
    
    const fac = m.useModule(WorldFactoryModule0_2);
    const acct = m.getAccount(0);
    const Registry = m.contract("WorldRegistry0_2", [acct, config.assetRegistryAdmins, fac.worldFactory], {
        after: [fac.worldFactory]
    });
    m.call(fac.worldFactory, "setAuthorizedRegistry", [Registry]);
    return {worldRegistry: Registry};
});