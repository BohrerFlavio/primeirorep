#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "totvs.ch"
#INCLUDE "colors.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF68     ºAutor  ³Giuliano Forgiarini º Data ³  12/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Previsão e gerenciamento de Produção da entrada da desossa º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF68()

	//Local aIndSZ2   	:= {}						// Arquivo e número de índice utilizado
	Local cCondicao 	:= ""						// Condição para a filtragem
	lOk := .f.
	aObjects := {}                                             //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()
	AAdd( aObjects, {100, 100, .T., .T. } )
	AAdd( aObjects, {100, 50, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	bLegenda1 :=  "SZ2->Z2_STATUS = 'A' .and. SZ2->Z2_FILIAL = '" + FWxfilial('SZ2')+"'"
	bLegenda2 :=  "SZ2->Z2_STATUS = 'E' .and. SZ2->Z2_FILIAL = '" + FWxfilial('SZ2')+"'"
	bLegenda3 :=  "SZ2->Z2_STATUS = 'I' .and. SZ2->Z2_FILIAL = '" + FWxfilial('SZ2')+"'"
	bLegenda4 :=  "SZ2->Z2_STATUS = 'B' .and. SZ2->Z2_FILIAL = '" + FWxfilial('SZ2')+"'"

	aCores2:= { { 'BR_VERDE'     ,'Aberta'    },;
				{ 'BR_VERMELHO'  ,'Encerrada' },;
				{ 'BR_AMARELO'   ,'Iniciada'  },;
				{ 'BR_AZUL'      ,'Bloqueada' }}

	aCores := { {bLegenda1, 'BR_VERDE'},{ bLegenda2, 'BR_VERMELHO'    },{ bLegenda3, 'BR_AMARELO'    } ,{ bLegenda4, 'BR_AZUL'    }}
	// 					aberto		              encerrada                     iniciada                		bloqueada

	Private cPerg   := "GJF68"
	Private cCadastro := "Previsão de Gerenciamento de Producao - Desossa"
	Private aRotina := {{"Pesquisar"  ,"AxPesqui"		,0,1} ,;
						{"&Visualizar","AxVisual"		,0,2} ,;
						{"&Incluir"   ,"u_gjf68inc"		,0,3} ,;
						{"E&xcluir"   ,"u_gjf68X('X')"	,0,5} ,;
						{"En&cerrar"  ,"u_gjf68X('E')"	,0,4} ,;
						{"Vis.Cert"   ,"u_Vcertif"		,0,4} ,;
						{"Liberar"    ,"u_gjf68lib"		,0,4} ,;
						{"Bloquear"   ,"u_gjf68blo"		,0,4} ,;
						{"Ger.Lote"   ,"u_gjf68Lot"		,0,4} ,;
						{"Lib.Carc."  ,"u_gjf68lca"		,0,4} ,;
						{"Lib.Terc."  ,"u_gjf68ter"		,0,4} ,;
						{"Legenda"    ,"u_gjf68leg"		,0,2}}

	//Aadd(aButtons,{"AUTOM", {||certif()},"Visualiza QR"    ,"Visualiza QR"  })
	Private _cOPCorte := ''
	Private _aClasEsp := {}

	dbSelectArea("SZ2")
	SZ2->(dbsetorder(1))

	if !pergunte(cPerg,.t.)
		return
	endif
	cCondicao := " (Z2_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "') "+;
	" AND (Z2_DTPROD BETWEEN '" + dtos(mv_par03) + "' AND '" + dtos(mv_par04) + "') "+;
	" AND Z2_FILIAL = '" + FWxfilial('SZ2') + "'" //String para filtro
	//Aplicação da filtragem
	if mv_par05 <> 4
		cCondicao += " AND Z2_CORORI = '" + iif(mv_par05 = 1,"T",iif(mv_par05 = 2,"D","C")) + "'"
	endif

	if mv_par06 <> 3
		cCondicao += " AND Z2_PRIORID IN(" + iif(mv_par06 = 1,"'R','D','P','A'","'T'") +  ")"
	endif

	if !empty(mv_par07)
		cCondicao += " AND Z2_NUMAM = '" + mv_par07 + "'"
	endif

	mBrowse(6,1,22,75,"SZ2", ,,,,2,aCores,,,,,,,,cCondicao)
	DbCloseArea()

return

// Botão para liberar e bloquear múltiplas OPs de Terceiros
User Function gjf68ter()
	Local _cQuery1 	:= ""
	Local _cQuery2 	:= ""
	Local cPerg		:= "GJF68T"

	pergunte(cPerg,.T.)

	while empty(mv_par01) .or. empty(mv_par02) .or. empty(mv_par03)
		FWAlertWarning('Por favor, preencha todos os parâmetros para continuar!','ALERTA!')
		pergunte(cPerg,.T.)
	end

	_cQuery1 := "UPDATE " + RetSqlName('SZ2')
	_cQuery1 += " SET Z2_STATUS = 'B'"
	_cQuery1 += " WHERE D_E_L_E_T_ <> '*'"
	_cQuery1 += " AND Z2_COD IN ('001340','001502','001450')"
	_cQuery1 += " AND Z2_PRIORID = 'T'"
	_cQuery1 += " AND Z2_STATUS <> 'B'"
	_cQuery1 += " AND Z2_FILIAL = '" + FWxFilial('SZ2') + "'"
	TcSqlExec(_cQuery1)

	_cQuery2 := "UPDATE " + RetSqlName('SZ2')
	_cQuery2 += " SET Z2_STATUS = 'A'"
	_cQuery2 += " WHERE D_E_L_E_T_ <> '*'"
	_cQuery2 += " AND Z2_COD IN ('001340','001502','001450')"
	_cQuery2 += " AND Z2_PRIORID = 'T'"
	_cQuery2 += " AND Z2_DATAABT = '" + dtos(mv_par01) + "'"
	_cQuery2 += " AND Z2_CORORI = '" + iif(mv_par02 = 1, 'T', if(mv_par02 = 2, 'D', 'C')) + "'"
	_cQuery2 += " AND Z2_CLASSIF = '" + mv_par03 + "'"
	_cQuery2 += " AND Z2_FILIAL = '" + FWxFilial('SZ2') + "'"
	TcSqlExec(_cQuery2)

Return

//INCLUSAO DA PREVISAO DE PRODUCAO
user function gjf68inc()
	Local nCont
	DEFINE MSDIALOG oDlg TITLE 'Previsão de Gerenciamento de Producao' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("SZ2",.T.)

	M->Z2_STATUS := 'A'

	obj := MsMGet():New("SZ2" ,SZ2->(RECNO()),3   ,     ,     ,     ,          ,aPosObj[1],              ,,,,,oDlg,,,.F. )

	@ aPosObj[2,1],002     BUTTON 'Calcular'            SIZE 47,20 ACTION u_gjf68Qtd(M->Z2_RESERV)                 OBJECT oBtn1

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||gjf68ok()},{||gjf68nok()})
	If lOk
		Processa({||GravaZAJ()},"GERAÇÃO DE PREVISAO DE PRODUÇÃO","Gravando registros na tabela ZAJ..." )     

		ConfirmSX8()

		recLock('SZ2',.T.)
		// Grava previsao de producao
		For nCont := 1 To FCount()
			If "FILIAL"$Field(nCont)
				FieldPut(nCont,FWxFilial("SZ2"))
			Else
				FieldPut(nCont,M->&(FIELDNAME(nCont)))
			Endif
		Next nCont

		MsUnLock()
	else
		RollBackSx8()
	endif

