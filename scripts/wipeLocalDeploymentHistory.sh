
# WARNING: if you run this script, it will clear all deployment history for 
# all contracts. Only do this when running tests on localhost and you've changed
# code.

# WORLD_SET_IMPL="World0_2#WorldFactory0_2~WorldFactory0_2.setImplementation";
# WORLD_SET_WORLD_REG="WorldRegistry0_2#WorldFactory0_2~WorldFactory0_2.setAuthorizedRegistry";
# WORLD="World0_2#World0_2";
# WORLD_REGISTRY="WorldRegistry0_2#WorldRegistry0_2";
# WORLD_FACTORY="WorldFactory0_2#WorldFactory0_2";
# REGISTRAR="RegistrarRegistry#RegistrarRegistry";
# #GAS_TOKEN="XRDNAGasToken#XRDNAGasToken";

# SET_ERC20_IMPL="NTAssets#AssetFactory~AssetFactory.setERC20Implementation";
# SET_ERC721_IMPL="NTAssets#AssetFactory~AssetFactory.setERC721Implementation";
# ERC20_BASE="NTAssets#NonTransferableERC20Asset";
# ERC721_BASE="NTAssets#NonTransferableERC721Asset";

# SET_ASSET_REGISTRY="AssetRegistry#AssetFactory~AssetFactory.setAuthorizedRegistry";
# ASSET_REGISTRY="AssetRegistry#AssetRegistry";
# ASSET_FACTORY="AssetFactory#AssetFactory";

# AVATAR_FACTORY="AvatarFactory#AvatarFactory";
# AVATAR_REGISTRY="AvatarRegistry#AvatarRegistry";
# SET_AVATAR_REGISTRY="AvatarRegistry#AvatarFactory~AvatarFactory.setAuthorizedRegistry";
# SET_AVATAR_IMPL="Avatar#AvatarFactory~AvatarFactory.setImplementation";
# AVATAR="Avatar#Avatar";

# COMPANY_FACTORY="CompanyFactory#CompanyFactory";
# COMPANY_REGISTRY="CompanyRegistry#CompanyRegistry";
# SET_COMPANY_REGISTRY="CompanyRegistry#CompanyFactory~CompanyFactory.setAuthorizedRegistry";
# COMPANY="Company#Company";
# SET_COMPANY_IMPL="Company#CompanyFactory~CompanyFactory.setImplementation";

# EXPERIENCE_FACTORY="ExperienceFactory#ExperienceFactory";
# EXPERIENCE_REGISTRY="ExperienceRegistry#ExperienceRegistry";
# SET_EXPERIENCE_REGISTRY="ExperienceRegistry#ExperienceFactory~ExperienceFactory.setAuthorizedRegistry";
# EXPERIENCE="Experience#Experience";
# SET_EXPERIENCE_IMPL="Experience#ExperienceFactory~ExperienceFactory.setImplementation";

# PORTAL_REGISTRY="PortalRegistry#PortalRegistry";

# ALL_FUTURES=(
            
#             $SET_COMPANY_IMPL $SET_COMPANY_REGISTRY $COMPANY \
#             $SET_ERC20_IMPL $SET_ERC721_IMPL  \
#             $SET_AVATAR_IMPL $SET_AVATAR_REGISTRY $AVATAR \
#             $ERC20_BASE $ERC721_BASE \
#             $SET_EXPERIENCE_IMPL $SET_EXPERIENCE_REGISTRY $EXPERIENCE $EXPERIENCE_REGISTRY $EXPERIENCE_FACTORY \
#             $WORLD_SET_IMPL $WORLD_SET_WORLD_REG $WORLD \
#             $COMPANY_REGISTRY  $COMPANY_FACTORY \
#             $AVATAR_REGISTRY $AVATAR_FACTORY  \
#             $WORLD_REGISTRY  $WORLD_FACTORY \
#             $REGISTRAR \
#             $SET_ASSET_FACTORY $SET_ASSET_REGISTRY $ASSET_REGISTRY $ASSET_FACTORY \
#             $PORTAL_REGISTRY)
# CHAIN=chain-55555
# #CHAIN=chain-26379

# for ext in ${ALL_FUTURES[@]};
# do 
#     echo "Wiping $ext"
#     npx hardhat ignition wipe $CHAIN $ext
# done

CHAIN=chain-55555
rm ./ignition/deployments/$CHAIN/journal.jsonl
