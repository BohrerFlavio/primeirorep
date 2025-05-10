#INCLUDE "rwmake.ch"

User Function FOL029()

	//vale lanche
	// A Pedido da Fabiane foi alteradas as Contas dia 08/02 - feito por Flávio  
	_cAlias:=Alias()


	DbselectArea("SRZ")



	_CONTA:=SPACE(12)

	If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="113" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="123"
		//_CONTA:="4102031007" 
		_CONTA:="4102023010"
	Endif
	If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="111" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="121"
		//_CONTA:="4104023006"
		_CONTA:="4104013010"
	Endif
	If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="112" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="122"
		//_CONTA:="4103023006"
		_CONTA:="4103013010"
	Endif



	DbSelectArea(_cAlias)
Return _CONTA
