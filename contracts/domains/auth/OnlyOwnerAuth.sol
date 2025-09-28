// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract OnlyOwnerAuth {
    
    error OnlyOwner__AccessDenied_OwnerOnly();

    address internal immutable i_owner;

    modifier onlyOwner() { 
        if(msg.sender != i_owner) {
            revert OnlyOwner__AccessDenied_OwnerOnly();
        }

        _;
    }
}
