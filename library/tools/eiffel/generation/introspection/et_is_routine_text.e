note

	description:

		"Compile time description of arguments and local vars of a routine."

class ET_IS_ROUTINE_TEXT

inherit

	IS_ROUTINE_TEXT
		redefine
			tuple_labels,
			home, 
			renames,
			var_at,
			inline_text_at
		end

	ET_IS_FEATURE_TEXT
		rename
			make as make_feature
		undefine
			has_position
		redefine
			declare_from_feature,
			define,
			tuple_labels,
			home,
			renames
		end

create

	declare_from_declaration,
	declare_from_agent

create {ET_IS_CLASS_TEXT}

	declare_from_feature,
	declare_renamed

feature {} -- Initialization 

	declare_from_feature (f: ET_FEATURE; h: like home; s: ET_IS_SYSTEM)
		local
			k, n: INTEGER
		do
			Precursor (f, h, s)
			flags := Routine_flag
			if f.is_once then
				flags := flags | Once_flag
			end
 			if attached {ET_INTERNAL_ROUTINE} f as ir then
				set_compound_positions (ir.compound, ir.rescue_clause, ir.end_keyword)
			end
		end

	declare_from_agent (a: ET_INTERNAL_ROUTINE_INLINE_AGENT;
											r: ET_IS_ROUTINE; h: like home; s: ET_IS_SYSTEM)
		local
			kw: ET_KEYWORD
			fl: INTEGER
		do
			fl := Routine_flag
			if r.is_once then
				fl := fl | Once_flag
			end
			if attached r.alias_name as anm then
				-- workaround to avoid a call on void target:
				make (r.fast_name, anm, fl, 0, 0, Void,
					r.argument_count, r.local_count, r.scope_var_count, Void)
			else
				make (r.fast_name, Void, fl, 0, 0, Void,
					r.argument_count, r.local_count, r.scope_var_count, Void)
			end
			home := h
			make_locals (r, s)
			kw := a.end_keyword
			set_positions (a.agent_keyword.position, kw.last_position)
			set_compound_positions (a.compound, a.rescue_clause, kw)
		end

feature -- Initialization 

	define (s: ET_IS_SYSTEM)
		local
			i: INTEGER
		do
			if not defined then
				Precursor (s)
				if attached vars as vv then
					from
						i := vv.count
					until i = 0 loop
						i := i - 1
						if attached vv [i] as v then
							v.define (s)
						end
					end
				end
			end
		end

feature -- Access 

	home: ET_IS_CLASS_TEXT

	tuple_labels: detachable IS_SEQUENCE [ET_IS_FEATURE_TEXT]

	var_at (i: INTEGER): detachable ET_IS_FEATURE_TEXT
		do
			if attached vars as vv then
				Result := vv [i]
			end		
		end

	inline_text_at (i: INTEGER): ET_IS_ROUTINE_TEXT
		do
			if attached inline_texts as it then
				Result := it [i]
			else
				-- should not happen, just to make routine void safe:
				Result := Current
			end
		end
	
feature -- Status setting 

	copy_instruction_positions (pos: SPECIAL[NATURAL])
		local
			n: INTEGER
		do
			n := pos.count
			if n > 0 then
				create instruction_positions.make_empty (n)
				instruction_positions.insert_data(pos, 0, 0, n)
			else
				instruction_positions := Void
			end
		end

	add_inline (rt: ET_IS_ROUTINE_TEXT)
		do
			if attached inline_texts then
			else
				create inline_texts
			end
			inline_texts.add (rt)
		end

	make_locals (r: ET_IS_ROUTINE; s: ET_IS_SYSTEM)
		local
			x0: detachable ET_IS_FEATURE_TEXT
			k, n: INTEGER
		do
			if s.needs_locals then
				argument_count := r.argument_count
				local_count := r.local_count
				scope_var_count := r.scope_var_count
				n := argument_count + local_count + scope_var_count
				if n > 0 then
						-- Search for a non-void local variable as pattern:
					from
						k := n
					until k = 0 loop
						k := k - 1
						if attached r.vars[k] as vk then
							x0 := vk.text
							k := 0
						end
					end
					if x0 /= Void then
						from
							create vars.make (n, x0)
						until k = n loop
							if attached r.vars[k] as v then
								vars.add (v.text)
							else
								vars.add (Void)
							end
							k := k + 1
						end
					else
						-- Nothing to do since local variables do not exist.
					end
				end
			end
		end
		
feature {} -- Implementation 

	renames: ET_IS_FEATURE_TEXT

	set_compound_positions (c, r: detachable ET_COMPOUND; e: detachable ET_KEYWORD)
		do
			if attached c as cc then
				entry_pos := position_to_integer (c.keyword.position)
			end
			if attached r as re then
				rescue_pos := position_to_integer (re.keyword.position)
			end
			if attached e as ex then
				exit_pos := position_to_integer (ex.position)
			end
		end

	position_to_integer (pos: detachable ET_POSITION): NATURAL
		do
			if attached pos as p then
				Result := (p.line * 256 + p.column).as_natural_32
			end
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
