// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;
import "./domains/auth/Auth.sol";
import "./domains/admin-management/AdminManagement.sol";

contract Core is Restricted, AdminManagement {
    string private contractName;

    constructor(string memory _contractName) {
        s_masterAdmin = msg.sender;
        s_isAdmin[msg.sender] = true;
        contractName = _contractName;

        // Admin(struct) - from AdminManagement.sol
        // s_platformAdmins - from AdminManagement.sol
        Admin memory masterAdmin = Admin({
            newAdminAddress: msg.sender,
            addedBy: msg.sender,
            addedAt: block.timestamp
        });

        s_platformAdmins.push(masterAdmin);
    }
}