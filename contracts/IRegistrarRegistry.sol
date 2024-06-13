// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


/**
 * @title IRegistrarRegistry
 * @dev Interface for the registrar registry contract. The registrar registry holds registrar
 * IDs and their list of authorized signers. Registrars are the only entity allowed to regsiter
 * worlds in the world registry. They must go through XRDNA to be approved as a registrar.
 */
interface IRegistrarRegistry {

    /**
     * @dev Returns true if the account is a signer for the given registrar id.
     */
    function isRegistrar(uint256 id, address account) external view returns (bool);

    /**
     * @dev Registers a new registrar signer. This can only be called by admin
     */
    function register(address payable signer) external payable;

    /**
     * @dev Adds a new registrar to the registry. This can only be called by admin.
     */
    function removeRegistrar(uint256 registrarId) external;

    /**
     * @dev Adds a list of signers to the registrar.
     */
    function addSigners(uint256 registrarId, address[] memory signers) external;

    /**
     * @dev Removes a list of signers from the registrar.
     */
    function removeSigners(uint256 registrarId, address[] memory signers) external;
}