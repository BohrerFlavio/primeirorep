#INCLUDE "rwmake.ch"

User Function FOL028()

	//salarios a pagar
	_cAlias:=Alias()


	DbselectArea("SRZ")



	_CONTA:=SPACE(12)

	If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="113" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="123"
		_CONTA:="4102021004"
	Endif
	If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="111" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="121"
		_CONTA:="4104011004"
	Endif
	If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="112" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="122"
		_CONTA:="4103011005"
	Endif
	If FunName() $ 'GPEM110A' //se for para o MANAD... alterado por Giuliano
		if mv_par03==2
			If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="113" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="123"
				_CONTA:="4102024001"
			Endif
			If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="111" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="121"
				_CONTA:="4104014001"
			Endif
			If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="112" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="122"
				_CONTA:="4103014001"
			Endif
		endif
	else
		if mv_par02==2
			If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="113" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="123"
				_CONTA:="4102024001"
			Endif
			If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="111" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="121"
				_CONTA:="4104014001"
			Endif
			If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="112" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="122"
				_CONTA:="4103014001"
			Endif
		endif   
	endif

	DbSelectArea(_cAlias)
Return _CONTA
