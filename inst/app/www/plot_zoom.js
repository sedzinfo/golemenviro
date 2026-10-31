// Full screen button of the charts of the Time Series and Daily Pattern tabs: shows a chart over the
// whole window, and back. The chart is hidden at once, redrawn by plotly for its new size, and only
// then faded in, so that it is never seen at the wrong size, which made it flicker
function plotZoom(el) {
  el = $(el);
  var chart = el.parent().parent();
  var graph = chart[0];
  var full = el.attr('data-full_screen') === 'false';
  chart.css({transition: 'none', opacity: 0});
  chart.toggleClass('full-screen', full);
  el.attr('data-full_screen', full ? 'true' : 'false');
  var shown = false;
  var show = function() {
    if (shown) return;
    shown = true;
    if (graph.removeListener) graph.removeListener('plotly_relayout', show);
    chart.css({transition: 'opacity 0.15s ease-in', opacity: 1});
  };
  // plotly redraws the chart for the new size of the window, and then says so
  if (graph.on) graph.on('plotly_relayout', show);
  // and when the size has not changed, nothing is redrawn
  setTimeout(show, 600);
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
