// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "../auth/Auth.sol";
import "../../lib/PlatformEvents.sol";

/// @title Admin Management Contract
/// @notice Enables addition and removal of platform admins with event logging
/// @dev Inherits access control from `Auth` (via `Auth`) and event emitters from `EventsEmitter`
contract AdminManagement is Auth, PlatformEvents {
    /// @notice Represents an admin record with address, who added them, and when
    struct Admin {
        address newAdminAddress;
        address addedBy;
        uint256 addedAt;
    }

    /// @notice Error thrown when attempting to add an already existing admin
    error AdminManagement__AlreadyAddedAsAdmin(Admin admin);

    /// @notice Error thrown when a provided user(address) is not an admin
    error AdminManagement__AddressIsNotAnAdmin();

    /// @notice Stores all platform admins added so far
    /// @dev This array grows as new admins are added and shrinks as they are removed.
    Admin[] internal s_platformAdmins;

    /// @notice Maps an admin address to the list of other admins they have added
    /// @dev Key is the admin's address, value is an array of `Admin` structs representing additions they made.
    mapping(address => Admin[]) private s_adminAddressToAdditions;

    /// @notice Maps an admin's address to their `Admin` profile
    /// @dev Allows constant-time lookup of a specific admin's full profile details.
    mapping(address => Admin) private s_adminAddressToAdminProfile;

    /// @notice Adds a new admin to the platform
    /// @dev Only callable by existing admins (enforced via `adminOnly` modifier)
    /// Emits an `AddedNewAdmin` event on success
    /// @param _address The address of the new admin to add
    function addAdmin(address _address) public adminOnly {
        if (s_isAdmin[_address]) {
            Admin storage admin = s_adminAddressToAdminProfile[_address];

            revert AdminManagement__AlreadyAddedAsAdmin(admin);
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
        s_adminAddressToAdminProfile[_address] = newAdmin;

        emit AddedNewAdmin("new admin added successfully", block.timestamp, "AdminManagement", _address, msg.sender);
    }

    /// @notice Removes an existing admin from the platform
    /// @dev Only callable by existing admins
    /// Cleans up both global and sender-specific admin lists
    /// Emits a `RemovedAdmin` event on success
    /// @param _address The admin address to be removed
    function removeAdmin(address _address) public adminOnly {
        if (!s_isAdmin[_address]) {
            revert AdminManagement__AddressIsNotAnAdmin();
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

        emit RemovedAdmin("admin removed successfully", block.timestamp, "AdminManagement", _address, msg.sender);
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
       return (s_isAdmin[_adminAddress]);
    }

    /// @notice Retrieves the full admin profile for a given address
    /// @param _adminAddress The address of the admin whose profile you want
    /// @return An `Admin` struct containing the profile details
    function getAdminProfile(address _adminAddress) public view returns (Admin memory) {
        if (!s_isAdmin[_adminAddress]) {
            revert AdminManagement__AddressIsNotAnAdmin();
        }

        Admin storage admin = s_adminAddressToAdminProfile[_adminAddress];

        return admin;
    }
}
