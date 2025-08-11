// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "../lib/PlatformEvents.sol";
import "../domains/product/ProductManagement.sol";

contract Core__Liquidity is PlatformEvents, ProductManagement {
    string private contractName;

    constructor() {
        string memory CONTRACT_NAME = "Core__Liquidity"; // set in one place to avoid mispelling elsewhere

        // i_owner(variable) - from ProductManagementAuth.sol
        i_owner = msg.sender;

        contractName = CONTRACT_NAME;

        emit Logs(
            "contract deployed successfully with constructor chores completed",
            block.timestamp,
            CONTRACT_NAME
        );
    }

    function getContractName() public view returns (string memory) {
        return contractName;
    }

    function getContractOwner() public view returns (address) {
        return i_owner;
    }

    // to be called as a verification - from external contracts - before they process other function calls
    function ping() external view returns (string memory, address, uint256) {
        return (contractName, address(this), block.timestamp);
    }
}
