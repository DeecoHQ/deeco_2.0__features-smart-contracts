// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

interface IAdminManagement__Core {
    // -------- Events --------
    event AddedNewAdmin(
        string message,
        uint256 timestamp,
        string contractName,
        address newAdmin,
        address addedBy
    );

    event AddedNewMerchant(
        string message,
        uint256 timestamp,
        string contractName,
        address merchantId,
        address addedBy
    );

    event Logs(
        string message,
        uint256 timestamp,
        string contractName
    );

    event ExternalContractAddressUpdated(
        string message,
        uint256 timestamp,
        string contractName,
        address contractAddress,
        string contractLabel,
        address updatedAddress,
        address updatedBy
    );

    // -------- Functions --------

    function checkIsAdmin(address account) external view returns (bool);

    function updateLiquidityCoreContractAddress(address _contractAddress) external;

    function getLiquidityCoreContractAddress() external view returns (address);

    function getContractName() external pure returns (string memory);

    function getContractOwner() external view returns (address);

    function ping() external view returns (string memory, address, uint256);
}
