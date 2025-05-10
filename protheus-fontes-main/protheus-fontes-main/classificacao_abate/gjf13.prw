#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF13     º Autor Giuliano Forgiarini  º Data ³  09/05/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de controle e análise de ph por aviso de matança º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF13()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "para controle e análise de pH por carcaças conforme"
	Local cDesc3         := "o aviso de matança indicado"
	//Local cPict          := ""
	Local titulo         := "R3 - ANALISE E CONTROLE DE pH"
	Local nLin           := 80
	Local Cabec1         := "  Seq.    Lc: Clas: PhD: PhE:              | eq.    Lc: Clas: PhD: PhE:               | eq.    Lc: Clas: PhD: PhE: "
	Local Cabec2         := "  Carc.                                      Carc.                                      Carc.                      "
	//Local Cabec3         := " "
	//Local imprime        := .T.
	Local aOrd           := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "GJF13" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "GJF13"
	//Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "GJF13" // Coloque aqui o nome do arquivo usado para impressao em disco

	Private cString := "SZK"

	dbSelectArea("SZK")

	pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario..                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

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
	Local _lLin   := 1 
	Local _cSeq   := space(1)  
	Local _OBS    := space(1) 
	Local _cNumam := space(8)   
	Local _nCComp := 0
	Local _nCInc  := 0 
	Local _ClasL  := space(3)
	Local _nAbtNE := 0 
	Local _nAbtHK := 0
	Local _nAbtUSA:= 0
	Local _nAbtBR := 0
	Local _nPhNE  := 0
	Local _nPhHK  := 0
	Local _nPhUSA := 0
	Local _nPhBR  := 0
	Local _nPhRU  := 0
	Local _nPhRA  := 0
	Local _nPhRT  := 0
	Local _nGra   := 0 
	Local _nNE    := 0
	Local _nHK    := 0
	Local _nUSA   := 0
	Local _nBR    := 0
	Local _nRU    := 0
	Local _nRUUY  := 0
	Local _nRUCN  := 0
	Local _nTST	  := 0
	Local _nHKCN  := 0
	Local _nHKUY  := 0
	Local _nRA    := 0
	Local _nRT    := 0
	Local Cabec3  := " "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetRegua(RecCount())

	SZK->(dbsetorder(2))   
	SZL->(dbsetorder(1))
	SZK->(dbGoTop())
	if SZK->(MsSeek(FWxfilial('SZK')+mv_par01))
		While SZK->(!eof()) .and. SZK->ZK_FILIAL = FWxFilial('SZK') .and. alltrim(SZK->ZK_NUMAM) = alltrim(mv_par01)
			incregua()

			if !empty(mv_par04)
				if SZK->ZK_CLASSIF <> mv_par04
					SZK->(dbskip())
					loop
				endif
			endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o cancelamento pelo usuario...                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If lAbortPrint
				@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impressao do cabecalho do relatorio. . .                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If nLin > 75
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 8
			endif

			_nPh1 := 0
			_nPh2 := 0  

			if SZL->(MsSeek(FWxfilial('SZL')+SZK->ZK_NUMAM+SZK->ZK_CONTROL+"D"))
				_nPh1 := SZL->ZL_PH                                              
			endif

			if SZL->(MsSeek(FWxfilial('SZL')+SZK->ZK_NUMAM+SZK->ZK_CONTROL+"E"))
				_nPh2 := SZL->ZL_PH
			endif

			if mv_par02 = 1
				if _nPh1 = 0 .and. _nPh2 = 0
					SZK->(DbSkip())
					loop
				endif
			endif

			if !empty(mv_par03)
				if SZK->ZK_LOCAL <> mv_par03
					SZK->(DbSkip())
					loop
				endif
			endif

			if !empty(mv_par05)
				if SZK->ZK_LOTE <> mv_par05
					SZK->(DbSkip())
					loop
				endif
			endif

			if mv_par06 = 1
				if SZK->ZK_CLASESP <> '1'
					SZK->(DbSkip())
					loop
				endif 
			elseif mv_par06 = 2
				if SZK->ZK_CLASESP <> '2'
					SZK->(DbSkip())
					loop
				endif 
			elseif mv_par06 = 3
			endif

			if _nPh1 <> 0 .and. _nPh2 <> 0
				_nCComp++
			elseif  (_nPh1 <> 0  .and. _nPh2 = 0) .or. (_nPh1 = 0  .and. _nPh2 <> 0)
				_nCInc++
			endif

			if SZK->ZK_DESTINO = 'G'
				_OBS  := 'Graxaria'
				_nGra++
			elseif SZK->ZK_DESTINO = 'S'
				_OBS := 'Conserva'
			elseif SZK->ZK_MATURA = 'N'
				_OBS := 'Desc.Matu.'
			endif

			if AllTrim(SZK->ZK_CLASSIF) = 'NE'
				_nAbtNE++
			elseif AllTrim(SZK->ZK_CLASSIF) = 'HK'
				_nAbtHK++
			elseif AllTrim(SZK->ZK_CLASSIF) = 'USA'
				_nAbtUSA++
			elseif AllTrim(SZK->ZK_CLASSIF) = 'BR'
				_nAbtBR++
			endif

			_ClasL := GetAdvFval('SZ4','Z4_CLASSIF',FWxfilial('SZ4')+SZK->(ZK_NUMAM+ZK_LOTE),1)

			if SZK->ZK_CLASABA <> _ClasL .and. SZK->ZK_DESTINO <> 'G' .and.	SZK->ZK_DESTINO <> 'S' .and. SZK->ZK_MATURA <> 'N'
				_OBS  := 'Desc.Abate'
			elseif SZK->ZK_CLASSIF <> SZK->ZK_CLASABA .and. SZK->ZK_TOP = 'S' .and. SZK->ZK_MATURA <> 'N'
				_OBS := 'Desc.Cama.'
			elseif SZK->ZK_CLASSIF <> SZK->ZK_CLASABA .and. (SZK->ZK_DESTINO <> 'G' .or. SZK->ZK_DESTINO <> 'S') .and.	SZK->ZK_MATURA <> 'N'
				_OBS := 'Desc.pH'
				if AllTrim(SZK->ZK_CLASSIF) = 'NE'
					_nPhNE++
				elseif AllTrim(SZK->ZK_CLASSIF) = 'HK'
					_nPhHK++
				elseif AllTrim(SZK->ZK_CLASSIF) = 'USA'
					_nPhUSA++
				elseif AllTrim(SZK->ZK_CLASSIF) = 'BR'
					_nPhBR++
				elseif AllTrim(SZK->ZK_CLASSIF) = 'RU'
					_nPhRU++
				elseif AllTrim(SZK->ZK_CLASSIF) = 'RA'
					_nPhRA++
				elseif AllTrim(SZK->ZK_CLASSIF) = 'RT'
					_nPhRT++
				endif
			endif

			if AllTrim(SZK->ZK_CLASSIF) = 'NE'
				_nNE++
			elseif AllTrim(SZK->ZK_CLASSIF) = 'HK'//.and. SZK->ZK_CLASESP != '1'
				_nHK++
			elseif AllTrim(SZK->ZK_CLASSIF) = 'USA'//.and. SZK->ZK_CLASESP != '1'
				_nUSA++
			elseif AllTrim(SZK->ZK_CLASSIF) = 'BR'//.and. SZK->ZK_CLASESP != '1'
				_nBR++
			/*elseif AllTrim(SZK->ZK_CLASSIF) = 'RU' .and. SZK->ZK_CLASESP != '1'
				_nRU++
			elseif AllTrim(SZK->ZK_CLASSIF) = 'RA'
				_nRA++*/
			elseif AllTrim(SZK->ZK_CLASSIF) = 'RT'
				_nRT++
			endif

			_nDenticao := val(SZK->ZK_DENT)

			/*If SZK->ZK_CLASESP = '1'	.and. AllTrim(SZK->ZK_CLASSIF) = 'RU' .and. _nDenticao > 4
				_nRUUY++
			endif
			if SZK->ZK_CLASESP = '1'	.and. AllTrim(SZK->ZK_CLASSIF) = 'HK' .and. _nDenticao > 4
				_nHKUY++
			endif
			if SZK->ZK_CLASESP = '1' .and. AllTrim(ZK->ZK_CLASSIF) = 'RU' .and. _nDenticao <= 4 
				_nRUCN++
				_nTST++
			endif
			if SZK->ZK_CLASESP = '1' .and. AllTrim(SZK->ZK_CLASSIF) = 'HK' .and. _nDenticao <= 4
				_nHKCN++
			endif*/

			if _cNumam <> SZK->ZK_NUMAM
				_cDia := substr(dtos(GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG')+SZK->ZK_NUMAM)),7,2)
				_cMes := substr(dtos(GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG')+SZK->ZK_NUMAM,1)),5,2)
				_cAno := substr(dtos(GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG')+SZK->ZK_NUMAM,1)),3,2)
				if nLin <=8
					nLin := 9
				endif
				@nlin,02 psay 'Aviso de Matança: ' + SZK->ZK_NUMAM
				@nlin,40 psay 'Rastro:         1733' + _cDia + _cMes + _cAno + '0000'
				nlin++
				@nlin,02 psay 'Data de Abate:    ' + DTOC(GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG')+SZK->ZK_NUMAM,1))
				@nlin,40 psay 'Quantidade:    ' + transform(GetAdvFVal('SZG','ZG_QTDTOT',FWxfilial('SZG')+SZK->ZK_NUMAM,1),'@E 9,999')
				_cNumam := SZK->ZK_NUMAM
				nlin += 2
			endif

			If ZK_DENT > '4'
				_cSeq := SZK->ZK_CONTROL + '  ' + SZK->ZK_LOCAL +'  ' + SZK->ZK_CLASSIF +;//iif(AllTrim(SZK->ZK_CLASSIF) != 'NE' .and. SZK->ZK_CLASESP = '1', '->UY',space(4)) +;
				' ['+ iif(_nPh1 > 0,transform(_nPh1,'@E 9.99'),space(4))+']['+;
				iif(_nPh2 > 0,transform(_nPh2,'@E 9.99'),space(4))+']'+ _OBS
			ElseiF ZK_DENT <= '4'
				_cSeq := SZK->ZK_CONTROL + '  ' + SZK->ZK_LOCAL +'  ' + SZK->ZK_CLASSIF +;//iif(AllTrim(SZK->ZK_CLASSIF) != 'NE' .and. SZK->ZK_CLASESP = '1', '->CN',space(4)) +;
				' ['+ iif(_nPh1 > 0,transform(_nPh1,'@E 9.99'),space(4))+']['+;
				iif(_nPh2 > 0,transform(_nPh2,'@E 9.99'),space(4))+']'+ _OBS
			EndIf

			If nLin > 75
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 8
			endif

			if nLin <=8
				nLin := 9
			endif

			if _lLin = 1
				@nlin,02 psay _cSeq
				_lLin := 2
			elseif _lLin = 2
				@nlin,44 psay '| '+_cSeq//43
				_lLin := 3
			elseif _lLin = 3
				@nlin,88 psay '| '+_cSeq//86
				_lLin := 1
				nlin++
			endif

			_OBS := space(1)
			SZK->(dbSkip()) // Avanca o ponteiro do registro no arquivo)
		EndDo
	endif	            

	Cabec1 := padc('RESUMO FINAL',132,'-')
	Cabec(Titulo,Cabec1,Cabec3,NomeProg,Tamanho,nTipo)
	nLin := 9
	//@ nlin,02 psay 'Numero de carcaças com pH analisado completamente: ' + transform(_nCComp,'@E 9,999')
	//nlin += 2
	/*bloco removido a pedido da Grazieli Ebling
	@nlin,00 psay replicate('-',132)
	nlin += 2   
	@ nlin,02 psay 'Carcaças classificadas NE no abate:                ' + transform(_nAbtNE,'@E 9,999')
	nlin += 2
	@ nlin,02 psay 'Carcaças classificadas HK no abate:                ' + transform(_nAbtHK,'@E 9,999') 
	nlin += 2 
	*/
	@nlin,00 psay replicate('-',132)

	nlin += 2   
	@ nlin,02 psay 'Carcaças reclassificação por pH :'   
	nlin += 2
	if _nPhRT <> 0
		@ nlin,02 psay '- Carcaças RT:          ' + transform(_nPhRT,'@E 999')
		nlin += 2
	endif
	/*
	if _nPhRA <> 0
		@ nlin,02  psay  '- Carcaças RA:          ' + transform(_nPhRA,'@E 999')
		nlin += 2
	endif
	if _nPhRU <> 0
		@ nlin,02 psay  '- Carcaças RU:          ' + transform(_nPhRU,'@E 999')
		nlin += 2
	endif*/
	if _nPhUSA <> 0
		@ nlin,02 psay  '- Carcaças USA:         ' + transform(_nPhUSA,'@E 999')
		nlin += 2
	endif
	if _nPhHK <> 0
		@ nlin,02 psay  '- Carcaças HK:          ' + transform(_nPhHK,'@E 999')
		nlin += 2
	endif
	if _nPhBR <> 0
		@ nlin,02 psay  '- Carcaças BR:          ' + transform(_nPhBR,'@E 999')
		nlin += 2
	endif
	if _nPhNE <> 0
		@ nlin,02 psay  '- Carcaças NE:          ' + transform(_nPhNE,'@E 999')
		nlin += 2
	endif
	@nlin,00 psay replicate('-',132)
	nlin += 2

	/*bloco removido a pedido da Grazieli Ebling
	@ nlin,02 psay 'Total de carcaças condenadas (Graxaria):           ' + transform(_nGra,'@E 9,999')  	
	nlin += 2 
	@nlin,00 psay replicate('-',132)
	nlin += 2                       
	*/
	@ nlin,02 psay 'Classificação Final de Carcaças:'   
	nlin += 2 

	if _nRT <> 0	
		@ nlin,02 psay '- Carcaças somente RT:          ' + transform(_nRT,'@E 999')
		nlin += 2
	endif    
	/*
	if _nRA <> 0
		@ nlin,02  psay  '- Carcaças somente RA:          ' + transform(_nRA,'@E 999')
		nlin += 2
	endif    
	if _nRU <> 0
		@ nlin,02 psay  '- Carcaças somente RU:          ' + transform(_nRU,'@E 999')
		nlin += 2
	endif
	if _nRUUY <> 0 
		@ nlin,02 psay  '- Carcaças RU->UY:          ' + transform(_nRUUY,'@E 999')
		nlin += 2
	endif
	if _nHKUY <> 0 
		@ nlin,02 psay  '- Carcaças HK->UY:          ' + transform(_nHKUY,'@E 999')
		nlin += 2
	endif 
	if _nTST <> 0
		@ nlin,02 psay  '- Carcaças RU->CN:          ' + transform(_nTST,'@E 999')
		nlin += 2
	endif
	if _nHKCN <> 0 
		@ nlin,02 psay  '- Carcaças HK->CN:          ' + transform(_nHKCN,'@E 999')
		nlin += 2
	endif*/
	if _nHK <> 0
		@ nlin,02 psay  '- Total de carcaças HK:          ' + transform(_nHK,'@E 999')
		nlin += 2
	endif
	if _nUSA <> 0
		@ nlin,02 psay  '- Total de carcaças USA:         ' + transform(_nUSA,'@E 999')
		nlin += 2
	endif
	if _nBR <> 0
		@ nlin,02 psay  '- Total de carcaças BR:          ' + transform(_nBR,'@E 999')
		nlin += 2
	endif
	if _nNE <> 0
		@ nlin,02 psay  '- Total de carcaças NE:          ' + transform(_nNE,'@E 999')
		nlin += 2
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

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
