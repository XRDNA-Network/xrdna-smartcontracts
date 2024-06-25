import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import Libraries from '../../libraries/Libraries.module';
import CoreModule from '../../core/Core.module';
import {abi as ABI} from '../../../../artifacts/contracts/interfaces/common/ISupportsFunds.sol/ISupportsFunds.json';

export const abi = ABI;

export default buildModule("FundsExtension", (m) => {

        const libs = m.useModule(Libraries);
        const core = m.useModule(CoreModule).coreExtensionRegistry;
        const fundsExt = m.contract("FundsExtension", [], {
            libraries: {
                LibFunds: libs.LibFunds,
                LibAccess: libs.LibAccess,
                LibExtensions: libs.LibExtensions
            },
            after: [
                core,
                libs.LibFunds,
                libs.LibExtensions,
                libs.LibAccess
            ]
        });
        m.call(core, "addExtension", [fundsExt]);
        return {
            fundsExtension: fundsExt
        }
});