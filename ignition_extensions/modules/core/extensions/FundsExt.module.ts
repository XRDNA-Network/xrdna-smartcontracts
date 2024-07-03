import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../libraries/Libraries.module";
import CoreExtRegistryModule from "../CoreExtRegistry.module";
import {abi as ABI} from '../../../../artifacts/contracts/core/extensions/funding/interfaces/IFundsExtension.sol/IFundsExtension.json';

export const abi = ABI;
export const name = "xr.core.FundsExt";

export default buildModule("FundsExtModule", (m) => {

        
        const libs = m.useModule(LibrariesModule);
        const coreReg = m.useModule(CoreExtRegistryModule).coreExtensionRegistry;
        
        const funds = m.contract("FundsExtension", [], {
            libraries: {
                LibAccess: libs.LibAccess,
                LibExtensions: libs.LibExtensions
            },
            after: [
                coreReg
            ]
        });
        return {
            fundsExtension: funds
        }
});