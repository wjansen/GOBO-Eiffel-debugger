note

	description: "Internal description of entities of an Eiffel class."

deferred class IS_ENTITY

inherit

	IS_NAME
		redefine
			is_less,
			is_name_less,
			name_has_prefix,
			append_name,
			hash_code
		end

feature {} -- Initialization 

	make_entity (nm: READABLE_STRING_8; t: like text)
		note
			action: "Initialize the entity description."
			nm: "name"
			t: "feature text"
		do
			fast_name := nm.twin
			text := t
			if nm.is_empty then
				-- make some atributes alive
				alias_name := no_name
			end
		ensure
			name_set: nm.is_equal (fast_name)
			text_set: text = t
		end

feature -- Access 

	target: like type
			-- Caller type; `Void' in case of a once routine or a constant
			-- (these are defined per class, not per type). 

	type: detachable IS_TYPE
		-- Type of the entity;
		-- `Void' if `Current' describes a procedure.

	is_attached: BOOLEAN
		note
			return: "Is `Current' of an attached type?"
		deferred
		ensure
			when_subobject: attached type as t and then t.is_subobject implies Result
		end

	is_subobject: BOOLEAN 

	type_set: detachable IS_SET [like type]
			-- Dynamic types of the entity. 

	text: detachable IS_FEATURE_TEXT
			-- The corresponding feature in class text. 

	alias_name: detachable READABLE_STRING_8
			-- Alias name of the entity (if any). 

feature {IS_BASE} -- Status setting 

	set_as_subobject
		do
			is_subobject := True
		ensure
			is_subobject: is_subobject
		end
	
feature -- COMPARABLE 

	is_less alias "<" (other: IS_ENTITY): BOOLEAN
		note
			return: "Compare `alias_name's if not void."
		do
			if same_name (other) then
			elseif attached alias_name as anm then
				Result := not other.is_name_less (anm)
			elseif attached other.alias_name as anm then
				Result := is_name_less (anm)
			else
				Result := Precursor (other)
			end
		end

	is_name_less (str: READABLE_STRING_8): BOOLEAN
		note
			return: "Compare also `alias_name' if not void."
		do
			if attached alias_name as anm then
				Result := STRING_.three_way_comparison (str , anm) = 1
			else
				Result := Precursor (str)
			end
		end

	name_has_prefix (s: READABLE_STRING_8): BOOLEAN
		note
			return:
		"[
		 Compare first `alias_name' for exact match
		 then, if no match, compare `fast_name' for initial match.
		 ]"
		do
			if attached alias_name as anm then
				Result := anm.same_string (s)
			else
				Result := Precursor (s)
			end
		end

feature -- Output 

	append_name (s: STRING)
		do
			if attached alias_name as anm then
				s.append (anm)
			else
				s.append (fast_name)
			end
		end

feature -- HASHABLE

	hash_code: INTEGER
		do
			Result := internal_hash_code
			if Result = 0 then
				Result := fast_name.hash_code
				if attached type as t then
					if Result < {INTEGER}.max_value / 2 then
						Result := Result |<< 1;
					end
					Result := Result.bit_xor (t.hash_code)
				end
				internal_hash_code := Result
			end
		end
	
feature {IS_NAME} -- Implementation 

	fast_name: STRING_8

	intenal_hash_code: INTEGER
	
invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
