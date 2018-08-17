var Fluence = {
	editor : {
		isPreviewActive: false
	}
};

Fluence.mde_options = function(can_edit) {
	options = {
		renderingConfig: { codeSyntaxHighlighting: true },
		status: ["autosave", "lines", "words", "cursor"],
		shortcuts: { drawTable: "Cmd-Alt-T", undo: "Cmd-Z", redo: "Cmd-Y" },
		autosave: { enabled: false, delay: 2000, uniqueId: 1},
		// Do not use placeholder because it only shows in Edit mode,
		// and it is not needed there.
		//placeholder: "Please enter Edit mode to add content",
		toolbar: [
			"fullscreen"
		]
	};
	if(can_edit) {
		options["toolbar"].push(
			{ name: "preview", action: Fluence.editor.togglePreview, className: "fa fa-eye no-disable", title: "Preview" },
			"side-by-side",
			"|",
			"bold",
			"italic",
			"strikethrough",
			"heading-smaller",
			"heading-bigger",
			"|",
			"code",
			"quote",
			"unordered-list",
			"ordered-list",
			"|",
			"link",
			"image",
			"table",
			"horizontal-rule",
			"|",
			{ name: "clean-block", action: InscrybMDE.cleanBlock, className: "fa fa-eraser fa-clean-block", title: "Clear formatting" },
			{ name: "undo", action: InscrybMDE.undo, className: "fa fa-undo", title: "Undo" },
			{ name: "redo", action: InscrybMDE.redo, className: "fa fa-redo", title: "Redo" }
		);
	};
	return options
}

Fluence.editor.togglePreview = function(){
	editor.togglePreview();
	Fluence.editor.isPreviewActive = !Fluence.editor.isPreviewActive
	if (Fluence.editor.isPreviewActive){
		$("#button_save").hide();
		$("#button_toggle").html("Edit");
	}
	else{
		$("#button_save").show();
		$("#button_toggle").html("Preview");
	}
}