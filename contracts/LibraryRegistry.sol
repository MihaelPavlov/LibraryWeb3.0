// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
pragma abicoder v2;
import "./2_Owner.sol";
import "./BookLibrary.sol";

contract LibraryRegistry is Owner{

    struct Registration{
        string username;
        uint registeredDay;
        bool isTaxPayed;
        bytes32[] readedBooks; // Collection of all books the the user read/returned.
    }

    uint[] private libraryTaxesHistory;

    mapping(address => Registration) internal registrations;

    event RegisteredUser(address _address);
    event test(address _address);
    modifier ValidateTax(uint _tax){
        require(_tax >= 27 wei, "The tax for the library is more or alteas 27 weis");
        _;
        libraryTaxesHistory.push(msg.value);
    }

    function register(string calldata _username) public payable ValidateTax(msg.value){
        require(bytes(registrations[msg.sender].username).length == 0, "You are already registered");
        require(bytes(_username).length >= 3,"Username should be atleast 3 symbols");

        bytes32[] memory emptyArr;
        registrations[msg.sender] = Registration(_username,block.timestamp,true, emptyArr);

        emit RegisteredUser(msg.sender);
    }

    function readBook(address _contractAddress, bytes32 _bookName) external payable{
        (string memory name,)= BookLibrary(_contractAddress).books(_bookName);
        require(bytes(name).length != 0,"This book doesn't exists");

        // if we pass msg.sender we are taking the address of the contract not the account address
        registrations[msg.sender].readedBooks.push(_bookName);
        // read the books from BooksLibrary 
        // check is the book exist
        emit test(msg.sender);
    } 

    function CheckHistory(uint _index) public view isOwner returns(uint){
        return libraryTaxesHistory[_index];
    }

    function CheckRegistration(address _address) public view isOwner returns (Registration memory){
        return registrations[_address];
    }
}