// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

error accessDenied__AdminOnly();

contract Restricted {
    address internal s_masterAdmin;
    mapping(address => bool) internal s_isAdmin;

    modifier adminOnly() { 
        if(msg.sender != s_masterAdmin && !s_isAdmin[msg.sender]) {
            revert accessDenied__AdminOnly();
        }

        _;
    }
}