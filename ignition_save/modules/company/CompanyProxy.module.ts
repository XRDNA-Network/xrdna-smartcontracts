import { buildModule } from "@nomicfoundation/ignition-core";
import CompanyFactoryModule from "./CompanyFactory.module";
import CompanyRegistryModule from "./CompanyRegistry.module";


export default buildModule("CompanyProxy", (m) => {
    
    const reg = m.useModule(CompanyRegistryModule);
    const fac = m.useModule(CompanyFactoryModule);

    const args = {
        factory: fac.companyFactory,
        registry: reg.companyRegistry,
    }
    const master = m.contract("CompanyProxy", [args], {
        after: [fac.companyFactory, 
                reg.companyRegistry]
    });
    m.call(fac.companyFactory, "setProxyImplementation", [master]);
    return {
        companyRegistry: reg.companyRegistry,
        companyFactory: fac.companyFactory,
        companyProxyMasterCopy: master
    }
});