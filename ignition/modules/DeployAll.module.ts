import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "./Libraries.module";
import ExtensionRegistryModule from "./ext-registry/ExtensionRegistry.module";
import RegistrarRegistryModule from "./registrar/registry/RegistrarRegistry.module";
import RegistrarModule from "./registrar/instance/Registrar.module";
import WorldRegistryModule from "./world/registry/WorldRegistry.module";
import WorldModule from "./world/instance/World.module";
import CompanyRegistryModule from "./company/registry/CompanyRegistry.module";
import CompanyModule from "./company/instance/Company.module";
import AvatarRegistryModule from "./avatar/registry/AvatarRegistry.module";
import AvatarModule from "./avatar/instance/Avatar.module";

export default buildModule("DeployAllModule", (m) => {

    const libs = m.useModule(LibrariesModule);
    const eReg = m.useModule(ExtensionRegistryModule);

    const registrarReg = m.useModule(RegistrarRegistryModule);
    const registrar = m.useModule(RegistrarModule);
    const worldReg = m.useModule(WorldRegistryModule);
    const world = m.useModule(WorldModule);
    const companyReg = m.useModule(CompanyRegistryModule);
    const company = m.useModule(CompanyModule);
    const avatarReg = m.useModule(AvatarRegistryModule);
    const avatar = m.useModule(AvatarModule);

    return {
        ...libs,
        ...eReg,
        ...registrar,
        ...registrarReg,
        ...worldReg,
        ...world,
        ...companyReg,
        ...company,
        ...avatarReg,
        ...avatar
    }
});