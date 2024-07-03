// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrationTerms} from "../../core-libs/LibTypes.sol";

interface ITermsOwner {
    event TermsChanged(RegistrationTerms newTerms);

    function isStillActive() external view returns (bool);
    function isTermsOwnerSigner(address a) external view returns (bool);
}