return

//funçao que confirma a inserção da previsao de produção
static function gjf68ok()
	//simplesmente calcula o que vai ser produzido   

	lOk := .f.
	if M->Z2_QPPECA <> 0

		If Select('TMP')<>0                                                           
			lOk := .t.  
		endif

	Endif

	Odlg:end()

Return lOk

static function gjf68nok()
	lOk := .f.
	Odlg:end()
Return

//Exclui ou encerra a previsão de produção
user function gjf68X(_oper)

	cNum := SZ2->Z2_NUM

	if SZ2->Z2_STATUS $ 'B/I' .and. _oper = 'X'
		FWAlertWarning('Previsão de Produção não pode ser excluída. Encerre-a primeiro!', 'ALERTA!')
		return
	elseif SZ2->Z2_STATUS = 'E' .and. _oper = 'E'
		FWAlertWarning('Previsão de Produção já encerrada!', 'ALERTA!')
		return		
	endif
	//ou se reserva carcaça
	dbselectarea('ZAJ')
	ZAJ->(dbSetOrder(1))
	ZAJ->(DbGoTop())

	if ZAJ->(MsSeek(FWxfilial('ZAJ') + SZ2->Z2_NUMAM))             //laço para calculo mediante os parametros   

		While ZAJ->(!eof()) .and. ZAJ->ZAJ_FILIAL = FWxfilial("ZAJ") .and. ZAJ->ZAJ_NUMAM  = SZ2->Z2_NUMAM

			if SZ2->Z2_NUM <> ZAJ->ZAJ_PREDES
				ZAJ->(DbSkip())
				loop
			endif

			if empty(ZAJ->ZAJ_DATAS) .and. empty(ZAJ->ZAJ_HORAS) 
				reclock('ZAJ',.f.)
				ZAJ->ZAJ_PREDES := ''
				msunlock()
			endif

			ZAJ->(dbskip())
		enddo
	endif

	reclock('SZ2',.f.)
	if _oper = 'X'
		dbdelete()
	else
		SZ2->Z2_STATUS := 'E'
	endif
	msunlock()

	SZ2->(dbsetorder(2))
	SZ2->(MsSeek(FWxfilial('SZ2') + cNum ,.t.))

	if _oper = 'X'
		FWAlertSuccess('Previsão de Produção excluída!', 'SUCESSO!')
	else
		FWAlertSuccess('Previsão de Produção encerrada!', 'SUCESSO!')
	endif
