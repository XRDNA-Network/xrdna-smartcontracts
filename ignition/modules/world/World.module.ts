import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import WorldRegistryModule0_2 from "./WorldRegistry.module";
import WorldFactoryModule0_2 from "./WorldFactory.module";
import CompanyModule from "../company/Company.module";
import AvatarModule from "../avatar/Avatar.module";
import NTAssetMasterModule from "../asset/NTAssetMaster.module";
import PortalRegistryModule from "../portal/PortalRegistry.module";
import { NamedArtifactContractDeploymentFuture } from "@nomicfoundation/ignition-core";
import { RegistrarRegistry } from "../../../src";
import RegistrarRegistryModule from "../RegistrarRegistry.module";

export interface IWorldDeploymentResult {
    assetRegistry: NamedArtifactContractDeploymentFuture<"AssetRegistry">;
    assetFactory: NamedArtifactContractDeploymentFuture<"AssetFactory">;
    erc20Master: NamedArtifactContractDeploymentFuture<"NonTransferableERC20Asset">;
    erc721Master: NamedArtifactContractDeploymentFuture<"NonTransferableERC721Asset">;
    avatarRegistry: NamedArtifactContractDeploymentFuture<"AvatarRegistry">;
    avatarFactory: NamedArtifactContractDeploymentFuture<"AvatarFactory">;
    avatarMasterCopy: NamedArtifactContractDeploymentFuture<"Avatar">;
    companyRegistry: NamedArtifactContractDeploymentFuture<"CompanyRegistry">;
    companyFactory: NamedArtifactContractDeploymentFuture<"CompanyFactory">;
    companyMasterCopy: NamedArtifactContractDeploymentFuture<"Company">;
    experienceRegistry: NamedArtifactContractDeploymentFuture<"ExperienceRegistry">;
    experienceFactory: NamedArtifactContractDeploymentFuture<"ExperienceFactory">;
    portalRegistry: NamedArtifactContractDeploymentFuture<"PortalRegistry">;
    registrarRegistry: NamedArtifactContractDeploymentFuture<"RegistrarRegistry">;
    worldMasterCopy: NamedArtifactContractDeploymentFuture<"World0_2">;
    worldRegistry: NamedArtifactContractDeploymentFuture<"WorldRegistry0_2">;
    worldFactory: NamedArtifactContractDeploymentFuture<"WorldFactory0_2">;
}

export default buildModule("World0_2", (m) => {
    
    const reg = m.useModule(WorldRegistryModule0_2);
    const fac = m.useModule(WorldFactoryModule0_2);
    const comp = m.useModule(CompanyModule);
    const avatar = m.useModule(AvatarModule);
    const assets = m.useModule(NTAssetMasterModule);
    const portal = m.useModule(PortalRegistryModule);
    const registrar = m.useModule(RegistrarRegistryModule);
    
    const args = {
        worldFactory: fac.worldFactory,
        worldRegistry: reg.worldRegistry,
        companyRegistry: comp.companyRegistry,
        avatarRegistry: avatar.avatarRegistry
    }
    const master = m.contract("World0_2", [args], {
        after: [fac.worldFactory, reg.worldRegistry, avatar.avatarRegistry, comp.companyRegistry]
    });
    m.call(fac.worldFactory, "setImplementation", [master]);
    return {
        assetRegistry: assets.assetRegistry,
        assetFactory: assets.assetFactory,
        erc20Master: assets.erc20Master,
        erc721Master: assets.erc721Master,
        avatarRegistry: avatar.avatarRegistry,
        avatarFactory: avatar.avatarFactory,
        avatarMasterCopy: avatar.avatarMasterCopy,
        companyRegistry: comp.companyRegistry,
        companyFactory: comp.companyFactory,
        companyMasterCopy: comp.companyMasterCopy,
        experienceRegistry: comp.experienceRegistry,
        experienceFactory: comp.experienceFactory,
        portalRegistry: portal.portalRegistry,
        registrarRegistry: registrar.registry,
        worldMasterCopy: master,
        worldRegistry: reg.worldRegistry,
        worldFactory: fac.worldFactory
    }
});