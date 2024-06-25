import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import FundsExtension, {abi as FundsABI} from './common/FundsExtension.module';
import SignersExtension, {abi as SigsABI} from './common/SignersExtension.module';
import {abi as CoreABI} from '../../../artifacts/contracts/core/interfaces/ICoreShell.sol/ICoreShell.json';

export const ExtensionMeta = {
    signersExtension: {
        abi: SigsABI,
        name: "xr.core.SignersExtension"
    },
    fundsExtension: {
        abi: FundsABI,
        name: "xr.core.FundsExtension"
    },
    core: {
        abi: CoreABI
    }
}

export default buildModule("Extensions", (m) => {

        const fundsExt = m.useModule(FundsExtension).fundsExtension;
        const sigExt = m.useModule(SignersExtension).signersExtension;
        
        
        return {
            signersExtension: sigExt,
            fundsExtension: fundsExt
        }
});