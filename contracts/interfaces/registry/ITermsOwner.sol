// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrationTerms} from "../../libraries/LibTypes.sol";

interface ITermsOwner {

    function isStillActive() external view returns (bool);
    function isTermsOwnerSigner(address a) external view returns (bool);
}