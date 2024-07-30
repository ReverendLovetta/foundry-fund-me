// SPDX-License-Identifier: MIT
// 1. Pragma
pragma solidity ^0.8.19;

// 2. Imports
import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 3. Interfaces, Libraries, Contracts
error FundMe__NotOwner();

/**
 * @title FundMe, a contract for crowd funding
 * @notice This contract is to demo a sample funding contract
 * @notice Taking only ETH as a fund.
 * Everyone can fund to this contract. The minimum funding is
 * 5 USD. All funds will go for maintaining development process for
 * <poject_name> project.
 * @dev This implements price feeds as our library
 */
contract FundMe {
    // Type Declarations
    using PriceConverter for uint256;

    // State variables
    uint256 public constant MINIMUM_USD = 5e18;
    address[] private s_funders;
    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded;
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    // Events (we have none!)

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    /// @notice Funds our contract based on the ETH/USD price
    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) > MINIMUM_USD, "Didn't send enough ETH");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    /**
     * @notice Function sending all ETH to owner,
     * resetting the map (address => amountFunded), and
     * resetting the array of s_funders
     */
    function withdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Withdraw failed");
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * Getter Functions
     */

    /**
     * @notice Gets the amount that address has funded
     * @param fundingAddress the address of the funder
     * @return the amount funded
     */
    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getVersion() external view returns (uint256) {
        return s_priceFeed.version();
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getPriceFeed() external view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
