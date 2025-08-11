// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title MerchantAuth
 * @notice Provides an access control mechanism that restricts certain functions to addresses designated as merchants.
 * @dev Implements a `merchantsOnly` modifier that checks whether the caller is a registered merchant using
 *      the `s_isMerchant` mapping.
 * 
 *      Usage:
 *      - Apply the `merchantsOnly` modifier to functions that should be accessible exclusively by merchant addresses.
 *      - The mapping `s_isMerchant` must be managed (e.g., adding/removing merchant addresses) by an authorized process.
 * 
 *      Example:
 *      ```
 *      contract MyStore is MerchantAuth {
 *          function addProduct(string calldata productId) external merchantsOnly {
 *              // Only merchants can add products
 *          }
 *      }
 *      ```
 * 
 *      Security Considerations:
 *      - Initialization of merchant addresses must be controlled to prevent unauthorized access.
 *      - Functions that change merchant status should themselves be access-restricted.
 *      - The contract does not implement merchant registration logic; inheriting contracts must handle it.
 */
contract MerchantAuth {

    /**
     * @notice Error indicating that the caller is not a registered merchant.
     * @dev Reverts with this error when a function protected by `merchantsOnly` is called by a non-merchant address.
     */
    error MerchantAuth__MerchantsOnly();

    /**
     * @notice Tracks whether an address is recognized as a merchant.
     * @dev Mapping from an Ethereum address to a boolean value:
     *      - `true`: Address is a merchant.
     *      - `false`: Address is not a merchant.
     * 
     *      Marked as `internal`, allowing access within this contract and any inheriting contracts.
     */
    mapping(address => bool) internal s_isMerchant;
    
    /**
     * @notice Restricts function execution to merchant addresses only.
     * @dev Checks if `msg.sender` is marked as a merchant in the `s_isMerchant` mapping.
     *      If not, the function reverts with `MerchantAuth__MerchantsOnly`.
     * 
     *      Functions using this modifier will execute `_` (the function body) only if the caller passes the merchant check.
     * 
     * @custom:example
     * function uploadInventory() external merchantsOnly {
     *     // logic that only merchants can perform
     * }
     */
    modifier merchantsOnly() {
        if (
            !s_isMerchant[msg.sender]
        ) {
            revert MerchantAuth__MerchantsOnly();
        }

        _;
    }
}
