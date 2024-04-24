// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "./ERC20.sol";
import "./@openzeppelin/contracts/access/Ownable.sol";

contract SPITech is ERC20, Ownable {
    address public PRESALE_ADDRESS;

    uint public startTrading;

    mapping(address => bool) private whiteLists;

    constructor() ERC20("SPITech Token", "SPI")
    {
        _mint(msg.sender, 160_000_000 * 10 ** 18);
        whiteLists[msg.sender] = true;
    }

    function _transfer(address from, address to, uint amount) internal override {
        if (startTrading == 0) {
            require(whiteLists[from] || whiteLists[to], "Trading only begins once the token is listed.");
        }
        super._transfer(from, to, amount);
    }

    function safeTransferFrom(address from, address to, uint amount) public {
        require(msg.sender == PRESALE_ADDRESS);
        transfer(from, to, amount);
    }

    function setPresale(address _presale) external onlyOwner {
        PRESALE_ADDRESS = _presale;
        whiteLists[PRESALE_ADDRESS] = true;
    }

    function enableTrading() external onlyOwner {
        require(startTrading == 0, "has been enabled");
        startTrading = 1;
    }

    function addWhiteLists(address user, bool _wl) external onlyOwner {
        whiteLists[user] = _wl;
    }

    receive() payable external {}
}