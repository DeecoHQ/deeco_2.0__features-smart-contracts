// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "../lib/PlatformEvents.sol";
import "../domains/auth/AdminAuth.sol";
import "../domains/product/Base__ProductManagement.sol";
import "../interfaces/IAdminManagement__Core.sol";

contract Core__ProductManagement is PlatformEvents, ProductManagement, AdminAuth {
    error ProductManagementCore__ZeroAddressError();
    error ProductManagementCore__AccessDenied_AdminOnly();
    error ProductManagementCore__NonMatchingAdminAddress();
    
    string private constant CONTRACT_NAME = "Core__ProductManagement";

    function _verifyIsAddress(address _address) private pure {
        if (_address == address(0)) {
            revert ProductManagementCore__ZeroAddressError();
        }
    }

    constructor(address _adminManagementCoreContractAddress) {
        // s_adminManagementCoreContractAddress(variable) -  from ProductManagementAuth.sol
        _verifyIsAddress(_adminManagementCoreContractAddress);
        
        s_adminManagementCoreContractAddress = _adminManagementCoreContractAddress;

        // they're both from the same contract but with different interfaces
        s_adminManagementContract__Base = IAdminManagement__Base(s_adminManagementCoreContractAddress);

        s_merchantManagementCoreContractAddress = s_adminManagementCoreContractAddress;

        s_merchantManagementContract__Base = IMerchantManagement__Base(s_adminManagementCoreContractAddress);

        // i_owner(variable) - from ProductManagementAuth.sol
        i_owner = msg.sender;

        emit Logs("contract deployed successfully with constructor chores completed", block.timestamp, CONTRACT_NAME);
    }

    function updateAdminManagementCoreContractAddress(
        address _newAddress
    ) public {
        if (!s_adminManagementContract__Base.checkIsAdmin(msg.sender)) {
            revert ProductManagementCore__AccessDenied_AdminOnly();
        }
        
        if (_newAddress == address(0)) {
            revert ProductManagementCore__ZeroAddressError();
        }

        /* 
        updating the admin management core contract address is a very sensitive process. The old/current contract 
        to switch from can be active and working, but if the 'isAdmin' check is passed(on the old/current contract), 
        and a new address is set which is wrong, it becomes impossible to now connect to the intending admin 
        contract. Hence the next step of admin check below, will keep failing and impossible to pass due to contract 
        immutability. Other chores requiring admin check will also be impossible.
    
        Hence the need to first connect and ping to make sure the new contract works before setting
        */
        // first connect and ping
        IAdminManagement__Core s_adminManagementContractToVerify = IAdminManagement__Core(_newAddress);
        ( , address contractAddress, ) = s_adminManagementContractToVerify.ping();

        // the fact that it pings without an error is enough - but still do as below to be super-sure
        if(contractAddress != _newAddress) { 
            revert ProductManagementCore__NonMatchingAdminAddress();
        }

        /* also ensure current sender is an admin on that contract - which further verifies that the contract 
        is indeed and 'adminManagement' contract */
        if (!s_adminManagementContractToVerify.checkIsAdmin(msg.sender)) {
            revert ProductManagementCore__AccessDenied_AdminOnly();
        }

        s_adminManagementCoreContractAddress = _newAddress;
        s_adminManagementContract__Base = IAdminManagement__Base(s_adminManagementCoreContractAddress);
    }

    // function updateMerchantManagementCoreContractAddress(address _newAddress) public {
    //     _verifyIsAddress(_newAddress);

    //     if (!s_adminManagementContract__Base.checkIsAdmin(msg.sender)) {
    //         revert ProductManagementCore__AccessDenied_AdminOnly();
    //     }

    //     s_merchantManagementCoreContractAddress = _newAddress;

    //     s_merchantManagementContract__Base = IMerchantManagement__Base(s_merchantManagementCoreContractAddress);
    // }

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
