#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} FA110SE5
Ponto Entrada FA110SE5 será utilizado na gravação de dados complementares na baixa a receber automática. Será executado após gravar o SE5.
@author 	Evandro Mugnol
@since 		16/08/2016
@obs 		N/A
/*/

User Function FA110SE5()

	Local _aArea   := FWGetArea()
	Local _aAreaSE5 := SE5->(GetArea())

	_cPrefixo := SE1->E1_PREFIXO
	_cNumero  := SE1->E1_NUM
	_cParcela := SE1->E1_PARCELA
	_cTipoDoc := SE1->E1_TIPO
	_cCliente := SE1->E1_CLIENTE
	_cLojaCli := SE1->E1_LOJA
	_nRapelE1 := SE1->E1_VLRAPEL
	_IdOrigSE5 := ""

	_cRapelBx := fBuscaCpo("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA, "A1_RAPELBX")

	If _cRapelBx == "S"			// Executa somente se no cadastro do cliente o campo A1_RAPELBX estiver com Sim
		If cEmpAnt == "01"		// Executa somente para a empresa 01

			// Atualiza histórico quando tem desconto rapel
			DbSelectArea("SE5")
			DbSetOrder(7)
			DbSeek(xFilial("SE5") + _cPrefixo + _cNumero + _cParcela + _cTipoDoc + _cCliente + _cLojaCli)
			While !Eof() .And. SE5->E5_FILIAL + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + SE5->E5_CLIFOR + SE5->E5_LOJA == xFilial("SE5") + _cPrefixo + _cNumero + _cParcela + _cTipoDoc + _cCliente + _cLojaCli
				If AllTrim(SE5->E5_TIPODOC) == "DC"
					If _nRapelE1 > 0
						_IdOrigSE5 := SE5->E5_IDORIG 
						RecLock("SE5",.F.)
						SE5->E5_HISTOR = "Desconto Rapel s/Receb.Titulo"
						MsUnlock()
					Endif
				Endif
				DbSelectArea("SE5")
				DbSkip()
			Enddo

			DbSelectArea("FK6")
			DbOrderNickName("IDORIGFK6")
			DbSeek(xFilial("FK6") + _IdOrigSE5)
			If Found()
				RecLock("FK6",.F.)
				FK6->FK6_HISTOR = "Desconto Rapel s/Receb.Titulo"
				MsUnlock()
			Endif
		Endif
	Endif

	RestArea(_aAreaSE5)
	FWRestArea(_aArea)

Return
