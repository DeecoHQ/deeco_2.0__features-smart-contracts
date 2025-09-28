// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;
import "../../interfaces/IAdminManagement__Base.sol";
import "../../interfaces/IMerchantManagement__Base.sol";

contract ProductManagementAuth {
    error ProductManagementAuth__AccessDenied_VerifiedAdminsOnly();

    address internal immutable i_owner;

    address internal s_adminManagementCoreContractAddress;
    address internal s_merchantManagementCoreContractAddress;

    IAdminManagement__Base internal s_adminManagementContract__Base =
    IAdminManagement__Base(s_adminManagementCoreContractAddress);

    IMerchantManagement__Base internal s_merchantManagementContract__Base =
    IMerchantManagement__Base(s_merchantManagementCoreContractAddress);

    modifier onlyVerifiedProductManager(address _address) {
        // IAdminManagement__Base(interface) - from the externally deployed Admin Management contract
        if (
            _address != i_owner &&
            !s_adminManagementContract__Base.checkIsAdmin(_address) &&
            !s_merchantManagementContract__Base.checkIsMerchant(_address)
        ) {
            revert ProductManagementAuth__AccessDenied_VerifiedAdminsOnly();
        }

        _;
    }
}
