CREATE DATABASE IF NOT EXISTS LAB3;
USE LAB3;

CREATE TABLE Book (
    Book_id   INT   NOT NULL   UNIQUE,
    Isbn      VARCHAR(20),
    Title     VARCHAR(100),
    Author    VARCHAR(50),
    Publisher VARCHAR(50),
    Year      INT
);

INSERT INTO Book (Book_id, Isbn, Title, Author, Publisher, Year) VALUES
(101, '978-0131103627', 'The C Programming Language', 'Dennis Ritchie', 'Prentice Hall', 1988),
(102, '978-0201633610', 'Design Patterns', 'Erich Gamma', 'Addison-Wesley', 1994),
(103, '978-0262033848', 'Introduction to Algorithms', 'Thomas H. Cormen', 'MIT Press', 2009),
(104, '978-0132350884', 'Clean Code', 'Robert C. Martin', 'Prentice Hall', 2008),
(105, '978-0134685991', 'Effective Java', 'Joshua Bloch', 'Addison-Wesley', 2018);

ALTER TABLE Book ADD PRIMARY KEY (Book_id);

CREATE TABLE Book_Copy (
    book_id   INT NOT NULL,
    copy_no   INT NOT NULL,
    shelf_no  INT,
    status    VARCHAR(20),
    PRIMARY KEY (book_id, copy_no)
);

ALTER TABLE Book_Copy
ADD CONSTRAINT fk_copy_referencing_book
FOREIGN KEY (book_id) REFERENCES Book(Book_id);

ALTER TABLE Book
ADD UNIQUE (Isbn);

INSERT INTO Book_Copy (book_id, copy_no, shelf_no, status) VALUES (101, 1, 5, 'Available');

SELECT * FROM Book;
SELECT * FROM Book_Copy;
