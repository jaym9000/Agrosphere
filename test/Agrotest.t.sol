// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Test} from "forge-std/Test.sol";
import {Agrosphere} from "../src/Agrosphere.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

contract AgroTest is Test {
    Agrosphere public agrosphere;
    address public admin;
    address public minter;
    address public pauser;
    address public user;
    uint256 public constant CAP = 1000 ether; // Using ether suffix for token decimals

    function setUp() public {
        admin = address(this);
        minter = makeAddr("minter");
        pauser = makeAddr("pauser");
        user = makeAddr("user");

        agrosphere = new Agrosphere(CAP);

        agrosphere.grantRole(agrosphere.MINTER_ROLE(), minter);
        agrosphere.grantRole(agrosphere.PAUSER_ROLE(), pauser);
    }

    // Test role assignments
    function test_RolesInitialization() public view {
        assertTrue(agrosphere.hasRole(agrosphere.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(agrosphere.hasRole(agrosphere.MINTER_ROLE(), minter));
        assertTrue(agrosphere.hasRole(agrosphere.PAUSER_ROLE(), pauser));
    }

    // Minting tests
    function test_Mint_Success() public {
        vm.prank(minter);
        agrosphere.mint(user, 100 ether);
        assertEq(agrosphere.balanceOf(user), 100 ether);
    }

    function test_Mint_RevertIfNotMinter() public {
        vm.prank(user);
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                user,
                agrosphere.MINTER_ROLE()
            )
        );
        agrosphere.mint(user, 100 ether);
    }

    function test_Mint_RevertIfExceedsCap() public {
        vm.prank(minter);
        agrosphere.mint(user, CAP);

        vm.prank(minter);
        vm.expectRevert("ERC20Capped: cap exceeded");
        agrosphere.mint(user, 1 wei);
    }

    // Pause functionality
    function test_Pause_Success() public {
        vm.prank(pauser);
        agrosphere.pause();

        vm.prank(minter);
        vm.expectRevert("EnforcedPause");
        agrosphere.mint(user, 100 ether);
    }

    function test_Unpause_Success() public {
        vm.prank(pauser);
        agrosphere.pause();

        vm.prank(pauser);
        agrosphere.unpause();

        vm.prank(minter);
        agrosphere.mint(user, 100 ether);
        assertEq(agrosphere.balanceOf(user), 100 ether);
    }

    // Burning tests
    function test_Burn_Success() public {
        vm.prank(minter);
        agrosphere.mint(user, 100 ether);

        vm.prank(user);
        agrosphere.burn(50 ether);
        assertEq(agrosphere.balanceOf(user), 50 ether);
    }

    function test_Burn_RevertIfInsufficientBalance() public {
        vm.prank(minter);
        agrosphere.mint(user, 50 ether);

        vm.prank(user);
        vm.expectRevert("ERC20: burn amount exceeds balance");
        agrosphere.burn(100 ether);
    }

    // Fuzz tests
    function testFuzz_MintWithinCap(uint256 amount) public {
        amount = bound(amount, 1 wei, CAP);
        vm.prank(minter);
        agrosphere.mint(user, amount);
        assertEq(agrosphere.balanceOf(user), amount);
    }

    function testFuzz_TransferAfterPause(uint256 amount) public {
        amount = bound(amount, 1 wei, CAP);

        vm.prank(minter);
        agrosphere.mint(user, amount);

        vm.prank(pauser);
        agrosphere.pause();

        vm.prank(user);
        vm.expectRevert("EnforcedPause");
        agrosphere.transfer(address(0x1), amount);
    }
}
