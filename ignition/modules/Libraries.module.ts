import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Libraries", (m) => {

        const libAccess = m.library("LibAccess");
        const libVector = m.library("LibVectorAddress");

        const libEntityRemoval = m.library("LibEntityRemoval");
        const libFactory = m.library("LibFactory");
        const libLinkedList = m.library("LibLinkedList");
        
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
            LibEntityRemoval: libEntityRemoval,
            LibFactory: libFactory,
            LibRemovableEntity: libRemovableEntity,
            LibLinkedList: libLinkedList
        }
});