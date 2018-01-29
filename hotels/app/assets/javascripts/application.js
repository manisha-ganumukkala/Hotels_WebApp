// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require rails-ujs
//= require turbolinks
//= require_tree .
//= require jquery-ui
//= require Chart.bundle
//= require chartkick

$(function() {
var dateFormat = "mm/dd/yy",
    from = $("#start_date").datepicker({
	  defaultDate: "+1D",
	  minDate:0,
	  numberOfMonths: 2
	}).on( "change", function() {
	  to.datepicker( "option", "minDate", getDate( this ) );
	});
    to = $("#end_date").datepicker({
	  defaultDate: "+2D",
	  minDate:"+1D",
	  numberOfMonths: 2
	}).on("change", function() {
	  from.datepicker( "option", "maxDate", getDate( this ) );
	});

function getDate( element ) {
      var date;
      try {
        date = $.datepicker.parseDate( dateFormat, element.value );
      } catch( error ) {
        date = null;
      }

      return date;
    }

});



