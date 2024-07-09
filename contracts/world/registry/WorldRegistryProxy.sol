// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseProxy, BaseProxyConstructorArgs} from '../../base-types/BaseProxy.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {LibRoles} from '../../libraries/LibRoles.sol';

struct WorldRegistryProxyConstructorArgs {
    address owner;
    address impl;
    address vectorAuthority;
    address[] admins;
}

contract WorldRegistryProxy is BaseProxy {
    constructor(WorldRegistryProxyConstructorArgs memory args) BaseProxy(BaseProxyConstructorArgs({
        owner: args.owner,
        impl: args.impl,
        admins: args.admins
    })) {
        require(args.vectorAuthority != address(0), "WorldRegistryProxy: vector authority is zero address");
        LibAccess._grantRole(LibRoles.ROLE_VECTOR_AUTHORITY, args.vectorAuthority);
    }
}