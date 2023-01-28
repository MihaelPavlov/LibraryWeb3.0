// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
pragma abicoder v2;
import "./2_Owner.sol";

contract BookLibrary is Owner{

    struct Book{
        string name;
        uint8 copies;
    }
    
    struct History{
        address user;
        string action;
        string book;
    }

    address[] private allAddresses;
    History[] private histories;
    string[] private namesOfAllBooks;
    mapping(string => Book) public libraryBooks;
    mapping(address => string[]) private borrowBooks;

    // Returns all available books for borrowing (available book when it has more then one copies)
    function getAllAvailableBooks() public view returns(Book[] memory){
        Book[] memory _books= new Book[](namesOfAllBooks.length);

         for(uint i = 0;  i < namesOfAllBooks.length; i++)
        {
            Book memory book = libraryBooks[namesOfAllBooks[i]];
            
            if(book.copies > 0){
             _books[i] = Book(book.name, book.copies);
            }
        }
        
        return _books;
    }

    // History contains information for all taken and returned books
    function history() public view returns(History[] memory){
        return histories;
    }

    // Add new book, if the book is already in the library we are adding only the copies
    function addBook(Book calldata _book) public isOwner{
        if(compareTexts(libraryBooks[_book.name].name, _book.name)){
            libraryBooks[_book.name].copies += _book.copies;
        }else{
            libraryBooks[_book.name] =_book;
            namesOfAllBooks.push(_book.name);
        }
    }

    // Borrow book only if it's available
    function borrowBook(string calldata _bookName) public {
        require(libraryBooks[_bookName].copies > 0, "At the moment, the library doesn't have copy of this book.");
        require(!validateBorrowing(_bookName), "This address already borrowed this book.");
        
        borrowBooks[msg.sender].push(_bookName);
        libraryBooks[_bookName].copies--;

        histories.push(History(msg.sender, "taken", _bookName));
        allAddresses.push(msg.sender);
    }

    // Return book
    function returnBook(string calldata _bookName) public {
        require(validateBorrowing(_bookName),"You don't have this book");

        removeBorrowBookByName(_bookName);
        libraryBooks[_bookName].copies++;

        histories.push(History(msg.sender, "returned", _bookName));
    }

    function removeBorrowBookByName(string memory _name) private {
        uint i = findBorrowBookIndex(_name);
        removeByIndex(i);
    }

    function findBorrowBookIndex(string memory value) private view returns(uint) {
        uint i = 0;
        while ((keccak256(abi.encodePacked((borrowBooks[msg.sender][i])))) != (keccak256(abi.encodePacked((value))))) {
            i++;
        }
        return i;
    }

    function removeByIndex(uint i) private {
        // let say we have book [1,2,3,4].
        // we want to remove number 3 this is index[2]
        // So we are doing [1,2,4,4] and removing that last number and the array is [1,2,4]
       borrowBooks[msg.sender][i] = borrowBooks[msg.sender][borrowBooks[msg.sender].length - 1];
       borrowBooks[msg.sender].pop();
    }

    function validateBorrowing(string memory _bookName) private view returns(bool){

        for(uint i = 0;  i < borrowBooks[msg.sender].length; i++)
        {
                if((keccak256(abi.encodePacked((borrowBooks[msg.sender][i]))) == keccak256(abi.encodePacked((_bookName))))){
                    return true;
                }
        }

        return false;
    }

    function compareTexts(string memory _text1, string memory _text2) private pure returns(bool){
        if((keccak256(abi.encodePacked(_text1)) == keccak256(abi.encodePacked(_text2)))){
            return true;
        }
        return false;
    }
}