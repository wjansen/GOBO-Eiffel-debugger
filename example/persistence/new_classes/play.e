note

	description: ""

class PLAY

create

	make

feature {NONE} -- Initialization

	make
		local
			almaviva, figaro, susanna: PERSONA
		do
			create almaviva.make ("Almaviva")
			create figaro.make ("Figaro")
			create susanna.make ("Susanna")
			figaro.set_lord (almaviva)
			susanna.set_lord (almaviva)
			figaro.set_in_love_to (susanna)
			almaviva.set_in_love_to (susanna)
			susanna.set_in_love_to (figaro)
			personae := <<almaviva, figaro, susanna>>
		end

feature -- Access

	personae: ARRAY [PERSONA]

end
