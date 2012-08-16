/* 
   Implements HTRC "select all" feature
*/
(function($) {
     //select all toggle
     Blacklight.do_select_all_behavior = function() {

         $("#selectall").click(function () {
 
              var checked = this.checked;

              var url = '/select_all';
              if (!checked) {
                  url = '/select_all/clear';
              }
              $.ajax({
                  url: url,
                  type: 'GET',
                  error: function() {
                      alert("Error in 'select all' request");
                  },
                  success: function(data, status, xhr) {
                      if (xhr.status != 0) {
                          $('#selectall').attr('checked', checked);
                          $('.toggle_folder').attr('checked', checked);
                          $("#folder_number").text(data.count);
                      } else {
                         alert("Error in response to 'select all' request");
                      }
                  }
              });
         });          
     };

     $(document).ready(function() {
     Blacklight.do_select_all_behavior();
  });
})(jQuery);
