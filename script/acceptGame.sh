if [[ "$#" -ne 1 ]]; then
    echo "Usage ./scripts/getState.sh GAME_ADDRESS"
    exit
fi

RANDOM1="0x$(xxd -p -l 16 /dev/urandom)"

source .env
GAME_ADDRESS=$1 RANDOM1=$RANDOM1 forge script script/Game.s.sol:AcceptGameScript --rpc-url $FORK_URL --evm-version shanghai --broadcast

echo "Use this random number as an argument to next command:"
echo $RANDOM1
