note

	description:
		"Some benchmark tests to test efficiency of store/retrive operations."

class PC_BENCHMARK

inherit

	IS_BASE
		redefine
			default_create,
			out
		end

	AP_PARSER
		rename
			make as make_parser
		redefine
			default_create,
			out
		end

create

	default_create
	
feature {NONE} -- Initialization 
	
	default_create
		do
			make_parser
			create general_flag.make ('g', "general")
			general_flag.set_description ("Store/restore general format, extension %".gs%".")
			options.force_last (general_flag)
			create fast_flag.make ('f', "fast")
			fast_flag.set_description ("Fast restore general format, extension %".gs%".")
			options.force_last (fast_flag)
			create basic_flag.make ('b', "basic")
			basic_flag.set_description ("Store/restore basic format, extension %".bs%".")
			options.force_last (basic_flag)
			create memory_flag.make ('m', "memory")
			memory_flag.set_description ("Store to memory (alternative to `deep_copy').")
			options.force_last (memory_flag)
			create text_flag.make ('t', "text")
			text_flag.set_description ("Store human readable format, extension %".txt%".")
			options.force_last (text_flag)
			create xml_flag.make ('x', "xml")
			xml_flag.set_description ("Store XML format, extension %".xml%".")
			options.force_last (xml_flag)
			create c_code_flag.make ('c', "c-code")
			c_code_flag.set_description ("Store as C code, extensions %".c%".")
			options.force_last (c_code_flag)
			create deep_flag.make ('d', "deep-copy")
			deep_flag.set_description ("Apply `deep_copy'.")
			options.force_last (deep_flag)
			create statistics_flag.make ('s', "stat")
			statistics_flag.set_description ("Accumulate statistics.")
			options.force_last (statistics_flag)
			create arch_option.make_with_long_form ("arch")
			arch_option.extend ("own")
			arch_option.extend ("32")
			arch_option.extend ("64")
			arch_option.set_parameter_description ("own|32|64")
			arch_option.set_description
			("[
				Estimate memory size within statistics for running
				platform ("own"), 32-bit ("32"), or 64-bit ("64") computer.
				]")
			options.force_last (arch_option)
		end

feature -- Control

	general_flag: AP_FLAG

	fast_flag: AP_FLAG

	basic_flag: AP_FLAG
	
	memory_flag: AP_FLAG

	text_flag: AP_FLAG

	xml_flag: AP_FLAG

	c_code_flag: AP_FLAG

	deep_flag: AP_FLAG

	statistics_flag: AP_FLAG

	arch_option: AP_ENUMERATION_OPTION

feature -- Access 

	actionable: BOOLEAN
	
	filename: STRING

	general_store_msec, general_load_msec, fast_load_msec: REAL_64

	basic_store_msec, basic_load_msec: REAL_64

	text_msec, xml_msec, c_code_msec: REAL_64

	memory_msec, copy_msec, statistics_msec: REAL_64

	generally_restored, basically_restored, copied_memory: ANY
	
	statistics: detachable PC_STATISTICS_TARGET
	
feature -- Basic operation 

	test (obj: ANY; act: BOOLEAN; fn: STRING)
		note
			action:
			"[
			 Test efficiency to store/retrieve `obj'.
			 File extensions added are:
			 ".bs" for `basic', ".gs" for `general' and `fast', ".txt" for `text',
			 ".xml" for `xml', ".c" and ".h" for `c_code'.
			 ]"
			fn: "file name (without extension) to use"
		require
			fn_not_empty: fn.is_empty
		local
		do
			actionable := act
			if act then
				act_flag := Actionable_flag
			else
				act_flag := 0
			end
			filename := fn
			general_store_msec := 0.
			general_load_msec := 0.
			fast_load_msec := 0.
			basic_store_msec := 0.
			basic_load_msec := 0.
			text_msec := 0.
			xml_msec := 0.
			c_code_msec := 0.
			memory_msec := 0.
			copy_msec := 0.
			statistics_msec := 0.
			if general_flag.was_found then
				generally_restored := load_test
				store_test (obj)
			end
			if fast_flag.was_found then
				if not general_flag.was_found then
					store_test (obj)
					general_store_msec := 0.
				end
				generally_restored := fast_load_test
			end
			if basic_flag.was_found then
				basic_store_test (obj)
				basically_restored := basic_load_test
			end
			if memory_flag.was_found then
				memory_test (obj)
			end
			if text_flag.was_found then
				store_text_test (obj)
			end
			if xml_flag.was_found then
				store_xml_test (obj)
			end
			if c_code_flag.was_found then
				store_c_code_test (obj)
			end
			if deep_flag.was_found then
				copy_test (obj)
			end
			if statistics_flag.was_found then
				statistics_test (obj)
			end
		end

