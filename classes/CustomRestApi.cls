/**
 * @description Custom REST API class to demonstrate the use of custom exceptions
 *              as an error handling mechanism that mimics the Salesforce
 *              Standard REST API response format
 * @author      Justus van den Berg (jfwberg@gmail.com)
 * @url         https://medium.com/@justusvandenberg/advanced-error-response-handling-in-custom-apex-rest-web-services-21c75af929c7
 * @test        System.debug(CustomRestApi.test());
 */
@RestResource(urlMapping='/custom-rest-api/*')
global with sharing class CustomRestApi {

    /**
     * CUSTOM EXCEPTION CLASSES
     */
    global class InputException      extends Exception {}
    global class AuthHeaderException extends Exception {}


    /**
     * @description Method that handles a POST request
     * @param  input The input to be processed
     */
    @HttpPost
    global static void handlePost(Integer input){

        try{
            // Validate that input is valid
            if(input < 1 || input > 10){
                throw new InputException('Input has to be between 1 and 10');
            }

            // Validate that the additional auth header exists
            if(!RestContext.request.headers.containsKey('CustomAuthHeader')){
                throw new AuthHeaderException('Custom Auth Header is Missing');
            }

            // A success response
            returnSuccess(200, input);

        }catch(InputException      e){
            returnError(400, 'INVALID_INPUT', e.getMessage());
        }catch(AuthHeaderException e){
            returnError(403, 'UNAUTHORIZED',  e.getMessage());
        }catch(Exception           e){
            returnError(500, 'APEX_ERROR',    e.getMessage());
        }
    }


    /**
     * @description Method to set the API response to a custom JSON object
     *              that serialized the response variable
     *
     * @param  statusCode The status code to respond with (i.e. 200, 201)
     */
    public static void returnSuccess(Integer statusCode, Object response){

        // Respond in JSON
        RestContext.response.headers.put('Content-Type', 'application/json');

        // Set the response status code
        RestContext.response.statusCode = statusCode;

        // Serialize the output JSON response
        RestContext.response.responseBody = Blob.valueOf(
          JSON.serializePretty(response)
        );
    }


    /**
     * @description Method to set the API response to a custom JSON error object
     *              that matches the standard Salesforce REST API Error response
     *
     * @param  statusCode The status code to respond with (i.e. 400, 402, 403, 404)
     * @param  errorCode  The error code to respond with  (i.e. INVALID_INPUT)
     * @param  message    The message to respond with
     */
    public static void returnError(Integer statusCode, String errorCode, String message){

        // Respond in JSON
        RestContext.response.headers.put('Content-Type', 'application/json');

        // Set the response status code
        RestContext.response.statusCode = statusCode;

        // Set the response header to be just like a Salesforce REST API header
        RestContext.response.responseBody = Blob.valueOf(
            JSON.serializePretty(new List<Map<String,String>>{
                new Map<String,String>{
                    'message'   => message,
                    'errorCode' => errorCode
                }
            }
        ));
    }


    /**
     * @description Method to test this class
     */
    public static String test(){

        // Create the request
        HttpRequest request = new HttpRequest();
        request.setEndpoint(URL.getOrgDomainUrl() + '/services/apexrest/custom-rest-api');
        request.setMethod('POST');
        request.setBody(JSON.serialize(
            new Map<String,Object>{
                'input' => 7
            })
        );

        // Set the request headers (adjust as needed)
        request.setHeader('Authorization',    'Bearer ' + UserInfo.getSessionId());
        request.setHeader('Content-Type',     'application/json');
        // request.setHeader('CustomAuthHeader', 'RemoveToForceError');

        return new Http().send(request).getBody();
    }
}