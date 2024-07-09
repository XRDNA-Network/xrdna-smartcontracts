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
import CompanyJumpExtModule from "./company/CompanyJumpExt.module";
import CompanyMintingExtModule from "./company/CompanyMintingExt.module";

import WorldAddCompanyExtModule from "./world/WorldAddCompanyExt.module";
import WorldAddAvatarExtModule from "./world/WorldAddAvatarExt.module";
import AvatarRegistrationExtModule from "./registry/avatar/AvatarRegistrationExt.module";

import ExperienceRegistrationExtModule from "./registry/experience/ExperienceRegistrationExt.module";
import ExperienceRemovalExtModule from "./registry/experience/ExperienceRemovalExt.module";
import ExperienceInfoExtModule from "./experience/ExperienceInfoExt.module";
import ExperienceJumpExtModule from "./experience/ExperienceJumpExt.module";

import WorldAddExpForCompanyModule from "./world/WorldAddExpForCompany.module";
import CompanyAddExperienceExtModule from "./company/CompanyAddExperienceExt.module";

import AssetConditionExtModule from "./asset/AssetConditionExt.module";
import AssetRegistrationExtModule from "./registry/asset/AssetRegistrationExt.module";
import AssetRemovalExtModule from "./registry/asset/AssetRemovalExt.module";

import ERC20InfoExtModule from "./asset/erc20/ERC20InfoExt.module";
import ERC20TransferExtModule from "./asset/erc20/ERC20TransferExt.module";
import ERC20MintingExtModule from "./asset/erc20/ERC20MintingExt.module";

import ERC721InfoExtModule from "./asset/erc721/ERC721InfoExt.module";
import ERC721TransferExtModule from "./asset/erc721/ERC721TransferExt.module";
import ERC721MintingExtModule from "./asset/erc721/ERC721MintingExt.module";

import PortalConditionsExtModule from "./portal/PortalConditionsExt.module";
import PortalRemovalExtModule from "./portal/PortalRemovalExt.module";
import PortalRegistrationExtModule from "./portal/PortalRegistrationExt.module";
import PortalJumpExtModule from "./portal/PortalJumpExt.module";

