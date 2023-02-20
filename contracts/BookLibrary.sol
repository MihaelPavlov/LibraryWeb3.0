// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
pragma abicoder v2;
import "@openzeppelin/contracts/access/Ownable.sol";

contract BookLibrary is Ownable{

    struct Book{
        string name;
        uint copies;
        address[] bookBorrowedAdresses;
    }

    bytes32[] public bookKeys;

    mapping(bytes32 => Book) public books;
    mapping(address => mapping(bytes32 => bool)) public borrowedBook;

    event AdjustCopies(string _bookName, uint _copies);
    event AddedBook(string _bookName, uint _copies);
    event BorrowedBook(string _bookName, address _address);
    event ReturnedBook(string _bookName, address _address);

    modifier doesBookExists(string memory _bookName){
        require(bytes(books[keccak256(abi.encodePacked(_bookName))].name).length != 0 ,"This book doesn't exists");
        _;
    }

    modifier isBookValid(string memory _bookName, uint _copies){
        bytes memory tempBookName = bytes(_bookName);
        require(tempBookName.length > 0 && _copies > 0, "Book data is not valid");
        _;
    }

    // Add new book, if the book is already in the library we are adding only the copies
    function addBook(string memory _bookName, uint _copies) public onlyOwner isBookValid(_bookName, _copies){
        address[] memory emptyAddressList;
        bytes32 bookNameBytes = bytes32(keccak256(abi.encodePacked(_bookName)));

        if(bytes(books[bookNameBytes].name).length > 0){
            books[bookNameBytes].copies += _copies;
            emit AdjustCopies(_bookName,books[bookNameBytes].copies);
        }
        else{
            books[bookNameBytes] = Book(_bookName,_copies, emptyAddressList);
            bookKeys.push(bookNameBytes);
            emit AddedBook(_bookName, _copies);
        }

    }

    // Borrow book only if it's available
    function borrowBook(string memory _bookName) public doesBookExists(_bookName){
        bytes32 bookName = bytes32(keccak256(abi.encodePacked(_bookName)));

        require(books[bookName].copies > 0, "At the moment, the library doesn't have copy of this book.");
        require(borrowedBook[msg.sender][bookName] == false, "This address already borrowed this book.");
        
        borrowedBook[msg.sender][bookName] = true;
        books[bookName].copies--;
        books[bookName].bookBorrowedAdresses.push(msg.sender);

        emit BorrowedBook(_bookName, msg.sender);
    }

    // Return book
    function returnBook(string calldata _bookName) public {
        bytes32 bookName = bytes32(keccak256(abi.encodePacked(_bookName)));

        require(borrowedBook[msg.sender][bookName],"You don't have this book");
        
        borrowedBook[msg.sender][bookName] = false;
        books[bookName].copies++;

        emit ReturnedBook(_bookName,msg.sender);
    }

    // Helpers
    function getNumberOfBooks() public view returns (uint _numberOfBooks){
        return bookKeys.length;
    }
}