return

user Function gjf268leg()
	BrwLegenda('Previsão de Produção',"Legenda",aCores2)
return

user function gjf68lib()
	if SZ2->Z2_STATUS != 'E' .and. SZ2->Z2_STATUS != 'I' .and. SZ2->Z2_STATUS != 'A'
		reclock('SZ2',.f.)
		if SZ2->Z2_QRPECA = 0
			SZ2->Z2_STATUS := 'A'
		else
			SZ2->Z2_STATUS := 'I'
		endif
		msunlock()
	else
		msgbox('Status não permite essa operação!','OPERAÇÃO INVALIDA!','STOP')
	endif
return

user function gjf68blo()
	if SZ2->Z2_STATUS != 'B' .and. SZ2->Z2_STATUS != 'E'
		reclock('SZ2',.f.)
		SZ2->Z2_STATUS := 'B'
		msunlock()
	else
		msgbox('Status não permite essa operação!','OPERAÇÃO INVALIDA!','STOP')
	endif
return

//Função para sugerir e reservar a quantidade de peças a serem desossadas de acordo com os parametros
User Function gjf68qtd(oper)                                                                     //parametro oper define se somente calcula
	MsgRun("Aguarde... Realizando contagem de registros...",,{||  u_gf68ap(oper) })
return

//Função chamada...
User Function gf68ap(oper)

	GeraTMP()

	M->Z2_QPPESO := 0.00
	M->Z2_QPPECA := 0

	_cOPCorte := M->Z2_NUM

	if substr(M->Z2_NUMAM,1,3) = 'SIF'
		M->Z2_QPPESO := 999999.99
		M->Z2_QPPECA := 9999
		return .t.
	endif

	ZAJ->(dbSetOrder(1))
	SZK->(dbsetorder(4))
	ZAJ->(DbGoTop())
	SZK->(DbGoTop())
	_aClasEsp := {}

	//Se prioridade for (T)erceiros...
	if alltrim(M->Z2_PRIORID) = 'T'
		buscaCert(M->Z2_CERTIF,M->Z2_CORORI,M->Z2_DERIV)
		while QRY->(!eof())   
			if !empty(QRY->ZAJ_PREDES)
				QRY->(DbSkip())
				loop					
			endif	 

			M->Z2_QPPECA := M->Z2_QPPECA + 1	   

			reclock('TMP',.t.)
			TMP->SEQPECA  := QRY->ZAJ_NUM
			msunlock()  

			QRY->(DbSkip())	
		enddo

	elseif ZAJ->(MsSeek(FWxfilial('ZAJ') + M->Z2_NUMAM))             //laço para calculo mediante os parametros
		While ZAJ->(!eof()) .and. ZAJ->ZAJ_FILIAL = FWxfilial("ZAJ") .and. ZAJ->ZAJ_NUMAM  = M->Z2_NUMAM  

			//Trata carcaças já baixadas
			if !empty(ZAJ->ZAJ_HORAS) .and. !empty(ZAJ->ZAJ_DATAS)
				ZAJ->(dbskip())
				loop
			endif

			//Trata o empenho
			if !empty(ZAJ->ZAJ_PREDES)
				ZAJ->(dbskip())
				loop
			endif 

			//Se é op de um produto derivativo faz o tratamento
			if !empty(M->Z2_DERIV)
				if M->Z2_DERIV <> ZAJ->ZAJ_COD
					ZAJ->(DbSkip())
					loop
				endif
			endif

			if SZK->(MsSeek(FWxfilial('SZK') + ZAJ->(ZAJ_NUMAM + ZAJ_CONTRO) ))
				_cClasEsp := SZK->ZK_CLASESP

				//Trata a tipificação
				if SZK->ZK_TIPIFI <> M->Z2_TIPIFI .and. M->Z2_PRIORID $ 'R/A'
					ZAJ->(dbskip())
					loop
				endif

				//Trata o programa
				if SZK->ZK_PROGRAM <> M->Z2_PROGRAM .and. M->Z2_PRIORID $ 'P/A'
					ZAJ->(dbskip())
					loop
				endif

				if ZAJ->ZAJ_CORORI <> M->Z2_CORORI
					ZAJ->(DbSkip())
					loop
				endif

				//Trata se é black
				if !empty(M->Z2_BLACK)
					if SZK->ZK_BLACK <> M->Z2_BLACK
						ZAJ->(dbSkip())
						loop
					endif
				endif             

				/*if ZAJ->ZAJ_COD <> M->Z2_COD
				ZAJ->(dbskip())
				loop
				endif*/

				//Trata a categoria
				if !empty(M->Z2_CATEG) .and. M->Z2_PRIORID <> 'D'
					if SZK->ZK_CATEG <> M->Z2_CATEG
						ZAJ->(DbSkip())
						loop
					endif
				endif

				//Trata a dentição
				if !empty(M->Z2_DENT)
					if SZK->ZK_DENT <> M->Z2_DENT
						ZAJ->(DbSkip())
						loop
					endif
				endif

				//Trata a Camara *BOTAR PRA RODAR*
				if !empty(M->Z2_CAMARA)
					if SZK->ZK_LOCAL <> M->Z2_CAMARA
						ZAJ->(DbSkip())
						loop
					endif
				endif

				//Se a Previsão de Produção tiver prioridade por rastreabilidade ou Ambos...
				if M->Z2_PRIORID $ 'R/A'
					_cClasEsp := SZK->ZK_CLASESP

					if M->Z2_CLASESP = 'S'

						if _cClasEsp <> '1' 
							ZAJ->(DbSkip())
							loop
						endif

						//Bloco comentando dia 22/12/15 para atender solicitação dos dois Matheuses(Giuliano)                    
						//if !trtClasEsp2(_cClasEsp)
						//	ZAJ->(DbSkip())
						//	loop
						//endif

						//ignorar esta linha abaixo
						//trataClasEsp(_cClasEsp)
					endif

					if M->Z2_CLASESP = 'N'
						if _cClasEsp <> '2'
							ZAJ->(dbSkip())
							loop
						endif
					endif

					//Se a previsão de Produção tiver prioridade Ambos...
					if M->Z2_PRIORID = 'A' 
						if  SZK->ZK_PROGRAM <> M->Z2_PROGRAM
							ZAJ ->(DbSkip())
							loop
						endif
					endif

					//Trata as classificações por rastreabiliade...
					do case
						case AllTrim(M->Z2_CLASSIF) = 'RU'
						if AllTrim(SZK->ZK_CLASSIF) $ 'RU/RT'
							M->Z2_QPPECA := M->Z2_QPPECA + 1
							M->Z2_QPPESO := M->Z2_QPPESO + ZAJ->ZAJ_PESO

							if oper = 'S'														 //para reserva da carcaça

								reclock('TMP',.t.)
								TMP->NUMAM    := M->Z2_NUMAM
								TMP->SEQABT   := ZAJ->ZAJ_CONTRO
								TMP->SEQPECA  := ZAJ->ZAJ_NUM
								TMP->CLASESP  := _cClasEsp
								msunlock()

							endif
						endif

						case AllTrim(M->Z2_CLASSIF) = 'RT'
						if (AllTrim(SZK->ZK_CLASSIF) = 'RT')
							M->Z2_QPPECA := M->Z2_QPPECA + 1
							M->Z2_QPPESO := M->Z2_QPPESO + ZAJ->ZAJ_PESO

							if oper = 'S'														 //para reserva da carcaça

								reclock('TMP',.t.)
								TMP->NUMAM    := M->Z2_NUMAM
								TMP->SEQABT   := ZAJ->ZAJ_CONTRO
								TMP->SEQPECA  := ZAJ->ZAJ_NUM
								TMP->CLASESP  := _cClasEsp
								msunlock()
							endif

						endif
						case AllTrim(M->Z2_CLASSIF) = 'USA'
						if (AllTrim(SZK->ZK_CLASSIF) = 'USA')

							M->Z2_QPPECA := M->Z2_QPPECA + 1
							M->Z2_QPPESO := M->Z2_QPPESO + ZAJ->ZAJ_PESO

							if oper = 'S'														 //para reserva da carcaça

								reclock('TMP',.t.)
								TMP->NUMAM    := M->Z2_NUMAM
								TMP->SEQABT   := ZAJ->ZAJ_CONTRO
								TMP->SEQPECA  := ZAJ->ZAJ_NUM
								TMP->CLASESP  := _cClasEsp
								msunlock()
							endif

						Endif

						case AllTrim(M->Z2_CLASSIF) = 'BR'
						if (AllTrim(SZK->ZK_CLASSIF) = 'BR')

							M->Z2_QPPECA := M->Z2_QPPECA + 1
							M->Z2_QPPESO := M->Z2_QPPESO + ZAJ->ZAJ_PESO

							if oper = 'S'														 //para reserva da carcaça

								reclock('TMP',.t.)
								TMP->NUMAM    := M->Z2_NUMAM
								TMP->SEQABT   := ZAJ->ZAJ_CONTRO
								TMP->SEQPECA  := ZAJ->ZAJ_NUM
								TMP->CLASESP  := _cClasEsp
								msunlock()
							endif

						Endif

						case AllTrim(M->Z2_CLASSIF) = 'HK'                                                   //calculo se for HK
						if AllTrim(SZK->ZK_CLASSIF) $ 'HK/RU/RT'
							M->Z2_QPPECA := M->Z2_QPPECA + 1
							M->Z2_QPPESO := M->Z2_QPPESO + ZAJ->ZAJ_PESO

							if oper = 'S'														 //para reserva da carcaça

								reclock('TMP',.t.)
								TMP->NUMAM    := M->Z2_NUMAM
								TMP->SEQABT   := ZAJ->ZAJ_CONTRO
								TMP->SEQPECA  := ZAJ->ZAJ_NUM
								TMP->CLASESP  :=	_cClasEsp
								msunlock()

							endif

						endif
						//calculo se for NE
						case AllTrim(M->Z2_CLASSIF) = 'NE'
						if  AllTrim(SZK->ZK_CLASSIF) $ 'NE/HK/RU/RA/RT'
							M->Z2_QPPECA := M->Z2_QPPECA + 1
							M->Z2_QPPESO := M->Z2_QPPESO + ZAJ->ZAJ_PESO

							if oper = 'S'														 //para reserva da carcaça

								reclock('TMP',.t.)
								TMP->NUMAM    := M->Z2_NUMAM
								TMP->SEQABT   := ZAJ->ZAJ_CONTRO
								TMP->SEQPECA  := ZAJ->ZAJ_NUM
								TMP->CLASESP  := _cClasEsp
								msunlock()

							endif

						endif
					endcase

					//Se a Previsão de Produção tiver prioridade por programa...
				elseif M->Z2_PRIORID = 'P'
					if  SZK->ZK_PROGRAM = M->Z2_PROGRAM
						M->Z2_QPPECA := M->Z2_QPPECA + 1
						M->Z2_QPPESO := M->Z2_QPPESO + ZAJ->ZAJ_PESO

						if oper = 'S'														 //para reserva da carcaça

							reclock('TMP',.t.)
							TMP->NUMAM    := M->Z2_NUMAM
							TMP->SEQABT   := ZAJ->ZAJ_CONTRO
							TMP->SEQPECA  := ZAJ->ZAJ_NUM
							TMP->CLASESP  := _cClasEsp
							msunlock()

						endif
					endif

				elseif M->Z2_PRIORID = 'D' //prioridade por dentição
					if  SZK->ZK_DENT = M->Z2_DENT
						M->Z2_QPPECA := M->Z2_QPPECA + 1
						M->Z2_QPPESO := M->Z2_QPPESO + ZAJ->ZAJ_PESO

						if oper = 'S'														 //para reserva da carcaça

							reclock('TMP',.t.)
							TMP->NUMAM    := M->Z2_NUMAM
							TMP->SEQABT   := ZAJ->ZAJ_CONTRO
							TMP->SEQPECA  := ZAJ->ZAJ_NUM
							TMP->CLASESP  := _cClasEsp
							msunlock()

						endif
					endif		 

				elseif M->Z2_PRIORID = 'C' .and. _cClasEsp = '1' //prioridade por classificação especial

					M->Z2_QPPECA := M->Z2_QPPECA + 1
					M->Z2_QPPESO := M->Z2_QPPESO + ZAJ->ZAJ_PESO

					if oper = 'S'														 //para reserva da carcaça

						reclock('TMP',.t.)
						TMP->NUMAM    := M->Z2_NUMAM
						TMP->SEQABT   := ZAJ->ZAJ_CONTRO
						TMP->SEQPECA  := ZAJ->ZAJ_NUM
						TMP->CLASESP  := _cClasEsp
						msunlock()

					endif
				endif
			endif

			ZAJ->(DbSkip())
		enddo 

	endif

	oDlg:refresh()
