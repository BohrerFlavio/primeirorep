#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'

user function FOL033()
	/* Criado em 02/04 - Flávio
		Reembolso Assistência Médica
		Acrescenta em um laçamento padrão que a Fabiane incluiu no sistema
	  */
	_cAlias:=Alias()

	DbselectArea("SRZ")

	_CONTA:=SPACE(12)

	If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="113" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="123"
		_CONTA:="4102023006"
	Endif
	If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="111" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="121"
		_CONTA:="4104013006"
	Endif
	If alltrim(SUBSTR(SRZ->RZ_CC,1,3))="112" .OR. alltrim(SUBSTR(SRZ->RZ_CC,1,3))="122"
		_CONTA:="4103013006"
	Endif

	DbSelectArea(_cAlias)
Return _CONTA
