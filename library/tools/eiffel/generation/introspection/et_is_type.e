note

	description: "Compile time description of types in an Eiffel system."

deferred class ET_IS_TYPE

inherit

	IS_TYPE
		export
			{ET_C_SOURCE, IS_SYSTEM}
				set_bytes
		redefine
			base_class,
			generic_at,
			effector_at,
			field_at,
			constant_at,
			routine_at,
			set_fields,
			is_equal
		end

	ET_IS_ORIGIN [ET_DYNAMIC_TYPE, IS_TYPE]	
			
	KL_IMPORTED_STRING_ROUTINES
		export
			{} all
			{ANY}
				copy,
				is_equal,
				out
		undefine
			default_create,
			copy,
			is_equal,
			out
		end

feature {} -- Initialization 

	declare (o: like origin; id: INTEGER; s: ET_IS_SYSTEM)
		note
			action: "Create `Current' according to `o'."
			id: "type ident"
		do
			make_origin (o)
			ident := id
			s.origin_table.force (Current, o)
			s.set_type (Current)
			s.force_class (o.base_class)
			base_class := s.last_class
			flags := compute_flags (id)
		ensure
			origin_set: origin = o
			ident_set: ident = id
		end
	
	declare_from_pattern (o: like origin; p: like Current; s: ET_IS_SYSTEM)
		local
			queries: ET_DYNAMIC_FEATURE_LIST
			q: ET_DYNAMIC_FEATURE
			a: ET_IS_FIELD
			buffer: like field_buffer
			nm: STRING
			i, n: INTEGER
		do
			copy (p)
			defined := False
			make_origin (o)
			s.origin_table.force (Current, o)
			ident := o.id
			s.force_class (o.base_class)
			base_class := s.last_class
			if not o.is_alive then
				flags := 0
			end
			associated := p
			s.set_type (Current)
			generics := Void
			effectors := Void
			fields := Void
			routines := Void
			last_routine := Void
			internal_hash_code := 0
			n := p.generic_count
			if n > 0 then
				from 
					create generics.make (n, Current)
				until n = 0 loop
					n := n - 1
					generics.add (s.below_top_type (n))
				end
			end
			if o.is_alive and then s.needs_attributes then
				queries := o.queries
				from
					i := queries.count
					n := 0
					buffer := field_buffer
				until i = 0 loop
					q := queries.item (i)
					nm := q.static_feature.lower_name
					if q.is_attribute and attached p.field_by_name (nm) as pa then
						create a.declare_from_pattern (q, pa, Current, n, s)
						n := n + 1
						buffer.push (a)
					end
					i := i - 1
				end
				if n > 0 then
					create fields.make (n, buffer.top)
					from
						i := n
					until i = 0 loop
						i := i - 1
						fields.add (buffer.top)
						buffer.pop (1)
					end
				end
			end
		end
	
feature -- Initialization 

	define (s: ET_IS_SYSTEM)
		note
			action: "Complete construction of `Current'."
		local
			list: ET_DYNAMIC_TYPE_SET
			i: INTEGER
			detach: BOOLEAN
		do
			if not defined then
				defined := True
				if attached base_class as bc then
					bc.define (s)
				end
				from
					i := generic_count
				until i = 0 loop
					i := i - 1
					generic_at (i).define (s)
				end
				from
					i := field_count
				until i = 0 loop
					i := i - 1
					if valid_field (i) then
						field_at (i).define (s)
					end
				end
				from
					i := constant_count
				until i = 0 loop
					i := i - 1
					if valid_constant (i) then
						constant_at (i).define (s)
					end
				end
				from
					i := routine_count
				until i = 0 loop
					i := i - 1
					if valid_routine (i) then
						routine_at (i).define (s)
					end
				end
				if s.needs_effectors then
					list := origin.conforming_dynamic_types
					effectors := s.type_set (Current, list, is_subobject)
					from
						i := effector_count
					until i = 0 loop
						i := i - 1
						effector_at (i).define (s)
					end
				end
				fast_name := out
			end
		end

