note

	description:
		"Compile time description of arguments and local variables of a routine."

class ET_IS_FEATURE_TEXT

inherit

	IS_FEATURE_TEXT
		redefine
			tuple_labels,
			home,
			renames
		end

	ET_IS_ORIGIN [ET_AST_NODE, IS_FEATURE_TEXT]

create

	declare_from_declaration,
	declare_simple

create {ET_IS_CLASS_TEXT}

	declare_from_feature,
	declare_renamed

feature {} -- Initialization 

	declare_from_declaration (o: attached like origin; nm: STRING;
			d: ET_DECLARED_TYPE; h: like home; s: ET_IS_SYSTEM)
		local
			pos: ET_POSITION
			fl: INTEGER
		do
			make_origin (o)
			if attached {ET_FEATURE} o as f and then f.is_constant_attribute then
				fl := Once_flag
			end
			make (s.internal_name (nm), Void, fl, 0, 0)
			home := h
			if attached {ET_FEATURE} o as f and then f.is_frozen then
				pos := f.frozen_keyword.position
			else
				pos := o.position
			end
			declare_result (d.type, s)
			first_pos := position_as_integer (pos.line, pos.column)
			if attached {ET_QUERY} o as q then
				if attached q.assigner as qa then
					pos := qa.last_position
				else
					pos := q.last_position
				end
			elseif attached {ET_COLON_TYPE} d as c then
				pos := c.type.last_position
			else
				pos := o.last_position
			end
			last_pos := position_as_integer (pos.line, pos.column).max (first_pos)
		ensure
			origin_set: origin = o
		end

	declare_simple (nm: STRING; t: ET_TYPE; pos: detachable ET_POSITION;
			h: like home; const: BOOLEAN; s: ET_IS_SYSTEM)
		local
			fl: INTEGER
		do
			if const then
				fl := Once_flag
			end
			make (s.internal_name (nm), Void, fl, 0, 0)
			home := h
			declare_result (t, s)
			if pos /= Void then
				first_pos := position_as_integer (pos.line, pos.column)
				last_pos := first_pos + nm.count.to_natural_32
			end
		end

	declare_from_feature (f: ET_FEATURE; h: like home; s: ET_IS_SYSTEM)
		require
			h_implements_e: f.origin.static_feature.implementing_class = h
		local
			static: ET_FEATURE
			pos: ET_POSITION
			nm: STRING
			fl: INTEGER
		do
			static := f --e.origin.static_feature
			home := h
			nm := s.internal_name (static.name.lower_name)
			make_origin (static)
			if f.is_constant_attribute then
				fl := Once_flag
			end
			make (s.internal_name (static.name.lower_name), Void, fl, 0, 0)
			if attached static.alias_name as fa then
				alias_name := s.internal_name (fa.alias_string.value)
			end
			if attached {ET_QUERY} static as q then
				declare_result (q.type, s)
			end
			pos := static.first_position
			first_pos := position_as_integer (pos.line, pos.column)
			if static.is_constant_attribute
				and then attached {ET_CONSTANT_ATTRIBUTE} f as a
			 then
				pos := a.constant.last_position
			elseif static.is_unique_attribute
				and then attached {ET_UNIQUE_ATTRIBUTE} f as u
			 then
				pos := u.unique_keyword.last_position
			else
				pos := static.last_position
			end
			if attached pos as p then
				last_pos := position_as_integer (p.line, p.column)
			end
			last_pos := last_pos.max (first_pos)
		ensure
			origin_set: origin = f.static_feature
		end

	declare_renamed (nm: STRING; h: like home; r: like renames; const: BOOLEAN
			s: ET_IS_SYSTEM)
		local
			fl: INTEGER
		do
			if const then
				fl := Once_flag
			end
			fl := fl | r.flags 
			make (s.internal_name (nm), Void, fl, 0, 0)
			home := h
			renames := r
			result_text := r.result_text
		end
	
feature -- Initialization 

	define (s: ET_IS_SYSTEM)
		local
			i: INTEGER
		do
			if not defined then
				defined := True
				if attached tuple_labels as tl then
					from
						i := tl.count
					until i = 0 loop
						i := i - 1
						if attached tl [i] as tli then
							tli.define (s)
						end
					end
				end
			end
		end

feature -- Access 

	home: ET_IS_CLASS_TEXT

	tuple_labels: detachable IS_SEQUENCE [ET_IS_FEATURE_TEXT]

feature -- Status Setting
	
	declare_tuple_labels (t: ET_BASE_TYPE; s: ET_IS_SYSTEM)
		note
			action: "TUPLE labels of `t'."
		local
			label: ET_LABEL
			text: ET_IS_FEATURE_TEXT
			nm: STRING
			i, n: INTEGER
		do
			if labels_table.has (t) then
				tuple_labels := labels_table.item (t)
			else
				if attached t.actual_parameters as list
					and then not attached tuple_labels
				 then
					from
						n := list.count
					until i = n loop
						if attached {ET_LABELED_ACTUAL_PARAMETER} list.item (i + 1).actual_parameter as param then
							if attached tuple_labels then
							else
								s.force_class (t.base_class)
							end
							label := param.label_item
							nm := label.identifier.lower_name
							create text.declare_from_declaration
								(label, nm, param.declared_type, home, s)
							if not attached tuple_labels then
								create tuple_labels.make (n, text)
							end
							tuple_labels.add (text)
						end
						i := i + 1
					end
					if attached tuple_labels as tl then
						labels_table.force (tl, t)
					end
				end
			end
		end

	set_positions(first, last: ET_POSITION)
		do
			first_pos := position_as_integer (first.line, first.column)
			last_pos := position_as_integer (last.line, last.column)
		end
	
feature -- Basic operation 

	print_name (a_file: KI_TEXT_OUTPUT_STREAM; g: ET_INTROSPECT_GENERATOR)
		do
		end

feature {} -- Implementation 

	renames: like Current

	labels_table: DS_HASH_TABLE [IS_SEQUENCE [ET_IS_FEATURE_TEXT], ET_BASE_TYPE]
		once
			create Result.make (100)
		end

	declare_result (t: ET_TYPE; s: ET_IS_SYSTEM)
		local
			bc: ET_CLASS
		do
			bc := t.base_class (home.origin)
			s.force_class (bc)
			result_text := s.last_class
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
