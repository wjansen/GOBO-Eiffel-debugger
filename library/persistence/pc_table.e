note

	description:
		"[ 
		 Abstract class maintaining the association between 
		 input and output idents during scanning the persistence closure. 
		 ]"

deferred class PC_TABLE [V_, K_ -> attached ANY]
	-- V_: type of idents generated by the `target' 
	-- K_: type of idents generated by the `source' 

inherit

	ITERABLE [V_]
		undefine
			copy,
			is_equal
		end

feature -- Access 

	valid_key (key: detachable K_): BOOLEAN
		deferred
		ensure
			when_valid: Result implies attached key as k and then k /= k.default
		end

	item alias "[]" (key: K_): V_ assign put
		require
			valid_key: has (key)
		deferred
		end

	key_of_value (v: detachable V_): detachable K_
		deferred
		ensure
			when_found: attached Result as r implies item (r) = v
		end

feature -- Status 

	is_empty: BOOLEAN
		do
			Result := count = 0
		ensure
			definition: Result = (count = 0)
		end

	count: INTEGER
		deferred
		ensure
			not_negative: Result >= 0
		end

	has (key: detachable K_): BOOLEAN
		note
			return:
				"[
				 Does the table contain `key'?
				 Caution: the function has side effects on private attributes.
				 ]"
		deferred
		ensure
			when_not_valid: not valid_key (key) implies False
		end

feature -- Element change 

	put (value: V_; key: K_)
		require
			has_key: has (key)
		deferred
		ensure
			no_more_data: count = old count
			has_key: has (key)
			item_set: item (key) = value
		end

feature -- Removal 

	clear
		deferred
		ensure
			empty: is_empty
		end

feature -- Traversal 

	do_keys (action: PROCEDURE [ANY, TUPLE [K_]])
		note
			action: "Apply `action' to all valid keys."
		deferred
		end

	do_values (action: PROCEDURE [ANY, TUPLE [attached V_]])
		note
			action: "Apply `action' to all values (different from `default')."
		deferred
		end

	do_pairs (action: PROCEDURE [ANY, TUPLE [attached V_, K_]])
		note
			action: "Apply `action' to all key-value pairs."
		deferred
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
