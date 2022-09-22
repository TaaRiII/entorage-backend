var sweetAlertConfirmConfig = {
  title: 'Are you sure?',
  type: 'warning',
  showCancelButton: true,
  confirmButtonColor: '#e53935',
  confirmButtonText: 'Delete'
};

function setLabel(html){
  id = $(html).attr('id');
  var label = $('label[for="' + id + '"]');
  enable = $('#'+id).data('label');
  if (enable != "yes"){
    if(html.checked){
      label.html('Yes');
    }else{
      label.html('No');
    }
  }
}
$(function() {
  //$(".all_tags").tagit();
  $('.datepicker').datepicker({
    autoclose: true,
    format: "mm/dd/yyyy",
    todayHighlight: true
  });
  Breakpoints();
  var Site = window.Site;
  Site.run();
  // datatables
  $('.dtable').dataTable({
    responsive: true,
    language: {
      "sSearchPlaceholder": "Search..",
      "lengthMenu": "_MENU_",
      "search": "_INPUT_",
      "paginate": {
        "previous": '<i class="fa fa-angle-left"></i>',
        "next": '<i class="fa fa-angle-right"></i>'
      }
    }
  });
  $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
      // save the latest tab; use cookies if you like 'em better:
      localStorage.setItem('lastTab', $(this).attr('href'));
  });

  // go to the latest tab, if it exists:
  var lastTab = localStorage.getItem('lastTab');
  if (lastTab) {
      $('[href="' + lastTab + '"]').tab('show');
  }
  var wizard_options = {
    step: ".steps .step, .pearls .pearl",
    onFinish: function() {
      $('.simple_form').submit();
    },
    buttonsAppendTo: '.panel-body',
    templates: {
      buttons: function() {
        var options = this.options;
        return '<div class="wizard-buttons">' +
          '<a class="btn btn-default" href="#' + this.id + '" data-wizard="back" role="button">' + options.buttonLabels.back + '</a>' +
          '<a class="btn btn-primary pull-right" href="#' + this.id + '" data-wizard="next" role="button">' + options.buttonLabels.next + '</a>' +
          '<a class="btn btn-success pull-right" href="#' + this.id + '" data-wizard="finish" role="button">' + options.buttonLabels.finish + '</a>' +
          '</div>';
      }
    }
  }

  $(".simple_wizard").wizard(wizard_options);
  $(".show-notifications").click(function(){
    $('.total-notifications').html(0);
  });
});

var FormPage = {
  init:function(){
    $(".validate").validate({
      errorPlacement: function(error,element) {
        return true;
      }
    });
    $('[data-plugin="select2"]').selectpicker({
      style: 'btn-select',
      iconBase: "icon",
      tickIcon: "md-check",
      liveSearch:true,
      size: 4
    });

    $('.select2-multiple').select2();
    $('.multiselectfast').fastselect();

    $('.as-spiner').asSpinner({
      namespace: "spinnerUi",
      skin: null,
      min: "-10",
      max: 100,
      mousewheel: true
    });
    var options = {color:'#3949ab'};
    var elems = Array.prototype.slice.call(document.querySelectorAll('.switchery'));
    elems.forEach(function(html) {
      var switchery = new Switchery(html,options);
      setLabel(html);
      html.onchange = function() {
        setLabel(html);
      };
    });

    $(".colorpicker").asColorPicker({
      mode:'simple',
      namespace: "colorInputUi"
    });


    $('.timepicker').timepicker({ 'timeFormat': 'g:i A' });
    $('.dropify').dropify({
      tpl: {
          wrap:            '<div class="dropify-wrapper"></div>',
          loader:          '<div class="dropify-loader"></div>',
          message:         '<div class="dropify-message"><i class="icon icon-lg md-camera margin-25" aria-hidden="true"></i></div>',
          preview:         '<div class="dropify-preview"><span class="dropify-render"></span>',
          filename:        '',
          clearButton:     '<button type="button" class="dropify-clear">{{ remove }}</button>',
          errorLine:       '<p class="dropify-error">{{ error }}</p>',
          errorsContainer: '<div class="dropify-errors-container"></div>'
      }
    });
  },
  setTitle:function(title,buttonText){
    $('.modal-title').html(title);
    $('.finisha').val(buttonText);
  }
}
