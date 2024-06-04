import { ChainIds } from './ChainIds';
import XrdnaTestnetDeployment from '../ignition/deployments/chain-26379/deployed_addresses.json';

type DeploymentAddressConfig = {
    RegistrarRegistry: string;
    WorldFactory: string;
    WorldRegistry: string;
    World: string;
}

const XrdnaBaseSepoliaAddresses: DeploymentAddressConfig = {
    RegistrarRegistry: XrdnaTestnetDeployment['RegistrarRegistry#RegistrarRegistry'],
    WorldFactory: XrdnaTestnetDeployment['WorldFactory#WorldFactory'],
    WorldRegistry: XrdnaTestnetDeployment['WorldRegistry#WorldRegistry'],
    World: XrdnaTestnetDeployment['World#World'],
};

export const ContractAddresses: ReadonlyMap<BigInt, DeploymentAddressConfig> = new Map([
    [BigInt(ChainIds.XrdnaBaseSepolia), XrdnaBaseSepoliaAddresses]
]);
