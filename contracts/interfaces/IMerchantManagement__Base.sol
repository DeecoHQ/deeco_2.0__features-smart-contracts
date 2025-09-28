// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

interface IMerchantManagement__Base {
    struct Merchant {
        address merchantId;
        address addedBy;
        uint256 addedAt;
        uint256 balance;
    }

    // -------- Errors --------
    error MerchantManagement__AlreadyAddedAsMerchant(Merchant merchant);
    error MerchantManagement__AddressIsNotMerchant();
    error MerchantManagement__ApprovedOperatorsOnly();
    error MerchantManagement__ZeroAddressError();

    // -------- Events --------
    event AddedNewMerchant(
        string message,
        uint256 timestamp,
        string contractName,
        address merchantId,
        address addedBy
    );

    event RemovedMerchant(
        string message,
        uint256 timestamp,
        string contractName,
        address merchantId,
        address removedBy
    );

    event UpdatedMerchantBalance(
        string message,
        uint256 timestamp,
        string contractName,
        address updatedBy,
        address merchantId,
        uint256 newBalance
    );

    // -------- Functions --------
    function addMerchant(address _merchantId) external;

    function removeMerchant(address _merchantId) external;

    function getMerchantBalance(address _merchantId)
        external
        view
        returns (uint256);

    function updateMerchantBalance(address _merchantId, uint256 _newBalance) external;

    function getPlatformMerchants() external view returns (Merchant[] memory);

    function getAdminMerchantRegistrations(address _adminAddress)
        external
        view
        returns (Merchant[] memory);

    function checkIsMerchant(address _merchantId) external view returns (bool);

    function getMerchantPayoutAddress() external view returns (address);

    function setMerchantPayoutAddress(address _address) external;

    function getMerchantProfile(address _merchantId)
        external
        view
        returns (Merchant memory);
}
