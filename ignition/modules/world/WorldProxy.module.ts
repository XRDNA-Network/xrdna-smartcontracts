import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import WorldRegistryModule0_2 from "./WorldRegistry.module";
import WorldFactoryModule0_2 from "./WorldFactory.module";
import { NamedArtifactContractDeploymentFuture } from "@nomicfoundation/ignition-core";

export interface IWorldDeploymentResult {
    worldProxyMasterCopy: NamedArtifactContractDeploymentFuture<"WorldProxy">;
    worldRegistry: NamedArtifactContractDeploymentFuture<"WorldRegistry0_2">;
    worldFactory: NamedArtifactContractDeploymentFuture<"WorldFactory0_2">;
}

export default buildModule("WorldProxy", (m) => {
    
    const reg = m.useModule(WorldRegistryModule0_2);
    const fac = m.useModule(WorldFactoryModule0_2);
    
    
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