return .t.

user Function gjf68leg()
	BrwLegenda('Previsão de Produção',"Legenda",aCores2)
return

//Execblock de gatilho no campo Z2_CORORI
User Function GJF68c()
	Local _cCod  := ''
	Local _cDesc := ''

	DbSelectArea('SB1')
	if M->Z2_PRIORID <> 'T'
		do case
			case M->Z2_CORORI = 'T'
			_cCod := '005016'
			case M->Z2_CORORI = 'D'
			_cCod := '005020'
			case M->Z2_CORORI = 'C'
			_cCod := '005018'
		endcase
	else
		do case
			case M->Z2_CORORI = 'T'
			_cCod := '001340'
			case M->Z2_CORORI = 'D'
			_cCod := '001502'
			case M->Z2_CORORI = 'C'
			_cCod := '001450'
		endcase
	endif

	_cDesc := GetAdvFVal('SB1','B1_DESC',FWxfilial('SB1')+_cCod,1)

	M->Z2_COD    := _cCod
	M->Z2_DESCRI := _cDesc

return .t.


//Validação do campo Z2_DERIV
User Function GJF68d()
	Local _cCod    := ''
	Local _cDesc   := ''
	Local _cCorOri := ''

	ZB4->(DbSetOrder(1))
	if ZB4->(MsSeek(FWxfilial('ZB4')+M->Z2_DERIV))
		_cCod     := ZB4->ZB4_COD
		_cDesc    := ZB4->ZB4_DESC
		_cCorOri  := ZB4->ZB4_CODORI
	endif

	M->Z2_COD    := _cCod
	M->Z2_DESCRI := _cDesc
	M->Z2_CORORI := _cCorOri

