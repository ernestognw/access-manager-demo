// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

contract Owned is Ownable {
    uint256 public value;

    event ValueSet(uint256 newValue);

    constructor(address initialOwner) Ownable(initialOwner) {}

    function setValue(uint256 newValue) public onlyOwner {
        value = newValue;
        emit ValueSet(newValue);
    }
}
