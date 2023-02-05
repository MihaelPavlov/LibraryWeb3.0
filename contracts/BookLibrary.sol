// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
pragma abicoder v2;
import "./2_Owner.sol";
import "./LibraryRegistry.sol";

interface ILibraryRegsitry {
    function register(string memory _username) external payable;

    function readBook(address _contractAddress, string memory _bookName) external;
}

contract BookLibrary is Owner{

    struct Book{
        string name;
        uint copies;
        address[] bookBorrowedAdresses;
    }

    ILibraryRegsitry public registry; // Can i check if this initialization is null. Is there a null?

    function setRegistry(address _addr) public{
        registry = ILibraryRegsitry(_addr);
    }

    bytes32[] public bookKeys;

    mapping(bytes32 => Book) public books;
    mapping(address => mapping(bytes32 => bool)) private borrowedBook;

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

    // modifier isRegisterdInLibrary(address _addr){
    //     require(bytes(registry.isRegistered(_addr).username).length > 0,"You are not registered");
    //     _;
    // }

    // Add new book, if the book is already in the library we are adding only the copies
    function addBook(string memory _bookName, uint _copies) public isOwner isBookValid(_bookName, _copies){
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
        books[bookName].copies ++;

        emit ReturnedBook(_bookName,msg.sender);

        registry.readBook(address(this), _bookName);

        // Delegetae call is sending the data from the caller 
        // basically if we call readBook function with delegateCall the msg.sender will be the account address. Else if we use just call the msg.sender will be the contract address

        // (bool isOkey,) = registry.delegatecall(abi.encodeWithSelector(LibraryRegistry.readBook.selector,address(this),bookName));
        // require(isOkey,"Something failed");
    }

    // Helpers
    function getNumberOfBooks() public view returns (uint _numberOfBooks){
        return bookKeys.length;
    }

    function GetbookBytes(string memory _bookName) public view returns(uint   ){
        return bytes(books[keccak256(abi.encodePacked(_bookName))].name).length;
    }
}