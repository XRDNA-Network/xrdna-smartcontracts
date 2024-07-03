// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRegistry} from '../../registry/interfaces/IRegistry.sol';
import {IEntityRemovalSupport} from '../../registry/extensions/entity-removal/interfaces/IEntityRemovalSupport.sol';
import {IRegistrationSupport } from '../../registry/extensions/registration/interfaces/IRegistrationSupport.sol';
import {ITermsOwnerSupport} from '../../entity/extensions/terms-owner/interfaces/ITermsOwnerSupport.sol';
import {ISignersSupport} from '../../core/extensions/signers/interfaces/ISignersSupport.sol';

interface IRegistrarRegistry is IRegistry, IRegistrationSupport, IEntityRemovalSupport, ITermsOwnerSupport, ISignersSupport {

    /**
     * These are installed extensions found in RegistryExtMgr:
     *
        extNames[0] = 'xr.registration.RegistrationExt';
        extNames[1] = 'xr.core.EntityRemovalExt';
        extNames[2] = 'xr.entity.TermsOwnerExt';
        extNames[3] = 'xr.core.SignersExtension';

        So we extend the support interfaces of those extensions to make sure we implement what's needed
     */
}