return .t.
//Função para liberação de carcaças não usadas das OPs
User Function gjf68lca()

	_nCarc := 0
	if SZ2->Z2_STATUS <> 'E'
		msgbox('Previsão de Produção ainda não encerrada!','OPERAÇÃO INCONSISTENTE!','ERRO')
		return .f.
	endif

	dbselectarea('ZAJ')
	ZAJ->(dbSetOrder(1))
	ZAJ->(DbGoTop())

	if ZAJ->(MsSeek(FWxfilial('ZAJ') + SZ2->Z2_NUMAM))

		while  ZAJ->(!eof()) .and. ZAJ->ZAJ_FILIAL = FWxfilial('ZAJ') .and. ZAJ->ZAJ_NUMAM = SZ2->Z2_NUMAM

			if SZ2->Z2_NUM = ZAJ->ZAJ_PREDES
				if !empty(ZAJ->ZAJ_DATAS)  .and.;
				!empty(ZAJ->ZAJ_HORAS)  .and.;
				!empty(ZAJ->ZAJ_PRECAR) .and.;
				!empty(ZAJ->ZAJ_PREPED) .and.;
				!empty(ZAJ->ZAJ_ITEM)

					_nCarc++

					reclock('ZAJ',.f.)
					ZAJ->ZAJ_PREDES := ' '
					msunlock()

				endif
			endif

			ZAJ->(dbskip())
		enddo
	endif
	msgbox('TOTAL DE CARCAÇAS COM RESERVA LIBERADA: ' + transform(_nCarc,'@E 9,999'),'FIM DE OPERAÇÃO','INFO')
