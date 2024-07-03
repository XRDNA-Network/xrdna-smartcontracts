import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import RegistrarRegistryModule from "./registry/RegistrarRegistry.module";
import RegistrarInstanceModule from "./instance/RegistrarInstance.module";
export default buildModule("RegistrarModule", (m) => {
        
       const regReg = m.useModule(RegistrarRegistryModule).registrarRegistry;
       const regInst = m.useModule(RegistrarInstanceModule).registrar;


        return {
            registrarRegistry: regReg,
            registrarMaster: regInst
        }
});