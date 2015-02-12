$(document).ready(function(event){
    function checkRadio(event) {
	var val = $('#new-eval-question #_question_type').val()
	if (val == 'Radio button' || val == 'Check box (multiple choices)') {
	    $('#new-eval-question #multiple-button-group').show();
	} else {
	    $('#new-eval-question #multiple-button-group').hide();
	};
    };

    checkRadio();
    $('#new-eval-question #_question_type').on('change', checkRadio);

    var rbDiv = $('#new-eval-question #multiple-option-group');
    var i = $('#new-eval-question #multiple-button-group input').size();
    $('#new-eval-question #add-option-button').click(function(event) {
	event.preventDefault();
	i++;
	$('<div class="form-group"><label class="control-label col-sm-2" for="multiple_btn_opts[' + i + ']">Radio button option ' + i + '</label><div class="col-md-3"><input class="form-control" id="multiple_btn_opts[' + i + ']" name="multiple_btn_opts[' + i + ']" type="text" data-parsley-required="true"></div><a href="#" class="col-sm-1 remove-multiple-input" id="remove-multiple-input[' + i +']">Remove</a></div>').appendTo(rbDiv);
	return false;
    });

    $('#new-eval-question').on('click', 'a.remove-multiple-input', function(e) {
	e.preventDefault();
	var firstIndex = parseInt($(this).attr('id').
				  match(/\[(.*)\]/)[1], 10) + 1;
	$(this).closest('div').remove();
	i--;
	var lastIndex = parseInt(
	    $('#new-eval-question #multiple-button-group input').last().
		attr('id').match(/\[(.*)\]/)[1], 10);
	for (var j = firstIndex; j <= lastIndex; j++) {
	    var thisFormGroup =
		$('#new-eval-question div:contains("Radio button option '
		  + j + '")').closest('.form-group');
	    var replacement = (j-1);
	    thisFormGroup.find('label').
		prop('for', 'multiple_btn_opts[' + replacement + ']');
	    thisFormGroup.find('input').
		prop('id', 'multiple_btn_opts[' + replacement + ']');
	    thisFormGroup.find('input').
		prop('name', 'multiple_btn_opts[' + replacement + ']');
	    thisFormGroup.find('a').
		prop('id', 'remove-multiple-input[' + replacement + ']');
	    thisFormGroup.find('label').
		text("Radio button option " + replacement);
	};
	return false;
    });

    /****************************************************************/

    function checkRadioModal(event) {
	var val = $('#edit-q-modal #_question_type').val();
	if (val == 'Radio button' || val == 'Check box (multiple choices)') {
	    $('#edit-q-modal #multiple-button-group').show();
	} else {
	    $('#edit-q-modal #multiple-button-group').hide();
	};
    };

    $('#edit-q-modal #_question_type').on('change', checkRadioModal);
    $('#edit-q-modal').on('show.bs.modal', function(e) {
	checkRadioModal();
    });

    var rbmDiv = $('#edit-q-modal #multiple-option-group');
    var im = $('#edit-q-modal #multiple-button-group input').size();
    $('#edit-q-modal #add-option-button').click(function(event) {
	event.preventDefault();
	im++;
	$('<div class="form-group"><label class="control-label col-sm-4" for="multiple_btn_opts[' + im + ']">Radio button option ' + im + '</label><div class="col-md-6"><input class="form-control" id="multiple_btn_opts[' + im + ']" name="multiple_btn_opts[' + im + ']" type="text" data-parsley-required="true"></div><a href="#" class="col-sm-1 remove-multiple-input" id="remove-multiple-input[' + im +']">Remove</a></div>').appendTo(rbmDiv);
	return false;
    });

    $('#edit-q-modal').on('click', 'a.remove-multiple-input', function(e) {
	e.preventDefault();
	var firstIndex = parseInt($(this).attr('id').
				  match(/\[(.*)\]/)[1], 10) + 1;
	$(this).closest('div').remove();
	im--;
	var lastIndex = parseInt(
	    $('#edit-q-modal #multiple-button-group input').last().
		attr('id').match(/\[(.*)\]/)[1], 10);
	for (var j = firstIndex; j <= lastIndex; j++) {
	    var thisFormGroup =
		$('#edit-q-modal div:contains("Radio button option ' +
		  j + '")').closest('.form-group');
	    var replacement = (j-1);
	    thisFormGroup.find('label').
		prop('for', 'multiple_btn_opts[' + replacement + ']');
	    thisFormGroup.find('input').
		prop('id', 'multiple_btn_opts[' + replacement + ']');
	    thisFormGroup.find('input').
		prop('name', 'multiple_btn_opts[' + replacement + ']');
	    thisFormGroup.find('a').
		prop('id', 'remove-multiple-input[' + replacement + ']');
	    thisFormGroup.find('label').
		text("Radio button option " + replacement);
	};
	return false;
    });

    $('.btn-edit-q').click(function(e) {
	var question_num    = $(this).closest('tr').index() + 1;
	var question_type   = $(this).closest('tr').find('td:eq(0)').text();
	var question_prompt = $(this).closest('tr').find('td:eq(1)').text();
	var question_opts = [];
	$(this).closest('tr').find('td:eq(2) p').
	    each(function(index, element) {
	    question_opts.push($(element).text().substring(3));
	});

	$('.modal-body').find('#_question_num').val(question_num);
	$('.modal-body').find('select').val(question_type);
	$('.modal-body').find('textarea').val(question_prompt);
	// If it already is; not if it gets changed to a radio button q.
	if (question_type == "Radio button") {
	    // Populate options with questions from table.
	    $('.modal-body #multiple-option-group input').val(question_opts[0]);
	    $.each(question_opts, function(index, element) {
		// We already added the first option just above.
		if (index > 0) {
		    im++;
	$('<div class="form-group"><label class="control-label col-sm-4" for="multiple_btn_opts[' + im + ']">Radio button option ' + im + '</label><div class="col-md-6"><input class="form-control" id="multiple_btn_opts[' + im + ']" name="multiple_btn_opts[' + im + ']" type="text" data-parsley-required="true"></div><a href="#" class="col-sm-1 remove-multiple-input" id="remove-multiple-input[' + im +']">Remove</a></div>').appendTo(rbmDiv);
		    $('.modal-body').find('input').last().
			val(question_opts[index]);
		};
	    });
	}
    });

    // Remove all but the first option.
    $('#edit-q-modal').on('hidden.bs.modal', function(e) {
	var options = $(this).find('#multiple-option-group input');
	$(options[0]).val("");
	// Remove the first element from the array, since we want to keep it
	// on the page.
	options = options.slice(1);
	$.each(options, function(index, element) {
	    $(options[index]).closest('.form-group').remove();
	    im--;
	});
    });

    /****************************************************************/

    // Client-side validation

    // Use Parsley to validate edit evaluation template forms.
    window.ParsleyValidator.addMessage('en', 'required',
				       'This field is required.');

    $('#new-eval-question form').parsley({ excluded: ':hidden' });
    $('#edit-q-modal form').parsley({ excluded: ':hidden' });

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
    // 	$("select#\\_ordering\\[" + new_position + "\\]").
    //      val(position_changes[old_position]);
    // 	position_changes[old_position] = new_position;
    // });

});
