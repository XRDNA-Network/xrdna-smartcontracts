import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {XRDNASigners} from '../../../src';
import {network} from 'hardhat';
import Libraries from '../libraries/Libraries.module';
import ExtensionsModule, {ExtensionMeta} from "../extensions/Extensions.module";
import CoreModule from "../core/Core.module";
import {generateABI} from '../ABIBuilder';

export default buildModule("ExtensionExample", (m) => {
    
    const libs = m.useModule(Libraries);
    const core = m.useModule(CoreModule).coreExtensionRegistry;
    const exts = m.useModule(ExtensionsModule);

    const xrdna = new XRDNASigners();
    const config = xrdna.deployment[network.config.chainId || 55555];
    const acct = config.registrarRegistryAdmin;

    const args = {
        owner: acct,
        otherAdmins: [],
        coreExtensionRegistry: core,
        extensionNames: [
            ExtensionMeta.fundsExtension.name,
            ExtensionMeta.signersExtension.name
        ]
    }

    const ExtEx = m.contract("ExtensionExample", [args], {
        libraries: {
            LibAccess: libs.LibAccess,
            LibExtensions: libs.LibExtensions
        },
        after: [
            exts.fundsExtension,
            exts.signersExtension,
        ]
    });
    generateABI({
        contractName: "ExtensionExample",
        abi: [
            ...ExtensionMeta.fundsExtension.abi,
            ...ExtensionMeta.signersExtension.abi,
            ...ExtensionMeta.core.abi
        ]
    })
    return {
        extensionExample: ExtEx,
        coreExtensionRegistry: core,
    };
});