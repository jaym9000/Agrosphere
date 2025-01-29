// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Agrosphere} from "../src/Agrosphere.sol";

contract AgroTest is Test {
    Agrosphere public agrosphere;

    function setUp() public {
        agrosphere = new Agrosphere(1000); // Assuming 1000 is the cap for demonstration
    }

    function test_Increment() public {
        agrosphere.mint(msg.sender, 100);
        assertEq(agrosphere.balanceOf(msg.sender), 100);
    }

    function testFuzz_SetNumber(uint256 x) public {
        agrosphere.mint(msg.sender, x);
        assertEq(agrosphere.balanceOf(msg.sender), x);
    }
}
