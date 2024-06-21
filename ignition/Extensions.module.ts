import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import Libraries from './Libraries.module';

export default buildModule("Extensions", (m) => {

        const libs = m.useModule(Libraries);
        const sigExt = m.contract("SignersExtension", [], {
            libraries: {
                LibSigners: libs.LibSigners
            },
            after: [
                libs.LibSigners,
                libs.LibMixin
            ]
        });

        const fundsExt = m.contract("FundsExtension", [], {
            libraries: {
                LibFunds: libs.LibFunds,
            },
            after: [
                libs.LibFunds,
                libs.LibMixin
            ]
        });
        
        return {
            signersExtension: sigExt,
            fundsExtension: fundsExt
        }
});