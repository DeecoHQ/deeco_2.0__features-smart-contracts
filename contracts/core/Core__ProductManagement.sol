// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "../lib/PlatformEvents.sol";
import "../domains/auth/AdminAuth.sol";
import "../domains/product/ProductManagement.sol";

contract Core__ProductManagement is PlatformEvents, ProductManagement, AdminAuth {

    string private constant CONTRACT_NAME = "Core__ProductManagement";

    constructor(address _adminManagementCoreContractAddress) {
        // s_AdminManagementCoreContractAddress(variable) -  from ProductManagementAuth.sol
        s_adminManagementCoreContractAddress = _adminManagementCoreContractAddress;

        // i_owner(variable) - from ProductManagementAuth.sol
        i_owner = msg.sender;

        emit Logs("contract deployed successfully with constructor chores completed", block.timestamp, CONTRACT_NAME);
    }

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
            "Core__ProductManagement contract address updated successfully",
            block.timestamp,
            CONTRACT_NAME,
            address(this),
            "Core__Liquidity",
            _contractAddress,
            msg.sender
        );
    }

    function getAdminManagementCoreContractAddress() public view returns(address) {
        // s_AdminManagementCoreContractAddress(variable) -  from ProductManagementAuth.sol
        return s_adminManagementCoreContractAddress; 
    }

    function getContractName() public pure returns(string memory) {
        return CONTRACT_NAME;
    }

    function getContractOwner() public view returns(address) {
        return i_owner;
    }

    function ping() external view returns(string memory name, address contractAddress) {
        return (CONTRACT_NAME, address(this));
    }
}
