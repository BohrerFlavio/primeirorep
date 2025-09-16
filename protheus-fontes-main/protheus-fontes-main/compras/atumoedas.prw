#INCLUDE "PROTHEUS.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "RWMAKE.CH"
//#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} ATUMOEDAS
Rotina efetua a atualização e projeta moedas / cambio a partir do site do banco central
@author     Evandro
@since      30/06/2020
@return     Nil
@obs        Utilizado nos módulos de faturamento, compras, financeiro e contabilidade gerencial 
		=>	Cadastrar 'Task Scheduler' no Windows de segunda a sexta para cada empresa/filial necessária
		=>	Start a Program -> Ex.: 	'E:\TOTVS12\Protheus12\bin\smartclient_x64\smartclient.exe' 
		=>	Add Arguments (optional) -> '-m -e=SILVA -p=U_atumoedas -a="0100"' onde no -a é informado empresa e filial
/*/

User Function AtuMoedas(_cEmpFil)

	Private _cEmp  := IIF(_cEmpFil==nil,"01",SubStr(_cEmpFil,1,2))
	Private _cFil  := IIF(_cEmpFil==nil,"01",SubStr(_cEmpFil,3,2))

	Private lAuto		:= .T.
	Private dDataRef, dData
	Private nValReal	:= 0
	Private nValDolar	:= 0
	Private nValUfir	:= 0.828700
	Private nValEuro	:= 0
	Private nValIene	:= 0
	Private nN			:= 0
	Private nS1, nS2, nS3
	Private nI1, nI2, nI3
	Private oDlg
	Private nDiasPro	:= 999
	Private nDiasReg	:= 999

	//RpcSetType(3) 			// Seta job para não consumir licensas

	WFPrepEnv( _cEmp, _cFil,, {"SM2","CTP"}, "FIN")

	_ExecMoeda()

	RpcClearEnv()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} _EXECMOEDA
Função que prepara prepara as informações para importação pelo arquivo .CSV
@author     Evandro
@since      26/06/2020
@param      N/A
@return     Nil
/*/
//-------------------------------------------------------------------
Static Function _ExecMoeda()

	Local nPass, cFile, cTexto, nLinhas, cLinha, cCompra, cVenda, J//, cdata, K
	Local xValDolar	:= 0
	Local xValEuro	:= 0
	Local xValIene	:= 0

	For nPass := 6 To 1 step -1			// Refaz os ultimos 5 dias. O BCB não disponibiliza periodo maior de uma semana
		dDataRef := dDataBase - nPass

		// Feriados Bancários Fixos
		If ( Dtos(dDataRef+1) == STR(Year(Date()),4)+'0101' )		// Dia Mundial da Paz
			cFile := Dtos(dDataRef - 2)+'.csv'
		ElseIf	Dtos(dDataRef+1) == STR(Year(Date()),4)+'0421'	// Dia de Tiradentes
			cFile := Dtos(dDataRef - 1)+'.csv'
		ElseIf	Dtos(dDataRef+1) == STR(Year(Date()),4)+'0501'	// Dia do Trabalho
			cFile := Dtos(dDataRef - 1)+'.csv'
		ElseIf	Dtos(dDataRef+1) == STR(Year(Date()),4)+'0907'	// Dia da Independencia
			cFile := Dtos(dDataRef - 1)+'.csv'
		ElseIf	Dtos(dDataRef+1) == STR(Year(Date()),4)+'1012'	// Dia da Nossa Sra. Aparecida
			cFile := Dtos(dDataRef - 1)+'.csv'
		ElseIf	Dtos(dDataRef+1) == STR(Year(Date()),4)+'1102'	// Dia de Finados
			cFile := Dtos(dDataRef - 1)+'.csv'
		ElseIf	Dtos(dDataRef+1) == STR(Year(Date()),4)+'1115'	// Dia da Proclamação da Republica
			cFile := Dtos(dDataRef - 1)+'.csv'
		ElseIf	Dtos(dDataRef+1) == STR(Year(Date()),4)+'1225'	// Natal
			cFile := Dtos(dDataRef - 1)+'.csv'
		ElseIf	Dtos(dDataRef+1) == STR(Year(Date()),4)+'1231'	// Dia sem Expediente Bancário
			cFile := Dtos(dDataRef - 1)+'.csv'
		ElseIf	Dow(dDataRef+1) == 1								// FINAL DE SEMANA (Se for Domingo)
			cFile := Dtos(dDataRef - 1)+'.csv'
		ElseIf	Dow(dDataRef+1) == 7  							// FINAL DE SEMANA (Se for Sábado)
			cFile := Dtos(dDataRef)+'.csv'
		ElseIf	Dow(dDataRef+1) == 2  							// INICIO DA SEMANA (Se for Segunda)
			cFile := Dtos(dDataRef - 2)+'.csv'
		Else													// Se for dia Normal
			cFile := Dtos(dDataRef)+'.csv'
		EndIf

		_http  := 'https://www4.bcb.gov.br/download/fechamento/' + cFile

		//Conout("Empresa / Filial: " + _cEmp + "/" + _cFil + "    link: " + _http)

		cTexto := HttpGet(_http,,15)

		If dtos(dDataRef)<'20130815'
			cTexto := StrTran(cTexto, Chr(10), Chr(13)+Chr(10))
		EndIf

		If ! Empty(cTexto)
			nLinhas := MLCount(cTexto)
			cLinha	:= Memoline(cTexto,65,1)
			//cData	:= Substr(cLinha,1,6)+substr(cLinha,9,2)

			nValDolar := 0
			nValIene  := 0
			nValEuro  := 0

			For J := 1 To nLinhas
				cLinha := Memoline(cTexto,,j)
				//cData  := Substr(cLinha,1,10)

				cCompra := StrTran(Substr(cLinha,22,10),',','.')	// Caso a empresa use o 'Valor de Compra' nas linhas abaixo substitua por esta variável
				cVenda  := StrTran(Substr(cLinha,33,10),',','.')	// Para conversão interna nas empresas normalmente usa-se 'Valor de Venda'

				If (Substr(cLinha,12,3) == '220')		// Seleciona o Valor do DÓLAR
					//dData	  := Ctod(cData)
					nValDolar := Val(cCompra)
				EndIf

				If (Substr(cLinha,12,3) == '978')		// Seleciona o Valor do EURO
					nValEuro := Val(cCompra)
				EndIf

				/*
				If (Substr(cLinha,12,3) == '470')		// Seleciona o Valor do IENE (NÃO USADO)
				nValIene := Val(cCompra)
				EndIf
				*/
			Next

			If nValDolar + nValEuro + nValIene <> 0
				xValDolar := nValDolar
				xValEuro  := nValEuro
				xValIene  := nValIene

				//_GrvDados(dData,"J")						// Grava Dados do Período selecionado em "J"
				_GrvDados(dDataRef+1,"J")						// Grava Dados do Período selecionado em "J"
			EndIf
		EndIf
	Next nPass

	If nValDolar + nValEuro + nValIene == 0
		nValDolar := xValDolar
		nValEuro  := xValEuro
		nValIene  := xValIene
	EndIf

	/*If nValDolar + nValEuro + nValIene <> 0
		// Sempre gravará hoje + 4 dias  (NÃO USADO)
		hoje := dData
		For K := 1 To 30
		hoje += 1

		_GrvDados(hoje,"K")					// Grava os Valores de Sabado, Domingo e Segunda, para calculo da Regressão
		Next
	EndIf*/

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} _GRVDADOS
Função que gravação dos dados na SM0 e CTP
@author     Evandro
@since      26/06/2020
@param      N/A
@return     Nil
/*/
//-------------------------------------------------------------------
Static Function _GrvDados(dDtp,Tipo)

	// Grava Moedas
	DbSelectArea("SM2")
	SM2->(DbSetorder(1))
	If SM2->(DbSeek(Dtos(dDtp)))
		cReg := "DATA JA EXISTE"
		Reclock('SM2',.F.)
	Else
		cReg := "DATA NOVA     "
		Reclock('SM2',.T.)
		SM2->M2_DATA := dDtp
	EndIf
	SM2->M2_MOEDA1 := nValReal				// REAL
	SM2->M2_MOEDA2 := nValDolar				// DÓLAR
	SM2->M2_MOEDA3 := nValUfir				// UFIR
	SM2->M2_MOEDA4 := nValEuro				// EURO
	SM2->M2_MOEDA5 := nValIene				// IENE
	SM2->M2_INFORM := "S"
	MsUnlock('SM2')

	/*
	//ConOut(Tipo + " - EmpFil: " + _cEmp + _cFil + " " + DtoC(dDtp) + " " + cREg + ;
			" ->REAL: "  + Transform(nValReal,  '@E 9999.999999') + ;
			" ->DOLAR: " + Transform(nValDolar, '@E 9999.999999') + ;
			" ->UFIR: "  + Transform(nValUfir,  '@E 9999.999999') + ;
			" ->EURO: "  + Transform(nValEuro,  '@E 9999.999999') + ;
			" ->IENE: "  + Transform(nValIene,  '@E 9999.999999'))
	*/
	
	// Grava Cambio (NÃO USADO)
	/*
	DbSelectArea('CTP')
	CTP->(DbSetorder(1))
	If CTP->(DbSeek(xFilial('CTP') + Dtos(dDtp) + '01'))		// REAL
	RecLock('CTP',.F.)
	Else
	RecLock('CTP',.T.)
	CTP->CTP_FILIAL	:= xFilial('CTP')
	CTP->CTP_DATA	:= dDtp
	EndIf
	CTP->CTP_MOEDA := '01'
	CTP->CTP_TAXA  := nValReal
	CTP->CTP_BLOQ  := '2'
	MsUnlock('CTP')

	If CTP->(DbSeek(xFilial('CTP') + Dtos(dDtp) + '02'))		// DÓLAR
	RecLock('CTP',.F.)
	Else
	RecLock('CTP',.T.)
	CTP->CTP_FILIAL	:= xFilial('CTP')
	CTP->CTP_DATA	:= dDtp
	EndIf
	CTP->CTP_MOEDA := '02'
	CTP->CTP_TAXA  := nValDolar
	CTP->CTP_BLOQ  := '2'
	MsUnlock('CTP')

	If CTP->(DbSeek(xFilial('CTP') + Dtos(dDtp) + '03'))		// UFIR
	RecLock('CTP',.F.)
	Else
	RecLock('CTP',.T.)
	CTP->CTP_FILIAL	:= xFilial('CTP')
	CTP->CTP_DATA	:= dDtp
	EndIf
	CTP->CTP_MOEDA := '03'
	CTP->CTP_TAXA  := nValUfir
	CTP->CTP_BLOQ  := '2'
	MsUnlock('CTP')

	If CTP->(DbSeek(xFilial('CTP') +Dtos(dDtp) + '04'))			// EURO
	RecLock('CTP',.F.)
	Else
	RecLock('CTP',.T.)
	CTP->CTP_FILIAL	:= xFilial('CTP')
	CTP->CTP_DATA	:= dDtp
	EndIf
	CTP->CTP_MOEDA := '04'
	CTP->CTP_TAXA  := nValEuro
	CTP->CTP_BLOQ  := '2'
	MsUnlock('CTP')

	If CTP->(DbSeek(xFilial('CTP') + Dtos(dDtp) + '05'))		// IENE
	RecLock('CTP',.F.)
	Else
	RecLock('CTP',.T.)
	CTP->CTP_FILIAL	:= xFilial('CTP')
	CTP->CTP_DATA	:= dDtp
	EndIf
	CTP->CTP_MOEDA := '05'
	CTP->CTP_TAXA  := nValIene
	CTP->CTP_BLOQ  := '2'
	MsUnlock('CTP')
	*/

Return
