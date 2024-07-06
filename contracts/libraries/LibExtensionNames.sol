// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

library LibExtensionNames {
    string public constant ACCESS = "AccessExt";
    string public constant FACTORY = "FactoryExt";
    string public constant REMOVABLE_ENTITY = "RemovableEntityExt";

    string public constant REGISTRAR_REGISTRATION = "RegistrarRegistrationExt";
    string public constant REGISTRAR_ENTITY_REMOVAL = "RegistrarEntityRemovalExt";
    string public constant REGISTRAR_WORLD_REGISTRATION = "RegistrarWorldRegistrationExt";

    string public constant WORLD_REGISTRATION = "WorldRegistrationExt";
    string public constant WORLD_REMOVAL = "WorldRemovalExt";
    string public constant WORLD_ADD_COMPANY  = "WorldAddCompanyExt";
    string public constant WORLD_ADD_AVATAR = "WorldAddAvatarExt";
    string public constant WORLD_ADD_EXPERIENCE = "WorldAddExpForCompanyExt";

    string public constant CHANGE_REGISTRAR = "ChangeRegistrarExt";
    string public constant TERMS_OWNER = "TermsOwnerExt";

    string public constant COMPANY_REGISTRATION = "CompanyRegistrationExt";
    string public constant COMPANY_REMOVAL = "CompanyRemovalExt";
    string public constant COMPANY_ADD_EXPERIENCE = "CompanyAddExperienceExt";

    string public constant AVATAR_REGISTRATION = "AvatarRegistrationExt";

    string public constant EXPERIENCE_REGISTRATION = "ExperienceRegistrationExt";
    string public constant EXPERIENCE_REMOVAL = "ExperienceRemovalExt";

    string public constant ASSET_REGISTRATION = "AssetRegistrationExt";
    string public constant ASSET_REMOVAL = "AssetRemovalExt";
    string public constant ASSET_CONDITION = "AssetConditionExt";
    
    string public constant ERC20_MINTING = "ERC20MintingExt";
    string public constant ERC20_INFO = "ERC20InfoExt";
    string public constant ERC20_TRANSFER = "ERC20TransferExt";

    string public constant ERC721_MINTING = "ERC721MintingExt";
    string public constant ERC721_INFO = "ERC721InfoExt";
    string public constant ERC721_TRANSFER = "ERC721TransferExt";
    
}