-include .env

.PHONY: all clean remove install update build test snapshot format coverage anvil deploy help fund withdraw

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

all:; clean remove install update build

# Clean the repo
clean:; forge clean

# Remove Modules
remove:; :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules removed"

# Install Modules
install :; forge install cyfrin/foundry-devops --no-commit && forge install smartcontractkit/chainlink-brownie-contracts --no-commit && forge install foundry-rs/forge-std --no-commit

# Update Dependencies
update:; forge update

build:; forge build

test:; forge test

snapshot:; forge snapshot

format:; forge fmt

coverage:; forge coverage

# Setting up local anvil
anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

# Deploying
deploy:; @forge script script/DeployFundMe.s.sol:DeployFundMe $(NETWORK_ARGS)

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network eth-sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make fund ARGS\"--network eth-sepolia\""

# Default setup -- anvil 
NETWORK_ARGS := --rpc-url http://127.0.0.1:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

# Eth-Sepolia setup
ifeq ($(findstring --network eth-sepolia,$(ARGS)), --network eth-sepolia)
	NETWORK_ARGS := --rpc-url $(ETH_SEPOLIA_RPC_URL) --account $(ACCOUNT) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

# Eth-Mainnet setup
ifeq ($(findstring --network eth-mainnet,$(ARGS)), --network eth-mainnet)
	NETWORK_ARGS := --rpc-url $(ETH_MAINNET_RPC_URL) --account $(ACCOUNT) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

# For deploing Interactions.s.sol:
SENDER_ADDRESS := <sender's address>

fund:; @forge script script/Interactions.s.sol:FundFundMe --sender $(SENDER_ADDRESS) $(NETWORK_ARGS)

withdraw:; @forge script script/Interactions.s.sol:WithdrawFundMe --sender $(SENDER_ADDRESS) $(NETWORK_ARGS)
