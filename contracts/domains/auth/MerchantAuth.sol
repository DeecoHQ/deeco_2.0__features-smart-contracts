// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract MerchantAuth {

    error MerchantAuth__MerchantsOnly();

    mapping(address => bool) internal s_isMerchant;
    
    modifier merchantsOnly() {
        if (
            !s_isMerchant[msg.sender]
        ) {
            revert MerchantAuth__MerchantsOnly();
        }

        _;
    }
}
