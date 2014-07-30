note

	description: "Compile time description of a class in a system."

class ET_IS_CLASS_TEXT

inherit

	IS_CLASS_TEXT
		redefine
			parent_at,
			feature_at,
		end

	ET_IS_ORIGIN [ET_CLASS, IS_CLASS_TEXT]

	PC_ACTIONABLE
		undefine
			default_create,
			copy,
			is_equal,
			out
		redefine
			pre_store,
			post_store
		end
	
	KL_IMPORTED_STRING_ROUTINES
		undefine
			copy,
			is_equal,
			out
		end

create {ET_IS_SYSTEM}

	declare

feature {} -- Initialization 

	declare (o: like origin; id: INTEGER; s: ET_IS_SYSTEM)
		note
			action: "Create object associated to `o'."
		require
			positive_id: id > 0
		local
			p: ET_PARENT
			c: ET_IS_CLASS_TEXT
			i, n: INTEGER
		do
			make_origin (o)
			s.origin_table.force (Current, o)
			create fast_name.make_from_string (o.upper_name)
			path := o.filename
			ident := id
			if s.needs_parents and then attached o.parents as pl then
				from
					n := pl.count
				until i = n loop
					i := i + 1
					p := pl.parent (i)
					s.force_class (p.type.base_class)
					c := s.last_class
					if i = 1 then
						create parents.make (n, c)
					end
					parents.add (c);
				end
			end
			flags := compute_flags (s)
			if s.needs_feature_texts then
				create features
			end
		ensure
			origin_set: origin = o
			s_has_result: s.class_at (ident) = Current
		end

feature -- Initialization 

	define (s: ET_IS_SYSTEM)
		note
			action: "Fill parent list."
		local
			i: INTEGER
		do
			if not defined then
				defined := True
				if attached parents as ps then
					ps.default_sort
					from
						i := ps.count
					until i = 0 loop
						i := i - 1
						ps [i].define (s)
					end
				end
				if attached features as ff then
					ff.default_sort
					from
						i := feature_count
					until i = 0 loop
						i := i - 1
						ff [i].define (s)
					end
				end
			end
		end

feature -- Access 

	parent_at (i: INTEGER): ET_IS_CLASS_TEXT
		do
			if attached parents as ps then
				Result := ps [i]
			end
		end

	feature_at (i: INTEGER): ET_IS_FEATURE_TEXT
		do
			if attached features as fs then
				Result := fs [i]
			end
		end

	last_feature: detachable ET_IS_FEATURE_TEXT
			-- Feature provided by `force_text'. 

feature -- Status setting 

	set_origin (o: attached like origin)
		require
			no_origin: not attached origin
		do
			origin := o
		ensure
			origin_set: origin = o
		end

	set_flags (fl: INTEGER)
		require
			no_origin: not attached origin
		do
			flags := fl
		ensure
			flags_set: flags = fl
		end

	add_flag (f: INTEGER)
		do
			flags := flags | f
		ensure
			flag_added: flags = old flags | f
		end

	add_text (f: like feature_at)
		require
			has_features: attached features
			not_has_f: not features.has (f)
		do
			if features = Void then
				create features.make_1 (f)
			else
				features.add (f)
			end
		ensure
			added: features.has (f)
		end

feature -- Searching 

	feature_by_origin (o: ET_FEATURE; s: ET_IS_SYSTEM): like feature_at
		note
			return: "Current's feature having origin `o'."
			o: "original feature"
		local
			i: INTEGER
		do
			s.origin_table.search (o)
			if s.origin_table.found and then
				attached {attached like last_feature} s.origin_table.found_item as found
			 then
				Result := found
			end
		ensure
			when_found: attached Result as r implies r.origin = o
		end

	feature_by_dynamic (o: ET_DYNAMIC_FEATURE; s: ET_IS_SYSTEM): like feature_at
		note
			return: "Current's feature having origin `o'."
			o: "original feature"
		do
			s.origin_table.search (o)
			if s.origin_table.found and then
				attached {attached like last_feature} s.origin_table.found_item as found
			 then
				Result := found
			end
		ensure
			when_found: attached Result as r implies r.origin = o
		end

feature -- Factory
	
	force_feature (e: ET_IS_ORIGIN[ET_DYNAMIC_FEATURE, IS_NAME]; s: ET_IS_SYSTEM)
		note
			action:
			"[
			 Create `last_feature' corresponding to `e' and add it to `features'. 
		   If the implementing class is not `Current' then create also
			 a ET_IS_FEATURE_TEXT in that class and set `last_feature.renames'
			 to this other feature. 
			 ]"
			e: "entity of `last_feature' to generate"
		local
			impl: ET_IS_CLASS_TEXT
			static: ET_FEATURE
			last: like last_feature
			rt: ET_IS_ROUTINE_TEXT
			nm: STRING
		do
			static := e.origin.static_feature
			s.force_class (static.implementation_class)
			impl := s.last_class
			if impl = Current then
				static := static.implementation_feature
				s.origin_table.search (static)
				if s.origin_table.found 
					and then attached {ET_IS_FEATURE_TEXT} s.origin_table.found_item as f
				 then
					last := f
				end
				if not attached last then
					if attached {ET_IS_ROUTINE} e as r then
						create rt.declare_from_feature (static, Current, s)
							rt.make_locals (r, s)
							last := rt
					else
						create last.declare_from_feature (static, Current, s)
					end
					s.origin_table.force (last, static)
					features.add (last)
				end
			else
				impl.force_feature (e, s)
				last := impl.last_feature
				nm := static.lower_name
				if not STRING_.same_string (nm, last.fast_name) then
					if attached {ET_IS_ROUTINE} e as r then
						create {ET_IS_ROUTINE_TEXT} last.declare_renamed (nm, Current, last, s)
					else
						create last.declare_renamed (nm, Current, last, s)
					end
					features.add (last)
				end
			end
			last_feature := last
		end
	
