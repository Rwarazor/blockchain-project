RANDOM1="0x$(xxd -p -l 16 /dev/urandom)"
source .env
RANDOM1=$RANDOM1 forge script script/Game.s.sol:CreateGameScript --rpc-url $FORK_URL --evm-version shanghai --broadcast
echo "Use this random number as an argument to next command:"
echo $RANDOM1
echo "Find transaction on https://sepolia.etherscan.io/ :)"