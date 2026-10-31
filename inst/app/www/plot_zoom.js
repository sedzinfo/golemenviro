// Full screen button of the charts of the Time Series and Daily Pattern tabs: shows a chart over the
// whole window, and back
function plotZoom(el) {
  el = $(el);
  var parent = el.parent().parent();
  if (el.attr('data-full_screen') === 'false') {
    parent.addClass('full-screen').trigger('resize').fadeOut().fadeIn();
    el.attr('data-full_screen', 'true');
  } else {
    parent.removeClass('full-screen').trigger('resize').fadeOut().fadeIn();
    el.attr('data-full_screen', 'false');
  }
  // plotly resizes its charts with the window
  window.dispatchEvent(new Event('resize'));
}

// Adds the button to the charts that do not have it yet
function addZoomButtons() {
  $('.plotly-full-screen .plotly.html-widget').filter(function() {
    return $(this).find('.plot-zoom').length === 0;
  }).append(`
    <div style='position: relative;'>
      <button onclick=plotZoom(this) class='plot-zoom' data-full_screen='false' title='Full Screen'>
        <i class='fa fa-expand-arrows-alt'></i>
      </button>
    </div>`);
}

// the chart is drawn after the page has loaded, and again for each sensor, server and period,
// so the charts are watched for new ones
$(function() {
  addZoomButtons();
  $('.plotly-full-screen').each(function() {
    new MutationObserver(addZoomButtons).observe(this, {childList: true, subtree: true});
  });
});
