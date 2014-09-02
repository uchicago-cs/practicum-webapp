$(document).ready(function(event){
    $('.datetimepicker').datetimepicker({
	format: 'YYYY-MM-DD HH:mm:00',
	useSeconds: false,
	useCurrent: false,
	minuteStepping: 15,
	language: 'en'
    });

    deadlines = $('.deadlines_class').data('deadlines');
    $('#quarter_start_date').val(deadlines["start"]);
    $('#quarter_project_proposal_deadline').val(deadlines["proposal"]);
    $('#quarter_student_submission_deadline').val(deadlines["submission"]);
    $('#quarter_advisor_decision_deadline').val(deadlines["decision"]);
    $('#quarter_admin_publish_deadline').val(deadlines["admin"]);
    $('#quarter_end_date').val(deadlines["end"]);

});
