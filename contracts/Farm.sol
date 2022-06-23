//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Farm is Ownable, AccessControl {
    event Response (bool success, bytes data);
      constructor (address root) {
        _setupRole(DEFAULT_ADMIN_ROLE, root);
    } 

    modifier onlyAdmin() {
        require(isAdmin(msg.sender), "Restricted to admins.");
        _;
    }
    
    function execute(address target, bytes calldata callData) public onlyAdmin {
        (bool success, bytes memory data) = target.call(callData);
        require(success);

        emit Response(success, data);
    }

    function isAdmin(address account) public virtual view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    function addAdmin(address account) public onlyOwner {
        grantRole(DEFAULT_ADMIN_ROLE, account);
    }

    function removeAdmin(address account) public onlyOwner {
        bool exists = isAdmin(account);
        require(exists, "Provided account is no admin.");
        renounceRole(DEFAULT_ADMIN_ROLE, account);
    }
}
