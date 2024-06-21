// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


struct SignersStorage {
    mapping(address => bool) signers;
}

library LibSigners {

    bytes32 constant SIGNERS_STORAGE_SLOT = keccak256("_SignersStorage");

    function load() internal pure returns (SignersStorage storage ss) {
        bytes32 slot = SIGNERS_STORAGE_SLOT;
        assembly {
            ss.slot := slot
        }
    }

    function isSigner(address _signer) external view returns (bool) {
        SignersStorage storage ss = load();
        return ss.signers[_signer];
    }

    function addSigners(address[] calldata _signers) external {
        SignersStorage storage ss = load();
        for(uint256 i = 0; i < _signers.length; i++) {
            require(_signers[i] != address(0), "LibSigners: signer is the zero address");
            ss.signers[_signers[i]] = true;
        }
    }

    function removeSigners(address[] calldata _signers) external {
        SignersStorage storage ss = load();
        for(uint256 i = 0; i < _signers.length; i++) {
            require(_signers[i] != address(0), "LibSigners: signer is the zero address");
            ss.signers[_signers[i]] = false;
        }
    }
}