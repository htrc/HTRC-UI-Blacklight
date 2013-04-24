/**
 * Created with JetBrains RubyMine.
    * User: kirkhess
* Date: 4/4/13
* Time: 2:47 PM
* To change this template use File | Settings | File Templates.
    */
// Requires jQuery!
(function($) {

    $(document).ready(function(){
        $.ajax({
            url: "http://jira.htrc.illinois.edu/s/en_USgcg1on-418945332/853/3/1.2.9/_/download/batch/com.atlassian.jira.collector.plugin.jira-issue-collector-plugin:issuecollector-embededjs/com.atlassian.jira.collector.plugin.jira-issue-collector-plugin:issuecollector-embededjs.js?collectorId=57e93b9a",
            type: "get",
            cache: true,
            dataType: "script"
        });

    });
})(jQuery);