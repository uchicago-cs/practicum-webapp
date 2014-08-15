$(document).ready(function(){
    $('.dropdown-toggle').dropdown()
    $('.datetimepicker').datetimepicker({
	format: 'dd/MM/yyyy HH:mm PP',
	pickSeconds: false,
	language: 'en'
    });
})
