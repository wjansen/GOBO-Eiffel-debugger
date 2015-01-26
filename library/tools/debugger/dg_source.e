note

	description:
		"[ 
		 Scanning the persistence closure of one memory object 
		 thereby transforming objects of a mutable introspection type 
		 to objects of the corresponding compiled type. 
		 ]"
	library: "Gobo Eiffel Tools Library"

class DG_SOURCE

inherit

	PC_MEMORY_SOURCE
		rename
			system as self_system,
			make as make_memory_source
		export
			{DG_TARGET} address
		redefine
			read_field_ident,
			process_ident,
			pre_object,
			post_object,
			pre_special,
			read_boolean,
			read_character,
			read_character_32,
			read_integer_8,
			read_integer_16,
			read_integer,
			read_integer_64,
			read_natural_8,
			read_natural_16,
			read_natural,
			read_natural_64,
			read_real,
			read_double,
			read_pointer,
			read_string,
			read_unicode,
			set_offset,
			set_indexed_offset,
			actual_object
		end

	KL_IMPORTED_STRING_ROUTINES
		undefine
			copy,
			is_equal,
			out
		end

create

	make

feature {NONE} -- Initialization 

	make (a_remote: like remote_system; a_self: like self_system;
			a_generator: ET_INTROSPECT_GENERATOR; a_top: ET_IS_SYSTEM)
		local
			t: IS_TYPE
			c: IS_CLASS_TEXT
			x: IS_FEATURE_TEXT
			r: IS_ROUTINE
			f: IS_FIELD
			a: IS_ARRAY [detachable IS_NAME]
			aa: ARRAY [IS_ARRAY[detachable IS_NAME]]
			any: ANY
			i, k: INTEGER
			ready: BOOLEAN
		do
			make_memory_source (a_self)
			remote_system := a_remote
			remote_to_self := a_generator.remote_to_self
			self_to_remote := a_generator.self_to_remote
			create remote_types.make (self_system.type_count, Void)
			create self_types.make (remote_system.type_count, Void)
			create data_offsets.make (31)
			create array_types.make_equal (5)
			array_types.put ("IS_ARRAY")
			array_types.put ("IS_SPARSE_ARRAY")
			array_types.put ("IS_SEQUENCE")
			array_types.put ("IS_SET")
			array_types.put ("IS_STACK")
			from
				i := self_system.type_count
			until i = 0 loop
				i := i - 1
				if attached self_system.type_at (i) as st then
					t := as_remote(st)
					if array_types.has (st.class_name) then
						from
							k := st.field_count
						until k = 0 loop
							k := k - 1
							f := st.field_at (k)
							if f.has_name ("data") then
								data_offsets.put (f.offset, st)
								t := as_remote (f.type)
								remote_types.force (t, st.ident)
								k := 0
							end
						end
					end
				end
			end
			if ready then
				-- Add certain types to the typeset of `last_ident':
				create a.make_1 (Void)
				a := a_top.all_classes
				a := a_top.all_types
				a := a_top.all_agents
				a := a_top.all_onces
				t := a_top.root_type
				a := t.effectors
				a := t.fields
				a := t.routines
				c := a_top.class_at (0)
				a := c.parents
				a := c.features
				r := t.routine_at (0)
				a := r.vars
				a := r.text.vars
				x := r.text.var_at (0)
				create aa.make_filled (a, 0, 1)
				aa.put (a, 0)
				last_ident := a
				last_string := ""
				last_unicode := last_string
				any := last_string
				any := last_unicode
				any := a_top.root_type
				any := a_top.root_type.field_at(0)
				any := a_top.root_creation_procedure
				any := a_top.once_at(0)
				any := a_top.origin_table.found_item
				last_ident := any
			end
		end
	
feature -- Access 

	remote_system: IS_SYSTEM
			-- Descriptors of the compilee system. 

	actual_object: detachable ANY
		do
			if valid_address then
				Result := Precursor 
			end
		end

feature {PC_DRIVER} -- Reading structure definitions 

	read_field_ident
		do
			Precursor
			if last_dynamic_type = Void then
				last_ident := void_ident
			end
		end

feature {PC_DRIVER} -- Push and pop data 

	pre_object (t: IS_TYPE; id: attached ANY)
		do
			Precursor (as_self (t), id)
			valid_address := t.is_alive
			if valid_address then
				last_ident := id
				in_string := t.is_string
				if in_string and then attached {STRING} last_ident as s then
					last_string.copy (s)
				elseif t.is_unicode and then attached {STRING_32} last_ident as u then
					last_unicode.copy (u)
				end
			else
				last_ident := void_ident
			end
		end

	post_object (t: IS_TYPE; id: attached ANY)
		do
			Precursor (t, id)
			valid_address := True
			in_string := False
		end

	pre_special (s: IS_SPECIAL_TYPE; cap: NATURAL; id: attached ANY)
		do
			Precursor (s, cap, id)
			valid_address := True
		end

feature {PC_DRIVER} -- Reading elementary data 

	read_boolean
		do
			if valid_address then
				Precursor
			else
				last_boolean := False
			end
		end

	read_character
		do
			if valid_address then
				Precursor
			else
				last_character := '%U'
			end
		end

	read_character_32
		local
			no_c32: CHARACTER_32
		do
			if valid_address then
				Precursor
			else
				last_character_32 := no_c32
			end
		end

	read_integer_8
		do
			if valid_address then
				Precursor
			else
				last_integer := 0
			end
		end

	read_integer_16
		do
			if valid_address then
				Precursor
			else
				last_integer := 0
			end
		end

	read_integer
		do
			if valid_address then
				Precursor
			else
				last_integer := 0
			end
		end

	read_integer_64
		do
			if valid_address then
				Precursor
			else
				last_integer_64 := 0
			end
		end

	read_natural_8
		do
			if valid_address then
				Precursor
			else
				last_natural := 0
			end
		end

	read_natural_16
		do
			if valid_address then
				Precursor
			else
				last_natural := 0
			end
		end

	read_natural
		do
			if valid_address then
				Precursor
			else
				last_natural := 0
			end
		end

	read_natural_64
		do
			if valid_address then
				Precursor
			else
				last_natural_64 := 0
			end
		end

	read_real
		do
			if valid_address then
				Precursor
			else
				last_real := 0
			end
		end

	read_double
		do
			if valid_address then
				Precursor
			else
				last_double := 0
			end
		end

	read_pointer
		local
			a0: like address
		do
			if valid_address then
				Precursor
			else
				last_pointer := a0
			end
		end

	read_string
		do
			if attached {STRING} as_any (address) as s then
				last_string.copy (s)
			else
				last_string.wipe_out
			end
		end

	read_unicode
		do
			if attached {STRING_32} as_any (address) as u then
				last_unicode.copy (u)
			else
				last_unicode.wipe_out
			end
		end

feature {NONE} -- Object location 

	set_offset (fd: like field)
		local
			a0: like address
			off: INTEGER
		do
			if address /= a0 then
				off := fd.offset
				valid_address := off >= 0
			else
				valid_address := False
			end
			if valid_address then
				offset := offset_sum + off
			end
		end

	set_indexed_offset (s: IS_SPECIAL_TYPE; n: NATURAL)
		local
			a0: like address
		do
			valid_address := address /= a0
			if valid_address then
				Precursor (s, n)
			end	
		end

feature {NONE} -- Type conversion 

	self_class: detachable IS_CLASS_TEXT
		note
			return:
			"[
			 Descriptor of a self type of the compiler.
			 Used for anchoring only.
			 ]"
		do
		ensure
			no_result: not attached Result
		end

	self_type: detachable IS_TYPE
		note
			return:
			"[
			 Descriptor of a self type of the compiler.
			 Used for anchoring only.
			 ]"
		do
		ensure
			no_result: not attached Result
		end

	self_special: detachable IS_SPECIAL_TYPE
		note
			return:
				"[
				 Descriptor of a self special type of the compiler.
				 Used for anchoring only.
				 ]"
		do
		ensure
			no_result: not attached Result
		end

	self_types: IS_SPARSE_ARRAY [like self_type]
			-- Types of the `self_system' at indices 
			-- corresponding to the system type idents. 

	remote_types: IS_SPARSE_ARRAY [like as_remote]
			-- Compiled types of the `remote_system' at indices 
			-- corresponding to the compiled type idents. 

	as_remote (a_self: attached like self_type): detachable IS_TYPE
		note
			return:
				"[
				 Descriptor of the compiled type in `remote_system'
				 corresponding to the self type `a_self'.
				 ]"
		local
			l_self: like as_self
			l_name: READABLE_STRING_8
			id, i, n: INTEGER
			failed: BOOLEAN
		do
			id := a_self.ident
			if remote_types.count > id then
				Result := remote_types [id]
			end
			if not attached Result as r then
				if a_self.is_agent and then attached {IS_AGENT_TYPE} a_self as a
					and then attached remote_system.agent_by_base_and_routine (as_remote (a.base), a.open_closed_pattern, a.routine_name) as r
				 then
					Result := r
				else
					l_name := a_self.class_name
					if self_to_remote.has (l_name) then
						l_name := self_to_remote.item (l_name)
					end
					from
						n := a_self.generic_count
					until failed or else i = n loop
						if attached as_remote (a_self.generic_at (i)) as g then
							remote_system.push_type (g.ident)
							i := i + 1
						else
							failed := True
						end
					end
					if not failed then
						Result := remote_system.type_by_class_and_generics (l_name, n, a_self.is_attached)
					end
					remote_system.pop_types (i)
				end
				if attached Result as remote then
					remote_types.force (remote, a_self.ident)
					associate (remote, a_self)
 					l_self := as_self (remote)
				end
			end
		ensure
			in_types: Result /= Void and then self_types [Result.ident] = a_self
		end

	as_self (a_remote: like as_remote): like self_type
		note
			return:
				"[
				 Descriptor of the type in `self_system' corresponding
				 to the compiled type `a_remote' in `remote_system'.
				 ]"
		local
			l_remote: like as_remote
			l_name: STRING
			id, i, n: INTEGER
			failed: BOOLEAN
		do
			id := a_remote.ident
			if self_types.count > id then
				Result := self_types.item (id)
			end
			if not attached Result then
				if a_remote.is_agent and then attached {IS_AGENT_TYPE} a_remote as a then
					Result := self_system.agent_by_base_and_routine
						(as_self (a.base), a.open_closed_pattern, a.routine_name)
				else
					l_name := a_remote.class_name
					if remote_to_self.has (l_name) then
						l_name := remote_to_self.item (l_name)
					end
					from
						n := a_remote.generic_count
					until failed or else i = n loop
						if attached as_self (a_remote.generic_at (i)) as g then
							self_system.push_type (g.ident)
							i := i + 1
						else
							failed := True
						end
					end
					if not failed then
						Result := self_system.type_by_class_and_generics (l_name, n, a_remote.is_attached)
					end
					self_system.pop_types (i)
				end
				if attached Result as self then
					self_types.force (self, a_remote.ident)
					l_remote := as_remote (self)
				end
			end
		ensure
			in_types: Result /= Void and then self_types.item (a_remote.ident) = Result
		end

