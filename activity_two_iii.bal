import ballerina/http;
import ballerina/io;
import ballerina/log;

endpoint http:Client clientEndpoint {
    url: "http://b.content.wso2.com/sites/all/ballerina-day/sample.json"
};

service<http:Service> hello bind { port: 9090 } {

    @http:ResourceConfig {
        methods: ["GET"]
    }
    sayHello(endpoint caller, http:Request req) {
        http:Response res = new;
        map<string> queryParams = req.getQueryParams();
        int req_published_year = check <int> queryParams.year;
        
        http:Response response = check clientEndpoint->get("");    
        json jsonPayload = check response.getJsonPayload();

        json[] bookPublishedAfterYearArr;
        int arrIndex = 0;
        foreach book in jsonPayload.store.books {
            int year = check <int> book.year;
            if (year > req_published_year) {
                bookPublishedAfterYearArr[arrIndex] = book;
                arrIndex++;
            }
        }        

        res.setPayload(untaint bookPublishedAfterYearArr);
        var respStatus = caller->respond(res);
        match (respStatus) {
            error e => log:printError("Error sending response", err = e);
            () => log:printInfo("Successfully responded to query based on year " + <string> req_published_year);
        }                           
    }
}