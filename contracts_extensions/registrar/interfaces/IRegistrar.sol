// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ITermsOwner} from '../../entity/extensions/terms-owner/interfaces/ITermsOwner.sol';
import {ITermsOwnerSupport} from '../../entity/extensions/terms-owner/interfaces/ITermsOwnerSupport.sol';
import {IRemovableEntity} from '../../registry/extensions/entity-removal/interfaces/IRemovableEntity.sol';
import {IRemovable} from '../../entity/extensions/removable/interfaces/IRemovable.sol';
import {IRegisteredEntity} from '../../entity/interfaces/IRegisteredEntity.sol';
import {IFundsSupport} from '../../core/extensions/funding/interfaces/IFundsSupport.sol';
import {ISignersSupport} from '../../core/extensions/signers/interfaces/ISignersSupport.sol';
import {IRemovableSupport} from '../../entity/extensions/removable/interfaces/IRemovableSupport.sol';
import {IBasicEntitySupport} from '../../entity/extensions/basic-entity/interfaces/IBasicEntitySupport.sol';

interface IRegistrar is IBasicEntitySupport, IFundsSupport, ISignersSupport, IRemovableSupport, ITermsOwnerSupport {
    
    

  /**
    * These extensions are installed so we have to include their support interfaces
        extNames[0] = 'xr.core.BasicEntityExt';
        extNames[1] = 'xr.core.FundingExt';
        extNames[2] = 'xr.core.SignersExtension';
        extNames[3] = 'xr.entity.RemovableExt';
        extNames[4] = 'xr.entity.TermsOwnerExt';
        */
}