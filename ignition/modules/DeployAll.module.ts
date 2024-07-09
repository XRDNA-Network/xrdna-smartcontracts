import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "./Libraries.module";
import RegistrarRegistryModule from "./registrar/registry/RegistrarRegistryProxy.module";
import RegistrarModule from "./registrar/instance/RegistrarProxy.module";
import WorldRegistryModule from "./world/registry/WorldRegistryProxy.module";
import WorldModule from "./world/instance/WorldProxy.module";
import CompanyRegistryModule from "./company/registry/CompanyRegistryProxy.module";
import CompanyModule from "./company/instance/CompanyProxy.module";
import AvatarRegistryModule from "./avatar/registry/AvatarRegistryProxy.module";
import AvatarModule from "./avatar/instance/AvatarProxy.module";
import ExperienceRegistryModule from "./experience/registry/ExperienceRegistryProxy.module";
import ExperienceModule from "./experience/instance/ExperienceProxy.module";

import ERC20Asset from "./asset/instance/erc20/ERC20AssetProxy.module";
import ERC721Asset from "./asset/instance/erc721/ERC721AssetProxy.module";
import ERC20RegistryProxyModule from "./asset/registry/ERC20RegistryProxy.module";
import ERC721RegistryProxyModule from "./asset/registry/ERC721RegistryProxy.module";
import MultiAssetRegistryModule from "./asset/registry/MultiAssetRegistry.module";
import PortalRegistryModule from "./portal/PortalRegistryProxy.module";

export default buildModule("DeployAllModule", (m) => {

    const libs = m.useModule(LibrariesModule);

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
    const erc20Reg = m.useModule(ERC20RegistryProxyModule);
    const erc721Reg = m.useModule(ERC721RegistryProxyModule);
    const multiAssetReg = m.useModule(MultiAssetRegistryModule);
    const portal = m.useModule(PortalRegistryModule);

    return {
        ...libs,
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
        ...erc20Reg,
        ...erc721Reg,
        ...multiAssetReg,
        ...portal
    }
});