feature -- Output 

	out: attached STRING
		do
			create Result.make (100)
			if general_store_msec > 0. then
				Result.append ("General store time:    ")
				Result.append_real (general_store_msec.truncated_to_real)
				Result.extend ('%N')
			end
			if general_load_msec > 0. then
				Result.append ("General retrieve time: ")
				Result.append_real (general_load_msec.truncated_to_real)
				Result.extend ('%N')
			end
			if fast_load_msec > 0. then
				Result.append ("Fast retrieve time:    ")
				Result.append_real (fast_load_msec.truncated_to_real)
				Result.extend ('%N')
			end
			if basic_store_msec > 0. then
				Result.append ("Basic store time:      ")
				Result.append_real (basic_store_msec.truncated_to_real)
				Result.extend ('%N')
				Result.append ("Basic retrieve time:   ")
				Result.append_real (basic_load_msec.truncated_to_real)
				Result.extend ('%N')
			end
			if memory_msec > 0. then
				Result.append ("Memory store time:     ")
				Result.append_real (memory_msec.truncated_to_real)
				Result.extend ('%N')
			end
			if text_msec > 0. then
				Result.append ("Text store time:       ")
				Result.append_real (text_msec.truncated_to_real)
				Result.extend ('%N')
			end
			if xml_msec > 0. then
				Result.append ("XML store time:        ")
				Result.append_real (xml_msec.truncated_to_real)
				Result.extend ('%N')
			end
			if c_code_msec > 0. then
				Result.append ("C code store time:     ")
				Result.append_real (c_code_msec.truncated_to_real)
				Result.extend ('%N')
			end
			if copy_msec > 0. then
				Result.append ("Deep_copy time:        ")
				Result.append_real (copy_msec.truncated_to_real)
				Result.extend ('%N')
			end
			if statistics /= Void then
				Result.append ("Statistics%N")
				Result.append (statistics.out)
			end
		end

