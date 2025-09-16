#INCLUDE "rwmake.ch"

User Function FOL020()  //Bx fgts s/ 13.salario

	_cAlias:=Alias()


	DbselectArea("SRZ")



	_CONTA:=SPACE(12)

	If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="113" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="123"
		_CONTA:="4102024003"
	Endif
	If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="111" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="121"
		_CONTA:="4104014003"
	Endif
	If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="112" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="122"
		_CONTA:="4103014003
		"
	Endif



	DbSelectArea(_cAlias)
Return _CONTA
