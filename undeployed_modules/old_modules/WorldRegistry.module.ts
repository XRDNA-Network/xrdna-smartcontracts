
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import RegistrarModule from './RegistrarRegistry.module';
import WorldFactoryModule from "./WorldFactory.module";
import {config} from '../modules/config';

export default buildModule("WorldRegistry", (m) => {
    
    const regReg = m.useModule(RegistrarModule);
    const fac = m.useModule(WorldFactoryModule);
    
    const Registry = m.contract("WorldRegistry", [config.vectorAddressAuthority, regReg.registry, fac.worldFactory, config.worldRegistryAdmin], {
        after: [regReg.registry, fac.worldFactory]
    });
    m.call(fac.worldFactory, "setWorldRegistry", [Registry]);
    return {worldRegistry: Registry};
});