feature {NONE} -- Implementation 

	act_flag: INTEGER
	
	basic_store_test (obj: ANY)
		local
			f: RAW_FILE
			s: PC_SERIALIZER
			c: REAL_64
		do
			create f.make_open_write (filename + ".bs")
			create s
			s.set_options (s.Fifo_flag | act_flag)
			c := c_clock
			s.put_basically (obj, f, Void)
			basic_store_msec := (c_clock - c) / 1000.
			f.close
		end

	store_test (obj: ANY)
		local
			f: RAW_FILE
			s: PC_SERIALIZER
			c: REAL_64
		do
			create f.make_open_write (filename + ".gs")
			create s
			s.set_options (s.Fifo_flag | act_flag)
			c := c_clock
			s.put (obj, f, Void)
			general_store_msec := (c_clock - c) / 1000.
			f.close
		end

	store_text_test (obj: ANY)
		local
			f: PLAIN_TEXT_FILE
			s: PC_SERIALIZER
			c: REAL_64
		do
			create f.make_open_write (filename + ".txt")
			create s
			s.set_options (s.Fifo_flag | act_flag)
			c := c_clock
			s.put_text (obj, f, False)
			text_msec := (c_clock - c) / 1000.
			f.close
		end

	store_xml_test (obj: ANY)
		local
			f: PLAIN_TEXT_FILE
			s: PC_SERIALIZER
			c: REAL_64
		do
			create f.make_open_write (filename + ".xml")
			create s
			s.set_options (s.Fifo_flag | act_flag)
			c := c_clock
			s.put_xml (obj, "top", f, Void)
			xml_msec := (c_clock - c) / 1000.
			f.close
		end

	store_c_code_test (obj: ANY)
		local
			fc: PLAIN_TEXT_FILE
			src: PC_MEMORY_SOURCE
			oo: PC_ANY_TABLE [PC_TYPED_IDENT [NATURAL]]
			driver: PC_FORWARD_DRIVER [NATURAL, ANY]
			tgt: PC_C_TARGET
			c: REAL_64
		do
			create fc.make_open_write (filename + ".c")
			create tgt.make (fc, Void, Void, "T", "x", "top",
											 runtime_system, True, True)
			create src.make (runtime_system)
			create oo.make (101)
			create driver.make (tgt, src,oo)
			c := c_clock
			driver.traverse (obj)
			c_code_msec := (c_clock - c) / 1000.
			fc.close
		end

	basic_load_test: ANY
		local
			fn: STRING
			f: RAW_FILE
			d: PC_DESERIALIZER
			c: REAL_64
			retried: BOOLEAN
		do
			if not retried then
				fn := filename + ".bs"
				create f.make_with_name (fn)
				if f.exists then
					create f.make_open_read (fn)
					create d
					c := c_clock
					d.read (f)
					basic_load_msec := (c_clock - c) / 1000.
					f.close
					Result := d.top_object
				end
			end
		rescue
			retried := True
			retry
		end

	fast_load_test: ANY
		local
			fn: STRING
			f: RAW_FILE
			d: PC_DESERIALIZER
			c: REAL_64
			retried: BOOLEAN
		do
			if not retried then
				fn := filename + ".gs"
				create f.make_with_name (fn)
				if f.exists then
					create f.make_open_read (fn)
					create d
					c := c_clock
					d.read (f)
					fast_load_msec := (c_clock - c) / 1000.
					f.close
					Result := d.top_object
				end
			end
		rescue
			retried := True
			retry
		end

	load_test: ANY
		local
			fn: STRING
			f: RAW_FILE
			d: PC_DESERIALIZER
			c: REAL_64
			retried: BOOLEAN
		do
			if not retried then
				fn := filename + ".gs"
				create f.make_with_name (fn)
				if f.exists then
					create f.make_open_read (fn)
					create d
					c := c_clock
					d.read (f)
					general_load_msec := (c_clock - c) / 1000.
					f.close
					Result := d.top_object
				end
			end
		rescue
			retried := True
			retry
		end

	memory_test (obj: ANY)
		local
			s: PC_SERIALIZER
			c: REAL_64
		do
			create s
			s.set_options (s.Fifo_flag | act_flag)
			c := c_clock
			s.put_memory (obj)
			memory_msec := (c_clock - c) / 1000.
			copied_memory := s.copied_object
		end
	
	statistics_test (obj: ANY)
		local
			s: PC_SERIALIZER
			c: REAL_64
		do
			if statistics = Void then
				create statistics.make (True)
			end
			if arch_option.was_found then
				if arch_option.parameter.is_equal ("64") then
					statistics.set_arch64 (True)
				elseif arch_option.parameter.is_equal ("32") then
					statistics.set_arch64 (False)
				end
			end
			create s
			c := c_clock
			s.pre_serialize (obj, statistics)
			statistics_msec := (c_clock - c) / 1000.
		end

	copy_test (obj: ANY)
		local
			a: detachable ANY
			c: REAL_64
		do
			c := c_clock
			a := obj.deep_twin
			copy_msec := (c_clock - c) / 1000.
		end

feature {NONE} -- External implemetation 

	c_clock: REAL_64
		external
			"C inline use <time.h>"
		alias
			"((EIF_NATURAL_64)clock()*1000)/(EIF_REAL_64)CLOCKS_PER_SEC"
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
