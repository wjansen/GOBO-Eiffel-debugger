indexing

	description:

		"Test XPath base-uri() function."

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2005, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

		-- TODO: awaiting ability to properly calculate Base URI of PIs

deferred class XM_XPATH_TEST_BASE_URI

inherit

	TS_TEST_CASE
		redefine
			set_up
		end

	XM_XPATH_TYPE
	
	XM_XPATH_ERROR_TYPES

	XM_XPATH_SHARED_CONFORMANCE

	KL_IMPORTED_STRING_ROUTINES

	KL_SHARED_STANDARD_FILES

	KL_SHARED_FILE_SYSTEM
		export {NONE} all end

	UT_SHARED_FILE_URI_ROUTINES
		export {NONE} all end

feature -- Access

	document_uri: STRING is
			-- Base-uri of books2.xml
		local
			a_uri: UT_URI
		once
			create a_uri.make_resolve (current_directory_base, "./data/base_uri_master.xml")
			Result := a_uri.full_reference
		end

	secondary_uri: STRING is
			-- Base-uri of base_uri_a.xml
		local
			a_uri: UT_URI
		once
			create a_uri.make_resolve (current_directory_base, "./data/base_uri_a.xml")
			Result := a_uri.full_reference
		end

	nested_xml_base_uri: STRING is
			-- Base-uri of nested element with xml:base
		once
			Result := "http://www.gobosoft.com/xml-tests/AAMilne-book"
		end

	xml_base_uri: STRING is
			-- Base-uri of element with xml:base
		once
			Result := "urn:base-uri:element2"
		end

	current_directory_base: UT_URI is
			-- URI of current directory
		local
			a_cwd: KI_PATHNAME
		once
			a_cwd := file_system.string_to_pathname (file_system.current_working_directory)
			Result := File_uri.pathname_to_uri (a_cwd)
		end

