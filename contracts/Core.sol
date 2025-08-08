// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "./lib/PlatformEvents.sol";
import "./domains/auth/Auth.sol";
import "./domains/admin-management/AdminManagement.sol";
import "./domains/product/ProductManagement.sol";

/// @title Core Contract Entry Point for Platform Functionality
/// @author @Okpainmo(Github)
/// @notice This contract serves as the main entry point of the platform, inheriting admin/access control features, and all of the other smart contracts - serving as a converging point
/// @dev Inherits from `Auth`, `PlatformEvents`, and `AdminManagement`. Initializes the master admin on deployment.
contract Core is Auth, PlatformEvents, AdminManagement, ProductManagement {
    /// @notice Stores the name of the contract instance
    /// @dev Intended to be immutable but can't be due to non-value type restriction
    string internal contractName; // variable should be 'immutable' but error say 'Immutable variables cannot have a non-value type'.

    /// @notice Initializes the Core contract, setting the deployer as the master admin
    /// @dev Sets up initial admin and emits deployment log. The `i_masterAdmin` is set in the constructor body.
    /// @param _contractName A descriptive name for the contract instance, stored privately
    constructor(string memory _contractName) {
        i_masterAdmin = msg.sender;
        s_isAdmin[msg.sender] = true;
        contractName = _contractName;

        // Admin(struct) - from AdminManagement.sol
        // s_platformAdmins - from AdminManagement.sol
        Admin memory masterAdmin = Admin({
            newAdminAddress: msg.sender,
            addedBy: msg.sender,
            addedAt: block.timestamp
        });

        s_platformAdmins.push(masterAdmin);

        emit Logs("contract deployed successfully with constructor chores completed", block.timestamp, "Core");
    }
}