import AvatarWearablesExtModule from "./avatar/WearablesExt.module";
import AvatarInfoExtModule from "./avatar/AvatarInfoExt.module";
import AvatarJumpExtModule from "./avatar/AvatarJumpExt.module";

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
        const companyJumpExt = m.useModule(CompanyJumpExtModule).companyJumpExtension;
        const companyMintingExt = m.useModule(CompanyMintingExtModule).companyMintingExtension;

        const avatarRegistrationExtension = m.useModule(AvatarRegistrationExtModule).avatarRegistrationExtension;
        const avatarWearablesExtension = m.useModule(AvatarWearablesExtModule).avatarWearablesExtension;
        const avatarInfoExtension = m.useModule(AvatarInfoExtModule).avatarInfoExtension;
        const avatarJumpExtension = m.useModule(AvatarJumpExtModule).avatarJumpExtension;

        const experienceRegistrationExtension = m.useModule(ExperienceRegistrationExtModule).experienceRegistrationExtension;
        const experienceRemovalExtension = m.useModule(ExperienceRemovalExtModule).experienceRemovalExtension;
        const experienceInfoExtModule = m.useModule(ExperienceInfoExtModule).experienceInfoExtension;
        const experienceJumpExtModule = m.useModule(ExperienceJumpExtModule).experienceJumpExtension;

        const assetConditionExt = m.useModule(AssetConditionExtModule).assetConditionExtension;
        const assetRegistrationExt = m.useModule(AssetRegistrationExtModule).assetRegistrationExtension;
        const assetRemovalExt = m.useModule(AssetRemovalExtModule).assetRemovalExtension;

        const erc20InfoExt = m.useModule(ERC20InfoExtModule).ERC20InfoExtension;
        const erc20TransferExt = m.useModule(ERC20TransferExtModule).ERC20TransferExtension;
        const erc20MintingExt = m.useModule(ERC20MintingExtModule).ERC20MintingExtension;

        const erc721InfoExt = m.useModule(ERC721InfoExtModule).ERC721InfoExtension;
        const erc721TransferExt = m.useModule(ERC721TransferExtModule).ERC721TransferExtension;
        const erc721MintingExt = m.useModule(ERC721MintingExtModule).ERC721MintingExtension;

        const portalConditionsExt = m.useModule(PortalConditionsExtModule).portalConditionsExtension;
        const portalRemovalExt = m.useModule(PortalRemovalExtModule).portalRemovalExtension;
        const portalRegistrationExt = m.useModule(PortalRegistrationExtModule).portalRegistrationExtension;
        const portalJumpExt = m.useModule(PortalJumpExtModule).portalJumpExtension;

        const batch1 = m.call(coreReg, "addExtensions", [[
             
            factoryExt.factoryExtension,
            termsOwnerExt.termsOwnerExtension,
            registrarRegExt.registrarRegistrationExtension,
            
            registrarRemovalExt.registrarRemovalExtension,
            registrarWorldRegExt.registrarWorldRegistrationExtension,
            
            companyRegistrationExt.companyRegistrationExtension,
            companyRemovalExt.companyRemovalExtension,
            companyAddExperienceExt,
            companyJumpExt,
            companyMintingExt,
            
        ]], {
            id: 'batch1',
            after: [
                coreReg
            ]
        })

        const batch2 = m.call(coreReg, "addExtensions", [[

            worldRegExt.worldRegistrationExtension,
            worldRemovalExt.worldRemovalExtension,
            worldAddCompanyExt.worldAddCompanyExtension,
            worldAddAvatarExt.worldAddAvatarExtension,
            worldAddExpForCompanyExt,

            changeWorldRegExt.changeWorldRegistrarExtention,

            experienceRegistrationExtension,
            experienceRemovalExtension,
            experienceInfoExtModule,
            experienceJumpExtModule,
            
        ]],{
            id: 'batch2',
            after: [
                batch1
            ]
        });

        const batch3 = m.call(coreReg, "addExtensions", [[

            assetConditionExt,
            assetRegistrationExt,
            assetRemovalExt,
            
            erc20InfoExt,
            erc20TransferExt,
            erc20MintingExt,

            erc721InfoExt,
            erc721TransferExt,
            erc721MintingExt,

            remEntity.removableEntityExtension,

        ]], {
            id: 'batch3',
            after: [
                batch2
            ]
        });

        m.call(coreReg, "addExtensions", [[

            accExt.accessExtension,

            avatarRegistrationExtension,
            avatarWearablesExtension,
            avatarInfoExtension,
            avatarJumpExtension,

            portalConditionsExt,
            portalRemovalExt,
            portalRegistrationExt,
            portalJumpExt,
        ]], {
            id: 'batch4',
            after: [
                batch3
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
            avatarWearablesExtension: avatarWearablesExtension,
            avatarInfoExtension: avatarInfoExtension,
            avatarJumpExtension: avatarJumpExtension,

            experienceRegistrationExtension: experienceRegistrationExtension,
            experienceRemovalExtension: experienceRemovalExtension,
            experienceInfoExtension: experienceInfoExtModule,
            experienceJumpExtension: experienceJumpExtModule,

            assetConditionExtension: assetConditionExt,
            erc20InfoExtension: erc20InfoExt,
            erc20TransferExtension: erc20TransferExt,
            erc20MintingExtension: erc20MintingExt,
            erc721InfoExtension: erc721InfoExt,
            erc721TransferExtension: erc721TransferExt,
            erc721MintingExtension: erc721MintingExt,

            portalConditionsExtension: portalConditionsExt,
            portalRemovalExtension: portalRemovalExt,
            portalRegistrationExtension: portalRegistrationExt,
            portalJumpExtension: portalJumpExt,
            
        }
    });