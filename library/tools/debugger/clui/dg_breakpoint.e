note

	description: "Breakpoint description."

class DG_BREAKPOINT

inherit

	DG_GLOBALS
		redefine
			copy,
			out
		end

create

	make

feature {NONE} -- Initialization 

	make (i: INTEGER; def_lr: detachable DG_LINE_RANGE)
		do
			ident := i
			enabled := True
			if attached def_lr as dlr then
				range := dlr.twin
			end
			create watch_value.make (0)
		ensure
			ident_set: ident = i
			range_set: attached def_lr as dlr implies attached range as r and then dlr.is_equal (r)
		end

feature -- Access 

	ident: INTEGER

	range: detachable DG_LINE_RANGE

	catch_key: like no_command

	watch_address: POINTER

	watch_value: DG_EXPRESSION

	old_watch: detachable DG_EXPRESSION

	like_type: detachable IS_TYPE

	from_stack_level: INTEGER

	if_condition: detachable DG_EXPRESSION

	do_action: detachable DG_EXPRESSION

	enabled, trace_only: BOOLEAN

	msg_str: STRING = "12345678901234567890"


	has_catch: BOOLEAN
		do
			Result := attached catch_key
		end

	has_range: BOOLEAN
		do
			Result := attached range
		end

	has_watch: BOOLEAN
		do
			Result := attached old_watch
		end

	has_stack: BOOLEAN
		do
			Result := from_stack_level > 0
		end

	has_automatic_increasing_stack: BOOLEAN

	has_like: BOOLEAN
		do
			Result := attached like_type
		end

	has_if: BOOLEAN
		do
			Result := attached if_condition
		end

	has_do: BOOLEAN
		do
			Result := attached do_action
		end

	watch_differ: BOOLEAN

	prompt_count: INTEGER = 18


feature -- Basic operation 

	match (ds: IS_STACK_FRAME; reason: INTEGER; ss: INTEGER): INTEGER
		local
			l: INTEGER
			ok: BOOLEAN
		do
			Result := No_match
			ok := enabled and then not has_catch
			if ok and then attached range then
				inspect reason
				when Instruction_break, Call_break, Assignment_break, End_routine_break then
					l := ds.line
					ok := match_line (ds.routine.home, l)
				else
					ok := False
				end
			end
			if ok then
				Result := match_conditions (ds, ss)
			end
		ensure
			like_disabled: not enabled implies Result = No_match
		end

	match_catch (ds, resc: IS_STACK_FRAME; reason, ss: INTEGER): INTEGER
		local
			text: detachable IS_FEATURE_TEXT
			r: INTEGER
			ok: BOOLEAN
		do
			Result := No_match
			inspect reason
			when Rescue_exception then
				r := Routine_failure
			when Loop_invariant then
				r := Loop_variant
			when Out_of_memory then
				r := No_more_memory
			when Floating_point_exception, External_exception, Exception_in_signal_handler, Operating_system_exception, Io_exception, Com_exception, Runtime_io_exception, Eiffel_runtime_fatal_error then
				r := Signal_exception
			else
				r := reason
			end
			ok := enabled and then attached catch_key as key and then key.code >= r
			if ok and then attached range as rng then
				ok := not attached rng.cls as c or else resc.routine.home = c
				if ok then
					if rng.first_line > 0 and then attached rng.cls as cls then
						text := cls.feature_of_line (rng.first_line)
					end
					if attached text as x then
						ok := x.same_name (resc.routine)
					end
				end
			end
			if ok then
				Result := match_conditions (ds, ss)
			end
		end

	match_line (cls: IS_CLASS_TEXT; l: INTEGER): BOOLEAN
		require
			range_not_void: attached range
		do
			Result := enabled and then (attached range as r and then r.match (cls, l))
		ensure
			like_disabled: not enabled implies not Result
		end

