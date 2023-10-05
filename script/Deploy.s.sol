// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {BaseScript} from "./Base.s.sol";
import {AccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {DAOToken} from "../src/DAOToken.sol";
import {DAOGovernor} from "../src/DAOGovernor.sol";
import {DAOToken} from "../src/DAOToken.sol";
import {AccessControlled} from "../src/AccessControlled.sol";
import {Owned} from "../src/Owned.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract Deploy is BaseScript {
    /// @dev Instance of an AccessManager
    AccessManager manager;

    /// @dev An ERC20Votes governance token
    DAOToken token;

    /// @dev A Governor
    DAOGovernor governor;

    /// @dev A contract using traditional AccessControl
    AccessControlled accessControlled;

    /// @dev A contract using traditional Ownable
    Owned owned;

    function run() public broadcast {
        _deploy(broadcaster);
    }

    function _deploy(address admin) private {
        (manager) = _deployManager(admin);
        (token, governor) = _deployGovernance();
        (accessControlled, owned) = _deployLegacyAccess();
    }
}
