note

	description: "Data of a qualified target."

class PC_TOOL_FIELD

inherit

	PC_TOOL_VALUE
		redefine
			evaluate
		end
	
create

	make_qualified

feature {} -- Initialization

	make_qualified (p: like parent; nm: READABLE_STRING_8)
		do
			ptr := c_new
			parent := p
			name := nm
			if attached parent as p_ and then not p_.head_name.is_empty then
				head_name := p_.head_name.twin
				head_name.extend ('.')
				head_name.append (nm)
			else
				head_name := nm
			end
		ensure
			parent_set: parent = p
			name_set: name.is_equal (nm)
		end

feature -- Access

	name: STRING
	
	field: detachable IS_FIELD

	parent: detachable PC_TOOL_FIELD

feature -- Status setting

	set_field (f: IS_FIELD)
		do
			field := f
		ensure
			field_set: field = f
		end
	
feature -- Basic operation

	count_name: STRING = "count"
	
	evaluate (id: NATURAL; driver: PC_SELECT_DRIVER) 
		local
			t: IS_TYPE
			v: PC_TOOL_VALUE
			fid, pid: NATURAL
		do
			if attached parent as p then
				p.evaluate (id, driver)
				if attached driver.source.type_at (p.type) as pt then
					t := pt
				end
				pid := p.ident_value
				if pid > 0 then
					driver.move_to (pid)
				end
			else
				t := driver.source.types [id]
				pid := id
			end
			if not attached field as f or else not f.has_name (name) then
				field := t.field_by_name (name)
			end
			if attached field as f
				and then f.offset >= 0 and then f.has_name (name)
			 then
				if t.is_special then
					if name.is_equal (count_name) then
						set_natural (driver.source.capacities [pid])
					else
						raise ("No such field.")
					end
				else
					v := driver.get_field_value (f, pid) 
					copy_value (v)
					if is_reference then
						fid := ident_value
						if fid = 0 then
							type := 0
						else
							type := driver.source.types [fid].ident
						end
					end
				end
			elseif name.is_empty then
				set_ident (id, driver.source.types[id].ident)
			elseif name.is_case_insensitive_equal (void_name) then
				set_ident (0, 0)
			elseif name.is_case_insensitive_equal (false_name) then
				set_boolean (False)
			elseif name.is_case_insensitive_equal (true_name) then
				set_boolean (True)
			else
				raise ("No such attribute.")
			end
		end
	
invariant
	
	when_evaluated: attached field as f implies f.fast_name.is_equal (name) 
		and attached parent

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
