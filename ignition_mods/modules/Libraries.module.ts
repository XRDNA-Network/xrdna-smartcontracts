import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Libraries", (m) => {

        const libDelegation = m.library("LibDelegation");

        const libVersionControl = m.library("LibVersionControl");
        const libAccess = m.library("LibAccess");
        const libEntityFactory = m.library("LibEntityFactory", {
            libraries: {
                LibDelegation: libDelegation
            }
        });

        const libFunds = m.library("LibFunds", {
            libraries: {
                LibAccess: libAccess
            }
        });

        const libActivation = m.library("LibActivation");
        const libEntity = m.library("LibEntity");
        const libRegistration = m.library("LibRegistration", {
            libraries: {
                LibDelegation: libDelegation
            }       
        });

        const libControlChange = m.library("LibControlChange", {
            libraries: {
                LibDelegation: libDelegation
            }   
        });

        const libEntityRemoval = m.library("LibEntityRemoval", {
            libraries: {
                LibDelegation: libDelegation
            }   
        });

        return {
            LibAccess: libAccess,
            LibEntityFactory: libEntityFactory,
            LibFunds: libFunds,
            LibActivation: libActivation,
            LibEntity: libEntity,
            LibRegistration: libRegistration,
            LibControlChange: libControlChange,
            LibEntityRemoval: libEntityRemoval,
            libVersionControl: libVersionControl
        }
});