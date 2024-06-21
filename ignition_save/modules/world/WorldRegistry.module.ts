import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import WorldFactoryModule from "./WorldFactory.module";
import RegistrarRegistryModule from '../registrar/RegistrarRegistry.module';
import {XRDNASigners} from '../../../src';
import {network} from 'hardhat';

export default buildModule("WorldRegistry", (m) => {
    
    const xrdna = new XRDNASigners();
    const config = xrdna.deployment[network.config.chainId || 55555];
    const acct = config.worldRegistryAdmin;
    const admins = config.worldRegistryOtherAdmins;
    const vector = config.vectorAddressAuthority;

    const fac = m.useModule(WorldFactoryModule);
    const registrarRegistry = m.useModule(RegistrarRegistryModule);
    
    const args = {
        vectorAuthority: vector,
        worldFactory: fac.worldFactory,
        registrarRegistry: registrarRegistry.registrarRegistry,
        defaultAdmin: acct,
        otherAdmins: admins,
    }
    const Registry = m.contract("WorldRegistry", [args], {
        after: [fac.worldFactory]
    });
    m.call(fac.worldFactory, "setAuthorizedRegistry", [Registry]);
    return {worldRegistry: Registry};
});