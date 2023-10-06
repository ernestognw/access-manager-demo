// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20Votes, ERC20, Votes} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {AccessManaged} from "@openzeppelin/contracts/access/manager/AccessManaged.sol";

contract DAOToken is ERC20Votes, AccessManaged {
    constructor(
        address manager,
        address initialHolder,
        uint256 initialSupply
    )
        ERC20Votes()
        ERC20("DAOToken", "DAO")
        EIP712("DAOToken", "1")
        AccessManaged(manager)
    {
        _mint(initialHolder, initialSupply);
    }

    function mint(address account, uint256 value) external restricted {
        _mint(account, value);
    }
}
