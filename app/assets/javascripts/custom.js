$(document).ready(function(){
    $('.dropdown-toggle').dropdown()
    $('.datetimepicker').datetimepicker({
	format: 'yyyy-MM-dd HH:mm:SS',
	// format: 'dd/MM/yyyy HH:mm PP',
	pickSeconds: false,
	language: 'en'
    });
})
