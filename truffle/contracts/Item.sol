//SPDX-License-Identifier: GPL-0.3
pragma solidity ^0.8.15;

import "./ItemManager.sol";

//Contrato do Item
contract Item {
    uint256 public priceInWei;
    uint256 public paidWei;
    uint256 public index;

    //Definindo contrato que faz relação
    ItemManager parentContract;

    //O _parentContract é do mesmo tipo que o contrato definido na linha acima
    constructor(
        ItemManager _parentContract,
        uint256 _priceInWei,
        uint256 _index
    ) {
        priceInWei = _priceInWei;
        index = _index;
        parentContract = _parentContract;
    }

    receive() external payable {
        require(msg.value == priceInWei, "We don't support partial payments");
        require(paidWei == 0, "Item is already paid!");
        paidWei += msg.value;
        (bool success, ) = address(parentContract).call{value: msg.value}(
            abi.encodeWithSignature("triggerPayment(uint256)", index)
        );
        require(success, "Delivery did not work");
    }

    fallback() external {}
}
