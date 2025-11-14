#!/bin/bash

source .env
echo "Running deploy script"
forge script script/Deploy.s.sol:Deploy --ffi --verifier-url "https://api.etherscan.io/v2/api?chainid=11155111" --rpc-url $SEPOLIA_RPC_URL --etherscan-api-key ${ETHERSCAN_API_KEY} --slow --broadcast --verify -vvvv