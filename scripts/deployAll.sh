#!/bin/sh

NETWORK=$1;
if [ -z "$NETWORK" ]; then
    echo "Please provide a network";
    exit 1;
fi
CWD=`pwd`
echo "Deploying to $NETWORK from $CWD"
MODULES=(./ignition/modules/asset/NTAssetMaster.module.ts \
         ./ignition/modules/avatar/Avatar.module.ts \
         ./ignition/modules/company/Company.module.ts \
         ./ignition/modules/experience/Experience.module.ts \
         ./ignition/modules/world/World.module.ts)

for module in ${MODULES[@]};
do
    yarn deploy $module --network $NETWORK
done