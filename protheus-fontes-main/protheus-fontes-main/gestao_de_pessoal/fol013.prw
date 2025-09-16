#INCLUDE "rwmake.ch"

User Function FOL013()//PROVISAO E BAIXA INSS 13 SALARIO

	_cAlias:=Alias()


	DbselectArea("SRZ")


	_CONTA:=SPACE(12)

	If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="113" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="123"
		_CONTA:="4102024002"
	Endif
	If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="111" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="121"
		_CONTA:="4104014002"
	Endif
	If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="112" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="122"
		_CONTA:="4103014002"
	Endif



	DbSelectArea(_cAlias)
Return _CONTA
