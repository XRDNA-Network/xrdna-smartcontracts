import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {XRDNASigners} from '../../../../src';
import {network} from 'hardhat';
import {ethers} from 'ethers';
import Libraries from '../../libraries/Libraries.module';
import RegistrarExtMgr, {registrarABI} from './RegistrarExtMgr.module';
import CoreExtRegistryModule from "../../core/CoreExtRegistry.module";
import RegistrarFactoryModule from "../factory/RegistrarFactory.module";
import { generateABI } from "../../ABIBuilder";
import RegistrarProxyModule from "./RegistrarProxy.module";
import RegistrarRegistryModule from "../registry/RegistrarRegistry.module";

const VERSION = 1;

export default buildModule("RegistrarInstanceModule", (m) => {
    
    const libs = m.useModule(Libraries);
    const core = m.useModule(CoreExtRegistryModule).coreExtensionRegistry;
    const regReg = m.useModule(RegistrarRegistryModule).registrarRegistry;
    const extMgr = m.useModule(RegistrarExtMgr).registrarExtensionManager;
    const factory = m.useModule(RegistrarFactoryModule).registrarFactory;
    const proxy = m.useModule(RegistrarProxyModule).registrarProxy;

    /**
     * address owner; //can be zero
    address[] otherAdmins; //can be empty
    address extensionManager;
    address factory;
    address registrar;
    //address worldRegistry
     */
    const args = {
        owner: ethers.ZeroAddress,
        otherAdmins: [],
        extensionManager: extMgr,
        factory: factory,
        registry: regReg
    }


    const reg = m.contract("Registrar", [args], {
        libraries: {
            LibAccess: libs.LibAccess,
            LibExtensions: libs.LibExtensions
        },
        after: [
            core,
            factory,
            extMgr,
            regReg,
            proxy
        ]
    });
    generateABI({
        contractName: "Registrar",
        abi: registrarABI
    });
    m.call(factory, "setImplementation", [reg, VERSION])
    return {
        registrar: reg
    };
});