indexing

	description:

		"Rename Elements"

	library: "Gobo Eiffel Ant"
	copyright: "Copyright (c) 2001, Sven Ehrke and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class GEANT_RENAME_ELEMENT

inherit

	GEANT_INTERPRETING_ELEMENT
		rename
			make as interpreting_element_make
		end

creation

	make

feature -- Initialization

	make (a_project: GEANT_PROJECT; a_xml_element: GEANT_XML_ELEMENT) is
			-- Create new rename clause with information held in `an_xml_element'.
		local
			a_value: STRING
		do
			interpreting_element_make (a_project, a_xml_element)

			create rename_clause.make

			if has_uc_attribute (Target_attribute_name) then
				a_value := uc_attribute_value (Target_attribute_name).out
				if a_value.count > 0 then
					rename_clause.set_original_name (a_value)
				end
			end

			if has_uc_attribute (As_attribute_name) then
				a_value := uc_attribute_value (As_attribute_name).out
				if a_value.count > 0 then
					rename_clause.set_new_name (a_value)
				end
			end

		end

feature -- Access

	rename_clause: GEANT_RENAME
		-- Rename clause

feature {NONE} -- Constants

	Target_attribute_name: UC_STRING is
			-- "target" attribute name
		once
			Result := new_unicode_string ("target")
		ensure
			attribute_name_not_void: Result /= Void
			attribute_name_not_empty: Result.count > 0
		end

	As_attribute_name: UC_STRING is
			-- "as" attribute name
		once
			Result := new_unicode_string ("as")
		ensure
			attribute_name_not_void: Result /= Void
			attribute_name_not_empty: Result.count > 0
		end

end
