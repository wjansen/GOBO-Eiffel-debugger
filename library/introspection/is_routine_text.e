note

	description: "Internal description of a routine text of a class."

class IS_ROUTINE_TEXT

inherit

	IS_FEATURE_TEXT
		rename
			make as make_feature
		redefine
			has_position
		end

create

	make

feature {NONE} -- Initialization

	make (nm: READABLE_STRING_8; anm: like alias_name; fl, l, c: INTEGER;
			vv: like vars; ac, lc, cc: INTEGER; inline: like inline_texts)
		do
			make_feature (nm, anm, fl, l, c)
			if l * c > 0 then
				create instruction_positions.make_filled (0, 1)
				instruction_positions.put (position_as_integer (l, c), 0)
			end
			vars := vv
			argument_count := ac
			local_count := lc
			scope_var_count := cc
			inline_texts := inline
		end

feature -- Access

	has_position (line, col: INTEGER): BOOLEAN
		local
			p: NATURAL
		do
			p := (line * 256 + col).to_natural_32
				-- GEC specific
			Result := entry_pos <= p and then p <= exit_pos
		end

	has_rescue: BOOLEAN
		do
			Result := rescue_pos > 0
		end

	var_count: INTEGER
		do
			if attached vars as ll then
				Result := ll.count
			end
		ensure
			not_negative: Result >= 0
		end

	var_at (i: INTEGER): IS_FEATURE_TEXT
		require
			valid: 0 = i and then i < var_count
		do
			if attached vars as ll then
				Result := ll [i]
			end
		end

	argument_count: INTEGER;
	
	local_count: INTEGER;
	
	scope_var_count: INTEGER

	inline_text_count: INTEGER
		do
			if attached inline_texts as ir then
				Result := ir.count
			end
		end
	
	valid_inline_text (i: INTEGER): BOOLEAN
		do
			Result := 0 <= i and then i < inline_text_count
		end
	
	inline_text_at (i: INTEGER): attached IS_ROUTINE_TEXT
		note
			return: "`i'-th inline routine defined within `Current'."
		require
			valid_index: valid_inline_text (i)
		do
			if attached inline_texts as it then
				Result := it [i]
			else
				-- should not happen, just to make routine void safe:
				Result := Current
			end
		end
	
	entry_pos, rescue_pos, exit_pos: NATURAL

	instruction_positions: detachable SPECIAL [NATURAL]

	get_next_position (p: NATURAL): NATURAL
		local
			i: INTEGER
			n: NATURAL
		do
			if attached instruction_positions as pos then
				from
					i := pos.count
					Result := {NATURAL}.max_value
				until i = 0 loop
					i := i - 1
					n := pos [i]
					if n < Result and then p <= n then
						Result := n
					end
				end
			end
		end

feature -- Status setting

	set_body (e, r, x: NATURAL)
		do
			entry_pos := e
			rescue_pos := r
			exit_pos := x
		ensure
			entry_pos_set: entry_pos = e
			rescue_pos_set: entry_pos = r
			exit_pos_set: entry_pos = x
		end

feature -- Searching

	var_by_name (nm: READABLE_STRING_8): detachable like var_at
		local
			l: like var_at
			i: INTEGER
		do
			from
				i := var_count
			until i = 0 loop
				i := i - 1
				l := vars [i]
				if STRING_.same_string (l.fast_name, nm) then
				Result := l
					i := 0
				end
			end
		end

feature {IS_BASE} -- Implementation

	vars: IS_SPARSE_ARRAY [like var_at]

feature {NONE} -- Implementation

	inline_texts: detachable IS_SEQUENCE [like inline_text_at]
	
invariant

	exit_below_entry: exit_pos >= entry_pos

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
