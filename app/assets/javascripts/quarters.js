$(document).ready(function(event){
    $('.datetimepicker').datetimepicker({
	format: 'YYYY-MM-DD HH:mm:00',
	useSeconds: false,
	useCurrent: false,
	minuteStepping: 15,
	language: 'en'
    });

    // Only the new form has a div with this class, so we check whether the
    // class exists before grabbing the data. Otherwise, we'd get an error.
    if ($('.deadlines_class').length) {
	deadlines = $('.deadlines_class').data('deadlines');
	$('#quarter_start_date').val(deadlines["start"]);
	$('#quarter_project_proposal_deadline').val(deadlines["proposal"]);
	$('#quarter_student_submission_deadline').val(deadlines["submission"]);
	$('#quarter_advisor_decision_deadline').val(deadlines["decision"]);
	$('#quarter_admin_publish_deadline').val(deadlines["admin"]);
	$('#quarter_end_date').val(deadlines["end"]);
    };

    $('#quarter-form-tooltip').tooltip({
	container: 'body',
	trigger: 'hover'
    });

});
