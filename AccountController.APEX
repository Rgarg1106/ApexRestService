@RestResource(urlMapping='/v2/accounts/*')

global with sharing class AccountsController {
    
    @HttpGet
    global static Account doGet() {

        RestRequest req = RestContext.request;

        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        Account result = [SELECT Id, Name, Phone, Website, AccountNumber FROM Account WHERE AccountNumber =: accountId];
        
        return result;
    }
        
    @HttpPost
    global static AccountDetailWrapper doPost(String Name, String Phone, String Website, String AccountNumber) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        AccountDetailWrapper response = new AccountDetailWrapper();       

        Account acct = new Account();

        acct.Name = Name;
        acct.Phone = Phone;
        acct.Website = Website;
        acct.AccountNumber = AccountNumber;
        
        insert acct; 
        
        response.Status = 'Success';
        response.Message = 'Your Account was created successfully.';
        
        return response;
    }
    
    @HttpPut
    global static AccountDetailWrapper doPut()
    {        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
		AccountDetailWrapper response = new AccountDetailWrapper();
        try
        {              
            Account acc = (Account)json.deserialize(RestContext.request.requestBody.toString(),Account.class);
            Account acct = [SELECT Id, Name, Phone, Website, AccountNumber FROM Account WHERE Id = :acc.Id];
            
            If(acct != null)
            {
                acct.Name = acc.Name;
                acct.AccountNumber = acc.AccountNumber;
                acct.Phone = acc.Phone;
                acct.Website = acc.Website;
                
                update acct;

        		response.UpdatedId = acct.Id;         
        		response.UpdatedName = acct.Name;
        		response.UpdatedAccNumber = acct.AccountNumber;
        		response.UpdatedPhone = acct.Phone; 
        		response.UpdatedWebsite = acct.Website;
        		response.Status =  'Success';	
        		response.Message =  'Account hasbeen update successfully'; 
            }
            else
            {
               res.StatusCode = 404;
               response.Status = 'Error';
               response.Message = 'No Record Found';
            }
        }
        catch(Exception exc) {
            res.StatusCode = 500;
            response.Status = 'Error';
            response.Message = 'Your request failed with the following error: ' + exc.getMessage();
        }       
                
        return response;
    }
    
    @HttpDelete
    global static AccountDetailWrapper doDelete()
    {               
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
		AccountDetailWrapper response = new AccountDetailWrapper();
        try
        {   
            String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);        
            Account acct = [SELECT Id, Name, Phone, Website, AccountNumber FROM Account WHERE Id = :accountId];
            
            If(acct != null)
            {
               delete acct;
               response.Status = 'Success';
               response.Message = 'Account Deleted';
            }
            else
            {
               res.StatusCode = 404;
               response.Status = 'Error';
               response.Message = 'No Record Found';
            }
        }
        catch(Exception exc) {
            res.StatusCode = 500;
            response.Status = 'Error';
            response.Message = 'Your request failed with the following error: ' + exc.getMessage();
        }       
                
        return response;
    }

    global class AccountDetailWrapper{
         public String UpdatedId;
         public String UpdatedName;
       	 public String UpdatedAccNumber;
       	 public String UpdatedPhone;
         public String UpdatedWebsite;
         public String Status;
         public String Message;
    }
}