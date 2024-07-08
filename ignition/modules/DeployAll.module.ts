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
import ExperienceRegistryModule from "./experience/registry/ExperienceRegistry.module";
import ExperienceModule from "./experience/instance/Experience.module";

import ERC20Asset from "./asset/instance/erc20/NTERC20Asset.module";
import ERC721Asset from "./asset/instance/erc721/NTERC721Asset.module";
import MultiAssetRegistryModule from "./asset/registry/MultiAssetRegistry.module";
import PortalRegistryModule from "./portal/PortalRegistry.module";

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

    const expReg = m.useModule(ExperienceRegistryModule);
    const exp = m.useModule(ExperienceModule);

    const erc20 = m.useModule(ERC20Asset);
    const erc721 = m.useModule(ERC721Asset);
    const multiAssetReg = m.useModule(MultiAssetRegistryModule);
    const portal = m.useModule(PortalRegistryModule);


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
        ...avatar,
        ...expReg,
        ...exp,
        ...erc20,
        ...erc721,
        ...multiAssetReg,
        ...portal
    }
});