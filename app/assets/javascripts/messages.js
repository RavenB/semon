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
      $(this).next().iCheck('check');
    });

    if($('.message-origin .field_with_errors').length) {
      $('.form-m-origin').addClass('message-origin-with-errors');
    }
  }
});
