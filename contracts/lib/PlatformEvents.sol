// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/// @title Centralized Event Emitter Contract
/// @author
/// @notice This contract defines all the events for the project.
/// @dev Events can be inherited and emitted by other contracts for standardized logging.

contract PlatformEvents {
    /// @notice Emitted for general logging purposes.
    /// @param message A custom message describing the log.
    /// @param timestamp The timestamp when the log was emitted.
    /// @param contractName The name of the contract emitting the log.
    event Logs(string message, uint256 timestamp, string indexed contractName);

    /// @notice Emitted when an admin is removed.
    /// @param message A description of the removal action.
    /// @param timestamp The time the removal occurred.
    /// @param contractName The name of the contract emitting the event.
    /// @param removedAdminAddress The address of the admin that was removed.
    event RemovedAdmin(
        string message,
        uint256 timestamp,
        string contractName,
        address indexed removedAdminAddress,
        address indexed removedBy
    );

    /// @notice Emitted when a new admin is added.
    /// @param message A description of the addition action.
    /// @param timestamp The time the new admin was added.
    /// @param contractName The name of the contract emitting the event.
    /// @param addedAdminAddress The address of the new admin that was added.
    event AddedNewAdmin(
        string message,
        uint256 timestamp,
        string contractName,
        address indexed addedAdminAddress,
        address indexed addedBy
    );

    enum ProductChoreActivityType { AddedNewProduct, UpdatedProduct, DeletedProduct }

    event ProductChore(
        string message,
        uint256 timestamp,
        ProductChoreActivityType indexed activity,
        string contractName,
        string indexed productId, // string instead of uint256 - incase of DBs like mongoDB that use string-like item ids
        address indexed addedBy
    );
}
