import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/sql;
import ballerina/mysql;

endpoint mysql:Client testDB {
    host: "localhost",
    port: 3306,
    name: "baldaytestdb",
    username: "wso2",
    password: "wso2",
    poolOptions: { maximumPoolSize: 5 },
    dbOptions: { useSSL: false }
};

service<http:Service> hello bind { port: 9090 } {

    @http:ResourceConfig {
        methods: ["GET"]
    }
    sayHello(endpoint caller, http:Request req) {
        http:Response res = new;
        map<string> queryParams = req.getQueryParams();
        int req_published_year = check <int> queryParams.year;
        
        sql:Parameter p1 = { sqlType: sql:TYPE_INTEGER, value: req_published_year };
        var selectRet = testDB->select("SELECT * FROM books where year > ?", Book, p1);
        json[] bookPublishedAfterYearArr;
        int arrIndex = 0;

        match selectRet {
            table tableReturned => {
                json jsonConversionRet = check <json>tableReturned;
                res.setPayload(untaint jsonConversionRet);
            }
            error e => {
                string errMessage = "Select data from student table failed: " + e.message;
                res.setPayload(untaint errMessage);
            }
        } 

        var respStatus = caller->respond(res);
        match (respStatus) {
            error e => log:printError("Error sending response", err = e);
            () => log:printInfo("Successfully responded to query based on year " + <string> req_published_year);
        }                           
    }
}

type Book record {
    string title;
    string author;
    string language;
    int year;
};