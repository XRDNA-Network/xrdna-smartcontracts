import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {XRDNASigners} from '../src';
import {network} from 'hardhat';
import Libraries from './Libraries.module';
import RegFactory from './RegistrarFactory.module';

export default buildModule("RegistrarExample", (m) => {
    
    const libs = m.useModule(Libraries);
    const xrdna = new XRDNASigners();
    const config = xrdna.deployment[network.config.chainId || 55555];
    const acct = config.registrarRegistryAdmin;
    const fac = m.useModule(RegFactory);

    const libBasic = m.library("LibRegistrarBasicInfo");
    const libWorldReg = m.library("LibWorldRegistration", {
        libraries: {
            LibRegistration: libs.LibRegistration
        },
        after: [
            libs.LibRegistration
        ]
    });
    const libRegInit = m.library("LibRegistrarInit", {
        libraries: {
           // LibSigners: libs.LibSigners,
            //LibRegistrarBasicInfo: libBasic,
            //LibWorldRegistration: libWorldReg
            LibFunds: libs.LibFunds,
        },
        after: [
            libBasic,
            libWorldReg,
            libs.LibSigners,
            libs.LibFunds
        ]
    });

    const Registry = m.contract("RegistrarExample", [acct, fac.registrarFactory], {
        libraries: {
            LibSigners: libs.LibSigners,
            LibHook: libs.LibHook,
            LibFunds: libs.LibFunds,
            LibRegistrarInit: libRegInit
        },
        after: [
            libs.LibMixin,
            libRegInit,
            fac.registrarFactory
        ]
    });
    return {
        registrarExample: Registry,
        factory: fac.registrarFactory
    };
});