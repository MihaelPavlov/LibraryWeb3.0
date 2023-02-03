// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
pragma abicoder v2;
import "./2_Owner.sol";

contract BookLibrary is Owner{

    struct Book{
        string name;
        uint copies;
        address[] bookBorrowedAdresses;
    }

    bytes32[] public bookKeys;

    mapping(bytes32 => Book) public books;
    mapping(address => mapping(bytes32 => bool)) private borrowedBook;

    event AddedBook(string _bookName, uint _copies);
    event BorrowedBook(string _bookName, address _address);
    event ReturnBook(string _bookName, address _address);

    modifier doesBookExists(string memory _bookName){
        require(bytes(books[keccak256(abi.encodePacked(_bookName))].name).length != 0 ,"This book doesn't exists");
        _;
    }

    modifier isBookValid(string memory _bookName, uint _copies){
        bytes memory tempBookName = bytes(_bookName);
        require(tempBookName.length > 0 && _copies > 0, "Book data is not valid");
        _;
    }

    modifier validateBorrowingBook(string memory _bookName){
        _;
    } 


    // Add new book, if the book is already in the library we are adding only the copies
    function addBook(string memory _bookName, uint _copies) public isOwner isBookValid(_bookName, _copies){
        address[] memory emptyAddressList;
        bytes32 bookNameBytes = bytes32(keccak256(abi.encodePacked(_bookName)));

        // if book is already added just increase the copies
        books[bookNameBytes] = Book(_bookName,_copies, emptyAddressList);
        bookKeys.push(bookNameBytes);

        emit AddedBook(_bookName, _copies);
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
    // function returnBook(string calldata _bookName) public {
    //     require(borrowBook[msg.sender][bytes32(_bookName)],"You don't have this book");

    //     borrowBook[msg.sender][bytes32(_bookName)] = false;

    //     removeBorrowBookByName(_bookName);
    //     libraryBooks[_bookName].copies++;

    //     histories.push(History(msg.sender, "returned", _bookName));

    //     emit ReturnBook(_bookName,msg.sender);
    // }

    function getNumberOfBooks() public view returns (uint _numberOfBooks){
        return bookKeys.length;
    }

    function GetbookBytes(string memory _bookName) public view returns(uint   ){
        return bytes(books[keccak256(abi.encodePacked(_bookName))].name).length;
    }

}