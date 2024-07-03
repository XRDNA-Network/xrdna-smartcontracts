import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {XRDNASigners} from '../../../../src';
import {network} from 'hardhat';
import Libraries from '../../libraries/Libraries.module';
import {generateABI} from '../../ABIBuilder';
import {abi} from '../../../../artifacts/contracts/registrar/registry/RegistryExtMgr.sol/RegistryExtMgr.json';
import CoreExtRegistryModule from "../../core/CoreExtRegistry.module";
import {abi as regABI} from '../../../../artifacts/contracts/registry/extensions/registration/interfaces/IRegistration.sol/IRegistration.json';
import {abi as erABI} from '../../../../artifacts/contracts/registry/extensions/entity-removal/interfaces/IEntityRemovalExtension.sol/IEntityRemovalExtension.json';
import {abi as toABI} from '../../../../artifacts/contracts/entity/extensions/terms-owner/interfaces/ITermsOwnerExtension.sol/ITermsOwnerExtension.json';
import {abi as seABI} from '../../../../artifacts/contracts/core/extensions/signers/interfaces/ISignersExtension.sol/ISignersExtension.json';
import {abi as coreABI} from '../../../../artifacts/contracts/core/interfaces/ICoreShell.sol/ICoreShell.json';
import {deployAndInstall} from '../../extensions/Extensions.module';
import { Future } from "@nomicfoundation/ignition-core";

export const registryABI = [
    ...coreABI,
    ...regABI,
    ...erABI,
    ...toABI,
    ...seABI
]



export default buildModule("RegistryExtMgrModule", (m) => {
    
    const libs = m.useModule(Libraries);

    const xrdna = new XRDNASigners();
    const config = xrdna.deployment[network.config.chainId || 55555];
    const acct = config.registrarExtensionManagerAdmin;
    const others = config.registrarExtensionManagerOtherAdmins;
    const coreReg = m.useModule(CoreExtRegistryModule).coreExtensionRegistry;
    const r = deployAndInstall();

    m.useModule(r.ignitionModule);

    const allExts: Future[] = [];
    r.ignitionModule.futures.forEach((f) => {
        allExts.push(f);
    });

    const args = {
        owner: acct,
        otherAdmins: others || [],
        coreExtensionRegistry: coreReg,
    }

    const extMgr = m.contract("RegistryExtMgr", [args], {
        libraries: {
            LibAccess: libs.LibAccess,
            LibExtensions: libs.LibExtensions
        },
        after: [
            coreReg,
            libs.LibExtensions,
            ...allExts
        ]
    });
    generateABI({
        contractName: "RegistryExtMgr",
        abi: abi
    })
    return {
        registrarRegistryExtentionManager: extMgr
    };
});