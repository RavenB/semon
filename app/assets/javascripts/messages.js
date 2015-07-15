$(function () {
  $('.input-group.date').datetimepicker({
    locale: 'de',
    allowInputToggle: true,
    showClose: true
  });

  $('input[type=radio]').iCheck({
    checkboxClass: 'icheckbox_square-blue',
    radioClass: 'iradio_square-blue'
  });

  if($('.message-origin').length) {
    $('.message-origin .btn').click(function () {
      // check radio button below social brand icon
      $(this).next().iCheck('check');
    });

    $('.message-origin input').on('ifChecked', function () {
      // open details form elements for clicked social media platform
      var choosenPlatform = $(this).val();
      console.log(choosenPlatform);
      $('.message-details ').hide();
      $('.' + choosenPlatform + '-details').slideDown();
    });

    if($('.message-origin .field_with_errors').length) {
      $('.form-m-origin').addClass('message-origin-with-errors');
    }
  }

  if($('.message-sentiment').length) {
    $('.message-sentiment .btn').click(function () {
      // check radio button below sentiment icon
      $(this).next().iCheck('check');
    });
  }
});
