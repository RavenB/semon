var firstTabOpened, secondTabOpened, thirdTabOpened = 0;
var tabInitialized = 0;

function drawDashboardCharts() {
  if ($('a[href=#tab_1]').parent().hasClass('active')) {
    drawFirstTabCharts();
  } else if($('a[href=#tab_2]').parent().hasClass('active')) {
    drawSecondTabCharts();
  } else if($('a[href=#tab_3]').parent().hasClass('active')) {
    drawThirdTabCharts();
  }

  initTabClicks();

  $('#loading-spinner').click(function (e) {
    e.preventDefault();
  });
}

function initTabClicks() {
  if (!tabInitialized) {
    // bind tab clicks to draw charts
    $('a[data-toggle=tab]').on('shown.bs.tab', function (e) {
      if ($(e.target).attr('href') == '#tab_1' && !firstTabOpened) {
        drawFirstTabCharts();
      } else if ($(e.target).attr('href') == '#tab_2' && !secondTabOpened) {
        drawSecondTabCharts();
      } else if ($(e.target).attr('href') == '#tab_3' && !thirdTabOpened) {
        drawThirdTabCharts();
      }
    });
    tabInitialized = 1;
  }
}

function drawFirstTabCharts() {
  messagesInPeriod();
  messagesAtTime();
  origin();
  sentiment();
  firstTabOpened = 1;
}

function drawSecondTabCharts() {
  topTags();
  wordCloud();
  wordTree();
  secondTabOpened = 1;
}

function drawThirdTabCharts() {
  topAuthors();
  authorGenders();
  thirdTabOpened = 1;
}
