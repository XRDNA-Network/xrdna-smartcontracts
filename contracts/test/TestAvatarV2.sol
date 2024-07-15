// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {Avatar, AvatarConstructorArgs} from '../avatar/instance/Avatar.sol';
import {Version} from '../libraries/LibVersion.sol';

struct V2Storage {
    uint256 v2Value;
}


contract TestAvatarV2 is Avatar {

    constructor(AvatarConstructorArgs memory args) Avatar(args) {}

    function load() internal pure returns (V2Storage storage ds) {
        bytes32 slot = keccak256("V2_STORAGE_SIMPLIFIED");
        assembly {
            ds.slot := slot
        }
    }

    function version() public pure override returns (Version memory) {
        return Version(1, 1);
    }

    function setValue(uint256 _value) external onlyAdmin {
        V2Storage storage ds = load();
        ds.v2Value = _value;
    }

    function getValue() external view returns (uint256) {
        V2Storage storage ds = load();
        return ds.v2Value;
    }

}