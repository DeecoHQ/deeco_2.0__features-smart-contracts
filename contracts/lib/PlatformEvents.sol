// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract PlatformEvents {

    event Logs(string message, uint256 timestamp, string indexed contractName);

    event AddedNewAdmin(
        string message,
        uint256 timestamp,
        string indexed contractName,
        address indexed addedAdminAddress,
        address indexed addedBy
    );

    event RemovedAdmin(
        string message,
        uint256 timestamp,
        string indexed contractName,
        address indexed removedAdminAddress,
        address indexed removedBy
    );

    event AddedNewMerchant(
        string message,
        uint256 timestamp,
        string indexed contractName,
        address indexed addedMerchantId,
        address indexed addedBy
    );

    event UpdatedMerchantBalance(
        string message,
        uint256 timestamp,
        string contractName,
        address indexed updatedBy,
        address indexed merchantId,
        uint256 indexed Amount
    );
    
    event RemovedMerchant(
        string message,
        uint256 timestamp,
        string indexed contractName,
        address indexed removedMerchantId,
        address indexed removedBy
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
