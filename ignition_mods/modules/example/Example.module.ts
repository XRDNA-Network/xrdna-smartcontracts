import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import {abi as ABI} from '../../../artifacts/contracts/example/Example.sol/Example.json';
import ModuleRegistryModule from "../ModuleRegistry.module";
import LibrariesModule from "../Libraries.module";
import ExampleProxyModule from "./ExampleProxy.module";

export const abi = ABI;

export default buildModule("ExampleModule", (m) => {

        const coreReg = m.useModule(ModuleRegistryModule).moduleRegistry
        const proxy = m.useModule(ExampleProxyModule).exampleProxy
        const libs = m.useModule(LibrariesModule);

        const ex = m.contract("Example", [coreReg],{
            libraries: {
                LibAccess: libs.LibAccess,
                LibFunds: libs.LibFunds,
            },
            after: [
                coreReg,
                proxy,
                libs.LibModule,
                libs.LibAccess,
                libs.LibFunds,
            ]
        });
        m.call(proxy, "setImplementation", [ex]);
        return {
            example: ex,
            exampleProxy: proxy
        }
});