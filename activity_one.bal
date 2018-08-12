import ballerina/io;
import ballerina/log;

function close(io:CharacterChannel characterChannel) {
    characterChannel.close() but {
        error e =>
          log:printError("Error occurred while closing character stream",
                          err = e)
    };
}

function read(string path) returns json {
    io:ByteChannel byteChannel = io:openFile(path, io:READ);
    io:CharacterChannel ch = new io:CharacterChannel(byteChannel, "UTF8");
    match ch.readJson() {
        json result => {
            close(ch);
            return result;
        }
        error err => {
            close(ch);
            throw err;
        }
    }
}

function main(string... args) {
    string filePath = "./files/sample.json";
    io:println("------ Read content from the file ------");
    json content = read(filePath);
    json books = content.store.books;
    io:println("------ Print books published after 1900 ------");
    foreach book in books {
        int year = check <int> book.year;
        if (year > 1900) {
            io:println(book);
        }
    }
}

