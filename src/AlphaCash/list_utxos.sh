#!/bin/bash

# Set variables
WALLET=$1
FEE=0.00001
BITCOIN_CLI="bitcoin-cli -regtest -rpcwallet=$WALLET"


# List unspent outputs
UTXOS=$($BITCOIN_CLI listunspent 0 9999999 '[]')
SORTED_AMOUNTS=$(echo $UTXOS | jq -r 'sort_by(.amount) | reverse | .[].amount' | paste -sd " " -)


echo "UTXOs from highest to lowest: $SORTED_AMOUNTS"




