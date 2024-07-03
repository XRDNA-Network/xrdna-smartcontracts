import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import BasicEntityExtModule, {abi as bABI, name as bName} from './extensions/BaseEntityExt.module';
import RemovableExtModule, {abi as rABI, name as rName} from "./extensions/RemovableExt.module";
import TermsOwnerExtModule, {abi as tABI, name as tName} from "./extensions/TermsOwnerExt.module";

export const EntityMetadata = {
    basicEntityExtensionABI: {
        abi: bABI,
        name: bName
    },
    removableExtension: {
        abi: rABI,
        name: rName,
    },
    termsOwnerExtension: {
        abi: tABI,
        name: tName
    }
}

export default buildModule("EntityModule", (m) => {
        
        const basicEntityExt = m.useModule(BasicEntityExtModule).basicEntityExtension;
        const removableExt = m.useModule(RemovableExtModule).removableExtension;
        const termsOwnerExt = m.useModule(TermsOwnerExtModule).termsOwnerExtension;

        return {
            basicEntityExtension: basicEntityExt,
            removableExtension: removableExt,
            termsOwnerExtension: termsOwnerExt
        }
});