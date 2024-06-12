import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import WorldRegistryModuleV2 from "./WorldRegistry.module";
import WorldFactoryModuleV2 from "./WorldFactory.module";
import { NamedArtifactContractDeploymentFuture } from "@nomicfoundation/ignition-core";

export interface IWorldDeploymentResult {
    worldProxyMasterCopy: NamedArtifactContractDeploymentFuture<"WorldProxy">;
    worldRegistry: NamedArtifactContractDeploymentFuture<"WorldRegistryV2">;
    worldFactory: NamedArtifactContractDeploymentFuture<"WorldFactoryV2">;
}

export default buildModule("WorldProxy", (m) => {
    
    const reg = m.useModule(WorldRegistryModuleV2);
    const fac = m.useModule(WorldFactoryModuleV2);
    
    
    const args = {
        factory: fac.worldFactory,
        registry: reg.worldRegistry
    }
    const master = m.contract("WorldProxy", [args], {
        after: [fac.worldFactory, reg.worldRegistry]
    });
    m.call(fac.worldFactory, "setProxyImplementation", [master]);
    return {
        worldProxyMasterCopy: master,
        worldRegistry: reg.worldRegistry,
        worldFactory: fac.worldFactory
    }
});