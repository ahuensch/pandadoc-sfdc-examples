// Every JSON builder should be extended from pandadoc.JsonBuilder class. Also this class should be global.
global with sharing class CustomObjectJsonBuilder extends pandadoc.JsonBuilder {

    private static final Map<String, Set<String>> RELATED_OBJECTS;

    static {
        //sObjectName used in lowercase
        String sObjectName = 'Custom_Object_Child__c'.toLowerCase();

        pandadoc.Item.ItemSettings setting = pandadoc.Item.PRICING_ITEM_SETTINGS_MAP.get(sObjectName);
        //Here we should use Map where key is a SOQL relationship name and value is a Set of fields for select
        RELATED_OBJECTS = new Map<String, Set<String>> {
            'Custom_Object_Childs__r' => setting.getSoqlFields()
        };
    }
    // Constructor without parameters is required
    global CustomObjectJsonBuilder() {
        //now we used second param too
        super(PD_Custom_Object__c.getSObjectType(), RELATED_OBJECTS, null);
    }
    // Here we forming PricingItems
    global override pandadoc.Item[] getItems(sObject record) {
        sObject[] sObjects = record.getSObjects('Custom_Object_Childs__r');

        //forms PricingItems
        pandadoc.Item[] result = new pandadoc.Item[]{};
        for (sObject rawObject: sObjects) {
            pandadoc.Item newItem = pandadoc.Item.sObjectToItem(rawObject);
            result.add(newItem);
        }
        return result;
    }
    // Here we forming Recipients
    global override pandadoc.Recipient[] getRecipients(sObject record) {
        //sObjectName used in lowercase
        String sObjectName = 'Contact'.toLowerCase();

        //now we have mapping setting for Recipient
        pandadoc.Recipient.RecipientSettings setting = pandadoc.Recipient.RECIPIENT_SETTINGS_MAP.get(sObjectName);
        //here we forming list with SOQL fields.
        String[] childFieldsList = new List<String>(setting.getSoqlFields());
        String childFieldsStr = String.join(childFieldsList, ',');

        String query = String.format(
            'SELECT {0} FROM Contact WHERE Custom_Object__c = \'\'{1}\'\'',
            new String[] {childFieldsStr, record.Id}
        );

        //forms Recipients
        sObject[] sObjects = Database.query(query);
        pandadoc.Recipient[] result = new pandadoc.Recipient[]{};
        for (sObject rawObject: sObjects) {
            pandadoc.Recipient newRecipient = pandadoc.Recipient.sObjectToRecipient(rawObject);
            result.add(newRecipient);
        }
        return result;

    }
}