feature {NONE} -- Implementation 

	in_string, valid_address: BOOLEAN

	data_offsets: DS_HASH_TABLE [INTEGER, like as_self]
	
	dynamic_type (a_type: like as_remote; at: like last_ident): like as_remote
		do
			if attached self_system.type_of_any (at, Void) as s then
				Result := as_remote (s)
			end
		end

	process_ident (id: like last_ident)
		local
			remote: like as_remote
			self: attached like self_type
			obj: like last_ident
			addr: POINTER
			off: INTEGER
		do
			last_ident := void_ident
			last_dynamic_type := Void
			last_count := 0
			last_capacity := 0
			obj := id
			if obj /= Void and then
				attached self_system.type_of_any (obj, Void) as st
			 then
				self := st
				remote := as_remote (self)
				if data_offsets.has (self) then
					off := data_offsets.item (self)
					addr := as_pointer (obj) + off
					addr := self_system.dereferenced (addr, self)
					obj := as_any (addr)
				end
			end
			if obj /= Void then
				if attached field_type as ft then
					last_dynamic_type := dynamic_type (ft, obj)
				elseif attached remote_system.any_type as at then
					last_dynamic_type := dynamic_type (at, obj)
				end
				if attached last_dynamic_type as t and then t.is_alive then
					last_ident := obj
					if t.is_special and then attached {IS_SPECIAL_TYPE} as_self (t) as s then
						if in_string then
							last_count := last_string.count.to_natural_32
							last_capacity := last_count
						else
							last_count := self_system.special_count (obj, s)
							last_capacity := self_system.special_capacity (obj, s)
						end
					elseif t.is_string and then attached {STRING} obj as s then
						last_string.copy (s)
					end
				end
			end
		end
	
	associate (to: attached like as_remote; what: attached like self_type)
		local
			f: IS_FIELD
			fw: detachable IS_FIELD
			i, n: INTEGER
		do
			to.set_bytes (what.instance_bytes)
			from
				n := to.field_count
			until i = n loop
				f := to.field_at (i)
				if to.is_normal then
					fw := what.field_by_name (f.name)
				elseif i < what.field_count then
					fw := what.field_at (i)
				else
					fw := Void
				end
				if fw /= Void then
					f.set_offset (fw.offset)
				end
				i := i + 1
			end
			if n > 0 then
				f := to.field_at (0)
				if f.name_has_prefix (underscore) then
					f.set_offset (0)
					if not f.has_name(id_name) then
						associate (f.type, what)
						self_types.force (what, f.type.ident)
					end
				end
			end
		end
	
	fast_name: STRING = ""

	id_name: STRING = "_id"

	underscore: STRING = "_"
	
	array_types: DS_HASH_SET [STRING]
		
	remote_to_self: DS_HASH_TABLE [STRING, STRING]
			-- Names of the mutable types corresponding 
			-- to names of the compiled types. 

	self_to_remote: DS_HASH_TABLE [STRING, STRING]
			-- Names of the compiled types corresponding 
			-- to names of the mutable types. 

invariant
	
note

	copyright: "Copyright (c) 2004-2010, Wolfgang Jansen, Eric Bezault and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

end
