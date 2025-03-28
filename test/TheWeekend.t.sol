// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test, console} from "forge-std/Test.sol";
import {TheWeekend} from "../src/TheWeekend.sol";
import {IERC1155Receiver} from "../dependencies/@openzeppelin-contracts-5.3.0-rc.0/token/ERC1155/IERC1155Receiver.sol";

contract TheWeekendTest is Test, IERC1155Receiver {
    TheWeekend public theWeekend;

    function setUp() public {
        theWeekend = new TheWeekend();
    }

    function test_IsWeekend() public view {
        // Test weekend detection for Saturday and Sunday

        // Saturday timestamp
        uint saturdayMorning = 1688803200; // Saturday 8am EST
        // Sunday timestamp
        uint sundayEvening = 1688938800; // Sunday 6pm EST

        // Test weekend days
        assertTrue(
            theWeekend.isWeekEnd(saturdayMorning),
            "Saturday should be weekend"
        );
        assertTrue(
            theWeekend.isWeekEnd(sundayEvening),
            "Sunday should be weekend"
        );

        // Test non-weekend days
        uint mondayMorning = 1689001200; // Monday 8am EST
        uint thursdayNoon = 1688652000; // Thursday 12pm EST
        uint fridayNoon = 1688738400; // Friday 12pm EST

        assertFalse(
            theWeekend.isWeekEnd(mondayMorning),
            "Monday should not be weekend"
        );
        assertFalse(
            theWeekend.isWeekEnd(thursdayNoon),
            "Thursday should not be weekend"
        );
        assertFalse(
            theWeekend.isWeekEnd(fridayNoon),
            "Friday should not be weekend"
        );
    }

    function testFuzz_DayOfWeek(uint256 timestamp) public view {
        uint256 day = theWeekend.getDayOfWeek(timestamp);
        assertTrue(day >= 1 && day <= 7);
    }

    function test_Mint_Weekday() public {
        // Set block timestamp to a weekday (Wednesday)
        vm.warp(1688566800); // Wednesday

        vm.expectRevert("Minting only allowed on weekends");
        theWeekend.mint();
    }

    function test_Mint_Weekend() public {
        // Set block timestamp to a weekend (Saturday)
        vm.warp(1688803200); // Saturday

        // Should mint successfully
        theWeekend.mint();

        // Check that the token was minted
        assertEq(theWeekend.balanceOf(address(this), 0), 1);
    }

    // IERC1155Receiver implementation
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) external pure override returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId;
    }
}
