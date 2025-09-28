// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../domains/order-management/Base__OrderManagement.sol";
import "../interfaces/IAdminManagement__Core.sol";

contract Core__OrderManagement is Base__OrderManagement {
    error OrderManagementCore__ZeroAddressError();
    error OrderManagementCore__AccessDenied_AdminOnly();
    error OrderManagementCore__NonMatchingAdminAddress();

    event Logs(string message, uint256 timestamp, string indexed contractName);

    string private constant CONTRACT_NAME = "Core__OrderManagement";
    address private immutable i_owner;

    function _verifyIsAddress(address _address) private pure {
        if (_address == address(0)) {
            revert OrderManagementCore__ZeroAddressError();
        }
    }

    constructor(address _adminManagementCoreContractAddress) {
        _verifyIsAddress(_adminManagementCoreContractAddress);

        s_adminManagementCoreContractAddress = _adminManagementCoreContractAddress;
        s_adminManagementContract__Base = IAdminManagement__Base(s_adminManagementCoreContractAddress);

        i_owner = msg.sender;

        emit Logs(
            "contract deployed successfully with constructor chores completed",
            block.timestamp,
            CONTRACT_NAME
        );
    }

    function getContractName() public pure returns (string memory) {
        return CONTRACT_NAME;
    }

    function getContractOwner() public view returns (address) {
        return i_owner;
    }

    function updateAdminManagementCoreContractAddress(address _newAddress) public {
        if (!s_adminManagementContract__Base.checkIsAdmin(msg.sender)) {
            revert OrderManagementCore__AccessDenied_AdminOnly();
        }

        if (_newAddress == address(0)) {
            revert OrderManagementCore__ZeroAddressError();
        }

        IAdminManagement__Core s_adminManagementContractToVerify = IAdminManagement__Core(_newAddress);
        ( , address contractAddress, ) = s_adminManagementContractToVerify.ping();

        if (contractAddress != _newAddress) {
            revert OrderManagementCore__NonMatchingAdminAddress();
        }

        if (!s_adminManagementContractToVerify.checkIsAdmin(msg.sender)) {
            revert OrderManagementCore__AccessDenied_AdminOnly();
        }

        s_adminManagementCoreContractAddress = _newAddress;
        s_adminManagementContract__Base = IAdminManagement__Base(s_adminManagementCoreContractAddress);
    }

    function setERC20TokenAddress(address _address) public {
        if (
            !s_adminManagementContract__Base.checkIsAdmin(msg.sender)
        ) {
            revert OrderManagementCore__AccessDenied_AdminOnly();
        }

        if (_address == address(0)) {
            revert OrderManagementCore__ZeroAddressError();
        }

        s_ERC20TokenAddress  = _address;
        s_ERC20Contract = IERC20(s_ERC20TokenAddress);
    }

    function getAdminManagementCoreContractAddress() public view returns (address) {
        return s_adminManagementCoreContractAddress;
    }

    function ping() external view returns (string memory, address, uint256) {
        return (CONTRACT_NAME, address(this), block.timestamp);
    }
}