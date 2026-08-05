/**
 * Sends an email using a specified Email Template and parameters.
 *
 * The EmailRequest object contains the following properties:
 * - templateName: The DeveloperName of the EmailTemplate to use.
 * - fromEmailAddress: Optional OrgWideEmailAddress to use as the sender.
 * - whatId: Optional Id of a related record to link the email to.
 * - whoId: Id of the recipient. Can be a User, Lead, or Contact Id.
 * - saveAsActivity: Optional boolean to save email as an Activity on the recipient. Default true if recipient is Lead or Contact.
 * - treatTargetObjectAsRecipient: Optional boolean to treat the whoId as a recipient instead of just related record.
 * - toAddresses: Optional list of email addresses to add in the To field.
 * - toCCAddresses: Optional list of email addresses to add in the CC field.
 * - toBCCAddresses: Optional list of email addresses to add in the BCC field.
 *
 * The method loops through the list of EmailRequest objects and sends an email for each one using the Messaging.SingleEmailMessage class.
*/
public class pp_SendEmailTemplateInvocable {
    @InvocableMethod(Label='Send Email using Template Name')
    public static void sendEmail(List<EmailRequest> requests) {
        try {
            EmailTemplate templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :requests[0].templateName];
            Id owaId = null;
            if (String.isNotBlank(requests[0].fromEmailAddress)){
                OrgWideEmailAddress owa = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE Address = :requests[0].fromEmailAddress LIMIT 1];
                owaId = owa.Id;
            }

            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            for (EmailRequest request : requests) {
                Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                msg.setTemplateId(templateId.Id);

                if (owaId != null){
                    msg.setOrgWideEmailAddressId(owaId);
                }

                if (request.whatId != null && request.whatId.length() > 0) {
                    msg.setWhatId(request.whatId);
                }

                if (request.whoId != null) {
                    msg.setTargetObjectId(request.whoId);

                    if (msg.getTargetObjectId().getSobjectType() == Lead.SObjectType
                            || msg.getTargetObjectId().getSobjectType() == Contact.SObjectType) {
                        if (request.saveAsActivity != null) {
                            msg.setSaveAsActivity(request.saveAsActivity);
                        } else {
                            msg.setSaveAsActivity(true);
                        }
                    }

                    if (request.treatTargetObjectAsRecipient != null) {
                        msg.setTreatTargetObjectAsRecipient(request.treatTargetObjectAsRecipient);
                    }

                    setAddresses(msg, request.toAddresses, request.toCCAddresses, request.toBCCAddresses);
                    messages.add(msg);
                } else if (String.isNotBlank(request.toAddresses)) {
                    for (String emailAddress : request.toAddresses.split(';')) {
                        Messaging.SingleEmailMessage mailToSingleAddress = cloneSingleEmailMessage(msg);
                        setAddresses(mailToSingleAddress, emailAddress, request.toCCAddresses, request.toBCCAddresses);
                        messages.add(mailToSingleAddress);
                    }
                }
            }

            if (!messages.isEmpty()) {
                System.debug(Messaging.sendEmail(messages, false));
            }
        } catch (Exception ex){
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }
    }

    private static void setAddresses(Messaging.SingleEmailMessage mail, String toAddresses, String toCCAddresses, String toBCCAddresses) {
        if (String.isNotBlank(toAddresses)) {
            mail.setToAddresses(toAddresses.split(';'));
        }
        if (String.isNotBlank(toCCAddresses)) {
            mail.setCcAddresses(toCCAddresses.split(';'));
        }
        if (String.isNotBlank(toBCCAddresses)) {
            mail.setBccAddresses(toBCCAddresses.split(';'));
        }
    }

    private static Messaging.SingleEmailMessage cloneSingleEmailMessage(Messaging.SingleEmailMessage original) {
        Messaging.SingleEmailMessage clonedMessage = new Messaging.SingleEmailMessage();
        clonedMessage.setTemplateId(original.getTemplateId());
        if (original.getOrgWideEmailAddressId() != null) clonedMessage.setOrgWideEmailAddressId(original.getOrgWideEmailAddressId());
        if (original.getWhatId() != null) clonedMessage.setWhatId(original.getWhatId());
        return clonedMessage;
    }


    public class EmailRequest {
        @InvocableVariable(Label='From Email Address' Description='Org-Wide email address. NOTE: Please make sure it\'s verified!')
        public String fromEmailAddress;

        @InvocableVariable(Label='To Email Addresses' Description='A list of email addresses. NOTE: At least "Send To SObject ID" or "To Email Addresses" should be populated.')
        public String toAddresses;

        @InvocableVariable(Label='To CC Email Addresses' Description='A list of CC email addresses.')
        public String toCcAddresses;

        @InvocableVariable(Label='To BCC Email Addresses' Description='A list of BCC email addresses.')
        public String toBccAddresses;

        @InvocableVariable(Label='Email Template Developer Name' Required=true Description='You can use the following SOQL to find the DeveloperName: SELECT Id, Name, DeveloperName FROM EmailTemplate WHERE Id = "email template id"')
        public String templateName;

        @InvocableVariable(Label='Send To SObject ID' Description='Lead/Contact/User ID who should receive the email. NOTE: At least "Send To SObject ID" or "To Email Addresses" should be populated.')
        public String whoId;

        @InvocableVariable(Label='Regarding SObject ID' Description='To what record should the email be linked to')
        public String whatId;

        @InvocableVariable(Label='Save as Activity' Description='This is TRUE by default for Leads and Contacts. Ignored for other SObjects.')
        public Boolean saveAsActivity;

        @InvocableVariable(Label='Treat Target Object As Recipient' Description='This is TRUE by default')
        public Boolean treatTargetObjectAsRecipient;
    }
}