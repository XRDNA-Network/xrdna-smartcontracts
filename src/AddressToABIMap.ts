
/**
 * This file is used to map the address of the deployed contract to the ABI of the contract.
 * This is used to parse any log related to this project from a generic transaction receipt.
 */
import { DeploymentAddressConfig, ContractNames} from "./ContractAddresses";
import { Avatar } from "./avatar/Avatar";
import { AvatarFactory } from "./avatar/AvatarFactory";
import { AvatarRegistry } from "./avatar/AvatarRegistry";
import { Company, CompanyFactory, CompanyRegistry } from "./company";
import { Experience, ExperienceFactory, ExperienceRegistry } from "./experience";
import { ERC20AssetFactory, ERC20AssetRegistry, ERC721Asset, ERC721AssetFactory, ERC721AssetRegistry, MultiAssetRegistry } from "./asset";
import {ERC20Asset} from "./asset/erc20/ERC20Asset";
import { PortalRegistry } from "./portal";
import { RegistrarRegistry } from "./registrar";
import { World, WorldFactory, WorldRegistry } from "./world";

export type ABI = any[];
export const AddrressToABIMap = new Map<string, ABI>();

export const buildAddressToABIMap = (config: DeploymentAddressConfig) => {
    if(AddrressToABIMap.size > 0) {
        return;
    }

    Object.values(ContractNames).forEach((contractName) => {
        const address = config.getOrThrow(contractName);
        const abi = resolveABI(contractName);
        if(abi) {
            AddrressToABIMap.set(address.toLowerCase(), abi);
        }
    });
}

const resolveABI = (name: string): ABI | undefined => {
    switch(name) {
        case ContractNames.Avatar: {
            return Avatar.abi;
        }
        case ContractNames.AvatarFactory: {
            return AvatarFactory.abi
        }
        case ContractNames.AvatarRegistry: {
            return AvatarRegistry.abi;
        }
        case ContractNames.Company: {
            return Company.abi;
        }
        case ContractNames.CompanyFactory: {
            return CompanyFactory.abi;
        }
        case ContractNames.CompanyRegistry: {
            return CompanyRegistry.abi;
        }
        case ContractNames.Experience: {
            return Experience.abi;
        }
        case ContractNames.ExperienceFactory: {
            return ExperienceFactory.abi;
        }
        case ContractNames.ExperienceRegistry: {
            return ExperienceRegistry.abi;
        }
        case ContractNames.ERC20AssetFactory: {
            return ERC20AssetFactory.abi;
        }
        case ContractNames.ERC20AssetRegistry: {
            return ERC20AssetRegistry.abi;
        }
        case ContractNames.NTERC20Asset: {
            return ERC20Asset.abi;
        }
        case ContractNames.ERC721AssetFactory: {
            return ERC721AssetFactory.abi;
        }
        case ContractNames.ERC721AssetRegistry: {
            return ERC721AssetRegistry.abi;
        }
        case ContractNames.NTERC721Asset: {
            return ERC721Asset.abi;
        }
        case ContractNames.MultiAssetRegistry: {
            return MultiAssetRegistry.abi;
        }
        case ContractNames.PortalRegistry: {
            return PortalRegistry.abi;
        }
        case ContractNames.RegistrarRegistry: {
            return RegistrarRegistry.abi;
        }
        case ContractNames.WorldFactoryV2: {
            return WorldFactory.abi;
        }
        case ContractNames.WorldRegistryV2: {
            return WorldRegistry.abi;
        }
        case ContractNames.WorldV2: {
            return World.abi;
        }
        default: {
            return undefined;
        }
    }

}

