note

	description: "Internal description of a class in a system."

class IS_CLASS_TEXT

inherit

	IS_NAME
		redefine
			is_less,
			three_way_comparison
		end

	PLATFORM
		undefine
			default_create,
			copy,
			is_equal,
			out
		end

create

	make,
	make_in_system

feature {} -- Initialization 

	make (id: INTEGER; nm: READABLE_STRING_8; fl: INTEGER; fn: like path;
			f: like features; p: like parents)
		require
			id_not_negative: id >= 0
			fl_not_negative: fl >= 0
		do
			ident := id
			fast_name := nm
			if attached fn as file then
				path := file.twin
			end
			flags := fl
			features := f
			parents := p
		ensure
			ident_set: ident = id
			name_set: has_name (nm)
			flags_set: flags = fl
			parents_set: parents = p
			features_set: features = f
		end

	make_in_system (cid, fl: INTEGER; nm: READABLE_STRING_8; f: IS_FACTORY)
		require
			valid_index: 0 < cid
			when_made: ident > 0 implies ident = cid
			nm_not_void: not nm.is_empty
		do
			ident := cid
			fast_name := nm
			flags := fl
			features := Void
			parents := Void
			scan_in_system (f)
		ensure
			ident_set: ident = cid
			name_set: has_name (nm)
		end
	
feature {IS_FACTORY} -- Initialization 

	scan_in_system (f: IS_FACTORY)
		do
		end

feature -- Access 

	ident: INTEGER

	flags: INTEGER

	path: detachable STRING

	is_expanded: BOOLEAN
		do
			Result := flags & Subobject_flag /= 0
		end

	is_basic: BOOLEAN
		do
			Result := flags & Basic_expanded_flag /= 0
		end

	is_separate: BOOLEAN
		do
			Result := flags & Proxy_flag /= 0
		end

	is_deferred: BOOLEAN
		do
			Result := flags & Memory_category_flag = 0
		end

	supports_invariant: BOOLEAN
		do
			Result := flags & Invariant_flag = 0
		end

	is_actionable: BOOLEAN
		do
			Result := flags & Actionable_flag /= 0
		end

	is_debug_enabled: BOOLEAN
		do
			Result := flags & Debugger_flag /= 0
		end

	parent_count: INTEGER
		note
			return: "Number of direct parent classes."
		do
			if attached parents as pp then
				Result := pp.count
			end
		end

	valid_parent (i: INTEGER): BOOLEAN
		do
			Result := 0 <= i and then i < parent_count
		ensure
			validity: Result = (0 <= i and then i < parent_count)
		end

	parent_at (i: INTEGER): IS_CLASS_TEXT
		note
			return: "The `i'-th direct parent."
		require
			valid_index: valid_parent (i)
		local
			pp: Like parents
		do
			pp := parents
			check attached pp end
			Result := pp [i]
		end

	feature_count: INTEGER
		note
			return: "Number of features."
		do
			if attached features as ff then
				Result := ff.count
			end
		end

	valid_feature (i: INTEGER): BOOLEAN
		do
			Result := 0 <= i and then i < feature_count
		ensure
			validity: Result = (0 <= i and then i < feature_count)
		end

	feature_at (i: INTEGER): IS_FEATURE_TEXT
		note
			return: "The `i'-th feature."
		require
			valid_index: valid_feature (i)
		local
			ff: like features
		do
			ff := features
			check attached ff end
			Result := ff [i]
		end

feature -- Status 

	has_feature (f: attached like feature_at): BOOLEAN
		local
			i: INTEGER
		do
			from
				i := feature_count
			until Result or else i = 0 loop
				i := i - 1
				Result := f.is_equal (feature_at (i))
			end
		end

	feature_of_line (l: INTEGER): detachable like feature_at
		require
			positive: l > 0
		local
			i: INTEGER
		do
			from
				i := feature_count
			until attached Result or else i = 0 loop
				i := i - 1
				Result := feature_at (i)
				if attached Result as r and then (r.first_line > l
																					or else r.last_line < l) then
					Result := Void
				end
			end
		ensure
			when_found: attached Result as r implies r.first_line <= l
									and then l <= r.last_line
		end

