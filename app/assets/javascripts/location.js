$( function() {
  $("#projects_select").on("change", function() {
    var clickedOption = $(this);
    var val = clickedOption.val();
    suffix = val.length==0 ? '' : val + '/edit';
    location.href = location.protocol + "//" + location.hostname+":"+location.port+"/projects/" + suffix;
  });
});





