$(document).ready(function(event){
    $('.dropdown-toggle').dropdown()
    $('.datetimepicker').datetimepicker({
	format: 'YYYY-MM-DD HH:mm:00',
	useSeconds: false,
	useCurrent: false,
	minuteStepping: 15,
	language: 'en'
    });

    /****************************************************************/

    /* Resize content-body div to fill the vertical space between the header
     * and footer
     */
    var resizeContentBody = function(event) {
	var content_body_height = $(window).height() - ($("header").outerHeight() + $("footer").outerHeight());
	$("#content-body").css("min-height", content_body_height + "px");
    };
    resizeContentBody();
    $(window).resize(function() {
	resizeContentBody();
    });

    /****************************************************************/

    function checkRadio(event) {
	if ($('#new-eval-question #_question_type').val() == 'Radio button') {
	    $('#new-eval-question #radio-button-group').show();
	} else {
	    $('#new-eval-question #radio-button-group').hide();
	};
    }

    checkRadio();
    $('#new-eval-question #_question_type').on('change', checkRadio);

    var rbDiv = $('#new-eval-question #radio-option-group');
    var i = $('#new-eval-question #radio-button-group input').size();
    $('#new-eval-question #add-option-button').click(function(event) {
	event.preventDefault();
	i++;
	$('<div class="form-group"><label class="control-label col-sm-2" for="radio_button_options[' + i + ']">Radio button option ' + i + '</label><div class="col-md-3"><input class="form-control" id="radio_button_options[' + i + ']" name="radio_button_options[' + i + ']" type="text"></div><a href="#" class="col-sm-1 remove-radio-input" id="remove-radio-input[' + i +']">Remove</a></div>').appendTo(rbDiv);
	return false;
    });

    $('#new-eval-question').on('click', 'a.remove-radio-input', function(e) {
	e.preventDefault();
	var firstIndex = parseInt($(this).attr('id').match(/\[(.*)\]/)[1], 10) + 1;
	$(this).closest('div').remove();
	i--;
	var lastIndex = parseInt($('#new-eval-question #radio-button-group input').last().attr('id').match(/\[(.*)\]/)[1], 10);
	for (var j = firstIndex; j <= lastIndex; j++) {
	    var thisFormGroup = $('#new-eval-question div:contains("Radio button option ' + j + '")').closest('.form-group');
	    var replacement = (j-1);
	    thisFormGroup.find('label').prop('for', 'radio_button_options[' + replacement + ']');
	    thisFormGroup.find('input').prop('id', 'radio_button_options[' + replacement + ']');
	    thisFormGroup.find('input').prop('name', 'radio_button_options[' + replacement + ']');
	    thisFormGroup.find('a').prop('id', 'remove-radio-input[' + replacement + ']');
	    thisFormGroup.find('label').text("Radio button option " + replacement);
	}
	return false;
    });

    /****************************************************************/

    $('.btn-edit-q').click(function(e) {
	var question_type   = $(this).closest('tr').find('td:eq(0)').text();
	var question_prompt = $(this).closest('tr').find('td:eq(1)').text();
	var question_opts   = $(this).closest('tr').find('td:eq(2)').text();
	var question_num    = $(this).closest('tr').index() + 1;

	$('.modal-body').find('#_question_num').val(question_num);
	$('.modal-body').find('select').val(question_type);
	$('.modal-body').find('textarea').val(question_prompt);
	if (question_opts == "Radio button") {
	    // Populate options with questions from table
	}
    });


    function checkRadioModal(event) {
	if ($('#edit-q-modal #_question_type').val() == 'Radio button') {
	    $('#edit-q-modal #radio-button-group').show();
	} else {
	    $('#edit-q-modal #radio-button-group').hide();
	};
    }

    $('#edit-q-modal #_question_type').on('change', checkRadioModal);
    $('#edit-q-modal').on('show.bs.modal', function(e) {
	checkRadioModal();
    });

    var rbmDiv = $('#edit-q-modal #radio-option-group');
    var im = $('#edit-q-modal #radio-button-group input').size();
    $('#edit-q-modal #add-option-button').click(function(event) {
	event.preventDefault();
	im++;
	$('<div class="form-group"><label class="control-label col-sm-2" for="radio_button_options[' + im + ']">Radio button option ' + im + '</label><div class="col-md-6"><input class="form-control" id="radio_button_options[' + im + ']" name="radio_button_options[' + im + ']" type="text"></div><a href="#" class="col-sm-1 remove-radio-input" id="remove-radio-input[' + im +']">Remove</a></div>').appendTo(rbmDiv);
	return false;
    });

    $('#edit-q-modal').on('click', 'a.remove-radio-input', function(e) {
	e.preventDefault();
	var firstIndex = parseInt($(this).attr('id').match(/\[(.*)\]/)[1], 10) + 1;
	$(this).closest('div').remove();
	im--;
	var lastIndex = parseInt($('#edit-q-modal #radio-button-group input').last().attr('id').match(/\[(.*)\]/)[1], 10);
	for (var j = firstIndex; j <= lastIndex; j++) {
	    var thisFormGroup = $('#edit-q-modal div:contains("Radio button option ' + j + '")').closest('.form-group');
	    var replacement = (j-1);
	    thisFormGroup.find('label').prop('for', 'radio_button_options[' + replacement + ']');
	    thisFormGroup.find('input').prop('id', 'radio_button_options[' + replacement + ']');
	    thisFormGroup.find('input').prop('name', 'radio_button_options[' + replacement + ']');
	    thisFormGroup.find('a').prop('id', 'remove-radio-input[' + replacement + ']');
	    thisFormGroup.find('label').text("Radio button option " + replacement);
	}
	return false;
    });

    /****************************************************************/

    // var ordering_group = $('.ordering-select');
    // var position_changes = {};
    // ordering_group.each(function(event) {
    // 	var dropdown          = $(this).find("select");
    // 	var question_num      = $(dropdown).attr("id").match(/\[(.*)\]/)[1]
    // 	var selected_position = $("option:selected", dropdown).text();
    // 	position_changes[question_num] = selected_position;
    // });
    // console.log(position_changes);
    // ordering_group.change(function(event) {
    // 	var dropdown     = $(this).find("select");
    // 	var new_position = $("option:selected", dropdown).text();
    // 	var old_position = $(dropdown).attr("id").match(/\[(.*)\]/)[1];
    // 	// old_position corresponds to question_num above.
    // 	$("select#\\_ordering\\[" + new_position + "\\]").val(position_changes[old_position]);
    // 	position_changes[old_position] = new_position;
    // });

});
