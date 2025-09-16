#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "FILEIO.CH"

#DEFINE ENTER Chr(13)+Chr(10)

User Function PMXML003()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ PMXML003 ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Esse arquivo contém funções responsáveis pelo funcionamento³±±
	±±³          ³ da opção de importação de XML de Nota Fiscal Eletronica    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³ Especifico para clientes TOTVS                             ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   Data   ³ Programador   ³Manutencao Efetuada                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	Local _aAmb   := FWGetArea()
	Local clPar         := "MTA140I"
	Private cIniFile    := GetADV97()
	Private cStartPath  := ""
	Private cStartLido  := ""
	Private c2StartPath := ""
	Private c3StartPath := ""
	Private cStartError := ""
	Private _cUser		  := RetCodUsr()
	Private _cBtnUsers  := GetMV("SI_RECUSE2")
	Private _cBtnUs2 	  := GetMV("SI_RECUSE3")
	Private _lBtn       := .T.
	Private _lBtn2		  := .T.
	Private aRotina 	  := {{"Pesquisar" , "AxPesqui",0,1},;
	{"Visualizar", "AxVisual",0,2},;
	{"Incluir"   , "AxInclui",0,3},;
	{"Alterar"   , "AxAltera",0,4}}

	//Flag para determinar o acesso a botões do recebimento de materias
	if _cUser $ _cBtnUsers
		_lBtn := .f.
	endif

	if _cUser $ _cBtnUs2
		_lBtn2 := .f.
	endif

	// Cria Diretórios
	MakeDir(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFE\')
	If cEmpAnt == '01'
		MakeDir(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFE\01\')
		cStartPath  := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile ) + "NFE\01\ENTRADA\"
	ElseIf cEmpAnt == '07'
		MakeDir(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFE\07\')
		cStartPath  := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile ) + "NFE\07\ENTRADA\"
	ElseIf cEmpAnt == '08'
		MakeDir(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFE\08\')
		cStartPath  := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile ) + "NFE\08\ENTRADA\"
	Else
		Alert("Rotina não será executada para a empresa selecionada.")
		Return
	Endif

	cStartLido  := Trim(cStartPath) + "OLD\"
	c2StartPath := Trim(cStartLido) + AllTrim(Str(Year(Date()))) + "\"
	c3StartPath := Trim(c2StartPath) + AllTrim(Str(Month(Date()))) + "\"
	cStartError := Trim(cStartPath) + "ERRO\"

	MakeDir(Trim(cStartPath))     // Cria Diretório ENTRADA
	MakeDir(cStartLido)           // Cria Diretório ARQUIVOS IMPORTADOS
	MakeDir(c2StartPath)          // Cria Diretório ANO
	MakeDir(c3StartPath)          // Cria Diretório MES
	MakeDir(cStartError)          // Cria Diretório ERRO

	If Pergunte(clPar,.T.,"")
		MsgRun(("Aguarde..."+Space(1)+"Criando Interface"),"Aguarde...",{|| MontaBrw() } )
	EndIf

	// Restaura grupo de perguntas da rotina MATA140
	Pergunte("MTA140",.F.)

	FWRestArea(_aAmb)

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SELCOR   ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna objeto com a cor do farol                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clStatus = Status do registro (SDS->DS_STATUS)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ olCor    = LoadBitmap(GetResources(),'COR')                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MontaBrw                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SelCor(clStatus)

	Local olCor := NIL

	Do Case
		Case clStatus == 'Q'   // STATUS = LIBERADO PARA INFORMAR QTDES
		olCor:=LoadBitmap(GetResources(),'BR_AZUL')
		Case clStatus == 'L'   // STATUS = LIBERADO PARA LIBERAR QTDES
		olCor:=LoadBitmap(GetResources(),'BR_AMARELO')
		Case clStatus == 'P'   // STATUS = PROCESSADA PELO PROTHEUS
		olCor:=LoadBitmap(GetResources(),'BR_VERMELHO')
		Case clStatus == 'R'   // REJEITADO NA RECEITA
		olCor:=LoadBitmap(GetResources(),'BR_PRETO')
		OtherWise              // STATUS = LIBERADO PARA PRE-NOTA
		olCor:=LoadBitmap(GetResources(),'BR_VERDE')
	EndCase

Return olCor


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MONTHDR  ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta o aHeader do browse principal com os itens da SDS    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ alHdRet  = Array com o nome dos campos selecionados no SX3 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MontaBrw                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MontHdr()

	Local alHdRet := {}
    Local nx

	aAdd(alHdRet,"DS_STATUS")
	/* dbSelectArea("SX3")
	DbSetOrder(1)
	dbGoTop()
	SX3->(DbSeek("SDS"))

	While !EOF() .AND. SX3->X3_ARQUIVO == "SDS"
		If (SX3->X3_BROWSE=="S") .AND. (cNivel>=SX3->X3_NIVEL) .AND. (!(ALLTRIM(SX3->X3_CAMPO) $ "DS_STATUS"))
			Aadd(alHdRet,SX3->X3_CAMPO)
		EndIf
		DbSkip()
	EndDo*/

	//202304 - ajuste para usar a função FWSX3Util para buscar informações do SX3
	aSx3 := FWSX3Util():GetAllFields("SDS")
	For nx := 1 to len(aSx3)
		If X3Uso(GetSx3Cache(aSx3[nx],"X3_USADO")) .AND. cNivel >= GetSx3Cache(aSx3[nx],"X3_NIVEL") .AND. !(ALLTRIM(GetSx3Cache(aSx3[nx],"X3_CAMPO")) $ "DS_STATUS")
			//Cabecalho - Estrutura MsNewGetDados
			aAdd(alHdRet,alltrim(GetSx3Cache(aSx3[nx],"X3_CAMPO")))
		Endif
	Next nx

	aAdd(alHdRet,"DS_CHAVENF")

Return alHdRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CARITENS ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica os itens a carregar no browse perante os campos e ³±±
±±³          ³ parametro.                                                 ³±±
±±³          ³ Adiciona reg. em um array (alRet) que e usado como retorno ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ alHdr    = Array com campos do browse                      ³±±
±±³          ³ alParam  = Array com possiveis parametros sendo as posicoes³±±
±±³          ³            [1]-{1 , " " } // 1 - Liberado para pre-nota    ³±±
±±³          ³            [2]-{2 , "P" } // 2 - Processada pelo Protheus  ³±±
±±³          ³            [3]-{3 , "Q" } // 3 - Bloqueado para Inf. Qtdes ³±±
±±³          ³            [4]-{4 , "L" } // 4 - Bloqueado para Lib. Qtdes ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ alRet    = Array contendo os registros                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AtuBrw                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CarItens(alHdr,alParam)

	Local alRet     := {}
	Local cArqInd   := ""
	Local cChaveInd := ""
	Local cQuery    := ""
	Local nlK       := 0
	Local nIndice   := 0

	Pergunte("MTA140I",.F.)
	dbSelectArea("SDS")
	dbSetOrder(1)

	DO CASE
		CASE MV_PAR05 == 1
		_cTpFiltro := " "   // Aptos a Gerar
		CASE MV_PAR05 == 2
		_cTpFiltro := "P"   // Doctos Gerados
		CASE MV_PAR05 == 3
		_cTpFiltro := "R"   // Canc. Receita
		CASE MV_PAR05 == 4
		_cTpFiltro := "T"   // Todos
	ENDCASE

	cArqInd   := CriaTrab(, .F.)
	cChaveInd := IndexKey()

	If _cTpFiltro == "T"
		cQuery := 'DS_FILIAL >="' + FWxFilial("SDS") + '" .And.'
		cQuery += 'DS_DOC    >="' + mv_par01 + '".And.DS_DOC   <="' + mv_par02 + '".And.'
		cQuery += 'DS_SERIE  >="' + mv_par03 + '".And.DS_SERIE <="' + mv_par04 + '"'
	Else
		cQuery := 'DS_FILIAL >="' + FWxFilial("SDS") + '" .And.'
		cQuery += 'DS_DOC    >="' + mv_par01 + '".And.DS_DOC   <="' + mv_par02 + '".And.'
		cQuery += 'DS_SERIE  >="' + mv_par03 + '".And.DS_SERIE <="' + mv_par04 + '".And.'
		cQuery += 'DS_STATUS  ="' + _cTpFiltro + '"'
	Endif

	IndRegua("SDS", cArqInd, cChaveInd, , cQuery,"Criando indice de trabalho" )

	nIndice := RetIndex("SDS") + 1
	#IFNDEF TOP
	dbSetIndex(cArqInd + OrdBagExt())
	#ENDIF
	dbSetOrder(nIndice)
	SDS->(MsSeek(FWxFilial("SDS")))

	While SDS->(!EOF())
		AADD(alRet,Array(Len(alHdr)))
		For nlk:=1 to Len(alHdr)
			If alHdr[nlk,4]=="V"
				alRet[Len(alRet),nlk]:=CriaVar(alHdr[nlk,2])
			Else
				If AllTrim(alHdr[nlk,2])=="DS_FILIAL"
					_cFilial := FieldGet(FieldPos(alHdr[nlk,2]))
					_aArea1  := SM0->(GetArea())
					_aArea2  := GetArea()
					DbSelectArea("SM0")
					If DbSeek(cEmpAnt+_cFilial)
						alRet[Len(alRet),nlk]:=_cFilial+"-"+SM0->M0_NOME
					Else
						alRet[Len(alRet),nlk]:=_cFilial
					Endif
					RestArea(_aArea1)
					RestArea(_aArea2)
				Else
					alRet[Len(alRet),nlk]:=FieldGet(FieldPos(alHdr[nlk,2]))
				Endif
			EndIf
		Next nlk
		SDS->(dbSKip())
	Enddo

	SDS->(DbClearFil())
	RetIndex("SDS")

Return alRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MONTABRW ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta o browse principal que exibe os schemas importados   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clRaiz = Diretorio/Local arquivos raiz                     ³±±
±±³          ³ clDest = Diretorio/Local arquivos lidos                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ alRet    = Array contendo os registros                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ A140XMLNFe                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MontaBrw()

	Local alSize      := MsAdvSize()
	Local alHdCps     := {}
	Local alHdSize    := {}
	Local alCpos      := {}
	Local alItBx      := {}
	Local alParam     := {}
	Local alCpHd      := MontHdr()
	Local clLine      := ""
	Local clLegenda   := ""
	Local clFilBrw    := ""
	Local cTCFilterEX := "TCFilterEX"
	//Local nlTl1     := alSize[1]
	//Local nlTl2     := alSize[2]
	//Local nlTl3     := alSize[1]+450				//+450
	//Local nlTl4     := alSize[2]+900				//+790
	Local nlTl1     	:= alSize[1]
	Local nlTl2    	:= alSize[2]
	Local nlTl3    	:= alSize[3]
	Local nlTl4     	:= alSize[4]-30
	Local nlCont      := 0
	Local nlPosCFor   := 0
	Local nlPosLoja   := 0
	Local nlPosNum    := 0
	Local nlPosSer    := 0
	Local nlPosCHNF   := 0
	Local olLBox      := NIL
	Local olBtLeg     := NIL
	Local olBtFiltro  := NIL
	Local olBtImpM    := NIL
	Local olBtRelD	  := NIL
    Local nx

	Private _opDlgPcp := NIL
	Private opBtVis   := NIL
	Private opBtImp   := NIL
	Private opBtPed   := NIL
	Private opBtLib   := NIL
	Private opBtLib2  := NIL
	Private cIdEnt

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array alParam recebe parametros para filtro                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(alParam,{1 , " " }) // 1 - Liberado para pre-nota
	aAdd(alParam,{2 , "P" }) // 2 - Processada pelo Protheus
	aAdd(alParam,{3 , "Q" }) // 3 - Bloqueado para Inf. Qtdes
	aAdd(alParam,{4 , "L" }) // 4 - Bloqueado para Lib. Qtdes

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Header com os titulos do TWBrowse                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//202304 - Alteração para pegar dados do SX3
	/* dbSelectArea("SX3")
	dbSetOrder(2)
	For nlCont	:= 1 to Len(alCpHd)
		If MsSeek(alCpHd[nlCont])
			If alCpHd[nlCont] == "DS_STATUS"
				AADD(alHdCps," ")
				AADD(alHdSize,1)
			Else
				AADD(alHdCps,AllTrim(X3Titulo()))
				AADD(alHdSize,Iif(nlCont==1,200,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo())))
			EndIf
			AADD(alCpos,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
		EndIf
	Next */
	
	For nlCont	:= 1 to Len(alCpHd)
        //                      1          2          3          4            5          6           7
		_sQuery :=  " SELECT X3_TIPO ,X3_TAMANHO ,X3_DECIMAL ,X3_PICTURE , X3_TITULO, X3_CAMPO, X3_CONTEXT"
		_sQuery +=  " FROM " + retSqlTab("SX3")
		_sQuery +=  " WHERE " + retSqlDel("SX3")
		_sQuery +=  " AND X3_CAMPO = '" + alCpHd[nlCont] + "'"

		_CSx3 := U_Qry2Array(_sQuery)
		if len(_CSx3) > 0
			If alCpHd[nlCont] == "DS_STATUS"
				AADD(alHdCps," ")
				AADD(alHdSize,1)
			Else
				AADD(alHdCps,AllTrim(X3Titulo()))
				AADD(alHdSize,Iif(nlCont==1,200,CalcFieldSize(_CSx3[1,1],_CSx3[1,2],_CSx3[1,3], _CSx3[1,4], _CSx3[1,5])))
			EndIf
			AADD(alCpos,{AllTrim(_CSx3[1,5]),_CSx3[1,6],_CSx3[1,1],_CSx3[1,7],_CSx3[1,4]})
		endif 
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as posicoes/ordens dos campos no array                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nlPosCFor := Ascan(alCpos,{|x|Alltrim(X[2])=="DS_FORNEC"})
	nlPosLoja := Ascan(alCpos,{|x|Alltrim(X[2])=="DS_LOJA"})
	nlPosNum  := Ascan(alCpos,{|x|Alltrim(X[2])=="DS_DOC"})
	nlPosSer  := Ascan(alCpos,{|x|Alltrim(X[2])=="DS_SERIE"})
	nlPosCHNF := Ascan(alCpos,{|x|Alltrim(X[2])=="DS_CHAVENF"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Colunas da ListBox/TWBrowse                               				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	clLine := "{|| {SelCor(alItBx[olLBox:nAt,1]) ,"
	For nlCont:=2 To Len(alCpos)
		clLine += "alItBx[olLBox:nAt,"+AllTrim(Str(nlCont))+"]"+IIf(nlCont<Len(alCpos),",","")
	Next nX
	clLine += "}}"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Legenda                                             				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	clLegenda := "BrwLegenda('NF-e Disponíveis','Legenda'  ,{{'BR_AZUL'     ,'Liberado p/ Informar Qtdes'}" + ;
	" ,{'BR_AMARELO'  ,'Apto p/ Liberar Qtdes'}"      + ;
	" ,{'BR_VERDE'    ,'Apto a gerar Pré nota'}"      + ;
	" ,{'BR_VERMELHO' ,'Documento Gerado'}"           + ;
	" ,{'BR_PRETO'    ,'Cancelado Receita'}"          + ;
	" })"

	cIdEnt := U_WSAT01GetIdEnt()

	DEFINE MSDIALOG _opDlgPcp TITLE "NF-e Disponíveis" From nlTl1,nlTl2 to nlTl3,nlTl4 PIXEL 

	_opDlgPcp:lMaximized := .T. //Maximizar a janela

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botões                                                    				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	// Libera p/ Gerar Pre Nota
	//opBtLib := TButton():New(nlTl1+203,alSize[2]+004,"Informa Qtdes",_opDlgPcp,{|| ( ExecTela(9, ;										// | Opcao
	opBtLib := TButton():New(alSize[4]-15,alSize[2]+025,"Informa Qtdes",_opDlgPcp,{|| ( ExecTela(9, ;										// | Opcao
	alItBx[olLBox:nAt,nlPosCFor],;				// | Cod. Fornec./Cli.
	alItBx[olLBox:nAt,nlPosLoja],;				// | Loja
	alItBx[olLBox:nAt,nlPosNum],;   			// | Num. Nota Fiscal
	alItBx[olLBox:nAt,nlPosSer]),;				// | Serie
	(olLBox:=AtuBrw(olLBox,alItBx,clLine,alCpos,alParam)),;
	(olLBox:Refresh()),(olLBox:bGoTop),;
	(Iif(!Empty(olLBox:aArray),AtuBtn(olLBox:aArray[olLBox:nAt,1]),)))};
	,040,014,,,,.T.  )

	//opBtLib2 := TButton():New(nlTl1+203,alSize[2]+047,"Libera Qtdes",_opDlgPcp,{|| (ExecTela(8, ;											// | Opcao
	opBtLib2 := TButton():New(alSize[4]-15,alSize[2]+067,"Libera Qtdes",_opDlgPcp,{|| ( ExecTela(8, ;										// | Opcao
	alItBx[olLBox:nAt,nlPosCFor],;				// | Cod. Fornec./Cli.
	alItBx[olLBox:nAt,nlPosLoja],;				// | Loja
	alItBx[olLBox:nAt,nlPosNum],;   			// | Num. Nota Fiscal
	alItBx[olLBox:nAt,nlPosSer]),;				// | Serie
	(olLBox:=AtuBrw(olLBox,alItBx,clLine,alCpos,alParam)),;
	(olLBox:Refresh()),(olLBox:bGoTop),;
	(Iif(!Empty(olLBox:aArray),AtuBtn(olLBox:aArray[olLBox:nAt,1]),)))};
	,040,014,,,,.T.  )

	// Selec. Pedido
	//opBtPed := TButton():New(nlTl1+203,alSize[2]+090,"Selec. Pedido",_opDlgPcp,{|| SelePed(alItBx[olLBox:nAt,nlPosCFor] ,;		// | Cod. Fornecedor
	opBtPed := TButton():New(alSize[4]-15,alSize[2]+110,"Selec. Pedido",_opDlgPcp,{|| SelePed(alItBx[olLBox:nAt,nlPosCFor] ,;		// | Cod. Fornecedor
	alItBx[olLBox:nAt,nlPosLoja] ,;		// | Loja
	alItBx[olLBox:nAt,nlPosNum ] ,;		// | Numero Doc.
	alItBx[olLBox:nAt,nlPosSer])} ;		// | Serie
	,041,014,,,,.T.  )

	// Visualizar
	//opBtVis := TButton():New(nlTl1+203,alSize[2]+135,"Visualizar",_opDlgPcp,{|| (ExecTela(	2,; 											// | Opcao
	opBtVis := TButton():New(alSize[4]-15,alSize[2]+180,"Visualizar",_opDlgPcp,{|| (ExecTela(	2,; 											// | Opcao
	alItBx[olLBox:nAt,nlPosCFor],;		// | Cod. Fornec./Cli.
	alItBx[olLBox:nAt,nlPosLoja],;	  	// | Loja
	alItBx[olLBox:nAt,nlPosNum],;	   	// | Num. Nota Fiscal
	alItBx[olLBox:nAt,nlPosSer])   ) };	// | Serie
	,035,014,,,,.T.  )

	// Gerar Pre Nota
	//opBtImp := TButton():New(nlTl1+203,alSize[2]+174,"Gerar Pre Nota",_opDlgPcp,{|| (ExecTela(3, ;										// | Opcao
	opBtImp := TButton():New(alSize[4]-15,alSize[2]+218,"Gerar Pre Nota",_opDlgPcp,{|| (ExecTela(3, ;										// | Opcao
	alItBx[olLBox:nAt,nlPosCFor],;	// | Cod. Fornec./Cli.
	alItBx[olLBox:nAt,nlPosLoja],;	// | Loja
	alItBx[olLBox:nAt,nlPosNum],;   	// | Num. Nota Fiscal
	alItBx[olLBox:nAt,nlPosSer]),;	// | Serie
	(olLBox:=AtuBrw(olLBox,alItBx,clLine,alCpos,alParam)),;
	(olLBox:Refresh()),(olLBox:bGoTop),;
	(Iif(!Empty(olLBox:aArray),AtuBtn(olLBox:aArray[olLBox:nAt,1]),)))};
	,040,014,,,,.T.  )
	// Legenda
	//olBtLeg := TButton():New(nlTl1+203,alSize[2]+219,"Legenda",_opDlgPcp, {|| &clLegenda } ,035,014,,,,.T.  )
	olBtLeg := TButton():New(alSize[4]-15,alSize[2]+270,"Legenda",_opDlgPcp, {|| &clLegenda } ,035,014,,,,.T.  )

	// Filtro
	//olBtFiltro := TButton():New(nlTl1+203,alSize[2]+259,"Filtro",_opDlgPcp, {|| FiltraBrw(olLBox,alItBx,clLine,alCpos,alParam, @clFilBrw) } ,035,014,,,,.T.  )
	olBtFiltro := TButton():New(alSize[4]-15,alSize[2]+308,"Filtro",_opDlgPcp, {|| FiltraBrw(olLBox,alItBx,clLine,alCpos,alParam, @clFilBrw) } ,035,014,,,,.T.  )

	// Importação manual
	//olBtImpM := TButton():New(nlTl1+203,alSize[2]+300,"Imp. Manual",_opDlgPcp, {|| ImpManual(),(olLBox:=AtuBrw(olLBox,alItBx,clLine,alCpos,alParam)) } ,035,014,,,,.T.  )
	olBtImpM := TButton():New(alSize[4]-15,alSize[2]+346,"Imp. Manual",_opDlgPcp, {|| ImpManual(),(olLBox:=AtuBrw(olLBox,alItBx,clLine,alCpos,alParam)) } ,035,014,,,,.T.  )
	//olBtImpM:Disable() 				// Para deixar sempre o botão desabilitado. Caso queira utilizar é só comentariar esta linha

	// Gerar relatório de divergências
	//@ (alSize[4]-15),(alSize[2]+400)	BUTTON "Rel. Diverg." SIZE 41,14 OF _opDlgPcp PIXEL ACTION (U_RelDiv())
	olBtRelD := TButton():New(alSize[4]-15,alSize[2]+400,"Rel. Diverg.",_opDlgPcp, {|| RelDiv(),(olLBox:=AtuBrw(olLBox,alItBx,clLine,alCpos,alParam)) } ,035,014,,,,.T.  )

	// Cosn. NFe
	//@ (nlTl1+203),(alSize[2]+339) 	BUTTON "Cons. NFE" SIZE 41,14 OF _opDlgPcp PIXEL ACTION (U_CoNFeChv(alItBx[olLBox:nAt,nlPosCHNF],cIdEnt))
	@ (alSize[4]-15),(alSize[2]+450)	BUTTON "Cons. NFE" SIZE 41,14 OF _opDlgPcp PIXEL ACTION (U_CoNFeChv(alItBx[olLBox:nAt,nlPosCHNF],cIdEnt))

	// Sair / Fechar
	//@ (nlTl1+203),(alSize[2]+384) 	BUTTON "Sair" SIZE 41,14 OF _opDlgPcp PIXEL ACTION Eval({|| DbSelectArea("SDS"), &cTCFilterEX.("",1), _opDlgPcp:END()})
	@ (alSize[4]-15),(alSize[2]+500)	BUTTON "Sair" SIZE 41,14 OF _opDlgPcp PIXEL ACTION Eval({|| DbSelectArea("SDS"), &cTCFilterEX.("",1), _opDlgPcp:END()})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TW Browse - Notas                                         				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//&cTCFilterEX.("",1)
	//olLBox := TwBrowse():New(nlTl1+10,nlTl2+5,nlTl3-5,nlTl4-715,,alHdCps,alHdSize,_opDlgPcp,,,,,{|| Iif(!Empty(olLBox:aArray),Eval(opBtVis:BACTION),) } ,,,,,,,.F.,,.T.,,.F.,,,)
	//olLBox := AtuBrw(olLBox,alItBx,clLine,alCpos,alParam)
	//olLBox:BChange:= Iif(!Empty(olLBox:aArray), {|| AtuBtn(olLBox:aArray[olLBox:nAt,1]) } , {|| olLBox:Refresh()  } )
	&cTCFilterEX.("",1)
	olLBox := TwBrowse():New(nlTl1,nlTl2,nlTl3-50,nlTl4,,alHdCps,alHdSize,_opDlgPcp,,,,,{|| Iif(!Empty(olLBox:aArray),Eval(opBtVis:BACTION),) } ,,,,,,,.F.,,.T.,,.F.,,,)
	olLBox := AtuBrw(olLBox,alItBx,clLine,alCpos,alParam)
	olLBox:BChange:= Iif(!Empty(olLBox:aArray), {|| AtuBtn(olLBox:aArray[olLBox:nAt,1]) } , {|| olLBox:Refresh()  } )

	ACTIVATE DIALOG _opDlgPcp CENTERED

Return NIL

// Função para gerar o relatório de divergências com seleção de parâmetros
Static Function RelDiv()
	if FWAlertNoYes('Gerar relatório de divergências?', 'Confirmação')
		Pergunte("GJF16", .T.) //Carrega as MV_PAR's exibindo a tela de parâmetros
		U_GJF16()
	endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ IMPMANUAL³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza a importacao manual do arquivo selecionado pelo    ³±±
±±³          ³ usuario utilizando a rotina automatica de importacao NF-e  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MontaBrw                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpManual()

	Local cPathR := cGetFile("*.xml","XML File",1,"C:\",.T.,GETF_LOCALHARD,.T.,.T.)
	Local cFile := cPathR

	If !Empty(cPathR)
		While At("\",cFile) > 0
			cFile := Substr(cFile,At("\",cFile)+1)
		End

		If !":\" $ cPathR //-- Arquivo do servidor
			Copy File &(cPathR) TO &(cStartPath +cFile)
		Else 					//-- Arquivo do client
			CpyT2S(cPathR,cStartPath)
		EndIf

		//-- Chama funcao de import
		MsAguarde({|| U_ReadXML(cFile,.T.)},"Aguarde","Importando dados do arquivo XML...",.F.)
	EndIf

Return( Nil )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FILTRABRW³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza botoes na mudanca de registro. Se o status for    ³±±
±±³          ³ P = Processada desabilita os botoes de selecionar pedido   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clStatus = Status do registro selecioado                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MontaBrw                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FiltraBrw(olLBox,alItBx,clLine,alCpos,alParam,clFilBrw )
	Local cTCFilterEX := "TCFilterEX"
	Local aArea			:= GetArea()
	clFilBrw 			:= BuildExpr("SDS",,clFilBrw)

	DbSelectArea("SDS")
	&cTCFilterEX.(clFilBrw,1)

	AtuBrw(olLBox,alItBx,clLine,alCpos,alParam)

	RestArea(aArea)

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ATUBNT   ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza botoes na mudanca de registro. Se o status for    ³±±
±±³          ³ P = Processada desabilita os botoes de selecionar pedido   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clStatus = Status do registro selecioado                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MontaBrw                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AtuBtn(clStatus)

	If (clStatus$"PQL")
		//opBtPed:Disable()
		opBtImp:Disable()
	Else
		opBtPed:Enable()
		opBtImp:Enable()
		//opBtLib:Disable()
		//opBtLib2:Disable()
	EndIf

	if !_lBtn
		opBtImp:Disable()
		opBtVis:Disable()
		opBtPed:Disable()
		opBtLib2:Disable()
	endif

	if !_lBtn2
		opBtLib:Disable()
	endif

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ATUBRW   ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza a tela apos gerar pre nota                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ olLBox  = Objeto do TwBrowse (ListBOx)                     ³±±
±±³          ³ alItBx  = Array contendo os itens do ListBox               ³±±
±±³          ³ clLine  = String do BLoco de Codigo bLine                  ³±±
±±³          ³ alCpos  = Campos exibidos no ListBox                       ³±±
±±³          ³ alParam = Array com informacoes do filtro                  ³±±
±±³          ³           [ 1 ] - Parametro escolhido                      ³±±
±±³          ³           [ 2 ] - String para sua representacao Ex.: "T"   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ olLBox = ListBox atualizado                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FiltraBrw, MontaBrw                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AtuBrw(olLBox,alItBx,clLine,alCpos,alParam)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega o array com as informações dos registros          				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	alItBx:=CarItens(alCpos, alParam)
	olLBox:SetArray(alItBx)
	olLBox:bLine := Iif(!Empty(alItBx),&clLine, {|| Array(Len(alCpos))} )

	If Empty(olLBox:aArray)
		//opBtPed:Disable()
		opBtVis:Disable()
		opBtImp:Disable()
		//opBtLib:Disable()
		//opBtLib2:Disable()
	EndIf

Return olLBox


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SELEPED  ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta tela para selecao do pedido de compra                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clCodFor  = Cod. Fornec./Cli.                              ³±±
±±³          ³ clLoja    = Loja                                           ³±±
±±³          ³ clNota    = Num. Nota                                      ³±±
±±³          ³ clSerie   = Serie da Nota                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MontaBrw                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SelePed(clCodFor,clLoja,clNota,clSerie)
	Local nlCont      := 0
	Local clDescProd  := ""
	Local clTipo      := ""
	Local alNome      := {}
	Local alRetRef    := {}
	Local olBtSch     := NIL
	Local olBDsfz     := NIL
	Local olFont      := TFont ():New(,,-11,.T.,.T.,5,.T.,5,.F.,.F.)
	Local alSize    	:= MsAdvSize()
	Local nlTl1     	:= alSize[1]
	Local nlTl2    	:= alSize[2]
	Local nlTl3    	:= alSize[1]+300
	Local nlTl4     	:= alSize[2]+520
	Local alItens     := {}
	Local alCabec     := {"DT_ITEM","DT_COD","DT_PRODFOR","B1_DESC"}
	Local alHdIt      := {}
	Local alTamHd     := {}
	Private _opBoxIt  := NIL
	Private _opSPeDlg	:= NIL

	//202304
	/* dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For nlCont	:= 1 to Len(alCabec)
		If MsSeek(alCabec[nlCont])
			AADD(alHdIt,AllTrim(X3Titulo()))
			AADD(alTamHd,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()) )
		EndIf
	Next */

	//202304 - ajuste para usar a função FWSX3Util para buscar informações do SX3
	For nlCont	:= 1 to Len(alCabec)
		_sQuery :=  "SELECT X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_PICTURE, X3_TITULO"
		_sQuery +=  " FROM " + retSqlTab("SX3")
		_sQuery +=  " WHERE " + retSqlDel("SX3")
		_sQuery +=  " AND X3_CAMPO = '" + alltrim(alCabec[nlCont])  + "'"

		_CSx3 := U_Qry2Array(_sQuery)
		if len(_CSx3) > 0
			AADD(alHdIt,AllTrim(_CSx3[1,5]))
			AADD(alTamHd,CalcFieldSize(_CSx3[1,1],_CSx3[1,2],_CSx3[1,3], _CSx3[1,4], _CSx3[1,5]) )
		endif 
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona para buscar nome do Fornecedor / Cliente        				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SDS")
	SDS->(dbSetOrder(1))
	SDS->(dbSeek(FWxFilial("SDS")+clNota+clSerie+clCodFor+clLoja))
	If SDS->DS_TIPO == 'N'
		dbSelectArea("SA2")
		dbSetOrder(1)
		aAdd(alNome,{"SA2","A2_NOME","Fornecedor"})
		clTipo:="N"
	ElseIf SDS->DS_TIPO == 'D'
		dbSelectArea("SA1")
		dbSetOrder(1)
		aAdd(alNome,{"SA1","A1_NOME","Cliente"})
		clTipo:="D"
	Else
		Aviso("Atenção","Tipo de Nota Fiscal não permitida",{"Ok"})
		Return
	EndIf
	&(alNome[1,1])->(dbGoTop())

	DEFINE MSDIALOG _opSPeDlg TITLE "Selecionar Pedido" From nlTl1,nlTl2 to nlTl3,nlTl4+100 PIXEL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Box                                                       				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@(nlTl1+10),nlTl2 to (nlTl1+35),(nlTl2+237) PIXEL OF _opSPeDlg
	@(nlTl1+14),(nlTl2+005) Say "Nota Fiscal:"+clNota Font olFont Pixel Of _opSPeDlg
	@(nlTl1+14),(nlTl2+180) Say "Serie :"+clSerie Font olFont Pixel Of _opSPeDlg
	@(nlTl1+23),(nlTl2+005) Say alNome[1,3]+clCodFor+" - "+ Posicione(alNome[1,1],1,(FWxFilial(alNome[1,1])+clCodFor+clLoja),alNome[1,2])      Font olFont Pixel Of _opSPeDlg

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega os Itens                                          				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SDT")
	SDT->(dbSetOrder(2))
	If SDT->(dbSeek(FWxFilial("SDT")+PadR(clCodFor,TamSx3("DT_FORNEC")[1])+PadR(clLoja,TamSx3("DT_LOJA")[1])+PadR(clNota,TamSx3("DT_DOC")[1])+PadR(clSerie,TamSx3("DT_SERIE")[1]) ))
		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		While SDT->(!EOF()) .AND. (SDT->DT_FORNEC==clCodFor) .AND. (SDT->DT_LOJA==clLoja) .AND. (SDT->DT_DOC==clNota) .AND. (SDT->DT_SERIE==clSerie)
			clDescProd:= Iif(!Empty(SDT->DT_COD),Posicione("SB1",1,(FWxFilial("SB1")+PadR(SDT->DT_COD,TamSX3("B1_COD")[1])),"B1_DESC"),SDT->DT_DESCFOR)
			aAdd(alItens,{SDT->DT_ITEM , SDT->DT_COD, SDT->DT_PRODFOR ,clDescProd })
			clDescProd:=""
			SDT->(dbSkip())
		EndDo
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TW Browse - Itens da Nota                                 				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_opBoxIt := TwBrowse():New(nlTl1+40,nlTl2,nlTl4-295,nlTl3-217,,alHdIt,alTamHd,_opSPeDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	_opBoxIt:SetArray(alItens)
	_opBoxIt:bLine := {|| {alItens[_opBoxIt:nAt,1],alItens[_opBoxIt:nAt,2],alItens[_opBoxIt:nAt,3], alItens[_opBoxIt:nAt,4]} }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botões                                                    				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	olBtSch  := TButton():New(nlTl1+132,nlTl2,"Selecionar Pedidos",_opSPeDlg,{||  MsgRun("Aguarde","Selecionando Registros..." ,{|| ProcPCxNFe(clCodFor,clLoja,clNota,clSerie,alItens,alItens[_opBoxIt:nAt,1], SDS->DS_TIPO) })    } ,055,012,,,,.T.  )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botao: "Desfazer amarracao do produto" ; Permite ao usuario refazer a amarracao Prod. X Prod. Fornec.  ³
	//³ Caso usuario escolha "SIM" na pergunta de confirmacao, sao executados os 4 passoas descritos abaixo    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	olBDsfz  := TButton():New(nlTl1+132,nlTl2+065,"Desfazer amarração do produto",_opSPeDlg, {|| Iif(Aviso("Deseja desfazer a amarração Prod x Prod.Fornec.?",("Ao clicar em <SIM> "+CRLF+"a seleção do pedido será excluída("+ alItens[_opBoxIt:nAt,1]+")"),{"Sim","Nâo"})==1 ,;  // Condicao
	((DelSDV((clCodFor+clLoja+clNota+clSerie),alItens[_opBoxIt:nAt,2])  						       ),;  // -----------| - Deleta registros tabela amarracao pedido de compra - SDV
	( GPrdxPrdF(clCodFor,clLoja,clNota,clSerie,alItens[_opBoxIt:nAt,3],"",SDS->DS_TIPO,alItens[_opBoxIt:nAt,1]) ),;  				//    Opcao   | - Altera / Limpa campo DT_COD
	( alRetRef:=RPrdxPrdF(clCodFor,clLoja,clNota,clSerie,alItens[_opBoxIt:nAt,3],,SDS->DS_TIPO,alItens[_opBoxIt:nAt,1]) ),;  	//     SIM    | - Atualiza SDT com nova amarracao do usuario
	((alItens[_opBoxIt:nAt,2]:=alRetRef[1]),(alItens[_opBoxIt:nAt,4]:=alRetRef[2]) 		)   ),;  // -----------| - Atualiza browse
	(	/* Opcao caso usuario escolha NAO. Nada faz / Nao usado */  									   )  )}; 	// Opcao NAO
	,095,012,,,,.T.  )

	DEFINE SBUTTON FROM nlTl1+134,nlTl2+212 TYPE 1 ACTION(_opSPeDlg:End()) ENABLE Of _opSPeDlg
	_opSPeDlg:Activate(,,,.T.,,,)

	SDT->(dbCloseArea())
	SB1->(dbCloseArea())
	&(alNome[1,1])->(dbCloseArea())

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DELSDV   ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Deleta os registros na tabela de relatorio de pedidos qdo  ³±±
±±³          ³ a amarracao do produto e desfeita                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clChave  = Fornecedor + Loja + Nota + Serie                ³±±
±±³          ³ clProd   = Codigo do produto                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SelePed                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DelSDV(clChave,clProd)

	Local alArea := GetArea()

	dbSelectArea("SDV")
	SDV->(dbSetOrder(1))
	SDV->(dbGoTop())
	If SDV->(dbSeek(FWxFilial("SDV")+clChave))
		While SDV->(!EOF()) .AND. (clChave==(SDV->DV_FORNEC+SDV->DV_LOJA+SDV->DV_DOC+SDV->DV_SERIE))
			If (clProd==SDV->DV_PROD)

				// Limpa Pedido e Item do Pedido na tabela SDT
				SDT->(dbOrderNickName("_SDTPCITEM"))
				If SDT->(dbSeek(FWxFilial("SDT")+SDV->DV_FORNEC+SDV->DV_LOJA+SDV->DV_DOC+SDV->DV_SERIE+SDV->DV_PROD+Str(SDV->DV_QUANT,18,7)+SDV->DV_NUMPED+SDV->DV_ITEMPC))
					If RecLock("SDT",.F.)
						Replace DT_PEDIDO With ""
						Replace DT_ITEMPC With ""
						Replace DT_CC     With ""
						Replace DT_OBS    With ""
						SDT->(MsUnLock())
					Endif
				Endif

				If RecLock("SDV",.F.)
					SDV->(DbDelete())
					MsUnlock("SDV")
				EndIf
			EndIf
			SDV->(dbSkip())
		EndDo
	EndIf
	SDV->(dbCloseArea())

	RestArea(alArea)

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RPRDxPRDF³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Refaz a amarracao de produto x produto fornecedor          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clCodFor  = Cod. Fornec./Cli.                              ³±±
±±³          ³ clLoja    = Loja                                           ³±±
±±³          ³ clNota    = Num. Nota                                      ³±±
±±³          ³ clSerie   = Serie da Nota                                  ³±±
±±³          ³ clProdFor = cod. produto identificacao do forn / cliente   ³±±
±±³          ³ clPar     = NIL                                            ³±±
±±³          ³ cTipo     = Tipo da nota - Entrada ou devolucao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ alRet  = [1] - Cod. produto  / [2] - Descricao do produto  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SelePed                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RPrdxPrdF(clCodFor,clLoja,clNota,clSerie,clProdFor,clPar,cTipo,cItem)

	Local llRetCons := .F.
	Local alRet     := {"",""}
	Local alArea    := GetArea()

	If (llRetCons:=ConPad1(,,,"SB1",,,.F.)) // Consulta Padrao
		alRet[1] := SB1->B1_COD
		alRet[2] := SB1->B1_DESC
		GPrdxPrdF(clCodFor,clLoja,clNota,clSerie,clProdFor,SB1->B1_COD,cTipo,cItem)
	Else
		alRet[2] := Posicione("SDT",2,(FWxFilial("SDT")+clCodFor+clLoja+clNota+clSerie+clProdFor),"DT_DESCFOR")
	EndIf

	RestArea(alArea)

Return alRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PROCPCxNFE³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Procura possiveis pedido de compra relacionado a NF        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clCodFor  = Cod. Fornec./Cli.                              ³±±
±±³          ³ clLoja    = Loja                                           ³±±
±±³          ³ clNota    = Num. Nota                                      ³±±
±±³          ³ clSerie   = Serie da Nota                                  ³±±
±±³          ³ alItens   = array contendo os itens da nota fiscal         ³±±
±±³          ³ clItem    = Item selecionado                               ³±±
±±³          ³ cTipo     = Tipo da nota - Entrada ou devolucao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ alItens  = array com os itens atualizados                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SelePed                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ProcPCxNFe(clCodFor,clLoja,clNota,clSerie,alItens,clItem,cTipo)

	Local nlPos   	   := Ascan(alItens,{|x|X[1]==clItem})
	Local alItem1 	   := {}
	Local llretCons   := .F.
	Local nlVarVal    := 0.01 // Variacao de valores para busca do pedido
	Local clArqSQL    := GetNextAlias()
	Local clQuery 	   := ""
	Local cCodProdEmp := ""
	Local lEmpGrupo   := .F. // Empresa do Grupo .T. = Sim / .F. = Não

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se Fornecedor faz parte do cadastro de empresas no Sigamat   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SA2->(DbSetOrder(1))
	If SA2->(DbSeek(FWxFilial("SA2")+clCodFor+clLoja))
		If Len(PesqCGC(SA2->A2_CGC))!=0
			lEmpGrupo := .T.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso nao tenha codigo do produto preenchido, possibilita que o usuario³
	//³ defina qual o produto corresponde ao codigo produto do fornecedor     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SDT")
	SDT->(dbSetOrder(2))
	If SDT->(dbSeek(FWxFilial("SDT")+clCodFor+clLoja+clNota+clSerie))
		While SDT->(!EOF()) .AND. (SDT->DT_FORNEC==clCodFor)
			If !Empty(SDT->DT_PEDIDO)
				SDT->(dbSkip())
				Loop
			Endif
			If AllTrim(SDT->DT_PRODFOR) == AllTrim(alItens[nlPos,3])
				If lEmpGrupo // Se for Empresa do Grupo utiliza proprio codigo XML
					cCodProdEmp := SDT->DT_PRODFOR
				Else
					cCodProdEmp := SDT->DT_COD
				EndIf
				If Empty(cCodProdEmp)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Procura rlacionamento do produto na tabela SA7 / SA5                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cCodProdEmp := PrdxForCli(clCodFor, clLoja, SDT->DT_PRODFOR, cTipo)
					If Empty(cCodProdEmp)
						If MsgYesNo("O produto da Nota está sem amarração no sistema, código "+Space(1)+AllTrim(SDT->DT_PRODFOR)+"."+CRLF+"Deseja selecionar um produto?"  )
							If (llRetCons:=ConPad1(,,,"SB1",,,.F.))
								cCodProdEmp := SB1->B1_COD
								GPrdxPrdF(clCodFor, clLoja, clNota, clSerie, SDT->DT_PRODFOR, cCodProdEmp, cTipo, SDT->DT_ITEM)

								_opBoxIt:aArray[_opBoxIt:nAt,2] := cCodProdEmp
								_opBoxIt:aArray[_opBoxIt:nAt,4] := SB1->B1_DESC
							EndIf
						EndIf
					Else
						GPrdxPrdF(clCodFor, clLoja, clNota, clSerie, SDT->DT_PRODFOR, cCodProdEmp, cTipo, SDT->DT_ITEM)

						_opBoxIt:aArray[_opBoxIt:nAt,2] := cCodProdEmp
						_opBoxIt:aArray[_opBoxIt:nAt,4] := SB1->B1_DESC
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carrega array que conterá as informações para a query                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(alItem1,SDT->DT_COD)       // COD. PRODUTO
				aAdd(alItem1,SDT->DT_PRODFOR)   // COD. PROD. FORNECEDOR
				aAdd(alItem1,SDT->DT_QUANT)     // QUANT. ITEM NA NF
				aAdd(alItem1,SDT->DT_VUNIT)     // VALOR UNITARIO
				Exit
			EndIf
			SDT->(dbSkip())
		EndDo
	EndIf

	If !Empty(cCodProdEmp)
		#IFDEF TOP
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a Query                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Where / Condicao
		clWhere := ""
		clWhere += " WHERE C7_FILENT = '" + FWxFilial("SC7") + "' "
		clWhere += "   AND SC7.D_E_L_E_T_ <> '*'
		clWhere += "   AND C7_FORNECE = '" + clCodFor + "' "
		clWhere += "   AND C7_LOJA = '" + clLoja + "' "
		clWhere += "   AND C7_PRODUTO = '" + alItem1[1] + "' "
		clWhere += "   AND (C7_QUANT - C7_QUJE - C7_QTDACLA) > 0 "
		clWhere += "   AND C7_ENCER = ' '  "
		clWhere += "   AND C7_RESIDUO = ' '  "
		clWhere += "   AND C7_TPOP <> 'P' "
		clWhere += "   AND (C7_CONAPRO = 'L' OR C7_CONAPRO = ' ') "

		// Query
		clQuery := ""
		clQuery += " SELECT "
		clQuery += " ( "
		clQuery += "	 SELECT COUNT(*) "
		clQuery += "	 FROM " + RetSqlName("SC7") + " SC7 "
		clQuery += clWhere
		clQuery += " ) "
		clQuery += " AS CONT "
		clQuery += "  , C7_NUM "
		clQuery += " 	, C7_ITEM "
		clQuery += " 	, C7_QUANT "
		clQuery += " 	, C7_PRECO "
		clQuery += " 	, C7_TOTAL "
		clQuery += " 	, C7_QUJE "
		clQuery += " 	, C7_EMISSAO "
		clQuery += " FROM " + RetSqlName("SC7") + " SC7 "
		clQuery += clWhere

		dbUseArea(.T., "TOPCONN", TCGenQry(,,clQuery),clArqSQL, .T., .T.)

		dbSelectArea(clArqSQL)
		&(clArqSQL)->(dbGoTop())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se encontrou pedidos                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If &(clArqSQL)->(!EOF())
			MarkBrwPC(clArqSQL,alItem1,clCodFor,clLoja,clNota,clSerie)
		Else
			//Aviso("Atenção",("Item não encontrado "+STRZero(Val(clItem),TamSX3("DT_ITEM")[1])+" na Nota "+clNota),{"Ok"})
			cMsg := '<font color="#FF0000" size="5">Pedido BLOQUEADO ou Item sem Saldo</font>'
			cMsg += '<br>'
			cMsg += '<br>'
			cMsg += '<font color="#FF0000" size="5">Pré-Nota ainda NÃO deve ser gerada</font>'
			FWAlertWarning(cMsg, "Item " + StrZero(Val(clItem),TamSX3("DT_ITEM")[1]) + " Não Liberado p/ Seleção de PC")
		EndIf

		&(clArqSQL)->(dbCloseArea())
		#ENDIF
	EndIf

Return alItens


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MARKBRWPC³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Responsavel por criar MsSelect/MarkBrowse para que o       ³±±
±±³          ³ usuario escolha os pedidos de compra referente aos itens   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clArqSQL  = String com o nome da Tabela SQL                ³±±
±±³          ³ vlItem1   = Dados do item da nota fiscal                   ³±±
±±³          ³          [1] - Cod. Produto                                ³±±
±±³          ³          [2] - Cod. Produto FOrnecedor                     ³±±
±±³          ³          [3] - Quant. do item na Nf                        ³±±
±±³          ³          [4] - Valor unitario                              ³±±
±±³          ³ clCodFor  = Cod. Fornec./Cli.                              ³±±
±±³          ³ clLoja    = Loja                                           ³±±
±±³          ³ clNota    = Num. Nota                                      ³±±
±±³          ³ clSerie   = Serie da Nota                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ alItens  = array com os itens atualizados                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ProcPCxNFe                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MarkBrwPC(clArqSQL,alItem1,clCodFor,clLoja,clNota,clSerie)
	Local _aArqTrb      := {} // ProcData 04/2023
	Local clQZ4         := 0
	Local olFont        := TFont ():New(,,-11,.T.,.T.,5,.T.,5,.F.,.F.)
	Local alSize    	  := MsAdvSize()
	Local nlTl1     	  := alSize[1]
	Local nlTl2    	  := alSize[2]
	Local nlTl3    	  := alSize[1]+300
	Local nlTl4     	  := alSize[2]+520
	Local clPed         := ""
	Local clItmPC       := ""
	Local alEstru       := {}
	Local llInvert      := .F.
	Local alCampos      := {}
	Local clTabTmp      := ""
	Local clTMPMark     := ""
	Local clTMPQtd      := 0
	Local alTamSDV      := {TAMSX3("DV_FORNEC")[1],TAMSX3("DV_LOJA")[1],TAMSX3("DV_DOC")[1],TAMSX3("DV_SERIE")[1],TAMSX3("DV_PROD")[1],TAMSX3("DV_NUMPED")[1],TAMSX3("DV_ITEMPC")[1]}
	Local olSayQtd      := NIL
	Local olMsSel01     := NIL
	Local clMarca       := GetMark() // Essa variável não pode ter outro conteudo
	Private opDlgMPed   := NIL

	// Foi necessario criar essas variaveis para que fosse possivel usar a funcao padrao do sistema A120Pedido()
	Private INCLUI      := .F.
	Private ALTERA      := .F.
	Private nTipoPed    := 1
	Private cCadastro   := "Seleção dos Pedidos de Compra"
	Private l120Auto    := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se alguma nota já preenche quantidade desse produto          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbselectArea("SDV")
	SDV->(dbSetOrder(1))
	SDV->(dbGoTop())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estrutura da tabela temporária                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	alEstru := {}
	aadd(alEstru,{"MMARK",     "C",  LEn(clMarca),           0                     })
	aadd(alEstru,{"PED ",      "C",  TamSx3("C7_NUM")[1],    0                     })
	aadd(alEstru,{"ITEM",      "C",  TamSx3("C7_ITEM")[1],   0                     })
	aadd(alEstru,{"DDATA",     "D",  8                   ,   0                     })
	aadd(alEstru,{"QTDDISP" ,  "N",  TamSx3("C7_QUANT")[1],  TamSx3("C7_QUANT")[2] })
	aadd(alEstru,{"QTDREF" ,   "N",  TamSx3("C7_QUANT")[1],  TamSx3("C7_QUANT")[2] })

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campos para MsSelect                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	alCampos := {}
	aAdd(alCampos,{"MMARK"    , , ""   	      ,""                      	})
	aAdd(alCampos,{"PED"      , , "Pedido"    ,PesqPict("SC7","C7_NUM")  	})
	aAdd(alCampos,{"ITEM"     , , "Item"      ,PesqPict("SC7","C7_ITEM")   })
	aAdd(alCampos,{"DDATA"    , , "Data"      ,                            })
	aAdd(alCampos,{"QTDDISP"  , , "Qtd.Disp." ,PesqPict("SC7","C7_QUANT")  })
	aAdd(alCampos,{"QTDREF"   , , "Qtd.Infor" ,PesqPict("SC7","C7_QUANT")  })

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria e seleciona a tabela temporária                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//clTabTmp := CriaTrab(alEstru,.T.)
	//dbUseArea(.T.,,clTabTmp,"TMP",.F.,.F.)
	//dbSelectArea("TMP")
	
	// ProcData 04/2023 - Chamada para criação do arquivo de trabalho
	clTabTmp := "TMP"
	U_ArqTrb("Cria", clTabTmp, alEstru, {}, @_aArqTrb)	
	dbSelectArea("TMP")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Transfere os dados para a tabela temporária                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(clArqSql)
	&(clArqSql+"->(dbGoTop())")
	While &(clArqSql+"->(!EOF())")
		clPed 	 := &(clArqSql+"->C7_NUM")
		clItmPc 	 := &(clArqSql+"->C7_ITEM")
		clTMPMark := ""
		clTMPQtd  := 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica registro na tabela SDV e traz preenchida caso encontre       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbselectArea("SDV")
		SDV->(dbSetOrder(1))
		SDV->(dbGoTop())
		If SDV->(dbSeek(FWxFilial("SDV")+PadR(clCodFor,alTamSDV[1])+PadR(clLoja,alTamSDV[2])+PadR(clNota,alTamSDV[3])+PadR(clSerie,alTamSDV[4])+PadR(alItem1[1],alTamSDV[5])+PadR(clPed,alTamSDV[6])+PadR(clItmPc,alTamSDV[7])))
			clTMPMark := clMarca
			clTMPQtd  := SDV->DV_QUANT
		EndIf

		dbselectArea("TMP")
		If RecLock("TMP",.T.)
			TMP->PED     := clPed
			TMP->ITEM    := clItmPc
			TMP->DDATA   := StoD(&(clArqSql+"->C7_EMISSAO"))
			TMP->QTDDISP := (&(clArqSql+"->C7_QUANT") - (&(clArqSql+"->C7_QUJE")+ clQZ4))
			TMP->MMARK   := clTMPMark
			TMP->QTDREF  := clTMPQtd
			TMP->(MsUnLock())
		EndIf

		dbSelectArea(clArqSql)
		&(clArqSql)->(dbSkip())
	EndDo

	TMP->(dbGoTop())

	DEFINE MSDIALOG opDlgMPed TITLE "Seleção dos Pedidos de Compra" From nlTl1,nlTl2 to nlTl3,nlTl4 PIXEL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cabeçalho da Tela                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@(nlTl1+10),nlTl2 to (nlTl1+35),(nlTl2+237) PIXEL OF opDlgMPed
	@(nlTl1+14),(nlTl2+005) Say AllTrim(alItem1[2]) + " / " + AllTrim(alItem1[1]) + " - " + Posicione("SB1",1,(FWxFilial("SB1")+PadR(alItem1[1],TamSX3("B1_COD")[1])),"B1_DESC")   Font olFont Pixel Of opDlgMPed
	@(nlTl1+23),(nlTl2+005) Say "Item "   + AllTrim(STR(alItem1[3]))      Font olFont Pixel Of opDlgMPed

	olSayQtd := tSay():New((nlTl1+23),(nlTl2+130),{|| "Qtd. Nota Fiscal " + AllTrim(STR(DigQtdeIt(0,alItem1[3],"C")[1])) },opDlgMPed,,olFont,,,,.T.,,,100,20)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ MarkBrowse / MsSelect                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	olMsSel01 :=  MsSelect():New('TMP','MMARK',"",alCampos,@llInvert,@clMarca,{(nlTl1+40),(nlTl2),(nlTl3-175),(nlTl4-283)},,opDlgMPed)
	olMsSel01:oBrowse:lColDrag    := .T.
	olMsSel01:bMark := {|| (MarcaReg(clMarca,alItem1[3]), olMsSel01:oBrowse:Refresh(), opDlgMPed:Refresh(), olSayQtd:cCaption:= "Qtd. Sem Pedido de Compra" + AllTrim(STR(DigQtdeIt(0,alItem1[3],"C")[1])) )  }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botões                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	obTVisPe := TButton():New(nlTl1+132,nlTl2,"Visualizar Pedido",opDlgMPed,{|| MsgRun("Pedido "+Space(1)+TMP->PED+"Sendo Localizado","Aguarde...", {|| A120Pedido("SC7",PosSC7( TMP->PED ),2) })   } ,055,012,,,,.T.  )
	DEFINE SBUTTON FROM nlTl1+134,nlTl2+178 TYPE 1 ACTION(eVal( {|| (MarkBrwOk(clCodFor,clLoja,clNota,clSerie,alItem1[1],alTamSDV) , opDlgMPed:End())  } )) ENABLE Of opDlgMPed
	DEFINE SBUTTON FROM nlTl1+134,nlTl2+212 TYPE 2 ACTION(opDlgMPed:End()) ENABLE Of opDlgMPed

	ACTIVATE DIALOG opDlgMPed CENTERED

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha e deleta aquivo da tabela temporária                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TMP->(dbCloseArea())
	If File( AllTrim(clTabTmp)+GetDBExtension())
		Ferase(AllTrim(clTabTmp)+GetDBExtension())
	EndIf

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MARKBRWOK³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executada no botao "OK" do MarkBrowse de selecao de pedido ³±±
±±³          ³ de compra deleta e/ou grava os registros na tabela         ³±±
±±³          ³ Ped. Compra X NFE (SDV)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clCodFor   = Cod. Fornec./Cli.                             ³±±
±±³          ³ clLoja     = Loja                                          ³±±
±±³          ³ clNota     = Num. Nota                                     ³±±
±±³          ³ clSerie    = Serie da Nota                                 ³±±
±±³          ³ clCodProd  = Codigo do produto                             ³±±
±±³          ³ alTamSDV   = Array com tamanhos dos campos usados no dbSeek³±±
±±³          ³              [1] - Tam. Campo DV_FORNEC                    ³±±
±±³          ³              [2] - Tam. Campo DV_LOJA                      ³±±
±±³          ³              [3] - Tam. Campo DV_DOC                       ³±±
±±³          ³              [4] - Tam. Campo DV_SERIE                     ³±±
±±³          ³              [5] - Tam. Campo DV_PROD                      ³±±
±±³          ³              [6] - Tam. Campo DV_NUMPED                    ³±±
±±³          ³              [7] - Tam. Campo DV_ITEMPC                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MarkBrwPc                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MarkBrwOk(clCodFor,clLoja,clNota,clSerie,clCodProd,alTamSDV)

	Local clNumPed := ""
	Local clItemPc := ""

	dbSelectArea("SDV")
	SDV->(dbSetOrder(1))

	TMP->(dbGoTop())
	While TMP->(!EOF())

		SDV->(dbGoTop())
		clNumPed  := PadR(TMP->PED,TamSX3("C7_NUM")[1])
		clItemPC  := PadR(TMP->ITEM,TamSX3("C7_ITEM")[1])
		dbSelectArea("SDV")
		SDV->(dbSetOrder(1))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui o registro da tabela                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If dbSeek(FWxFilial("SDV")+PadR(clCodFor,alTamSDV[1])+PadR(clLoja,alTamSDV[2])+PadR(clNota,alTamSDV[3])+PadR(clSerie,alTamSDV[4])+PadR(clCodProd,alTamSDV[5])+PadR(clNumPed,alTamSDV[6])+PadR(clItemPC,alTamSDV[7])+Str(TMP->QTDREF,18,7))
			If RecLock("SDV",.F.)
				SDV->(DbDelete())
				SDV->(MsUnlock())
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava na SDV se estiver marcado                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(TMP->MMARK)
			Begin Transaction
				If RecLock("SDV",.T.)
					SDV->DV_FILIAL := FWxFilial("SDV")
					SDV->DV_DOC    := clNota
					SDV->DV_SERIE  := clSerie
					SDV->DV_FORNEC := clCodFor
					SDV->DV_LOJA   := clLoja
					SDV->DV_PROD  	:= clCodProd
					SDV->DV_NUMPED := TMP->PED
					SDV->DV_ITEMPC	:= TMP->ITEM
					SDV->DV_QUANT	:= TMP->QTDREF
					dbCommit()
					SDV->(MsUnlock())

					// Atualiza Pedido de Compra na tabela SDT
					dbSelectArea("SDT")
					SDT->(dbOrderNickName("_SDTQUANT"))
					If SDT->(dbSeek(FWxFilial("SDT")+clCodFor+clLoja+clNota+clSerie+clCodProd+Str(TMP->QTDREF,18,7)))
						while SDT->(!eof()) .and.;
						FWxFilial("SDT")+clCodFor+clLoja+clNota+clSerie+clCodProd+Str(TMP->QTDREF,18,7) = ;
						SDT->(DT_FILIAL+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE+DT_COD+Str(TMP->QTDREF,18,7))

							if (TMP->PED = SDT->DT_PEDIDO) .and. (TMP->ITEM = SDT->DT_ITEMPC)
								exit
								//TMP->(DbSkip())
								//loop
							else

								if (empty(SDT->DT_PEDIDO) .and. empty(SDT->DT_ITEMPC))

									_cCC  := GetAdvFval('SC7','C7_CC',FWxfilial('SC7')+TMP->(PED+ITEM),1)
									_cObs := GetAdvFval('SC7','C7_OBS',FWxfilial('SC7')+TMP->(PED+ITEM),1)

									If RecLock("SDT",.F.)
										Replace DT_PEDIDO With TMP->PED
										Replace DT_ITEMPC With TMP->ITEM
										Replace DT_CC     With _cCC
										Replace DT_OBS    With _cObs
										SDT->(MsUnLock())
									Endif

									exit

								else
									SDT->(DbSkip())
									loop
								endif
							endif

							SDT->(DbSkip())
						enddo
					Endif

				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Libera para Informar Qtdes                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SDS")
				dbSetOrder(1)
				SDS->(dbGoTop())
				If dbSeek(FWxFilial("SDS")+clNota+clSerie+clCodFor+clLoja)
					If RecLock("SDS",.F.)
						Replace DS_STATUS With 'Q' 		// " " = LIBERADO PARA INFORMAR QTDES
						SDS->(MsUnLock())
						Aviso("Atenção", "Documento Liberado para Informar Qtdes com Sucesso!" ,{"Ok"})
					EndIf
				EndIf

			End Transaction
		EndIf
		dbSelectArea("TMP")
		TMP->(dbSkip())
	EndDo

	SDV->(dbCloseArea())

Return NIL


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MARCAREG ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executada quando o registro e marcado                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clMarca   = String retornada do GETMark()                  ³±±
±±³          ³ nlQtdTot  = Qtd. total / maxima permitida                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MarkBrwPc                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MarcaReg(clMarca,nlQtdTot)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Preenche com valor digitado pelo usuário                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If RecLock("TMP",.F.)
		REPLACE TMP->QTDREF with DigValIt(TMP->QTDREF,TMP->QTDDISP,nlQtdTot)
		MsUnLock()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o valor é zero e caso sim desmarca o registro             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(TMP->QTDREF)
		If RecLock("TMP",.F.)
			REPLACE TMP->MMARK with ""
			MsUnLock()
		EndIF
	Else
		If RecLock("TMP",.F.)
			REPLACE TMP->MMARK with clMarca
			MsUnLock()
		EndIF
	EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DIGVALIT ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao cria telinha para que o usuario digite numa get o   ³±±
±±³          ³ valor (unidades) do item da nota fiscal correspondente ao  ³±±
±±³          ³ pedido selecionado                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nlValGet   = quantidade ja preenchido                      ³±±
±±³          ³ nlValDisp  = quantidade maxima disponivel                  ³±±
±±³          ³ nlQtdTot   = quantidade total                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Se variavel llOk == .T., retorna valor digitado 'nlValGet' ³±±
±±³          ³ senao retorna  nlValAnt = valor anterior                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MarcaReg                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DigValIt(nlValGet,nlValDisp,nlQtdTot)

	Local nlValAnt  	:= nlValGet
	Local alSize   	:= MsAdvSize()
	Local llOk     	:= .F.
	Local olGetVal  	:= Nil
	Private _opdlgGet := Nil

	DEFINE MSDIALOG _opdlgGet TITLE "Quantidade" From alSize[1],alSize[2] to (alSize[1]+080),(alSize[2]+195) PIXEL

	olGetVal :=TGet():New((alSize[1]+10),(alSize[2]+15),{|u| if(PCount()>0,nlValGet:=u,nlValGet)}, _opdlgGet ,50,10,PesqPict("SC7","C7_QUANT") , {|| ValorNFxPC(nlValGet, nlValDisp, nlQtdTot ) },,,,,,.T.,,,,,,,.F.,,,"nlValGet")
	DEFINE SBUTTON FROM (alSize[1]+28),(alSize[2]+57) TYPE 1 ACTION(eVal( {|| ( (llOk:=.T.),_opdlgGet:End())  } )) ENABLE Of _opdlgGet

	ACTIVATE DIALOG _opdlgGet CENTERED

Return ( Iif(llOk,nlValGet,nlValAnt) )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VALORNFxPC³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida valor informado do item da nota fiscal correspondent³±±
±±³          ³ ao pedido selecionado                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nlValGet   = quantidade ja preenchido                      ³±±
±±³          ³ nlValDisp  = quantidade maxima disponivel                  ³±±
±±³          ³ nlQtdTot   = quantidade total                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ DigValIt                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValorNFxPC(nlValGet, nlValDisp, nlQtdTot )
	Local lRet := .F.

	If (nlValGet<=nlValDisp) .AND. (DigQtdeIt(nlValGet,nlQtdTot,"V")[2] ) .And. Positivo(nlValGet)
		lRet := .T.
	Else
		If !MsgYesNo("O valor informado do Item da nota não corresponde ao pedido selecionado. " + CHR(13)+CHR(10) + "Deseja continuar ?")
			lRet := .F.
		Else
			lRet := .T.
		Endif
	EndIf

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DIGQTDEIT³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao cria telinha para que o usuario digite numa get o   ³±±
±±³          ³ valor (unidades) do item da nota fiscal correspondente ao  ³±±
±±³          ³ pedido selecionado                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nlValGet   = quantidade ja preenchido                      ³±±
±±³          ³ nlQtdTot   = quantidade total                              ³±±
±±³          ³ clFin      = Finalidade da funcao. Pode receber "C" ou "V" ³±±
±±³          ³ Se recebe "V" (verificar), valida se ainda e possivel      ³±±
±±³          ³ selecionar valores referente ao item da nota. Valida o max.³±±
±±³          ³ Se "C" apenas calcula a quant. ja informada ( alRet[1] )   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ alRet = array 2 posicoes                                   ³±±
±±³          ³         [1] - soma dos valores jah preenchidos para o item ³±±
±±³          ³         [2] - Se .F., nao possivel mais indicar valor      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MarkBrwPC, ValorNFxPC                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DigQtdeIt(nlValGet,nlQtdTot,clFin)

	Local alRet := {0,.T.}
	Local nlReg := TMP->(Recno())

	TMP->(dbGoTop())
	While  TMP->(!EOF())
		If (clFin=="V")
			If (TMP->(Recno()) <> nlReg)
				alRet[1]+=TMP->QTDREF
			EndIf
		Else
			alRet[1]+=TMP->QTDREF
		EndIf
		TMP->(dbSkip())
	EndDo
	TMP->(dbGoTop())

	TMP->(dbGoTo(nlReg))
	If (clFin=="V")
		If ((alRet[1]+nlValGet) > nlQtdTot)
			alRet[2] := !alRet[2]
		EndIf
	Else
		alRet[1] := (nlQtdTot-alRet[1])
	EndIf

Return alRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ POSSC7   ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao para posicionar a Tabela SC7 no pedido escolhido    ³±±
±±³          ³ retorna o recno que sera passado como parametro na funcao  ³±±
±±³          ³ padrao do sistema A120Pedido()                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clPed = Numero do pedido de compra                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nlRet = SC7->(Recno())                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MarkBrwPC                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PosSC7(clPed)

	Local nlRet := 0

	dbSelectArea("SC7")
	dbSetOrder(1)
	SC7->(dbGoTop())
	If dbSeek(FWxFilial("SC7")+PadR(clPed,TamSx3("C7_NUM")[1]) )
		nlRet := SC7->(Recno())
	EndIf

Return nlRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ EXECTELA ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que monta aCols, aHeader para tela e executa rotina ³±±
±±³          ³ automatica                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nlOpc     := Opcao escolhida (2-Visu / 3-Gerar)            ³±±
±±³          ³ clCodFor  := Cod. Fornecedor/Cliente                       ³±±
±±³          ³ clLoja    := Loja                                          ³±±
±±³          ³ clNota    := Num. Nota                                     ³±±
±±³          ³ clSerie   := Serie                                         ³±±
±±³          ³ olLBox    := Objeto                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MontaBrw                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ExecTela(nlOpc,clCodFor,clLoja,clNota,clSerie,olLBox)

	Local nlUsado       := 0
	Local alDTVirt      := {}
	Local alDTVisu      := {}
	Local alRecDT       := {}
	Local alSF1         := {}
	Local alSD1         := {}
	Local alSize        := MsAdvSize(.T.)
	Local clKey         := ""
	Local clTab1	     := "SDS"
	Local clTab2	     := "SDT"
	Local clAwysT       := "AllwaysTrue()"
	Local alCpoEnch     := {}
	Local alHeaderDT    := {}
	Local llPedCom      := .F.
	Local llD1Imp       := .F.
	Local x
    Local nx
	Private lMsErroAuto := .F.
	Private aCols 	     := {}
	Private aHeader     := {}

	DO CASE
		CASE nlOpc == 9
			nlOpc := 4
			Private aHeader := GdMontaHeader(	@nlUsado     	,; //01 -> Por Referencia contera o numero de campos em Uso
												@alDTVirt       ,; //02 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Virtuais
												@alDTVisu       ,; //03 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Visuais
												clTab2          ,; //04 -> Opcional, Alias do Arquivo Para Montagem do aHeader
												{"DT_FILIAL","DT_QUANT","DT_PRODFOR","DT_DESCFOR","DT_FORNEC","DT_LOJA","DT_DOC","DT_SERIE","DT_CNPJ","DT_VUNIT","DT_TOTAL","DT_NFORI","DT_SERIORI","DT_ITEMORI","DT_VALFRE","DT_SEGURO","DT_DESPESA","DT_VALDESC"} 	 ,; //05 -> Opcional, Campos que nao Deverao constar no aHeader
												.F.             ,; //06 -> Opcional, Carregar Todos os Campos
												.F.             ,; //07 -> Nao Carrega os Campos Virtuais
												.F.             ,; //08 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
												NIL             ,; //09 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
												.T.             ,; //10 -> Verifica se Deve Checar se o campo eh usado
												.T.             ,;
												.F.             ,;
												.F.             ,;
												)
		CASE nlOpc == 8
			nlOpc := 2
			Private aHeader := GdMontaHeader(	@nlUsado     	,; //01 -> Por Referencia contera o numero de campos em Uso
												@alDTVirt       ,; //02 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Virtuais
												@alDTVisu       ,; //03 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Visuais
												clTab2          ,; //04 -> Opcional, Alias do Arquivo Para Montagem do aHeader
												{"DT_FILIAL","DT_PRODFOR","DT_DESCFOR","DT_FORNEC","DT_LOJA","DT_DOC","DT_SERIE","DT_CNPJ","DT_VUNIT","DT_TOTAL","DT_PEDIDO","DT_ITEMPC","DT_NFORI","DT_SERIORI","DT_ITEMORI","DT_VALFRE","DT_SEGURO","DT_DESPESA","DT_VALDESC"} 	 ,; //05 -> Opcional, Campos que nao Deverao constar no aHeader
												.F.             ,; //06 -> Opcional, Carregar Todos os Campos
												.F.             ,; //07 -> Nao Carrega os Campos Virtuais
												.F.             ,; //08 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
												NIL             ,; //09 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
												.T.             ,; //10 -> Verifica se Deve Checar se o campo eh usado
												.T.             ,;
												.F.             ,;
												.F.             ,;
												)
		OTHERWISE
			nlOpc := 2
			Private aHeader := GdMontaHeader(	@nlUsado     	,; //01 -> Por Referencia contera o numero de campos em Uso
												@alDTVirt       ,; //02 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Virtuais
												@alDTVisu       ,; //03 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Visuais
												clTab2          ,; //04 -> Opcional, Alias do Arquivo Para Montagem do aHeader
												{"DT_FILIAL"} 	,; //05 -> Opcional, Campos que nao Deverao constar no aHeader
												.F.             ,; //06 -> Opcional, Carregar Todos os Campos
												.F.             ,; //07 -> Nao Carrega os Campos Virtuais
												.F.             ,; //08 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
												NIL             ,; //09 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
												.T.             ,; //10 -> Verifica se Deve Checar se o campo eh usado
												.T.             ,;
												.F.             ,;
												.F.             ,;
												)
	ENDCASE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona a tabela SDS e carrega variáveis de memória                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(clTab1)
	dbSetOrder(1)
	&(clTab1+"->(dbGoTop())")
	dbSeek(FWxFilial(clTab1)+clNota+clSerie+clCodFor+clLoja)
	RegToMemory("SDS",.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campos usados para Enchoice                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/* dbSelectArea("SX3")
	SX3->(dbSetOrder(1))
	SX3->(dbGoTop())
	SX3->(dbSeek("SDS")) */
	alCpoEnch:={}
/* 	Do While !Eof().And.(SX3->X3_ARQUIVO=="SDS")
		V_CPO:=ALLTRIM(X3_CAMPO)
		If X3USO(SX3->X3_USADO) .And. cNivel>=SX3->X3_NIVEL
			Aadd(alCpoEnch,V_CPO)
		Endif
		DbSkip()
	EndDo */
	//202304 - ajuste para usar a função FWSX3Util para buscar informações do SX3
	aSx3 := FWSX3Util():GetAllFields("SDS")
	For nx := 1 to len(aSx3)
		If X3Uso(GetSx3Cache(aSx3[nx],"X3_USADO")) .AND. cNivel >= GetSx3Cache(aSx3[nx],"X3_NIVEL") 
			V_CPO:= ALLTRIM(GetSx3Cache(aSx3[nx],"X3_CAMPO"))
			Aadd(alCpoEnch,V_CPO)
		Endif
	Next nx



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aCols                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SDT")
	SDT->(dbSetOrder(1))
	SDT->(dbGoTop())
	alRecDT := {}
	alHeaderDT:=aClone(aHeader)
	clKey := FWxFilial("SDS")+M->DS_CNPJ+clCodFor+clLoja+clNota+clSerie
	aCols := GdMontaCols(	@alHeaderDT		,; //01 -> Array com os Campos do Cabecalho da GetDados
							@nlUsado		,;	//02 -> Numero de Campos em Uso
							@alDTVirt		,;	//03 -> [@]Array com os Campos Virtuais
							@alDTVisu   	,;	//04 -> [@]Array com os Campos Visuais
							clTab2			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
							NIL				,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
							@alRecDT		,;	//07 -> [@]Array unidimensional contendo os Recnos
							clTab1			,;	//08 -> Alias do Arquivo Pai
							clKey  			,;	//09 -> Chave para o Posicionamento no Alias Filho
							NIL				,;	//10 -> Bloco para condicao de Loop While
							NIL				,;	//11 -> Bloco para Skip no Loop While
							.F.				,;	//12 -> Se Havera o Elemento de Delecao no aCols
							.F.				,;	//13 -> Se cria variaveis Publicas
							.T.				,;	//14 -> Se Sera considerado o Inicializador Padrao
							NIL				,;	//15 -> Lado para o inicializador padrao
							NIL				,;	//16 -> Opcional, Carregar Todos os Campos
							.F.				,;	//17 -> Opcional, Nao Carregar os Campos Virtuais
							NIL				,;	//18 -> Opcional, Utilizacao de Query para Selecao de Dados
							NIL				,;	//19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
							NIL				,;	//20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
							.F.				,;	//21 -> Carregar Coluna Fantasma
							NIL				,;	//22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
							.T.				,;	//23 -> Verifica se Deve Checar se o campo eh usado
							.T.				,;	//24 -> Verifica se Deve Checar o nivel do usuario
							NIL				,;	//25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
							NIL				,;	//26 -> [@]Array que contera as chaves conforme recnos
							NIL				,;	//27 -> [@]Se devera efetuar o Lock dos Registros
							NIL				,;	//28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
							NIL				,;	//29 -> Numero maximo de Locks a ser efetuado
							.F.				,;	//30 -> Utiliza Numeracao na GhostCol
							NIL				,;	//31
							nlOpc		     ;	//32 -> nOpc
							)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta tela modelo 3                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Mod3XML(	nlOpc,;                  								  		// 01 -> Opcao
				"Nf-e Disponíveis",;                  							// 02 -> Titulo da Tela
				clTab1,;                  								  		// 03 -> Tabela para Enchoice
				clTab2,;               									 		// 04 -> Tabela para GetDados
				alCpoEnch,;                 							  		// 05 -> Campos Enchoice
				clAwysT,;                 								  		// 06 -> CampoOk
				clAwysT,;                  								 		// 07 -> LinhaOk
				nlOpc,;                 										// 08 -> Opcao Enchoice
				nlOpc,;                  										// 09 -> Opcao GetDados
				clAwysT,;                  										// 10 -> TdOk
				.T.,;                  											// 11 -> Se carrega Campos Virtuais
				alCpoEnch,;                  									// 12 -> Campos alterar
				GetRodape(clCodFor,clLoja,clNota,clSerie,clTab1) ); 			// 13 -> Array com as informacoes do Radape
				.AND. VldCpoProd(clCodFor,clLoja,clNota,clSerie,SDS->DS_TIPO)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processa Liberação ou Geração da pre-nota                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Begin Transaction

			If SDS->DS_STATUS == "L"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se todas qtdes informadas são iguais a qtde do XML           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				_lQtdeNOk := .F.
				dbSelectArea("SDT")
				dbSetOrder(3)
				If SDT->(dbSeek(FWxFilial("SDT")+clCodFor+clLoja+clNota+clSerie))
					While SDT->(!EOF()) .AND. (SDT->DT_FILIAL==FWxFilial("SDT")) .AND. (SDT->DT_FORNEC==clCodFor) .AND. (SDT->DT_LOJA==clLoja) .AND. (SDT->DT_DOC==clNota) .AND. (SDT->DT_SERIE==clSerie)
						If SDT->DT_QUANT <> SDT->DT_QUANTC
							_lQtdeNOk := .T.
							MsgAlert("Existem Divergências entre Qtdes Recebidas do XML e Qtdes Informadas. Qtdes Serão Zeradas e Deverão ser Redigitadas")
							Exit
						Endif
						SDT->(dbSkip())
					EndDo
				Endif

				If _lQtdeNOk		// Caso exista divergência entre Qtdes
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza Informação das Qtdes tabela SDT                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SDT")
					dbSetOrder(3)
					If SDT->(dbSeek(FWxFilial("SDT")+clCodFor+clLoja+clNota+clSerie))
						While SDT->(!EOF()) .AND. (SDT->DT_FILIAL==FWxFilial("SDT")) .AND. (SDT->DT_FORNEC==clCodFor) .AND. (SDT->DT_LOJA==clLoja) .AND. (SDT->DT_DOC==clNota) .AND. (SDT->DT_SERIE==clSerie)
							RecLock("SDT",.F.)
							Replace DT_QUANTC With 0
							SDT->(MsUnLock())
							SDT->(dbSkip())
						EndDo
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza Status para Liberar Qtdes                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea(clTab1)
					dbSetOrder(1)
					&(clTab1)->(dbGoTop())
					If dbSeek(FWxFilial(clTab1)+clNota+clSerie+clCodFor+clLoja)
						If RecLock(clTab1,.F.)
							Replace DS_STATUS With 'Q' 		// LIBERA QTDES
							&(clTab1)->(MsUnLock())
						EndIf
					EndIf
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza Status para Gerar Pré-Nota                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea(clTab1)
					dbSetOrder(1)
					&(clTab1)->(dbGoTop())
					If dbSeek(FWxFilial(clTab1)+clNota+clSerie+clCodFor+clLoja)
						If RecLock(clTab1,.F.)
							Replace DS_STATUS With ' ' 		// LIBERADO PARA GERAR PRE-NOTA
							&(clTab1)->(MsUnLock())
							Aviso("Atenção", "Documento Liberado para Gerar Pré-Nota com Sucesso!" ,{"Ok"})
						EndIf
					EndIf
				Endif

			ElseIf SDS->DS_STATUS == "Q"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza Informação das Qtdes tabela SDT                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				For x:=1 To Len(aCols)
					dbSelectArea("SDT")
					//SDT->(DbOrderNickName("_SERIEITEM"))
					SDT->(DbSetOrder(8))

					If SDT->(dbSeek(FWxFilial("SDT")+clCodFor+clLoja+clNota+clSerie+aCols[x][1]))
						RecLock("SDT",.F.)
						Replace DT_QUANTC With gdFieldGet('DT_QUANTC',x)
						Replace DT_TEMMERC With gdFieldGet('DT_TEMMERC',x)
						Replace DT_MOTDEV1 With gdFieldGet('DT_MOTDEV1',x)
						SDT->(MsUnLock())

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza QTDE CONFERIDA na tabela de histórico das qtdes informadas   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("ZDT")
						DbSetOrder(3)
						DbSeek(FWxFilial("ZDT") + clNota + clSerie + clCodFor + clLoja)
						While !Eof() .And. ZDT_FILIAL + ZDT_DOC + ZDT_SERIE + ZDT_FORNEC + ZDT_LOJA == FWxFilial("ZDT") + clNota + clSerie + clCodFor + clLoja
							RecLock("ZDT",.F.)
							ZDT->ZDT_QUANTC := SDT->DT_QUANTC
							ZDT->ZDT_USQTDC := cUserName
							MsUnlock()

							DbSelectArea("ZDT")
							DbSkip()
						Enddo
						
						SDT->(dbSkip())
					Endif
				Next

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza Status para Liberar Qtdes                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea(clTab1)
				dbSetOrder(1)
				&(clTab1)->(dbGoTop())
				If dbSeek(FWxFilial(clTab1)+clNota+clSerie+clCodFor+clLoja)
					If RecLock(clTab1,.F.)
						Replace DS_STATUS With 'L' 		// LIBERA QTDES
						&(clTab1)->(MsUnLock())
					EndIf
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera a pre-nota                                                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Alimenta vetores para a rotina automática (MSExecAuto)                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				alSF1:=F1Imp(clCodFor,clLoja,clNota,clSerie,clTab1)
				MsgRun("Aguarde...",,{|| iif(!Empty(alSD1:=D1Imp(clCodFor,clLoja,clNota,clSerie,clTab2)),llD1Imp:=.T.,llD1Imp:=.F.  ) } )
				MsgRun("Aguarde...",,{|| llPedCom := VldQtdPC(alSD1) } )
				If llD1Imp .AND. llPedCom
					lMsErroAuto := .F.

					MsgRun("Aguarde gerando Pré-Nota de Entrada...",,{|| MSExecAuto({|x,y,z| MATA140(x,y,z)},alSF1,alSD1,3 )})			// Sem exibir tela
					//MsgRun("Aguarde gerando Pré-Nota de Entrada...",,{|| MSExecAuto({|x,y,z,a,b| MATA140(x,y,z,a,b)},alSF1,alSD1,3,,1 )})	// Exibindo a tela

					If !lMsErroAuto
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Após executada a rotina automática, atualiza registro                 ³
						//³ (Status, Data Importação ...)                                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea(clTab1)
						dbSetOrder(1)
						&(clTab1)->(dbGoTop())
						If dbSeek(FWxFilial(clTab1)+clNota+clSerie+clCodFor+clLoja)
							If RecLock(clTab1,.F.)
								Replace DS_USERPRE  With cUserName
								Replace DS_DATAPRE  With dDataBase
								Replace DS_HORAPRE  With Time()
								Replace DS_STATUS   With 'P' // P = PROCESSADA PELO PROTHEUS
								&(clTab1)->(MsUnLock())
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Atualiza protocolo na tabela de histórico das qtdes informadas        ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								DbSelectArea("ZDT")
								DbSetOrder(3)
								DbSeek(FWxFilial("ZDT") + clNota + clSerie + clCodFor + clLoja)
								While !Eof() .And. ZDT_FILIAL + ZDT_DOC + ZDT_SERIE + ZDT_FORNEC + ZDT_LOJA == FWxFilial("ZDT") + clNota + clSerie + clCodFor + clLoja
									RecLock("ZDT",.F.)
									ZDT->ZDT_PROT 	:= SDS->DS_STATUS + "-" + SDS->DS_CHAVENF + "-V" + SDS->DS_VERSAO 
									ZDT->ZDT_DTPROT	:= DDATABASE
									ZDT->ZDT_USPROT := cUserName
									MsUnlock()

									DbSelectArea("ZDT")
									DbSkip()
								Enddo
								
								Aviso("Atenção", "Pré-Nota gerada com Sucesso!" ,{"Ok"})
							EndIf
						EndIf
					Else
						DisarmTransaction()
						lMsErroAuto := .F.
						MostraErro()
					EndIf
				EndIf
			Endif

		End Transaction
		/*
		Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza Informação das Qtdes tabela SDT                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SDT")
		dbSetOrder(3)
		If SDT->(dbSeek(FWxFilial("SDT")+clCodFor+clLoja+clNota+clSerie))
		While SDT->(!EOF()) .AND. (SDT->DT_FILIAL==FWxFilial("SDT")) .AND. (SDT->DT_FORNEC==clCodFor) .AND. (SDT->DT_LOJA==clLoja) .AND. (SDT->DT_DOC==clNota) .AND. (SDT->DT_SERIE==clSerie)
		RecLock("SDT",.F.)
		Replace DT_QUANTC With 0
		SDT->(MsUnLock())
		SDT->(dbSkip())
		EndDo
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza Status para Liberar Qtdes                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(clTab1)
		dbSetOrder(1)
		&(clTab1)->(dbGoTop())
		If dbSeek(FWxFilial(clTab1)+clNota+clSerie+clCodFor+clLoja)
		If RecLock(clTab1,.F.)
		Replace DS_STATUS With 'Q' 		// LIBERA QTDES
		&(clTab1)->(MsUnLock())
		EndIf
		EndIf

		MsgAlert("Devido ao Cancelamento do Processo as Qtdes Foram Zeradas e Deverão ser Redigitadas")
		*/
	EndIf

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VLDQTDPC ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Essa funcao executada quando gera pre nota. Se retornar .T.³±±
±±³          ³ gera a rotina automatica.                                  ³±±
±±³          ³ Funcao verifica se qtde do pedido compra escolhido condiz  ³±±
±±³          ³ com a qtde disponivel do pedido compra (SC7) atualizado    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ alItns := Array com os itens (D1) para rotina automatica   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ llRet = Se .T. = OK                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ExecTela                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VldQtdPC(alItns)

	Local llRet     := .T.
	Local nlK       := 0
	Local llErro    := .F.
	Local nlPedPos  := 0
	Local nlItnPos  := 0
	Local nlQtdPos  := 0
	Local nlForPos  := 0
	Local nlLojPos  := 0
	Local nlNotPos  := 0
	Local nlSerPos  := 0
	Local nlCodPos  := 0

	// Desabilitado para poder processar pre nota com qtde maior que o pedido original
	/*/
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Laço percorre array dos itens e faz verificação se item tiver         ³
	//³ pedido de compra preenchido                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nlK:=1 to Len(alItns)
	If ((nlPedPos:=Ascan(alItns[nlK],{|x|X[1]=="D1_PEDIDO"}))>0) .AND. ((nlItnPos:=Ascan(alItns[nlK],{|x|X[1]=="D1_ITEMPC"}))>0)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as posicoes dos campos no array                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nlQtdPos := Ascan(alItns[nlK],{|x|X[1]=="D1_QUANT"})
	nlForPos := Ascan(alItns[nlK],{|x|X[1]=="D1_FORNECE"})
	nlLojPos := Ascan(alItns[nlK],{|x|X[1]=="D1_LOJA"})
	nlNotPos := Ascan(alItns[nlK],{|x|X[1]=="D1_DOC"})
	nlSerPos := Ascan(alItns[nlK],{|x|X[1]=="D1_SERIE"})
	nlCodPos := Ascan(alItns[nlK],{|x|X[1]=="D1_COD"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se na tabela de pedido de compras existe realmente a qtde    ³
	//³ disponível e se tiver diferença para mais exclui da SDV               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC7")
	dbSetOrder(1)
	SC7->(dbGoTop())
	If SC7->(dbSeek(FWxFilial("SC7")+PadR(alItns[nlK,nlPedPos,2],TamSx3("C7_NUM")[1])+ PadR(alItns[nlK,nlItnPos,2],TamSx3("C7_ITEM")[1])))
	If (alItns[nlK,nlQtdPos,2] > (SC7->C7_QUANT-SC7->C7_QUJE) )
	dbSelectArea("SDV")
	dbSetOrder(1)
	SDV->(dbGoTop()) // dbSeek - > Fornecedor+Loja+Nota Num.+Serie+Cod. Produto+Num. Pedido+Item PC
	If SDV->(dbSeek(FWxFilial("SDV")+alItns[nlK,nlForPos,2]+alItns[nlK,nlLojPos,2]+alItns[nlK,nlNotPos,2]+alItns[nlK,nlSerPos,2]+alItns[nlK,nlCodPos,2]+alItns[nlK,nlPedPos,2]+alItns[nlK,nlItnPos,2] ))
	If RecLock("SDV",.F.)
	SDV->(DbDelete())
	SDV->(MsUnlock())
	EndIf
	llErro:=.T.
	EndIf
	EndIf
	EndIf
	EndIf
	Next nlK
	/*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe mensagem de erro                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If llErro
		Aviso("Atenção","Erro ao importar a Pré-Nota",{"Ok"})
		llRet:=.F.
	EndIf

Return llRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VLDCPOPROD³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se campo Produto esta preenchido. Caso nao estejac³±±
±±³          ³ executa funcao para que o usuario escolha qual produto se  ³±±
±±³          ³ corresponde                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clCodFor  := Cod. Fornecedor/Cliente                       ³±±
±±³          ³ clLoja    := Loja                                          ³±±
±±³          ³ clNota    := Num. Nota                                     ³±±
±±³          ³ clSerie   := Serie                                         ³±±
±±³          ³ clTipo    := N = Nota fiscal Normal / B ou D = Benef./Dev. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ llRet = Se .T. = OK                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ExecTela                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VldCpoProd(clCodFor,clLoja,clNota,clSerie, clTipo)

	Local llRet     := .T.
	Local nlK       := 0
	Local nlPosCmp  := Ascan(aHeader,{|x|Alltrim(X[2])=="DT_COD"})

	For nlK:=1 to Len(aCols)
		If Empty(aCols[nlK,nlPosCmp])
			llRet:=EscolhaPrd(clCodFor,clLoja,clNota,clSerie,clTipo,nlK,nlPosCmp)
			Exit
		EndIf
	Next nlK

Return llRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ESCOLHAPRD³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta a tela com produtos sem cod. para que usuario escolha³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clCodFor  := Cod. Fornecedor/Cliente                       ³±±
±±³          ³ clLoja    := Loja                                          ³±±
±±³          ³ clNota    := Num. Nota                                     ³±±
±±³          ³ clSerie   := Serie                                         ³±±
±±³          ³ clTipo    := N = Nota fiscal Normal / B ou D = Benef./Dev. ³±±
±±³          ³ nlK       := Primeira posicao do acols encontrada s/ Prod. ³±±
±±³          ³ nlPosCmp  := Posicao no aHeader do campo "DT_COD"          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ llProcPrd = Se .T. = OK                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VldCpoProd                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function EscolhaPrd(clCodFor,clLoja,clNota,clSerie, clTipo, nlK, nlPosCmp)

	Local llProcPrd   :=.F.
	Local alSize    	:= MsAdvSize()
	Local nlTl1     	:= alSize[1]
	Local nlTl2    	:= alSize[2]
	Local nlTl3    	:= alSize[1]+300
	Local nlTl4     	:= alSize[2]+520
	Local olFont      := TFont ():New(,,-11,.T.,.T.,5,.T.,5,.F.,.F.)
	Local llRetCons   := .F.
	Local alHeaderTw  := {("Escolha produto"+Iif(AllTrim(clTipo)=="N","Fornecdor","Cliente" )),"Produto","Descrição"}
	Local alTamHeader := {60,60,100}
	Local alRegs      := {}
	Local olLisBox    := NIL
	Local olBtInf     := NIL
	Local alAlias     := Iif(AllTrim(clTipo)=="N",{"SA2","A2_NOME"},{"SA1","A1_NOME"})
	Local nlCodPos    := Ascan(aHeader,{|x|Alltrim(X[2])=="DT_PRODFOR"})

	Local nlCodIte    := Ascan(aHeader,{|x|Alltrim(X[2])=="DT_ITEM"}) // new

	Local nlCont      := 0
	Private _opPPrDlg := NIL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona registros                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nlCont:=nlK to Len(aCols)
		If Empty(aCols[nlCont,nlPosCmp])
			aAdd(alRegs,{(aCols[nlCont,nlCodPos]),"","",(aCols[nlCont,nlCodIte]),nlCont})
		EndIf
	Next nlCont

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tela - Interface                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG _opPPrDlg TITLE "Seleção Produtos" From nlTl1,nlTl2 to nlTl3,nlTl4 PIXEL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Box                                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@(nlTl1+10),nlTl2 to (nlTl1+35),(nlTl2+237) PIXEL OF _opPPrDlg
	@(nlTl1+14),(nlTl2+005) Say "Fornecedor: " + clCodFor + " - " + Posicione(alAlias[1],1,(FWxFilial(alAlias[1])+clCodFor+clLoja),alAlias[2])   Font olFont Pixel Of _opPPrDlg
	@(nlTl1+23),(nlTl2+005) Say "Itens sem Código " + AllTrim(SM0->M0_NOME)+"/"+AllTrim(SM0->M0_FILIAL) + " Font olFont Pixel Of _opPPrDlg

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TW Browse - Itens da Nota                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	olLisBox := TwBrowse():New(nlTl1+40,nlTl2,nlTl4-295,nlTl3-217,,alHeaderTw,alTamHeader,_opPPrDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	olLisBox:SetArray(alRegs)
	olLisBox:bLine := {|| {alRegs[olLisBox:nAt,1],alRegs[olLisBox:nAt,2],alRegs[olLisBox:nAt,3]} }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botoes                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	olBtInf  := TButton():New(nlTl1+132,nlTl2,"Produto" ,_opPPrDlg,{|| (llRetCons:=ConPad1(,,,"SB1",,,.F.)),(Iif(llRetCons, ((alRegs[olLisBox:nAt,2]:=SB1->B1_COD),(alRegs[olLisBox:nAt,3]:=SB1->B1_DESC)) ,  ) )    } ,065,012,,,,.T.  )
	DEFINE SBUTTON FROM nlTl1+134,nlTl2+178 TYPE 1 ACTION (eVal( {|| llProcPrd:=PrcPrdOK(alRegs),  Iif((llProcPrd==.T.),(AtuSDT(alRegs,nlPosCmp,clCodFor,clLoja,clNota,clSerie, clTipo, ""),_opPPrDlg:End()),Aviso("Atenção" ,"Produto não encontrado" ,{"Ok" }))   } )) ENABLE Of _opPPrDlg
	DEFINE SBUTTON FROM nlTl1+134,nlTl2+212 TYPE 2 ACTION (eVal( {|| Iif(MsgyESnO("Deseja sair?"),_opPPrDlg:End(),) } )) ENABLE Of _opPPrDlg

	ACTIVATE DIALOG _opPPrDlg CENTERED

Return llProcPrd


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ATUSDT   ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao atualiza aCols e tabela SDT pela escolha do usuario ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ alRegs    := Array com os registros                        ³±±
±±³          ³ nlPosCmp  := Posicao no aHeader do Campo DT_COD            ³±±
±±³          ³ clCodFor  := Cod. Fornecedor/Cliente                       ³±±
±±³          ³ clLoja    := Loja                                          ³±±
±±³          ³ clNota    := Num. Nota                                     ³±±
±±³          ³ clSerie   := Serie                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EscolhaPrd                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AtuSDT(alRegs,nlPosCmp,clCodForCli,clLoja,clNota,clSerie, clTipo, cItem)

	Local nlK         := 0
	Local nlPosDes 	:= Ascan(aHeader,{|x|Alltrim(X[2])=="DT_DESC"})
	Local cProdForCli := ""
	Local aArea		   := GetArea()

	For nlK:=1 to Len(alRegs)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza aCols                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCols[alRegs[nlK,Len(alRegs[nlK])],nlPosCmp] := alRegs[nlK,2]
		aCols[alRegs[nlK,Len(alRegs[nlK])],nlPosDes] := alRegs[nlK,3]

		cItem       := PadR(AllTrim(alRegs[nlK,4]),TamSx3("DT_ITEM")[1])
		cProdForCli := PadR(AllTrim(alRegs[nlK,1]),TamSx3("DT_PRODFOR")[1])
		cProdEmp		:= PadR(AllTrim(alRegs[nlK,2]),TamSX3("B1_COD")[1])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza relacionamento Produto X Fornecedor e tabela SDT             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		GPrdxPrdF(clCodForCli, clLoja, clNota, clSerie, cProdForCli, cProdEmp, clTipo, cItem)
	Next nlK

	RestArea(aArea)

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PRCPRDOK ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao do botao OK na tela de selecao de prod. corresp. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ alRegs     := Array com os itens                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EscolhaPrd                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrcPrdOK(alRegs)

	Local llPrcPrdOk := .T.
	Local nlT        := 0

	For nlT:=1 to Len(alRegs)
		If Empty(alRegs[nlT,2])
			llPrcPrdOk := !llPrcPrdOk
			Exit
		EndIf
	Next nlT

Return llPrcPrdOk


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GETRODAPE³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao que busca as inforamcoes do rodape da tela mod. 3   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clCodFor  := Cod. Fornecedor/Cliente                       ³±±
±±³          ³ clLoja    := Loja                                          ³±±
±±³          ³ clNota    := Num. Nota                                     ³±±
±±³          ³ clSerie   := Serie                                         ³±±
±±³          ³ clTab1    := Tabela SDS                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array alNFe                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ExecTela                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GetRodape(clCodFor,clLoja,clNota,clSerie,clTab1)

	Local alNFe := {}

	dbSelectArea(clTab1)
	dbSetOrder(1)
	&(clTab1)->(dbGoTop())
	If dbSeek(FWxFilial(clTab1)+clNota+clSerie+clCodFor+clLoja)
		aAdd(alNFe, &(clTab1+"->DS_STATUS"  ))
		aAdd(alNFe, &(clTab1+"->DS_ARQUIVO" ))
		aAdd(alNFe, &(clTab1+"->DS_USERIMP" ))
		aAdd(alNFe, &(clTab1+"->DS_DATAIMP" ))
		aAdd(alNFe, &(clTab1+"->DS_HORAIMP" ))
	EndIf

Return alNFe


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MOD3XML  ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina principal para importar Schema XML                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nlOpc       := Opcao Usuario (2-Visualiza/3-Gera Pre Nota) ³±±
±±³          ³ clTitle     := Titulo da Tela                              ³±±
±±³          ³ clTab1      := Alias da Enchoice                           ³±±
±±³          ³ clTab2      := Alias da GetDados                           ³±±
±±³          ³ alCpoEnch   := Cmpos da Enchoice                           ³±±
±±³          ³ clAwysT     := cLinhaOk                                    ³±±
±±³          ³ clAwysT     := cTudoOk                                     ³±±
±±³          ³ nlOpc1      := Opcao Enchoice                              ³±±
±±³          ³ nlOpc2      := Opcao GetDados                              ³±±
±±³          ³ clAwysT     := cFieldOk                                    ³±±
±±³          ³ llVirtual   := llVirtual (Campos Virtuais)                 ³±±
±±³          ³ alCpoEnch   := Campos Alteracao enchoice                   ³±±
±±³          ³ alInfRod    := Array com as informacoes do radpe           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ llRet                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ExecTela                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Mod3XML(nlOpc,clTitle,clTab1,clTab2,alCpoEnch,clAwysT,clAwysT,nlOpc1,nlOpc2,clAwysT,llVirtual,alAltEnch,alInfRod)

	//Local alAdvSz    := MsAdvSize()
	Local alAdvSz     := MsAdvSize(,.F.,400)
	Local alRNfe     := alInfRod
	Local olFld      := NIL
	Local llRet 	  := .F.
	Local olFont     := TFont ():New(,,-11,.T.,.F.,5,.T.,5,.F.,.F.)
	Local olFont2    := TFont ():New(,,-11,.T.,.T.,5,.T.,5,.F.,.F.)
	Local clPicture  := "@E 999,999,999.99"
	Local olEnch     := NIL
	Local olGetDd    := NIL
	Local olGetStats := NIL
	Local olGetArq   := NIL
	Local olGetUser  := NIL
	Local olGetData  := NIL
	Local olGetHora  := NIL
	Local clGStatus  := Iif( Empty(Upper(alRNfe[1])),"???","???")
	Local clGNomArq  := Upper(alRNfe[2])
	Local clGUser    := alRNfe[3]
	Local dlGData    := alRNfe[4]
	Local clGHora    := alRNfe[5]
	Local nPosDesc	  := 0
	Local nPosProd	  := 0
	Local cDescProd  := ""
	Local aPosCab   := {}
	Local oSize     := FwDefSize():New()
	Local nLoop
	Local nLoops
	Private aTrocaF3 := {}
	Private _opMoD3lg:= NIL

	oSize:AddObject("CABEC",100,20,.T.,.T.) // Totalmente dimensionavel
	oSize:lProp := .T. 						 // Proporcional             
	oSize:aMargins := {0,0,0,3}			  	 // Espaco ao lado dos objetos 0, entre eles 3 
	oSize:Process() 	   					 // Dispara os calculos de coordenadas

	aPosCab := {oSize:GetDimension("CABEC","LININI"),oSize:GetDimension("CABEC","COLINI"),;
	oSize:GetDimension("CABEC","LINEND"),oSize:GetDimension("CABEC","COLEND")}

	DEFINE MSDIALOG _opMoD3lg FROM alAdvSz[7]+45,0 TO alAdvSz[6],alAdvSz[5] TITLE clTitle Of oMainWnd PIXEL

	oPanelH := tPanel():New(0,0,"",_opMoD3lg,,,,,,0,0)
	oPanelE := tPanel():New(0,0,"",oPanelH,,,,,,0,110)	
	oPanelF := tPanel():New(0,0,"",oPanelH,,,,,,0,80) 
	oPanelG := tPanel():New(0,0,"",oPanelH,,,,,,0,0)

	oPanelH:Align := CONTROL_ALIGN_ALLCLIENT
	oPanelE:Align := CONTROL_ALIGN_TOP
	oPanelF:Align := CONTROL_ALIGN_BOTTOM
	oPanelG:Align := CONTROL_ALIGN_ALLCLIENT

	//olFld := TFolder():New((alAdvSz[1]+151),(alAdvSz[2]-6),{"Arquivos XML carregados"},{},_opMoD3lg,,,,.T.,.F., 334 , 068  )
	olFld := TFolder():New(0,0,{"Arquivos XML carregados"},{},oPanelF,,,,.T.,.F.,0,0)

	olFld:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajusta tela para TEMAP10                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (Alltrim(GetTheme()) == "TEMAP10") .Or. SetMdiChild()
		_opMoD3lg:nHeight+=025
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Muda consulta padrão do campo DS_FORNEC para tabela de clientes - SA1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF AllTrim(SDS->DS_TIPO)<>"N"
		Aadd(aTrocaF3,{"DS_FORNEC", "SA1"} )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Enchoice e GetDados                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RegToMemory(clTab1,.F.)
	//olEnch := Msmget():New(clTab1,&(clTab1)->(Recno()),nlOpc,,,,alCpoEnch,{15,5,80,340},,3,,,,_opMoD3lg,,.T.,,,,,,,,.T.)
	olEnch := Msmget():New(clTab1,&(clTab1)->(Recno()),2,,,,alCpoEnch,aPosCab,,3,,,,oPanelE,,.T.,,,,,,,,.F.)
	olEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT


	If !(Type("aHeader") == "U") .AND. !(Type("aCols") == "U") .AND. ((nPosDesc := GDFieldPos("DT_DESC", aHeader))>0) .AND. ((nPosProd := GDFieldPos("DT_COD", aHeader))>0)
		nLoops := Len( aCols  )
		For nLoop := 1 To nLoops
			cDescProd := Posicione("SB1",1,FWxFilial("SB1")+aCols[nLoop][nPosProd],"B1_DESC")
			GdFieldPut( "DT_DESC" , cDescProd , nLoop , aHeader , aCols )
		Next nLoop
	EndIf

	//olGetDd := MsGetDados():New(84,5,150,340,nlOpc,clAwysT,clAwysT,"",.T.,,,,,clAwysT)
	olGetDd := MsGetDados():New(0,0,0,0,nlOpc,clAwysT,clAwysT,"",.T.,,,,,,,,,oPanelG)

	olGetDd:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Rodapé                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	// NOTA FISCAL ELETRONICA
	// Status
	@(alAdvSz[1]+010),(alAdvSz[2]-2) Say "Status" Font olFont Pixel Of olFld:aDialogs[1]
	olGetStats := TGet():New((alAdvSz[1]+08),(alAdvSz[2]+045),{|u| if(PCount()>0,clGStatus:=u,clGStatus)}, olFld:aDialogs[1] ,110,10,"@!",,,,,,,.T.,,,,,,,.T.,,,"clGStatus")

	// Arquivo
	@(alAdvSz[1]+025),(alAdvSz[2]-2) Say "Arquivo" Font olFont Pixel Of olFld:aDialogs[1]
	olGetArq := TGet():New((alAdvSz[1]+23),(alAdvSz[2]+045),{|u| if(PCount()>0,clGNomArq:=u,clGNomArq)}, olFld:aDialogs[1] ,110,10,"@!",,,,,,,.T.,,,,,,,.T.,,,"clGNomArq")

	// Usuario Import
	@(alAdvSz[1]+010),(alAdvSz[2]+170) Say "Usuario Import" Font olFont Pixel Of olFld:aDialogs[1]
	olGetUser := TGet():New((alAdvSz[1]+08),(alAdvSz[2]+240),{|u| if(PCount()>0,clGUser:=u,clGUser)}, olFld:aDialogs[1] ,70,10,,,,,,,,.T.,,,,,,,.T.,,,"clGUser")

	// Data Import
	@(alAdvSz[1]+025),(alAdvSz[2]+170) Say "Data Import" Font olFont Pixel Of olFld:aDialogs[1]
	olGetData := TGet():New((alAdvSz[1]+23),(alAdvSz[2]+240),{|u| if(PCount()>0,dlGData:=u,dlGData)}, olFld:aDialogs[1] ,50,10,,,,,,,,.T.,,,,,,,.T.,,,"dlGData")

	// Hora Import
	@(alAdvSz[1]+040),(alAdvSz[2]+170) Say "Hora Import" Font olFont Pixel Of olFld:aDialogs[1]
	olGetHora := TGet():New((alAdvSz[1]+38),(alAdvSz[2]+240),{|u| if(PCount()>0,clGHora:=u,clGHora)}, olFld:aDialogs[1] ,40,10,,,,,,,,.T.,,,,,,,.T.,,,"clGHora")

	ACTIVATE MSDIALOG _opMoD3lg ON INIT(EnchoiceBar(_opMoD3lg,{|| (Iif((nlOpc==3 .Or. nlOpc==4 .Or. nlOpc==2),llRet:=.T.,), _opMoD3lg:End()) } , {|| _opMoD3lg:End()},  ,  )) CENTERED

Return llRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ D1IMP    ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega Array com itens da nota fiscal p/ rotina automatica³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clCodFor = Cod. Fornecedor                                 ³±±
±±³          ³ clLoja   = Loja                                            ³±±
±±³          ³ clNota   = Num. NOta                                       ³±±
±±³          ³ clSerie  = Serie                                           ³±±
±±³          ³ clTab    = Tabela de itens - SDT                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ alRet = array com dados para execucao da rotina automatica ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ExecTela                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function D1Imp(clCodFor,clLoja,clNota,clSerie,clTab)

	Local alItens	 := {}
	Local alRet     := {}
	Local nlQtd     := 0
	Local nlCont	 := 0
	Local alBaseImp := {}
	Local alAliqImp := {}

	Local alTamSDV  := {TAMSX3("DV_FORNEC")[1],TAMSX3("DV_LOJA")[1],TAMSX3("DV_DOC")[1],TAMSX3("DV_SERIE")[1],TAMSX3("DV_PROD")[1],TAMSX3("DV_NUMPED")[1],TAMSX3("DV_ITEMPC")[1]}
	Local nlPosProd := Ascan(aHeader,{|x|Alltrim(X[2])=="DT_PRODFOR"})
	Local nlPosItem := Ascan(aHeader,{|x|Alltrim(X[2])=="DT_ITEM"})

	For nlCont:=1 to Len(aCols)
		dbSelectarea(clTab)
		dbOrderNickName("_SDTPFITEM")
		&(clTab)->(dbGoTop())
		alBaseImp := {}
		alAliqImp := {}
		//MsgAlert(FWxFilial(clTab)+"-"+clCodFor+"-"+clLoja+"-"+clNota+"-"+clSerie+"-"+aCols[nlCont,nlPosProd]+"-"+aCols[nlCont,nlPosItem]+"-")
		If dbSeek(FWxFilial(clTab)+clCodFor+clLoja+clNota+clSerie+aCols[nlCont,nlPosProd]+aCols[nlCont,nlPosItem])
			nlQtd := SDT->DT_QUANT

			dbSelectArea("SDV")
			SDV->(dbSetOrder(1))
			SDV->(dbGoTop())
			//MsgAlert(dbSeek(FWxFilial("SDV")+PadR(clCodFor,alTamSDV[1])+PadR(clLoja,alTamSDV[2])+PadR(clNota,alTamSDV[3])+PadR(clSerie,alTamSDV[4])+PadR(SDT->DT_COD,alTamSDV[5])+PadR(SDT->DT_PEDIDO,alTamSDV[6])+PadR(SDT->DT_ITEMPC,alTamSDV[7])+Str(SDT->DT_QUANT,18,7)))
			If dbSeek(FWxFilial("SDV")+PadR(clCodFor,alTamSDV[1])+PadR(clLoja,alTamSDV[2])+PadR(clNota,alTamSDV[3])+PadR(clSerie,alTamSDV[4])+PadR(SDT->DT_COD,alTamSDV[5])+PadR(SDT->DT_PEDIDO,alTamSDV[6])+PadR(SDT->DT_ITEMPC,alTamSDV[7])+Str(SDT->DT_QUANT,18,7))
				While SDV->(!EOF()) .AND. (SDV->DV_FILIAL==SDT->DT_FILIAL) .AND. (SDV->DV_FORNEC==SDT->DT_FORNEC) .AND. (SDV->DV_LOJA==SDT->DT_LOJA) .AND. (SDV->DV_DOC==SDT->DT_DOC) .AND. (SDV->DV_SERIE==SDT->DT_SERIE) .AND. (SDV->DV_PROD==SDT->DT_COD) .AND. (SDV->DV_NUMPED==SDT->DT_PEDIDO) .AND. (SDV->DV_ITEMPC==SDT->DT_ITEMPC) .AND. (Str(SDV->DV_QUANT,18,7)==Str(SDT->DT_QUANT,18,7))
					//MsgAlert("Item SDT => "+SDT->DT_ITEM+"-"+SDT->DT_COD+chr(13)+"Item SDV => "+SDV->DV_ITEMPC+"-"+SDV->DV_PROD+chr(13)+"Item Calc => "+StrZero(Len(alRet)+1,4))
					alItens:={}
					aAdd(alItens,{"D1_FILIAL"   , SDT->DT_FILIAL          		,NIL})  // INF. PED.
					aAdd(alItens,{"D1_ITEM"     , StrZero(Len(alRet)+1,4) 		,NIL})
					aAdd(alItens,{"D1_COD"      , SDT->DT_COD             		,NIL})
					aAdd(alItens,{"D1_PEDIDO" 	, SDV->DV_NUMPED       			,NIL})
					aAdd(alItens,{"D1_ITEMPC"   , SDV->DV_ITEMPC      	   		,NIL})
					aAdd(alItens,{"D1_QUANT"    , SDV->DV_QUANT           		,NIL})
					aAdd(alItens,{"D1_VUNIT"    , SDT->DT_VUNIT           		,NIL})
					aAdd(alItens,{"D1_TOTAL"    , (SDT->DT_VUNIT*SDV->DV_QUANT) ,NIL})
					aAdd(alItens,{"D1_FORNECE"  , SDT->DT_FORNEC          		,NIL})
					aAdd(alItens,{"D1_LOJA"     , SDT->DT_LOJA            		,NIL})
					aAdd(alItens,{"D1_DOC"      , SDT->DT_DOC             		,NIL})
					aAdd(alItens,{"D1_SERIE"    , SDT->DT_SERIE           		,NIL})
					aAdd(alItens,{"D1_TEMMERC"  , SDT->DT_TEMMERC           	,NIL})
					aAdd(alItens,{"D1_MOTDEV"   , SDT->DT_MOTDEV1           	,NIL})				
					//aAdd(alItens,{"D1_ICMSRET"  , SDT->DT_XMLICST           	,NIL})				
					//aAdd(alItens,{"D1_ALIQSOL"  , SDT->DT_XALICST           	,NIL})				
					aAdd(alRet,alItens)
					nlQtd := (nlQtd - SDV->DV_QUANT)
					SDV->(dbSkip())
				EndDo
			EndIf

			If nlQtd > 0
				alItens:={}
				aAdd(alItens,{"D1_FILIAL"   , SDT->DT_FILIAL          ,NIL})  // INF. PED.
				aAdd(alItens,{"D1_ITEM"     , StrZero(Len(alRet)+1,4) ,NIL})
				aAdd(alItens,{"D1_COD"      , SDT->DT_COD             ,NIL})
				aAdd(alItens,{"D1_QUANT"    , nlQtd                   ,NIL})
				aAdd(alItens,{"D1_VUNIT"    , SDT->DT_VUNIT           ,NIL})
				aAdd(alItens,{"D1_TOTAL"    , (SDT->DT_VUNIT*nlQtd)   ,NIL})
				aAdd(alItens,{"D1_FORNECE"  , SDT->DT_FORNEC          ,NIL})
				aAdd(alItens,{"D1_LOJA"     , SDT->DT_LOJA            ,NIL})
				aAdd(alItens,{"D1_DOC"      , SDT->DT_DOC             ,NIL})
				aAdd(alItens,{"D1_SERIE"    , SDT->DT_SERIE           ,NIL})			
				aAdd(alItens,{"D1_TEMMERC"  , SDT->DT_TEMMERC     	  ,NIL})
				aAdd(alItens,{"D1_MOTDEV"   , SDT->DT_MOTDEV1     	  ,NIL})			
				//aAdd(alItens,{"D1_ICMSRET"  , SDT->DT_XMLICST         ,NIL})				
				//aAdd(alItens,{"D1_ALIQSOL"  , SDT->DT_XALICST         ,NIL})				
				aAdd(alRet,alItens)
			EndIf
		EndIf
	Next nlCont

Return alRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ F1IMP    ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega Array com cabecalho da nota fiscal p/ rotina autom.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clCodFor = Cod. Fornecedor                                 ³±±
±±³          ³ clLoja   = Loja                                            ³±±
±±³          ³ clNota   = Num. NOta                                       ³±±
±±³          ³ clSerie  = Serie                                           ³±±
±±³          ³ clTab    = Tabela de cabecalho - SDS                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ alCabec = array com os dados para execucao da rotina autom.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ExecTela                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function F1Imp(clCodFor,clLoja,clNota,clSerie,clTab)

	Local alCabec := {}

	// Recupera o Environment utilizado para verificar se faz validações ou não
	cEnv := Upper(GetEnvServer())

	dbSelectArea(clTab)
	dbSetOrder(1)
	&(clTab)->(dbGoTop())
	If dbSeek(FWxFilial(clTab)+clNota+clSerie+clCodFor+clLoja)
		aAdd(alCabec,{"F1_FILIAL"      ,SDS->DS_FILIAL        ,Nil})
		aAdd(alCabec,{"F1_TIPO"        ,SDS->DS_TIPO          ,Nil})
		aAdd(alCabec,{"F1_FORMUL"      ,SDS->DS_FORMUL        ,Nil})
		aAdd(alCabec,{"F1_DOC"         ,SDS->DS_DOC           ,Nil})
		aAdd(alCabec,{"F1_SERIE"       ,SDS->DS_SERIE         ,Nil})
		aAdd(alCabec,{"F1_EMISSAO"     ,SDS->DS_EMISSA		  ,Nil})
		aAdd(alCabec,{"F1_FORNECE"     ,SDS->DS_FORNEC        ,Nil})
		aAdd(alCabec,{"F1_LOJA"        ,SDS->DS_LOJA          ,Nil})
		aAdd(alCabec,{"F1_ESPECIE"     ,SDS->DS_ESPECI        ,Nil})
		aAdd(alCabec,{"F1_DTDIGIT"     ,SDS->DS_DATAIMP		  ,Nil})
		aAdd(alCabec,{"F1_EST"         ,SDS->DS_EST			  ,Nil})
		aAdd(alCabec,{"F1_HORA"        ,SubStr(Time(),1,5)	  ,Nil})
		//aAdd(alCabec,{"F1_INDPRES"     ,"0"					  ,Nil})
		//aAdd(alCabec,{"F1_CODA1U"      ,""					  ,Nil})
		aAdd(alCabec,{"F1_CHVNFE"      ,SDS->DS_CHAVENF		  ,Nil})
	EndIf
	&(clTab)->(dbCloseArea())

Return alCabec


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³XMLRETNOME³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Chamada no inicializador padrão do campo DS_NOME (virtual) ³±±
±±³          ³ posiciona na tabela correta (Fornec/Cliente) e retorna nome³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clCodFor = Cod. Fornecedor                                 ³±±
±±³          ³ clLoja   = Loja                                            ³±±
±±³          ³ clTipo   = Tipo da Nota (NORMAL/DEVOLUCAO/BENEFICIAMNETO)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ clNomeRet = Nome do fornecedor ou cliente                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function XmlRetNome(clForCli,clLoja,clTipo)
	Local clNomeRet := ""
	Local clAlias   := Iif((AllTrim(clTipo)<>"N"),"SA1","SA2")

	clNomeRet := POSICIONE(clAlias,1,(FWXFILIAL(clAlias)+clForCli+clLoja),(Right(clAlias,2)+"_NOME") )

Return clNomeRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GPRDxPRDF ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Grava relacinamento Produto x Produto do Pornecedor        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Cod. Fornecedor|Cliente                            ³±±
±±³          ³ ExpC2 = Loja Fornecedor|Cliente                            ³±±
±±³          ³ ExpC3 = Nota Fiscal                                        ³±±
±±³          ³ ExpC4 = Serie da Nota                                      ³±±
±±³          ³ ExpC5 = Produto Clinte/Fornecedor                          ³±±
±±³          ³ ExpC6 = Cod. Produto                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SelePed, RPrdxPrdF, ProcPCxNFe, AtuSDT                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GPrdxPrdF(clCodForCli, clLoja, clNota, clSerie, cProdForCli, cProdEmp, cTipo, cItem)
	Local aArea	:= GetArea()

	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// | GRAVA RELACIONAMENTO PARA PROXIMA IMPORTACAO |
	// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SDT")
	SDT->(dbOrderNickName("_SDTPFITEM"))
	If SDT->(dbSeek(FWxFilial("SDT")+clCodForCli+clLoja+clNota+clSerie+cProdForCli+cItem))
		If RecLock("SDT",.F.)
			Replace DT_COD With cProdEmp
			SDT->(MsUnLock())
			If !Empty(SDT->DT_COD)
				// Grava Amarração Produto X Fornecedor ou Produto X Cliente dependendo do tipo da nota
				dbSelectArea("SDS")
				dbSetOrder(1)
				DbSeek(FWxFilial("SDS")+SDT->DT_DOC+SDT->DT_SERIE+SDT->DT_FORNEC+SDT->DT_LOJA)
				If Found()
					_cTpNota := SDS->DS_TIPO
				Else
					_cTpNota := "N"
				Endif

				If _cTpNota == "N"
					dbSelectArea("SA5")
					dbSeek(FWxFilial("SA5")+SDT->DT_FORNEC+SDT->DT_LOJA+SDT->DT_COD)
					If !Found()
						RecLock("SA5",.T.)
						A5_FILIAL 	:= FWxFilial("SA5")
						A5_FORNECE 	:= SDT->DT_FORNEC
						A5_LOJA	 	:= SDT->DT_LOJA
						A5_NOMEFOR	:= Posicione("SA2",1,FWxFilial("SA2")+SDT->DT_FORNEC+SDT->DT_LOJA,"A2_NOME")
						A5_CODPRF	:= SDT->DT_PRODFOR
						A5_PRODUTO  := SDT->DT_COD
						A5_NOMPROD  := Posicione("SB1",1,FWxFilial("SB1")+SDT->DT_COD,"B1_DESC")
						MsUnlock()
					Endif
				Else
					dbSelectArea("SA7")
					dbSeek(FWxFilial("SA7")+SDT->DT_FORNEC+SDT->DT_LOJA+SDT->DT_COD)
					If !Found()
						RecLock("SA7",.T.)
						A7_FILIAL 	:= FWxFilial("SA7")
						A7_CLIENTE 	:= SDT->DT_FORNEC
						A7_LOJA 		:= SDT->DT_LOJA
						A7_CODCLI   := SDT->DT_PRODFOR
						A7_PRODUTO  := SDT->DT_COD
						A7_DESCCLI  := SDT->DT_DESCFOR
						MsUnlock()
					Endif
				Endif
			EndIf
		Endif
	EndIf

	RestArea( aArea )

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PRDxFORCLI³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida se existe amarracão entre Produto x Fornec./Cliente ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Cod. Fornecedor|Cliente                            ³±±
±±³          ³ ExpC2 = Loja Fornecedor|Cliente                            ³±±
±±³          ³ ExpC3 = Cod. Produto                                       ³±±
±±³          ³ ExpC4 = Tipo da Nota                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cProdEmp = Produto relacionado ao Forncedor/Cliente        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ProcPCxNFe                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrdxForCli(clCodForCli, clLoja, clCodProd,clTipo)
	Local cWAlias 	:= ""
	Local cProdEmp	:= ""
	Local nOrd		:= 1

	If clTipo<>"N"
		cWAlias := "SA7"
		nOrd := RetOrder("SA7", "A7_FILIAL+A7_CLIENTE+A7_LOJA+A7_PRODUTO")
	Else
		cWAlias := "SA5"
		nOrd	:= RetOrder("SA5", "A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO")
	EndIf

	DbSelectArea(cWAlias)
	(cWAlias)->(DbSetOrder( nOrd ))

	If ( (cWAlias)->(dbSeek(FWxFilial(cWAlias)+clCodForCli+clLoja+clCodProd )) )
		If cWAlias == "SA5"
			cProdEmp := SA5->A5_PRODUTO
		Else
			cProdEmp := SA7->A7_PRODUTO
		EndIf
	EndIf

Return cProdEmp


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PESQCGC  ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Pesquisa no SM0 para qual empresa/filial é destinado a NFe ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clCGC = CNPJ informado no arquivo XML                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ alRet = Array de 2 posicoes                                ³±±
±±³          ³         [ 1 ] = COD. EMPRESA                               ³±±
±±³          ³         [ 2 ] = COD. FILIAL                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PesqCGC(clCGC)
	Local alAreaSM0
	Local aCodEmpFil := {}

	dbSelectArea("SM0")
	alAreaSM0 := SM0->(GetArea())
	dbGoTop()
	Do While !eof() .And. !Empty(clCGC)
		If SM0->M0_CGC = clCGC
			aAdd(aCodEmpFil, {SM0->M0_CODIGO, SM0->M0_CODFIL})
			exit
		Endif
		dbSkip()
	Enddo

	RestArea(alAreaSM0)

Return aCodEmpFil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ READXML  ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para leitura de XMLs de NFe no diretorio de download³±±
±±³          ³ e geracao da pre-nota de entrada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ReadXML(cFile,lJob)

	Local cProduto	 := space(15) //CriaVar("B1_COD")
	Local cXML      := ""
	Local cError    := ""
	Local cWarning  := ""
	Local cCGC	    := ""
	Local cTipoNF   := ""
	Local cTabEmit  := ""
	Local cDoc	    := ""
	Local cSerie    := ""
	Local cCodigo   := ""
	Local cLoja	    := ""
	Local cCampo1   := ""
	Local cCampo2   := ""
	Local cCampo3   := ""
	Local cCampo4   := ""
	Local cCampo5   := ""
	Local cQuery    := ""
	Local cNFECFAP  := SuperGetMV("MV_NFECFAP",.F.,"")
	Local lFound    := .F.
	Local lProces   := .T.
	Local lCFOPEsp  := .T.
	Local nX		    := 0
	Local nY		    := 0
	Local oFullXML  := NIL
	Local oAuxXML   := NIL
	Local oXML	    := NIL
	Local aItens    := {}
	Local aHeadSDS  := {}
	Local aItemSDT  := {}
	Local aItemZDT  := {}
	Local oDlg
	Local cProduto2 := space(15) 			//Não deixo mais com o CriaVar pois estava considerando o codigo de criacao do produto na sb1
	/*
	Local lFCPAnt		:= SDT->(FieldPos("DT_XBFCPAN")) > 0 .And. SDT->(FieldPos("DT_XAFCPAN")) > 0 .And. SDT->(FieldPos("DT_XVFCPAN")) > 0
	Local lFCPST		:= SDT->(FieldPos("DT_XBFCPST")) > 0 .And. SDT->(FieldPos("DT_XAFCPST")) > 0 .And. SDT->(FieldPos("DT_XVFCPST")) > 0
	Local lICMSSTRet	:= SDT->(FieldPos("DT_ICMNDES")) > 0 .And. SDT->(FieldPos("DT_BASNDES")) > 0 .And. SDT->(FieldPos("DT_ALQNDES")) > 0
	Local lDTICMDeson	:= SDT->(FieldPos("DT_ICMDES")) > 0 .And. SDT->(FieldPos("DT_ICMDEMT")) > 0
	Local nICMDeson		:= 0
	Local cICMDesMot	:= ""
	Local cClasFis		:= ""
	Local cOrigClas		:= ""
	Local cCSTClas		:= ""
	Local aClasFis		:= {}
	Local nClasFis		:= 0
	Local cMVClasFis	:= SuperGetMV("MV_COLCFIS",.F.,"")
	Local lDTClasFis	:= SDT->(FieldPos("DT_CLASFIS")) > 0
	*/
	Private cEmailAdm   := GETMV("MV_WFADMIN")			        			// Endereco eletronico do administrador do workflow. Este recebera todas as notificacoes ocorridas.
	Private cEmailErro  := "contabilidade2@frigorificosilva.com.br" 		// Indica a conta de e-mail para envio de erros ocorridos
	Private cEmailFrom  := "info@frigorificosilva.com.br"					// Indica a conta de e-mail do campo FROM no envio dos e-mails internos de processamento dos arquivos XML
	Private lMsErroAuto := .F.

	Default lJob := .T.

	If !File(cStartPath +cFile)
		If lJob
		Else
			Aviso("Error","Arquivo " +cFile +" inexistente.",{"OK"},2,"ReadXML")
		EndIf
		lProces := .F.
	Else
		cXML := MemoRead(cStartPath +cFile)
		//-- Nao processa conhecimentos de transporte
		If "</CTE>" $ Upper(cXML)
			FErase(cStartPath+cFile)
			lProces := .F.
		EndIf
		
		
		if lProces
			If "</CANCNFE>" $ Upper(cXML) .OR. "</CANCCTE>" $ Upper(cXML)
				FErase(cStartPath+cFile)
				lProces := .F.
			EndIf
		Endif

		//-- Nao processa XML de outra empresa/filial
		If lProces .And. !(Substr(SM0->M0_CGC,0,8) $ cXML)
			lProces := .F.
		EndIf

	EndIf

	If lProces
		oFullXML := XmlParserFile(cStartPath + cFile,"_",@cError,@cWarning)

		//-- Erro na sintaxe do XML
		If Empty(oFullXML) .Or. !Empty(cError)
			If lJob
			Else
				Aviso("Erro",cError,{"OK"},2,"ReadXML")
			EndIf

			//-- Move arquivo para pasta dos erros
			cArqTXT := cStartPath+cFile
			//copia o arquivo antes da transacao
			cNomNovArq  := cStartError+cFile
			If MsErase(cNomNovArq)
				__CopyFile(cArqTXT,cNomNovArq)
				FErase(cStartPath+cFile)
			EndIf
			lProces := .F.
		Else
			oXML    := oFullXML
			oAuxXML := oXML

			//-- Resgata o no inicial da NF-e
			While !lFound
				oAuxXML := XmlChildEx(oAuxXML,"_NFE")
				If !(lFound := oAuxXML # NIL)
					For nX := 1 To XmlChildCount(oXML)
						oAuxXML  := XmlChildEx(XmlGetchild(oXML,nX),"_NFE")
						lFound := oAuxXML:_InfNfe # Nil
						If lFound
							oXML := oAuxXML
							Exit
						EndIf
					Next nX
				EndIf

				If lFound
					oXML := oAuxXML
					Exit
				EndIf
			EndDo
			//VERIFICAR PARA QUAL FILIAL SERA IMPORTADO
			cCNPJInf := oXML:_INFNFE:_DEST:_CNPJ:TEXT
			
			
		
			If lJob
				dbSelectArea("SM0")
				dbSetOrder(1)
				dbGoTop()
				While !Eof()
					If M0_CGC == cCNPJInf
						cFilAnt := M0_CODFIL
						cEmpAnt := M0_CODIGO
						Exit
					EndIf
					dbSkip()
				End
			Else
				If SM0->M0_CGC # cCNPJInf
					MsgStop("Este arquivo não pertence a esta Filial!","Atenção - PMXML003")
					Return
				EndIf
			EndIf

			//-- Verifica se este ID ja foi processado
			DbSelectArea("SDS")
			SDS->(DbSetOrder(2))
			lFound := SDS->(DbSeek(FWxFilial("SDS")+Right(AllTrim(oXML:_InfNfe:_Id:Text),44)))//Filial + Chave de acesso

			//PEGA A IDENT
			If lJob
				cIdEnt := U_WSAT01GetIdEnt()
			EndIf

			//VERIFICA O STATUS NA RECEITA FEDERAL E EM CASO DE REJEICAO NAO IMPORTA
			aStatus := U_CoNFeChv(Right(AllTrim(oXML:_InfNfe:_Id:Text),44),cIdEnt,lJob)

			/*/
			If !aStatus[1]
			If !lJob
			MsgStop("NFe com problemas, rotina Cancelada!","PMXML003")
			Return
			Else
			//ENVIA E-MAIL
			U_EnvMail1(cEmailFrom,cEmailErro,'',aStatus[2],' Importacao XML NFe entrada com Erros' ,"")
			Return
			EndIf
			EndIf
			/*/

			If lFound
				If lJob
					cEmailErro :="ReadXML Error:"+ENTER+ENTER
					cEmailErro +="Arquivo: " +cFile+ENTER+ENTER
					cEmailErro +="Ocorrencia: ID de NFe ja registrado na NF " +SDS->(DS_DOC+"/"+DS_SERIE)+" do fornecedor " +SDS->(DS_FORNEC+" / "+DS_LOJA) +"."+ENTER

					//ENVIA E-MAIL
					U_EnvMail1(cEmailFrom,cEmailErro,'',aStatus[2],' Importacao XML NFe entrada com Erros' ,"")

				Else
					Aviso("Erro","ID de NFe ja registrado na NF " +SDS->(DS_DOC+"/"+DS_SERIE)+" do fornecedor " +SDS->(DS_FORNEC+"/"+DS_LOJA) +".",{"OK"},2,"ReadXML")
				EndIf

				//-- Move arquivo para pasta dos erros
				cArqTXT := cStartPath+cFile
				//copia o arquivo antes da transacao
				cNomNovArq  := cStartError+cFile
				If MsErase(cNomNovArq)
					__CopyFile(cArqTXT,cNomNovArq)
					FErase(cStartPath+cFile)
				EndIf

				lProces := .F.
			EndIf

			//-- Se ID valido
			//-- Extrai tag _InfNfe:_Det
			If lProces
				If ValType(oXML:_InfNfe:_Det) == "O"
					aItens := {oXML:_InfNfe:_Det}
				ElseIf ValType(oXML:_InfNfe:_Det) == "U"
					If lJob
						cEmailErro :="ReadXML Error:"+ENTER+ENTER
						cEmailErro +="Arquivo: " +cFile+ENTER+ENTER
						cEmailErro +="Ocorrencia: tag _InfNfe:_Det nao localizada."+ENTER

						//ENVIA E-MAIL
						U_EnvMail1(cEmailFrom,cEmailErro,'',aStatus[2],' Importacao XML NFe entrada com Erros' ,"")

					Else
						Aviso("Erro","Tag _InfNfe:_Det nao localizada.",{"OK"},2,"ReadXML")
					EndIf

					//-- Move arquivo para pasta dos erros
					cArqTXT := cStartPath+cFile
					//copia o arquivo antes da transacao
					cNomNovArq  := cStartError+cFile
					If MsErase(cNomNovArq)
						__CopyFile(cArqTXT,cNomNovArq)
						FErase(cStartPath+cFile)
					EndIf

					lProces := .F.
				Else
					aItens := oXML:_InfNfe:_Det
				EndIf
			EndIf

			//-- Se tag _InfNfe:_Det valida
			//-- Extrai CGC do fornecedor/cliente
			If lProces
				//If AllTrim(oXML:_InfNfe:_Ide:_finNFe:Text) == "1"
				//	cTipoNF := "N"
				//ElseIf AllTrim(oXML:_InfNfe:_Ide:_finNFe:Text) == "2"
				//	cTipoNF := "D"
				//Else
				//	cTipoNF := "B"
				//EndIf

				//Tratamento notas de devolução pela CFOP partindo da premissa que a nota é do tipo normal e que se existir um item com CFOP de devolução a nota inteira é de devolução
				cTipoNF := "N"
				For nX := 1 To Len(aItens)
					_CfopDev := _GetParam()
					If Alltrim(aItens[nX]:_PROD:_CFOP:TEXT) $ _CfopDev
						cTipoNF := "D"
					EndIf
				Next nX
				
				// Problema de validação do _CNPJ quando não existe
				//alert(ValType(oXML:_INFNFE:_EMIT:_CNPJ))
				//alert(ValType(oXML:_INFNFE:_EMIT:_CPF))
				
				If ValType(oXML:_INFNFE:_EMIT:_CNPJ) <> "U"
					cCGC := oXML:_INFNFE:_EMIT:_CNPJ:Text
				ElseIf ValType(oXML:_INFNFE:_EMIT:_CPF) <> "U"
					cCGC := oXML:_INFNFE:_EMIT:_CPF:Text
				Else
					If lJob
						cEmailErro :="ReadXML Error:"+ENTER+ENTER
						cEmailErro +="Arquivo: " +cFile+ENTER+ENTER
						cEmailErro +="Ocorrencia: tag _CNPJ/_CPF ausente."+ENTER

						//ENVIA E-MAIL
						U_EnvMail1(cEmailFrom,cEmailErro,'',aStatus[2],' Importacao XML NFe entrada com Erros' ,"")

					Else
						Aviso("Erro","Tag _CNPJ/_CPF ausente.",{"OK"},2,"ReadXML")
					EndIf

					//-- Move arquivo para pasta dos erros
					cArqTXT := cStartPath+cFile
					//copia o arquivo antes da transacao
					cNomNovArq  := cStartError+cFile
					If MsErase(cNomNovArq)
						__CopyFile(cArqTXT,cNomNovArq)
						FErase(cStartPath+cFile)
					EndIf

					lProces := .F.
				EndIf
			EndIf

			//-- Se tag CGC valida
			//-- Busca fornecedor/cliente na base

			If lProces
				cTabEmit := If(cTipoNF == "N","SA2","SA1")
				(cTabEmit)->(dbSetOrder(3))
				If (cTabEmit)->(dbSeek(FWxFilial(cTabEmit)+cCGC))

					cCodigo := (cTabEmit)->&(Substr(cTabEmit,2,2)+"_COD")
					cLoja   := (cTabEmit)->&(Substr(cTabEmit,2,2)+"_LOJA")
				Else
					If lJob
						cEmailErro :="ReadXML Error:"+ENTER+ENTER
						cEmailErro +="Arquivo: " +cFile+ENTER+ENTER
						cEmailErro +="Ocorrencia: " +If(cTipoNF == "N","fornecedor","cliente") +" de CNJP/CPF numero " +cCGC +" inexistente na base."+ENTER

						//ENVIA E-MAIL
						U_EnvMail1(cEmailFrom,cEmailErro,'',aStatus[2],' Importacao XML NFe entrada com Erros' ,"")					
					Else				
						Aviso("Erro",If(cTipoNF == "N","Fornecedor","Cliente") +" de CNJP/CPF numero " +cCGC +" inexistente na base.",{"OK"},2,"ReadXML")
					EndIf

					//-- Move arquivo para pasta dos erros
					cArqTXT := cStartPath+cFile
					//copia o arquivo antes da transacao
					cNomNovArq  := cStartError+cFile
					If MsErase(cNomNovArq)
						__CopyFile(cArqTXT,cNomNovArq)
						FErase(cStartPath+cFile)
					EndIf

					lProces := .F.
				EndIf
			EndIf

			//-- Se fornecedor/cliente validado
			//-- Processa cabeçalho e itens
			If lProces
				cCampo1 := If(cTipoNF # "N","A7_PRODUTO","A5_PRODUTO")
				cCampo2 := If(cTipoNF # "N","A7_FILIAL","A5_FILIAL")
				cCampo3 := If(cTipoNF # "N","A7_CLIENTE","A5_FORNECE")
				cCampo4 := If(cTipoNF # "N","A7_LOJA","A5_LOJA")
				cCampo5 := If(cTipoNF # "N","A7_CODCLI","A5_CODPRF")

				cDoc    := StrZero(Val(AllTrim(oXML:_InfNfe:_Ide:_nNF:Text)),TamSx3("F1_DOC")[1])
				cSerie  := PadR(oXML:_InfNfe:_Ide:_Serie:Text,TamSX3("F1_SERIE")[1])

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava os dados do cabeçalho - SDS                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//Acrescentado por Fabian Maurer em 16/11/14 as variaveis _cVersao(Para verificar qual versao de xml esta recebendo "2.00 ou 3.10"
				// e a variavel _dEmissa(que identifica conforme a versão qual tag de emissao deve pegar "DhEmis ou DEmis"
				_cVersao := Alltrim(oXML:_InfNfe:_versao:text)
				//_dEmissa := iif(_cVersao = "3.10",StoD(StrTran(AllTrim(oXML:_InfNfe:_Ide:_DhEmi:Text),"-","")),StoD(StrTran(AllTrim(oXML:_InfNfe:_Ide:_DEmi:Text),"-","")))
				_dEmissa := iif(_cVersao = "3.10",StoD(StrTran(AllTrim(oXML:_InfNfe:_Ide:_DhEmi:Text),"-","")),StoD(StrTran(AllTrim(oXML:_InfNfe:_Ide:_DhEmi:Text),"-","")))

				DbSelectArea("SDS")
				AADD(aHeadSDS,{{"DS_FILIAL"	,FWxFilial("SDS")																	    			 	 },; //Filial
				{"DS_CNPJ"		,cCGC																										 },; //CGC
				{"DS_DOC"		,cDoc 																									 },; //Numero do Documento
				{"DS_SERIE"		,cSerie 																									 },; //Serie
				{"DS_FORNEC"	,cCodigo																									 },; //Fornecedor
				{"DS_LOJA"		,cLoja 																									 },; //Loja do Fornecedor
				{"DS_EMISSA"	,_dEmissa   		 				 },; //Data de Emissão
				{"DS_EST"		,oXML:_INFNFE:_EMIT:_ENDEREMIT:_UF:TEXT														 },; //Estado de emissao da NF
				{"DS_TIPO"		,cTipoNF 																						 		 },; //Tipo da Nota
				{"DS_FORMUL"	,"N" 																								 		 },; //Formulario proprio
				{"DS_DTDIGI"	,dDataBase 																						 		 },; //Dtda de digitaçao
				{"DS_ESPECI"	,"SPED"																		  							 },; //Especie
				{"DS_ARQUIVO"	,AllTrim(cFile)																 		 	   		 },; //Arquivo importado
				{"DS_STATUS"	,"Q"																				   			   	 },; //Status
				{"DS_CHAVENF"	,Iif(ValType("opNF:_InfNfe:_Id")<>"U",Right(AllTrim(oXML:_InfNfe:_Id:Text),44),"")},; //Chave de Acesso da NF
				{"DS_VERSAO"	,Iif(ValType("opNF:_InfNfe:_versao")<>"U",oXML:_InfNfe:_versao:text ,"")			 },; //Versão
				{"DS_USERIMP"	,Iif(!Empty(cUserName),cUserName,"JOB" ) 														 },; //Usuario na importacao
				{"DS_DATAIMP"	,dDataBase																								 },; //Data importacao do XML
				{"DS_HORAIMP"	,SubStr(Time(),1,5)																					 }}) //Hora importacao XML

				For nX := 1 To Len(aItens)
					cProduto := AllTrim(aItens[nX]:_Prod:_cProd:Text)

					cQuery := "SELECT " +cCampo1 +" FROM " +RetSqlName(If(cTipoNF # "N","SA7","SA5"))
					cQuery += " WHERE D_E_L_E_T_ <> '*' AND "
					cQuery += cCampo2 +" = '" +FWxFilial(If(cTipoNF # "N","SA7","SA5")) +"' AND "
					cQuery += cCampo3 +" = '" +cCodigo +"' AND "
					cQuery += cCampo4 +" = '" +cLoja +"' AND "
					cQuery += cCampo5 +" = '" +cProduto +"'"

					If Select("TRB") > 0
						TRB->(dbCloseArea())
					EndIf

					TcQuery cQuery new Alias "TRB"

					If !TRB->(EOF())
						cProduto2 := TRB->(&cCampo1)
					Else
						If lJob
						Else
							Aviso("Erro",If(cTipoNF == "N","Fornecedor ","Cliente ") +cCodigo +"/" +cLoja+" sem cadastro de Produto X " +If(cTipoNF == "N","Fornecedor","Cliente")+" para o código " +cProduto +".",{"OK"},2,"ReadXML")

							If MsgYesNo('Atencao Produto '+cProduto+' Não Encontrado na Amarraçâo Prod. x Fornecedor, Deseja incluir?' )
								cProduto2 := cProduto+Space(15-Len(cProduto))
								@ 65,153 To 229,435 Dialog oDlg Title OemToAnsi("Inclusão Amarracao")
								@ 9,9 Say OemToAnsi("Produto") Size 99,8
								@ 28,9 Get cProduto2 Picture "@!" F3 "SB1" VALID Existcpo("SB1",cProduto2) Size 59,10
								@ 62,39 BMPBUTTON TYPE 1 ACTION Close(oDlg)

								Activate Dialog oDlg Centered

								If !Empty(cProduto2)
									If cTipoNF # "N"
										dbSelectArea("SA7")
										RecLock("SA7",.T.)
										A7_FILIAL 	:= FWxFilial("SA7")
										A7_CLIENTE 	:= cCodigo //codigo do cliente
										A7_LOJA 		:= cLoja   //loja do cliente
										A7_CODCLI   := cProduto //codigo do produto do cliente
										A7_PRODUTO  := cProduto2 //produto do frigorifico
										MsUnlock()
									Else
										dbSelectArea("SA5")
										RecLock("SA5",.T.)
										A5_FILIAL 	:= FWxFilial("SA5")
										A5_FORNECE 	:= cCodigo
										A5_LOJA	 	:= cLoja
										A5_NOME		:= Posicione("SA2",1,FWxFilial("SA2")+cCodigo+cLoja,"A2_NOME")
										A5_CODPRF	:= cProduto
										A5_PRODUTO  := cProduto2
										A5_NOMPROD  := Posicione("SB1",1,FWxFilial("SB1")+cProduto2,"B1_DESC")
										MsUnlock()
									Endif
								EndIf
							Else
								//-- Move arquivo para pasta dos erros
								cArqTXT := cStartPath+cFile
								//copia o arquivo antes da transacao
								cNomNovArq  := cStartError+cFile
								If MsErase(cNomNovArq)
									__CopyFile(cArqTXT,cNomNovArq)
									FErase(cStartPath+cFile)
								EndIf

								lProces := .F.
								Exit
							EndIf
						EndIf
					EndIf

					TRB->(dbCloseArea())


					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Tratamento para Segunda Unidade de Medida                             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
					/* 	Autor : Flávio Bohrer Flôres -- Data - 28/03/19 
						Tratamento para quando vem quantidade de Ítens ou Valor unitário zerado do xml do fornecedor
					*/
					if  Val(aItens[nX]:_Prod:_vUnCom:Text) = 0 .or. Val(aItens[nX]:_Prod:_qCom:Text) = 0
											
						msgbox('Quantidade ou unidade zeradas, Entre em contato com quem enviou o XML','OPERACAO NEGADA','STOP')
						Return
						
					else
					
						_nQuant := Round(Val(aItens[nX]:_Prod:_qCom:Text),TamSX3("DT_QUANT")[2])
						_nVUnit := Round(Val(aItens[nX]:_Prod:_vUnCom:Text),TamSX3("C7_PRECO")[2])
						
					endif 
								
					
						
					If cTipoNF == "N"
						SA5->(DBSetOrder(1))
						If SA5->(DbSeek(FWxFilial("SA5")+Padr(cCodigo,6)+Padr(cLoja,2)+Padr(cProduto2,15))) .And. SA5->A5_UMNFE == "2"
							SB1->(DbSetOrder(1))
							If SB1->(DbSeek(FWxFilial("SB1")+Padr(cProduto2,15))) .And. SB1->B1_CONV <> 0 .And. SB1->B1_TIPCONV <> ""
								If SB1->B1_TIPCONV == "M"
									_nQuant := Round(_nQuant/SB1->B1_CONV,TamSX3("DT_QUANT")[2])
									//_nVUnit := Round(Val(aItens[nX]:_Prod:_vProd:Text)/_nQuant,TamSX3("D1_VUNIT")[2])		// Arredondamento anterior (decimais SX3)
									_nVUnit := Round(Val(aItens[nX]:_Prod:_vProd:Text)/_nQuant,5)							// Arredondamento novo (decimais fixo)
								ElseIf SB1->B1_TIPCONV == "D"
									_nQuant := Round(_nQuant*SB1->B1_CONV,TamSX3("DT_QUANT")[2])
									//_nVUnit := Round(Val(aItens[nX]:_Prod:_vProd:Text)/_nQuant,TamSX3("D1_VUNIT")[2])		// Arredondamento anterior (decimais SX3)
									_nVUnit := Round(Val(aItens[nX]:_Prod:_vProd:Text)/_nQuant,5)							// Arredondamento novo (decimais fixo)
								Else
									_nQuant := Round(Val(aItens[nX]:_Prod:_qCom:Text),TamSX3("DT_QUANT")[2])
									_nVUnit := Round(Val(aItens[nX]:_Prod:_vUnCom:Text),TamSX3("C7_PRECO")[2])
								Endif
							Endif
						Endif
					Endif

					/*
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se existe a Tag para os valores de impostos. ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nIPIItem  := 0
					nICMItem  := 0
					nISSItem  := 0    
					nPISItem  := 0
					nCOFItem  := 0
					nIMCSTIt  := 0
					
					nAlIPIItem  := 0
					nAlICMItem  := 0
					nAlISSItem  := 0    
					nAlPISItem  := 0
					nALCOFItem  := 0
					nALIMCSTIt  := 0
					
					nBCFCPSTRet := 0
					nPFCPSTRet  := 0
					nVFCPSTRet  := 0
					
					nBCFCPST := 0
					nPFCPST  := 0
					nVFCPST  := 0
					
					nVICMSSTRet	:= 0 //Valor ICMS ST Ret
					nBICMSSTRet	:= 0 //Base ICMS ST Ret
					nAICMSSTRet	:= 0 //Aliquota ICMS ST Ret
					
					//--IPI
					If ValType(XmlChildEx(aItens[nX]:_Imposto,"_IPI")) == "O"
						If ValType(XmlChildEx(aItens[nX]:_Imposto:_IPI,"_IPITRIB")) == "O"
							// Verifica as TAGS do imposto IPI, pois ha XML que vem somente com 1 das TAGS abaixo.
							If ValType(XmlChildEx(aItens[nX]:_Imposto:_IPI:_IPITrib,"_VIPI")) == "O"
								nIPIItem := Val(aItens[nX]:_Imposto:_IPI:_IPITrib:_vIPI:Text)
							EndIf
							
							If ValType(XmlChildEx(aItens[nX]:_Imposto:_IPI:_IPITrib,"_PIPI")) == "O"
								nAlIPIItem := Val(aItens[nX]:_Imposto:_IPI:_IPITrib:_pIPI:Text)
							EndIf
						Endif
					EndIf

					//--ICMS
					If ValType(XmlChildEx(aItens[nX]:_Imposto,"_ICMS")) == "O"
						If ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS00")) == "O"
							nICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS00,"_VICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS00:_vICMS:Text), 0)
							nAlICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS00,"_PICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS00:_pICMS:Text), 0)
							cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS00,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS00:_Orig:Text,"")
							cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS00,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS00:_CST:Text,"")
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS10")) == "O"
							nICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_VICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS10:_vICMS:Text), 0)
							nAlICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_PICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS10:_pICMS:Text), 0)
							nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_VICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS10:_vICMSST:Text), 0)
							nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_PICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS10:_pICMSST:Text), 0)
							nBCFCPST 	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_VBCFCPST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS10:_VBCFCPST:Text), 0)
							nPFCPST  	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_PFCPST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS10:_PFCPST:Text), 0)
							nVFCPST  	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_VFCPST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS10:_VFCPST:Text), 0)
							cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS10:_Orig:Text,"")
							cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS10,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS10:_CST:Text,"")
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS20")) == "O"
							nICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS20,"_VICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS20:_vICMS:Text), 0)
							nAlICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS20,"_PICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS20:_pICMS:Text), 0)
							cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS20,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS20:_Orig:Text,"")
							cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS20,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS20:_CST:Text,"")
							nICMDeson	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS20,"_VICMSDESON")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS20:_vICMSDeson:Text), 0)
							cICMDesMot	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS20,"_MOTDESICMS")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS20:_motDesICMS:Text,"")
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS30")) == "O"
							nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS30,"_VICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS30:_vICMSST:Text), 0)
							nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS30,"_PICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS30:_pICMSST:Text), 0)
							cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS30,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS30:_Orig:Text,"")
							cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS30,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS30:_CST:Text,"")
							nICMDeson	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS30,"_VICMSDESON")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS30:_vICMSDeson:Text), 0)
							cICMDesMot	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS30,"_MOTDESICMS")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS30:_motDesICMS:Text,"")
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS40")) == "O"
							cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS40,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS40:_Orig:Text,"")
							cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS40,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS40:_CST:Text,"")
							nICMDeson	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS40,"_VICMSDESON")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS40:_vICMSDeson:Text), 0)
							cICMDesMot	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS40,"_MOTDESICMS")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS40:_motDesICMS:Text,"")
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS41")) == "O"
							cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS41,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS41:_Orig:Text,"")
							cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS41,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS41:_CST:Text,"")
							nICMDeson	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS41,"_VICMSDESON")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS41:_vICMSDeson:Text), 0)
							cICMDesMot	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS41,"_MOTDESICMS")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS41:_motDesICMS:Text,"")
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS50")) == "O"
							cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS50,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS50:_Orig:Text,"")
							cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS50,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS50:_CST:Text,"")
							nICMDeson	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS50,"_VICMSDESON")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS50:_vICMSDeson:Text), 0)
							cICMDesMot	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS50,"_MOTDESICMS")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS50:_motDesICMS:Text,"")
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS51")) == "O"
							nICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS51,"_VICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS51:_vICMS:Text), 0)
							nAlICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS51,"_PICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS51:_pICMS:Text), 0)
							cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS51,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS51:_Orig:Text,"")
							cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS51,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS51:_CST:Text,"")
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS60")) == "O"
							nBCFCPSTRet := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS60,"_VBCFCPSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS60:_vBCFCPSTRet:Text), 0)
							nPFCPSTRet  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS60,"_PFCPSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS60:_pFCPSTRet:Text), 0)
							nVFCPSTRet  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS60,"_VFCPSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS60:_vFCPSTRet:Text), 0)
							cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS60,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS60:_Orig:Text,"")
							cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS60,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS60:_CST:Text,"")
							nVICMSSTRet	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS60,"_VICMSSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS60:_vICMSSTRet:Text), 0)
							nBICMSSTRet	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS60,"_VBCSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS60:_vBCSTRet:Text), 0)
							nAICMSSTRet	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS60,"_PST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS60:_pST:Text), 0)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS70")) == "O"
							nICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_VICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS70:_vICMS:Text), 0)
							nAlICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_PICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS70:_pICMS:Text), 0)
							nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_VICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS70:_vICMSST:Text), 0)
							nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_PICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS70:_pICMSST:Text), 0)
							cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS70:_Orig:Text,"")
							cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS70:_CST:Text,"")
							nICMDeson	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_VICMSDESON")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS70:_vICMSDeson:Text), 0)
							cICMDesMot	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS70,"_MOTDESICMS")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS70:_motDesICMS:Text,"")
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMS90")) == "O"
							nICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS90,"_VICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS90:_vICMS:Text), 0)
							nAlICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS90,"_PICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS90:_pICMS:Text), 0)	
							nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS90,"_VICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS90:_vICMSST:Text), 0)
							nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS90,"_PICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS90:_pICMSST:Text), 0)
							cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS90,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS90:_Orig:Text,"")
							cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS90,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS90:_CST:Text,"")
							nICMDeson	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS90,"_VICMSDESON")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMS90:_vICMSDeson:Text), 0)
							cICMDesMot	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMS90,"_MOTDESICMS")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMS90:_motDesICMS:Text,"")
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSPART")) == "O"
							nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSPART,"_VICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSPART:_vICMSST:Text), 0)
							nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSPART,"_PICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSPART:_pICMSST:Text), 0)
							cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSPART,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSPART:_Orig:Text,"")
							cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSPART,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSPART:_CST:Text,"")
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSST")) == "O" 
							nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSST,"_VICMSSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSST:_vICMSSTRet:Text), 0)
							cOrigClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSST,"_ORIG")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSST:_Orig:Text,"")
							cCSTClas	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSST,"_CST")) == "O", aItens[nX]:_Imposto:_ICMS:_ICMSST:_CST:Text,"")
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSSN201")) == "O"	
							nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN201,"_VICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN201:_vICMSST:Text), 0)
							nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN201,"_PICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN201:_pICMSST:Text), 0)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSSN202")) == "O"
							nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN202,"_VICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN202:_vICMSST:Text), 0)
							nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN202,"_PICMSST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN202:_pICMSST:Text), 0)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSSN500")) == "O"	
							nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN500,"_VICMSSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN500:_vICMSSTRet:Text), 0)
							nBCFCPSTRet := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN500,"_VBCFCPSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN500:_vBCFCPSTRet:Text), 0)
							nPFCPSTRet  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN500,"_PFCPSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN500:_pFCPSTRet:Text), 0)
							nVFCPSTRet  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN500,"_VFCPSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN500:_vFCPSTRet:Text), 0)
							nVICMSSTRet	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN500,"_VICMSSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN500:_vICMSSTRet:Text), 0)
							nBICMSSTRet	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN500,"_VBCSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN500:_vBCSTRet:Text), 0)
							nAICMSSTRet	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN500,"_PST")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN500:_pST:Text), 0)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS,"_ICMSSN900")) == "O"
							nICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN900,"_VICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN900:_vICMS:Text), 0)
							nAlICMItem	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN900,"_PICMS")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN900:_pICMS:Text), 0)	
							nIMCSTIt	:= If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN900,"_VICMSSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN900:_vICMSSTRet:Text), 0)
							nALIMCSTIt  := If(ValType(XmlChildEx(aItens[nX]:_Imposto:_ICMS:_ICMSSN900,"_PICMSSTRET")) == "O", Val(aItens[nX]:_Imposto:_ICMS:_ICMSSN900:_pICMSSTRet:Text), 0)
						EndIf
					EndIf

					If !Empty(cOrigClas) .And. !Empty(cCSTClas)
						If Empty(cMVClasFis)
							cClasFis := cOrigClas+cCSTClas
						Else
							//Conversão a partir do parametro MV_COLCFIS
							aClasFis := Separa(cMVClasFis,"|")
							
							nClasFis := aScan(aClasFis,{|x| SubStr(x,1,1) == cOrigClas})
							If nClasFis > 0
								cClasFis := SubStr(aClasFis[nClasFis],3,1) + cCSTClas 
							Endif
						Endif
					Endif 

					//--PIS
					If ValType(XmlChildEx(aItens[nX]:_Imposto,"_PIS")) == "O"
						If ValType(XmlChildEx(aItens[nX]:_Imposto:_PIS,"_PISALIQ")) == "O"  
							nPISItem := Val(aItens[nX]:_Imposto:_PIS:_PISAliq:_vPIS:Text)
							nAlPISItem := Val(aItens[nX]:_Imposto:_PIS:_PISAliq:_pPIS:Text)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_PIS,"_PISQTDE")) == "O"
							nPISItem := Val(aItens[nX]:_Imposto:_PIS:_PISQtde:_vPIS:Text)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_PIS,"_PISOUTR")) == "O"
							nPISItem := Val(aItens[nX]:_Imposto:_PIS:_PISOutr:_vPIS:Text)
							If ValType(XmlChildEx(aItens[nX]:_Imposto:_PIS:_PISOutr,"_PPIS")) == "O"
								nAlPISItem := Val(aItens[nX]:_Imposto:_PIS:_PISOutr:_pPIS:Text)
							ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_PIS:_PISOutr,"_VALIQPROD")) == "O"
								nAlPISItem := Val(aItens[nX]:_Imposto:_PIS:_PISOutr:_vAliqProd:Text)
							EndIf
						Endif
					EndIf
					
					//--COFINS
					If ValType(XmlChildEx(aItens[nX]:_Imposto,"_COFINS")) == "O"
						If ValType(XmlChildEx(aItens[nX]:_Imposto:_COFINS,"_COFINSALIQ")) == "O"
							nCOFItem := Val(aItens[nX]:_Imposto:_COFINS:_COFINSAliq:_vCOFINS:Text)
							nAlCOFItem := Val(aItens[nX]:_Imposto:_COFINS:_COFINSAliq:_pCOFINS:Text)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_COFINS,"_COFINSQTDE")) == "O"
							nCOFItem := Val(aItens[nX]:_Imposto:_COFINS:_COFINSQtde:_vCOFINS:Text)
						ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_COFINS,"_COFINSOUTR")) == "O"
							nCOFItem := Val(aItens[nX]:_Imposto:_COFINS:_COFINSOutr:_vCOFINS:Text)
							If ValType(XmlChildEx(aItens[nX]:_Imposto:_COFINS:_COFINSOutr,"_PCOFINS")) == "O"
								nAlCOFItem := Val(aItens[nX]:_Imposto:_COFINS:_COFINSOutr:_pCOFINS:Text)
							ElseIf ValType(XmlChildEx(aItens[nX]:_Imposto:_COFINS:_COFINSOutr,"_VALIQPROD")) == "O"
								nAlCOFItem := Val(aItens[nX]:_Imposto:_COFINS:_COFINSOutr:_vAliqProd:Text)
							EndIf
						EndIf
					EndIf
					*/
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Dados dos itens - SDT                                                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SDT")

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Dados do produto                                                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					AADD(aItemSDT,{ {"DT_FILIAL" 	,FWxFilial("SDT")												},; // Filial
									{"DT_CNPJ"		,cCGC														},; // CGC
									{"DT_COD"		,cProduto2													},; // Codigo do produto
									{"DT_PRODFOR"	,aItens[nX]:_PROD:_CPROD:TEXT								},; // Cdgo do pduto do Fornecedor
									{"DT_DESCFOR"	,aItens[nX]:_PROD:_XPROD:TEXT								},; // Dcao do pduto do Fornecedor
									{"DT_ITEM"   	,PadL(aItens[nX]:_nItem:Text,TamSX3("D1_ITEM")[1],"0")		},; // Item
									{"DT_QUANT"  	,_nQuant                         							},; // Qtde
									{"DT_VUNIT"		,_nVUnit													},; // Vlor Unitário
									{"DT_FORNEC"	,cCodigo													},; // Forncedor
									{"DT_LOJA"   	,cLoja														},; // Lja
									{"DT_DOC"    	,cDoc														},; // DocmTo
									{"DT_SERIE"		,cSerie							   							},; // Serie
									{"DT_TOTAL"		,Val(aItens[nX]:_Prod:_vProd:Text)							}}) // Valor Total

									 /*
									 aAdd(aItemSDT[Len(aItemSDT)],{"DT_XMLIPI"  , nIPIItem})
									 aAdd(aItemSDT[Len(aItemSDT)],{"DT_XMLICM"  , nICMItem})
									 aAdd(aItemSDT[Len(aItemSDT)],{"DT_XMLISS"  , nISSItem})
									 aAdd(aItemSDT[Len(aItemSDT)],{"DT_XMLPIS"  , nPISItem})
									 aAdd(aItemSDT[Len(aItemSDT)],{"DT_XMLCOF"  , nCOFItem})
									 aAdd(aItemSDT[Len(aItemSDT)],{"DT_XMLICST" , nIMCSTIt})
									 
								 	 aAdd(aItemSDT[Len(aItemSDT)],{"DT_XALQIPI"  , nAlIPIItem})
									 aAdd(aItemSDT[Len(aItemSDT)],{"DT_XALQICM"  , nAlICMItem})
									 aAdd(aItemSDT[Len(aItemSDT)],{"DT_XALQISS"  , nAlISSItem})
								  	 aAdd(aItemSDT[Len(aItemSDT)],{"DT_XALQPIS"  , nAlPISItem})
  									 aAdd(aItemSDT[Len(aItemSDT)],{"DT_XALQCOF"  , nAlCOFItem})
  									 aAdd(aItemSDT[Len(aItemSDT)],{"DT_XALICST"  , nALIMCSTIt})
  									 
  									 If lFCPAnt
  									 	aAdd(aItemSDT[Len(aItemSDT)],{"DT_XBFCPAN"  , nBCFCPSTRet})
  									 	aAdd(aItemSDT[Len(aItemSDT)],{"DT_XAFCPAN"  , nPFCPSTRet})
  									 	aAdd(aItemSDT[Len(aItemSDT)],{"DT_XVFCPAN"  , nVFCPSTRet})
  									 Endif
  									 
  									 If lFCPST
  									 	aAdd(aItemSDT[Len(aItemSDT)],{"DT_XBFCPST"  , nBCFCPST})
  									 	aAdd(aItemSDT[Len(aItemSDT)],{"DT_XAFCPST"  , nPFCPST})
  									 	aAdd(aItemSDT[Len(aItemSDT)],{"DT_XVFCPST"  , nVFCPST})
  									 Endif
  									 
  									 If lDTClasFis .And. !Empty(cClasFis)
  									 	aAdd(aItemSDT[Len(aItemSDT)],{"DT_CLASFIS"  , cClasFis})
  									 Endif
  									 
  									 If lICMSSTRet
  									 	aAdd(aItemSDT[Len(aItemSDT)],{"DT_ICMNDES"  , nVICMSSTRet})
  										aAdd(aItemSDT[Len(aItemSDT)],{"DT_BASNDES"  , nBICMSSTRet})
  										aAdd(aItemSDT[Len(aItemSDT)],{"DT_ALQNDES"  , nAICMSSTRet})
  									 Endif
  									 
									 If lDTICMDeson
									 	aAdd(aItemSDT[Len(aItemSDT)],{"DT_ICMDES"  	, nICMDeson})
  										aAdd(aItemSDT[Len(aItemSDT)],{"DT_ICMDEMT"  , cICMDesMot})
  									 Endif
  									 */

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Efetua carga para gravação da tabela de histórico das qtdes informadas  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					AADD(aItemZDT,{ {"ZDT_FILIAL" 	,FWxFilial("ZDT")												},; // Filial
									{"ZDT_DTHIST"	,DDATABASE													},; // Database da inclusão do histórico
									{"ZDT_HRHIST"	,TIME()														},; // Hora da inclusão do histórico
									{"ZDT_DTIXML"	,DDATABASE  												},; // Database da importação do xml
									{"ZDT_USIXML"	,cUserName													},; // Usuário que importou xml
									{"ZDT_DOC"    	,cDoc														},; // Documento
									{"ZDT_SERIE"	,cSerie							   							},; // Serie
									{"ZDT_FORNEC"	,cCodigo													},; // Fornecedor
									{"ZDT_LOJA"   	,cLoja														},; // Loja
									{"ZDT_NOMFOR"	,GetAdvFval("SA2","A2_NOME",FWxFilial("SA2")+cCodigo+cLoja,1)	},; // Nome Fornecedor
									{"ZDT_ITEM"   	,PadL(aItens[nX]:_nItem:Text,TamSX3("D1_ITEM")[1],"0")		},; // Item
									{"ZDT_COD"		,cProduto2													},; // Codigo do produto
									{"ZDT_DESC"		,GetAdvFval("SB1","B1_DESC",FWxFilial("SB1")+cProduto2,1)		}}) // Descriçao do produto

				Next nX

				If !Empty(aItemSDT) .And. !Empty(aHeadSDS)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava os dados do cabeçalho e itens da nota importada do XML          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Begin Transaction

						aHeadSDS:=aHeadSDS[1]

						//--Grava cabeçalho
						RecLock("SDS",.T.)
						For nX:=1 To Len(aHeadSDS)
							SDS->&(aHeadSDS[nX][1]):= aHeadSDS[nX][2]
						Next
						dbCommit()
						MsUnlock()

						//--Grava Itens
						For nX:=1 To Len(aItemSDT)
							RecLock("SDT",.T.)
							For nY:=1 To Len(aItemSDT[nX])
								SDT->&(aItemSDT[nX][nY][1]):= aItemSDT[nX][nY][2]
							Next
							dbCommit()
							MsUnlock()
						Next
						
						//--Grava Histórico
						For nX:=1 To Len(aItemZDT)
							RecLock("ZDT",.T.)
							For nY:=1 To Len(aItemZDT[nX])
								ZDT->&(aItemZDT[nX][nY][1]):= aItemZDT[nX][nY][2]
							Next
							dbCommit()
							MsUnlock()
						Next

						cArqTXT := cStartPath+cFile

						//copia o arquivo antes da transacao
						cNomNovArq  := c3StartPath+cFile
						If MsErase(cNomNovArq)
							__CopyFile(cArqTXT,cNomNovArq)
							FErase(cStartPath+cFile)
						EndIf

					End Transaction
				Else
					//-- Move arquivo para pasta dos erros
					cArqTXT := cStartPath+cFile

					//copia o arquivo antes da transacao
					cNomNovArq  := cStartError+cFile
					If MsErase(cNomNovArq)
						__CopyFile(cArqTXT,cNomNovArq)
						FErase(cStartPath+cFile)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return lProces


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CONSNFECHV³   Autor ³ Evandro Mugnol      ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta chave na NFe no Sefaz                             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function CoNFeChv(cChaveNFe,cIdEnt,lWeb)

	Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local cMensagem := ""
	Local oWS
	Local lErro 	 := .F.

	If ValType(lWeb) == 'U'
		lWeb := .F.
	EndIf


	oWs:= WsNFeSBra():New()
	oWs:cUserToken := "TOTVS"
	oWs:cID_ENT    := cIdEnt
	ows:cCHVNFE	   := cChaveNFe
	oWs:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"

	If oWs:ConsultaChaveNFE()
		cMensagem := ""
		If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cVERSAO)
			cMensagem += "Versão da Mensagem"+": "+oWs:oWSCONSULTACHAVENFERESULT:cVERSAO+CRLF
		EndIf
		cMensagem += "Ambiente"+": "+IIf(oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1,"Produção","Homologação")+CRLF
		cMensagem += "Cod.Ret.NFe"+": "+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF
		cMensagem += "Msg.Ret.NFe"+": "+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF
		If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
			cMensagem += "Protocolo"+": "+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF
		EndIf

		//QUANDO NAO ESTIVER OK NAO IMPORTA, CODIGO DIFERENTE DE 100
		If oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE # "100"
			lErro := .T.
		EndIf

		If !lWeb
			Aviso("Consulta NF",cMensagem,{"Ok"},3)
		Else
			Return({lErro,cMensagem,oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE})
		EndIf
	Else
		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
	EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GETIDENT ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Obtem o codigo da entidade apos enviar o post para o Totvs ³±±
±±³          ³ Service                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpC1: Codigo da entidade no Totvs Services                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function WSAT01GetIdEnt()

	Local aArea  := GetArea()
	Local cIdEnt := ""
	Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local oWs

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Obtem o codigo da entidade                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWS := WsSPEDAdm():New()
	oWS:cUSERTOKEN := "TOTVS"

	oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
	oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM
	oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
	oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
	oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
	oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
	oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
	oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
	oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
	oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
	oWS:oWSEMPRESA:cCOD_PAIS   := "01058"
	oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
	oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
	oWS:oWSEMPRESA:cCEP_CP     := Nil
	oWS:oWSEMPRESA:cCP         := Nil
	oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
	oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
	oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
	oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
	oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
	oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
	oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cINDSITESP  := ""
	oWS:oWSEMPRESA:cID_MATRIZ  := ""
	oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
	oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
	If oWs:ADMEMPRESAS()
		cIdEnt := oWs:cADMEMPRESASRESULT
	Else
		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
	EndIf

	RestArea(aArea)

Return(cIdEnt)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ENVMAIL1   ³ Autor ³ Evandro Mugnol      ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Envia e-mail para responsaveis                             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³cVar1 - conta de email no campo FROM³
//³cVar2 - conta de email no campo TO  ³
//³cVar3 - nao usado                   ³
//³cVar4 - Mensagem do corpo do email  ³
//³cVar5 - titullo do email            ³
//³cVar6 - endereco do anexo           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function EnvMail1(cVar1,cVar2,cVar3,cVar4,cVar5,cVar6)

	Local lResult     := .F.                           // Resultado da tentativa de comunicacao com servidor de E-Mail
	Local cTitulo1    := RTrim(cVar5)
	Local cEmailTo    := RTrim(cVar2)
	Local cEmailBcc	:= ""
	Local cError   	:= ""
	Local lRelauth 	:= GetNewPar("MV_RELAUTH",.F.)   // Parametro que indica se existe autenticacao no e-mail
	Local lRet        := .F.
	Local cFrom       := alltrim(GetMV("MV_RELFROM"))
	Local cConta   	:= alltrim(GetMV("MV_RELACNT"))
	Local cSenhaa  	:= alltrim(GetMV("MV_RELPSW"))
	Local cServer		:= alltrim(GetMV("MV_RELSERV"))
	Local cMensagem   := cVar4
	Local cAttachment := cVar6

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tenta conexão com o servidor de e-Mail                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CONNECT SMTP;
	SERVER  cServer;				// Nome do servidor de e-mail
	ACCOUNT cConta;  				// Nome da conta a ser usada no e-mail
	PASSWORD cSenhaa;  			// Senha
	RESULT lResult             // Resultado da tentativa de conexão

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a conexão com o SMTP está ok                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lResult
		// Se existe autenticacao para envio valida pela funcao MAILAUTH
		If lRelauth
			lRet := Mailauth(cConta,cSenhaa)
		Else
			lRet := .T.
		Endif

		If lRet
			SEND MAIL FROM cFrom ;
			TO cEmailTo;
			BCC cEmailBcc;
			SUBJECT cTitulo1;
			BODY cMensagem;
			ATTACHMENT cAttachment;
			RESULT lResult

			If !lResult
				GET MAIL ERROR cError
				Aviso("Erro",cEmailTo,{"OK"},3,"ReadXML")
			Endif
		EndIf
		DISCONNECT SMTP SERVER
	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		Aviso("Erro",cError,{"OK"},3,"ReadXML")
	Endif

Return

Static Function _GetParam()

	_cRet := GetMv("PM_CFOPDEV")

Return(_cRet)

/*
user function Qry2Array(_sQuery)
   local   _aLinha    := {}
   local   _aArray    := {}
   local   _aCampos   := {}
   local   _nRecCount := 0
   local   _aAreaAnt  := U_ML_SRArea ()
   Local _nCampo
   private _sAliasQ   := ""
   private _aAreaQry  := {}

   // Executa a query para saber quais os campos retornados.
//   procregua (10)
//   incproc ("Buscando dados...")
   _sAliasQ = GetNextAlias()
   DbUseArea(.t., 'TOPCONN', TcGenQry(,, _sQuery), _sAliasQ, .f., .t.)
   count to _nRecCount

   // Altera tipo de campos data cfe. dicionario de dados.
//   incproc ("Ajustando campos...")
   sx3 -> (dbsetorder (2))
   for _nCampo = 1 to (_sAliasQ) -> (fcount ())
      if sx3->(dbseek (padr (alltrim ((_sAliasQ) -> (FieldName (_nCampo))), 10, " "), .F.))
      		
         if GETSX3CACHE(FieldName (_nCampo), "X3_TIPO") $ "ND"  // Numerico ou data
            TCSetField(_sAliasQ, GETSX3CACHE(FieldName (_nCampo), "X3_CAMPO"), GETSX3CACHE(FieldName (_nCampo), "X3_TIPO"), GETSX3CACHE(FieldName(_nCampo), "X3_TAMANHO"), GETSX3CACHE(FieldName(_nCampo), "X3_DECIMAL"))
         endif
      endif
   next

   // Passa dados para a array
//   procregua (_nRecCount)
//   incproc ("Alimentando array...")
   _aArray = {}
   (_sAliasQ) -> (dbgotop ())
   do while ! (_sAliasQ) -> (eof ())
//      incproc ()
      _aLinha = {}
      for _nCampo = 1 to (_sAliasQ) -> (fcount ())
         aadd (_aLinha, (_sAliasQ) -> (fieldget (_nCampo)))
      next
      aadd (_aArray, aclone (_aLinha))
      (_sAliasQ) -> (dbskip ())
   enddo
   (_sAliasQ) -> (dbclosearea ())

   U_ML_SRArea (_aAreaAnt)
return _aArray
/*
