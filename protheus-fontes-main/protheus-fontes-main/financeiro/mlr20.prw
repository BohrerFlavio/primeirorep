#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MLR20 ³ Autor ³ Mauricio Roehrs   ³ Data ³ 07/08/2013 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Controle do Sequencial de Arquivo CNAB                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilizacao³ Especifico para Frigorífico Silva                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   Data   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//Função inicial que controla o sequencial do arquivo CNAB
User Function MLR20()
	Local _aArqTrb  := {}
	Private _nQuant := 0
	Private _nSeq   := GETMV('SI_CNABCAI')
	Private valor   := space(03)
	Private campoA  := space(06)
	Private campoB  := {"NAO","SIM"}
	/*
	DEFINE MSDIALOG telacnab FROM 0,0 TO 200,350 PIXEL TITLE "CONFIRMAÇÃO SEQUENCIAL CNAB"

	@ 01,01 SAY "Ultimo sequencial gerado:" of telacnab
	@ 08,80 MSGET CampoA VAR _nSeq SIZE 25,10 OF telacnab PIXEL WHEN .f.
	@ 02,01 SAY "Deseja manter o sequencial?" of telacnab
	@ 02,10 COMBOBOX valor items campoB SIZE 40,08 OF telacnab

	TButton():New(70, 10, "CONFIRMAR"     , telacnab,{|| telacnab:end() },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG telacnab CENTERED

	
	if valor = "NAO"
		_nSeq++
		PUTMV('SI_CNABCAI',_nSeq)
	endif
	*/
	_nSeq++
		PUTMV('SI_CNABCAI',_nSeq)
		/* Dia 15/07/22 - Claudioir solicitou que fosse comentada a linha abaixo*/
	//Processa({||mlr20Func()} ,"PROCESSANDO REGISTROS...","Selecionando Funcionarios...")

	// ProcData 04/2023 - Chamada para fechar arquivo de trabalho
	u_arqtrb ("FechaTodos",,,, @_aArqTrb) 
return _nSeq

