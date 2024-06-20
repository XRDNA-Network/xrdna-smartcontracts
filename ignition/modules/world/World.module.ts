import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import CompanyModule from "../company/Company.module";
import AvatarModule from "../avatar/Avatar.module";
import MultiAssetModule from "../asset/MultiAssetRegistry.module";
import PortalRegistryModule from "../portal/PortalRegistry.module";
import { NamedArtifactContractDeploymentFuture } from "@nomicfoundation/ignition-core";
import RegistrarModule from "../registrar/Registrar.module";
import WorldProxyModule from './WorldProxy.module';
import LibModule from '../libraries/Libraries.module';

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
    registrarFactory: NamedArtifactContractDeploymentFuture<"RegistrarFactory">;
    registrarMasterCopy: NamedArtifactContractDeploymentFuture<"Registrar">;
    worldMasterCopy: NamedArtifactContractDeploymentFuture<"World">;
    worldRegistry: NamedArtifactContractDeploymentFuture<"WorldRegistry">;
    worldFactory: NamedArtifactContractDeploymentFuture<"WorldFactory">;
}

const VERSION = 1;
export default buildModule("World", (m) => {
    
    const proxy = m.useModule(WorldProxyModule);
    
    const comp = m.useModule(CompanyModule);
    const avatar = m.useModule(AvatarModule);
    const assets = m.useModule(MultiAssetModule);
    const portal = m.useModule(PortalRegistryModule);
    const registrar = m.useModule(RegistrarModule);

    const libs = m.useModule(LibModule);
    
    const args = {
        worldFactory: proxy.worldFactory,
        worldRegistry: proxy.worldRegistry,
        companyRegistry: comp.companyRegistry,
        avatarRegistry: avatar.avatarRegistry,
        experienceRegistry: comp.experienceRegistry,
        registrarRegistry: registrar.registrarRegistry,
    }
    
    const master = m.contract("World", [args], {
        libraries: {
            LibHooks: libs.LibHooks,
            LibRegistration: libs.LibRegistration,
            LibWorld: libs.LibWorld
        },
        after: [
            registrar.registrarRegistry,
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
        registrarRegistry: registrar.registrarRegistry,
        registrarFactory: registrar.registrarFactory,
        registrarMasterCopy: registrar.registrarMasterCopy,
        worldMasterCopy: master,
        worldRegistry: proxy.worldRegistry,
        worldFactory: proxy.worldFactory
    }
});