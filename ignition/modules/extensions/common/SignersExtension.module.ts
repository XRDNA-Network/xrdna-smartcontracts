import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import Libraries from '../../libraries/Libraries.module';
import CoreModule from "../../core/Core.module";
import {abi as ABI} from '../../../../artifacts/contracts/interfaces/common/ISupportsSigners.sol/ISupportsSigners.json';

export const abi = ABI;

export default buildModule("SignersExtensions", (m) => {

        const libs = m.useModule(Libraries);
        const core = m.useModule(CoreModule).coreExtensionRegistry;
        const sigExt = m.contract("SignersExtension", [], {
            libraries: {
                LibSigners: libs.LibSigners,
                LibAccess: libs.LibAccess,
                LibExtensions: libs.LibExtensions
            },
            after: [
                core,
                libs.LibSigners,
                libs.LibExtensions,
                libs.LibAccess
            ]
        });
        m.call(core, "addExtension", [sigExt]);
        
        return {
            signersExtension: sigExt,
        }
});