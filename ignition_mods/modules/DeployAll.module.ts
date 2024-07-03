import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "./Libraries.module";
import ControlChangeModule, {abi as ccABI} from "./mods/control-change/ControlChange.module";
import EntityRemovalModule, {abi as erABI} from "./mods/entity-removal/EntityRemoval.module";
import RegistrationModule, {abi as registrationABI} from "./mods/registration/Registration.module";
import RegistrarFactoryModule, {abi as regFactoryABI} from "./mods/registrar-factory/RegistrarFactory.module";
import RegistrarRegistryModule, {abi as regRegABI} from "./registrar/registry/RegistrarRegistry.module";
import RegistrarModule, {abi as registrarABI} from "./registrar/instance/Registrar.module";

export const allABI = {
    ControlChange: ccABI,
    EntityRemoval: erABI,
    Registration: registrationABI,
    RegistrarFactory: regFactoryABI,
    RegistrarRegistry: regRegABI,
    Registrar: registrarABI
}

export default buildModule("DeployAllModule", (m) => {

    const libs = m.useModule(LibrariesModule);
    const controlChange = m.useModule(ControlChangeModule);
    const entityRemoval = m.useModule(EntityRemovalModule);
    const registrationModule = m.useModule(RegistrationModule);
    const registrarFactory = m.useModule(RegistrarFactoryModule);
    const registrarRegistry = m.useModule(RegistrarRegistryModule);
    const registrar = m.useModule(RegistrarModule);

    return {
        ...libs,
        ...controlChange,
        ...entityRemoval,
        ...registrationModule,
        ...registrarFactory,
        ...registrarRegistry,
        ...registrar
    }
});