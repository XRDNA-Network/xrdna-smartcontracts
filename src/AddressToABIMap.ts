
/**
 * This file is used to map the address of the deployed contract to the ABI of the contract.
 * This is used to parse any log related to this project from a generic transaction receipt.
 */
import { DeploymentAddressConfig, ContractNames} from "./ContractAddresses";
import { AvatarRegistry } from "./avatar/registry/AvatarRegistry";
import { CompanyRegistry } from "./company/registry/CompanyRegistry";
import { RegistrarRegistry } from "./registrar";
import { WorldRegistry } from "./world";
//import { RegistrarRegistry } from "./registrar/registry/RegistrarRegistry";
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
        
        case ContractNames.RegistrarRegistry: {
            return RegistrarRegistry.abi;
        }
        case ContractNames.WorldRegistry: {
            return WorldRegistry.abi;
        }
        case ContractNames.CompanyRegistry: {
            return CompanyRegistry.abi
        }
        case ContractNames.AvatarRegistry: {
            return AvatarRegistry.abi
        }
        default: {
            return undefined;
        }
    }

}

