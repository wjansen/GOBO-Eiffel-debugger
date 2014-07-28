note

	description: "Description of a line range for source code listing."

class DG_LINE_RANGE

feature -- Status 

	cls: detachable IS_CLASS_TEXT
			-- 

	text: detachable IS_FEATURE_TEXT
			-- 

	first_line: INTEGER
		do
			if fl > 0 then
				Result := fl
			elseif attached text as x then
				Result := x.first_line
			end
		ensure
			when_feature: attached text as x implies Result = x.first_line
		end

	last_line: INTEGER
		do
			Result := first_line + count - 1
		end

	count: INTEGER
		do
			if lc > 0 then
				Result := lc
			else
				Result := 1
			end
		ensure
			positive: attached cls implies Result > 0
		end

	column: INTEGER
			-- 

	is_relative: BOOLEAN
		do
			Result := first_line <= 0
		ensure
			definition: Result = (first_line <= 0)
		end

feature -- Status setting 

	set_class (c: detachable IS_CLASS_TEXT)
		note
			action: "Set class text"
		do
			if not attached c or else c /= cls then
				text := Void
				fl := 0
				lc := 1
				column := 0
			end
			cls := c
		ensure
			cls_set: cls = c
		end

	set_text (f: detachable IS_FEATURE_TEXT; body: BOOLEAN)
		note
			action: "Set class and feature text (or remove them if `f=Void')."
			body: "only feature body"
		require
			not_void: attached c or attached f
			in_class: attached c as c_ and then attached f implies c_.has_feature (f)
		do
			text := f
			if attached f as f_ then
				cls := f_.home
				if body and then attached {IS_ROUTINE_TEXT} f_ as r then
					fl := f_.line_of_position (r.entry_pos)
					lc := 1
				else
					fl := f_.first_line
					if f_.last_line > 0 then
						lc := f_.last_line - fl + 1
					else
						lc := 1
					end
					column := f_.column
				end
			else
				set_class (cls)
			end
		ensure
			text_set: text = f
		end

	set_first_line (f: INTEGER)
		note
			action: "Set first line"
		do
			fl := f
			if f > 0 then
				text := Void
			end
			column := 0
		ensure
			first_set: first_line = f
			no_column: column = 0
			no_feature: not attached text
		end

	set_count (c: INTEGER)
		note
			action: "Set line count"
		require
			positive: c > 0
		do
			lc := c
		ensure
			count_set: count = c
			no_feature: not attached text
		end

	set_line_column (l, c: INTEGER)
		require
			l_positive: l > 0
			c_not_negative: c >= 0
		do
			set_first_line (l)
			set_count (1)
			column := c
		ensure
			first_line_set: first_line = l
			column_set: column = c
			one_line: count = 1
		end

	update (other: attached like Current; body: BOOLEAN)
		do
			if attached other.cls as c then
				set_class (c)
			end
			if attached other.text as x and then attached other.cls as c then
				set_text (x, body)
			elseif other.first_line > 0 then
				set_first_line (other.first_line)
			end
			if other.column > 0 then
				set_line_column (other.first_line, other.column)
				set_count (1)
			elseif other.count > 0 then
				set_count (other.count)
			end
		end

feature -- Basic operation 

	match (c: like cls; l: INTEGER): BOOLEAN
		do
			Result := c = cls
			if Result then
				if 0 < first_line and then 0 < count then
					Result := first_line <= l and then l <= last_line
				elseif attached text as x then
					Result := x.has_line (l)
				end
			end
		end

feature {NONE} -- Implementation 

	fl, lc: INTEGER

invariant

	has_feature: attached cls as c and then attached text as x implies c.has_feature (x)

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