return .t.


User Function gjf68Lot()
	campoA := {'NE','HK','RU','RT'}
	campoB := {'Liberar','Bloquear'}
	valor1 := ''
	valor2 := ''
	DEFINE MSDIALOG oDlg2 TITLE 'Gerenciamento em Lote' from 000,000 To 100,250 OF oMainWnd PIXEL
	@ 013,002 SAY  'Classificação:' Object oSay1
	@ 025,002 SAY  'Operação:' Object oSay2
	@ 001,006 COMBOBOX valor1 items campoA SIZE 20,08
	@ 002,006 COMBOBOX valor2 items campoB SIZE 40,08
	@ 014,100 BMPBUTTON TYPE 1 ACTION Lote() Object Obtn1
	@ 028,100 BMPBUTTON TYPE 2 ACTION odlg2:end() Object Obtn2
	ACTIVATE MSDIALOG oDlg2
return .t.

Static Function Lote()

	SZ2->(DbSetOrder(2))
	SZ2->(DbGoTop())
	SZ2->(MsSeek(FWxfilial('SZ2')) )

	While SZ2->(!eof()) .and. SZ2->Z2_FILIAL = FWxfilial('SZ2')

		if SZ2->Z2_STATUS = 'E'
			SZ2->(DbSkip())
			loop
		endif
		if AllTrim(SZ2->Z2_CLASSIF) <> valor1
			SZ2->(DbSkip())
			loop
		endif

		if valor2 = 'Liberar'
			if SZ2->Z2_QRPECA <> 0
				reclock('SZ2',.f.)
				SZ2->Z2_STATUS := 'I'
				msunlock()
			elseif SZ2->Z2_QRPECA = 0
				reclock('SZ2',.f.)
				SZ2->Z2_STATUS := 'A'
				msunlock()
			endif
		elseif valor2 = 'Bloquear'
			if SZ2->Z2_STATUS $ 'A/I'
				reclock('SZ2',.f.)
				SZ2->Z2_STATUS := 'B'
				msunlock()
			endif
		endif

		SZ2->(DbSkip())

	enddo

	SZ2->(DbSetOrder(1))
	odlg2:end()
