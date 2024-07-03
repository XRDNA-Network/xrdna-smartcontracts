import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import CoreModule from "../core/Core.module";
import RegistryModule from "../registry/Registry.module";
import CoreExtRegistryModule from "../core/CoreExtRegistry.module";
import EntityModule from "../entity/Entity.module";
import { ContractCallFuture } from "@nomicfoundation/ignition-core";

export interface ModOut {
    ignitionModule: ReturnType<typeof buildModule>,
}
export const deployAndInstall = (): ModOut =>  {
    const mod =  buildModule("Extensions", (m) => {
        
        const core = m.useModule(CoreModule);
        const registry = m.useModule(RegistryModule);
        const entity = m.useModule(EntityModule);
        const coreReg = m.useModule(CoreExtRegistryModule).coreExtensionRegistry;

        const installation = m.call(coreReg, "addExtensions", [[
            core.fundsExtension, 
            core.signersExtension, 
            registry.controllerChangeExtension,
            registry.entityRemovalExtension,
            registry.registrationExtension,
            entity.basicEntityExtension,
            entity.removableExtension,
            entity.termsOwnerExtension
        ]],{
            after: [
                coreReg
            ]
        });

        return {
            fundsExtension: core.fundsExtension,
            signersExtension: core.signersExtension,
            changeControllerExtension: registry.controllerChangeExtension,
            entityRemovalExtension: registry.entityRemovalExtension,
            registrationExtension: registry.registrationExtension,
            basicEntityExtension: entity.basicEntityExtension,
            removableExtension: entity.removableExtension,
            termsOwnerExtension: entity.termsOwnerExtension,
        }
    });
    return {
        ignitionModule: mod
    }
};