feature -- Status setting 

	clear
		do
			range := Void
			catch_key := Void
			old_watch := Void
			watch_address := default_pointer
			from_stack_level := 0
			has_automatic_increasing_stack := False
			like_type := Void
			if_condition := Void
			do_action := Void
			trace_only := False
		end

	set_range (r: like range)
		note
			action: "Set range as copy of `r'."
		local
			c, l, p: INTEGER
		do
			if attached r as r_ then
				if attached range as rng then
					rng.copy (r_)
				else
					range := r.twin
				end
			else
				range := Void
			end
			if attached range as rng then
				rng.set_count (1)
				if attached rng.cls as rc then
					l := rng.first_line
					c := rng.column
					if attached {IS_ROUTINE_TEXT} rc.feature_of_line (l) as rt then
						p := rt.get_next_position (rt.position_as_integer (l, c))
						if p > 0 then
							l := rt.line_of_position (p)
							c := rt.column_of_position (p)
							rng.set_line_column (l, c)
						end
					end
				end
			end
		ensure
			range_set: (not attached r xor attached range)
								 or else (attached r as r_ and then attached range as rng
													and then rng.is_equal (r))
		end

	set_catch (key: like no_command)
		do
			catch_key := key
		ensure
			catch_key = key
		end

	set_watch (ex: detachable DG_EXPRESSION; ds: IS_STACK_FRAME)
		require
			when_ex: attached ex as e implies e.has_result
		local
			off: INTEGER
		do
			if attached ex as e then
				e.compute (ds, value_stack)
				if attached e.in_object as obj then
					if attached e.bottom as val then
						if attached {IS_FIELD} val.entity as f then
							off := f.offset
						elseif attached {IS_local} val.entity as l then
							off := l.offset
						else
							raise (Not_watchable)
						end
						watch_value := val
						watch_address := as_pointer (obj) + off
						if attached old_watch as ow then
							ow.clear_value
						else
							create old_watch.make (0)
						end
						check attached old_watch end
						old_watch.copy_value (watch_value)
						old_watch.fix_value
						value_stack.pop (1)
						watch_differ := False
					end
				else
					raise (Not_watchable)
				end
			else
				watch_value := Void
				old_watch := Void
				watch_address := default_pointer
			end
		end

	set_stack_level (n: INTEGER)
		require
			not_negative: 0 <= n
		do
			from_stack_level := n
		ensure
			from_set: from_stack_level = n
		end

	set_automatic_stack (auto: BOOLEAN)
		do
			has_automatic_increasing_stack := auto
		ensure
			has_automatic_increasing_stack = auto
		end

	set_type (t: like like_type)
		do
			like_type := t
		ensure
			like_set: like_type = t
		end

	set_condition (c: like if_condition)
		do
			if_condition := c
		ensure
			if_set: if_condition = c
		end

	set_action (a: like do_action)
		do
			do_action := a
		ensure
			do_action_set: do_action = a
		end

	set_trace_only (b: BOOLEAN)
		do
			trace_only := b
		ensure
			trace_only = b
		end

	set_enabled (b: BOOLEAN)
		do
			enabled := b
		ensure
			enabled_set: enabled = b
		end

	update (m: INTEGER; ss: INTEGER; ds: IS_STACK_FRAME)
		do
			inspect m
			when Break_match, Trace_match then
				if from_stack_level > 0 and then has_automatic_increasing_stack then
					from_stack_level := from_stack_level.max (ss + 1)
				end
			else
			end
			if watch_differ and then attached watch_value as wv then
				wv.compute (ds, value_stack)
				check attached old_value end
				old_watch.copy_value (watch_value)
				if old_watch.is_shared then
					old_watch.fix_value
				end
				watch_differ := False
			end
		end

	correct_if_condition
		require
			has_if: has_if
		do
			if attached if_condition as ic and then attached ic.entity then
				ic.correct_for_type (debuggee.boolean_type)
			else
				if_condition := Void
			end
		end

	correct_do_action
		require
			do_action_not_void: attached do_action
		do
			if attached do_action as da then
				da.correct
				if attached da.entity then
				else
					do_action := Void
				end
			end
		end

feature -- Duplication 

	copy (other: like Current)
		local
			id: INTEGER
		do
			id := ident
			standard_copy (other)
			other.set_condition (Void)
			other.set_action (Void)
			if attached range as r then
				range := r.twin
			end
			ident := id
		end

