class AA

creation

	make

feature

	make is
		local
			b: BB
		do
			create b
			print (b.f)
		end

end -- class AA
