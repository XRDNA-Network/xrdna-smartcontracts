import { ChainIds } from './ChainIds';
import XrdnaTestnetDeployment from '../ignition/deployments/chain-26379/deployed_addresses.json';
// import HardhatDeployment from '../ignition/deployments/chain-55555/deployed_addresses.json';

export enum ContractNames {
    AvatarFactory = "AvatarFactory#AvatarFactory",
    CompanyFactory = "CompanyFactory#CompanyFactory",
    ERC20AssetFactory = "ERC20AssetFactory#ERC20AssetFactory",
    ERC721AssetFactory = "ERC721AssetFactory#ERC721AssetFactory",
    ExperienceFactory = "ExperienceFactory#ExperienceFactory",
    PortalRegistry = "PortalRegistry#PortalRegistry",
    RegistrarRegistry = "RegistrarRegistry#RegistrarRegistry",
    WorldFactoryV2 = "WorldFactoryV2#WorldFactoryV2",
    ERC20AssetRegistry = "ERC20AssetRegistry#ERC20AssetRegistry",
    ERC721AssetRegistry = "ERC721AssetRegistry#ERC721AssetRegistry",
    WorldRegistryV2 = "WorldRegistryV2#WorldRegistryV2",
    AvatarRegistry = "AvatarRegistry#AvatarRegistry",
    CompanyRegistry = "CompanyRegistry#CompanyRegistry",
    MultiAssetRegistry = "MultiAssetRegistry#MultiAssetRegistry",
    NTERC20Proxy = "NTERC20Proxy#NTERC20Proxy",
    NTERC721Proxy = "NTERC721Proxy#NTERC721Proxy",
    WorldProxy = "WorldProxy#WorldProxy",
    AvatarProxy = "AvatarProxy#AvatarProxy",
    CompanyProxy = "CompanyProxy#CompanyProxy",
    ExperienceRegistry = "ExperienceRegistry#ExperienceRegistry",
    NTERC20Asset = "NTERC20Asset#NTERC20Asset",
    WorldV2 = "WorldV2#WorldV2",
    Company = "Company#Company",
    Experience = "Experience#Experience",
    ExperienceProxy = "ExperienceProxy#ExperienceProxy",
    NTERC721Asset = "NTERC721Asset#NTERC721Asset",
    Avatar = "Avatar#Avatar",
}

export class DeploymentAddressConfig extends Map {

    constructor(data?: { [key in ContractNames]: string | undefined }) {
        super();
        if (data) {
            Object.entries(data).forEach(([key, value]) => {
                this.set(key, value);
            });
        }
    }

    getOrThrow(contractName: ContractNames): string {
        const address = this.get(contractName);
        if (!address) {
            throw new Error(`Address not found for contract: ${contractName}`);
        }
        return address;
    }

}

function mapJsonToDeploymentAddressConfig(json: any): DeploymentAddressConfig {
    return Object.values(ContractNames)
        .reduce((acc, jsonProp) => {
            acc.set(jsonProp, (json as any)[jsonProp]);
            return acc;
        }, new DeploymentAddressConfig());
}

const XrdnaBaseSepoliaAddresses = mapJsonToDeploymentAddressConfig(
    XrdnaTestnetDeployment
);

// const HardhatAddresses = mapJsonToDeploymentAddressConfig(
//     HardhatDeployment
// );


export const ContractAddresses: ReadonlyMap<BigInt, DeploymentAddressConfig> = new Map([
    [BigInt(ChainIds.XrdnaBaseSepolia), XrdnaBaseSepoliaAddresses],
    // [BigInt(ChainIds.Hardhat), HardhatAddresses]
]);
