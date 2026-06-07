@isTest
global class MockBillingHttpResponse implements HttpCalloutMock {
    private Integer statusCode;
    
    global MockBillingHttpResponse(Integer statusCode) {
        this.statusCode = statusCode;
    }
    
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        
        if (statusCode == 200) {
            response.setBody('{"status":"success","message":"Charge created"}');
        } else {
            response.setBody('{"status":"error","message":"Payment failed"}');
        }
        
        return response;
    }
}