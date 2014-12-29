note

	Description:

		"Basic constants of the debugger."

deferred class DG_CONSTANTS

inherit

	PLATFORM

feature -- Constants 

	No_match: INTEGER = 0

	Break_match: INTEGER = 1

	Trace_match: INTEGER = 2

	Error_match: INTEGER = 9

	No_expression_error: INTEGER = 101

	Unknown_query: INTEGER = 102

	Not_unique_query: INTEGER = 103

	Not_initialized: INTEGER = 104

	Missing_args: INTEGER = 105

	Too_few_args: INTEGER = 106

	Too_many_args: INTEGER = 107

	Non_conforming_arg: INTEGER = 108

	Not_a_function: INTEGER = 109

	Not_an_old: INTEGER = 110

	No_bracket: INTEGER = 111

	Not_array_target: INTEGER = 112

	Array_target: INTEGER = 113

	Bad_index: INTEGER = 114

	Failing_call: INTEGER = 115

	Unknown_closure_ident: INTEGER = 116

	Object_not_ok: INTEGER = 117

	Last_expression_error: INTEGER = 118

	Any_exception: INTEGER = 30

	Instruction_break: INTEGER = 0

	Call_break: INTEGER = -1

	Step_into_break: INTEGER = -2

	Assignment_break: INTEGER = -3

	Debug_break: INTEGER = -4

	End_scope_break: INTEGER = -5

	End_routine_break: INTEGER = -6

	Start_program_break: INTEGER = -7

	End_program_break: INTEGER = -8

	After_mark_break: INTEGER = -9

	After_reset_break: INTEGER = -10

	not_op: INTEGER = 1
	and_op: INTEGER = 2
	or_op: INTEGER = 3
	xor_op: INTEGER = 4
	implies_op: INTEGER = 5
	
	eq_op: INTEGER = 11
	ne_op: INTEGER = 12
	lt_op: INTEGER = 13
	le_op: INTEGER = 14
	gt_op: INTEGER = 15
	ge_op: INTEGER = 16
	sim_op: INTEGER = 17
	nsim_op: INTEGER = 18
	
	plus_op: INTEGER = 21
	minus_op: INTEGER = 22
	mult_op: INTEGER = 23
	div_op: INTEGER = 24
	idiv_op: INTEGER = 25
	imod_op: INTEGER = 26
	power_op: INTEGER = 27

	interval_op: INTEGER = 30

	free_op: INTEGER = 40
	
feature {NONE} -- External implementation 

	Interrupt_signal: INTEGER
		external
			"C macro use <sys/signal.h>"
		alias
			"SIGINT"
		end

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
