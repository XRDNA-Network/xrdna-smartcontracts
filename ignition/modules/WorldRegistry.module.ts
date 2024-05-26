
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import RegistrarModule from './RegistrarRegistry.module';
import WorldFactoryModule from "./WorldFactory.module";


export default buildModule("WorldRegistry", (m) => {
    
    const regReg = m.useModule(RegistrarModule);
    const fac = m.useModule(WorldFactoryModule);
    const acct = m.getAccount(0);
    
    const Registry = m.contract("WorldRegistry", [regReg.registry, fac.worldFactory, acct], {
        after: [regReg.registry, fac.worldFactory]
    });
    m.call(fac.worldFactory, "setWorldRegistry", [Registry]);
    return {worldRegistry: Registry};
});