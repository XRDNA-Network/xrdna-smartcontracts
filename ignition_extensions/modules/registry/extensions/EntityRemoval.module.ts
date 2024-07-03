import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { XRDNASigners } from "../../../../src";
import {ethers, network} from 'hardhat';
import LibrariesModule from "../../libraries/Libraries.module";
import CoreExtRegistryModule from "../../core/CoreExtRegistry.module";
import {abi as ABI} from '../../../../artifacts/contracts/registry/extensions/entity-removal/interfaces/IEntityRemovalExtension.sol/IEntityRemovalExtension.json';

export const abi = ABI;
export const name = "xr.registration.EntityRemovalExt";

export default buildModule("EntityRemovalExtModule", (m) => {

        
        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).coreExtensionRegistry;
        
        const er = m.contract("EntityRemovalExt", [], {
            libraries: {
                LibAccess: libs.LibAccess,
                LibExtensions: libs.LibExtensions,
            },
            after: [
                coreReg,
                libs.LibExtensions,
                libs.LibRegistration
            ]
        });
        
        return {
            entityRemovalExtension: er
        }
});