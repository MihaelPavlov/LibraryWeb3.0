
import { BookLibrary__factory } from "./../typechain-types/factories/contracts/BookLibrary__factory";
import { BookLibrary } from "./../typechain-types/contracts/BookLibrary";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("BookLibrary", function () {
    let bookLibraryFactory: BookLibrary__factory;
    let bookLibrary: BookLibrary;

    describe("Add Book", function () {

        before(async () => {
            bookLibraryFactory = await ethers.getContractFactory("BookLibrary");
        });

        beforeEach(async () => {
            bookLibrary = await bookLibraryFactory.deploy();

            await bookLibrary.deployed();
        });

        it("Should be added to the library", async () => {
            await bookLibrary.addBook("bookOne", 2);
            let bookByte = bookLibrary.bookKeys(0);
            expect((await bookLibrary.books(bookByte)).name).to.equal("bookOne");
        });

        it("If book exist add just the new copies", async () => {
            await bookLibrary.addBook("bookOne", 2);
            await bookLibrary.addBook("bookOne", 2);

            let bookByte = bookLibrary.bookKeys(0);
            expect((await bookLibrary.books(bookByte)).copies).to.equal(4);
        });

        it("Should emit event if we add book successfully", async () => {
            await expect(bookLibrary.addBook("bookOne", 2)).to.emit(bookLibrary, "AddedBook").withArgs("bookOne", 2);
        });

        it("Should emit event if we add copies successfully", async () => {
            await bookLibrary.addBook("bookOne", 2)
            await expect(bookLibrary.addBook("bookOne", 2)).to.emit(bookLibrary, "AdjustCopies").withArgs("bookOne", 4);
        });

        it("Should be reverted", async () => {
            await expect(bookLibrary.addBook("", 0)).to.be.revertedWith("Book data is not valid");
        });

        it("Should be reverted if it's not owner", async () => {
            const [, addr1] = await ethers.getSigners();

            await expect(bookLibrary.connect(addr1).addBook("test", 1)).to.be.revertedWith("Ownable: caller is not the owner");
        });
    });

    describe("Borrow Book", function () {

        before(async () => {
            bookLibraryFactory = await ethers.getContractFactory("BookLibrary");

            bookLibrary = await bookLibraryFactory.deploy();

            await bookLibrary.deployed();
        });

        it("Should be reverted if book doesn't exist", async () => {
            await expect(bookLibrary.borrowBook("bookOne")).to.be.revertedWith("This book doesn't exists");
        });

        it("Should be borrowed successfully and emit event", async () => {
            const [owner] = await ethers.getSigners();

            await bookLibrary.addBook("bookOne", 2);

            let bookByte = bookLibrary.bookKeys(0);

            await expect(bookLibrary.borrowBook("bookOne")).to.emit(bookLibrary, "BorrowedBook").withArgs("bookOne", await owner.getAddress());
            expect((await bookLibrary.books(bookByte)).copies).to.equal(1);
        });

        it("Should be reverted book already borrowed by this address", async () => {
            await expect(bookLibrary.borrowBook("bookOne")).to.be.revertedWith("This address already borrowed this book.");
        });

        it("Should be successfully if we borrowed from different address", async () => {
            const [, addr1] = await ethers.getSigners();

            let bookByte = bookLibrary.bookKeys(0);
            await bookLibrary.connect(addr1).borrowBook("bookOne");
            expect((await bookLibrary.books(bookByte)).copies).to.equal(0);
        });

        it("Should be reverted book doesn't have copies", async () => {
            await expect(bookLibrary.borrowBook("bookOne")).to.be.revertedWith("At the moment, the library doesn't have copy of this book.");
        });
    });

    describe("Return Book", function () {

        before(async () => {
            bookLibraryFactory = await ethers.getContractFactory("BookLibrary");
        });

        beforeEach(async () => {
            bookLibrary = await bookLibraryFactory.deploy();

            await bookLibrary.deployed();
        });

        it("Should be returned successfully and emit event", async () => {
            await bookLibrary.addBook("bookOne", 2);
            await bookLibrary.borrowBook("bookOne");

            let bookByte = bookLibrary.bookKeys(0);
            const [owner] = await ethers.getSigners();

            expect((await bookLibrary.books(bookByte)).copies).to.equal(1);
            await expect(bookLibrary.returnBook("bookOne")).to.emit(bookLibrary, "ReturnedBook").withArgs("bookOne", await owner.getAddress());
            expect((await bookLibrary.books(bookByte)).copies).to.equal(2);
        });

        it("Should be reverted", async () => {
            await expect(bookLibrary.returnBook("bookOne")).to.be.revertedWith("You don't have this book");
        });
    });

    describe("Helpers", function () {

        before(async () => {
            bookLibraryFactory = await ethers.getContractFactory("BookLibrary");
            bookLibrary = await bookLibraryFactory.deploy();

            await bookLibrary.deployed();
        });

        it("Get Number of books should return 2", async () => {
            await bookLibrary.addBook("bookOne", 2);
            await bookLibrary.addBook("bookTwo", 2);
            let countBooks =await bookLibrary.getNumberOfBooks();
            expect(countBooks).to.equal(2);
        });

    });
});