// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "./domains/auth/Auth.sol";
import "./domains/admin-management/AdminManagement.sol";
import "./lib/EventsEmitter.sol";

/// @title Core Contract Entry Point for Platform Functionality
/// @author @Okpainmo(Github)
/// @notice This contract serves as the main entry point of the platform, inheriting admin and access control features
/// @dev Inherits from `Restricted`, `EventsEmitter`, and `AdminManagement`. Initializes the master admin on deployment.

contract Core is Restricted, EventsEmitter, AdminManagement {
    /// @notice Stores the name of the contract instance
    string private contractName;

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
