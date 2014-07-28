note

	description:
		"[ 
		 Internal description of object test locals of a routine. 
		 The description is immutable up to the `offset' and the scope limits 
		 which may be set later. 
		 ]"

class IS_SCOPE_VARIABLE

inherit

	IS_LOCAL
		rename
			make as make_local
		end
	
create

	make

feature {} -- Initialization

	make (nm: READABLE_STRING_8; t: like type; ts: like type_set;
			as_object_test: BOOLEAN; f: like text)
		do
			make_local (nm, t, ts, f)
			if as_object_test then
				is_object_test := True
			else
				is_across_component := True
			end
		end
	
feature -- Access 

	lower_scope_limit: INTEGER

	upper_scope_limit: INTEGER

	is_object_test: BOOLEAN

	is_across_component: BOOLEAN

feature -- Status 

	in_scope (line, col: INTEGER): BOOLEAN
		note
			return: "Is position `line,col' in `Currents''s scope?"
		local
			p: INTEGER
		do
			p := line * 256 + col
				-- GEC specific 
			Result := lower_scope_limit <= p and then p <= upper_scope_limit
		end

feature -- Status setting 

	set_lower_scope_limit (p: INTEGER)
		require
			positive: p > 0
		do
			lower_scope_limit := p
		ensure
			lower_scope_limit_set: lower_scope_limit = p
		end

	set_upper_scope_limit (p: INTEGER)
		require
			positive: p > 0
		do
			upper_scope_limit := p
		ensure
			upper_scope_limit_set: upper_scope_limit = p
		end

invariant

	mode_set: is_object_test xor is_across_component

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
