import ballerina/http;
import ballerina/io;
import ballerina/log;

endpoint http:Client clientEndpoint {
    url: "http://b.content.wso2.com/sites/all/ballerina-day/sample.json"
};


function main(string... args) {    
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
