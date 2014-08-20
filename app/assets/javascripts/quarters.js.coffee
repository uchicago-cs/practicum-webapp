# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

`
$(document).ready(function(event){
    deadlines = $('.deadlines_class').data('deadlines');
    $('#quarter_start_date').val(deadlines["start"]);
    $('#quarter_project_proposal_deadline').val(deadlines["proposal"]);
    $('#quarter_student_submission_deadline').val(deadlines["submission"]);
    $('#quarter_advisor_decision_deadline').val(deadlines["decision"]);
    $('#quarter_admin_publish_deadline').val(deadlines["admin"]);
    $('#quarter_end_date').val(deadlines["end"]);
});
`