// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrationTerms} from "../../../../registry/extensions/registration/interfaces/IRegistration.sol";

interface ITermsOwner {
    function setTerms(RegistrationTerms calldata terms) external;
    function getTerms() external view returns (RegistrationTerms memory);
    function isStillActive() external view returns (bool);
    function isSigner(address a) external view returns (bool);
}