import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import WorldFactoryModule0_2 from "./WorldFactory.module";
import RegistrarRegistryModule from '../RegistrarRegistry.module';

import {config} from '../config';

export default buildModule("WorldRegistry0_2", (m) => {
    
    const fac = m.useModule(WorldFactoryModule0_2);
    const registrarRegistry = m.useModule(RegistrarRegistryModule);
    const acct = m.getAccount(0);
    const args = {
        vectorAuthority: config.vectorAddressAuthority,
        worldFactory: fac.worldFactory,
        registrarRegistry: registrarRegistry.registry,
        defaultAdmin: acct,
        oldWorldRegistry: "0xD070dB63B8051895ff683779a1b33B3fbB9c966C"
    }
    const Registry = m.contract("WorldRegistry0_2", [args], {
        after: [fac.worldFactory]
    });
    m.call(fac.worldFactory, "setAuthorizedRegistry", [Registry]);
    return {worldRegistry: Registry};
});