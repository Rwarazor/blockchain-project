source .env

if [[ "$#" == 5 ]]; then
    GAME_ADDRESS=$1 MOVENO=1 \
    MOVE1=$(($2 + $3 * 256)) MOVE2=$(($4 + $5 * 256)) \
    MOVE3=0 MOVE4=0 \
    forge script script/Game.s.sol:MakeMoveScript --rpc-url $FORK_URL --evm-version shanghai --broadcast
fi
if [[ "$#" == 9 ]]; then
    GAME_ADDRESS=$1 MOVENO=2 \
    MOVE1=$(($2 + $3 * 256)) MOVE2=$(($4 + $5 * 256)) \
    MOVE3=$(($6 + $7 * 256)) MOVE4=$(($8 + $9 * 256)) \
    forge script script/Game.s.sol:MakeMoveScript --rpc-url $FORK_URL --evm-version shanghai --broadcast
fi
if [[ "$#" != 5 && "$#" != 9 ]]; then
    echo "Usage ./scripts/getState.sh <game address> <move1from> <move1to> <move2from> <move2to> [<move3from> <move3to> <move4from> <move4to>]"
    exit
fi