feature -- Tests

	test_implicit_document_root is
			-- Test fn:base-uri().
		local
			an_evaluator: XM_XPATH_EVALUATOR
			a_uri: XM_XPATH_ANY_URI_VALUE
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/base_uri_master.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("base-uri()")
			assert ("No evaluation error", not an_evaluator.is_error)
			assert ("One evaluated item",  an_evaluator.evaluated_items.count = 1)
			a_uri ?= an_evaluator.evaluated_items.item (1)
			assert ("AnyURI value", a_uri /= Void)
			assert ("Correct base-URI", STRING_.same_string (document_uri, a_uri.string_value))
		end

	test_context_item_not_a_node is
			-- Test (1,2,3)[fn:base-uri() eq 'fred'].
		local
			an_evaluator: XM_XPATH_EVALUATOR
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/base_uri_master.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("(1,2,3)[base-uri() eq 'fred']")
			assert ("Evaluation error", an_evaluator.is_error)
			assert ("Error FORG0006", STRING_.same_string (an_evaluator.error_value.code, "FORG0006"))
		end

	test_empty_sequence is
			-- Test fn:base-uri(()).
		local
			an_evaluator: XM_XPATH_EVALUATOR
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/base_uri_master.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("base-uri(())")
			assert ("No evaluation error", not an_evaluator.is_error)
			assert ("Empty sequence",  an_evaluator.evaluated_items.count = 0)
		end

	test_empty_sequence_tiny_tree is
			-- Test fn:base-uri(()).
		local
			an_evaluator: XM_XPATH_EVALUATOR
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/base_uri_master.xml", False, False, True, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("base-uri(())")
			assert ("No evaluation error", not an_evaluator.is_error)
			assert ("Empty sequence",  an_evaluator.evaluated_items.count = 0)
		end

	test_element_with_xml_base is
			-- Test fn:base-uri(/*[1]/*[2]/ITEM[2]).
		local
			an_evaluator: XM_XPATH_EVALUATOR
			a_uri: XM_XPATH_ANY_URI_VALUE
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/base_uri_master.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("base-uri(/*[1]/*[2]/ITEM[2])")
			assert ("No evaluation error", not an_evaluator.is_error)
			assert ("One evaluated item",  an_evaluator.evaluated_items.count = 1)
			a_uri ?= an_evaluator.evaluated_items.item (1)
			assert ("AnyURI value", a_uri /= Void)
			assert ("Correct base-URI", STRING_.same_string (nested_xml_base_uri, a_uri.string_value))
		end

	test_element_with_xml_base_tiny_tree is
			-- Test fn:base-uri(/*[1]/*[2]/ITEM[2]).
		local
			an_evaluator: XM_XPATH_EVALUATOR
			a_uri: XM_XPATH_ANY_URI_VALUE
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/base_uri_master.xml", False, False, True, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("base-uri(/*[1]/*[2]/ITEM[2])")
			assert ("No evaluation error", not an_evaluator.is_error)
			assert ("One evaluated item",  an_evaluator.evaluated_items.count = 1)
			a_uri ?= an_evaluator.evaluated_items.item (1)
			assert ("AnyURI value", a_uri /= Void)
			assert ("Correct base-URI", STRING_.same_string (nested_xml_base_uri, a_uri.string_value))
		end

	test_element is
			-- Test fn:base-uri(/*[1]/*[2]/ITEM[1]).
		local
			an_evaluator: XM_XPATH_EVALUATOR
			a_uri: XM_XPATH_ANY_URI_VALUE
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/base_uri_master.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("base-uri(/*[1]/*[2]/ITEM[1])")
			assert ("No evaluation error", not an_evaluator.is_error)
			assert ("One evaluated item",  an_evaluator.evaluated_items.count = 1)
			a_uri ?= an_evaluator.evaluated_items.item (1)
			assert ("AnyURI value", a_uri /= Void)
			assert ("Correct base-URI", STRING_.same_string (secondary_uri, a_uri.string_value))
		end

	test_element_tiny_tree is
			-- Test fn:base-uri(/*[1]/*[2]/ITEM[1]).
		local
			an_evaluator: XM_XPATH_EVALUATOR
			a_uri: XM_XPATH_ANY_URI_VALUE
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/base_uri_master.xml", False, False, True, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("base-uri(/*[1]/*[2]/ITEM[1])")
			assert ("No evaluation error", not an_evaluator.is_error)
			assert ("One evaluated item",  an_evaluator.evaluated_items.count = 1)
			a_uri ?= an_evaluator.evaluated_items.item (1)
			assert ("AnyURI value", a_uri /= Void)
			assert ("Correct base-URI", STRING_.same_string (secondary_uri, a_uri.string_value))
		end

	test_nested_element is
			-- Test fn:base-uri(/*[1]/*[2]/nested-element).
		local
			an_evaluator: XM_XPATH_EVALUATOR
			a_uri: XM_XPATH_ANY_URI_VALUE
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/base_uri_master.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("base-uri(/*[1]/*[2]/nested-element)")
			assert ("No evaluation error", not an_evaluator.is_error)
			assert ("One evaluated item",  an_evaluator.evaluated_items.count = 1)
			a_uri ?= an_evaluator.evaluated_items.item (1)
			assert ("AnyURI value", a_uri /= Void)
			assert ("Correct base-URI", STRING_.same_string (xml_base_uri, a_uri.string_value))
		end

	test_nested_element_tiny_tree is
			-- Test fn:base-uri(/*[1]/*[2]/nested-element).
		local
			an_evaluator: XM_XPATH_EVALUATOR
			a_uri: XM_XPATH_ANY_URI_VALUE
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/base_uri_master.xml", False, False, True, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("base-uri(/*[1]/*[2]/nested-element)")
			assert ("No evaluation error", not an_evaluator.is_error)
			assert ("One evaluated item",  an_evaluator.evaluated_items.count = 1)
			a_uri ?= an_evaluator.evaluated_items.item (1)
			assert ("AnyURI value", a_uri /= Void)
			assert ("Correct base-URI", STRING_.same_string (xml_base_uri, a_uri.string_value))
		end

	test_pi_child_of_element_with_xml_base is
			-- Test fn:base-uri(/*[1]/*[1]/ITEM[2]/processing-instruction()).
		local
			an_evaluator: XM_XPATH_EVALUATOR
			a_uri: XM_XPATH_ANY_URI_VALUE
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/base_uri_master.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("base-uri(/*[1]/*[1]/ITEM[2]/processing-instruction())")
			assert ("No evaluation error", not an_evaluator.is_error)
			assert ("One evaluated item",  an_evaluator.evaluated_items.count = 1)
			a_uri ?= an_evaluator.evaluated_items.item (1)
			assert ("AnyURI value", a_uri /= Void)
			assert ("Correct base-URI", STRING_.same_string (nested_xml_base_uri, a_uri.string_value))
		end

	test_pi_child_of_element_with_xml_base_tiny_tree is
			-- Test fn:base-uri(/*[1]/*[1]/ITEM[2]/processing-instruction()).
		local
			an_evaluator: XM_XPATH_EVALUATOR
			a_uri: XM_XPATH_ANY_URI_VALUE
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/base_uri_master.xml", False, False, True, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("base-uri(/*[1]/*[1]/ITEM[2]/processing-instruction())")
			assert ("No evaluation error", not an_evaluator.is_error)
			assert ("One evaluated item",  an_evaluator.evaluated_items.count = 1)
			a_uri ?= an_evaluator.evaluated_items.item (1)
			assert ("AnyURI value", a_uri /= Void)
			assert ("Correct base-URI", STRING_.same_string (nested_xml_base_uri, a_uri.string_value))
		end

	test_pi_at_top_level is
			-- Test fn:base-uri(/*[1]/*[1]/processing-instruction()[2]).
		local
			an_evaluator: XM_XPATH_EVALUATOR
			a_uri: XM_XPATH_ANY_URI_VALUE
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/base_uri_master.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("base-uri(/*[1]/*[1]/processing-instruction()[2])")
			assert ("No evaluation error", not an_evaluator.is_error)
			assert ("One evaluated item",  an_evaluator.evaluated_items.count = 1)
			a_uri ?= an_evaluator.evaluated_items.item (1)
			assert ("AnyURI value", a_uri /= Void)
			assert ("Correct base-URI", STRING_.same_string (secondary_uri, a_uri.string_value))
		end

	test_pi_at_top_level_tiny_tree is
			-- Test fn:base-uri(/*[1]/*[1]/processing-instruction()[2]).
		local
			an_evaluator: XM_XPATH_EVALUATOR
			a_uri: XM_XPATH_ANY_URI_VALUE
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/base_uri_master.xml", False, False, True, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("base-uri(/*[1]/*[1]/processing-instruction()[2])")
			assert ("No evaluation error", not an_evaluator.is_error)
			assert ("One evaluated item",  an_evaluator.evaluated_items.count = 1)
			a_uri ?= an_evaluator.evaluated_items.item (1)
			assert ("AnyURI value", a_uri /= Void)
			assert ("Correct base-URI", STRING_.same_string (secondary_uri, a_uri.string_value))
		end

	set_up is
		do
			conformance.set_basic_xslt_processor
		end

end

			