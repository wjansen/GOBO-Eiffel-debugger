note

	description:
		"Compile time description of arguments and local variables of a routine."

class ET_IS_LOCAL

inherit

	IS_LOCAL
		redefine
			type,
			text,
			is_attached
		end

	ET_IS_ORIGIN [detachable ET_AST_NODE, IS_LOCAL]

create

	declare

feature {NONE} -- Initialization 

	declare (n: detachable ET_AST_NODE; nm: detachable STRING;
			t: ET_DYNAMIC_TYPE; h: like home; x: like text; 
			s: ET_IS_SYSTEM)
		require
			has_name: attached {ET_IDENTIFIER} n or else attached nm 
		do
			make_origin (n)
			if attached {ET_IDENTIFIER} n as id then
				fast_name := s.internal_name (id.lower_name)
			else
				fast_name := s.internal_name (nm)
			end
			target := h.target
			home := h
			s.force_type (t)
			type := s.last_type
			is_attached := t.base_type.is_type_attached (home.in_class.origin)
			text := x
			if attached x as tx and then s.needs_feature_texts
				and then type.is_tuple
			 then
				declare_labels (t.base_type, tx, s)
			end
		ensure
			home_set: home = h
		end

feature -- Initialization 

	define (s: ET_IS_SYSTEM)
		do
			if not defined then
				defined := True
				type.define (s)
				if attached text as x then
					x.define (s)
				end
			end
		end

feature -- Access 

	type: ET_IS_TYPE

	home: ET_IS_ROUTINE

	text: detachable ET_IS_FEATURE_TEXT

	is_attached: BOOLEAN

feature {IS_BASE} -- Status setting 

	set_text (t: detachable ET_IS_FEATURE_TEXT)
		do
			text := t
		ensure
			text_set: text = t
		end

	set_type_set (dt: like type_set)
		do
			type_set := dt
		ensure
			type_set_set: type_set = dt
		end

	set_attached
		do
			is_attached := True
		end

feature -- Basic operation 

	print_name (a_file: KI_TEXT_OUTPUT_STREAM; g: ET_INTROSPECT_GENERATOR)
		local
			l: ET_LOCAL_VARIABLE
			i: INTEGER
		do
-- To do: compute `i'
			l := home.origin.static_feature.locals.local_variable (i)
			g.print_local_name (l.name, a_file) 
		end

feature {NONE} -- Implentation 

	declare_labels (t: ET_TYPE; x: attached like text; s: ET_IS_SYSTEM)
		local
			cls: ET_CLASS
		do
			cls := home.origin.static_feature.implementation_class
			if attached t.base_type (cls) as bt then
				x.declare_tuple_labels (bt, s)
			end
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
