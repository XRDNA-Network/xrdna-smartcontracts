import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

import ExtensionRegistryModule from "../ext-registry/ExtensionRegistry.module";
import RemovableEntityExtension from "../extensions/entity/RemovableEntityExt.module";
import FactoryExtModule from "../extensions/registry/FactoryExt.module";
import TermsOwnerExtModule from "../extensions/registry/TermsOwnerExt.module";
import RegistrarRegistrationExtModule from "../extensions/registry/registrar/RegistrarRegistrationExt.module";
import RegistrarRemovalExtModule from "../extensions/registry/registrar/RegistrarRemovalExt.module";
import RegistrarWorldRegExtModule from "../extensions/registrar/RegistrarWorldRegExt.module";
import ChangeWorldRegExtModule from "../extensions/registry/world/ChangeWorldRegExt.module";
import WorldRegistrationExtModule from "../extensions/registry/world/WorldRegistrationExt.module";
import WorldRemovalExtModule from "../extensions/registry/world/WorldRemovalExt.module";
import AccessExtModule from "../extensions/AccessExt.module";
import CompanyRegistrationExtModule from "./registry/company/CompanyRegistrationExt.module";
import CompanyRemovalExtModule from "./registry/company/CompanyRemovalExt.module";
import WorldAddCompanyExtModule from "./world/WorldAddCompanyExt.module";
import WorldAddAvatarExtModule from "./world/WorldAddAvatarExt.module";
import AvatarRegistrationExtModule from "./registry/avatar/AvatarRegistrationExt.module";
import ExperienceRegistrationExtModule from "./registry/experience/ExperienceRegistrationExt.module";
import ExperienceRemovalExtModule from "./registry/experience/ExperienceRemovalExt.module";
import WorldAddExpForCompanyModule from "./world/WorldAddExpForCompany.module";
import CompanyAddExperienceExtModule from "./company/CompanyAddExperienceExt.module";
export interface ModOut {
    ignitionModule: ReturnType<typeof buildModule>,
}
export default buildModule("Extensions", (m) => {
        
        const coreReg = m.useModule(ExtensionRegistryModule).extensionsRegistry;
        const accExt = m.useModule(AccessExtModule);
        
        const remEntity = m.useModule(RemovableEntityExtension);
        
        const factoryExt = m.useModule(FactoryExtModule);
        const termsOwnerExt = m.useModule(TermsOwnerExtModule);
        const registrarRegExt = m.useModule(RegistrarRegistrationExtModule);
        
        const registrarRemovalExt = m.useModule(RegistrarRemovalExtModule);
        const registrarWorldRegExt = m.useModule(RegistrarWorldRegExtModule);
        
        const changeWorldRegExt = m.useModule(ChangeWorldRegExtModule);
        
        const worldRegExt = m.useModule(WorldRegistrationExtModule);
        const worldRemovalExt = m.useModule(WorldRemovalExtModule);
        const worldAddCompanyExt = m.useModule(WorldAddCompanyExtModule);
        const worldAddAvatarExt = m.useModule(WorldAddAvatarExtModule);
        const worldAddExpForCompanyExt = m.useModule(WorldAddExpForCompanyModule).worldAddExpForCompanyExtension;

        const companyRegistrationExt = m.useModule(CompanyRegistrationExtModule);
        const companyRemovalExt = m.useModule(CompanyRemovalExtModule);
        const companyAddExperienceExt = m.useModule(CompanyAddExperienceExtModule).companyAddExperienceExtension;


        const avatarRegistrationExtension = m.useModule(AvatarRegistrationExtModule).avatarRegistrationExtension;
        

        const experienceRegistrationExtension = m.useModule(ExperienceRegistrationExtModule).experienceRegistrationExtension;
        const experienceRemovalExtension = m.useModule(ExperienceRemovalExtModule).experienceRemovalExtension;

        const installation = m.call(coreReg, "addExtensions", [[
            accExt.accessExtension,
            
            remEntity.removableEntityExtension,
            
            factoryExt.factoryExtension,
            termsOwnerExt.termsOwnerExtension,
            registrarRegExt.registrarRegistrationExtension,
            
            registrarRemovalExt.registrarRemovalExtension,
            registrarWorldRegExt.registrarWorldRegistrationExtension,
            
            changeWorldRegExt.changeWorldRegistrarExtention,
            
            worldRegExt.worldRegistrationExtension,
            worldRemovalExt.worldRemovalExtension,
            worldAddCompanyExt.worldAddCompanyExtension,
            worldAddAvatarExt.worldAddAvatarExtension,
            worldAddExpForCompanyExt,

            companyRegistrationExt.companyRegistrationExtension,
            companyRemovalExt.companyRemovalExtension,
            companyAddExperienceExt,

            avatarRegistrationExtension,

            experienceRegistrationExtension,
            experienceRemovalExtension

            
        ]],{
            after: [
                coreReg
            ]
        });

        return {
            accessExtension: accExt.accessExtension,
            
            removableEntityExtension: remEntity.removableEntityExtension,
            
            factoryExtension: factoryExt.factoryExtension,
            termsOwnerExtension: termsOwnerExt.termsOwnerExtension,
            registrarRegistrationExtension: registrarRegExt.registrarRegistrationExtension,
            
            registrarRemovalExtension: registrarRemovalExt.registrarRemovalExtension,
            registrarWorldRegistrationExtension: registrarWorldRegExt.registrarWorldRegistrationExtension,
            
            changeWorldRegistrarExtention: changeWorldRegExt.changeWorldRegistrarExtention,
            
            worldRegistrationExtension: worldRegExt.worldRegistrationExtension,
            worldRemovalExtension: worldRemovalExt.worldRemovalExtension,
            worldAddCompanyExtension: worldAddCompanyExt.worldAddCompanyExtension,
            worldAddAvatarExtension: worldAddAvatarExt.worldAddAvatarExtension,
            worldAddExpForCompanyExtension: worldAddExpForCompanyExt,
            
            companyRegistrationExtension: companyRegistrationExt.companyRegistrationExtension,
            companyRemovalExtension: companyRemovalExt.companyRemovalExtension,
            companyAddExperienceExtension: companyAddExperienceExt,

            avatarRegistrationExtension: avatarRegistrationExtension,

            experienceRegistrationExtension: experienceRegistrationExtension,
            experienceRemovalExtension: experienceRemovalExtension,
            
        }
    });