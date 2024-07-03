import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {abi as ABI} from '../../../../artifacts/contracts/registrar/interfaces/IRegistrarRegistry.sol/IRegistrarRegistry.json';
import {abi as pABI} from '../../../../artifacts/contracts/registrar/registry/RegistrarRegistryProxy.sol/RegistrarRegistryProxy.json';
import LibrariesModule from "../../Libraries.module";
import RegistrarRegistryProxyModule from "./RegistrarRegistryProxy.module";

export const abi = [
    ...ABI,
    ...pABI
]

export default buildModule("RegistrarRegistryModule", (m) => {

    const libs = m.useModule(LibrariesModule);
    const proxy = m.useModule(RegistrarRegistryProxyModule).registrarRegistryProxy;

    const rr = m.contract("RegistrarRegistry", [], {
        libraries: {
            LibAccess: libs.LibAccess,
            LibEntityRemoval: libs.LibEntityRemoval,
            LibRegistration: libs.LibRegistration,
            LibRegistry: libs.LibRegistry,
        },
        after: [
            libs.LibAccess,
            libs.LibRegistry,
            libs.LibRegistration,
            libs.LibEntityRemoval,
            proxy
        ]
    });
    m.call(proxy, "setImplementation", [rr]);
    return {
        registrarRegistry: rr,
        registrarRegistryProxy: proxy
    }
});