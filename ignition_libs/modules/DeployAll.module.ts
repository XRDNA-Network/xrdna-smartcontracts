import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "./Libraries.module";
import RegistrarRegistryModule, {abi as regRegABI} from "./registrar/registry/RegistrarRegistry.module";
import RegistrarModule, {abi as registrarABI} from "./registrar/instance/Registrar.module";
import WorldRegistryModule, {abi as worldRegistryABI} from "./world/registry/WorldRegistry.module";
import WorldModule, {abi as worldABI} from "./world/instance/World.module";

export const allABI = {
    RegistrarRegistry: regRegABI,
    Registrar: registrarABI,
    World: worldABI,
    WorldRegistry: worldRegistryABI
}

export default buildModule("DeployAllModule", (m) => {

    const libs = m.useModule(LibrariesModule);
    const registrarRegistry = m.useModule(RegistrarRegistryModule);
    const registrar = m.useModule(RegistrarModule);
    const worldRegistry = m.useModule(WorldRegistryModule);
    const world = m.useModule(WorldModule);

    return {
        ...libs,
        ...registrarRegistry,
        ...registrar,
        ...worldRegistry,
        ...world
    }
});