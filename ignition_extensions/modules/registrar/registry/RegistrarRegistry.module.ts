import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {XRDNASigners} from '../../../../src';
import {network} from 'hardhat';
import Libraries from '../../libraries/Libraries.module';
import RegistryExtMgr, {registryABI} from './RegistryExtMgr.module';
import CoreExtRegistryModule from "../../core/CoreExtRegistry.module";
import RegistrarFactoryModule from "../factory/RegistrarFactory.module";
import { generateABI } from "../../ABIBuilder";


export default buildModule("RegistrarRegistryModule", (m) => {
    
    const libs = m.useModule(Libraries);
    const core = m.useModule(CoreExtRegistryModule).coreExtensionRegistry;
    const extMgr = m.useModule(RegistryExtMgr).registrarRegistryExtentionManager;
    const factory = m.useModule(RegistrarFactoryModule).registrarFactory;

    const xrdna = new XRDNASigners();
    const config = xrdna.deployment[network.config.chainId || 55555];
    const owner = config.registrarRegistryAdmin;
    const others = config.registrarRegistryOtherAdmins;

    const args = {
        owner,
        otherAdmins: others || [],
        coreExtensionRegistry: core,
        extensionManager: extMgr,
        entityCreator: factory,
        registrarTerms: {
            fee: 0n,
            coveragePeriodDays: 0n,
            gracePeriodDays: 30n //only for deactivation grace period before removal
        }
    }

    const regReg = m.contract("RegistrarRegistry", [args], {
        libraries: {
            LibAccess: libs.LibAccess,
            LibExtensions: libs.LibExtensions
        },
        after: [
            factory,
            extMgr,
        ]
    });
    generateABI({
        contractName: "RegistrarRegistry",
        abi: registryABI
    })
    m.call(factory, 'setAuthorizedRegistry', [regReg])
    return {
        registrarRegistry: regReg
    };
});