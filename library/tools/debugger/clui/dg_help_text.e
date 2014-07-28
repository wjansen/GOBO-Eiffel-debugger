note

	description:

		"Topic of help information."


class DG_HELP_TEXT

inherit

	DG_GLOBALS

create

	make,
	make_leave

feature {NONE} -- Initialization 

	make (top, head, main: STRING; rep: detachable STRING; m: like more)
		do
			make_leave (top, head, main, rep)
			more := m
		ensure
			topic_set: topic = top
			head_line_set: head_line = head
			main_part_set: main_part = main
			repeat_set: repeat = rep
			more_set: more = m
		end

	make_leave (top, head, main: STRING; rep: detachable STRING)
		do
			topic := top
			head_line := head
			main_part := main
			repeat := rep
		ensure
			topic_set: topic = top
			head_line_set: head_line = head
			main_part_set: main_part = main
			repeat_set: repeat = rep
		end

feature -- Access 

	head_line: STRING
			-- Headline of text (to follow the prefix ""). 

	main_part: STRING
			-- Help text to be printed. 

	repeat: detachable STRING
			-- Text describing command repetition (to follow "Repetition: "). 

	topic: STRING
			-- Short name for use in `more' list. 

	more: detachable ARRAY [DG_HELP_TEXT]
			-- List of related DG_HELP_TEXTs. 

feature -- Basic operation 

	display
		do
			tmp_str.wipe_out
			tmp_str.append ("%FHelp on ")
			tmp_str.append (head_line)
			tmp_str.extend ('%N')
			tmp_str.extend ('%N')
			tmp_str.append (main_part)
			if attached repeat as r then
				tmp_str.extend ('%N')
				tmp_str.append ("%NRepetition: ")
				tmp_str.append (r)
			end
			ui_file.put_line (tmp_str)
		end

feature {NONE} -- Implementation 

	go_back: STRING = "^"


	exit: STRING = "--"


	prompt: STRING = "%NMore help"


invariant

	when_more: attached more as m implies m.count > 0

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
