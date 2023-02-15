const ethers = require("ethers");
const BookLibrary = require("../artifacts/contracts/BookLibrary.sol/BookLibrary.json");
require('dotenv').config();

const run = async function () {
    const provider = new ethers.providers.InfuraProvider("goerli", "31d722098d4e48929c96519ba339b2d0")
    const wallet = new ethers.Wallet("a61ded91802937b4690567a62077f2cca4cb1342a9be3cd69fd81689ad349c04", provider);
    const balance = await wallet.getBalance();
    console.log(ethers.utils.formatEther(balance, 18))

    const contractAddress = "0xB115936fab293142C8E18781A8D5Aa264fAF5912";
    const contract = new ethers.Contract(contractAddress, BookLibrary.abi, wallet)

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
        const state = await contract.borrowBook("test")
        await state.wait();
        await printMessageBookByIndex(0, "AddedBook", contract);
    } catch (error) {
        console.log("Transaction borrowBook was not successful");
    }

    try {
        const state = await contract.returnBook("test")
        await state.wait();
        await printMessageBookByIndex(0, "ReturnedBook", contract);
    } catch (error) {
        console.log("Transaction returnBook was not successful");
    }
}
run();

async function printMessageBookByIndex(id, action, contract) {
    const returnedBookKey = await contract.bookKeys(id);
    const returnedBook = await contract.books(returnedBookKey);
    console.log(`${action}: Book name is {${returnedBook.name}} and contains {${returnedBook.copies}} copies`);
}