feature -- Status setting 

	invalidate_path
		note
			action: "Indicate `path' as invalid (e.g. not existing or too old)."
		do
			path := Void
		ensure
			no_path: not attached path
		end

feature {IS_SYSTEM} -- Status setting 

	set_features (ff: like features)
		do
			features := ff
		ensure
			features_set: features = ff
		end
	
feature -- Comparison 

	is_less alias "<" (other: IS_CLASS_TEXT): BOOLEAN
		note
			return: "Comparison by name."
		do
			Result := fast_name < other.fast_name
		end

	three_way_comparison (other: IS_CLASS_TEXT): INTEGER
		note
			return: "Comparison by name."
		do
			Result := Precursor (other)
		end
	
	descendance (other: IS_CLASS_TEXT): INTEGER
		note
			return:
			"[
			 How good does `Current' conform to `other'?
			 `Result=0' means exact match, `Result=Maximum_integer' means no match.
			 other value means `other' is a parent class.
			 ]"
		local
			i, p: INTEGER
		do
			if other.ident /= ident then
				Result := {INTEGER}.max_value
				from
					i := parent_count
				until i = 0 loop
					i := i - 1
					p := parent_at (i).descendance (other)
					if p < Result then
						Result := p + 1
					end
				end
			end
		ensure
			not_negative: 0 <= Result
		end
	
	is_descendant (other: IS_CLASS_TEXT): BOOLEAN
		note
			return: "Does `Current' inherit from `other'?"
		do
			Result := descendance (other) < {INTEGER}.max_value
		end

feature -- Searching 

	feature_by_name (nm: READABLE_STRING_8): detachable like feature_at
		note
			return: "[
				Index of `Current's feature with name `nm'.
				`Void' if no such feature exists.
				]"
		local
			i: INTEGER
		do
			from
				i := feature_count
			until attached Result or else i = 0 loop
				i := i - 1
				if attached feature_at (i) as f and then f.has_name (nm) then
					Result := f
					i := 0
				end
			end
		ensure
			when_found: attached Result as r implies r.has_name (nm)
									and then attached features as ff and then ff.has (r)
		end

	feature_by_line (l: INTEGER): detachable like feature_at
		note
			return:
			"[
			 Index of `Current's feature at line `l'
			 `Void' if no such feature exists.
			 ]"
		require
			positive: l > 0
		local
			i: INTEGER
		do
			from
				i := feature_count
			until attached Result or else i = 0 loop
				i := i - 1
				if attached feature_at (i) as f then
					if f.first_line <= l and then l <= f.last_line then
						Result := f
						i := 0
					end
				end
			end
		end

feature -- Output 

	append_indented (s: STRING; indent, indent_increment: INTEGER)
		note
			action: "Printable format of `Current' closed by a new line character."
			s: "STRING to be extended"
			indent: "size of indentation"
			indent_increment: "size of indentation increment used within the routine"
		require
			indent_not_neagive: indent >= 0
			increment_not_negative: indent_increment >= 0
		do
			pad_right (s, indent)
			append_name (s)
		end

feature {IS_SYSTEM} -- Construction from C 

	add_parent(p: like parent_at)
		do
			if attached parents as pp then
				pp.add (p)
			else
				create parents.make_1 (p)
			end
		ensure
			p_added: parents.has (p)
		end

feature {IS_BASE} -- Implementation 

	parents: detachable IS_SEQUENCE [like parent_at]

	features: detachable IS_SEQUENCE [like feature_at]

feature {IS_NAME} -- Implementation 

	fast_name: STRING_8

feature {IS_BASE} -- Implementation 

	class_pattern: IS_CLASS_TEXT
		local
			p: like parents
			f: like features
		once
			create Result.make (0, no_name, 0, Void, f, p)
		end

invariant

	ident_not_negative: ident >= 0

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
