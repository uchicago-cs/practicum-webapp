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
	if ($('#_question_type').val() == 'Radio button') {
	    $('#radio-button-group').show();
	    //$('.form-group').has('#radio_button_group').show();
	} else {
	    $('#radio-button-group').hide();
	};
    }

    checkRadio();
    $('#_question_type').on('change', checkRadio);

    var rbDiv = $('#radio-option-group');
    var i = $('#radio-button-group input').size() + 1;
    $('#add-option-button').click(function(event) {
	event.preventDefault();
	// Can we make this prettier?
	$('<div class="form-group"><label class="control-label col-sm-2" for="radio_button_options[' + i + ']">Radio button option ' + i + '</label><div class="col-xs-2"><input class="form-control" id="radio_button_options[' + i + ']" name="radio_button_options[' + i + ']" type="text"></div><a href="#" class="col-sm-1 remove-radio-input">Remove</a></div>').appendTo(rbDiv);
	i++;
	return false;
    });

    $('#new-eval-question').on('click', 'a.remove-radio-input', function(event) {
	event.preventDefault();
	$(this).closest('div').remove();
	i--;
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
