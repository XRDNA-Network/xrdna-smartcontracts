// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrationTerms} from '../../registration/interfaces/IRegistration.sol';

struct ChangeControllerArgsNoTerms {
    address entity;
    
    bytes oldControllerSignature;

    bytes entitySignature;

    uint256 expiration;
}

struct ChangeControllerArgsWithTerms {
    address entity;
    
    bytes oldControllerSignature;

    bytes entitySignature;

    uint256 expiration;

    RegistrationTerms terms;
}

interface IControllerChangeExtension {

    event ControllerChanged(address indexed entity, address indexed newController);

    /**
     * @dev Change the controller that can activate/deactivate/remove the entity. There are no terms set when the 
     * controller is changed with this function. Both the previous controller and the entity must sign the change
     * which includes the entity address, new controller address and the expiration time. No nonce is required since the expiration
     * time is used to prevent replay attacks. This must be called by the new controller contract.
     */
    function changeControllerNoTerms(ChangeControllerArgsNoTerms calldata args) external;

    /**
     * @dev Change the controller that can activate/deactivate/remove the entity. The new controller can set terms 
     * for the entity. The initial terms are provided and signed by the entity, but not previous controller. The
     * previous controller only signs the entity address, new controller address, expiration time. The entity must 
     * sign the new controller address, terms, and expiration time. No nonce is required since the expiration
     * time is used to prevent replay attacks. This must be called by the new controller contract.
     */
    function changeControllerWithTerms(ChangeControllerArgsWithTerms calldata args) external;
}