note

	description:

	"[
	 Demonstartion how to use persistence closure routines.
	 ]"

	library: "Gobo Eiffel Regexp Library"
	copyright: "Copyright (c) 2015, Wolfgang Jansen and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

class PC_EXAMPLE

inherit

create

	make

feature {NONE} -- Initialization

	make
		-- Execute example.
		local
			s: PC_SERIALIZER
			d: PC_DESERIALIZER
			base, fn: STRING
			play: PLAY
			other: detachable like object
		do
			base := "personae"
			create play.make
			object := play.personae [3]
			create s
			create d
			
			-- Basic store/retrieve:
			fn := base + ".bs"
			store (object, s, fn, True)
			retrieve (d, fn)
			check_result (retrieved, object, True)
			
			-- Independent store/retrieve:
			fn := base + ".gs"
			store (object, s, fn, False)
			retrieve (d, fn)
			check_result (retrieved, object, False)

			-- Assignment attempt:
			if attached {like object} retrieved as obj then
				other := obj
			end

			-- Text output, both flat and deep:
			io.output.put_string ("-- Flat persistence closure:%N")
			s.put_text (other, Void, False)
			io.output.put_string ("%N-- Deep persistence closure:%N")
			s.put_text (other, Void, True)
		end

feature -- Basic operation

	store (a: ANY; s: PC_SERIALIZER; filename: STRING; basic: BOOLEAN)
		local
			f: RAW_FILE
		do
			create f.make_open_write (filename)
			if basic then
				s.put_basically (a, f, Void)
			else
				s.put (a, f, Void)
			end
			f.close
		end
	
	retrieve (d: PC_DESERIALIZER; filename: STRING)
		local
			f: RAW_FILE
			retried: BOOLEAN
		do
			if not retried then
				retrieved := Void
				d.reset
				create f.make_with_name (filename)
				if f.exists then
					create f.make_open_read (filename)
					d.read (f)
					f.close
					retrieved := d.top_object
				end
			end
		rescue
			retried := True
			retry
		end
	
feature {NONE} -- Implementation

	object: PERSONA

	retrieved: detachable ANY

	check_result (read: detachable ANY; written: ANY; basic: BOOLEAN)
		local
			str: STRING
			ok: BOOLEAN
		do
			if basic then
				str := "Basic "
			else
				str := "Independent "
			end
			str.append ("retrieve failed with ")
			if read = Void then
				str.append ("no object.")
			elseif not read.same_type (written) then
				str.append ("incorrect object type.")
-- `is_deep_equal' is not yet implemented, so we skip the test:
--			elseif not read.is_deep_equal (written) then
--				str.append (failed)
--				str.append ("incorrect object contents.")
			else
				ok := True
			end
			if not ok then
				io.error.put_string (str)
				io.error.put_new_line
			end
		end
	
end
