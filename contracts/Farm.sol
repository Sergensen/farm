//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Farm is Ownable {
    string[] private admins;

    event Response (bool success, bytes data);

    function execute(address target, bytes calldata callData) public onlyOwner {
        (bool success, bytes memory data) = target.call(callData);
        require(success);

        emit Response(success, data);
    }

    function getAdmins() public view returns (string[] memory) {
        return admins;
    }

    function addAdmin(string memory admin) public onlyOwner {
        require(admins.length < 5, "Cannot add more that 5 admins.");
        admins.push(admin);
    }

    function removeAdmin(string memory admin) public onlyOwner {
        uint index = adminIndex(admin);
        require(index != 10, "Provided account is no admin.");

        admins[index] = admins[admins.length - 1];
        admins.pop();
    }

    function adminIndex(string memory account) private view returns(uint) {
        for (uint i = 0 ; i < admins.length; i++) {
            if (keccak256(abi.encodePacked(admins[i])) == keccak256(abi.encodePacked(account))) {
                return i;
            }
        }
        return 10;
    }
}
