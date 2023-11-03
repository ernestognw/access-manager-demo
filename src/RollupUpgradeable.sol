// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessManagedUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

contract RollupUpgradeableV1 is AccessManagedUpgradeable, UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address manager) public initializer {
        __AccessManaged_init(manager);
    }

    function _authorizeUpgrade(address) internal override restricted {}

    function version() external pure returns (string memory) {
        return "1";
    }
}
