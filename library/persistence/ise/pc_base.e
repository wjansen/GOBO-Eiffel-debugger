note

	description: "General definitions for object persistence."

deferred class PC_BASE

feature -- Constants 

	Fifo_flag: INTEGER = 0

	Lifo_flag: INTEGER = 1

	Flat_flag: INTEGER = 1

	Deep_flag: INTEGER = 0x10000	-- Illegal value: deep traversal not supported

	Forward_flag: INTEGER = 3

	Order_flag: INTEGER = 3

	Basic_flag: INTEGER = 8

	Once_observation_flag: INTEGER = 0x10

	Accept_actionable_flag: INTEGER = 0x20

	Non_consecutive_flag: INTEGER = 0x40

	File_position_flag: INTEGER = 0x80

	Indices_flag: INTEGER = 0xC0
	
	Stack_flag: INTEGER = 0x100

	Skip_agents_flag: INTEGER = 0x1000

note

	author: "Wolfgang Jansen"
	date: "$Date$"
	revision: "$Revision$"

end
