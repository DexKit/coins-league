//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * In progress
 */
contract SquidGameMumbai is Ownable {
    enum GameType {
        Winner,
        Loser
    }
    uint256 currentRound;
    uint256 startTimestamp;
    uint256 endTimestamp;
    enum ChallengeState {
        Joining,
        Setup,
        Started,
        Finished,
        Quit
    }
    ChallengeState gameState;
    bool[6] challengeResult;
    address houseAddress = address(0);
    event PlayerJoinedRound(
        uint256 round,
        address player,
        uint256 created_at,
        bool play
    );
    event PlayerJoined(address player, uint256 created_at);
    event ChallengeSetup(
        uint256 round,
        address feed,
        uint256 created_at,
        uint256 game_type
    );
    event ChallengeStarted(
        uint256 round,
        int256 start_price,
        uint256 created_at
    );
    event ChallengeFinished(
        uint256 round,
        int256 end_price,
        uint256 created_at,
        bool result
    );

    event VoteToQuit(uint256 round, address player, uint256 created_at);

    event GameQuitted(
        uint256 round,
        uint256 amount_voted,
        uint256 amount_total,
        uint256 created_at
    );

    event Withdrawed(uint256 amount, address player, uint256 created_at);

    event WithdrawedHouse(uint256 amount, uint256 created_at);
    struct Coin {
        address feed;
        int256 start_price;
        uint256 start_timestamp;
        uint256 duration;
        int256 end_price;
        int256 score;
        uint256 game_type;
    }
    mapping(uint256 => Coin) public CoinRound;

    bool _houseWithdrawed = false;

    Coin public coin;

    mapping(uint256 => mapping(address => bool)) public PlayersPlay;
    address[] public PlayersJoined;
    mapping(uint256 => address[]) public PlayersRound;
    mapping(uint256 => address[]) public PlayersVote;
    mapping(uint256 => mapping(address => bool)) public PlayersVoteMap;
    mapping(uint256 => mapping(address => bool)) public PlayersRoundMap;
    mapping(address => bool) public PlayersJoinedMap;
    uint256 public pot = 1 ether;
    uint256 lastChallengeTimestamp;

    constructor(uint256 _startTimestamp, uint256 _pot) {
        currentRound = 0;
        startTimestamp = _startTimestamp;
        pot = _pot;
        gameState = ChallengeState.Joining;
    }

    function joinGame() external payable {
        require(msg.value == pot, "Need to sent exact amount of pot");
        require(PlayersJoinedMap[msg.sender] == false, "Already joined");
        PlayersJoinedMap[msg.sender] = true;
        PlayersJoined.push(msg.sender);
        emit PlayerJoined(msg.sender, block.timestamp);
    }

    /**
     *  Go to Next Challenge
     */
    function playChallenge(bool play) external {
        require(
            PlayersJoinedMap[msg.sender] == true,
            "you need join game to be able to go next challenges"
        );
        if (currentRound > 0) {
            require(
                PlayersRoundMap[currentRound - 1][msg.sender] == true,
                "you need to been on previous round"
            );
            require(
                PlayersPlay[currentRound - 1][msg.sender] ==
                    challengeResult[currentRound - 1],
                "you not passed challenge"
            );
        }
        require(
            gameState == ChallengeState.Setup,
            "Challenge needs to be setup phase"
        );
        require(currentRound + 1 < 7, "There is only 6 rounds");
        PlayersRound[currentRound].push(msg.sender);
        PlayersRoundMap[currentRound][msg.sender] = true;
        PlayersPlay[currentRound][msg.sender] = play;
        emit PlayerJoinedRound(0, msg.sender, block.timestamp, play);
    }

    // We setup first the challenge to start in few hours
    function setupChallenge() external {
        require(block.timestamp > startTimestamp, "Tournament not started");
        require(
            block.timestamp > lastChallengeTimestamp + 24 * 3600,
            "Challenge needs at least to pass 24 hours to go next round"
        );
        require(gameState != ChallengeState.Started, "challenge started");
        require(
            gameState != ChallengeState.Setup,
            "challenge was already setup"
        );
        uint256 gameType = _random(0) % 1;
        uint256 feed = _random(1) % 4;
        CoinRound[currentRound] = Coin(
            getFeeds()[feed],
            0,
            0,
            0,
            0,
            0,
            gameType
        );
        CoinRound[currentRound].start_timestamp = block.timestamp + 3600;
        //we do rounds of one hour
        CoinRound[currentRound].duration = 3600;
        gameState = ChallengeState.Setup;
        emit ChallengeSetup(
            currentRound,
            getFeeds()[feed],
            block.timestamp,
            gameType
        );
    }

    // The challenge starts
    function startChallenge() external {
        require(
            block.timestamp > CoinRound[currentRound].start_timestamp,
            "Challenge not started"
        );
        require(gameState != ChallengeState.Started, "Already started");
        require(gameState != ChallengeState.Quit, "Game was finished");
        CoinRound[currentRound].start_price = getPriceFeed(
            CoinRound[currentRound].feed
        );
        gameState = ChallengeState.Started;
        emit ChallengeStarted(
            currentRound,
            CoinRound[currentRound].start_price,
            block.timestamp
        );
    }

    function finishChallenge() external {
        require(
            block.timestamp >
                CoinRound[currentRound].start_timestamp +
                    CoinRound[currentRound].duration,
            "Duration not elapsed yet"
        );
        require(gameState != ChallengeState.Finished, "Game already finished");
        CoinRound[currentRound].end_price = getPriceFeed(
            CoinRound[currentRound].feed
        );
        CoinRound[currentRound].score = (((CoinRound[currentRound].end_price -
            CoinRound[currentRound].start_price) * 100000) /
            CoinRound[currentRound].end_price);
        // If it is bull score needs to be positive
        if (CoinRound[currentRound].game_type == 0) {
            if (CoinRound[currentRound].score > 0) {
                challengeResult[currentRound] = true;
            } else {
                challengeResult[currentRound] = false;
            }
        }
        // If it is bear score needs to be negative
        if (CoinRound[currentRound].game_type == 1) {
            if (CoinRound[currentRound].score > 0) {
                challengeResult[currentRound] = false;
            } else {
                challengeResult[currentRound] = true;
            }
        }
        currentRound = currentRound + 1;
        lastChallengeTimestamp = block.timestamp;
        gameState = ChallengeState.Finished;
        emit ChallengeFinished(
            currentRound - 1,
            CoinRound[currentRound - 1].end_price,
            block.timestamp,
            challengeResult[currentRound - 1]
        );
    }

    function voteEndGame() external {
        require(
            PlayersVoteMap[currentRound][msg.sender] == false,
            "You already voted on this round"
        );
        require(
            gameState == ChallengeState.Finished,
            "Challenge needs to be finished to vote"
        );
        PlayersVote[currentRound].push(msg.sender);
        PlayersVoteMap[currentRound][msg.sender] = true;
        emit VoteToQuit(currentRound, msg.sender, block.timestamp);
    }

    // If majority of players voted to quit the game, game just quit
    function computeEndGame() external {
        require(
            gameState == ChallengeState.Setup,
            "Only on Setup State we can end the challenge"
        );
        if (
            2 * PlayersVote[currentRound].length >
            PlayersRound[currentRound].length
        ) {
            gameState = ChallengeState.Quit;
            emit GameQuitted(
                currentRound,
                PlayersVote[currentRound].length,
                PlayersRound[currentRound].length,
                block.timestamp
            );
        }
    }

    /**
     * Total pot depends on joined players
     */
    function getTotalPot() public view returns (uint256) {
        if (currentRound > 0) {
            return (PlayersJoined.length) * pot;
        } else {
            return 0;
        }
    }

    function getCurrentPlayers() external view returns (uint256) {
        return PlayersRound[currentRound].length;
    }

    function getJoinedPlayers() external view returns (uint256) {
        return PlayersJoined.length;
    }

    function getCurrentRound() external view returns (uint256) {
        return currentRound;
    }

    function getPlayerCurrentChallengeResultAtRound(
        address player,
        uint256 round
    ) external view returns (bool) {
        require(round <= currentRound, "round is higher than current round");
        return PlayersPlay[round][player] == challengeResult[round];
    }

    function withdraw() external {
        require(
            currentRound == 6 || gameState == ChallengeState.Quit,
            "Game not finished yet"
        );
        uint256 totalPotMinusHouse = getTotalPot() - (getTotalPot() * 10) / 100;
        uint256 currentPlayers = PlayersRound[currentRound].length;
        uint256 amountToSend = totalPotMinusHouse / currentPlayers;

        (bool sent, ) = msg.sender.call{value: amountToSend}("");
        require(sent, "Failed to send Ether");
        emit Withdrawed(amountToSend, msg.sender, block.timestamp);
    }

    function withdrawHouse() external {
        require(
            currentRound == 6 || gameState == ChallengeState.Quit,
            "Game not finished yet"
        );
        require(_houseWithdrawed == false, "House already withdrawed");
        _houseWithdrawed = true;
        uint256 totalPotHouse = (getTotalPot() * 10) / 100;
        // If all the players were eliminated, house takes all;
        if (PlayersRound[currentRound].length == 0) {
            totalPotHouse = getTotalPot();
        }

        (bool sent, ) = houseAddress.call{value: totalPotHouse}("");
        require(sent, "Failed to send Ether");
        emit WithdrawedHouse(totalPotHouse, block.timestamp);
    }

    function getCurrentPlayersAtRound(uint256 round)
        external
        view
        returns (uint256)
    {
        require(
            round < currentRound,
            "round can not be higher than current one"
        );
        return PlayersRound[round].length;
    }

    function getPriceFeed(address coin_feed) public view returns (int256) {
        (, int256 price, , , ) = AggregatorV3Interface(coin_feed)
            .latestRoundData();
        return price;
    }

    // We generate a pseudo random number, just for fun
    function _random(uint256 tokenId) private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.difficulty, block.timestamp, tokenId)
                )
            );
    }

    /**
     * returns feed associated with coin
     */
    function getFeeds() internal pure returns (address[3] memory) {
        return [
            // BTC
            0x007A22900a3B98143368Bd5906f8E17e9867581b,
            // ETH
            0x007A22900a3B98143368Bd5906f8E17e9867581b,
            // MATIC
            0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada
        ];
    }
}
