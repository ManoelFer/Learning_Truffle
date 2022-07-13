//SPDX-License-Identifier: GPL-0.3
//Versão do compilador
pragma solidity ^0.8.15;

import "./Ownable.sol";

import "./Item.sol";

//Bloco do contrato
contract ItemManager is Ownable {
    //Variável de enum com os valores definidos dentro das chaves [Created, Paid,  Delivered]
    enum SupplyChainSteps {
        Created,
        Paid,
        Delivered
    }

    event SupplyChainStep(
        uint256 _itemIndex,
        uint256 _step,
        address _itemAddress
    );

    //Variável do tipo struct para armazenamento dos atributos de um item
    struct S_Item {
        Item _item; //Do mesmo tipo do contrato que tem relação
        ItemManager.SupplyChainSteps _step; //Variável que recebe o enum com o estado do item
        string _identifier;
    }

    //Variável do tipo mapping para armazenamento do Item
    mapping(uint256 => S_Item) public items;

    //Inteiro não nulo para armazenar a posição que um item está
    uint256 index;

    //Função para criação dos itens. O parâmetro _identifier é uma string que ficará armazenada em memória e o _priceInWei é o preço em wei
    function createItem(string memory _identifier, uint256 _priceInWei)
        public
        onlyOwner
    {
        Item item = new Item(this, _priceInWei, index);

        //==Adiciona no mapeamento do item em específico, seus atributos==
        items[index]._item = item;
        items[index]._step = SupplyChainSteps.Created;
        items[index]._identifier = _identifier;
        //================================================================

        //Emite um evento para retornar o item criado, semelhante ao console.log
        emit SupplyChainStep(index, uint256(items[index]._step), address(item));

        //passa para a próxima posição do index, para criar um novo produto
        index++;
    }

    // Aciona o pagamento
    function triggerPayment(uint256 _index) public payable {
        Item item = items[_index]._item;
        require(
            address(item) == msg.sender,
            "Only items are allowed to update themselves"
        );
        require(item.priceInWei() == msg.value, "Not fully paid yet");
        //Verifica se existe o item e o estado dele é somente criado
        require(
            items[_index]._step == SupplyChainSteps.Created,
            "Item is further in the supply chain"
        );
        //Muda o estado para pago
        items[_index]._step = SupplyChainSteps.Paid;

        //Emite um evento com os dados do pagamento
        emit SupplyChainStep(
            _index,
            uint256(items[_index]._step),
            address(item)
        );
    }

    // Aciona a entrega
    function triggerDelivery(uint256 _index) public onlyOwner {
        //Verifica se existe o item e o estado dele é somente criado
        require(
            items[_index]._step == SupplyChainSteps.Paid,
            "Item is further in the supply chain"
        );
        items[_index]._step = SupplyChainSteps.Delivered;

        //Emite um evento com os dados da entrega
        emit SupplyChainStep(
            index,
            uint256(items[index]._step),
            address(items[_index]._item)
        );
    }
}
