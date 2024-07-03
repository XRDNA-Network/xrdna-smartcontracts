import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import CoreExtRegistryModule, {abi as CoreRegABI} from "./CoreExtRegistry.module";
import FundsExtModule, {abi as FundsABI, name as fName} from "./extensions/FundsExt.module";   
import SignersExtModule, {abi as SignersABI, name as sName} from "./extensions/SignersExt.module";

export const CoreMetadata = {
    coreExtRegistryABI: {
        abi: CoreRegABI
    },
    fundsExtension: {
        abi: FundsABI,
        name: fName,
    },
    signersExtension: {
        abi: SignersABI,
        name: sName
    }
}

export default buildModule("CoreModule", (m) => {
        
        const coreReg = m.useModule(CoreExtRegistryModule).coreExtensionRegistry;
        const fundsExt = m.useModule(FundsExtModule).fundsExtension;
        const signersExt = m.useModule(SignersExtModule).signersExtension;

        return {
            coreExtensionRegistry: coreReg,
            fundsExtension: fundsExt,
            signersExtension: signersExt
        }
});