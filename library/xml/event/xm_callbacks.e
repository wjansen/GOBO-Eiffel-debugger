indexing

	description:

		"Callback interface for core content XML events"

	library: "Gobo Eiffel XML Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class XM_CALLBACKS

feature -- Document

	on_start is
			-- Called when parsing starts.
		deferred
		end

	on_finish is
			-- Called when parsing finished.
		deferred
		end

	on_xml_declaration (a_version: STRING; an_encoding: STRING; a_standalone: BOOLEAN) is
			-- XML declaration.
		require
			a_version_not_void: a_version /= Void
			a_version_not_empty: a_version.count > 0
		deferred
		end

feature -- Errors

	on_error (a_message: STRING) is
			-- Event producer detected an error.
		require
			not_void: a_message /= Void
		deferred
		end

feature -- Meta

	on_processing_instruction (a_name: STRING; a_content: STRING) is
			-- Processing instruction.
		require
			name_not_void: a_name /= Void
			content_not_void: a_content /= Void
		deferred
		end

	on_comment (a_content: STRING) is
			-- Processing a comment.
			-- Atomic: single comment produces single event
		require
			a_content_not_void: a_content /= Void
		deferred
		end

feature -- Tag

	on_start_tag (a_namespace: STRING; a_prefix: STRING; a_local_part: STRING) is
			-- Start of start tag.
		require
			--unresolved_namespace_is_void: a_namespace may be void
			local_part: is_local_part (a_local_part)
		deferred
		end

	on_attribute (a_namespace: STRING; a_prefix: STRING; a_local_part: STRING; a_value: STRING) is
			-- Start of attribute.
		require
			--unresolved_namespace_is_void: a_namespace may be void
			local_part: is_local_part (a_local_part)
			a_value_not_void: a_value /= Void
		deferred
		end

	on_start_tag_finish is
			-- End of start tag.
		deferred
		end

	on_end_tag (a_namespace: STRING; a_prefix: STRING; a_local_part: STRING) is
			-- End tag.
		require
			--unresolved_namespace_is_void: a_namespace may be void
			local_part: is_local_part (a_local_part)
		deferred
		end

feature -- Content

	on_content (a_content: STRING) is
			-- Text content.
			-- NOT atomic: two on_content events may follow each other
			-- without a markup event in between.
		require
			not_void: a_content /= Void
			not_empty: a_content.count >= 0
		deferred
		end

feature -- Support

	has_prefix (a: STRING): BOOLEAN is
			-- Is prefix in use?
		do
			Result := a /= Void
		end

	has_namespace (a: STRING): BOOLEAN is
			-- Is namespace resolved?
		do
			Result := a /= Void
		end

	is_local_part (a: STRING): BOOLEAN is
			-- Is this a valid local part string?
		do
			Result := a /= Void and then a.count > 0
		ensure
			definition: Result = (a /= Void and then a.count > 0)
		end

end
