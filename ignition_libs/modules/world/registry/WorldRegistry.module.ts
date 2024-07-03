import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {abi as ABI} from '../../../../artifacts/contracts/world/interfaces/IWorldRegistry.sol/IWorldRegistry.json';
import {abi as pABI} from '../../../../artifacts/contracts/world/registry/WorldRegistryProxy.sol/WorldRegistryProxy.json';
import LibrariesModule from "../../Libraries.module";
import WorldRegistryProxyModule from "./WorldRegistryProxy.module";
import RegistrarRegistryModule from "../../registrar/registry/RegistrarRegistry.module";

export const abi = [
    ...ABI,
    ...pABI
]

export default buildModule("WorldRegistryModule", (m) => {

    const libs = m.useModule(LibrariesModule);
    const proxy = m.useModule(WorldRegistryProxyModule).worldRegistryProxy;

    const args = {
        registrarRegistry: m.useModule(RegistrarRegistryModule).registrarRegistryProxy
    }
    const rr = m.contract("WorldRegistry", [args], {
        libraries: {
            LibAccess: libs.LibAccess,
            LibEntityRemoval: libs.LibEntityRemoval,
            LibRegistration: libs.LibRegistration,
            LibRegistry: libs.LibRegistry,
            LibControlChange: libs.LibControlChange,
            LibVectorAddress: libs.LibVectorAddress
        },
        after: [
            libs.LibAccess,
            libs.LibRegistry,
            libs.LibRegistration,
            libs.LibEntityRemoval,
            libs.LibControlChange,
            proxy
        ]
    });
    m.call(proxy, "setImplementation", [rr]);
    return {
        worldRegistry: rr,
        worldRegistryProxy: proxy
    }
});