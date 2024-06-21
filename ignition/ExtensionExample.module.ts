import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {XRDNASigners} from '../src';
import {network} from 'hardhat';
import Libraries from './Libraries.module';
import ExtensionsModule from "./Extensions.module";
import RegistrarFactoryModule from "./RegistrarFactory.module";

export default buildModule("ExtensionExample", (m) => {
    
    const libs = m.useModule(Libraries);
    const exts = m.useModule(ExtensionsModule);
    const fac = m.useModule(RegistrarFactoryModule);


    const xrdna = new XRDNASigners();
    const config = xrdna.deployment[network.config.chainId || 55555];
    const acct = config.registrarRegistryAdmin;

    const initExt = m.contract("InitExample", [fac.registrarFactory], {
        libraries: {
            LibFunds: libs.LibFunds,
            LibSigners: libs.LibSigners
        },
        after: [
            fac.registrarFactory,
            libs.LibFunds,
            libs.LibSigners
        ]
    });

    const ExtEx = m.contract("ExtensionExample", [[
            exts.fundsExtension, 
            exts.signersExtension,
            initExt
        ]], {
        
        after: [
            exts.fundsExtension,
            exts.signersExtension,
            initExt
        ]
    });
    return {
        extensionExample: ExtEx,
        factory: fac.registrarFactory
    };
});