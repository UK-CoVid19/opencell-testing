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
//= require bs-custom-file-input/dist/bs-custom-file-input.min.js
//= require chart.js/dist/Chart.min.js
//= require jsqr/dist/jsQR.js
//= require jquery/dist/jquery.min.js
//= require jquery-ui-dist/jquery-ui.min.js
//= require bootstrap-select/dist/js/bootstrap-select.min.js
//= require popper
//= require bootstrap-sprockets
//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require_tree .


$(document).on('turbolinks:load', () => {$('[data-toggle="tooltip"]').tooltip()});
$(document).on('turbolinks:load', () => {bsCustomFileInput.init()});


