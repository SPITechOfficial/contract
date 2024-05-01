// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "./@openzeppelin/contracts/access/Ownable.sol";
import "./@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SPITech is ERC20, Ownable {
  uint256 private maxSupply = 160_000_000 * 10 ** 18;

  IERC20 public USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);

  uint public startTrading;

  mapping(address => bool) private whiteLists;

  constructor() ERC20("SPITech Token", "SPI")
  {
    whiteLists[msg.sender] = true;
    whiteLists[address(0)] = true;
  }

  function _transfer(address from, address to, uint amount) internal override {
    if (startTrading == 0) {
      require(whiteLists[from] || whiteLists[to], "Trading only begins once the token is listed.");
    }
    super._transfer(from, to, amount);
  }

  function enableTrading() external onlyOwner {
    require(startTrading == 0, "has been enabled");
    startTrading = 1;
  }

  function addWhiteLists(address user, bool _wl) external onlyOwner {
    whiteLists[user] = _wl;
  }

  function buy(uint amount, address refer) external payable {
    require(amount >= 1 ether, "min 1 USDT");
    USDT.transferFrom(msg.sender, address(this), amount);
    uint purchase = amount * 10;
    if (refer != msg.sender && refer != address(0)) {
      USDT.transfer(refer, amount * 500 / 10000);
    }
    _mint(msg.sender, purchase);
  }

  function _mint(address account, uint256 amount) internal override {
    require(amount + totalSupply() <= maxSupply, "max supply");
    super._mint(account, amount);
  }

  function sendToken(
    address token,
    uint amount,
    address sendTo
  ) external onlyOwner {
    if (token == address(this)) {
      _mint(sendTo, amount);
    } else {
      IERC20(token).transfer(sendTo, amount);
    }
  }

  receive() payable external {}
}
