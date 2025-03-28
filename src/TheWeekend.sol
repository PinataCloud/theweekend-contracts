// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {ERC1155} from "../dependencies/@openzeppelin-contracts-5.3.0-rc.0/token/ERC1155/ERC1155.sol";
import {Ownable} from "../dependencies/@openzeppelin-contracts-5.3.0-rc.0/access/Ownable.sol";

/// @custom:security-contact steve@pinata.cloud
contract TheWeekend is ERC1155, Ownable {
    // DateTime constants from BokkyPooBah's library
    uint256 public constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 public constant SECONDS_PER_HOUR = 60 * 60;
    uint256 public constant SECONDS_PER_MINUTE = 60;

    // Day of week constants
    uint256 public constant DOW_MON = 1;
    uint256 public constant DOW_TUE = 2;
    uint256 public constant DOW_WED = 3;
    uint256 public constant DOW_THU = 4;
    uint256 public constant DOW_FRI = 5;
    uint256 public constant DOW_SAT = 6;
    uint256 public constant DOW_SUN = 7;

    constructor() ERC1155("ipfs://bafkreie6npd5qvtugmm54swvcg3zmvawvhe2hkwocwsrdipb7ouw2xwr74") Ownable(msg.sender) {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    // Custom modifier to only allow minting on weekends (Saturday or Sunday)
    modifier onlyOnWeekends() {
        require(isWeekEnd(block.timestamp), "Minting only allowed on weekends");
        _;
    }

    // Implementation of the isWeekEnd function from BokkyPooBah's library
    function isWeekEnd(uint256 timestamp) public pure returns (bool weekEnd) {
        uint256 dayOfWeek = getDayOfWeek(timestamp);
        return dayOfWeek == DOW_SAT || dayOfWeek == DOW_SUN || dayOfWeek == DOW_FRI;
    }

    // Implementation of the getDayOfWeek function from BokkyPooBah's library
    function getDayOfWeek(uint256 timestamp) public pure returns (uint256 dayOfWeek) {
        uint256 _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = ((_days + 3) % 7) + 1; // 1970/01/01 is Thursday (day 4)
    }

    // Modified mint function to only allow minting on weekends
    function mint() public onlyOnWeekends {
        _mint(msg.sender, 0, 1, new bytes(0));
    }
}
