
var showDisableLayer = function() {
    $('<div id="loading" style="position:fixed; z-index: 2147483647; top:0; left:0; background-color: white; opacity:0.0;filter:alpha(opacity=0);"></div>').appendTo(document.body);
    $("#loading").height($(document).height());
    $("#loading").width($(document).width());
};

var hideDisableLayer = function() {
    $("#loading").remove();
};

$(document).ready(function() {
  $('#select-all-search-link').click(function(event){
    $("#loading").show();
    maximum = $('#max_items').data('show') ;
    total = $('#total_items').data('show') ;
    if (total > maximum) {
        alert('There are too many results here.  Please refine your search');
        $("#loading").hide();
        return true ;
    }
    var answer = $.rails.confirm("Are you sure you want to select all the items in this search only?", $(this)) ;
    if (!answer) {
        $("#loading").hide();
        /* event.preventDefault(); */
        return false ;
    }
    /* add an extra confirmation if there are a lot of records */
    if (total > 1000) {
        answer = $.rails.confirm("You've selected over 1,000 items. This may take some time. Consider refining your results.  Do you want to continue?", $(this)) ;
        if (!answer) {
            $("#loading").hide();
            /* event.preventDefault(); */
            return false ;
        }
    }
  });

  $('#remove-all-search-link').click(function(event){
    $("#loading").show();
    maximum = $('#max_items').data('show') ;
    total = $('#total_items').data('show') ;
    if (total > maximum) {
        alert('There are too many items here.  Please refine your search');
        $("#loading").hide();
        /* event.preventDefault(); */
        return true ;
    }
    var answer = $.rails.confirm("Are you sure you want to delete only all the items you've selected in this search?", $(this)) ;
    if (!answer) {
      $("#loading").hide();
      /* event.preventDefault(); */
      return false ;
    }
    /* add an extra confirmation if there are a lot of records */
    if (total > 1000) {
        answer = $.rails.confirm("Since there are over 1,000 items in this search, this deselection may take some time. So, consider refining your search. Do you wish to continue?", $(this)) ;
        if (!answer) {
          $("#loading").hide();
          /* event.preventDefault(); */
          return false ;
        }
    }
    // showDisableLayer() ; // Show the layer of glass
  });

  $('#select-page-link').click(function(event){
    /* testing... */
    // alert('Made it here!');
    $("#loading").show();
  });

  $('#remove-page-link').click(function(event){
      $("#loading").show();
  });

  $('#remove-all-link').click(function(event){
    $("#loading").show();
    total = $('#total_items').data('show')
    var answer = $.rails.confirm("Are you sure you want to remove ALL the items from this folder?", $(this)) ;
    if (!answer) {
      $("#loading").hide();
      /* event.preventDefault(); */
      return false ;
    }
    /* add an extra confirmation if there are a lot of records */
    if (total > 1000) {
      answer = $.rails.confirm("Since there are over 1,000 items in this folder, this removal may take some time. Do you wish to continue?", $(this)) ;
      if (!answer) {
        $("#loading").hide();
        /* event.preventDefault(); */
        return false ;
      }
    }
  });

  /* Ajax processing.... testing... */
  /*

  $('#remove-all-search-link').bind('ajax:complete', function(data, status, xhr) {
    // hideDisableLayer() ; // Hides the layer of glass
  });

  $('#remove-all-search-link').bind('ajax:success', function(data, status, xhr) {
      if (xhr.status != 0) {
              $("#loading").hide();
        $("#folder_number").text('999');
        $('.toggle_folder').attr('checked', false);
        FLASH message....

      }
  });

  */

});


