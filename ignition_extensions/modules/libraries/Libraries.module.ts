import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Libraries", (m) => {

        const libAccess = m.library("LibAccess");
        const libExtensions = m.library("LibExtensions");

        const libFactory = m.library("LibFactory");
        const libProxy = m.library("LibProxy");
        const libRegistration = m.library("LibRegistration");
        const libEntity = m.library("LibEntity");
        const libTermsOwner = m.library("LibTermsOwner");

        const libCoreExtRegistry = m.library("LibCoreExtensionRegistry", {
            libraries: {
                LibAccess: libAccess
            },
            after: [libAccess]
        });


        return {
            LibAccess: libAccess,
            LibExtensions: libExtensions,
            LibCoreExtensionRegistry: libCoreExtRegistry,
            LibFactory: libFactory,
            LibProxy: libProxy,
            LibRegistration: libRegistration,
            LibEntity: libEntity,
            LibTermsOwner: libTermsOwner

        }
});