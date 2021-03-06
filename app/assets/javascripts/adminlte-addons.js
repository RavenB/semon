$(function () {
  hoverCampaignIndexAction();
});

/*
 * on campaign index page:
 * set the hover style of the dashboard footer action also
 * on hovering the box, not only with mouse enter on footer
 */
function hoverCampaignIndexAction() {
  if($('.small-box .inner').length) {
    $('.small-box .inner, .small-box .icon').hover(
      function () {
        $(this).siblings('.small-box-footer').addClass('small-box-footer-hover');
      },
      function () {
        $(this).siblings('.small-box-footer').removeClass('small-box-footer-hover');
      }
    );
  }
}
