// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.23;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {ERC20Capped} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/// @title Agrosphere ERC20 Token
/// @notice ERC20 implementation with burnable, pausable, capped, permit functionality and role-based access control
/// @dev Inherits multiple OpenZeppelin ERC20 extensions and uses AccessControl for role management
/// @custom:security-contact jean_marcc@hotmail.com
contract Agrosphere is
    ERC20,
    ERC20Burnable,
    ERC20Pausable,
    ERC20Capped,
    ERC20Permit,
    AccessControl
{
    /// @notice Role identifier for token minting privileges
    /// @dev Computed as keccak256("MINTER_ROLE")
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @notice Role identifier for pausing privileges
    /// @dev Computed as keccak256("PAUSER_ROLE")
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @notice Initializes the contract with token details and access control
    /// @dev Sets up ERC20 metadata, cap, and assigns initial roles to deployer
    /// @param cap Maximum token supply (in smallest denomination)
    constructor(
        uint256 cap
    ) ERC20("AgroToken", "AGT") ERC20Capped(cap) ERC20Permit("AgroToken") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
    }

    /// @notice Mints new tokens to specified address
    /// @dev Only callable by accounts with MINTER_ROLE, respects ERC20Capped limit
    /// @param to Address receiving the minted tokens
    /// @param amount Amount of tokens to mint (in smallest denomination)
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /// @notice Pauses all token transfers
    /// @dev Only callable by accounts with PAUSER_ROLE
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /// @notice Unpauses token transfers
    /// @dev Only callable by accounts with PAUSER_ROLE
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    // The following functions are overrides required by Solidity.

    /// @notice Handles token transfer logic with pausable and capped enforcement
    /// @dev Overrides multiple parent contracts' _update function
    /// @param from Sender address (0 for minting)
    /// @param to Recipient address (0 for burning)
    /// @param value Transfer amount
    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Pausable, ERC20Capped) {
        super._update(from, to, value);
    }
}
