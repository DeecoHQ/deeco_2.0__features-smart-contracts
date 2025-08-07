// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/// @title Restricted Access Control Contract
/// @author 
/// @notice This contract provides admin-only access control functionality.
/// @dev The master admin is set as an immutable address; additional admins can be added to the mapping.

/// @notice Error thrown when a non-admin attempts to access a restricted function.
error Restricted__AccessDenied_AdminOnly();

contract Restricted {
    /// @notice The address of the master admin, set at deployment and immutable.
    address internal immutable i_masterAdmin;

    /// @notice A mapping of addresses that are granted admin rights.
    mapping(address => bool) internal s_isAdmin;

    /// @notice Modifier that restricts function access to the master admin or approved admins.
    /// @dev Reverts with `Restricted__accessDenied_AdminOnly` if the caller is not authorized.
    modifier adminOnly() { 
        if(msg.sender != i_masterAdmin && !s_isAdmin[msg.sender]) {
            revert Restricted__AccessDenied_AdminOnly();
        }

        _;
    }
}
