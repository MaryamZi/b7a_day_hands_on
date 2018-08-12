import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/sql;
import ballerina/mysql;

endpoint http:Client clientEndpoint {
    url: "http://b.content.wso2.com/sites/all/ballerina-day/sample.json"
};

endpoint mysql:Client testDB {
    host: "localhost",
    port: 3306,
    name: "baldaytestdb",
    username: "wso2",
    password: "wso2",
    poolOptions: { maximumPoolSize: 5 },
    dbOptions: { useSSL: false }
};


function main(string... args) {    
    io:println("Creating a table for book information if not exists:");
    var ret = testDB->update("CREATE TABLE IF NOT EXISTS books(title VARCHAR(255),
                          author VARCHAR(255), language VARCHAR(255),
                          year INT, PRIMARY KEY (title))");
    handleUpdate(ret, "Create Table `books`");

    io:println("------ Retrieve list of books ------");
    var response = clientEndpoint->get("");    
    match response {
        http:Response resp => {
            var msg = resp.getJsonPayload();
            match msg {
                json jsonPayload => {
                    io:println(jsonPayload);
                    foreach book in jsonPayload.store.books {
                        io:println("Book ", book);
                        sql:Parameter p1 = { sqlType: sql:TYPE_VARCHAR, value: book.title.toString() };
                        sql:Parameter p2 = { sqlType: sql:TYPE_VARCHAR, value: book.author.toString() };
                        sql:Parameter p3 = { sqlType: sql:TYPE_VARCHAR, value: book.language.toString() };
                        int year = check <int> book.year;
                        sql:Parameter p4 = { sqlType: sql:TYPE_INTEGER, value: year };
                        ret = testDB->update("INSERT INTO books(title, author, language, year) values (?, ?, ?, ?)",
                          p1, p2, p3, p4);
                        handleUpdate(ret, "Insert data to books table");
                    }
                }
                error err => {
                    log:printError(err.message, err = err);
                }
            }
        }
        error err => { log:printError(err.message, err = err); }
    }
}

function handleUpdate(int|error resp, string message) {
    match resp {
        int retInt => io:println(message + " status: " + retInt);
        error e => io:println(message + " failed: " + e.message);
    }
}