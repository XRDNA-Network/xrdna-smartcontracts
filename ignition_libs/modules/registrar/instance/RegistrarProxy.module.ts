import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {abi as ABI} from '../../../../artifacts/contracts/registrar/instance/RegistrarProxy.sol/RegistrarProxy.json';
import RegistrarRegistryModule from "../registry/RegistrarRegistry.module";
import LibrariesModule from "../../Libraries.module";

export const abi = ABI;

export default buildModule("RegistrarProxyModule", (m) => {

    const rReg = m.useModule(RegistrarRegistryModule);
    const libs = m.useModule(LibrariesModule);

    //use proxy address, not implementation
    const args = {
        owningRegistry: rReg.registrarRegistryProxy
    }
    const proxy = m.contract("RegistrarProxy", [args], {
        after: [
            rReg.registrarRegistry
        ]
    });
    const data = m.encodeFunctionCall(rReg.registrarRegistry, "setProxyImplementation", [proxy]);
    m.send("setProxyImplementation", rReg.registrarRegistryProxy, 0n, data);
    return {
        registrarProxy: proxy
    }
});