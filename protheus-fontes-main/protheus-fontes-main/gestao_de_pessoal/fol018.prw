#INCLUDE "rwmake.ch"

User Function FOL018()    //liquido salarios

	_cAlias:=Alias()


	DbselectArea("SRZ")




	_CONTA:=SPACE(12) 

	If alltrim(SUBSTR(SRZ->RZ_MAT,1,6))="000001" .OR.  alltrim(SUBSTR(SRZ->RZ_MAT,1,6))="000003" 
		_CONTA:="2104011002"
	Endif

	If alltrim(SUBSTR(SRZ->RZ_MAT,1,6))="000001" 
		_CONTA:="2104012002"
	Endif

	If alltrim(SUBSTR(SRZ->RZ_FILIAL,1,2))="00" 
		_CONTA:="2104011001"
	Endif
	If alltrim(SUBSTR(SRZ->RZ_FILIAL,1,2))="01" 
		_CONTA:="2104012001"
	Endif




	DbSelectArea(_cAlias)
Return _CONTA
