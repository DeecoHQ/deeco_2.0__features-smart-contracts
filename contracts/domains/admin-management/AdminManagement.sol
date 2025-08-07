// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "../auth/Auth.sol";
import "../../lib/EventsEmitter.sol";

/// @title Admin Management Contract
/// @notice Enables addition and removal of platform admins with event logging
/// @dev Inherits access control from `Restricted` (via `Auth`) and event emitters from `EventsEmitter`

contract AdminManagement is Restricted, EventsEmitter {
    /// @notice Error thrown when attempting to add an already existing admin
    error AdminManagement__alreadyAddedAsAdmin();

    /// @notice Error thrown when attempting to remove a non-admin address
    error AdminManagement__userIsNotAnAdmin();

    /// @notice Represents an admin record with address, who added them, and when
    struct Admin {
        address newAdminAddress;
        address addedBy;
        uint256 addedAt;
    }

    /// @dev Stores all platform admins added so far
    Admin[] internal s_platformAdmins;

    /// @dev Maps an admin address to the list of other admins they have added
    mapping(address => Admin[]) private s_adminAddressToAdditions;

    /// @notice Adds a new admin to the platform
    /// @dev Only callable by existing admins (enforced via `adminOnly` modifier)
    /// Emits an `AddedNewAdmin` event on success
    /// @param _address The address of the new admin to add
    function addAdmin(address _address) public adminOnly {
        if (s_isAdmin[_address]) {
            revert AdminManagement__alreadyAddedAsAdmin();
        }

        Admin memory newAdmin = Admin({
            newAdminAddress: _address,
            addedBy: msg.sender,
            addedAt: block.timestamp
        });

        s_platformAdmins.push(newAdmin);

        Admin[] storage senderAdminAdditions = s_adminAddressToAdditions[msg.sender];
        senderAdminAdditions.push(newAdmin);

        s_adminAddressToAdditions[msg.sender] = senderAdminAdditions;
        s_isAdmin[_address] = true;

        emit AddedNewAdmin("new admin added successfully", block.timestamp, "AdminManagement", _address);
    }

    /// @notice Removes an existing admin from the platform
    /// @dev Only callable by existing admins
    /// Cleans up both global and sender-specific admin lists
    /// Emits a `RemovedAdmin` event on success
    /// @param _address The admin address to be removed
    function removeAdmin(address _address) public adminOnly {
        if (!s_isAdmin[_address]) {
            revert AdminManagement__userIsNotAnAdmin();
        }

        s_isAdmin[_address] = false;

        // Remove from global admin list
        for (uint256 i = 0; i < s_platformAdmins.length; i++) {
            if (!s_isAdmin[s_platformAdmins[i].newAdminAddress]) {
                s_platformAdmins[i] = s_platformAdmins[s_platformAdmins.length - 1];
                s_platformAdmins.pop();
            }
        }

        Admin[] storage senderAdminAdditions = s_adminAddressToAdditions[msg.sender];

        // Remove from sender-specific admin additions list
        for (uint256 i = 0; i < senderAdminAdditions.length; i++) {
            if (!s_isAdmin[senderAdminAdditions[i].newAdminAddress]) {
                senderAdminAdditions[i] = senderAdminAdditions[senderAdminAdditions.length - 1];
                senderAdminAdditions.pop();
            }
        }

        emit RemovedAdmin("admin removed successfully", block.timestamp, "AdminManagement", _address);
    }

    /// @notice Returns the list of all platform admins
    /// @return An array of `Admin` structs representing all added admins
    function getPlatformAdmins() public view returns (Admin[] memory) {
        return s_platformAdmins;
    }

    /// @notice Retrieves a list of admins added by a specific admin
    /// @param _adminAddress The address of the admin whose additions you want to query
    /// @return An array of `Admin` structs added by the given address
    function getAdminRegistrations(address _adminAddress) public view returns (Admin[] memory) {
        return s_adminAddressToAdditions[_adminAddress];
    }

    /// @notice Checks whether an address is currently marked as an admin
    /// @param _adminAddress The address to check
    /// @return True if the address is an admin, false otherwise
    function checkIsAdmin(address _adminAddress) public view returns (bool) {
        return s_isAdmin[_adminAddress];
    }
}
