
# WARNING: if you run this script, it will clear all deployment history for 
# all contracts. Only do this when running tests on localhost and you've changed
# code.

WORLD_SET_IMPL="World#WorldFactory~WorldFactory.setImplementation";
WORLD="World#World";
WORLD_REGISTRY="WorldRegistry#WorldRegistry";
WORLD_FACTORY="WorldFactory#WorldFactory";
REGISTRAR="RegistrarRegistry#RegistrarRegistry";

CHAIN=chain-55555

# Wipe all deployment history
npx hardhat ignition wipe $CHAIN $WORLD_SET_IMPL
npx hardhat ignition wipe $CHAIN $WORLD
npx hardhat ignition wipe $CHAIN $WORLD_REGISTRY
npx hardhat ignition wipe $CHAIN $WORLD_FACTORY
npx hardhat ignition wipe $CHAIN $REGISTRAR

