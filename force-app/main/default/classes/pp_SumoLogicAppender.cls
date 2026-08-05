/**
 * Created on 26/06/2024.
 */

public with sharing class pp_SumoLogicAppender extends pp_Log.DefaultAsyncAppender {

    public override void flush() {
        String sourceUrl = this.getSourceUrl();
        if (String.isEmpty(sourceUrl)) return;

        String logsInString = '';
        for (pp_Log.Context ctx : this.contexts) {
            if (ctx.message != null) logsInString += this.getPrefix(ctx, this.getPrefixPattern()) + ctx.message + '\n';
            if (ctx.error != null) logsInString += this.getPrefix(ctx, this.getPrefixPattern()) + ctx.error + '\n';
        }
        logsInString = logsInString.removeEnd('\n');
        pp_R.debug.run('LOGS:', logsInString);
        if (String.isNotEmpty(logsInString)) {
            new pp_RestExplorer(this.getSourceUrl())
                    .doPost()
                    .setBody(logsInString)
                    .getResult();
        }
    }

    private String getPrefixPattern() {
        if (this.options != null && this.options.containsKey('prefixPattern')) {
            return String.valueOf(this.options.get('prefixPattern'));
        }

        return '%date [%logger]|%level|%class.%method|Line:%line,Column:%column - ';
    }

    private String getSourceUrl() {
        if (this.options != null && this.options.containsKey('sourceUrl')) {
            return String.valueOf(this.options.get('sourceUrl'));
        }

        return null;
    }
}