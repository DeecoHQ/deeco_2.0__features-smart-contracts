// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "../lib/PlatformEvents.sol";
import "../domains/auth/OnlyOwnerAuth.sol";
import "../domains/admin-management/AdminManagement.sol";
import "../domains/admin-management/MerchantManagement.sol";

/**
 * @title Core__AdminManagement
 * @notice Core contract that manages platform admins and merchants, combining ownership, admin, and merchant management.
 * @dev
 * - Inherits ownership authorization, platform event logging, admin management, and merchant management.
 * - Upon deployment, assigns the deployer as the contract owner, master admin, and master merchant.
 * - Provides functions to update and query the liquidity core contract address, contract name, owner, and health check.
 */
contract Core__AdminManagement is
    OnlyOwnerAuth,
    PlatformEvents,
    AdminManagement,
    MerchantManagement
{
    string private constant CONTRACT_NAME = "Core__AdminManagement"; // set in one place to avoid mispelling elsewhere

    /**
     * @notice Assigns the deployer as the master admin.
     * @dev
     * - Creates an Admin struct with `msg.sender` as the admin and adder.
     * - Adds the master admin to the list of platform admins and tracks additions by the sender.
     * - Marks the sender as admin in the authorization mapping.
     * - Emits `AddedNewAdmin` event indicating successful addition.
     * @custom:visibility private
     */
    function makeMasterAdmin() private {
        // Admin(struct) - from AdminManagement.sol
        Admin memory masterAdmin = Admin({
            adminAddress: msg.sender,
            addedBy: msg.sender,
            addedAt: block.timestamp
        });

        // s_platformAdmins - from AdminManagement.sol
        s_platformAdmins.push(masterAdmin);

        Admin[]
            storage senderAdminAdditions_admin = s_adminAddressToAdditions_admin[
                msg.sender
            ];
        senderAdminAdditions_admin.push(masterAdmin);

        s_adminAddressToAdditions_admin[
            msg.sender
        ] = senderAdminAdditions_admin;
        // s_isAdmin(variable) - from AdminAuth.sol
        s_isAdmin[msg.sender] = true;
        s_adminAddressToAdminProfile[msg.sender] = masterAdmin;

        emit AddedNewAdmin(
            "new admin added successfully",
            block.timestamp,
            CONTRACT_NAME,
            msg.sender,
            msg.sender
        );
    }

    /**
     * @notice Assigns the deployer as the master merchant.
     * @dev
     * - Creates a Merchant struct with `msg.sender` as the merchant and adder, with zero initial balance.
     * - Adds the master merchant to the list of platform merchants and tracks additions by the sender.
     * - Marks the sender as merchant in the authorization mapping.
     * - Emits `AddedNewMerchant` event indicating successful addition.
     * @custom:visibility private
     */
    function makeMasterMerchant() private {
        // Merchant(struct) - from MerchantManagement.sol
        Merchant memory masterMerchant = Merchant({
            merchantId: msg.sender,
            addedBy: msg.sender,
            addedAt: block.timestamp,
            balance: 0
        });

        // s_platformMerchant(variable) - from MerchantManagement.sol
        s_platformMerchants.push(masterMerchant);

        Merchant[]
            storage senderAdminAdditions_merchant = s_adminAddressToAdditions_merchants[
                msg.sender
            ];

        senderAdminAdditions_merchant.push(masterMerchant);
        s_adminAddressToAdditions_merchants[
            msg.sender
        ] = senderAdminAdditions_merchant;

        // s_isMerchant(variable) - from MerchantAuth.sol
        s_isMerchant[msg.sender] = true;
        s_merchantAddressToMerchantProfile[msg.sender] = masterMerchant;

        emit AddedNewMerchant(
            "new merchant added successfully",
            block.timestamp,
            CONTRACT_NAME,
            msg.sender,
            msg.sender
        );
    }

    /**
     * @notice Contract constructor that initializes the owner, master admin, and master merchant.
     * @dev
     * - Sets the deployer as the immutable contract owner.
     * - Grants deployer admin and merchant roles.
     * - Calls internal functions to register deployer as master admin and merchant.
     * - Emits a `Logs` event signaling successful deployment.
     */
    constructor() {
        // i_owner(variable) - from OnlyOwnerAuth.sol
        i_owner = msg.sender;
        s_isAdmin[msg.sender] = true;
        s_isMerchant[msg.sender] = true;

        makeMasterAdmin();
        makeMasterMerchant();

        emit Logs(
            "contract deployed successfully with constructor chores completed",
            block.timestamp,
            CONTRACT_NAME
        );
    }

    /**
     * @notice Updates the address of the `Core__Liquidity` contract used for liquidity management.
     * @dev
     * - Can only be called by an admin (`adminOnly` modifier).
     * - Updates internal reference used by merchant management for balance updates and related logic.
     * - Emits `ExternalContractAddressUpdated` event documenting the address change.
     * @param _contractAddress The new deployed address of the `Core__Liquidity` contract.
     */
    function updateLiquidityCoreContractAddress(
        address _contractAddress
    ) public adminOnly {
        // s_liquidityCoreContractAddress(variable) - from MerchantManagement.sol
        s_liquidityCoreContractAddress = _contractAddress;

        emit ExternalContractAddressUpdated(
            "'Core____AdminManagement' contract address updated successfully",
            block.timestamp,
            CONTRACT_NAME,
            address(this),
            "Core____AdminManagement",
            _contractAddress,
            msg.sender
        );
    }

    /**
     * @notice Retrieves the current address of the `Core__Liquidity` contract.
     * @return The address currently set for liquidity core contract interaction.
     */
    function getLiquidityCoreContractAddress() public view returns (address) {
        // s_liquidityCoreContractAddress(variable) - from MerchantManagement.sol
        return s_liquidityCoreContractAddress;
    }

    /**
     * @notice Returns the name identifier of this contract.
     * @return The constant string "Core__AdminManagement".
     */
    function getContractName() public pure returns (string memory) {
        return CONTRACT_NAME;
    }

    /**
     * @notice Returns the owner address of the contract.
     * @return The address that deployed the contract and holds ownership rights.
     */
    function getContractOwner() public view returns (address) {
        return i_owner;
    }

    /**
     * @notice Provides a simple ping endpoint to verify contract availability and basic info.
     * @dev
     * - Callable externally to confirm the contract is deployed and responsive.
     * @return contractName The name of the contract.
     * @return contractAddress The current contract address.
     * @return currentTimestamp The current blockchain timestamp.
     */
    // to be called as a verification - from external contracts - before they process other function calls
    function ping() external view returns(string memory, address, uint256) {
        return(CONTRACT_NAME, address(this), block.timestamp);
    }
}