Return .t.

////Funções para atualização do mBrowse////
Static Function AutoRefresh(oDlg)
	Local oTimer
	oTimer := TTimer():New(2, {|| PBrow() }, oDlg)
	oTimer:Activate()
Return .T.

////Funções para atualização do mBrowse////
Static Function PBrow()
	oBrowse := getObjBrow()
	oBrowse:default()
	oBrowse:refresh()
Return

//Função para gerar arquivo TMP
Static Function GeraTMP()

	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMP->(dbCloseArea())
	//Endif

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	_aArqTrb := {}
	aStru := {}

	aadd(aStru,{"NUMAM"   , "C",   08, 0,  "@!",'Abate'})	
	aadd(aStru,{"SEQABT"  , "C",   06, 0,  "@!",'Seq.Abate'})
	aadd(aStru,{"SEQPECA" , "C",   10, 0,  "@!",'Seq.Peca'}) 
	aadd(aStru,{"CLASESP" , "C",   01, 0,  "@!",'Clas.Esp.'})

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado
	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMP->(dbCloseArea())
	//Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

Return  

//Grava o que está no TMP para a ZAJ
Static Function GravaZAJ()
	local _nCont := 0
	_aArqTrb := {}

	if M->Z2_RESERV = 'S'

		If Select('TMP')<>0
			ZAJ->(DbSetOrder(2))
			SZK->(DbSetOrder(4))
			SZK->(DbGoTop())
			ZAJ->(DbGoTop())
			TMP->(DbGoTop())

			While TMP->(!eof())
				_ncont++
				TMP->(DbSkip())
			enddo

			TMP->(DbGoTop())

			//Se houverem registros selecionados
			//faz o processo...
			if _nCont <> 0

				ProcRegua(M->Z2_QPPECA)

				While TMP->(!eof())

					incproc()
					if ZAJ->(MsSeek(FWxfilial('ZAJ')+ TMP->SEQPECA))
						reclock('ZAJ',.f.)
						ZAJ->ZAJ_PREDES := _cOPCorte
						msunlock()
					endif
					TMP->(DbSkip())

				enddo

				TMP->(dbCloseArea())

				u_arqtrb ("FechaTodos",,,, @_aArqTrb)

				//Tratamaneto do vetor com peças
				//cujo ClasEsp deve ser alterado para "2"
				/*if len(_aClasEsp) <> 0
				SZK->(DbGoTop())
				for i:= 1 to len(_aClasEsp)
				if SZK->(MsSeek(FWxfilial('SZK') + M->Z2_NUMAM + _aClasEsp[i]))
				reclock('SZK',.f.)
				SZK->ZK_CLASESP := '2'
				msunlock()
				endif
				next
				endif*/
			endif
		Endif
	endif

