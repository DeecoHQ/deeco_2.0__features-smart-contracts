// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library EthUsdConverter {

    function getEthPrice() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (, int price,,,) = priceFeed.latestRoundData();

        return uint256(price * 1e10);
    }

    function usdToEth(uint256 _usdAmount) public view returns(uint256, uint256) {
        uint256 ethPrice = getEthPrice();

        uint256 standardUnitAmount = (_usdAmount * 1e18) / ethPrice;
        uint256 readAbleAmount = standardUnitAmount / 1e18;

        return (standardUnitAmount, readAbleAmount);
    }

    function ethToUSD(uint256 _ethAmount) public view returns(uint256, uint256) {
        uint256 ethPrice = getEthPrice();

        uint256 standardUnitPrice = (_ethAmount * ethPrice) / 1e18;
        uint256 readablePrice = standardUnitPrice / 1e18;

        return (standardUnitPrice, readablePrice);
    }
}
