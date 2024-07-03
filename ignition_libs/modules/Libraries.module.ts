import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Libraries", (m) => {

        const libAccess = m.library("LibAccess");
        const libVector = m.library("LibVectorAddress");
        const libRegistration = m.library("LibRegistration", {
            libraries: {
                LibVectorAddress: libVector
            }
        });

        const libRegistry = m.library("LibRegistry", {
            libraries: {
                LibRegistration: libRegistration
            },
            after: [
                libRegistration
            ]
        });
        
        const libRegistrar = m.library("LibRegistrar", {
            libraries: {
                LibAccess: libAccess,
            },
            after: [
                libAccess
            ]
        });

        const libWorld = m.library("LibWorld", {
            libraries: {
                LibAccess: libAccess,
                LibVectorAddress: libVector,
            },
            after: [
                libAccess
            ]
        });
        

        const libControlChange = m.library("LibControlChange");

        const libEntityRemoval = m.library("LibEntityRemoval");

        return {
            LibAccess: libAccess,
            LibVectorAddress: libVector,
            LibRegistration: libRegistration,
            LibRegistrar: libRegistrar,
            LibRegistry: libRegistry,
            LibControlChange: libControlChange,
            LibEntityRemoval: libEntityRemoval,
            LibWorld: libWorld
        }
});