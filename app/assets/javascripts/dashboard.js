var secondTabOpended, thirdTabOpended = 0;

function drawDashboardCharts() {
  messagesInPeriod();
  messagesAtTime();
  origin();
  sentiment();

  $('a[data-toggle=tab]').on('shown.bs.tab', function (e) {
    if ($(e.target).attr('href') == '#tab_2' && !secondTabOpended) {
      topTags();
      wordCloud();
      wordTree();
      secondTabOpended = 1;
    } else if ($(e.target).attr('href') == '#tab_3' && !thirdTabOpended) {
      topAuthors();
      authorGenders();
      thirdTabOpended = 1;
    }
  });

  $('#loading-spinner').click(function (e) {
    e.preventDefault();
  });
}
