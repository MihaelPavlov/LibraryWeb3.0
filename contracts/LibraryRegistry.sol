// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
pragma abicoder v2;
import "./2_Owner.sol";
import "./BookLibrary.sol";
import "hardhat/console.sol";

contract LibraryRegistry is Owner{

    struct Registration{
        string username;
        uint registeredDay;
        bool isTaxPayed;
        string[] readedBooks; // Collection of all books the the user read/returned.
    }

    uint[] private libraryTaxesHistory;

    mapping(address => Registration) private registrations;

    event RegisteredUser(address _address);
    event test(address _address);
    modifier ValidateTax(uint _tax){
        require(_tax >= 27 wei, "The tax for the library is more or alteas 27 weis");
        _;
        libraryTaxesHistory.push(msg.value);
    }

    // function isRegistered(address _addr) public view returns(Registration memory){
    //     return registrations[_addr];
    // }

    function register(string calldata _username) public payable ValidateTax(msg.value){
        require(bytes(registrations[msg.sender].username).length == 0, "You are already registered");
        require(bytes(_username).length >= 3,"Username should be atleast 3 symbols");

        registrations[msg.sender] = Registration(_username,block.timestamp,true, new string[](0));

        emit RegisteredUser(tx.origin);
    }

    function readBook(address _contractAddress, string calldata _bookName) external {

        // if i use this code here and validate the _bookName , after this when i pushed the _bookname it's isn't there. 
        // read the books from BooksLibrary 
        // check is the book exist

        // (string memory name,)= BookLibrary(_contractAddress).books(bytes32(keccak256(abi.encodePacked(_bookName))));
        // require(bytes(name).length != 0,"This book doesn't exists");

        // if we pass msg.sender we are taking the address of the contract not the account address

        registrations[tx.origin].readedBooks.push(_bookName);
 
        emit test(tx.origin);
    } 

    function CheckHistory(uint _index) public view isOwner returns(uint){
        return libraryTaxesHistory[_index];
    }

    function CheckRegistration(address _address) public view isOwner returns (Registration memory){
        return registrations[_address];
    }
}