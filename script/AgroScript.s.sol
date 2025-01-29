// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Script, console} from "forge-std/Script.sol";
import {Agrosphere} from "../src/Agrosphere.sol";

contract AgroScript is Script {
    Agrosphere public agrosphere;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        agrosphere = new Agrosphere(1000); // Assuming 1000 is the cap for demonstration

        vm.stopBroadcast();
    }
}
