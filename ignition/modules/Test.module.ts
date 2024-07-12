import DeployAllModule from './DeployAll.module';
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("TestModule", (m) => {
    const all = m.useModule(DeployAllModule);
    const avatarV2Args = {
        avatarRegistry: all.avatarRegistryProxy,
        companyRegistry: all.companyRegistryProxy,
        experienceRegistry: all.experienceRegistryProxy,
        portalRegistry: all.portalRegistryProxy,
        erc721Registry: all.erc721RegistryProxy,
    };

    const avatarV2 = m.contract("TestAvatarV2", [avatarV2Args], {
        libraries: {
            LibLinkedList: all.LibLinkedList,
            LibAccess: all.LibAccess,
        },
        after: [
            all.avatarRegistryProxy,
            all.companyRegistryProxy,
            all.experienceRegistryProxy,
            all.portalRegistryProxy,
            all.erc721RegistryProxy,
            all.LibLinkedList,
            all.LibAccess

        ]
    });

    return {
        ...all,
        avatarV2
    };
});