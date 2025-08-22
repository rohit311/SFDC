trigger AccountMergeTrigger on Account (after delete) {
	Map<Id, Account> masterRecordsToUpdate = new Map<Id, Account>();
    Set<Id> masterRecordIds = new Set<Id>();
    List<String> fieldNames = new List<String>();
    
    
    if (Trigger.isAfter && Trigger.isDelete) {
        
        for (Account losingAcc: Trigger.old) {
            if (losingAcc.MasterRecordId != null) {
                masterRecordIds.add(losingAcc.MasterRecordId);
            }
        }
        
		if (!masterRecordIds.isEmpty()) {
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap();
            
            for (Schema.FieldSetMember f : SObjectType.Account.FieldSets.Merge_Backfill_Fields.getFields()) {
                fieldNames.add(f.getFieldPath());
            }
            
            // Build dynamic SOQL to query master records
            String soql = 'SELECT Id, ' + String.join(fieldNames, ',') +
                          ' FROM Account WHERE Id IN :masterRecordIds';
            List<Account> masterRecords = Database.query(soql);
            
        	masterRecordsToUpdate = new Map<Id, Account>(masterRecords);
        }
        
        for (Account acc : Trigger.old) {
            
            if (acc.MasterRecordId == null) {
                continue;
            }
            
            Account master = masterRecordsToUpdate.get(acc.MasterRecordId);
            Boolean changed = false;

            // Backfill blanks
            for (String fieldName : fieldNames) {
                Object masterVal = master.get(fieldName);
                Object losingVal = acc.get(fieldName);

                if ((masterVal == null || String.valueOf(masterVal).trim() == '') && 
                    (losingVal != null && String.valueOf(losingVal).trim() != '')) {
                    master.put(fieldName, losingVal);
                    changed = true;
                }
            }
            
            if (changed) {
        		masterRecordsToUpdate.put(master.Id, master);
    		}
        }
        
        if (!masterRecordsToUpdate.isEmpty()) {
            // Update this in async process or in before update context
            // update masterRecordsToUpdate.values();
        }
    }
}
