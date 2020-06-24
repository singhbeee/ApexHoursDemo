public class ApexHoursDemo {
    
    public void handleBeforeInsert(List<Sale__C> newSales){
        addErrorForUnauthorizedAuditChanges(newSales, null);
        setCategory(newSales);
    }
    
    public void handleBeforeUpdate(List<Sale__C> newSales, 
                                   Map<Id,Sale__C> oldMap){
        addErrorForUnauthorizedAuditChanges(newSales, oldMap);
        handleAuditFieldChanges(newSales, oldMap);
        setCategory(newSales);
    }
    
    private void setCategory(List<Sale__C> newSales){
        for(Sale__c s : newSales) {
            s.Sale_Category__c = SaleBusinessRuleManager.getCategory(s.Amount__c);
        }
    }
    
    public void handleAuditFieldChanges(List<Sale__C> newSales, 
                                        Map<Id,Sale__C> oldMap){
        for(Sale__c s : newSales) {
            if(s.Audit_Completed__c == true){
                setAuditFields(s);
            }
            else { 
                clearAuditFields(s);
            }
        }    
    }

    private void addErrorForUnauthorizedAuditChanges(List<Sale__C> newSales, 
                                                     Map<Id,Sale__C> oldMap){
        if(!SaleBusinessRuleManager.auditAllowed()){
            for(Sale__c s : newSales) {
                if (auditBoxChanged(s, oldMap)){
                    s.addError(SaleBusinessRuleManager.NO_PERMISSION_TO_AUDIT);
                }
            }
        }
    }
    
    private Boolean auditBoxChanged(Sale__C newRecord, Map<Id,Sale__C> oldMap){
        Boolean changed = false;
        
        if(oldMap != null){
            Sale__c oldRecord = oldMap.get(newRecord.Id);
            changed = oldRecord.Audit_Completed__c != newRecord.Audit_Completed__c;
        }
        else if(newRecord.Audit_Completed__c){
            changed = true;
        }
        return changed;
    }
    
    private void clearAuditFields(Sale__c s){
        s.Audit_Completed_Time__c = null;
        s.Auditor__c = null;
    }
    
    
    private void setAuditFields(Sale__c s){
        s.Audit_Completed_Time__c = system.now();
        s.Auditor__c = UserInfo.getUserId();
    }
}