return

Static Function buscaCert(_cNum,_cCorOri,_cDeriv)

	_cQuery := " SELECT ZAJ_NUM, ZAJ_IMP, ZAJ_ZAPNUM, ZAJ_PREDES"
	_cQuery += " FROM  " + retSqlTab('ZAJ')
	_cQuery += " WHERE " + retSqlFil('ZAJ')
	_cQuery += " AND ZAJ_ZAPNUM = '" + _cNum + "' AND ZAJ_IMP = 'S'"
	_cQuery += " AND ZAJ_DATAS = '' AND ZAJ_HORAS = '' AND ZAJ_CORORI = '" + _cCorOri + "'"
	_cQuery += iif(!empty(_cDeriv)," AND ZAJ_COD = '" + _cDeriv + "'","")
	_cQuery += " AND " + retSqlDel('ZAJ')
	_cQuery += " ORDER BY ZAJ_NUM"

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

return

Static Function trataClasEsp(_cClasEsp)

	//Trata a classificação especial (igual a 1 = Sim)
	/*Se o Ph não estiver preenchido a carcaça deixa de ser classifcação especil
	no momento da geração da OP - solicitado pelo Matheus Silva*/
	if _cClasEsp = '1'
		_Ph1:= 0
		_Ph2:= 0
		_pH1 := GetAdvFVal('SZL','ZL_PH',FWxFilial('SZL') + ZAJ->(ZAJ_NUMAM + ZAJ_CONTRO) + 'D',1)
		_pH2 := GetAdvFVal('SZL','ZL_PH',FWxFilial('SZL') + ZAJ->(ZAJ_NUMAM + ZAJ_CONTRO) + 'E',1)

		if (_pH1 = 0) .or. (_pH2 = 0)
			_cClasEsp := '2'
			aadd(_aClasEsp,ZAJ->ZAJ_CONTRO)
		endif

	endif	

return

Static Function trtClasEsp2(_cClasEsp)

	Local _lConta := .f.

	//Trata a classificação especial (igual a 1 = Sim)
	/*Se o Ph não estiver preenchido a carcaça deixa de ser classifcação especil
	no momento da geração da OP - solicitado pelo Matheus Silva*/
	if _cClasEsp = '1'

		_lConta := .t. 

		_Ph1:= 0
		_Ph2:= 0
		_pH1 := GetAdvFVal('SZL','ZL_PH',FWxFilial('SZL') + ZAJ->(ZAJ_NUMAM + ZAJ_CONTRO) + 'D',1)
		_pH2 := GetAdvFVal('SZL','ZL_PH',FWxFilial('SZL') + ZAJ->(ZAJ_NUMAM + ZAJ_CONTRO) + 'E',1)

		if (_pH1 = 0) .or. (_pH2 = 0)
			_lConta := .f.
		endif

	endif	

return _lConta

/*  Função criada para mostrar o nr do certificado da tabela ZAP  */
User Function Vcertif()
	Local cCodigo := SZ2->Z2_CERTIF 
	//Local cCodigo := alltrim(M->Z2_CERTIF)

	_cCERT := GetAdvFVal('ZAP','ZAP_CERT',FWxfilial('ZAP')+alltrim(cCodigo),3)

	if !empty(alltrim(cCodigo))
		FWAlertInfo('Certificado Nr: ' + _cCERT, 'CERTIFICADO')
	else
		FWAlertError('Previsão da Desossa sem Certificado Marcado!', 'ERRO!')
	endif
Return
