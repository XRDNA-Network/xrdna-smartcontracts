import { ChainIds } from './ChainIds';
 
export enum ContractNames {
    RegistrarRegistry = "RegistrarRegistryProxyModule#RegistrarRegistryProxy",
    WorldRegistry = "WorldRegistryProxyModule#WorldRegistryProxy",
    CompanyRegistry = "CompanyRegistryProxyModule#CompanyRegistryProxy",
    AvatarRegistry = "AvatarRegistryProxyModule#AvatarRegistryProxy",
    ERC20AssetRegistry = "ERC20RegistryProxyModule#ERC20RegistryProxy",
    ERC721AssetRegistry = "ERC721RegistryProxyModule#ERC721RegistryProxy",
    MultiAssetRegistry = "MultiAssetRegistry#MultiAssetRegistry",
    ExperienceRegistry = "ExperienceRegistryProxyModule#ExperienceRegistryProxy",
    PortalRegistry = "PortalRegistryProxyModule#PortalRegistryProxy",

    /*
    AvatarFactory = "AvatarFactory#AvatarFactory",
    CompanyFactory = "CompanyFactory#CompanyFactory",
    ERC20AssetFactory = "ERC20AssetFactory#ERC20AssetFactory",
    ERC721AssetFactory = "ERC721AssetFactory#ERC721AssetFactory",
    ExperienceFactory = "ExperienceFactory#ExperienceFactory",
    PortalRegistry = "PortalRegistry#PortalRegistry",
    RegistrarRegistry = "RegistrarRegistry#RegistrarRegistry",
    WorldFactory = "WorldFactory#WorldFactory",
    ERC20AssetRegistry = "ERC20AssetRegistry#ERC20AssetRegistry",
    ERC721AssetRegistry = "ERC721AssetRegistry#ERC721AssetRegistry",
    WorldRegistry = "WorldRegistry#WorldRegistry",
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
    World = "World#World",
    Company = "Company#Company",
    Experience = "Experience#Experience",
    ExperienceProxy = "ExperienceProxy#ExperienceProxy",
    NTERC721Asset = "NTERC721Asset#NTERC721Asset",
    Avatar = "Avatar#Avatar",
    */
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

export function mapJsonToDeploymentAddressConfig(json: any): DeploymentAddressConfig {
    if(!json) throw new Error("Invalid JSON");
    return Object.values(ContractNames)
        .reduce((acc, jsonProp) => {
            acc.set(jsonProp, (json as any)[jsonProp]);
            return acc;
        }, new DeploymentAddressConfig());
}

/*
const XrdnaBaseSepoliaAddresses = mapJsonToDeploymentAddressConfig(
    XrdnaTestnetDeployment
);

 const HardhatAddresses = mapJsonToDeploymentAddressConfig(
     HardhatDeployment
 );


export const ContractAddresses: ReadonlyMap<BigInt, DeploymentAddressConfig> = new Map([
    [BigInt(ChainIds.XrdnaBaseSepolia), XrdnaBaseSepoliaAddresses],
     [BigInt(ChainIds.LocalTestnet), HardhatAddresses]
]);
*/

export type ContractAddresses = ReadonlyMap<BigInt, DeploymentAddressConfig>;
export const buildContractAddresses = (chainId: bigint): ContractAddresses => {
    const XrdnaTestnetDeployment = require('../ignition/deployments/chain-26379/deployed_addresses.json');
    const HardhatDeployment = require('../ignition/deployments/chain-55555/deployed_addresses.json');

    return new Map([
        [BigInt(ChainIds.XrdnaBaseSepolia), XrdnaTestnetDeployment ? mapJsonToDeploymentAddressConfig(XrdnaTestnetDeployment): new DeploymentAddressConfig()],
        [BigInt(ChainIds.LocalTestnet),HardhatDeployment ?  mapJsonToDeploymentAddressConfig(HardhatDeployment): new DeploymentAddressConfig()]
    ]);
}
