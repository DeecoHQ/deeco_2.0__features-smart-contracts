// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

interface IAdminManagement__Base {
    struct Admin {
        address adminAddress;
        address addedBy;
        uint256 addedAt;
    }

    // -------- Errors --------
    error AdminManagement__AlreadyAddedAsAdmin(Admin admin);
    error AdminManagement__AddressIsNotAnAdmin();

    // -------- Events --------
    event AddedNewAdmin(
        string message,
        uint256 timestamp,
        string contractName,
        address newAdmin,
        address addedBy
    );

    event RemovedAdmin(
        string message,
        uint256 timestamp,
        string contractName,
        address removedAdmin,
        address removedBy
    );

    // -------- Functions --------
    function addAdmin(address _address) external;

    function removeAdmin(address _address) external;

    function getPlatformAdmins() external view returns (Admin[] memory);

    function getAdminAdminRegistrations(address _adminAddress)
        external
        view
        returns (Admin[] memory);

    function checkIsAdmin(address _adminAddress) external view returns (bool);

    function getAdminProfile(address _adminAddress)
        external
        view
        returns (Admin memory);
}
