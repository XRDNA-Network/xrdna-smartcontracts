import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import CompanyModule from "../company/Company.module";
import AvatarModule from "../avatar/Avatar.module";
import MultiAssetModule from "../asset/MultiAssetRegistry.module";
import PortalRegistryModule from "../portal/PortalRegistry.module";
import { NamedArtifactContractDeploymentFuture } from "@nomicfoundation/ignition-core";
import RegistrarRegistryModule from "../RegistrarRegistry.module";
import WorldProxyModule from './WorldProxy.module';
import { experience } from "../../../typechain-types/contracts";

export interface IWorldDeploymentResult {
    erc20AssetRegistry: NamedArtifactContractDeploymentFuture<"ERC20AssetRegistry">;
    erc20AssetFactory: NamedArtifactContractDeploymentFuture<"ERC20AssetFactory">;
    erc721AssetRegistry: NamedArtifactContractDeploymentFuture<"ERC721AssetRegistry">;
    erc721AssetFactory: NamedArtifactContractDeploymentFuture<"ERC721AssetFactory">;
    erc20Master: NamedArtifactContractDeploymentFuture<"NTERC20Asset">;
    erc721Master: NamedArtifactContractDeploymentFuture<"NTERC721Asset">;
    multiAssetRegistry: NamedArtifactContractDeploymentFuture<"MultiAssetRegistry">;
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
    worldMasterCopy: NamedArtifactContractDeploymentFuture<"WorldV2">;
    worldRegistry: NamedArtifactContractDeploymentFuture<"WorldRegistryV2">;
    worldFactory: NamedArtifactContractDeploymentFuture<"WorldFactoryV2">;
}

const VERSION = 2;
export default buildModule("WorldV2", (m) => {
    
    const proxy = m.useModule(WorldProxyModule);
    
    const comp = m.useModule(CompanyModule);
    const avatar = m.useModule(AvatarModule);
    const assets = m.useModule(MultiAssetModule);
    const portal = m.useModule(PortalRegistryModule);
    const registrar = m.useModule(RegistrarRegistryModule);
    
    const args = {
        worldFactory: proxy.worldFactory,
        worldRegistry: proxy.worldRegistry,
        companyRegistry: comp.companyRegistry,
        avatarRegistry: avatar.avatarRegistry,
        experienceRegistry: comp.experienceRegistry,
    }
    
    const master = m.contract("WorldV2", [args], {
        after: [
            proxy.worldFactory, 
            proxy.worldRegistry, 
            avatar.avatarRegistry, 
            comp.companyRegistry,
            comp.experienceRegistry
        ]
    });
    m.call(proxy.worldFactory, "setImplementation", [master, VERSION]);
    return {
        erc20Registry: assets.erc20Registry,
        erc20Factory: assets.erc20Factory,
        erc721Registry: assets.erc721Registry,
        erc721Factory: assets.erc721Factory,
        erc20Master: assets.erc20Master,
        erc721Master: assets.erc721Master,
        multiAssetRegistry: assets.multiAssetRegistry,
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
        worldRegistry: proxy.worldRegistry,
        worldFactory: proxy.worldFactory
    }
});