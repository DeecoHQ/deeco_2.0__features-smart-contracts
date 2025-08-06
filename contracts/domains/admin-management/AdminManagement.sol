// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;
import "../auth/Auth.sol";

contract AdminManagement is Restricted {
    error alreadyAddedAsAdmin();
    error userIsNotAnAdmin();

    struct Admin {
        address newAdminAddress;
        address addedBy;
        uint256 addedAt;
    }

    Admin[] internal s_platformAdmins;

    mapping(address => Admin[]) private s_adminAddressToAdditions;

    // adminOnly(modifier) - from Auth.sol
    // s_isAdmin(variable) - from Auth.sol
    function addAdmin(address _address) public adminOnly {
        if(s_isAdmin[_address]) {
            revert alreadyAddedAsAdmin();
        }

        Admin memory newAdmin = Admin({
            newAdminAddress: _address,
            addedBy: msg.sender,
            addedAt: block.timestamp
        });

        s_platformAdmins.push(newAdmin);

        Admin[] storage senderAdminAdditions = s_adminAddressToAdditions[msg.sender];
        senderAdminAdditions.push(newAdmin);

        s_adminAddressToAdditions[msg.sender] = senderAdminAdditions;
        s_isAdmin[_address] = true;
    } 

    function removeAdmin(address _address) public adminOnly {
        if(!s_isAdmin[_address]) {
            revert userIsNotAnAdmin();
        }

        s_isAdmin[_address] = false;
                
        // remove from platform admin list
        for(uint256 i = 0; i < s_platformAdmins.length; i++) {
            if(!s_isAdmin[s_platformAdmins[i].newAdminAddress]) { // checks if the item(admin) is no longer an admin(s_isAdmin == false)
                s_platformAdmins[i] = s_platformAdmins[s_platformAdmins.length - 1]; // replaces the item with the last item on the list

                s_platformAdmins.pop(); // removes the last item - task is done

                // break;
            }
        }

        Admin[] storage senderAdminAdditions = s_adminAddressToAdditions[msg.sender];

        // remove from platform admin list
        for(uint256 i = 0; i < senderAdminAdditions.length; i++) {
            if(!s_isAdmin[senderAdminAdditions[i].newAdminAddress]) { // checks if the item(admin) is no longer an admin(s_isAdmin == false)
                senderAdminAdditions[i] = senderAdminAdditions[senderAdminAdditions.length - 1]; // replaces the item with the last item on the list

                senderAdminAdditions.pop(); // removes the last item - task is done

                // break;
            }
        } 
    } 
    

    function getPlatformAdmins() public view returns (Admin[] memory){        
        return s_platformAdmins;
    }
    
    function getAdminRegistrations(address _adminAddress) public view returns(Admin[] memory) {                
        return s_adminAddressToAdditions[_adminAddress];
    }

    function checkIsAdmin(address _adminAddress) public view returns(bool) {
        return s_isAdmin[_adminAddress];
    }
}