// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract AdminAuth {

    error AdminAuth__AccessDenied_AdminOnly();

    mapping(address => bool) internal s_isAdmin;

    modifier adminOnly() {
        if (!s_isAdmin[msg.sender]) {
            revert AdminAuth__AccessDenied_AdminOnly();
        }

        _;
    }
}
