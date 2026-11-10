// On phones the tabs are in the menu of the collapsed navbar (collapsible in app_ui()): the menu
// closes once a tab is chosen, so that the tab shows at once (Bootstrap leaves it open)
$(document).on('click', '.navbar-collapse.in a[data-toggle="tab"], .navbar-collapse.in a[data-bs-toggle="tab"]', function() {
  $(this).closest('.navbar-collapse').collapse('hide');
});
