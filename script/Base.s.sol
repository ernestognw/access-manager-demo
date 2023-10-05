// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {AccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {DAOToken} from "../src/DAOToken.sol";
import {DAOGovernor} from "../src/DAOGovernor.sol";
import {DAOToken} from "../src/DAOToken.sol";
import {AccessControlled} from "../src/AccessControlled.sol";
import {Owned} from "../src/Owned.sol";
import {RollupUpgradeable} from "../src/RollupUpgradeable.sol";

abstract contract BaseScript is Script {
    /// @dev Included to enable compilation of the script without a $MNEMONIC environment variable.
    string internal constant TEST_MNEMONIC =
        "test test test test test test test test test test test junk";

    /// @dev Needed for the deterministic deployments.
    bytes32 internal constant ZERO_SALT = bytes32(0);

    /// @dev The address of the transaction broadcaster.
    address internal broadcaster;

    /// @dev Used to derive the broadcaster's address if $ETH_FROM is not defined.
    string internal mnemonic;

    /// @dev Initializes the transaction broadcaster like this:
    ///
    /// - If $ETH_FROM is defined, use it.
    /// - Otherwise, derive the broadcaster address from $MNEMONIC.
    /// - If $MNEMONIC is not defined, default to a test mnemonic.
    ///
    /// The use case for $ETH_FROM is to specify the broadcaster key and its address via the command line.
    constructor() {
        address from = vm.envOr({name: "ETH_FROM", defaultValue: address(0)});
        if (from != address(0)) {
            broadcaster = from;
        } else {
            mnemonic = vm.envOr({
                name: "MNEMONIC",
                defaultValue: TEST_MNEMONIC
            });
            (broadcaster, ) = deriveRememberKey({mnemonic: mnemonic, index: 0});
        }
    }

    modifier broadcast() {
        vm.startBroadcast(broadcaster);
        _;
        vm.stopBroadcast();
    }

    function _deployManager(
        address admin
    ) internal virtual returns (AccessManager manager) {
        return new AccessManager(admin);
    }

    function _deployGovernance(
        address manager
    ) internal virtual returns (DAOToken token, DAOGovernor governor) {
        token = new DAOToken(manager);
        governor = new DAOGovernor(token);
    }

    function _deployLegacyAccess(
        address manager
    )
        internal
        virtual
        returns (AccessControlled accessControlled, Owned owned)
    {
        accessControlled = new AccessControlled(manager);
        owned = new Owned(manager);
    }

    function _deployUpgradeable(
        address manager
    ) internal virtual returns (RollupUpgradeable upgradeable) {
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(new RollupUpgradeable()),
            abi.encodeCall(
                RollupUpgradeable.initialize.selector,
                abi.encode(manager)
            )
        );

        return RollupUpgradeable(proxy);
    }
}
