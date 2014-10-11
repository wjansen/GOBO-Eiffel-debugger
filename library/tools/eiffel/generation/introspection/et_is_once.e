note

	description:

		"Compile time description of the value of a once function."

class ET_IS_ONCE

inherit

	ET_IS_ROUTINE
		rename
			declare as declare_routine,
			in_class as home
		redefine
			target,
			home,
			type,
			text,
			inline_agent
		end
	
	IS_ONCE
		undefine
			make,
			var_at,
			inline_routine_at
		redefine
			target,
			home,
			type,
			text,
			inline_agent
		end

create

	declare

feature {} -- Initialization 

	declare (o: attached like origin; where: like target; s: ET_IS_SYSTEM)
		require
			is_once: o.static_feature.is_once
		do
			declare_routine (o, where, s)
			flags := flags | Once_flag
		ensure
			origin_set: origin = o
		end

feature -- Access 

	target: ET_IS_TYPE

	home: ET_IS_CLASS_TEXT

	type: detachable ET_IS_TYPE

	text: detachable ET_IS_ROUTINE_TEXT

	inline_agent: detachable ET_IS_AGENT_TYPE

feature -- Basic operation 

	print_init (a_file: KI_TEXT_OUTPUT_STREAM; g: ET_INTROSPECT_GENERATOR)
		do
			a_file.put_character ('&')
			g.print_once_status_name (origin.static_feature, a_file)
		end

	print_value (a_file: KI_TEXT_OUTPUT_STREAM; g: ET_INTROSPECT_GENERATOR)
		do
			if is_function then
				a_file.put_character ('&')
				g.print_once_value_name (origin.static_feature, a_file)
			else
				a_file.put_character ('0')
			end
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
