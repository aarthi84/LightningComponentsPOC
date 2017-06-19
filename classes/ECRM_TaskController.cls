/* May 2015: This My Tasks lightning component is created for Salesforce Lab competition by Kashi Ahmed http://www.kashifahmed.com */
/* July 2016: Updated after Summer 16 rel to fix bugs -  Kashi Ahmed http://www.kashifahmed.com */
public with sharing class ECRM_TaskController  {
    @AuraEnabled
     public static List<Task> MyTask() {
         if (!Schema.sObjectType.Task.fields.subject.isAccessible()){

          return NULL;

         }
        return [SELECT Id,ActivityDate,Priority,Status,Subject,What.Name, Who.Name FROM Task WHERE OwnerId = :UserInfo.getUserId() and IsClosed=false  limit 100 ];
    }
    
    @AuraEnabled
     public static List<Task> TaskByFilter(string fltr) {
        
         if (!Schema.sObjectType.Task.fields.subject.isAccessible()){

          return NULL;

         }
         List <Task> taskList = new List <Task> (); 
       
         string query='',whereClause='';
         if(fltr =='AllOpen'){
            whereClause='';
         
         }else if( fltr ==  'ThisMonth'){
             whereClause='and ActivityDate = THIS_MONTH';   
         }
         else if( fltr ==  'Overdue'){
             whereClause='and ActivityDate < TODAY';   
         }
         else if(fltr == 'Today'){
             whereClause='and ActivityDate = TODAY';   
         
         }
         else if(fltr == 'TodayOverdue'){
             whereClause='and ActivityDate <= TODAY';   
         
         }
         else if(fltr == 'Tomorrow'){
             whereClause='and ActivityDate = TOMORROW';   
         
         }
         else if(fltr == 'NextSevenDays'){
             whereClause='and (ActivityDate = NEXT_N_DAYS:7 OR ActivityDate = TODAY)';   
         
         }else {
             
             whereClause='and ActivityDate <= NEXT_N_DAYS:7';  
         }
         
         
         query = 'SELECT Id,ActivityDate,Priority,Status,Subject,What.Name,Who.Name FROM Task  WHERE (ownerId = \'' + UserInfo.getUserID() + '\' and IsClosed=false ) '+whereClause+' limit 100'; 
         taskList = Database.query(query);      
         return taskList;
    }
}