feature -- Output 

	out: STRING
		do
			create Result.make (100)
			append_out (Result)
		end

	append_out (s: STRING)
		do
			append_short_out (s)
			if attached catch_key as key and then attached key.help_line as hl then
				s.append (once "%N  catch  : ")
				if not hl.is_empty then
					s.append (hl)
				end
			end
			if attached range as r and then attached r.cls as cls then
				s.append (once "%N  at     : ")
				cls.append_name (s)
				if attached r.text as rt then
					s.extend ('.')
					rt.append_name (s)
				elseif r.first_line > 0 then
					s.extend (':')
					s.append_integer (r.first_line)
					if r.column > 0 then
						s.extend (':')
						s.append_integer (r.column)
					end
				end
			end
			if from_stack_level > 0 then
				s.append (once "%N  depth  : ")
				s.append_integer (from_stack_level)
				if has_automatic_increasing_stack then
					s.append (once " ++")
				end
			end
			if has_watch and then attached watch_value as ex then
				s.append (once "%N  watch  : ")
				s.append (watch_address.out)
				s.append (once " = ")
				s.append (ex.c_out)
			end
			if attached like_type as lt then
				s.append (once "%N  type   : ")
				lt.append_name (s)
			end
			if attached if_condition as ic then
				s.append (once "%N  if     : ")
				ic.append_single (s)
			end
			if attached do_action as da then
				s.append (once "%N  print  : ")
				da.append_detailed (s)
			end
			s.append (once "%N  enabled: ")
			if enabled then
				s.append (once "yes")
			else
				s.append (once "no")
			end
		end

	append_short_out (s: STRING)
		do
			if trace_only then
				s.append (once "Tracepoint ")
			else
				s.append (once "Breakpoint ")
			end
			s.append_integer (ident)
		end

	append_as_line (s: STRING)
		do
			if attached catch_key as key then
				s.append (once " catch ")
				s.append (key.name)
			end
			if attached range as r and then attached r.cls as cls then
				s.append (once " at ")
				cls.append_name (s)
				if attached r.text as rt then
					s.extend ('.')
					rt.append_name (s)
				elseif r.first_line > 0 then
					s.extend (':')
					s.append_integer (r.first_line)
					if r.column > 0 then
						s.extend (':')
						s.append_integer (r.column)
					end
				end
			end
			if has_watch then
				s.append (once " watch ")
				s.append (watch_address.out)
				s.extend ('=')
				s.append (watch_value.out)
			end
			if from_stack_level > 0 then
				s.append (once " depth ")
				s.append_integer (from_stack_level)
				if has_automatic_increasing_stack then
					s.append (once " ++")
				end
			end
			if attached like_type as lt then
				s.append (once " type ")
				lt.append_name (s)
			end
			if attached if_condition as ic then
				s.append (once " if ")
				ic.append_out (s)
			end
			if attached do_action as da then
				s.append (once " print ")
				da.append_out (s)
			end
			if trace_only then
				s.append (once " cont")
			end
		end

feature {NONE} -- Implementation 

	Not_watchable: STRING = "Expression not watchable."

	watch_type: IS_TYPE
		local
			nt: detachable IS_TYPE
		do
			if attached old_watch as ow and then attached ow.type as owt then
				Result := owt
			else
				nt := debuggee.none_type
				check attached nt end
				Result := nt
			end
		end

	match_conditions (ds: IS_STACK_FRAME; ss: INTEGER): INTEGER
		local
			t: like like_type
			ok, retried: BOOLEAN
		do
			watch_differ := False
			if not retried then
				Result := No_match
				ok := True
				if ok and then from_stack_level > 0 then
					ok := ss >= from_stack_level
				end
				if ok and then has_watch and then attached old_watch as ow then
					watch_differ := not ow.compare_to (watch_value)
					ok := watch_differ
				end
				if ok then
					if attached like_type as lt then
						t := ds.target_type
						check attached t end
						if not t.is_subobject then
							t := debuggee.type_of_any (as_any (ds.target), t)
						end
						check attached t end
						ok := t.does_effect (lt)
					end
				end
				if ok and then attached if_condition as cond then
					if ds.routine.uses_current then
						cond.compute (ds, value_stack)
						t := cond.bottom.type
						check attached t end
						if not t.is_boolean then
							value_stack.pop (1)
							cond.bottom.set_entity (Void)
							raise (once "Not a boolean expression.")
						end
						ok := cond.bottom.as_boolean
						value_stack.pop (1)
					else
						ok := False
					end
				end
				if ok and then Result = No_match then
					if trace_only then
						Result := Trace_match
					else
						Result := Break_match
					end
				end
			end
		rescue
			if exception = Signal_exception and then signal_number = Interrupt_signal then
			else
				Result := Error_match
				retried := True
				retry
			end
		end

invariant

	when_watch: attached watch_value as wv implies wv.has_result and attached wv.parent 
		and attached old_value and watch_address /= default_pointer

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
