/* 
   Implements HTRC "select all" feature
*/
(function($) {

      $("#loading").hide();

      function select_all(url) {
          $("#loading").show();
          $.ajax({
              url: url,
              type: 'GET',
              error: function() {
                  alert("Error in 'select all' request");
                  $("#loading").hide();
              },
              success: function(data, status, xhr) {
                  if (xhr.status != 0) {
                      $("#loading").hide();
                      $('#selectall').attr('checked', checked);
                      $('.toggle_folder').attr('checked', checked);
                      $("#folder_number").text(data.count);
                  } else {
                     $("#loading").hide();
                     alert("Error in response to 'select all' request");
                  }
              }
          });
     };

     //select all toggle
     Blacklight.do_select_all_behavior = function() {
 

         $("#selectall").click(function () {
 
              var checked = this.checked;

              var url = '/select_all';
              if (!checked) {
                  url = '/select_all/clear';
              }

              var total = $("#select_all_total").val();
 
              var cancel = false;
              if (checked) {
                 if (total > 100000) {
                    alert("Too many results. Please narrow your search.");
                    return;
                 }
                 else if (total > 10000) {
                    var $dialog = $('<div></div>')
                    .html("You've selected over 10,000 items. This may take some time. Consider refinining your results.")
                    .dialog({
                        autoOpen: false,
                        modal: true,
                        buttons : {
                           "OK" : function() {
                               cancel = false;
                               $('#selectall').attr('checked', true);
                               $(this).dialog("close");
                               select_all(url);
                            },
                            "Cancel" : function() {
                               $('#selectall').attr('checked', false);
                               $(this).dialog("close");
                               return false;
                            }
                        }
                     });
                     $dialog.dialog("open");
                 } else {
                   return select_all(url);
                 }
             } else {
                 return select_all(url);
             }
         });          
     };

     $(document).ready(function() {
        Blacklight.do_select_all_behavior();
     });
})(jQuery);