feature -- Access 

	base_class: ET_IS_CLASS_TEXT

	generic_at (i: INTEGER): ET_IS_TYPE
		do
			Result := generics [i]
		end

	effector_at (i: INTEGER): ET_IS_TYPE
		do
			Result := effectors [i]
		end

	field_at (i: INTEGER): ET_IS_FIELD
		do
			Result := fields [i]
		end

	constant_at (i: INTEGER): ET_IS_CONSTANT
		do
			Result := constants [i]
		end

	routine_at (i: INTEGER): ET_IS_ROUTINE
		do
			Result := routines [i]
		end

	last_routine: like routine_at
			-- Routine provided by `force_routine'. 

	associated: like Current
			-- Type description of `IS_*' if `Current' describes `ET_IS_*',
			-- otherwise, `Current'.
	
feature -- Status setting

	resolve_ident
		do
			ident := origin.id
		end
	
	add_effector (e: like effector_at)
		do
			if not attached effectors then
				create effectors.make_1 (e)
			else
				effectors.add (e)
			end
		ensure
			has_effector: attached effectors as ee and then ee.has (e)
		end
	
	set_fields (aa: IS_SEQUENCE [IS_FIELD])
		do
			if attached {IS_SEQUENCE [ET_IS_FIELD]} aa as ff then
				-- workaround spurious catcall
				fields := ff
			end
		end

feature -- Searching 

	routine_by_origin (o: ET_DYNAMIC_FEATURE; s: ET_IS_SYSTEM): detachable like routine_at
		note
			return: "Current's routine having origin `o'."
			o: "original routine, possible as Precursor"
		do
			s.origin_table.search (o)
			if s.origin_table.found and then
				attached {like routine_at} s.origin_table.found_item as r
			 then
				Result := r
			end
		ensure
			when_found: attached Result as r implies r.origin = o
		end

feature -- Factory 

	force_routine (f: ET_DYNAMIC_FEATURE; as_create: BOOLEAN; s: ET_IS_SYSTEM)
		note
			action:
			"[
			 Search routine corresponding to `f'.
			 Create `Result' if not found.
			 ]"
			f: "original routine"
		require
			is_routine: f.static_feature.is_function
									or else f.static_feature.is_procedure
		local
			last: like last_routine
			n: INTEGER
		do
			last := routine_by_origin (f, s)
			if attached last as l and then l.is_creation /= as_create then
				last := Void
			end
			if not attached last then
				create last.declare (f, Current, s)
				if attached routines then
				else
					create routines
				end
				routines.add (last)
				s.origin_table.force (last, f)
			end
			last_routine := last
		ensure
			not_void: attached last_routine
		end

	force_anonymous_routine (r: ET_IS_ROUTINE)
		require
			anonymous: r.is_anonymous
			has_routines: routines /= Void
		do
			routines.add (r)
		end

	force_precursor_routine (r: ET_IS_ROUTINE)
		require
			is_precursor: r.is_precursor
		do
			if routines = Void then
				create routines
			end
			routines.add (r)
		ensure
			routine_set: routines.has (r)
		end
	
feature -- Status setting 

	add_flag (fl: like flags)
		do
			flags := flags | fl
		ensure
			flag_added: flags = old flags | fl
		end

feature -- Comparison
	
	is_equal (other: ET_IS_TYPE): BOOLEAN
		do
			Result := ident = other.ident
		end

feature -- ET_IS_ORIGIN 

	print_name (file: KI_TEXT_OUTPUT_STREAM; g: ET_INTROSPECT_GENERATOR)
		do
			g.print_type_name (origin, file)
		end

	print_boxed_name (file: KI_TEXT_OUTPUT_STREAM; g: ET_INTROSPECT_GENERATOR)
		require
			is_subobject: is_subobject
		do
			g.print_boxed_type_name (origin, file)
		end

	print_default (file: KI_TEXT_OUTPUT_STREAM; g: ET_INTROSPECT_GENERATOR)
		do
			g.print_default_name (origin, file)
		end