feature -- ET_IS_ORIGIN 

	print_name (file: KI_TEXT_OUTPUT_STREAM; g: ET_INTROSPECT_GENERATOR)
		note
			action: "Do nothing."
			file: "file to write"
			g: "formatting tool"
		do
		end

feature {} -- PC_ACTIONABLE

	pre_store
		do
			preserve
			if not is_debug_enabled then
				features := Void
			end
		end
	
	post_store
		do
			restore
		end
	
feature {} -- Implementation 

	compute_flags (s: ET_IS_SYSTEM): INTEGER
		local
			xace: detachable ET_XACE_CLASS_OPTIONS
			xcl: detachable ET_XACE_CLUSTER
			i: INTEGER
			dg, dg_set: BOOLEAN
		do
			if attached origin as o then
				if o.is_expanded then
					Result := Result | Subobject_flag
					if o.is_basic then
						Result := Result | Basic_expanded_flag
					end
				elseif o.is_separate then
					Result := Result | Proxy_flag
				elseif not origin.is_deferred then
					Result := Result | Reference_flag
					if o.is_special_class then
						Result := Result | Flexible_flag
					elseif o.is_tuple_class then
						Result := Result | Tuple_flag
					elseif has_name("AGENT") then
						Result := Result | Agent_flag
					end
				end
				if not o.is_expanded then
					if o.is_actionable_class then
						Result := Result | Actionable_flag
					else
						from
							i := parent_count
						until i = 0 loop
							i := i - 1
							if parents [i].is_actionable then
								Result := Result | Actionable_flag
								i := 0
							end
						end
					end
				end
				if s.is_debugging and then (Result & Basic_expanded_flag) = 0 
					and then attached {ET_XACE_CLUSTER} o.group.cluster as xc then
					if attached xc.class_options as cop then
						from
							cop.start
						until cop.after loop
							xace := cop.item_for_iteration
							if STRING_.same_string (xace.class_name, fast_name) then
								dg_set := xace.options.is_debugger_declared
								if dg_set then
									dg := xace.options.debugger
								end
								cop.finish
							else
								cop.forth
							end
						end
					end
					from
						xcl := xc
					until dg_set or else not attached xcl loop
						if attached xcl.options as op then
							dg_set := op.is_debugger_declared
							if dg_set then
								dg := op.debugger
							end
						end
						xcl := xcl.parent
					end
					if not dg_set
						and then attached {ET_XACE_SYSTEM} o.group.universe as xs 
						and then attached xs.options as co
					 then
						dg := co.debugger
					end				
					if dg_set implies dg then
						Result := Result | Debugger_flag
					end
				else
					Result := Result | Debugger_flag
				end
			end
		end

	remote_names: DS_HASH_TABLE [STRING, STRING]
		once
			create Result.make (50)
			Result.put ("IS_RUNTIME_SYSTEM", "ET_IS_SYSTEM")
			Result.put ("IS_CLASS_TEXT", "ET_IS_CLASS_TEXT")
			Result.put ("IS_FEATURE_TEXT", "ET_IS_FEATURE_TEXT")
			Result.put ("IS_ROUTINE_TEXT", "ET_IS_ROUTINE_TEXT")
			Result.put ("IS_TYPE", "ET_IS_TYPE")
			Result.put ("IS_NORMAL_TYPE", "ET_IS_NORMAL_TYPE")
			Result.put ("IS_SPECIAL_TYPE", "ET_IS_SPECIAL_TYPE")
			Result.put ("IS_TUPLE_TYPE", "ET_IS_TUPLE_TYPE")
			Result.put ("IS_AGENT_TYPE", "ET_IS_AGENT_TYPE")
			Result.put ("IS_FIELD", "ET_IS_FIELD")
			Result.put ("IS_LOCAL", "ET_IS_LOCAL")
			Result.put ("IS_ROUTINE", "ET_IS_ROUTINE")
			Result.put ("IS_ONCE_CALL", "ET_IS_ONCE_CALL")
			Result.put ("IS_ONCE_VALUE", "ET_IS_ONCE_VALUE")
		end

	actionable_name: STRING = "PC_ACTIONABLE"
	
note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end