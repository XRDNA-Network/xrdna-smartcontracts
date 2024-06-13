import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import WorldFactoryModuleV2 from "./WorldFactory.module";
import RegistrarRegistryModule from '../RegistrarRegistry.module';
import {XRDNASigners} from '../../../src';
import {network} from 'hardhat';

export default buildModule("WorldRegistryV2", (m) => {
    
    const xrdna = new XRDNASigners();
    const config = xrdna.deployment[network.config.chainId || 55555];
    const acct = config.worldRegistryAdmin;
    const admins = config.worldRegistryOtherAdmins;
    const vector = config.vectorAddressAuthority;

    const fac = m.useModule(WorldFactoryModuleV2);
    const registrarRegistry = m.useModule(RegistrarRegistryModule);
    
    const args = {
        vectorAuthority: vector,
        worldFactory: fac.worldFactory,
        registrarRegistry: registrarRegistry.registry,
        defaultAdmin: acct,
        otherAdmins: admins,
        oldWorldRegistry: "0xD070dB63B8051895ff683779a1b33B3fbB9c966C"
    }
    const Registry = m.contract("WorldRegistryV2", [args], {
        after: [fac.worldFactory]
    });
    m.call(fac.worldFactory, "setAuthorizedRegistry", [Registry]);
    return {worldRegistry: Registry};
});