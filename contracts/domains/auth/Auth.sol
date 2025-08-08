// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/// @title Restricted Access Control Contract
/// @author 
/// @notice This contract provides admin-only access control functionality.
/// @dev The master admin is set as an immutable address; additional admins can be added to the mapping.


contract Auth {
    /// @notice Error thrown when a non-admin attempts to access a restricted function.
    error Auth__AccessDenied_AdminOnly();

    /// @notice The address of the master admin, set at deployment and immutable.
    /// @dev This variable is used for strict ownership control and cannot be changed after deployment.
    address internal immutable i_masterAdmin;

    /// @notice Mapping of admin addresses to their admin status.
    /// @dev `true` indicates the address has admin privileges; `false` means no admin rights.
    mapping(address => bool) internal s_isAdmin;

    /// @notice Modifier that restricts function access to the master admin or approved admins.
    /// @dev Reverts with `Auth__AccessDenied_AdminOnly` if the caller is not authorized.
    modifier adminOnly() { 
        if(msg.sender != i_masterAdmin && !s_isAdmin[msg.sender]) {
            revert Auth__AccessDenied_AdminOnly();
        }

        _;
    }
}
