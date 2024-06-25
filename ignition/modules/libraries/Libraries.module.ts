import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Libraries", (m) => {

        const libAccess = m.library("LibAccess");
        const libExtensions = m.library("LibExtensions", {
            libraries: {
                LibAccess: libAccess
            },
            after: [libAccess]
        });
        const libCoreExtRegistry = m.library("LibCoreExtensionRegistry", {
            libraries: {
                LibAccess: libAccess
            },
            after: [libAccess]
        });

        return {
            LibAccess: libAccess,
            LibExtensions: libExtensions,
            LibCoreExtensionRegistry: libCoreExtRegistry

        }
});