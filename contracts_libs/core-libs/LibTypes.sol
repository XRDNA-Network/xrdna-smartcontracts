// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


struct RegistrationTerms {
    uint16 coveragePeriodDays;
    uint16 gracePeriodDays;
    uint256 fee;
}

struct Version {
    uint16 major;
    uint16 minor;
}

library LibTypes {}