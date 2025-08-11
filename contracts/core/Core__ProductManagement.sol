// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "../lib/PlatformEvents.sol";
import "../domains/auth/AdminAuth.sol";
import "../domains/product/ProductManagement.sol";

/**
 * @title Core__ProductManagement
 * @notice Core-level product management contract that integrates product logic, admin authentication,
 *         and platform-wide event emission. Acts as the orchestration layer for product-related operations
 *         while enforcing access control via `AdminAuth` and `ProductManagementAuth` (inherited indirectly).
 * @dev This contract:
 *      - Inherits from `PlatformEvents` for emitting standardized events.
 *      - Inherits from `ProductManagement` for product domain logic and `ProductManagementAuth`'s access control storage.
 *      - Inherits from `AdminAuth` for admin verification.
 *      - Stores the `i_owner` (immutable owner) and the address of the `Core__AdminManagement` contract.
 */
contract Core__ProductManagement is PlatformEvents, ProductManagement, AdminAuth {
    /**
     * @notice Human-readable identifier for this contract instance.
     * @dev Used for off-chain tooling, debugging, and ping verification.
     */
    string private constant CONTRACT_NAME = "Core__ProductManagement";

    /**
     * @notice Deploys the Core__ProductManagement contract and initializes key state variables.
     * @dev 
     * - Sets the immutable owner `i_owner` (inherited from ProductManagementAuth) to `msg.sender`.
     * - Stores the reference to the `Core__AdminManagement` contract for admin/merchant verification.
     * - Emits a `Logs` event to record successful deployment.
     * @param _adminManagementCoreContractAddress The address of the deployed `Core__AdminManagement` contract
     *        used for verifying admins and merchants.
     */
    constructor(address _adminManagementCoreContractAddress) {
        // s_AdminManagementCoreContractAddress(variable) -  from ProductManagementAuth.sol
        s_adminManagementCoreContractAddress = _adminManagementCoreContractAddress;

        // i_owner(variable) - from ProductManagementAuth.sol
        i_owner = msg.sender;

        emit Logs("contract deployed successfully with constructor chores completed", block.timestamp, CONTRACT_NAME);
    }

    /**
    * @notice Updates the address of the `Core__AdminManagement` contract.
    * @dev
    * - This function can only be called by the contract owner (`i_owner`) or a verified admin
    *   from the current `Core__AdminManagement` contract.
    * - The updated address is critical for all future verification of admin and merchant roles,
    *   ensuring interactions refer to the correct external contract.
    * - Emits an `ExternalContractAddressUpdated` event recording the update details.
    * @param _contractAddress The new address of the deployed `Core__AdminManagement` contract.
    * @custom:error ProductManagementAuth__AccessDenied_VerifiedAdminsOnly
    *         Reverts if the caller is neither the owner nor a verified admin according to the existing `Core__AdminManagement` contract.
    */
    function updateAdminManagementCoreContractAddress(address _contractAddress) public {
        // Core__AdminManagement(interface) - from the externally deployed 'Core____AdminManagement' smart contract
        if (
            msg.sender != i_owner &&
            !Core__AdminManagement(s_adminManagementCoreContractAddress)
                .checkIsAdmin(msg.sender)
        ) {
            revert ProductManagementAuth__AccessDenied_VerifiedAdminsOnly();
        }

        // s_AdminManagementCoreContractAddress(variable) -  from ProductManagementAuth.sol
        // needed for interaction with the 'Core____AdminManagement' smart contract - is initially set via/in the constructor of this (Core__ProductManagement) smart contract
        s_adminManagementCoreContractAddress = _contractAddress;

        emit ExternalContractAddressUpdated(
            "'Core__Liquidity' contract address updated successfully",
            block.timestamp,
            CONTRACT_NAME,
            address(this),
            "Core__Liquidity",
            _contractAddress,
            msg.sender
        );
    }

    /**
     * @notice Retrieves the address of the `Core__AdminManagement` contract in use.
     * @dev This address is used for all admin/merchant verification checks.
     * @return The address of the `Core__AdminManagement` contract.
     */
    function getAdminManagementCoreContractAddress() public view returns(address) {
        // s_AdminManagementCoreContractAddress(variable) -  from ProductManagementAuth.sol
        return s_adminManagementCoreContractAddress; 
    }

    /**
     * @notice Returns the human-readable name of this contract instance.
     * @dev Useful for external systems to verify which contract they are interacting with.
     * @return The contract name as a string.
     */
    function getContractName() public pure returns(string memory) {
        return CONTRACT_NAME;
    }

    /**
     * @notice Retrieves the owner address of this contract.
     * @dev Owner is immutable and set at deployment in the constructor.
     * @return The address of the contract owner.
     */
    function getContractOwner() public view returns(address) {
        return i_owner;
    }

    /**
     * @notice External verification method to confirm contract identity and address.
     * @dev Returns both the contract name and its own deployed address.
     *      Intended to be called by external contracts before processing further logic.
     * @return name The contract name.
     * @return contractAddress The deployed address of this contract.
     */
    function ping() external view returns(string memory name, address contractAddress) {
        return (CONTRACT_NAME, address(this));
    }
}
