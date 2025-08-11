// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "../auth/AdminAuth.sol";
import "../../lib/PlatformEvents.sol";

/**
 * @title AdminManagement
 * @notice Manages platform administrators by enabling addition, removal, and retrieval of admin profiles and registrations.
 *         Enforces that only existing admins can add or remove admins via the inherited `adminOnly` modifier.
 * @dev 
 * - Inherits from `AdminAuth` to manage admin access control state.
 * - Inherits from `PlatformEvents` to emit standardized platform events on admin-related actions.
 */
contract AdminManagement is AdminAuth, PlatformEvents {
    /**
     * @notice Represents an admin's profile and metadata about their registration.
     * @param adminAddress The Ethereum address of the admin.
     * @param addedBy The address of the admin who added this admin.
     * @param addedAt The Unix timestamp when this admin was added.
     */
    struct Admin {
        address adminAddress;
        address addedBy;
        uint256 addedAt;
    }

    /**
     * @notice Error thrown when attempting to add an address that is already an admin.
     * @param admin The existing admin profile for the address.
     */
    error AdminManagement__AlreadyAddedAsAdmin(Admin admin);

    /**
     * @notice Error thrown when an address is expected to be an admin but is not.
     */
    error AdminManagement__AddressIsNotAnAdmin();

    /// @notice Array holding all admins currently registered on the platform.
    Admin[] internal s_platformAdmins;

    /// @notice Maps an admin address to a list of `Admin` structs representing the admins they have added.
    mapping(address => Admin[]) internal s_adminAddressToAdditions_admin;

    /// @notice Maps an admin address to their `Admin` profile information.
    mapping(address => Admin) internal s_adminAddressToAdminProfile;

    /// @notice Constant holding the contract name for event context to avoid spelling errors.
    string private constant CURRENT_CONTRACT_NAME = "AdminManagement"; // keep name in one variable to avoid mispelling it at any point

    /**
     * @notice Adds a new admin to the platform.
     * @dev 
     * - Can only be called by an existing admin (`adminOnly` modifier).
     * - Reverts with `AdminManagement__AlreadyAddedAsAdmin` if the address is already an admin.
     * - Updates internal storage and emits `AddedNewAdmin` event upon success.
     * @param _address The address to be granted admin privileges.
     */
    function addAdmin(address _address) public adminOnly {
        // s_isAdmin(variable) - from AdminAuth.sol
        if (s_isAdmin[_address]) {
            Admin storage admin = s_adminAddressToAdminProfile[_address];

            revert AdminManagement__AlreadyAddedAsAdmin(admin);
        }

        Admin memory newAdmin = Admin({
            adminAddress: _address,
            addedBy: msg.sender,
            addedAt: block.timestamp
        });

        s_platformAdmins.push(newAdmin);

        Admin[] storage senderAdminAdditions = s_adminAddressToAdditions_admin[msg.sender];
        senderAdminAdditions.push(newAdmin);

        s_adminAddressToAdditions_admin[msg.sender] = senderAdminAdditions;
        s_isAdmin[_address] = true;
        s_adminAddressToAdminProfile[_address] = newAdmin;

        emit AddedNewAdmin("new admin added successfully", block.timestamp, CURRENT_CONTRACT_NAME, _address, msg.sender);
    }

    /**
     * @notice Removes an existing admin from the platform.
     * @dev 
     * - Can only be called by an existing admin (`adminOnly` modifier).
     * - Reverts with `AdminManagement__AddressIsNotAnAdmin` if the address is not an admin.
     * - Removes admin from all internal lists and mappings.
     * - Emits a `RemovedAdmin` event upon success.
     * @param _address The admin address to be removed.
     */
    function removeAdmin(address _address) public adminOnly {
        // s_isAdmin(variable) - from AdminAuth.sol
        if (!s_isAdmin[_address]) {
            revert AdminManagement__AddressIsNotAnAdmin();
        }

        s_isAdmin[_address] = false;

        // Remove from global admin list
        for (uint256 i = 0; i < s_platformAdmins.length; i++) {
            if (s_platformAdmins[i].adminAddress == _address) {
                s_platformAdmins[i] = s_platformAdmins[s_platformAdmins.length - 1];
                s_platformAdmins.pop();

                break;
            }
        }

        Admin[] storage senderAdminAdditions = s_adminAddressToAdditions_admin[msg.sender];

        // Remove from additions-list of the admin who added this admin
        for (uint256 i = 0; i < senderAdminAdditions.length; i++) {
            if (senderAdminAdditions[i].adminAddress == _address) {
                senderAdminAdditions[i] = senderAdminAdditions[senderAdminAdditions.length - 1];
                senderAdminAdditions.pop();

                break;
            }
        }

        emit RemovedAdmin("admin removed successfully", block.timestamp, CURRENT_CONTRACT_NAME, _address, msg.sender);
    }

    /**
     * @notice Returns the list of all registered platform admins.
     * @return An array of `Admin` structs representing all platform admins.
     */
    function getPlatformAdmins() public view returns (Admin[] memory) {
        return s_platformAdmins;
    }

    /**
     * @notice Retrieves the list of admins added by a specific admin.
     * @param _adminAddress The admin whose additions are requested.
     * @return An array of `Admin` structs representing the admins added by `_adminAddress`.
     */
    function getAdminAdminRegistrations(address _adminAddress) public view returns (Admin[] memory) {
        return s_adminAddressToAdditions_admin[_adminAddress];
    }

    /**
     * @notice Checks whether a given address currently holds admin status.
     * @param _adminAddress The address to check.
     * @return True if the address is an admin, false otherwise.
     */
    function checkIsAdmin(address _adminAddress) public view returns (bool) {
       return (s_isAdmin[_adminAddress]);
    }

    /**
     * @notice Retrieves the admin profile information for a given address.
     * @dev Reverts if the address is not an admin.
     * @param _adminAddress The admin address to query.
     * @return The `Admin` struct containing profile and registration metadata.
     * @custom:error AdminManagement__AddressIsNotAnAdmin Thrown if the address is not registered as an admin.
     */
    function getAdminProfile(address _adminAddress) public view returns (Admin memory) {
        if (!s_isAdmin[_adminAddress]) {
            revert AdminManagement__AddressIsNotAnAdmin();
        }

        Admin memory admin = s_adminAddressToAdminProfile[_adminAddress];

        return admin;
    }
}
