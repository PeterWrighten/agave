#!/bin/bash

# This script correctly simulates the behavior of the official solana-test-validator.
# It ensures all necessary binaries are built, creates a persistent ledger with all
# required keypairs (identity, vote, stake, faucet), generates a genesis block,
# and finally starts the validator with the correct parameters.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Setup ---
# Get the script's directory and navigate to the project root.
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
cd "$SCRIPT_DIR"

# Set environment for build on macOS
if [[ "$(uname)" == "Darwin" ]]; then
  if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Please install Homebrew to manage dependencies." >&2
    exit 1
  fi
  LLVM_PATH=$(brew --prefix llvm)
  if [ -d "$LLVM_PATH" ]; then
    export LLVM_CONFIG_PATH="$LLVM_PATH/bin/llvm-config"
    export DYLD_LIBRARY_PATH="$LLVM_PATH/lib"
  fi
fi

# --- Define paths ---
DEBUG_DIR="./target/debug"
AGAVE_VALIDATOR_EXE="$DEBUG_DIR/agave-validator"
KEYGEN_EXE="$DEBUG_DIR/solana-keygen"
GENESIS_EXE="$DEBUG_DIR/solana-genesis"

LEDGER_DIR="./test-ledger"
IDENTITY_KEYFILE="$LEDGER_DIR/identity-keypair.json"
VOTE_KEYFILE="$LEDGER_DIR/vote-account-keypair.json"
STAKE_KEYFILE="$LEDGER_DIR/stake-account-keypair.json"
FAUCET_KEYFILE="$LEDGER_DIR/faucet-keypair.json"
GENESIS_FILE="$LEDGER_DIR/genesis.bin"


# --- Build required binaries ---
echo "Ensuring validator, keygen, and genesis binaries are built..."
cargo build -p agave-validator -p solana-keygen -p solana-genesis

# --- Prepare ledger directory and all keypairs ---
mkdir -p "$LEDGER_DIR"

if [ ! -f "$IDENTITY_KEYFILE" ]; then
    echo "Identity keypair not found. Creating..."
    "$KEYGEN_EXE" new --no-bip39-passphrase -o "$IDENTITY_KEYFILE"
fi
if [ ! -f "$VOTE_KEYFILE" ]; then
    echo "Vote account keypair not found. Creating..."
    "$KEYGEN_EXE" new --no-bip39-passphrase -o "$VOTE_KEYFILE"
fi
if [ ! -f "$STAKE_KEYFILE" ]; then
    echo "Stake account keypair not found. Creating..."
    "$KEYGEN_EXE" new --no-bip39-passphrase -o "$STAKE_KEYFILE"
fi
if [ ! -f "$FAUCET_KEYFILE" ]; then
    echo "Faucet keypair not found. Creating..."
    "$KEYGEN_EXE" new --no-bip39-passphrase -o "$FAUCET_KEYFILE"
fi

# --- Generate Genesis Block ---
if [ ! -f "$GENESIS_FILE" ]; then
    echo "Genesis block not found. Creating a new one..."
    
    IDENTITY_PUBKEY=$("$KEYGEN_EXE" pubkey "$IDENTITY_KEYFILE")
    VOTE_PUBKEY=$("$KEYGEN_EXE" pubkey "$VOTE_KEYFILE")
    STAKE_PUBKEY=$("$KEYGEN_EXE" pubkey "$STAKE_KEYFILE")
    FAUCET_PUBKEY=$("$KEYGEN_EXE" pubkey "$FAUCET_KEYFILE")

    "$GENESIS_EXE" \
        --ledger "$LEDGER_DIR" \
        --faucet-lamports 500000000000000000 \
        --faucet-pubkey "$FAUCET_PUBKEY" \
        --bootstrap-validator "$IDENTITY_PUBKEY" "$VOTE_PUBKEY" "$STAKE_PUBKEY"
fi

# --- Run the validator ---
echo "Starting the Agave validator..."
echo "Identity Pubkey: $("$KEYGEN_EXE" pubkey "$IDENTITY_KEYFILE")"
echo "Ledger Path: $LEDGER_DIR"
echo "Press Ctrl+C to stop the validator."
echo "----------------------------------------------------"

# Execute the actual validator binary with all required arguments.
"$AGAVE_VALIDATOR_EXE" \
    --identity "$IDENTITY_KEYFILE" \
    --vote-account "$VOTE_KEYFILE" \
    --ledger "$LEDGER_DIR" \
    --rpc-faucet-address 127.0.0.1:9900 \
    "$@" 