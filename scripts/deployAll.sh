#!/bin/sh

NETWORK=$1;
if [ -z "$NETWORK" ]; then
    echo "Please provide a network";
    exit 1;
fi
CWD=`pwd`
echo "Deploying to $NETWORK from $CWD"
# World module encapsulates all other modules so deploying it deploys all
MODULES=(./ignition/modules/world/World.module.ts)

for module in ${MODULES[@]};
do
    yarn deploy $module --network $NETWORK
done