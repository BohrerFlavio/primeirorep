#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} SACI008
O ponto de entrada SACI008 sera executado após gravar todos os dados da baixa a receber.
Neste momento todos os registros já foram atualizados e destravados e a contabilização efetuada.
@author 	Evandro Mugnol
@since 		16/08/2016
@obs 		N/A
/*/

User Function SACI008()

	_cPrefixo := SE1->E1_PREFIXO
	_cNumero  := SE1->E1_NUM
	_cParcela := SE1->E1_PARCELA
	_cTipoDoc := SE1->E1_TIPO
	_cCliente := SE1->E1_CLIENTE
	_cLojaCli := SE1->E1_LOJA
	_nRapelE1 := SE1->E1_VLRAPEL
	_IdOrigSE5 := ""

	// Atualiza histórico quando tem desconto rapel
	DbSelectArea("SE5")
	DbSetOrder(7)
	DbSeek(xFilial("SE5") + _cPrefixo + _cNumero + _cParcela + _cTipoDoc + _cCliente + _cLojaCli)
	While !Eof() .And. SE5->E5_FILIAL + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + SE5->E5_CLIFOR + SE5->E5_LOJA == xFilial("SE5") + _cPrefixo + _cNumero + _cParcela + _cTipoDoc + _cCliente + _cLojaCli
		If AllTrim(SE5->E5_TIPODOC) == "DC"
			If _nRapelE1 > 0
				_IdOrigSE5 := SE5->E5_IDORIG 
				RecLock("SE5",.F.)
				SE5->E5_HISTOR := "Desconto Rapel s/Receb.Titulo"
				MsUnlock()
			Endif
		Endif

		// Grava baixa como contabilizada para poder contabilizar em caso de exclusão
		If AllTrim(SE5->E5_ORIGEM) == "BXLOTSE1"
			RecLock("SE5",.F.)
			SE5->E5_LA := "S"
			MsUnlock()
		EndIf
		
		DbSelectArea("SE5")
		DbSkip()
	Enddo

	DbSelectArea("FK6")
	DbOrderNickName("IDORIGFK6")
	DbSeek(xFilial("FK6") + _IdOrigSE5)
	If Found()
		RecLock("FK6",.F.)
		FK6->FK6_HISTOR := "Desconto Rapel s/Receb.Titulo"
		MsUnlock()
	Endif

Return
