// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {BaseScript} from "./utils/Base.s.sol";
import {AccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {DAOToken} from "../src/DAOToken.sol";
import {DAOGovernor} from "../src/DAOGovernor.sol";
import {DAOToken} from "../src/DAOToken.sol";
import {AccessControlled} from "../src/AccessControlled.sol";
import {Owned} from "../src/Owned.sol";
import {RollupUpgradeableV1, UUPSUpgradeable} from "../src/RollupUpgradeable.sol";

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

    /// @dev A contract using traditional Ownable
    RollupUpgradeableV1 rollup;

    // Roles
    uint64 public constant CALLER_ROLE = 1;
    uint64 public constant CALLER_GUARDIAN_ROLE = 2;
    uint64 public constant CALLER_ADMIN_ROLE = 3;

    uint64 public constant UPGRADER_ROLE = 4;
    uint64 public constant UPGRADER_GUARDIAN_ROLE = 5;
    uint64 public constant UPGRADER_ADMIN_ROLE = 6;

    uint64 public constant MINTER_ROLE = 7;
    uint64 public constant MINTER_GUARDIAN_ROLE = 8;
    uint64 public constant MINTER_ADMIN_ROLE = 9;

    function run() public broadcast {
        manager = new AccessManager(broadcaster); // Broadcaster is initial admin

        // Deploy
        token = new DAOToken(
            address(manager),
            vm.envOr({name: "INITIAL_HOLDER", defaultValue: broadcaster}),
            10_000_000 ether
        );
        governor = new DAOGovernor(token);
        accessControlled = new AccessControlled(address(manager));
        owned = new Owned(address(manager));
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(new RollupUpgradeableV1()),
            abi.encodeCall(RollupUpgradeableV1.initialize, address(manager))
        );
        rollup = RollupUpgradeableV1(address(proxy));

        // Restrict functions

        manager.setTargetFunctionRole(
            address(token),
            _asSingletonArray(DAOToken.mint.selector),
            MINTER_ROLE
        );
        manager.setTargetFunctionRole(
            address(owned),
            _asSingletonArray(Owned.setValue.selector),
            CALLER_ROLE
        );
        manager.setTargetFunctionRole(
            address(accessControlled),
            _asSingletonArray(AccessControlled.doSomething.selector),
            CALLER_ROLE
        );
        manager.setTargetFunctionRole(
            address(rollup),
            _asSingletonArray(UUPSUpgradeable.upgradeToAndCall.selector),
            UPGRADER_ROLE
        );

        // Assign roles
        address admin = vm.envAddress("ADMIN");
        _grantMissingRole(manager.ADMIN_ROLE(), admin);

        _setUpRole({
            roleId: MINTER_ROLE,
            account: vm.envAddress("MINTER"),
            adminId: MINTER_ADMIN_ROLE,
            admin: vm.envOr({name: "MINTER_ADMIN", defaultValue: admin}),
            guardianId: MINTER_GUARDIAN_ROLE,
            guardian: vm.envOr({name: "MINTER_GUARDIAN", defaultValue: admin}),
            label: "MINTER"
        });
        _setUpRole({
            roleId: CALLER_ROLE,
            account: vm.envAddress("CALLER"),
            adminId: CALLER_ADMIN_ROLE,
            admin: vm.envOr({name: "CALLER_ADMIN", defaultValue: admin}),
            guardianId: CALLER_GUARDIAN_ROLE,
            guardian: vm.envOr({name: "CALLER_AGUARDIAN", defaultValue: admin}),
            label: "CALLER"
        });
        _setUpRole({
            roleId: UPGRADER_ROLE,
            account: vm.envAddress("UPGRADER"),
            adminId: UPGRADER_ADMIN_ROLE,
            admin: vm.envOr({name: "UPGRADER_ADMIN", defaultValue: admin}),
            guardianId: UPGRADER_GUARDIAN_ROLE,
            guardian: vm.envOr({
                name: "UPGRADER_GUARDIAN",
                defaultValue: admin
            }),
            label: "UPGRADER"
        });

        manager.renounceRole(manager.ADMIN_ROLE(), broadcaster); // Admin renounced
    }

    function _setUpRole(
        uint64 roleId,
        address account,
        uint64 adminId,
        address admin,
        uint64 guardianId,
        address guardian,
        string memory label
    ) private {
        _grantMissingRole(roleId, account);
        manager.labelRole(roleId, label);

        manager.setRoleGuardian(roleId, guardianId);
        _grantMissingRole(guardianId, guardian);

        manager.setRoleAdmin(roleId, adminId);
        _grantMissingRole(adminId, admin);
    }

    function _grantMissingRole(uint64 roleId, address account) private {
        (bool isMember, ) = manager.hasRole(roleId, account);
        if (!isMember) {
            manager.grantRole(roleId, account, 0);
        }
    }

    function _asSingletonArray(
        bytes4 element
    ) private pure returns (bytes4[] memory) {
        bytes4[] memory array = new bytes4[](1);
        array[0] = element;

        return array;
    }
}
