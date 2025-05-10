#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

//Programa:  FBF55     º Autor: Giuliano Forgiarini    º Data ³  15/03/07   º±±
//±±ºDescricao:Relatório de Produção do Abate                               º±±
//±±º          ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³ AP6 IDE                                                    º±±


User Function FBF55()

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "da produção do abate para servir de instrumento ao "
	Local cDesc3         := "controle do processo de rastreabilidade"
	Local cPict          := ""
	Local titulo         := "R11 - PRODUCAO DO ABATE"
	Local nLin           := 80

	Local Cabec1         := "  Seq.  Clas. Cam.     Numero   Tipif. Motivo        Cod.       |"+;       //L1
	"  Seq.   Clas.  Cam.     Numero    Tipif.    Motivo       Cod. "
	Local Cabec2         := " Carc.  Carc. Dest.    SISBOV   Carc.  Descl.        Prog.      |"+;      // L2
	" Carc.   Carc.  Dest.    SISBOV    Carc.     Descl.       Prog."

	Local imprime        := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private cperg        := "GJF01"
	Private nomeprog     := "FBF55"
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}

	Private nLastKey     := 0
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01

	Private wnrel        := "FBF55" // Coloque aqui o nome do arquivo usado para impressao em disco

	Private cString      := "SZK"

	pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Variaveis utilizadas para parametros                                  	³
	//³  mv_par01            //     Aviso                        				³
	//³  mv_par02            //     Do Lote                               		³
	//³  mv_par03            //     Ao Lote                                		³
	//³  mv_par04            //     Do Local                                    ³
	//³  mv_par05            //     Ao Local                                    ³
	//³  mv-par06            //     Classificação                               ³
	//³  mv-par07            //     Somente desclassificados?                   ³
	//³  mv-par08            //     Programa:                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)


	If nLastKey == 27
		Return
	Endif

	SetDefault( aReturn,cString,,,tamanho,1)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)


	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem 
	Local _cNumam  := space(1)   //Aviso de Matança
	Local _cLote   := space(1)   //Numero do lote
	Local _cSeq1    := space(1)   //Numero sequencial da carcaça
	Local _cSeq2    := space(1)   //Numero sequencial da carcaça
	Local _cSeq3    := space(1)   //Numero sequencial da carcaça
	Local _cSeq4    := space(1)   //Numero sequencial da carcaça
	Local _lLin    := .f.        //Flag para mudar de linha
	Local _cMD     := space(1)   //Impressão modivo de desclassificação
	Local _cClLote := space(2)   //Classificação do lote
	Local _nRT     := 0          //Numero de classificaçãos RT
	Local _nRU     := 0          //Numero de classificaçãos RU
	Local _nHK     := 0          //Numero de classificaçãos HK
	Local _nNE     := 0          //Numero de classificaçãos NE   
	Local _nTot    := 0          //Numero total de carcaças do abate
	Local _nRRT    := 0          //Numero total de carcaças Lançadas no recebimento (RT)
	Local _nDABT   := 0          //Numero total de carcaças desclassificadas no abate 
	Local _nCon    := 0          //Numero total de carcaças condenadas no abate 
	Local _nIF     := 0          //Numero de carcaças desclassificadas pela IF
	Local _cTST		:=''

	dbSelectArea(cString)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SZK->(SetRegua(RecCount()))


	SZK->(dbGoTop())    
	SZK->(dbsetorder(5)) 
	SZK->(dbseek(xfilial("SZK") + mv_par01,.t.))  
	While SZK->(!EOF()) .and. SZK->ZK_NUMAM = mv_par01 	
		incregua()
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

		If nLin > 75 // Salto de Página. Neste caso o formulario tem 75 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		IF (SZK->ZK_LOTE < mv_par02 .or. SZK->ZK_LOTE > mv_par03)
			dbskip()
			loop
		endif
		IF (SZK->ZK_LOCAL < mv_par04 .or. SZK->ZK_LOCAL > mv_par05)
			SZK->(dbskip())
			loop
		endif

		if !empty(mv_par06)
			if SZK->ZK_CLASABA <> mv_par06
				SZK->(DbSkip())
				loop
			endif
		endif


		if mv_par07 = 1
			if empty(SZK->ZK_RASTRO) .or. SZK->ZK_OBS = '0' 
				SZK->(DbSkip())
				loop
			endif
		endif

		if !empty(mv_par08)
			if SZK->ZK_PROGRAM <> mv_par08
				SZK->(DbSkip())
				loop
			endif
		endif

		if _cNumam <> SZK->ZK_NUMAM 
			_cDia := substr(dtos(fbuscaCPO('SZG',1,xfilial('SZG')+SZK->ZK_NUMAM,'ZG_DATA')),7,2)
			_cMes := substr(dtos(fbuscaCPO('SZG',1,xfilial('SZG')+SZK->ZK_NUMAM,'ZG_DATA')),5,2) 
			_cAno := substr(dtos(fbuscaCPO('SZG',1,xfilial('SZG')+SZK->ZK_NUMAM,'ZG_DATA')),3,2)
			@nlin,02 psay 'Ordem de Matança: ' + SZK->ZK_NUMAM 
			@nlin,40 psay 'Código de Rastreabilidade:   1733' + _cDia + _cMes + _cAno + '0000'
			nlin++
			@nlin,02 psay 'Data de Abate:    ' + DTOC(fBuscaCPO('SZG',1,xfilial('SZG')+SZK->ZK_NUMAM,'ZG_DATA')) 
			@nlin,40 psay 'Quantidade:    ' + transform(fBuscaCPO('SZG',1,xfilial('SZG')+SZK->ZK_NUMAM,'ZG_QTDTOT'),'@E 9,999')
			_cNumam := SZK->ZK_NUMAM  
			nlin++ 
		endif     

		if _cLote <> SZK->ZK_LOTE 
			nlin += 2 
			_cClLote := fBuscaCPO('SZ4',1,xfilial('SZ4')+SZK->(ZK_NUMAM+ZK_LOTE),'Z4_CLASSIF')
			@nlin,02 psay 'Lote n.: ' + SZK->ZK_LOTE + '   Classif. Original: ' + _cClLote + '   Hora início: ' + SZK->ZK_HORA  
			nlin++   
			@nlin,00 psay replicate('-',132)
			_cLote := SZK->ZK_LOTE 	
			_lLin := .f. 
			nlin++
		endif 

		if _cClLote = 'RT'
			_nRRT++
		endif	

		_cMD := space(09)  

		if SZK->ZK_IF = 'S'
			_nIF++
		endif 

		do case
			case SZK->ZK_OBS = '1'
			_cMD := padr('Sem Brinco',16,'')
			case SZK->ZK_OBS = '2'
			_cMD := padr('Br. Err.',16,'')
			case SZK->ZK_OBS = '3'
			_cMD := padr('Sexo Err.',16,'')
			case SZK->ZK_OBS = '4'
			_cMD := padr('Idade Err.',16,'') 
			case SZK->ZK_OBS = '5'
			_cMD := padr('-40 d. area hab',16,'')
			case SZK->ZK_OBS = '6'
			_cMD := padr('-90 d. ult. Prop.',16,'')
			case SZK->ZK_OBS = '7'
			_cTST := padr('DIF ',16,'')   
			otherwise
			_cMD := space(16)
		endcase                           

		if SZK->ZK_DESTINO = 'G'
			_cSeq1 := SZK->ZK_CONTROL + '   Graxaria'
			_nCon++ 
		elseif AllTrim(SZK->ZK_CLASABA) != 'NE'
			_cSeq1 := SZK->ZK_CONTROL + ' ' + SZK->ZK_CLASABA + ' ' ;
			+ SZK->ZK_LOCAL  + '  '     + SZK->ZK_RASTRO
			_cSeq2 := SZK->ZK_TIPIFI 
			_cSeq3 := _cMD
			//        _cSeq4 := SZK->ZK_RACA
			_cSeq4 := SZK->ZK_PROGRAM
		elseif AllTrim(SZK->ZK_CLASABA) = 'NE'
			_cSeq1 := SZK->ZK_CONTROL + ' ' + SZK->ZK_CLASABA + ' ' ;
			+ SZK->ZK_LOCAL   + '  '     + SZK->ZK_RASTRO 
			_cSeq2 := SZK->ZK_TIPIFI  
			_cSeq3 := _cTST
			_cSeq4 := SZK->ZK_PROGRAM
		endif
		/*
		alteração do motivo de desclassificação
		*/
		if SZK->ZK_CLASESP = '2' 
			_cSeq3 := alltrim(_cSeq3)+' 8+'
		endif   
		// ultima alteração // 
		if SZK->ZK_CONTROL = '000032'


		endif
		if SZK->ZK_CLASESP = '1'  .AND. AllTrim(SZK->ZK_CLASABA) != 'NE'
			_cSeq3 := 'CE'
		endif                                            

		if _lLin = .f.    
			@nlin,01  psay _cSeq1
			@nlin,34  psay _cSeq2        // espaço 1
			if _cSeq3 <> ''
				@nlin,36  psay substr(_cSeq3,1,13)        // espaço 16
			endif
			//@nlin,54  psay _cSeq4        // espaço 3
			_lLin := .t.
		else  
			@nlin,65 psay '| ' + _cSeq1
			@nlin,100 psay _cSeq2        // espaço 1
			@nlin,104 psay _cSeq3        // espaço 16
			//@nlin,122 psay _cSeq4        // espaço 3 
			_lLin := .f.  
			nlin++
		endif  

		if !(AllTrim(SZK->ZK_CLASABA) = 'RT') .and. AllTrim(_cClLote) = 'RT'
			_nDABT++
		endif

		do case
			case AllTrim(SZK->ZK_CLASABA) = 'RT'
			_nRT++
			case AllTrim(SZK->ZK_CLASABA) = 'RU'
			_nRU++
			case AllTrim(SZK->ZK_CLASABA) = 'HK'
			_nHK++
			case AllTrim(SZK->ZK_CLASABA) = 'NE'
			_nNE++
		endcase 
		_nTot++
		dbSkip() // Avanca o ponteiro do registro no arquivo
	End while

	nlin += 2

	Cabec1 := padc('RESUMO FINAL',132,'-') 
	Cabec2 := ''
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9   

	@nlin,02 psay 'Total de carcaças listadas do abate:            ' + transform(_nTot,'@E 999')  
	nlin += 2 

	if _nRRT <> 0
		@nlin,02 psay 'Carcaças rastreadas lançadas no recebimento:    ' + transform(_nRRT,'@E 999')  
		nlin += 2
	endif

	@nlin,02 psay 'Carcaças rastreadas desclassificadas no abate:  ' + transform(_nDABT,'@E 999')  
	nlin += 2

	@nlin,00 psay replicate('-',132)
	nlin += 2 

	@nlin,02 psay 'Resumo de carcaças por classificação: '

	nlin += 2
	if _nRT <> 0
		@nlin,02 psay '- Carcaças com classificação RT:        ' + transform(_nRT,'@E 999')  
		nlin += 2
	endif   

	if _nRU <> 0
		@nlin,02 psay '- Carcaças com classificação RU:        ' + transform(_nRU,'@E 999')
		nlin += 2
	endif  

	if _nHK <> 0
		@nlin,02 psay '- Carcaças com classificação HK:        ' + transform(_nHK,'@E 999')
		nlin += 2
	endif  

	if _nNE <> 0
		@nlin,02 psay '- Carcaças com classificação NE:        ' + transform(_nNE,'@E 999')    
		nlin += 2
	endif 

	@nlin,00 psay replicate('-',132)
	nlin += 2 

	if _nCon <> 0
		@nlin,02 psay 'Total de carcaças condenadas no abate:          ' + transform(_nCon,'@E 999')  
		nlin += 2
	endif 

	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return
