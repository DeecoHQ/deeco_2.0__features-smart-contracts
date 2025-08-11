// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "../auth/AdminAuth.sol";
import "../auth/MerchantAuth.sol";
import "../../lib/PlatformEvents.sol";

/**
 * @title MerchantManagement
 * @notice Manages merchants on the platform, including adding, removing, updating balances, and retrieving merchant profiles.
 *         Enforces access controls: only admins can add or remove merchants, and only admins or the Core__Liquidity contract
 *         can update merchant balances.
 * @dev
 * - Inherits from AdminAuth and MerchantAuth for role verification.
 * - Emits platform events to track merchant lifecycle and balance updates.
 */
contract MerchantManagement is AdminAuth, MerchantAuth, PlatformEvents {
    /**
     * @notice Struct representing a merchant and metadata about their registration.
     * @param merchantId The Ethereum address of the merchant.
     * @param addedBy The address of the admin who added this merchant.
     * @param addedAt Unix timestamp when the merchant was added.
     * @param balance The current balance associated with the merchant.
     */
    struct Merchant {
        address merchantId;
        address addedBy;
        uint256 addedAt;
        uint256 balance;
    }

    /**
     * @notice Error thrown when attempting to add an address that is already a merchant.
     * @param merchant The existing merchant profile for the address.
     */
    error MerchantManagement__AlreadyAddedAsMerchant(Merchant merchant);

    /**
     * @notice Error thrown when an address is expected to be a merchant but is not.
     */
    error MerchantManagement__AddressIsNotMerchant();

    /**
     * @notice Error thrown when an unauthorized operator attempts to update a merchant balance.
     */
    error MerchantManagement__ApprovedOperatorsOnly();

    /// @notice List of all merchants currently registered on the platform.
    Merchant[] internal s_platformMerchants;

    /// @notice Maps an admin address to a list of merchants they have added.
    mapping(address => Merchant[]) internal s_adminAddressToAdditions_merchants;

    /// @notice Maps a merchant address to their merchant profile.
    mapping(address => Merchant) internal s_merchantAddressToMerchantProfile;

    /// @notice Name of this contract for event logging context.
    string private constant CURRENT_CONTRACT_NAME = "MerchantManagement"; // keep name in one variable to avoid mispelling it at any point 

    /**
     * @notice Address of the external Core__Liquidity contract authorized to update merchant balances.
     * @dev Can only be set or updated by an admin (setter function not shown in this snippet).
     */
    address internal s_liquidityCoreContractAddress;

    /**
     * @notice Adds a new merchant to the platform.
     * @dev Only callable by an admin (`adminOnly` modifier).
     *      Reverts with `MerchantManagement__AlreadyAddedAsMerchant` if the merchant already exists.
     * @param _merchantId The address of the merchant to add.
     */
    function addMerchant(address _merchantId) public adminOnly {
        if (s_isMerchant[_merchantId]) {
            Merchant storage merchant = s_merchantAddressToMerchantProfile[
                _merchantId
            ];

            revert MerchantManagement__AlreadyAddedAsMerchant(merchant);
        }

        Merchant memory newMerchant = Merchant({
            merchantId: _merchantId,
            addedBy: msg.sender,
            addedAt: block.timestamp,
            balance: 0
        });

        s_platformMerchants.push(newMerchant);

        Merchant[] storage senderAdminAdditions = s_adminAddressToAdditions_merchants[
            msg.sender
        ];
        senderAdminAdditions.push(newMerchant);
        s_adminAddressToAdditions_merchants[msg.sender] = senderAdminAdditions;

        s_isMerchant[_merchantId] = true;
        s_merchantAddressToMerchantProfile[_merchantId] = newMerchant;

        emit AddedNewMerchant(
            "new merchant added successfully",
            block.timestamp,
            CURRENT_CONTRACT_NAME,
            _merchantId,
            msg.sender
        );
    }

    /**
     * @notice Removes an existing merchant from the platform.
     * @dev Only callable by an admin (`adminOnly` modifier).
     *      Reverts with `MerchantManagement__AddressIsNotMerchant` if merchant does not exist.
     *      Removes merchant from storage mappings and arrays.
     * @param _merchantId The address of the merchant to remove.
     */
    function removeMerchant(address _merchantId) public adminOnly {
        if (!s_isMerchant[_merchantId]) {
            revert MerchantManagement__AddressIsNotMerchant();
        }

        s_isMerchant[_merchantId] = false;

        // Remove from global merchants list
        for (uint256 i = 0; i < s_platformMerchants.length; i++) {
            if (s_platformMerchants[i].merchantId == _merchantId) {
                s_platformMerchants[i] = s_platformMerchants[
                    s_platformMerchants.length - 1
                ];
                s_platformMerchants.pop();

                break;
            }
        }

        Merchant[] storage senderAdminAdditions = s_adminAddressToAdditions_merchants[
            msg.sender
        ];

        // Remove from sender-specific admin additions list
        for (uint256 i = 0; i < senderAdminAdditions.length; i++) {
            if (senderAdminAdditions[i].merchantId == _merchantId) {
                senderAdminAdditions[i] = senderAdminAdditions[
                    senderAdminAdditions.length - 1
                ];
                senderAdminAdditions.pop();

                break;
            }
        }

        emit RemovedMerchant(
            "merchant removed successfully",
            block.timestamp,
            CURRENT_CONTRACT_NAME,
            _merchantId,
            msg.sender
        );
    }

    /**
     * @notice Returns the current balance of a merchant.
     * @dev Reverts if the address is not registered as a merchant.
     * @param _merchantId The merchant address to query.
     * @return The current balance of the merchant.
     */
    function getMerchantBalance(address _merchantId) public view returns(uint256) {
        if (!s_isMerchant[_merchantId]) {
            revert MerchantManagement__AddressIsNotMerchant();
        }

        return s_merchantAddressToMerchantProfile[_merchantId].balance;
    }

    /**
     * @notice Updates the balance for a merchant.
     * @dev Only callable by an admin or the Core__Liquidity contract.
     *      Reverts with `MerchantManagement__ApprovedOperatorsOnly` if caller is unauthorized.
     *      Emits an `UpdatedMerchantBalance` event upon success.
     * @param _merchantId The merchant address whose balance will be updated.
     * @param _newBalance The new balance value to set.
     */
    function updateMerchantBalance(address _merchantId, uint256 _newBalance) public {
        if (!s_isAdmin[msg.sender] && msg.sender != s_liquidityCoreContractAddress) {
            revert MerchantManagement__ApprovedOperatorsOnly();
        }

        s_merchantAddressToMerchantProfile[_merchantId].balance = _newBalance;

        Merchant memory updatedMerchantProfile = s_merchantAddressToMerchantProfile[_merchantId];

        // update merchant in the platform merchants list
        for(uint256 i = 0; i < s_platformMerchants.length; i++) {
            if(s_platformMerchants[i].merchantId == _merchantId) {
                s_platformMerchants[i] = updatedMerchantProfile;

                break;
            }
        }

        // update merchant in the admin additions list
        for(uint256 i = 0; i < s_adminAddressToAdditions_merchants[updatedMerchantProfile.addedBy].length; i++) {
            if(s_adminAddressToAdditions_merchants[updatedMerchantProfile.addedBy][i].merchantId == _merchantId) {
                s_adminAddressToAdditions_merchants[updatedMerchantProfile.addedBy][i] = updatedMerchantProfile;

                break;
            }
        }

        emit UpdatedMerchantBalance (
            "merchant balance updated successfully",
            block.timestamp,
            CURRENT_CONTRACT_NAME,
            msg.sender,
            _merchantId,
            _newBalance
        );
    }

    /**
     * @notice Returns all merchants registered on the platform.
     * @return An array of `Merchant` structs representing all merchants.
     */
    function getPlatformMerchants() public view returns (Merchant[] memory) {
        return s_platformMerchants;
    }

    /**
     * @notice Returns the list of merchants added by a specific admin.
     * @param _adminAddress The admin address whose merchant additions are requested.
     * @return An array of `Merchant` structs representing merchants added by the admin.
     */
    function getAdminMerchantRegistrations(
        address _adminAddress
    ) public view returns (Merchant[] memory) {
        return s_adminAddressToAdditions_merchants[_adminAddress];
    }

    /**
     * @notice Checks if an address is a registered merchant.
     * @param _merchantId The address to check.
     * @return True if the address is a merchant, false otherwise.
     */
    function checkIsMerchant(address _merchantId) public view returns (bool) {
        return (s_isMerchant[_merchantId]);
    }

    /**
     * @notice Retrieves the merchant profile for a given address.
     * @dev Reverts if the address is not a merchant.
     * @param _merchantId The merchant address to query.
     * @return The `Merchant` struct containing profile and registration metadata.
     */
    function getMerchantProfile(
        address _merchantId
    ) public view returns (Merchant memory) {
        if (!s_isMerchant[_merchantId]) {
            revert MerchantManagement__AddressIsNotMerchant();
        }

        Merchant memory merchant = s_merchantAddressToMerchantProfile[
            _merchantId
        ];

        return merchant;
    }
}
