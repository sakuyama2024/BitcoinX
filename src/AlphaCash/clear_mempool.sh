#!/bin/bash

# Stop the bitcoind daemon
echo "Stopping bitcoind..."
bitcoin-cli -regtest stop

# Wait for bitcoind to stop
sleep 5

# Delete the mempool.dat file
echo "Clearing the mempool..."
rm -f "$HOME/Library/Application Support/Bitcoin/regtest/mempool.dat" 

# Restart the bitcoind daemon
echo "Restarting bitcoind..."
bitcoind -regtest -daemon

echo "Mempool cleared and bitcoind restarted."