feature {ET_IS_TYPE} -- Additional construction
	
	declare_fields (s: ET_IS_SYSTEM)
		note
			action: "Create all variable fields."
		require
			no_fields: field_count = 0
		local
			qq: ET_DYNAMIC_FEATURE_LIST
			df: ET_DYNAMIC_FEATURE
			buffer: like field_buffer
			f: ET_IS_FIELD
			i, n, na: INTEGER
		do
			if s.needs_attributes and then origin.is_alive then
				buffer := field_buffer
				qq := origin.queries
				from
					i := qq.count
				until i = 0 loop
					df := qq.item (i)
					if df.is_attribute then
						create f.declare (df, Current, s)
						na := na + 1
						buffer.push (f)
					end
					i := i - 1
				end
				from
					i := na
				until i = 0 loop
					i := i - 1
					if not attached fields then
						if is_special then
							n := 2
						else
							n := na
						end
						create fields.make (n, buffer.top)
					end
					fields.add (buffer.top)
					buffer.pop (1)
				end
			end
		end

	declare_routines (s: ET_IS_SYSTEM)
		note
			action: "Create all routines."
		require
			no_routines: routine_count = 0
		local
			queries, procedures: ET_DYNAMIC_FEATURE_LIST
			dynamic: ET_DYNAMIC_FEATURE
			static: ET_FEATURE
			buffer: like routine_buffer
			r: detachable ET_IS_ROUTINE
			rc: ET_IS_ROUTINE
			nm: STRING
			i, nr: INTEGER
			needed, onces_only: BOOLEAN
		do
			if origin.is_alive then
				buffer := routine_buffer
				nr := buffer.count
				needed := s.needs_routines
				onces_only := not needed and s.needs_once_values
				if needed or else onces_only then
					from
						queries := origin.queries
						i := queries.count
					until i = 0 loop
						dynamic := queries.item (i)
						if not s.origin_table.has (dynamic) then
							static := dynamic.static_feature
							i := i - 1
							r := Void
							if needed or else (onces_only and then static.is_once) then
								if not (dynamic.is_inlined or else dynamic.is_builtin)
									and then dynamic.is_built and then dynamic.is_function
								 then
									if not attached r then
										if (needed or else onces_only) and then
											not (is_basic and then attached static.alias_name)
										 then
											if static.is_once then
												s.force_once (dynamic, Current)
												r := s.last_once
											else
												create r.declare (dynamic, Current, s)
											end
										end
									end
									if r /= Void then
										buffer.push (r)
										s.origin_table.force (r, dynamic)
									end
								else
								end
							end
						end
					end
					if is_basic then
						add_operators (buffer, s)
					end
					if needed then
						from
							procedures := origin.procedures
							i := procedures.count
						until i = 0 loop
							dynamic := procedures.item (i)
							if not s.origin_table.has (dynamic) then
								static := dynamic.static_feature
								i := i - 1
								r := Void
								if not (dynamic.is_inlined or else dynamic.is_builtin)
									and then dynamic.is_built
								 then
									if not attached r then
										create r.declare (dynamic, Current, s)
									end
									check attached r end
									buffer.push (r)
									s.origin_table.force (r, dynamic)
								end
							end
						end
					end
					-- To do: create invariant 
				elseif s.needs_default_creation then
					procedures := origin.procedures
					from
						i := procedures.count
					until i = 0 loop
						dynamic := procedures.item (i)
						static := dynamic.static_feature
						i := i - 1
						if dynamic.is_creation and then
							static.has_seed (s.origin.current_system.default_create_seed)
						 then
							if not s.origin_table.has (dynamic) then
								create rc.declare (dynamic, Current, s)
								s.origin_table.force (rc, dynamic)
								buffer.push (rc)
							end
						end
					end
				end
				nr := buffer.count - nr
				if nr > 0 and then routines = Void then
					create routines.make (nr, buffer.top)
				end
				from
				until nr = 0 loop
					routines.add (buffer.top)
					buffer.pop (1)
					nr := nr - 1
				end
			end
		end
	
feature {} -- Implementation 

	compute_flags (id: INTEGER): INTEGER
		do
			if attached base_class as bc then
				Result := bc.flags & Type_category_flag & Reference_flag.bit_not
				if (Result & Subobject_flag = 0) 
					and then attached origin as o and then o.is_alive
				 then
					Result := Result | Reference_flag
				end
			end
		end
	
	field_buffer: IS_STACK [ET_IS_FIELD]
		once
			create Result
		end

	routine_buffer: IS_STACK [ET_IS_ROUTINE]
		once
			create Result
		end
	
	add_operators (buffer: like routine_buffer; s: ET_IS_SYSTEM)
		require
			is_basic: is_basic
		do
		end
	
invariant
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
