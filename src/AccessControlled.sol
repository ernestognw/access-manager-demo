// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControlDefaultAdminRules} from "@openzeppelin/contracts/access/extensions/AccessControlDefaultAdminRules.sol";

contract AccessControlled is AccessControlDefaultAdminRules {
    uint256 public value;

    event DidSomething();

    constructor(
        address initialAdmin
    ) AccessControlDefaultAdminRules(3 days, initialAdmin) {}

    function doSomething() public onlyRole(DEFAULT_ADMIN_ROLE) {
        emit DidSomething();
    }
}
