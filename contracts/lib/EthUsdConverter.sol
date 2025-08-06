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

library EthUsdConverter {
    function getEthPrice() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (,int price,,,) = priceFeed.latestRoundData();

        return uint256(price * 1e10);
    }

    /* USD amount input parameter must always be sent in the standard 18 decimal position format */
    function usdToEth(uint256 _usdAmount) public view returns(uint256, uint256){
        // uint256 ethPrice = 3502776878180000000000; // subject to change - for local remix testing
        uint256 ethPrice = getEthPrice();

        /* using the commented code below, requires an input in normal(readable) integer format
        e.g. 3500. But the response value would likely not be an accurate whole. Hence it is 
        recommended to send an input that always has 18 decimal positions as required in solidity.
        e.g. for 3466.67 - you strip all decimals and/or commas, and input - 3466670000000000000000 - add 16 zeros */
        // uint256 standardUnitAmount =  (_usdAmount * 1e18 * 1e18) / ethPrice;
                
        uint256 standardUnitAmount =  (_usdAmount * 1e18) / ethPrice;
        uint256 readAbleAmount = standardUnitAmount / 1e18;

        return (standardUnitAmount, readAbleAmount);
    }

    /* eth input parameter must always be sent in the standard 18 decimal position format */
    function ethToUSD(uint256 _ethAmount) public view returns(uint256, uint256){
        // uint256 ethPrice = 3502776878180000000000; // subject to change - for local remix testing
        uint256 ethPrice = getEthPrice();

        uint256 standardUnitPrice = (_ethAmount * ethPrice) / 1e18;
        uint256 readablePrice = standardUnitPrice / 1e18;

        return (standardUnitPrice, readablePrice);
    }
}
