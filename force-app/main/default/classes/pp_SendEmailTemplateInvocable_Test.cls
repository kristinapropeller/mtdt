/**
 * Created on 15/11/2023.
 */

@IsTest
private class pp_SendEmailTemplateInvocable_Test {
    @IsTest
    static void testSendingWithWhoId() {
        Contact contactVar = new Contact(
                FirstName = 'qwe',
                LastName = 'qwe',
                Email = 'qwe@qwe.qw'
        );
        insert contactVar;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            EmailTemplate testTemplate = new EmailTemplate(
                    Name = 'Test template',
                    DeveloperName = 'name',
                    TemplateType = 'text',
                    FolderId = UserInfo.getUserId()
            );
            insert testTemplate;

            pp_SendEmailTemplateInvocable.EmailRequest request = new pp_SendEmailTemplateInvocable.EmailRequest();
            request.templateName = 'name';
            request.whoId = contactVar.Id;
            request.whatId = UserInfo.getUserId();
            pp_SendEmailTemplateInvocable.sendEmail(new List<pp_SendEmailTemplateInvocable.EmailRequest>{
                    request
            });
        }

    }

    @IsTest
    static void testSendingToAddressesOnly() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            EmailTemplate testTemplate = new EmailTemplate(
                    Name = 'Test template',
                    DeveloperName = 'name',
                    TemplateType = 'text',
                    FolderId = UserInfo.getUserId()
            );
            insert testTemplate;

            pp_SendEmailTemplateInvocable.EmailRequest request = new pp_SendEmailTemplateInvocable.EmailRequest();
            request.templateName = 'name';
            request.toAddresses = 'qwe@qwe.qw';
            request.toCcAddresses = 'qweCC@qwe.qw';
            request.toBccAddresses = 'qwBCCe@qwe.qw';
            request.whatId = UserInfo.getUserId();
            pp_SendEmailTemplateInvocable.sendEmail(new List<pp_SendEmailTemplateInvocable.EmailRequest>{
                    request
            });
        }

    }
}