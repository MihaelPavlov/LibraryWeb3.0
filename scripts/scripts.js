const ethers = require("ethers");
const BookLibrary = require("../artifacts/contracts/BookLibrary.sol/BookLibrary.json");

const run = async function () {
  if (!BookLibrary) {
    throw new Error("There is no book library artifact");
  }

  const provider = new ethers.providers.JsonRpcProvider("http://localhost:8545")
  const wallet = new ethers.Wallet("0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80", provider);
  const balance = await wallet.getBalance();
  console.log(balance.toString())

  const contractAddress = "0x0165878A594ca255338adfa4d48449f69242Eb8F";
  const contract = new ethers.Contract(contractAddress, BookLibrary.abi, provider.getSigner())

  await contract.addBook("Test", 2);
  await contract.addBook("Green World", 5);

  const addBookState = await contract.addBook("Harry Potter", 2);
  const result = await addBookState.wait();

  if (result.status != 1) {
    console.log("Transaction was not successful");
    return;
  }

  console.log(`Successfully added a book`);

  const numberOfBooks = await contract.getNumberOfBooks();
  for (let index = 0; index < numberOfBooks.toNumber(); index++) {
    await printMessageBookByIndex(index, "", contract);
  }

  console.log(`The number of books -> ${numberOfBooks.toNumber()}`);

  try {
    await contract.borrowBook("Green World")
  } catch (error) {
    console.log("Transaction borrowBook was not successful");
  }

  await printMessageBookByIndex(1, "AddedBook", contract);

  try {
    await contract.returnBook("Green World")
  } catch (error) {
    console.log("Transaction returnBook was not successful");
  }

  await printMessageBookByIndex(1, "ReturnedBook", contract);
}
run();

async function printMessageBookByIndex(id, action, contract) {
  const returnedBookKey = await contract.bookKeys(id);
  const returnedBook = await contract.books(returnedBookKey);
  console.log(`${action}: Book name is {${returnedBook.name}} and contains {${returnedBook.copies}} copies`);
}