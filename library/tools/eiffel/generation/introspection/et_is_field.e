note

	description:

		"Compile time description of attributes of a type or of arguments."

class ET_IS_FIELD

inherit

	IS_FIELD
		export
			{ANY}
				set_offset
		redefine
			type,
			text
		end

	ET_IS_ORIGIN [detachable ET_DYNAMIC_FEATURE, IS_FIELD]

create

	declare,
	declare_without_origin
	
create {ET_IS_TYPE, IS_FACTORY}

	make_in_system

feature {} -- Initialization 

	declare (o: attached like origin; h: like target; s: ET_IS_SYSTEM)
		note
			action: "Create `Current' according to `o'."
			h: "enclosing type"
		local
			static: ET_FEATURE
			nm: READABLE_STRING_8
			l, u: INTEGER
		do
			make_origin (o)
			static := o.static_feature
			fast_name := s.internal_name (static.lower_name)
			s.force_type (o.result_type_set.static_type)
			type := s.last_type
			target := h
			is_attached := static.type.is_type_attached (o.target_type.base_class)
			s.force_class (o.target_type.base_class)
			if attached static.alias_name as anm then
				nm := anm.alias_string.value
				l := nm.index_of ('"', 1)
				if l > 0 then
					-- remove leading alias tag
					l := l + 1
					u := nm.index_of ('"', l) - 1
					nm := nm.substring (l, u)
				end
				alias_name := s.internal_name (nm)
			end
			declare_text (static, s)
				-- `offset' is not yet valid: 
			offset := -1
		ensure
			origin_set: origin = o
			target_set: target = h
		end

	declare_without_origin (id: INTEGER; nm: STRING; t: ET_IS_TYPE; 
			tgt: like target; s: ET_IS_SYSTEM)
		note
			action: "Create `Current'."
			id: "index in enclosing type"
			nm: "field name"
			t: "field type"
			tgt: "enclosing type"
		do
			ident := id
			fast_name := s.internal_name (nm)
			type := t
			target := tgt
			offset := -1
			is_attached := t.origin.base_type.type.is_type_attached (tgt.origin.base_class)
		ensure
			ident_set: ident = id
			name_set: STRING_.same_string (fast_name, nm)
			type_set: type = t
			target_set: target = tgt
		end
	
feature -- Initialization 

	define (s: ET_IS_SYSTEM)
		note
			action: "Complete construction of `Current'."
		local
			bt: ET_BASE_TYPE
		do
			if not defined then
				defined := True
				type.define (s)
				target.define (s)
				if s.needs_typeset and then attached origin as o then
					type_set := s.type_set (type, o.result_type_set, is_attached)
				end
				if attached text as x and then attached origin as o then
					x.define (s)
					if attached {ET_QUERY} o.static_feature as q then
						bt := q.type.base_type (q.implementation_class)
						x.declare_tuple_labels (bt, s)
					end
				end
			end
		end

feature -- Access 

	type: ET_IS_TYPE

	text: detachable ET_IS_FEATURE_TEXT

	ident: INTEGER
			-- Index 0... in enclosing type if `origin=Void'. 
	
feature {IS_NAME} -- Status setting 

	set_text (t: detachable ET_IS_FEATURE_TEXT)
		do
			text := t
			if t /= Void then
				fast_name := t.fast_name
			end
		ensure
			text_set: text = t
		end

feature -- ET_IS_ORIGIN 

	print_name (file: KI_TEXT_OUTPUT_STREAM; g: ET_INTROSPECT_GENERATOR)
		do
			if attached origin as o then
				g.print_attribute_name (o, o.target_type, file)
			elseif attached {ET_IS_SPECIAL_TYPE} target as st then
				g.print_attribute_special_item_name (st.origin, file)
			else
				-- TUPLE item:
				file.put_character ('z')
				file.put_integer (ident + 1)
			end
		end

feature {} -- Implentation

	declare_text (static: ET_FEATURE; s: ET_IS_SYSTEM)
		require
			has_origin: attached origin
		local
			target_class: ET_IS_CLASS_TEXT
		do
			if s.needs_feature_texts then
				s.force_class (origin.target_type.base_class)
				target_class := s.last_class
				target_class.force_feature (origin.static_feature, s)
				text := target_class.last_feature
			end
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
