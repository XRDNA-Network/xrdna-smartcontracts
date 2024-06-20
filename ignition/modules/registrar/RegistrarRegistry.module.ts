import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {XRDNASigners} from '../../../src';
import {network} from 'hardhat';
import RegistrarFactoryModule from './RegistrarFactory.module';


export default buildModule("RegistrarRegistry", (m) => {
    
    const fac = m.useModule(RegistrarFactoryModule);
    const libRegistration = m.library("LibRegistration");

    const xrdna = new XRDNASigners();
    const config = xrdna.deployment[network.config.chainId || 55555];
    const acct = config.registrarRegistryAdmin;
    const regs = config.registrarRegistryOtherAdmins;
    const Registry = m.contract("RegistrarRegistry", [acct, regs, fac.registrarFactory], {
        libraries: {
            LibRegistration: libRegistration
        },
        after: [fac.registrarFactory]
    });
    m.call(fac.registrarFactory, "setAuthorizedRegistry", [Registry]);
    return {registrarRegistry: Registry};
});