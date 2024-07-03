import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import CoreModule from "./core/Core.module";
import RegistryModule from "./registry/Registry.module";
import RegistrarModule from "./registrar/Registrar.module";

export default buildModule("DeployAllModule", (m) => {

    const core = m.useModule(CoreModule);
    const registry = m.useModule(RegistryModule);
    const registrar = m.useModule(RegistrarModule);

    return {
        ...core,
        ...registry,
        ...registrar
    }
});