// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title PlatformEvents
 * @notice Defines standardized events and enums used across the platform to emit consistent logs
 *         for administrative, merchant, product, and external contract update activities.
 * @dev This contract acts as a centralized event interface to enable easier tracking and monitoring
 *      of platform activities by off-chain systems and for auditability.
 */
contract PlatformEvents {
    /**
     * @notice General log event for emitting informational messages with timestamps and contract context.
     * @param message Human-readable message describing the log.
     * @param timestamp Unix timestamp when the event was emitted.
     * @param contractName The name of the contract emitting the event (indexed for efficient filtering).
     */
    event Logs(string message, uint256 timestamp, string indexed contractName);

    /**
     * @notice Emitted when a new admin is added to the platform.
     * @param message Human-readable message describing the event.
     * @param timestamp Unix timestamp when the admin was added.
     * @param contractName The contract name emitting this event (indexed).
     * @param addedAdminAddress Address of the admin account that was added (indexed).
     * @param addedBy Address of the account (admin/owner) who performed the addition (indexed).
     */
    event AddedNewAdmin(
        string message,
        uint256 timestamp,
        string indexed contractName,
        address indexed addedAdminAddress,
        address indexed addedBy
    );

    /**
     * @notice Emitted when an admin is removed from the platform.
     * @param message Human-readable message describing the event.
     * @param timestamp Unix timestamp when the admin was removed.
     * @param contractName The contract name emitting this event (indexed).
     * @param removedAdminAddress Address of the admin account that was removed (indexed).
     * @param removedBy Address of the account (admin/owner) who performed the removal (indexed).
     */
    event RemovedAdmin(
        string message,
        uint256 timestamp,
        string indexed contractName,
        address indexed removedAdminAddress,
        address indexed removedBy
    );

    /**
     * @notice Emitted when a new merchant is added to the platform.
     * @param message Human-readable message describing the event.
     * @param timestamp Unix timestamp when the merchant was added.
     * @param contractName The contract name emitting this event (indexed).
     * @param addedMerchantId Address of the merchant that was added (indexed).
     * @param addedBy Address of the account who performed the addition (indexed).
     */
    event AddedNewMerchant(
        string message,
        uint256 timestamp,
        string indexed contractName,
        address indexed addedMerchantId,
        address indexed addedBy
    );

    /**
     * @notice Emitted when a merchant's balance is updated.
     * @param message Human-readable message describing the update.
     * @param timestamp Unix timestamp when the balance was updated.
     * @param contractName The contract name emitting this event.
     * @param updatedBy Address of the account performing the update (indexed).
     * @param merchantId Address of the merchant whose balance was updated (indexed).
     * @param Amount The amount by which the balance was updated (indexed).
     */
    event UpdatedMerchantBalance(
        string message,
        uint256 timestamp,
        string contractName,
        address indexed updatedBy,
        address indexed merchantId,
        uint256 indexed Amount
    );
    
    /**
     * @notice Emitted when a merchant is removed from the platform.
     * @param message Human-readable message describing the event.
     * @param timestamp Unix timestamp when the merchant was removed.
     * @param contractName The contract name emitting this event (indexed).
     * @param removedMerchantId Address of the merchant account that was removed (indexed).
     * @param removedBy Address of the account who performed the removal (indexed).
     */
    event RemovedMerchant(
        string message,
        uint256 timestamp,
        string indexed contractName,
        address indexed removedMerchantId,
        address indexed removedBy
    );

    /**
     * @notice Enum representing the types of product-related activities that can be emitted in events.
     */
    enum ProductChoreActivityType { AddedNewProduct, UpdatedProduct, DeletedProduct }

    /**
     * @notice Emitted when a product-related action occurs (addition, update, or deletion).
     * @param message Human-readable message describing the product activity.
     * @param timestamp Unix timestamp when the product activity happened.
     * @param activity Enum indicating the type of product activity (indexed for filtering).
     * @param contractName The contract name emitting this event.
     * @param productId Unique identifier of the product affected (indexed).
     * @param addedBy Address of the admin/merchant who performed the action (indexed).
     */
    event ProductChore(
        string message,
        uint256 timestamp,
        ProductChoreActivityType indexed activity,
        string contractName,
        string indexed productId, // string instead of uint256 - incase of DBs like mongoDB that use string-like item ids
        address indexed addedBy
    );

    /**
    * @notice Emitted when an external contract address reference is updated.
    * @param message Human-readable message describing the update.
    * @param timestamp Unix timestamp when the update occurred.
    * @param parentContractName The name of the contract updating the address.
    * @param parentContractAddress The address of the contract updating the reference (indexed).
    * @param addressUpdatedFor_ContractName The name or label of the contract/address being updated.
    * @param newAddressAdded The address of the contract/address being updated (indexed).
    * @param updatedBy The address of the account that triggered the update (indexed).
    */
    event ExternalContractAddressUpdated(
        string message,
        uint256 timestamp,
        string parentContractName,
        address indexed parentContractAddress,
        string addressUpdatedFor_ContractName,
        address indexed newAddressAdded,
        address indexed updatedBy
    );
}
