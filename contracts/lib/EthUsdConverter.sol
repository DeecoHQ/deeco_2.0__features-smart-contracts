// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// interface AggregatorV3Interface {
//     function latestRoundData() external view
//     returns (
//         uint80 roundId,
//         int256 answer,
//         uint256 startedAt,
//         uint256 updatedAt,
//         uint80 answeredInRound
//     );
// }

/// @title ETH/USD Price Conversion Library using Chainlink Oracle
/// @notice Provides utility functions to fetch ETH price and convert between ETH and USD
/// @dev Uses Chainlink's AggregatorV3Interface for fetching live ETH/USD price data
library EthUsdConverter {
    /// @notice Retrieves the current ETH price in USD from the Chainlink price feed
    /// @dev Returns price scaled to 18 decimal places (from Chainlink's 8 decimals)
    /// @return The latest ETH price in USD with 18 decimals
    function getEthPrice() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (, int price,,,) = priceFeed.latestRoundData();

        return uint256(price * 1e10);
    }

    /// @notice Converts a USD amount (18 decimal format) to the equivalent ETH amount
    /// @dev Input USD amount must be in 18 decimal format (e.g. 3466.67 = 3466670000000000000000)
    /// @param _usdAmount The USD amount to convert, in 18 decimal standard format
    /// @return standardUnitAmount The equivalent ETH value in 18 decimal format
    /// @return readAbleAmount The equivalent ETH value as a whole number (no decimals)
    function usdToEth(uint256 _usdAmount) public view returns(uint256, uint256) {
        uint256 ethPrice = getEthPrice();

        uint256 standardUnitAmount = (_usdAmount * 1e18) / ethPrice;
        uint256 readAbleAmount = standardUnitAmount / 1e18;

        return (standardUnitAmount, readAbleAmount);
    }

    /// @notice Converts an ETH amount (18 decimal format) to the equivalent USD amount
    /// @dev Input ETH amount must be in 18 decimal format (e.g. 2.5 ETH = 2500000000000000000)
    /// @param _ethAmount The ETH amount to convert, in 18 decimal standard format
    /// @return standardUnitPrice The equivalent USD value in 18 decimal format
    /// @return readablePrice The equivalent USD value as a whole number (no decimals)
    function ethToUSD(uint256 _ethAmount) public view returns(uint256, uint256) {
        uint256 ethPrice = getEthPrice();

        uint256 standardUnitPrice = (_ethAmount * ethPrice) / 1e18;
        uint256 readablePrice = standardUnitPrice / 1e18;

        return (standardUnitPrice, readablePrice);
    }
}
