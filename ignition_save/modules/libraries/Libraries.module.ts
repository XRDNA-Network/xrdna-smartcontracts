import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Libraries", (m) => {

        const libHooks = m.library("LibHooks");
        const libRegistration = m.library("LibRegistration");
        const libLinkedList = m.library("LibLinkedList");
        const libWorld = m.library("LibWorld", {
            libraries: {
                LibHooks: libHooks,
                LibRegistration: libRegistration,
            }
        });

        return {
            LibHooks: libHooks,
            LibRegistration: libRegistration,
            LibLinkedList: libLinkedList,
            LibWorld: libWorld
        }
});