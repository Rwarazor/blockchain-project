if [[ "$#" -ne 1 ]]; then
    echo "Usage ./scripts/getState.sh GAME_ADDRESS"
    exit
fi

source .env
GAME_ADDRESS=$1 forge script script/Game.s.sol:GetStateScript --rpc-url $FORK_URL --evm-version shanghai

