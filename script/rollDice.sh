if [[ "$#" -ne 2 ]]; then
    echo "Usage ./scripts/rollDice.sh GAME_ADDRESS RANDOM1"
    exit
fi
RANDOM2="0x$(xxd -p -l 16 /dev/urandom)"
source .env
GAME_ADDRESS=$1 RANDOM1=$2 RANDOM2=$RANDOM2 forge script script/Game.s.sol:RollDiceScript --rpc-url $FORK_URL --evm-version shanghai --broadcast
echo "Use this random number as an argument to next command:"
echo $RANDOM2
