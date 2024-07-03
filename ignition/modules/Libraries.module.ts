import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Libraries", (m) => {

        const libAccess = m.library("LibAccess");
        const libVector = m.library("LibVectorAddress");

        const libCoreExtensionRegistry = m.library("LibCoreExtensionRegistry", {
            libraries: {
                LibAccess: libAccess,
            }
        });
        const libControlChange = m.library("LibControlChange");
        const libEntityRemoval = m.library("LibEntityRemoval");
        const libExtensions = m.library("LibExtensions");
        const libFactory = m.library("LibFactory");
        
        const libRegistration = m.library("LibRegistration", {
            libraries: {
                LibVectorAddress: libVector
            }
        });
        const libRemovableEntity = m.library("LibRemovableEntity");


        return {
            LibAccess: libAccess,
            LibVectorAddress: libVector,
            LibRegistration: libRegistration,
            LibControlChange: libControlChange,
            LibEntityRemoval: libEntityRemoval,
            LibExtensions: libExtensions,
            LibFactory: libFactory,
            LibRemovableEntity: libRemovableEntity,
            libCoreExtensionRegistry: libCoreExtensionRegistry,
        }
});