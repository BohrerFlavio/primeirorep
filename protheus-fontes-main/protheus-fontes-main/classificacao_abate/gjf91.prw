#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF91   º Autor ³ Giuliano Forgiarini  º Data ³  20/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ R10 - Relatorio de Rastreabilidade - Expedição de peças    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Qualidade e PCP (SIGAPCP)                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF91()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "de expedição de peças para fins de controle de      "
	Local cDesc3         := "rastreabilidade e estoque de peças proprias         "
	//Local cPict          := ""
	Local titulo         := "R10 - EXPEDIÇÃO DE PEÇAS"
	Local nLin           := 80

	Local Cabec1         := "Dados do Aviso de Matança"
	Local Cabec2         := "   Data      Hora       Produto                  Dt.Abate Carreg. |"+;
	"      Data      Hora     Produto               Dt.Abate Carreg."

	//Local imprime        := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "GJF91" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "GJF91"
	//Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "GJF91" // Coloque aqui o nome do arquivo usado para impressao em disco

	pergunte(cPerg,.t.)

	wnrel := SetPrint('ZZ2',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	//para verificação se existe previsao de pesagem

	cQuery := " SELECT ZAJ_CONTRO AS CONTRO, (ZAJ_NUMAM+ZAJ_CONTRO) AS RASTRO, ZAJ_NUMAM AS NUMAM,"
	cQuery += " ZAJ_COD AS COD, ZAJ_PRECAR AS PRECAR, ZAJ_CORORI AS CORORI, ZAJ_ZAPNUM AS CERTIF,"
	cQuery += " ZAJ_DESCRI AS DESCRI, ZAJ_PESOB AS PESOB, ZAJ_PESO AS PESOL,"
	cQuery += " ZAJ_PREPED AS PREPED, ZAJ_HORAS AS HORAS, ZAJ_DATAS AS DATAS"
	cQuery += " FROM " + RetSqlTab("ZAJ") + " WHERE "   
	cQuery += RetSQLFil('ZAJ') + " AND "
	if mv_par06 = 2
		cQuery += " ZAJ_PRECAR = 'ACERTO' AND "
	elseif mv_par06 = 3
		cQuery += " ZAJ_PRECAR <> '' AND ZAJ_PRECAR <> 'ACERTO' AND "
	endif
	cQuery += " ZAJ_DATAS BETWEEN '" + dtos(mv_par03) + "' AND '" + dtos(mv_par04) + "'"
	cQuery += iif(!empty(mv_par05)," AND ZAJ_PRECAR = '" + mv_par05 + "'","")
	cQuery += iif(!empty(mv_par01)," AND ZAJ_NUMAM = '" + mv_par01 + "'","")
	if !empty(mv_par07) .and. !empty(mv_par08)
		cQuery += " AND ZAJ_DATA BETWEEN '" + dtos(mv_par07) + "' AND '" + dtos(mv_par08) + "'"
	endif
	cQuery += " AND " + retSqlDel('ZAJ')
	cQuery += " ORDER BY ZAJ_NUMAM, ZAJ_CONTRO, ZAJ_COD, ZAJ_DATAS, ZAJ_HORAS"

	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("EXP") != 0
		EXP->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "EXP"

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'EXP')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	//Local nOrdem
	Local _lLin  := .t.
	Local _Seq   := space(6)
	Local _nT    := 0, _nD := 0, _nC := 0, _nO := 0
	Local _nDUSA := 0, _nDHK := 0, _nDBR := 0, _nDNE := 0, _nDSC := 0
	Local _nTUSA := 0, _nTHK := 0, _nTBR := 0, _nTNE := 0, _nTSC := 0
	Local _nCUSA := 0, _nCHK := 0, _nCBR := 0, _nCNE := 0, _nCSC := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	EXP->(dbGoTop())

	EXP->(SetRegua(RecCount()))

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	if !empty(mv_par01)
		_dDataNum := dtos(GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG')+EXP->NUMAM,1))
		_dData    := dtoc(GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG')+EXP->NUMAM,1))
		_cDataNum := substr(_dDataNum,7,2)+substr(_dDataNum,5,2)+substr(_dDataNum,3,2)		// aviso de matança sem as barras
		_cRASTRO  := GetMv("MV_NUMIF") + _cDataNum + '0000'

		@nlin,02 psay 'Rastreabilidade: ' + _cRASTRO
		nlin++
		@nlin,02 psay 'Aviso nr.:       ' + EXP->NUMAM
		nlin++
		@nlin,02 psay 'Data de Abate:   ' + _dData
		nlin += 2
	endif

	While EXP->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		_cClas    := GetAdvFVal('SZK','ZK_CLASSIF',FWxfilial('SZK')+EXP->(NUMAM+CONTRO),4)
		_cNumam   := GetAdvFVal('SZK','ZK_NUMAM',FWxfilial('SZK')+EXP->(NUMAM+CONTRO),4)
		if !empty(EXP->CERTIF)
			_cDataAbt := dtoc(GetAdvFVal('ZAP','ZAP_DATAP',FWxfilial('ZAP')+EXP->CERTIF,3))
		else
			_cDataAbt := dtoc(GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG')+EXP->NUMAM,1))
		endif

		if !empty(mv_par02)
			if mv_par02 <> _cClas
				EXP->(DbSkip())
				loop
			endif
		endif

		if _Seq <> EXP->CONTRO
			_Seq := EXP->CONTRO

			if _lLin = .f.
				nlin++
			endif

			nlin++ 

			@nlin,02 psay 'Sequencial ' + _Seq  + '   Aviso de Matança: ' +_cNumam + ' Data: ' + _cDataAbt + '    Classificação: ' + _cClas
			_lLin := .t.
			nlin++
		endif

		_String := dtoc(stod(EXP->DATAS)) + '  ' + EXP->HORAS + '  ' + alltrim(EXP->COD) + '  ' + iif(!empty(EXP->CERTIF),substr(EXP->DESCRI,1,19) + _cDataAbt + '  ' +	EXP->PRECAR,substr(EXP->DESCRI,1,20) + '         ' + EXP->PRECAR)

		if _lLin = .t.
			@nlin,02 psay _String  + ' |'
		else
			@nlin,70 psay _String
			nlin++
		endif

		_lLin := !_lLin

		if EXP->COD = '005020'
			_nD++
		elseif EXP->COD = '005016'
			_nT++
		elseif EXP->COD = '005018'
			_nC++
		else
			_nO++
		endif

		do case 
			case AllTrim(_cClas) = 'USA' .and. EXP->COD = '005020'
				_nDUSA++
			case AllTrim(_cClas) = 'USA' .and. EXP->COD = '005016'
				_nTUSA++
			case AllTrim(_cClas) = 'USA' .and. EXP->COD = '005018'
				_nCUSA++
			case AllTrim(_cClas) = 'HK' .and. EXP->COD = '005020'
				_nDHK++
			case AllTrim(_cClas) = 'HK' .and. EXP->COD = '005016'
				_nTHK++
			case AllTrim(_cClas) = 'HK' .and. EXP->COD = '005018'
				_nCHK++
			case AllTrim(_cClas) = 'BR' .and. EXP->COD = '005020'
				_nDBR++
			case AllTrim(_cClas) = 'BR' .and. EXP->COD = '005016'
				_nTBR++
			case AllTrim(_cClas) = 'BR' .and. EXP->COD = '005018'
				_nCBR++
			case AllTrim(_cClas) = 'NE' .and. EXP->COD = '005020'
				_nDNE++
			case AllTrim(_cClas) = 'NE' .and. EXP->COD = '005016'
				_nTNE++
			case AllTrim(_cClas) = 'NE' .and. EXP->COD = '005018'
				_nCNE++
			case empty(_cClas) .and. EXP->CORORI = 'D'
				_nDSC++
			case empty(_cClas) .and. EXP->CORORI = 'T'
				_nTSC++
			case empty(_cClas) .and. EXP->CORORI = 'C'
				_nCSC++
		endcase

		EXP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	EndDo

	nlin += 2

	@nlin,01 psay replicate('-', limite)
	nlin++
	If _nD <> 0
		@nlin,02 psay 'Numero de Dianteiros: ' + transform(_nD,'@E 9,999')
		nlin++
	EndIf
	If _nDUSA <> 0
		@nlin,04 psay 'Dianteiros USA:     ' + transform(_nDUSA, '@E 9,999')
		nlin++
	EndIf
	If _nDHK <> 0
		@nlin,04 psay 'Dianteiros HK:      ' + transform(_nDHK, '@E 9,999')
		nlin++
	EndIf
	If _nDBR <> 0
		@nlin,04 psay 'Dianteiros BR:      ' + transform(_nDBR, '@E 9,999')
		nlin++
	EndIf
	If _nDNE <> 0
		@nlin,04 psay 'Dianteiros NE:      ' + transform(_nDNE, '@E 9,999')
		nlin++
	EndIf
	@nlin,01 psay replicate('-', limite)
	nlin++
	//--------------------TRASEIROS------------------------------------------------------------
	If _nT <> 0
		@nlin,02 psay 'Numero de Traseiros:  ' + transform(_nT,'@E 9,999')
		nlin++
	EndIf
	If _nTUSA <> 0
		@nlin,04 psay 'Traseiros USA:      ' + transform(_nTUSA, '@E 9,999')
		nlin++
	EndIf
	If _nTHK <> 0
		@nlin,04 psay 'Traseiros HK:       ' + transform(_nTHK, '@E 9,999')
		nlin++
	EndIf
	If _nTBR <> 0
		@nlin,04 psay 'Traseiros BR:       ' + transform(_nTBR, '@E 9,999')
		nlin++
	EndIf
	If _nTNE <> 0
		@nlin,04 psay 'Traseiros NE:       ' + transform(_nTNE, '@E 9,999')
		nlin++
	EndIf
	@nlin,01 psay replicate('-', limite)
	nlin++
	//--------------------COSTELAS------------------------------------------------------------
	If _nC <> 0
		@nlin,02 psay 'Numero de Costelas:   ' + transform(_nC,'@E 9,999')
		nlin++
	EndIf
	If _nCUSA <> 0
		@nlin,04 psay 'Costelas USA:       ' + transform(_nCUSA, '@E 9,999')
		nlin++
	EndIf
	If _nCHK <> 0
		@nlin,04 psay 'Costelas HK:        ' + transform(_nCHK, '@E 9,999')
		nlin++
	EndIf
	If _nCBR <> 0
		@nlin,04 psay 'Costelas BR:        ' + transform(_nCBR, '@E 9,999')
		nlin++
	EndIf
	If _nCNE <> 0
		@nlin,04 psay 'Costelas NE:        ' + transform(_nCNE, '@E 9,999')
		nlin++
	EndIf
	@nlin,01 psay replicate('-', limite)
	nlin++
	//--------------------CORTES------------------------------------------------------------
	If _nO <> 0
		@nlin,02 psay 'Numero de Cortes:     ' + transform(_nO,'@E 9,999')
		nlin++
	EndIf
	If _nDSC <> 0
		@nlin,04 psay 'Cortes de Dianteiro:' + transform(_nDSC, '@E 9,999')
		nlin++
	EndIf
	If _nTSC <> 0
		@nlin,04 psay 'Cortes de Traseiro: ' + transform(_nTSC, '@E 9,999')
		nlin++
	EndIf
	If _nCSC <> 0
		@nlin,04 psay 'Cortes de Costela:  ' + transform(_nCSC, '@E 9,999')
		nlin++
	EndIf
	@nlin,01 psay replicate('-', limite)
	nlin++

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	EXP->(DbCloseArea())

	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return
