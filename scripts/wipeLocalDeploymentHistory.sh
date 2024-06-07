
# WARNING: if you run this script, it will clear all deployment history for 
# all contracts. Only do this when running tests on localhost and you've changed
# code.

WORLD_SET_IMPL="World0_2#WorldFactory0_2~WorldFactory0_2.setImplementation";
WORLD_SET_WORLD_REG="WorldRegistry0_2#WorldFactory0_2~WorldFactory0_2.setAuthorizedRegistry";
WORLD="World0_2#World0_2";
WORLD_REGISTRY="WorldRegistry0_2#WorldRegistry0_2";
WORLD_FACTORY="WorldFactory0_2#WorldFactory0_2";
REGISTRAR="RegistrarRegistry#RegistrarRegistry";
GAS_TOKEN="XRDNAGasToken#XRDNAGasToken";

SET_ERC20_IMPL="NTAssets#AssetFactory~AssetFactory.setERC20Implementation";
SET_ERC721_IMPL="NTAssets#AssetFactory~AssetFactory.setERC721Implementation";
ERC20_BASE="NTAssets#NonTransferableERC20Asset";
ERC721_BASE="NTAssets#NonTransferableERC721Asset";
SET_ASSET_FACTORY="AssetRegistry#AssetFactory~AssetFactory.setAuthorizedRegistry";
ASSET_REGISTRY="AssetRegistry#AssetRegistry";
ASSET_FACTORY="AssetFactory#AssetFactory";

AVATAR_FACTORY="AvatarFactory#AvatarFactory";
AVATAR_REGISTRY="AvatarRegistry#AvatarRegistry";

COMPANY_FACTORY="CompanyFactory#CompanyFactory";
COMPANY_REGISTRY="CompanyRegistry#CompanyRegistry";


ALL_FUTURES=($GAS_TOKEN $WORLD_SET_IMPL $WORLD_SET_WORLD_REG \
             $WORLD $WORLD_REGISTRY $WORLD_FACTORY $REGISTRAR \
             $SET_ERC20_IMPL $SET_ERC721_IMPL $ERC20_BASE \
             $ERC721_BASE $SET_ASSET_FACTORY $ASSET_REGISTRY \
             $ASSET_FACTORY $AVATAR_FACTORY $AVATAR_REGISTRY \
            $COMPANY_FACTORY $COMPANY_REGISTRY)
CHAIN=chain-55555
#CHAIN=chain-26379

for ext in ${ALL_FUTURES[@]};
do 
    echo "Wiping $ext"
    npx hardhat ignition wipe $CHAIN $ext
done

# Wipe all deployment history
# npx hardhat ignition wipe $CHAIN $GAS_TOKEN
# npx hardhat ignition wipe $CHAIN $WORLD_SET_IMPL
# npx hardhat ignition wipe $CHAIN $WORLD_SET_WORLD_REG
# npx hardhat ignition wipe $CHAIN $WORLD
# npx hardhat ignition wipe $CHAIN $WORLD_REGISTRY
# npx hardhat ignition wipe $CHAIN $WORLD_FACTORY
# npx hardhat ignition wipe $CHAIN $REGISTRAR

