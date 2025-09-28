// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "../lib/PlatformEvents.sol";
import "../domains/auth/OnlyOwnerAuth.sol";
import "../domains/admin-management/Base__AdminManagement.sol";
import "../domains/admin-management/Base__MerchantManagement.sol";

contract Core__AdminManagement is
    OnlyOwnerAuth,
    PlatformEvents,
    Base__AdminManagement,
    Base__MerchantManagement
{
    string private constant CONTRACT_NAME = "Core__AdminManagement"; // set in one place to avoid mispelling elsewhere

    function makeMasterAdmin() private {
        // Admin(struct) - from AdminManagement.sol
        Admin memory masterAdmin = Admin({
            adminAddress: msg.sender,
            addedBy: msg.sender,
            addedAt: block.timestamp
        });

        // s_platformAdmins - from AdminManagement.sol
        s_platformAdmins.push(masterAdmin);

        Admin[]
            storage senderAdminAdditions_admin = s_adminAddressToAdditions_admin[
                msg.sender
            ];
        senderAdminAdditions_admin.push(masterAdmin);

        s_adminAddressToAdditions_admin[
            msg.sender
        ] = senderAdminAdditions_admin;
        // s_isAdmin(variable) - from AdminAuth.sol
        s_isAdmin[msg.sender] = true;
        s_adminAddressToAdminProfile[msg.sender] = masterAdmin;

        emit AddedNewAdmin(
            "new admin added successfully",
            block.timestamp,
            CONTRACT_NAME,
            msg.sender,
            msg.sender
        );
    }

    function makeMasterMerchant() private {
        // Merchant(struct) - from MerchantManagement.sol
        Merchant memory masterMerchant = Merchant({
            merchantId: msg.sender,
            addedBy: msg.sender,
            addedAt: block.timestamp,
            balance: 0
        });

        // s_platformMerchant(variable) - from MerchantManagement.sol
        s_platformMerchants.push(masterMerchant);

        Merchant[]
            storage senderAdminAdditions_merchant = s_adminAddressToAdditions_merchants[
                msg.sender
            ];

        senderAdminAdditions_merchant.push(masterMerchant);
        s_adminAddressToAdditions_merchants[
            msg.sender
        ] = senderAdminAdditions_merchant;

        // s_isMerchant(variable) - from MerchantAuth.sol
        s_isMerchant[msg.sender] = true;
        s_merchantAddressToMerchantProfile[msg.sender] = masterMerchant;

        emit AddedNewMerchant(
            "new merchant added successfully",
            block.timestamp,
            CONTRACT_NAME,
            msg.sender,
            msg.sender
        );
    }

    constructor() {
        // i_owner(variable) - from OnlyOwnerAuth.sol
        i_owner = msg.sender;
        s_isAdmin[msg.sender] = true;
        s_isMerchant[msg.sender] = true;

        makeMasterAdmin();
        makeMasterMerchant();

        emit Logs(
            "contract deployed successfully with constructor chores completed",
            block.timestamp,
            CONTRACT_NAME
        );
    }

    // function updateLiquidityCoreContractAddress(
    //     address _contractAddress
    // ) public adminOnly {
    //     // s_liquidityCoreContractAddress(variable) - from MerchantManagement.sol
    //     s_liquidityCoreContractAddress = _contractAddress;

    //     emit ExternalContractAddressUpdated(
    //         "Core____AdminManagement contract address updated successfully",
    //         block.timestamp,
    //         CONTRACT_NAME,
    //         address(this),
    //         "Core____AdminManagement",
    //         _contractAddress,
    //         msg.sender
    //     );
    // }

    // function getLiquidityCoreContractAddress() public view returns (address) {
    //     // s_liquidityCoreContractAddress(variable) - from MerchantManagement.sol
    //     return s_liquidityCoreContractAddress;
    // }

    function getContractName() public pure returns (string memory) {
        return CONTRACT_NAME;
    }

    function getContractOwner() public view returns (address) {
        return i_owner;
    }

    function ping() external view returns(string memory, address, uint256) {
        return(CONTRACT_NAME, address(this), block.timestamp);
    }
}
