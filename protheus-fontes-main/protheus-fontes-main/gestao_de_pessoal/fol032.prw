#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'

user function FOL032()
	//Vale Gás
	_cAlias:=Alias()

	DbselectArea("SRZ")

	_CONTA:=SPACE(12)

	If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="113" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="123"
		_CONTA:="4102023013"
	Endif
	If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="111" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="121"
		_CONTA:="4104013014"
	Endif
	If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="112" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="122"
		_CONTA:="4103013013"
	Endif

	DbSelectArea(_cAlias)
Return _CONTA
