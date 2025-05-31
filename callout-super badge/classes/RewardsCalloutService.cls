public class RewardsCalloutService{

    public static Integer submitUsersForRewardCallout(String jsonBody) {
        //Set Endpoint from Named Credential
        HttpRequest req = new HttpRequest();
        req.setEndPoint('callout:IntegrationSB__BalancedLiving/rewards');
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(jsonBody);

        //Make HTTP Callout
        Http http = new Http();
        HTTPResponse res = http.send(req);


        //Update to return response status code
        return res.getStatusCode();
    }
}