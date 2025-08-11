// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract LiquidityOperatorAuth {
    error LiquidityOperatorAuth__ApprovedLiquidityOperatorsOnly();

    address internal s_liquidityCoreContractAddress;

    modifier onlyLiquidityOperators() {
        if (msg.sender != s_liquidityCoreContractAddress) {
            revert LiquidityOperatorAuth__ApprovedLiquidityOperatorsOnly();
        }

        _;
    }
}
