// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

// import the core admin management(admin and merchant management) contract inteface
import "../../core/Core__AdminManagement.sol";

/**
 * @title ProductManagementAuth
 * @notice Provides access control for product management actions by verifying whether a caller is:
 *         - The contract owner, or
 *         - An admin, or
 *         - A merchant, as determined by an external Core Admin Management contract.
 * @dev This contract interacts with an externally deployed `Core__AdminManagement` contract to validate
 *      administrative and merchant privileges. The check is done through the `onlyVerifiedProductManager` modifier.
 * 
 *      Key Features:
 *      - Restricts product management actions to verified roles only.
 *      - Owner address is stored in `i_owner` and is immutable after deployment.
 *      - Admin and merchant roles are checked dynamically through the external `Core__AdminManagement` contract.
 * 
 *      Usage:
 *      - Use the `onlyVerifiedProductManager` modifier to protect product-related functions.
 *      - The `_address` parameter should be explicitly passed in from `msg.sender` to ensure clarity and
 *        to allow for explicit message sender forwarding if needed.
 * 
 *      Example:
 *      ```
 *      contract ProductManager is ProductManagementAuth {
 *          function addProduct(string calldata productId) external onlyVerifiedProductManager(msg.sender) {
 *              // product addition logic
 *          }
 *      }
 *      ```
 * 
 *      Security Considerations:
 *      - Ensure `s_adminManagementCoreContractAddress` is set to a trusted and verified deployment of `Core__AdminManagement`.
 *      - Changes to `s_adminManagementCoreContractAddress` should themselves be access-controlled.
 *      - Passing `_address` instead of directly reading `msg.sender` adds explicitness but still requires
 *        validation of inputs.
 */
contract ProductManagementAuth {
    /**
     * @notice Error indicating that the caller is not a verified product manager.
     * @dev This error is triggered when none of the following conditions are met:
     *      - Caller is the owner (`i_owner`), OR
     *      - Caller is an admin as verified by the `Core__AdminManagement` contract, OR
     *      - Caller is a merchant as verified by the `Core__AdminManagement` contract.
     */
    error ProductManagementAuth__AccessDenied_VerifiedAdminsOnly();

    /**
     * @notice The address of the contract owner.
     * @dev Immutable and set once during deployment; cannot be modified afterward.
     *      The owner is automatically granted full product management privileges.
     */
    address internal immutable i_owner;

    /**
     * @notice The address of the external `Core__AdminManagement` contract.
     * @dev This contract is used to dynamically check admin and merchant status.
     *      Must be a valid deployment of the `Core__AdminManagement` interface.
     */
    address internal s_adminManagementCoreContractAddress;

    /**
     * @notice Restricts access to verified product managers (owner, admin, or merchant).
     * @dev This modifier performs three checks:
     *      1. Whether `_address` matches the immutable `i_owner`.
     *      2. Whether `_address` is an admin according to `Core__AdminManagement.checkIsAdmin`.
     *      3. Whether `_address` is a merchant according to `Core__AdminManagement.checkIsMerchant`.
     * 
     *      The `_address` argument should be passed explicitly as `msg.sender` from the calling function.
     * 
     * @param _address The address being verified for product management privileges (typically `msg.sender`).
     * 
     * @custom:example
     * function updateProduct(string calldata productId) external onlyVerifiedProductManager(msg.sender) {
     *     // logic to update product details
     * }
     */
    // "_address" will simply be the "msg.sender" being passed down - I feel this way is more secure than adding the message.sender here directly
    modifier onlyVerifiedProductManager(address _address) {
        // Core__AdminManagement(interface) - from the externally deployed 'Core__AdminManagement' contract
        if (
            _address != i_owner &&
            !Core__AdminManagement(s_adminManagementCoreContractAddress)
                .checkIsAdmin(_address) &&
            !Core__AdminManagement(s_adminManagementCoreContractAddress)
                .checkIsMerchant(_address)
        ) {
            revert ProductManagementAuth__AccessDenied_VerifiedAdminsOnly();
        }

        _;
    }
}
