// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

/**
 * @dev Interface for a hook that can be added to an experience to further evaluate
 * an avatar's request to portal into the experience.
 */
interface IExperienceHook {
    /**
     * @dev This function is called before a jump entry is made to the destination experience.
     * @param destExperience The destination experience address.
     * @param sourceWorld The source world address.
     * @param sourceCompany The source company address.
     * @param avatar The avatar address.
     * @return bool True if the jump entry is allowed, false otherwise.
     */
    function beforeJumpEntry(address destExperience, address sourceWorld, address sourceCompany, address avatar) external returns (bool);

    /**
     * @dev This function is called before an experience is upgraded.
     * @return bool True if the upgrade is allowed, false otherwise.
     */
    function beforeUpgrade(bytes calldata data) external returns (bool);
}