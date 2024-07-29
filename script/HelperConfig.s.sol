// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

/**
 * @title HelperConfig
 * @notice This script does the folowing:
 * 1. Deploy mocks when we are on a local chain.
 * 2. Keep track of contract address across different chains.
 */
contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 3000e8;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getEthSepoliaConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getEthMainnetConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    function getEthSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethSepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return ethSepoliaConfig;
    }

    function getEthMainnetConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethMainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethMainnetConfig;
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        // 1. Deploy the mocks
        // 2. Return the mock address

        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
