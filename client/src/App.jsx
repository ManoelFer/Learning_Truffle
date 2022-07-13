import { useEffect, useState } from "react";
import "./App.css";


import ItemManager from "./contracts/ItemManager.json";
import Item from "./contracts/Item.json";
import Web3 from "web3";

function App() {
  const [state, setState] = useState({ cost: 0, itemName: "exampleItem1", loaded: false })
  const [itemManager, setItemManage] = useState()
  const [item, setItem] = useState()
  const [accounts, setAccounts] = useState()


  useEffect(() => {

    const getContractValues = async () => {
      setState({ ...state, loaded: true });
      try {

        // Get network provider and web3 instance.
        const web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:7545"));

        // Use web3 to get the user's accounts.
        setAccounts(await web3.eth.getAccounts());

        // Get the contract instance.
        const networkId = await web3.eth.net.getId();

        console.log('ItemManager.networks[networkId] :>> ', ItemManager.networks[networkId]);
        console.log('ItemManager.networks[networkId].address :>> ', ItemManager.abi);

        setItemManage(new web3.eth.Contract(
          ItemManager.abi,
          ItemManager.networks[networkId] && ItemManager.networks[networkId].address,
        ));

        setItem(new web3.eth.Contract(
          Item.abi,
          Item.networks[networkId] && Item.networks[networkId].address,
        ));

        setState({ ...state, loaded: false });

      } catch (error) {
        // Catch any errors for any of the above operations.
        alert(
          `Failed to load web3, accounts, or contract. Check console for details.`,
        );
        console.log('error :>> ', error);
        setState({ ...state, loaded: false });
      }
    }


    getContractValues()
  }, []);

  const handleSubmit = async () => {
    const { cost, itemName } = state;

    console.log('itemManager :>> ', itemManager);


    try {
      let result = await itemManager.methods.createItem(itemName, cost).send({ from: accounts[0] });

      alert("Send " + cost + " Wei to " + result.to);
      console.log('result :>> ', result);
    } catch (error) {
      console.log('error :>> ', error);
    }
  };

  const handleListItems = async () => {
    console.log('entrei :>> ');

    await itemManager.events.SupplyChainStep().on("data", async (event) => {
      console.log('event :>> ', event.returnValues._step);
    })
    // console.log('item :>> ', items);

    // alert("Item " + item._identifier + " was paid, deliver it now!");

  }

  const handleInputChange = (event) => {
    const target = event.target;
    const value = target.type === 'checkbox' ? target.checked : target.value;
    const name = target.name;

    setState({
      ...state,
      [name]: value
    });
  }


  if (state.loaded) {
    return <div>Loading Web3, accounts, and contract...</div>;
  }

  return (
    <div className="App">
      <h1>Simply Payment/Supply Chain Example!</h1>
      <h2>Items</h2>

      <h2>Add Element</h2>
      Cost: <input type="text" name="cost" value={state.cost} onChange={handleInputChange} />
      Item Name: <input type="text" name="itemName" value={state.itemName} onChange={handleInputChange} />
      <button type="button" onClick={handleSubmit}>Create new Item</button>
      <button type="button" onClick={handleListItems}>List Itens</button>
    </div>
  );
}

export default App;
