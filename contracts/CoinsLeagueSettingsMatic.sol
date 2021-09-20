//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./interfaces/ICoinsLeagueSettings.sol";

// stores all settings of game
contract CoinsLeagueSettingsMatic is ICoinsLeagueSettings {
     mapping(address => bool) private _chainlink_feeds;
     mapping(uint256 => bool) private _allowed_amount_players;
     mapping(uint256 => bool) private _allowed_amount_coins;
     mapping(uint256 => bool) private _allowed_amounts;
     mapping(uint256 => bool) private _allowed_time_frames;

     constructor(){
             // AAVE / USD
        _chainlink_feeds[0x72484B12719E23115761D5DA1646945632979bB6] = true;
        // ALCX / USD
        _chainlink_feeds[0x5DB6e61B6159B20F068dc15A47dF2E5931b14f29] = true;
        // ALGO / USD
        _chainlink_feeds[0x03Bc6D9EFed65708D35fDaEfb25E87631a0a3437] = true;
        // AUD / USD
        _chainlink_feeds[0x062Df9C4efd2030e243ffCc398b652e8b8F95C6f] = true;
        // BAL / USD
        _chainlink_feeds[0xD106B538F2A868c28Ca1Ec7E298C3325E0251d66] = true;
        // BAT / USD
        _chainlink_feeds[0x2346Ce62bd732c62618944E51cbFa09D985d86D2] = true;
         // BCH / USD
        _chainlink_feeds[0x327d9822e9932996f55b39F557AEC838313da8b7] = true;
         // BNB / USD
        _chainlink_feeds[0x82a6c4AF830caa6c97bb504425f6A66165C2c26e] = true;
         // BNT / USD
        _chainlink_feeds[0xF5724884b6E99257cC003375e6b844bC776183f9] = true;
         // BOND / USD
        _chainlink_feeds[0x58527C2dCC755297bB81f9334b80b2B6032d8524] = true;
          // BSV / USD
        _chainlink_feeds[0x8803DD6705F0d38e79790B02A2C43594A0538D22] = true;
        // BTC / USD
        _chainlink_feeds[0xc907E116054Ad103354f2D350FD2514433D57F6f] = true;
         // BTG / USD
        _chainlink_feeds[0x2f2C605F28DE314bc579a7c0FDf85536529E9825] = true;
          // BZRX / USD
        _chainlink_feeds[0x6b7D436583e5fE0874B7310b74D29A13af816860] = true;
           // CEL / USD
        _chainlink_feeds[0xc9ECF45956f576681bDc01F79602A79bC2667B0c] = true;
          // COMP  / USD
        _chainlink_feeds[0x2A8758b7257102461BC958279054e372C2b1bDE6] = true;
          // CRV  / USD
        _chainlink_feeds[0x336584C8E6Dc19637A5b36206B1c79923111b405] = true;
         // DASH  / USD
        _chainlink_feeds[0xD94427eDee70E4991b4b8DdCc848f2B58ED01C0b] = true;
          // DOGE  / USD
        _chainlink_feeds[0xbaf9327b6564454F4a3364C33eFeEf032b4b4444] = true;
          // DOT  / USD
        _chainlink_feeds[0xacb51F1a83922632ca02B25a8164c10748001BdE] = true;
           // DPI  / USD
        _chainlink_feeds[0x2e48b7924FBe04d575BA229A59b64547d9da16e9] = true;
          // EOS  / USD
        _chainlink_feeds[0xd6285F06203D938ab713Fa6A315e7d23247DDE95] = true;
         // ETC  / USD
        _chainlink_feeds[0xDf3f72Be10d194b58B1BB56f2c4183e661cB2114] = true;
        // ETH  / USD
        _chainlink_feeds[0xF9680D99D6C9589e2a93a78A04A279e509205945] = true;
        // HT  / USD
        _chainlink_feeds[0x6F8F9e75C0285AecE30ADFe1BCc1955f145d971A] = true;
          // ICP  / USD
        _chainlink_feeds[0x84227A76a04289473057BEF706646199D7C58c34] = true;
          // KNC  / USD
        _chainlink_feeds[0x10e5f3DFc81B3e5Ef4e648C4454D04e79E1E41E2] = true;

         // Allowed Amounts
        _allowed_amounts[0.1 ether] = true;
        _allowed_amounts[1 ether]   = true;
        _allowed_amounts[3 ether]   = true;
        _allowed_amounts[5 ether]   = true;
        _allowed_amounts[25 ether]  = true;
        _allowed_amounts[50 ether]  = true;
        _allowed_amounts[250 ether] = true;
         // Allowed Players Amount
        _allowed_amount_players[2]  = true;
        _allowed_amount_players[5]  = true;
        _allowed_amount_players[10] = true;
        // Allowed Amount Coins
        _allowed_amount_coins[2]  = true;
        _allowed_amount_coins[5]  = true;
        _allowed_amount_coins[10] = true;
         // Allowed Time Frames
        _allowed_time_frames[60*60]  = true;
        _allowed_time_frames[60*60*4]  = true;
        _allowed_time_frames[60*60*8]  = true;
        _allowed_time_frames[60*60*24]  = true;
        _allowed_time_frames[60*60*24*7]  = true;
     }

    function isChainLinkFeed(address feed) external view override returns (bool) {
        require(feed != address(0), "No zero address feed");
        return _chainlink_feeds[feed];
    }

    function isAllowedAmountPlayers(uint256 num) external view override returns (bool){
         return _allowed_amount_players[num];
     }

     function isAllowedAmounts(uint256 amount) external view override returns (bool){
         return _allowed_amounts[amount];
     }

     function isAllowedAmountCoins(uint256 num) external view override returns (bool){
         return _allowed_amount_coins[num];
     }

    function isAllowedTimeFrame(uint256 time) external view override returns (bool){
         return _allowed_time_frames[time];
     }

    function getHouseAddress() external view override returns (address){
         return 0x5bD68B4d6f90Bcc9F3a9456791c0Db5A43df676d;
    }

      function getPrizesTwoPlayers() external view override  returns (uint256[2] memory prizes){
        return [uint256(80), uint256(20)];
     }

     function getPrizesPlayers() external view override  returns (uint256[3] memory){
        return [uint256(50), uint256(30), uint256(20)];
     }
     
     function getBITTMultiplier() external view override  returns (uint256){
         return 1;
     }
     function getChampionsMultiplier() external override  view returns (uint256){
         return 1;
     }



}