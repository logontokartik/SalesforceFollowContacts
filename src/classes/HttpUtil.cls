/***************************************************************************
 Name 		: HttpUtil 
 Created By : Kartik Viswanadha (kartik.viswanadha@gmail.com)
 Created Date : 12/24/2012
 Description  : Util Class that performs the Http Requests to Twitter.
 
******************************************************************************/

public with sharing class HttpUtil {
	
	public static HttpResponse testResponse; // use it for testing
	private static String GENERIC_ERR = 'Error doing callout - Twitter API'; // Generic Error
	
	// Main method that performs the Http Call
	
	public static String performHttpRequest(String postBody,String endPoint,String method, String contentType, String auth){
		
		HttpRequest req = new HttpRequest();
		Http http		= new Http();
		
		req.setmethod(method);
		req.setHeader('Authorization',auth);
		
		if(contentType != null && contentType != '')
			req.setHeader('Content-Type',contentType);
		req.setEndpoint(endpoint);
		
		if((method == 'POST' || method == 'PUT') && (postBody != null))
			req.setBody(postBody);
		
		HttpResponse res = new HttpResponse();
		
		try {
			
			system.debug('------------------- HTTP Request --------------------------------- ');
			system.debug(req);
			system.debug(req.getBody());
			system.debug('------------------- END HTTP Request --------------------------------- ');
			
			if(!Test.isRunningTest())
				res = http.send(req);
			else		
				res = testResponse;
			
			system.debug('------------------- HTTP RESPONSE --------------------------------- ');
			system.debug(res.getBody());
			system.debug('------------------- END HTTP RESPONSE --------------------------------- ');	
				
			if(res.getStatusCode() > 300){
				throw new TwitterException(GENERIC_ERR + ' ' + res.getBody());
			}
				
		}catch(CalloutException e){
			throw new TwitterException(GENERIC_ERR + ' ' + e.getMessage());
		}
		
		return res.getBody(); // Return the body
		
	}
	

}