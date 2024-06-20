import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import WorldRegistryModule from "./WorldRegistry.module";
import WorldFactoryModule from "./WorldFactory.module";
import { NamedArtifactContractDeploymentFuture } from "@nomicfoundation/ignition-core";

export interface IWorldDeploymentResult {
    worldProxyMasterCopy: NamedArtifactContractDeploymentFuture<"WorldProxy">;
    worldRegistry: NamedArtifactContractDeploymentFuture<"WorldRegistryV2">;
    worldFactory: NamedArtifactContractDeploymentFuture<"WorldFactoryV2">;
}

export default buildModule("WorldProxy", (m) => {
    
    const reg = m.useModule(WorldRegistryModule);
    const fac = m.useModule(WorldFactoryModule);
    
    
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