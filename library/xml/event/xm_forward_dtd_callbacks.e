indexing

	description:

		"Callbacks for DTD declaration"

	library: "Gobo Eiffel XML Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_FORWARD_DTD_CALLBACKS

inherit

	XM_DTD_CALLBACKS_SOURCE

	XM_DTD_CALLBACKS
		export {NONE} all end

feature -- Access

	dtd_callbacks: XM_DTD_CALLBACKS
			-- Callbacks event interface to which events are forwarded;
			-- If void, a null callback is created on startup.

feature -- Setting

	set_dtd_callbacks (a_callbacks: XM_DTD_CALLBACKS) is
			-- Set `dtd_callbacks' to `a_callbacks'.
		do
			dtd_callbacks := a_callbacks
		ensure then
			dtd_callbacks_set: dtd_callbacks = a_callbacks
		end

feature {NONE} -- Document type definition callbacks

	on_doctype (name: STRING; an_id: XM_DTD_EXTERNAL_ID; has_internal_subset: BOOLEAN) is
			-- Document type declaration.
		do
			check_void
			dtd_callbacks.on_doctype (name, an_id, has_internal_subset)
		end

	on_element_declaration (a_name: STRING; a_model: XM_DTD_ELEMENT_CONTENT) is
			-- Element declaration.
		do
			check_void
			dtd_callbacks.on_element_declaration (a_name, a_model)
		end

	on_attribute_declaration (an_element_name, a_name: STRING; a_model: XM_DTD_ATTRIBUTE_CONTENT) is
			-- Attribute declaration, one event per attribute.
		do
			check_void
			dtd_callbacks.on_attribute_declaration (an_element_name, a_name, a_model)
		end

	on_entity_declaration (entity_name: STRING; is_parameter: BOOLEAN; value: STRING;
		an_id: XM_DTD_EXTERNAL_ID; notation_name: STRING) is
			-- Entity declaration.
		do
			check_void
			dtd_callbacks.on_entity_declaration (entity_name, is_parameter, value, an_id, notation_name)
		end

	on_notation_declaration (notation_name: STRING; an_id: XM_DTD_EXTERNAL_ID) is
			-- Notation declaration.
		do
			check_void
			dtd_callbacks.on_notation_declaration (notation_name, an_id)
		end

feature {NONE} -- Implementation

	check_void is
			-- Initialise with DTD callbacks if no handler.
		do
			if dtd_callbacks = Void then
				create {XM_DTD_CALLBACKS_NULL} dtd_callbacks.make
			end
		ensure
			dtd_callbacks_not_void: dtd_callbacks /= Void
		end

end
