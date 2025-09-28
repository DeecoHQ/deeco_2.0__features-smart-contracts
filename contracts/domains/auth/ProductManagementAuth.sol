// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

// import the core admin management(admin and merchant management) contract inteface
import "../../core/Core__AdminManagement.sol";

contract ProductManagementAuth {
    error ProductManagementAuth__AccessDenied_VerifiedAdminsOnly();

    address internal immutable i_owner;

    address internal s_adminManagementCoreContractAddress;

    IAdminManagement__Base internal s_adminManagementContract__Base =
    IAdminManagement__Base(s_adminManagementCoreContractAddress);

    modifier onlyVerifiedProductManager(address _address) {
        // Core__AdminManagement(interface) - from the externally deployed 'Core__AdminManagement' contract
        if (
            _address != i_owner &&
            !Core__AdminManagement(s_adminManagementCoreContractAddress)
                .checkIsAdmin(_address) &&
            !Core__AdminManagement(s_adminManagementCoreContractAddress)
                .checkIsMerchant(_address)
        ) {
            revert ProductManagementAuth__AccessDenied_VerifiedAdminsOnly();
        }

        _;
    }
}
