// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRemovableEntity} from "../../entity-libs/interfaces/IRemovableEntity.sol";
import {ITermsOwner} from "../../entity-libs/interfaces/ITermsOwner.sol";
import {IFundable} from "../../IFundable.sol";
import {RegistrationTerms} from '../../core-libs/LibTypes.sol';
import {VectorAddress} from '../../core-libs/LibVectorAddress.sol';
import {Version} from '../../core-libs/LibTypes.sol';

interface IWorld is IRemovableEntity, ITermsOwner, IFundable{

    event CompanyTermsChanged(RegistrationTerms terms);
    event TermsOwnerChanged(address owner);
    event AvatarTermsChanged(RegistrationTerms terms);
    event WorldDeactivatedCompany(address company, string reason);
    event WorldReactivatedCompany(address company);
    event WorldRemovedCompany(address company, string reason);
    event WorldUpgraded(address indexed newImpl, Version newVersion);
    
    function deactivateCompany(address company, string calldata reason) external;
    function reactivateCompany(address company) external;
    function removeCompany(address company, string calldata reason) external;
    function changeTermsOwner(address owner) external;
    function getBaseVector() external view returns (VectorAddress memory);

}