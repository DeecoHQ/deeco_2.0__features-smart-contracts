// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;
// import "../auth/OnlyOwnerAuth.sol";
import "../../interfaces/IAdminManagement__Base.sol";
import "../../interfaces/IERC20.sol";

contract Base__OrderManagement {
    error OrderManagement__ZeroAddressError();
    error OrderManagement__AccessDenied_VerifiedAdminsOnly();

    event OrderProcessed(
        address indexed payer,
        address indexed token,
        uint256 totalAmount,
        uint256 commission,
        uint256 merchantAmount
    );

    struct Order {
        uint256 orderId;
        address createdBy;
        string orderCID;
        uint256 totalAmount;
        uint256 createdAt;
        /* 
        the incoming total amount will always be 101%(100%[product price] + 1%[platform fee/commission charged from the buyer])
        that way, we deduct our platform 2%, and payout 98% to the merchant.
        */
    }

    /* 
    The ledger Id tracker, is a counter that helps to prevent re-use of ids on previously created entries(orders). 
    This simply means that an id can only be used once - like in regular off-chain databases. By addding this, even when an 
    order is removed for any reason, the tracker can simply continue the count without depending on a check of the length
    of the orders array, since using that length will permit re-using Ids - which can result in conflicts.
    
    This problem will still re-surface if for any reason a new order contract is deployed(as the tracker will reset to 0). 
    The solution to this, will be to migrate over the order state on the previous contract, then use the 
    "updateLedgerIdTracker" function to reset the counter.
    */
    uint256 s_ledgerIdTracker = 0;
    address s_platformCommisionWalletAddress;
    address internal s_merchantPayoutAddress;

    // The ERC20 token address that is used for order payment
    address internal s_ERC20TokenAddress;

    address internal s_adminManagementCoreContractAddress;
    address internal s_merchantManagementCoreContractAddress;

    IAdminManagement__Base internal s_adminManagementContract__Base =
        IAdminManagement__Base(s_adminManagementCoreContractAddress);

    IERC20 internal s_ERC20Contract = IERC20(s_ERC20TokenAddress);

    Order[] internal s_storeOrders;

    function getPlatformCommisionWalletAddress() public view returns (address) {
        return s_platformCommisionWalletAddress;
    }

    function setPlatformCommisionWalletAddress(address _address) public {
        if (!s_adminManagementContract__Base.checkIsAdmin(msg.sender)) {
            revert OrderManagement__AccessDenied_VerifiedAdminsOnly();
        }

        if (_address == address(0)) {
            revert OrderManagement__ZeroAddressError();
        }

        s_platformCommisionWalletAddress = _address;
    }

    function getERC20TokenAddress() public view returns (address) {
        return s_ERC20TokenAddress;
    }

    function getMerchantPayoutAddress() public view returns (address) {
        return s_merchantPayoutAddress;
    }

    function setMerchantPayoutAddress(address _address) public {
        if (!s_adminManagementContract__Base.checkIsAdmin(msg.sender)) {
            revert OrderManagement__AccessDenied_VerifiedAdminsOnly();
        }

        if (_address == address(0)) {
            revert OrderManagement__ZeroAddressError();
        }

        s_merchantPayoutAddress = _address;
    }

    // call directly on UI - via user wallet to get user approval
    function approveOrderPayment(
        uint256 _amount,
        address _orchestratorContractAddress
    ) public {
        require(
            IERC20(s_ERC20TokenAddress).approve(
                _orchestratorContractAddress,
                _amount
            ),
            "ERC20 approve failed"
        );
    }

    // call via orchestrator SC
    function processOrder__ERC20(
        address _createdBy,
        string memory _orderCID,
        uint256 _totalAmount
    ) public {
        s_ledgerIdTracker = s_ledgerIdTracker + 1;
        uint256 orderId = s_ledgerIdTracker;

        // Calculate platform commission (2%) and merchant payout (98%)
        uint256 platformCommission = (_totalAmount * 2) / 100;
        uint256 merchantPayout = _totalAmount - platformCommission;

        // update before payment to prevent re-entrancy
        Order memory newOrder = Order({
            orderId: orderId,
            createdBy: _createdBy,
            orderCID: _orderCID,
            totalAmount: _totalAmount,
            createdAt: block.timestamp
        });

        s_storeOrders.push(newOrder);

        // Transfer 2% to platform commission wallet
        require(
            s_ERC20Contract.transferFrom(
                _createdBy,
                s_platformCommisionWalletAddress,
                platformCommission
            ),
            "Commission transfer failed"
        );

        // Transfer 98% to merchant payout address
        require(
            s_ERC20Contract.transferFrom(
                _createdBy,
                s_merchantPayoutAddress,
                merchantPayout
            ),
            "Merchant payout transfer failed"
        );

        emit OrderProcessed(
            _createdBy,
            s_ERC20TokenAddress,
            _totalAmount,
            platformCommission,
            merchantPayout
        );
    }
}
