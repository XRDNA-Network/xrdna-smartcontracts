import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {abi as ABI} from '../../../../artifacts/contracts/registrar/registry/IRegistrarRegistry.sol/IRegistrarRegistry.json';
import {abi as pABI} from '../../../../artifacts/contracts/registrar/registry/RegistrarRegistryProxy.sol/RegistrarRegistryProxy.json';
import LibrariesModule from "../../Libraries.module";
import RegistrarRegistryProxyModule from "./RegistrarRegistryProxy.module";
import RegistrarFactoryModule from "../../mods/registrar-factory/RegistrarFactory.module";
import EntityRemovalModule from "../../mods/entity-removal/EntityRemoval.module";
import RegistrationModule from "../../mods/registration/Registration.module";

export const abi = [
    ...ABI,
    ...pABI
]

export default buildModule("RegistrarRegistryModule", (m) => {

    const libs = m.useModule(LibrariesModule);
    const proxy = m.useModule(RegistrarRegistryProxyModule).registrarRegistryProxy;
    const regFactory = m.useModule(RegistrarFactoryModule).registrarFactory;
    const eRemoval = m.useModule(EntityRemovalModule).entityRemovalModule;
    const registration = m.useModule(RegistrationModule).registrationModule;
    
    const rr = m.contract("RegistrarRegistry", [], {
        libraries: {
            LibAccess: libs.LibAccess,
            LibEntityRemoval: libs.LibEntityRemoval,
            LibRegistration: libs.LibRegistration
        },
        after: [
            proxy
        ]
    });
    m.call(proxy, "setImplementation", [rr]);
    let data: any = m.encodeFunctionCall(rr, "setEntityFactory", [regFactory]);
    m.send("setEntityFactory", proxy, 0n, data);
    data = m.encodeFunctionCall(rr, "setRegistrationLogic", [registration]);
    m.send("setRegistrationLogic", proxy, 0n, data);
    data = m.encodeFunctionCall(rr, "setEntityRemovalLogic", [eRemoval]);
    m.send("setEntityRemovalLogic", proxy, 0n, data);
    return {
        registrarRegistry: rr,
        registrarRegistryProxy: proxy
    }
});