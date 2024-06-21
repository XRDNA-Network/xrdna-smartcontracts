// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrarInitArgs} from "../../interfaces/registrar/IRegistrarInit.sol";

struct RegistrarBasicInfoV1 {
    address owner;

    string name;
}

library LibRegistrarBasicInfo {
    bytes32 constant V1_STORAGE_SLOT = keccak256("_RegistrarBasicInfoV1");

    function load() internal pure returns (RegistrarBasicInfoV1 storage s) {
        bytes32 position = V1_STORAGE_SLOT;
        assembly {
            s.slot := position
        }
    }

    function init(RegistrarInitArgs calldata args) external {
        RegistrarBasicInfoV1 storage s = load();
        require(args.owner != address(0), "Registrar: owner is the zero address");
        require(bytes(args.name).length > 0, "Registrar: name is empty");

        require(s.owner == address(0), "Registrar: already initialized");

        s.name = args.name;
        s.owner = args.owner;
    }

    function name() external view returns (string memory) {
        return load().name;
    }

    
}