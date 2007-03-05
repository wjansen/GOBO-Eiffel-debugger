indexing

	description:

		"Objects that implement the XSLT unparsed-entity-uri() function"

	library: "Gobo Eiffel XSLT Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

class XM_XSLT_UNPARSED_ENTITY_URI

inherit

	XM_XPATH_SYSTEM_FUNCTION
		redefine
			simplify, pre_evaluate, evaluate_item
		end

create

	make

feature {NONE} -- Initialization

	make is
			-- Establish invariant
		do
			name := "unparsed-entity-uri"; namespace_uri := Xpath_standard_functions_uri
			fingerprint := Unparsed_entity_uri_function_type_code
			minimum_argument_count := 1
			maximum_argument_count := 1
			create arguments.make (1)
			arguments.set_equality_tester (expression_tester)
			initialized := True
		end

feature -- Access

	item_type: XM_XPATH_ITEM_TYPE is
			-- Data type of the expression, where known
		do
			Result := type_factory.any_uri_type
			if Result /= Void then
				-- Bug in SE 1.0 and 1.1: Make sure that
				-- that `Result' is not optimized away.
			end
		end

feature -- Status report

	required_type (argument_number: INTEGER): XM_XPATH_SEQUENCE_TYPE is
			-- Type of argument number `argument_number'
		do
			create Result.make_single_string
		end

feature -- Optimization

	simplify is
			-- Perform context-independent static optimizations
		local
			a_function: XM_XSLT_UNPARSED_ENTITY_URI
		do
			Precursor
			if was_expression_replaced then
				a_function ?= replacement_expression
				if a_function /= Void then
					a_function.add_context_document_argument (1, "unparsed-entity-uri+")
				end
			else
				add_context_document_argument (1, "unparsed-entity-uri+")
				merge_dependencies (arguments.item (2).dependencies)
			end
		end

feature -- Evaluation

	evaluate_item (a_context: XM_XPATH_CONTEXT) is
			-- Evaluate `Current' as a single item
		local
			an_entity, an_id: STRING
		do
			arguments.item (1).evaluate_item (a_context)
			if arguments.item (1).last_evaluated_item.is_error then
				last_evaluated_item := arguments.item (1).last_evaluated_item
			else
				an_entity := arguments.item (1).last_evaluated_item.string_value
				arguments.item (2).evaluate_item (a_context)
				if arguments.item (2).last_evaluated_item.is_error then
					last_evaluated_item := arguments.item (2).last_evaluated_item
				elseif arguments.item (2).last_evaluated_item.is_document then
					an_id := arguments.item (2).last_evaluated_item.as_document.unparsed_entity_system_id (an_entity)
					if an_id = Void then
						an_id := ""
					end
					create {XM_XPATH_ANY_URI_VALUE} last_evaluated_item.make (an_id)
				else
					create {XM_XPATH_INVALID_ITEM} last_evaluated_item.make_from_string ("Context node is not set or it's root is not a document node.",
																												Xpath_errors_uri, "XTDE1370", Dynamic_error)
				end
			end
		end

	pre_evaluate (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Pre-evaluate `Current' at compile time.
		do
			-- Suppress compile-time evaluation
		end

	create_node_iterator (a_context: XM_XPATH_CONTEXT) is
			-- Create an iterator over a node sequence
		do
			-- pre-condition is never met
		end

feature {XM_XPATH_EXPRESSION} -- Restricted

	compute_cardinality is
			-- Compute cardinality.
		do
			set_cardinality_exactly_one
		end


end
	