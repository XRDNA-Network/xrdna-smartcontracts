
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../../libraries/LibVectorAddress.sol';

struct AddExperienceArgs {

    //experience's globally unique name
    string name;

    //company contract init data, if any
    bytes initData;
}

interface ICompanyAddExperience {

    /**
     * @dev Add an experience to company's surrounding world. This is called by signers of company.
     */
    function addExperience(AddExperienceArgs memory args) external returns (address experience, uint256 portalId);

    /**
     * @dev Deactivates an experience contract. Must be called by signer
     */
    function deactivateExperience(address experience, string calldata reason) external;

    /**
     * @dev Reactivates an experience contract. Must be called by signers
     */
    function reactivateExperience(address experience) external;

    /**
     * @dev Removes a experience contract. Must be called by signers
     */
    function removeExperience(address experience, string calldata reason) external returns (uint256 portalId);
}