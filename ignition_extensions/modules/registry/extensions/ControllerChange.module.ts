import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { XRDNASigners } from "../../../../src";
import {ethers, network} from 'hardhat';
import LibrariesModule from "../../libraries/Libraries.module";
import CoreExtRegistryModule from "../../core/CoreExtRegistry.module";
import {abi as ABI} from '../../../../artifacts/contracts/registry/extensions/controller-change/interfaces/IControllerChangeExtension.sol/IControllerChangeExtension.json';

export const abi = ABI;
export const name = "xr.registration.ControllerChangeExt";

export default buildModule("ControllerChangeExtModule", (m) => {

        
        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).coreExtensionRegistry;
        
        const cc = m.contract("ControllerChangeExt", [], {
            libraries: {
                LibAccess: libs.LibAccess,
                LibExtensions: libs.LibExtensions
            },
            after: [
                coreReg,
                libs.LibExtensions,
                libs.LibRegistration
            ]
        });
        
        return {
            controllerChangeExtension: cc
        }
});