//Função para selecionar quais funcionarios irão compor o arquivo CNAB
Static Function mlr20Func()
	Private _nValAdian := 0
	Private _nValFol   := 0
	Private _nValResc  := 0
	Private _cAdian    := iif(alltrim(mv_par01) = 'ADI','SIM','NAO')
	Private _cFolha    := iif(alltrim(mv_par01) = 'FOL','SIM','NAO')
	Private _cResci    := iif(alltrim(mv_par01) = 'RES','SIM','NAO')
	Private lInverte   := .f.
	Private cMark      := GetMark()
	Private oMark
	Private marc       := .f.

	//alert(mv_par01)


	SRA->(DbSetOrder(1))
	SRA->(DbGoTop())
	//ProcRegua(_nQuant)
	ProcRegua(SRA->(RecCount()))

	while SRA->(!eof()) .and. SRA->RA_FILIAL = xfilial('SRA')

		incproc()

		if SRA->RA_GERALIQ = ''
			SRA->(DbSkip())
			loop
		endif

		reclock('SRA',.f.)
		SRA->RA_GERALIQ := ''
		msunlock()

		SRA->(DbSkip())
	enddo

	SRA->(DbGoTop())

	_aArqTrb    := {} 
	aStru := dbStruct()

	//dbcreate(cArq,aStru)        //Cria a estrutura do vetor no TMP criado
	// ProcData 04/2023 - Chamada para criar arquivo de trabalho
	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	If Select('TMP')<>0   		//Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
	Endif

	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )  //Manda usar o TMP.
	//DbSelectArea('TMP')


	//alert(mv_par11)
	TMP->(DbGoTop())
	SRA->(DbSetOrder(1))
	SRA->(DbGoTop())
	//Seleciona Registros para arquivo temporario com base em informações passadas pelo Sr. Clailton
	SRA->(dbSeek(xFilial('SRA')))
	while SRA->(!eof()) .and. xFilial('SRA') = SRA->RA_FILIAL .and. SRA->RA_MAT <= mv_par11


		_nValAdian  := fBuscaCPO('SRC',1,xFilial('SRC') + SRA->RA_MAT + '170','RC_VALOR')//Adiantamento
		_nValFol 	:= fBuscaCPO('SRC',1,xFilial('SRC') + SRA->RA_MAT + '799','RC_VALOR')//Folha

		//_nValResc 	:= fBuscaCPO('SRC',1,xFilial('SRC') + SRA->RA_MAT + '496','RC_VALOR')//Rescisao


		if SRA->RA_MAT < mv_par10
			SRA->(DbSkip())
			loop
		endif

		if (_cFolha = 'NAO' .and. _cResci = 'NAO') .and. (_cAdian = 'SIM' .and. _nValAdian <= 0) //Adiantamento
			SRA->(DbSkip())
			loop
		endif

		if (_cAdian = 'NAO' .and. _cResci = 'NAO') .and. (_cFolha = 'SIM' .and. _nValFol <= 0) //Folha
			SRA->(DbSkip())
			loop
		endif

		if (_cAdian = 'NAO' .and. _cFolha = 'NAO') .and. (_cResci = 'SIM') //.and. _nValResc <= 0) //Recisão

			_cQuery := " SELECT COUNT(RR_MAT)   AS RETORNO
			_cQuery += " FROM  " + RetSQLTab('SRR')
			_cQuery += " WHERE " + RetSQLFil('SRR')
			_cQuery += " AND RR_DATAPAG BETWEEN '" + dtos(mv_par21) + "' AND '" + dtos(mv_par22) + "'"
			_cQuery += " AND RR_TIPO3 = 'R' AND RR_PD = '496' AND RR_VALOR > 0 AND RR_MAT = '" + SRA->RA_MAT + "'"
			_cQuery += " AND " + RetSQLDel('SRR')

			_cQuery := ChangeQuery(_cQuery)

			//	* Mostrar a consulta */
			//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
			//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
			//Activate Dialog oDlgMemo

			If Select("QRY")<>0
				QRY->(dbCloseArea())
			Endif

			TCQUERY _cQuery NEW ALIAS "QRY"

			if QRY->RETORNO  = 0
				SRA->(DbSkip())
				loop
			endif
		endif

		if(_cAdian = 'SIM') .and. (_cFolha = 'SIM') .and. (_cResci = 'SIM')
			SRA->(DbSkip())
			loop
		endif

		if(_cAdian = 'SIM' .and. _cFolha = 'NAO') .and.(_cResci = 'SIM')
			SRA->(DbSkip())
			loop
		endif

		if(_cAdian = 'NAO' .and. _cFolha = 'SIM') .and. (_cResci = 'SIM')
			SRA->(DbSkip())
			loop
		endif

		if(_cAdian = 'SIM' .and. _cFolha = 'SIM') .and. (_cResci = 'NAO')
			SRA->(DbSkip())
			loop
		endif


		reclock('TMP',.t.)
		TMP->RA_MAT     := SRA->RA_MAT
		TMP->RA_NOME    := SRA->RA_NOME
		TMP->RA_SITFOLH := SRA->RA_SITFOLH
		msunlock()

		SRA->(DbSkip())
	enddo

	aCampos := {}

	AADD(aCampos,{"RA_GERALIQ"  ,, "OK"       	,"@!"   })
	AADD(aCampos,{"RA_MAT"      ,, "Matricula"  ,"@!"   })
	AADD(aCampos,{"RA_NOME"     ,, "Nome"		,"@!"   })
	AADD(aCampos,{"RA_SITFOLH"  ,, "Situacao"   ,"@!"   })

	dbselectarea('TMP')

	TMP->(dbgotop())

	DEFINE MSDIALOG oDlg TITLE "Funcionarios para CNAB" From 9,0 To 400,1000 PIXEL
	oMark := MsSelect():New("TMP","RA_GERALIQ","",aCampos,@lInverte,@cMark,{17,1,160,500},,,,,)
	oMark:bMark := {| | Disp()}

	TButton():New(170, 020, "Marcar Todos"    , oDlg,{|| mlr20Sel()   },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(170, 070, "Gerar"        	  , oDlg,{|| mlr20Conta() },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(170, 390, "Sair"            , oDlg,{|| oDlg:end()   },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg CENTERED

return

Static Function Disp()

	RecLock("TMP",.F.)
	if Marked("RA_GERALIQ")
		TMP->RA_GERALIQ := cMark
	else
		TMP->RA_GERALIQ := ""
	endif
	msunlock()
	oMark:oBrowse:Refresh()

Return .t.

Static Function mlr20Conta()

	Processa({||mlr20Gera()} ,"PROCESSANDO REGISTROS PARA ARQUIVO CNAB","Selecionando Funcionarios...")

return

//Efetiva marcação dos funcionarios para CNAB
Static Function mlr20Gera()

	SRA->(dbsetorder(1))
	TMP->(dbgotop())

	//ProcRegua(_nQuant2)
	ProcRegua(TMP->(RecCount()))
	while TMP->(!eof())
		if !empty(TMP->RA_GERALIQ)

			incproc()
			marc := .t.

			SRA->(dbsetorder(1))
			if SRA->(dbseek(xfilial('SRA')+TMP->RA_MAT))
				reclock('SRA',.f.)
				SRA->RA_GERALIQ := 'S'
				msunlock()
			endif

		endif
		TMP->(dbskip())
	enddo

	if marc
		msgbox('Funcionarios selecionados para geração do CNAB ',"CONFIRMAÇÃO","INFO")
	else
		msgbox('Não houveram funcionarios selecionados!',"OPERACAO NULA",'INFO')
	endif

	oDlg:end()
return .t.

//Função que marca todos os funcionarios para geração do cnab
Static Function mlr20Sel()
	TMP->(dbgotop())

	while TMP->(!eof())
		reclock('TMP',.f.)
		TMP->RA_GERALIQ := cMark
		msunlock()
		TMP->(dbskip())
	enddo

	TMP->(dbgotop())

	oMark:oBrowse:Refresh()
return .t.
