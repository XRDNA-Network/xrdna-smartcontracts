// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import {IExtension} from '../../interfaces/IExtension.sol';
import {IAssetMinting} from '../../interfaces/asset/IAssetMinting.sol';
import {IAsset} from '../../asset/IAsset.sol';
import {IAvatar} from '../../avatar/instance/IAvatar.sol';
import {ICompany} from '../../company/instance/ICompany.sol';
import {ICompanyRegistry} from '../../company/registry/ICompanyRegistry.sol';
import {LibAsset} from '../../libraries/LibAsset.sol';
import {IExperience} from '../../experience/instance/IExperience.sol';


abstract contract BaseAssetMintingExt is ReentrancyGuard, IExtension, IAssetMinting {

    modifier onlyRegistry() {
        require(msg.sender == address(IAsset(address(this)).assetRegistry()), "BaseAssetMintingExt: only registry allowed");
        _;
    }

    modifier onlyIssuer() {
        address i = LibAsset.load().issuer;
        require(msg.sender == i, "BaseAssetMintingExt: only issuer allowed");
        ICompanyRegistry companyRegistry = IAsset(address(this)).companyRegistry();
        require(companyRegistry.isRegistered(i), "BaseAssetMintingExt: issuer is not a registered company");
        require(ICompany(i).isEntityActive(), "BaseAssetMintingExt: issuer is not active");
       _;
    }


    /**
     * @dev Verifies that the asset issuer matches the company owner of 
     * the avatar's current experience. This is used when an avatar restricts
     * receiving assets to only those issued by the company that owns the
     * the experience they are currently in.
     */
    function _verifyAvatarLocationMatchesIssuer(IAvatar avatar) internal view {
        //get the avatar's current location
        address e = avatar.location();
        require(e != address(0), "BaseAsset: avatar has no location");
        IExperience exp = IExperience(e);
        require(exp.company() == LibAsset.load().issuer, "BaseAsset: avatar does not allow assets outside of its current experience");
    }
}