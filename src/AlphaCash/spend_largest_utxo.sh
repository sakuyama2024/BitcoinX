#!/bin/bash

# Set variables
WALLET=$1
RECIPIENT_ADDRESS="$2"
AMOUNT="$3"
FEE=0.00001
BITCOIN_CLI="bitcoin-cli -regtest -rpcwallet=$WALLET"

# Check if recipient address and amount are provided
if [ -z "$RECIPIENT_ADDRESS" ] || [ -z "$AMOUNT" ]; then
  echo "Usage: $0 <wallet> <recipient_address> <amount>"
  exit 1
fi

# List unspent outputs
UTXOS=$($BITCOIN_CLI listunspent 0 9999999 '[]')

# Find the largest UTXO
LARGEST_UTXO=$(echo $UTXOS | jq -c 'sort_by(.amount) | reverse | .[0]')
TXID=$(echo $LARGEST_UTXO | jq -r '.txid')
VOUT=$(echo $LARGEST_UTXO | jq -r '.vout')
AMOUNT_AVAILABLE=$(echo $LARGEST_UTXO | jq -r '.amount')

#echo "Largest UTXO: $LARGEST_UTXO"
echo "Amount Available" $AMOUNT_AVAILABLE


# Check if a suitable UTXO was found
if [ -z "$TXID" ] || [ "$TXID" == "null" ]; then
  echo "No suitable UTXO found"
  exit 1
fi



# Check if the UTXO amount is sufficient
TOTAL_AMOUNT_REQUIRED=$(echo "$AMOUNT + $FEE" | bc)
if (( $(echo "$AMOUNT_AVAILABLE < $TOTAL_AMOUNT_REQUIRED" | bc -l) )); then
  echo "UTXO amount is less than the transaction amount plus fees. Ending."
  exit 1
fi


# Calculate change (if any)
CHANGE=$(echo "$AMOUNT_AVAILABLE - $AMOUNT - $FEE" | bc)
echo "Calculated change: $CHANGE"


echo "Creating raw transaction..."
if (( $(echo "$CHANGE > 0" | bc -l) )); then
  CHANGE_ADDRESS=$($BITCOIN_CLI getnewaddress)
  RAWTX=$($BITCOIN_CLI createrawtransaction \
    "[{\"txid\":\"$TXID\",\"vout\":$VOUT}]" \
    "{\"$RECIPIENT_ADDRESS\":$AMOUNT, \"$CHANGE_ADDRESS\":$CHANGE}")
  echo "Change address: $CHANGE_ADDRESS"
else
  RAWTX=$($BITCOIN_CLI createrawtransaction \
    "[{\"txid\":\"$TXID\",\"vout\":$VOUT}]" \
    "{\"$RECIPIENT_ADDRESS\":$AMOUNT}")
fi
echo "Raw transaction: $RAWTX"

echo "Signing the transaction..."
SIGNEDTX=$($BITCOIN_CLI signrawtransactionwithwallet $RAWTX | jq -r '.hex')
echo "Signed transaction: $SIGNEDTX"

# Send the transaction
echo "Sending the transaction..."
TXID=$($BITCOIN_CLI sendrawtransaction $SIGNEDTX)
echo "Transaction ID: $TXID"

# Output the transaction ID
echo "Transaction successfully sent!"
echo "Transaction ID: $TXID"



