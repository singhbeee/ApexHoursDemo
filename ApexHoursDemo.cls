public class ApexHoursDemo {
    
    Id currentProfileId= userinfo.getProfileId();
    List<String> allowedProfileNames = new List<String> { 'System Administrator'};
        
        public  void handleBeforeUpdate(List<Sale__C> newSales, Map<Id,Sale__C> oldMap){
            
            // update audit fields
            for(Sale__c s : newSales) {
                if(oldMap != null){ // this is an update
                    
                    Sale__c oldRec = oldMap.get(s.id); 
                    
                    if( oldRec.Audit_Completed__c == true && s.Audit_Completed__c == false) {
                        boolean canAudit = false;
                        Id currentProfileId= userinfo.getProfileId();
                        
                        Profile curUserProfile = [Select Id,Name from Profile where Id = :currentProfileId LIMIT 1];
                        
                        for(String pname: allowedProfileNames){
                            if(curUserProfile.name == pname){
                                canAudit = true;
                            }
                        }
                        if(!canAudit){
                            s.addError('Audit Box cannot be unchecked once checked');
                        }
                    }
                    else if(s.Audit_Completed__c == true){
                        s.Audit_Completed_Time__c = system.now();
                        s.Auditor__c = UserInfo.getUserId();
                    }
                    else { // an admin is unchecking the checkbox
                        system.debug('an admin is unchecking the sales audit checkbox');
                        s.Audit_Completed_Time__c = null;
                        s.Auditor__c = null;
                    }
                } // insert - there is no oldmap
                else if(s.Audit_Completed__c == true){
                    s.Audit_Completed_Time__c = system.now();
                    s.Auditor__c = UserInfo.getUserId();
                }
            } 
            
            for(Sale__c s : newSales) {
                
                String category;
                if(s.Amount__c < 1000){
                    s.Sale_Category__c  = 'Small';
                }
                else if( s.Amount__c < 10000){
                    s.Sale_Category__c = 'Medium';
                }
                else if(s.Amount__c < 50000){
                    s.Sale_Category__c = 'Large';
                }
                else if(s.Amount__c > 50000){
                    s.Sale_Category__c = 'Extra Large';
                }
            }
        }
    
    public  void handleBeforeInsert(List<Sale__C> newSales){
        
        for(Sale__c s : newSales) {
            
            String category;
            if(s.Amount__c < 1000){
                s.Sale_Category__c  = 'Small';
            }
            else if( s.Amount__c < 10000){
                s.Sale_Category__c = 'Medium';
            }
            else if(s.Amount__c < 50000){
                s.Sale_Category__c = 'Large';
            }
            else if(s.Amount__c > 50000){
                s.Sale_Category__c = 'Extra Large';
            }
        }
    }
}
