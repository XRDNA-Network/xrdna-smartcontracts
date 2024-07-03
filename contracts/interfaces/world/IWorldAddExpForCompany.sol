
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {RegistrationTerms} from '../../libraries/LibTypes.sol';

struct NewExperienceArgs {

    //the experience's vector address
    VectorAddress vector;

    //experience's globally unique name
    string name;

    //company contract init data, if any
    bytes initData;
}

interface IWorldAddExpForCompany {

    /**
     * @dev Add an experience to the world. This is called by the company offering the experience
     */
    function addExperience(NewExperienceArgs memory args) external payable returns (address experience, uint256 portalId);

    /**
     * @dev Deactivates a company contract. Must be called by owning company
     */
    function deactivateExperience(address experience, string calldata reason) external;

    /**
     * @dev Reactivates an experience contract. Must be called by owning company
     */
    function reactivateExperience(address experience) external;

    /**
     * @dev Removes a experience contract. Must be called by owning company
     */
    function removeExperience(address experience, string calldata reason) external returns (uint256 portalId);
}