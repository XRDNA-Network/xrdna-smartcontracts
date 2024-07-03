import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import ControllerChangeModule, {abi as cABI, name as cName} from "./extensions/ControllerChange.module";
import EntityRemovalModule, {abi as erABI, name as erName} from "./extensions/EntityRemoval.module";
import RegistrationExtModule, {abi as rABI, name as rName} from "./extensions/RegistrationExt.module";

export const RegistryMetadata = {
    controllerChangeExtension: {
        abi: cABI,
        name: cName
    },
    entityRemovalExtension: {
        abi: erABI,
        name: erName
    },
    registrationExtension: {
        abi: rABI,
        name: rName
    }
}

export default buildModule("RegistryModule", (m) => {
        
         const controllerChange = m.useModule(ControllerChangeModule).controllerChangeExtension;
          const entityRemoval = m.useModule(EntityRemovalModule).entityRemovalExtension;
          const registration = m.useModule(RegistrationExtModule).registrationExtension;
    
          return {
                controllerChangeExtension: controllerChange,
                entityRemovalExtension: entityRemoval,
                registrationExtension: registration
          }
});