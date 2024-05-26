#!/bin/bash

# Set variables
WALLET=$1
BITCOIN_CLI="bitcoin-cli -regtest -rpcwallet=$WALLET"

# Check if wallet name is provided
if [ -z "$WALLET" ]; then
  echo "Usage: $0 <wallet_name>"
  exit 1
fi

# List unspent outputs
echo "Listing unspent outputs for wallet $WALLET..."
UTXOS=$($BITCOIN_CLI listunspent 0 9999999)

# Process and print each UTXO's address and amount
echo "Address Amount"
echo "$UTXOS" | jq -r '.[] | "\(.address) \(.amount)"'



