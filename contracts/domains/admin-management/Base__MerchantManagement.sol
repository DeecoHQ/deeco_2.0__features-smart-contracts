// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "../auth/AdminAuth.sol";
import "../auth/MerchantAuth.sol";
import "../../lib/PlatformEvents.sol";

contract Base__MerchantManagement is AdminAuth, MerchantAuth, PlatformEvents {

    struct Merchant {
        address merchantId;
        address addedBy;
        uint256 addedAt;
        uint256 balance;
    }

    error MerchantManagement__AlreadyAddedAsMerchant(Merchant merchant);

    error MerchantManagement__AddressIsNotMerchant();

    error MerchantManagement__ApprovedOperatorsOnly();

    error MerchantManagement__ZeroAddressError();

    Merchant[] internal s_platformMerchants;

    mapping(address => Merchant[]) internal s_adminAddressToAdditions_merchants;

    mapping(address => Merchant) internal s_merchantAddressToMerchantProfile;

    string private constant CURRENT_CONTRACT_NAME = "MerchantManagement"; // keep name in one variable to avoid mispelling it at any point 

    address internal s_liquidityCoreContractAddress;

    address internal s_merchantPayoutAddress;

    function addMerchant(address _merchantId) public adminOnly {
        if (s_isMerchant[_merchantId]) {
            Merchant storage merchant = s_merchantAddressToMerchantProfile[
                _merchantId
            ];

            revert MerchantManagement__AlreadyAddedAsMerchant(merchant);
        }

        Merchant memory newMerchant = Merchant({
            merchantId: _merchantId,
            addedBy: msg.sender,
            addedAt: block.timestamp,
            balance: 0
        });

        s_platformMerchants.push(newMerchant);

        Merchant[] storage senderAdminAdditions = s_adminAddressToAdditions_merchants[
            msg.sender
        ];
        senderAdminAdditions.push(newMerchant);
        s_adminAddressToAdditions_merchants[msg.sender] = senderAdminAdditions;

        s_isMerchant[_merchantId] = true;
        s_merchantAddressToMerchantProfile[_merchantId] = newMerchant;

        emit AddedNewMerchant(
            "new merchant added successfully",
            block.timestamp,
            CURRENT_CONTRACT_NAME,
            _merchantId,
            msg.sender
        );
    }

    function removeMerchant(address _merchantId) public adminOnly {
        if (!s_isMerchant[_merchantId]) {
            revert MerchantManagement__AddressIsNotMerchant();
        }

        s_isMerchant[_merchantId] = false;

        // Remove from global merchants list
        for (uint256 i = 0; i < s_platformMerchants.length; i++) {
            if (s_platformMerchants[i].merchantId == _merchantId) {
                s_platformMerchants[i] = s_platformMerchants[
                    s_platformMerchants.length - 1
                ];
                s_platformMerchants.pop();

                break;
            }
        }

        Merchant[] storage senderAdminAdditions = s_adminAddressToAdditions_merchants[
            msg.sender
        ];

        // Remove from sender-specific admin additions list
        for (uint256 i = 0; i < senderAdminAdditions.length; i++) {
            if (senderAdminAdditions[i].merchantId == _merchantId) {
                senderAdminAdditions[i] = senderAdminAdditions[
                    senderAdminAdditions.length - 1
                ];
                senderAdminAdditions.pop();

                break;
            }
        }

        emit RemovedMerchant(
            "merchant removed successfully",
            block.timestamp,
            CURRENT_CONTRACT_NAME,
            _merchantId,
            msg.sender
        );
    }

    function getMerchantBalance(address _merchantId) public view returns(uint256) {
        if (!s_isMerchant[_merchantId]) {
            revert MerchantManagement__AddressIsNotMerchant();
        }

        return s_merchantAddressToMerchantProfile[_merchantId].balance;
    }

    function updateMerchantBalance(address _merchantId, uint256 _newBalance) public {
        if (!s_isAdmin[msg.sender] && msg.sender != s_liquidityCoreContractAddress) {
            revert MerchantManagement__ApprovedOperatorsOnly();
        }

        s_merchantAddressToMerchantProfile[_merchantId].balance = _newBalance;

        Merchant memory updatedMerchantProfile = s_merchantAddressToMerchantProfile[_merchantId];

        // update merchant in the platform merchants list
        for(uint256 i = 0; i < s_platformMerchants.length; i++) {
            if(s_platformMerchants[i].merchantId == _merchantId) {
                s_platformMerchants[i] = updatedMerchantProfile;

                break;
            }
        }

        // update merchant in the admin additions list
        for(uint256 i = 0; i < s_adminAddressToAdditions_merchants[updatedMerchantProfile.addedBy].length; i++) {
            if(s_adminAddressToAdditions_merchants[updatedMerchantProfile.addedBy][i].merchantId == _merchantId) {
                s_adminAddressToAdditions_merchants[updatedMerchantProfile.addedBy][i] = updatedMerchantProfile;

                break;
            }
        }

        emit UpdatedMerchantBalance (
            "merchant balance updated successfully",
            block.timestamp,
            CURRENT_CONTRACT_NAME,
            msg.sender,
            _merchantId,
            _newBalance
        );
    }

    function getPlatformMerchants() public view returns (Merchant[] memory) {
        return s_platformMerchants;
    }

    function getMerchantPayoutAddress() public view returns (address) {
        return s_merchantPayoutAddress;
    }
    
    function setMerchantPayoutAddress(address _address) public {
        if (_address == address(0)) {
            revert MerchantManagement__ZeroAddressError();
        }

        s_merchantPayoutAddress = _address;
    }

    function getAdminMerchantRegistrations(
        address _adminAddress
    ) public view returns (Merchant[] memory) {
        return s_adminAddressToAdditions_merchants[_adminAddress];
    }

    function checkIsMerchant(address _merchantId) public view returns (bool) {
        return (s_isMerchant[_merchantId]);
    }

    function getMerchantProfile(
        address _merchantId
    ) public view returns (Merchant memory) {
        if (!s_isMerchant[_merchantId]) {
            revert MerchantManagement__AddressIsNotMerchant();
        }

        Merchant memory merchant = s_merchantAddressToMerchantProfile[
            _merchantId
        ];

        return merchant;
    }
}
