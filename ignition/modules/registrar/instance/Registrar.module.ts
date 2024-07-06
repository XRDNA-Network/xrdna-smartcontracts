import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import LibrariesModule from "../../Libraries.module";
import RegistrarRegistryModule from "../registry/RegistrarRegistry.module";
import WorldRegistryModule from "../../world/registry/WorldRegistry.module";
import FactoryExtModule from "../../extensions/registry/FactoryExt.module";
import RegistrarExtResolverModule from "./RegistrarExtResolver.module";

export default buildModule("RegistrarModule", (m) => {

        const libs = m.useModule(LibrariesModule);
        const regExtResolver = m.useModule(RegistrarExtResolverModule).registrarExtensionResolver;
        const regReg = m.useModule(RegistrarRegistryModule).registrarRegistry;
        const worldReg = m.useModule(WorldRegistryModule).worldRegistry;
        const factoryExt = m.useModule(FactoryExtModule).factoryExtension;
        
        const args = {
            extensionResolver: regExtResolver,
            owningRegistry: regReg,
            worldRegistry: worldReg
        }
        
        const fe = m.contract("Registrar", [args], {
            libraries: {
                LibAccess: libs.LibAccess
            },
            after: [
                regExtResolver,
                regReg,
                worldReg,
                libs.LibAccess
            ]
        });
        const data = m.encodeFunctionCall(factoryExt, "setEntityImplementation", [fe]);
        m.send("setEntityImplementation", regReg, 0n, data);
        return {
            registrar: fe
        }
});