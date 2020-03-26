var dataTable = null

$(document).on('turbolinks:before-cache', function(){
  if (dataTable !== null) {
   dataTable.destroy()
   dataTable = null
  }
})

$(document).on('turbolinks:load', function(){
    dataTable = $('#datatable').DataTable({
        "bInfo" : false,
        "columnDefs": [{
            "targets": 'no-sort',
            "orderable": false,
        }],
        "aaSorting": [],
        "language": {
            "lengthMenu": "Showing _MENU_ samples",
            "emptyTable": "No samples to show"
        },
        "stateSave": true
    });
});