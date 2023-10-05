// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControlDefaultAdminRules} from "@openzeppelin/contracts/access/extensions/AccessControlDefaultAdminRules.sol";

contract AccessControlled is AccessControlDefaultAdminRules {
    uint256 public value;

    event ValueSet(uint256 newValue);

    constructor(
        address initialAdmin
    ) AccessControlDefaultAdminRules(3 days, initialAdmin) {}

    function setValue(uint256 newValue) public onlyRole(DEFAULT_ADMIN_ROLE) {
        value = newValue;
        emit ValueSet(newValue);
    }
}
