note

	description: "Stack for arguments of C functions to be evaluated."

class DG_VALUE_STACK

inherit

	MANAGED_POINTER
		rename
			make as make_addresses,
			resize as resize_addresses,
			item as addresses,
			count as addresses_size
		redefine
			default_create,
			dispose
		end

create

	default_create

feature {} -- Initialization 

	default_create
		local
			n: INTEGER
		do
			n := 10
			create values.make (n)
			own_memory := own_memory.memory_calloc (n, c_size)
			make_addresses (n * Pointer_bytes)
		end

feature {} -- Termination 

	dispose
		do
			own_memory.memory_free
			own_memory := default_pointer
			Precursor
		end

feature -- Access 

	count: INTEGER
		note
			return: "Number of elements."
		do
			Result := values.count
		end

	valid_index (i: INTEGER): BOOLEAN
		note
			return: "Is `i' a valid index?"
		do
			Result := 0 <= i and then i < count
		end

feature -- Status 

	top_type: detachable IS_TYPE
		note
			return: "Type of the top element."
		require
			not_empty: 0 < count
		do
			Result := values.last.type
		end

feature -- Status setting 

	clear
		note
			action: "Make stack empty."
		do
			pop (count)
		ensure
			empty: count = 0
		end

	push (v: DG_EXPRESSION)
		note
			action: "Add `v' on top of stack."
		local
			n, s: INTEGER
		do
			values.force (v)
			n := values.count
			s := n * Pointer_bytes
			if addresses_size < s then
				resize_addresses (2 * s)
				own_memory := own_memory.memory_realloc (2 * n * c_size)
			end
			if v.c_ptr = default_pointer then
				v.share (own_memory + n * c_size, v.type)
			end
		ensure
			incremented: count = old count + 1
			added: top = v
		end

	put (v: DG_EXPRESSION)
		note
			action: "Replace top element by `v'."
		do
			values.finish
			values.replace (v)
			if v.c_ptr = default_pointer then
				v.share (own_memory + count * c_size, v.type)
			end
		ensure
			same_count: count = old count
			set: top = v
		end

	top: DG_EXPRESSION
		note
			return: "Top element."
		require
			not_empty: count > 0
		do
			Result := values.last
		ensure
			same_count: count = old count
		end

	below_top (i: INTEGER): DG_EXPRESSION
		note
			return: "`i'-th element below top (`i=0' means the top element)."
		require
			not_negative: i >= 0
			large_enough: count > i
		do
			Result := values [count - i]
		ensure
			same_count: count = old count
		end

	pop (n: INTEGER)
		note
			action: "Remove the `n' top most elements."
		require
			large_enough: count >= n
		local
			v: DG_EXPRESSION
			p: POINTER
			i, s: INTEGER
		do
			from
				i := n
				s := c_size
				p := own_memory + count * s
			until i = 0 loop
				values.finish
				p := p + -s
				v := values.item
				if v.c_ptr = p then
					v.free_memory
				end
				values.remove
				i := i - 1
			end
		ensure
			removed: count = old count - n
		end

	exchange
		note
			action: "Exchange two top most elements."
		require
			enough_elements: count >= 2
		local
			first: like top
		do
			first := top
			pop (1)
			push (first)
		ensure
			same_count: count = old count
			exchanged: top = old below_top (1) and old top = below_top (1)
		end

feature -- Basic operation 

	invoke (r: IS_ROUTINE)
		note
			action:
				"[
				 Call `r' with the top most elements as arguments
				 (including the target) and the result (below arguments).
				 Remove the arguments and leave the result at the top.
				 ]"
		require
			large_enough: count >= r.argument_count
			when_function: r.is_function implies count > r.argument_count
		local
			v: like top
			res_ptr: POINTER
			i, k, n: INTEGER
		do
			n := r.argument_count
			from
				i := n
				k := count
			until i = 0 loop
				v := values [k]
				i := i - 1
				put_pointer (v.address, i * Pointer_bytes)
				k := k - 1
			end
			v := values [k]
			res_ptr := v.c_ptr
			put_pointer (res_ptr, n * Pointer_bytes)
			c_call (r.wrap, r.call, addresses, res_ptr)
			pop (n)
		ensure
			arguments_removed: count = old count - r.argument_count
		end

feature {NONE} -- Implementation 

	values: ARRAYED_LIST [DG_EXPRESSION]

	own_memory: POINTER

feature {NONE} -- Externals 

	c_size: INTEGER
		external
			"C inline"
		alias
			"GE_z_usize"
		end

	c_call (wrap: INTEGER; call: POINTER; args: POINTER; res: POINTER)
		external
			"C inline"
		alias
			"GE_z_wrap($wrap,$call,*(void**)$args,&((void**)$args)[1],$res)"
		end

invariant

	own_memory_not_null: own_memory /= default_pointer

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
