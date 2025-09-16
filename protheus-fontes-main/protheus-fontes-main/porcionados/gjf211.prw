#INCLUDE "FILEIO.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

User Function GJF211(nOpc)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ GJF211  ³ Autor ³ Giuliano Forgiarini   ³ Data ³ nov/2014 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Manutenção das previsões de produção da industria de       ³±±
	±±³          ³ porcionados                                                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³ porcionados                                                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Data      ³ Programador   ³ Manutencao Efetuada                        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³ Giuliano      ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	Private cAlias    := "ZAR"
	Private aRotina 	:= MenuDef()
	Private cCadastro := "Previsão de Produção Porcionados"
	Private cCondicao := ""
	Private cPerg     := "" 
	Private _cProd    := ""   
	Private aBrowse1  := {}  
	Private _aReceita := {}                                      
	Private _dDataDes := ddatabase

	//Parametro que determina os grupos que são PA para carne moída	
	Private _cGrpMoi := GetMV('SI_GRPMOI')

	cPerg  := "GJF211"
	cPerg2 := "GJF211b"

	If !Pergunte(cPerg,.T.)
		Return
	endif

	bLegenda1 := " empty(ZAR->ZAR_PREEMB) .and. empty(ZAR->ZAR_DTABAT)"    // Aberta 
	bLegenda2 := " ZAR->ZAR_PREEMB = 'S' .and.  empty(ZAR->ZAR_DTABAT) "    // Com OP de embalagem
	bLegenda3 := " ZAR->ZAR_PREEMB = 'S' .and. !empty(ZAR->ZAR_DTABAT) "    // Com Op de embalagem e data de abate vinculada
	bLegenda4 := " ZAR->ZAR_PREEMB = 'S' .and. !empty(ZAR->ZAR_DTABAT) .and. !empty(ZAR->ZAR_LOTE)"   // Com Op de embalagem, data de abate vinculada e lote
	bLegenda5 := " !empty(ZAR->ZAR_LOTE)"   // Somente com o lote apontado
	bLegenda6 := " alltrim(ZAR->ZAR_CODCLI) = 'MANUAL' "   // Somente com o lote apontado




	aCores := { {bLegenda1, 'BR_AZUL'    },;       // Aberta
	{bLegenda2, 'BR_VERMELHO'},;      // Com OP de embalagem
	{bLegenda3, 'BR_LARANJA' },;       // Com Op de embalagem e data de abate vinculada
	{bLegenda4, 'BR_AMARELO' },;        // Com Op de embalagem, data de abate vinculada e lote
	{bLegenda5, 'BR_BRANCO'  },;       //somente com o lote 
	{bLegenda6, 'BR_CINZA'   }}        //Manuais 


	aCores2:= { {'BR_AZUL'    ,'Por processar...'    },;
	{'BR_AMARELO' ,'Op Embalagem'},;
	{'BR_LARANJA' ,'OP Emb./Dt.Abate ' },;
	{'BR_VERMELHO','Op Emb./Dt.Abate/Lote' },;
	{'BR_BRANCO'  ,'Somente com o lote' },;
	{'BR_CINZA'   ,'Manuais' }}

	cCondicao := " ZAR_DATA BETWEEN '"+ dtos(mv_par01) +"' AND '" +dtos(mv_par02) + "' "

	if mv_par03 = 1
		cCondicao += " AND ZAR_PREPED  <> '' "
	elseif mv_par03 = 2
		cCondicao += " AND ZAR_PREPED  LIKE 'MANUAL%' "
	endif                                    

	if !empty(mv_par04)
		cCondicao += " AND ZAR_LOTE  = '" + mv_par04 + "' "
	endif


	if !empty(mv_par05) .and. !empty(mv_par06)
		cCondicao += " AND ZAR_CODCLI  = '" + mv_par05 + "'  AND ZAR_LOJA = '" + mv_par06 + "'"
	endif

	if !empty(mv_par07) .and. !empty(mv_par08)
		cCondicao += " AND ZAR_PREPED BETWEEN '" + mv_par07 + "'  AND  '" + mv_par08 + "'"
	endif

	ZAR->(DbSetOrder(1))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   

	mBrowse(6,1,22,75,cAlias,,,,,,aCores,,,,{|x| AutoRefresh(x)},,,,cCondicao)      

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ MenuDef  ³ Autor ³ Giuliano Forgiarini   ³ Data ³ Jun/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Definição das funções do menu principal da rotina          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

	Local aRotina := {{ OemToAnsi("Pesquisar")	,"AxPesqui"	, 0 , 1,,.F.} ,;
	{ OemToAnsi("Visualizar")	,"U_gf211m" , 0 , 2		} ,;
	{ OemToAnsi("Incluir")		,"U_gf211m"	, 0 , 3		} ,;
	{ OemToAnsi("Alterar")		,"U_gf211m"	, 0 , 4		} ,;
	{ OemToAnsi("Empenho")  	,"U_gjf212"	, 0 , 4		} ,;
	{ OemToAnsi("Excluir")		,"U_gf211m"	, 0 , 5		} ,;
	{ OemToAnsi("Ajuste")   	,"U_gf211j"	, 0 , 4		},;
	{OemToAnsi("Legenda")      ,"U_gf211l" , 0 , 2     }}
Return(aRotina)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ gf211m ³ Autor ³ Giuliano Forgiarini    ³ Data ³ nov/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Exibe na tela enchoice e a getdados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do Arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do Registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function gf211m(cAlias,nReg,nOpc)

	// Declaração das variaveis
	Local nSaveSx8Len := GetSx8Len()

	Private oEnch
	Private oDlg
	Private oGDItens
	Private aGets     := {} 
	Private aTela     := {}
	Private aButtons  := {}
	Private nOpcao		:= 0
	Private bOk       := { || IIf(Obrigatorio(aGets,aTela), (nOpcao:=1,oDlg:End()) , nOpcao := 0) }
	Private bCancel   := { || nOpcao:=0 , oDlg:End() }
	Private nSuperior := 0
	Private nEsquerda := 0
	Private nInferior := 0
	Private nDireita  := 0
	Private aSizeAut  := {}
	Private aObjects  := {}
	Private aInfo     := {}
	Private aPosGet   := {}
	Private aPosObj   := {} 
	Private nUsado	   :=	0
	Private aHeader	:= {}
	Private aCols	:= {}


	nReg   := IIf(nOpc==3,Nil,ZAR->(Recno()))
	cAlias := "ZAR"

	// Maximizacao da tela em relação a area de trabalho
	aSizeAut := MsAdvSize()
	aAdd(aObjects,{100,040,.T.,.F.})
	aAdd(aObjects,{100,100,.T.,.T.})

	aInfo   := {aSizeAut[1],aSizeAut[2],aSizeAut[3],aSizeAut[4],3,3}
	aPosObj := MsObjSize(aInfo,aObjects)

	//Ajusta para ter mais um array com divisoes da dimenssao da tela
	aPosObj[1,3]:=aPosObj[1,3]*3.2

	// Verifica o tipo de chamada e trata a situação
	cNaoExbCps := ""

	Do Case
		Case nOpc == 2	// Visualização
		nOpEnch:= 2
		aExbCpo:= fInitVarX3(cAlias,.F.,cNaoExbCps)
		Case nOpc == 3	// Inclusão
		nOpEnch:= 3   
		_cProd := ""
		aExbCpo:= fInitVarX3(cAlias,.T.,cNaoExbCps)  
		Case nOpc == 4	// Alteração
		nOpEnch:= 4
		aExbCpo:= fInitVarX3(cAlias,.F.,cNaoExbCps)
		Case nOpc == 5	// Exclusão
		nOpEnch:= 5
		aExbCpo:= fInitVarX3(cAlias,.F.,cNaoExbCps)
		Otherwise 		// Outras Situações
		nOpEnch:= 2
		aExbCpo:= fInitVarX3(cAlias,.F.,cNaoExbCps)
	EndCase


	if nOpc == 3
		M->ZAR_CODCLI := ''
		M->ZAR_LOJA   := ''      
		M->ZAR_DESCLI := 'MANUAL'
	endif

	if nOpc == 4
		if !(ZAR->ZAR_STATUS $ 'A/S')
			if (ZAR->ZAR_QRPESO <> 0)
				alert('Produção já iniciada. Não é possível a alteração desta previsão!')
				return .f.
			endif      
			if !empty(ZAR->ZAR_PREPED)
				alert('Rotina não foi gerada manualmente. Não é possível a alteração desta previsão!')
				return .f.
			endif    
			if !empty(ZAR->ZAR_LOTE)
				alert('Ordem de produção pertence a um Lote de Produção!')
				return .f.
			endif    		
		endif
	endif


	if nOpc == 5 .or. nOpc == 6
		if ZAR->ZAR_STATUS <> 'A'
			alert('Status atual da Previsão de Produção impede essa operação!')
			return .f.	
		endif
		if !empty(ZAR->ZAR_LOTE)
			alert('Ordem de produção já pertencente a um Lote de Produção!')
			return .f.
		endif    	
	endif

	GeraBrow(M->ZAR_NUM)

	// Montagem da tela que serah apresentada para usuario (lay-out)
	Define MsDialog oDlg Title cCadastro From aSizeAut[7],0 To aSizeAut[6],aSizeAut[5] Of oMainWnd Pixel

	// Montagem do Cabeçalho
	oEnch := Msmget():New(cAlias,ZAR->(RECNO()),nOpEnch,,,,aExbCpo,aPosObj[1],aExbCpo,,,,,oDlg,,.T.)	

	if nOpc == 3 .or. nOpc == 4
		@ aPosObj[1,3]+10,020   BUTTON 'Calcular Quantidades' SIZE 60,20 ACTION Calcular()    OBJECT oBtn1 
		@ aPosObj[1,3]+10,090   BUTTON 'Define Materia Prima' SIZE 60,20 ACTION ProcessaMP(M->ZAR_COD,M->ZAR_QPPESO)  OBJECT oBtn2	
		@ aPosObj[1,3]+10,160   BUTTON 'Prev. Prod. Embal.'   SIZE 60,20 ACTION u_gjf211D(cAlias,nOpc)  OBJECT oBtn3
	endif

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

	Do Case
		Case nOpc == 3 .And. nOpcao == 1		// Se for inclusao e foi confirmado  
		fSalvaTudo(nOpc,cAlias,aExbCpo,nReg)   
		WfwPorc(nOpc) //Aciona workflow

		// Atualiza ou retorna sequencial do carregamento    	  
		While GetSx8Len() > nSaveSx8Len
			IF nOpcao == 1
				ConfirmSX8()
			Else
				RollBackSX8()
			Endif
		Enddo
		Case nOpc == 4 .And. nOpcao == 1		// Se for alteracao e foi confirmado
		fSalvaTudo(nOpc,cAlias,aExbCpo,nReg)         
		WfwPorc(nOpc) //Aciona workflow
		Case nOpc == 6 .And. nOpcao == 1		// Se for exclusao e foi confirmado    
		WfwPorc(nOpc) //Aciona workflow      
		fExcluiTudo()   
		OtherWise   

		While GetSx8Len() > nSaveSx8Len
			// Retorna sequencial do carregamento no cancelamento
			RollBackSX8()
		End
	EndCase

	aBrowse1 := {}

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ fInitVarX3   ³ Autor ³ Giuliano Forgiarini³ Data ³ Nov/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Carrega as variaveis em memoria                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fInitVarX3(cAlias,lInitVarX3,cNaoExbCps)

	Local i
	Local aExibLst := {}

	//SX3->(DbSetOrder(1))
	//SX3->(DbSeek(cAlias))
	//While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
	//	If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
	_cAlias  := cAlias
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO'))) .And. cNivel >= GetSx3Cache(_aCpoSX3[i], 'X3_NIVEL')
			If Empty(cNaoExbCps) .Or. !(AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) $ cNaoExbCps)
				If lInitVarX3
					_SetOwnerPrvt(Trim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')),CriaVar(Trim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')),.T.))
				Else
					If GetSx3Cache(_aCpoSX3[i], 'X3_CONTEXT') != "V"
						_SetOwnerPrvt(Trim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')),&(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')))
					Else
						_SetOwnerPrvt(Trim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')),&(GetSx3Cache(_aCpoSX3[i], 'X3_RELACAO')))
					EndIf
				EndIf
				AADD(aExibLst,GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO'))
			EndIf
		EndIf
	Next
	//	SX3->(DbSkip())
	//End

Return(aExibLst)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ fSalvaTudo   ³ Autor ³ Giuliano Forgiarini Data ³ nov/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Funcao responsavel pela gravacao das inclusoes e alteracoes³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fSalvaTudo(nOpc,cAlias,aExbCpo)

	// Declara variaveis
	Local aArea	   := ZAR->(GetArea())
	Local x        := 1
	Local nOrdSeek := 6
	Local aGrvCps  := {}
	Local k

	// Trata campos do enchoice
	For x:=1 To Len(aExbCpo)
		aAdd(aGrvCps,{aExbCpo[x] ,"M->"+aExbCpo[x] })
	Next x

	If nOpc == 3 .Or. nOpc == 4
		// Grava campos do cabeçalho
		DbSelectArea("ZAR")
		If nOpc == 3
			RecLock("ZAR",.T.)  
			ZAR->ZAR_STATUS := 'A' 
		ElseIf nOpc == 4
			RecLock("ZAR",.F.)
		EndIf

		ZAR->ZAR_FILIAL := FWxFilial("ZAR")
		For k:=1 To Len(aGrvCps)
			&(aGrvCps[k,1]) := &(aGrvCps[k,2])
		Next k

		MsUnlock()  

		GravaMP(aBrowse1)

	Endif

	RestArea(aArea)

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ fExcluiTudo  ³ Autor ³ Evandro Mugnol    ³ Data ³ Mai/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Funcao responsavel pela exclusão de todos os itens         ³±±
±±³          ³ apresentados na tela                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 

Static Function fExcluiTudo()
	Local _lExiste := .f.

	if !empty(ZAR->ZAR_LOTE)
		Help(" ",1,"LOTE",,"Op vinculada a um lote de produção!",4,1)
	else
		If Aviso("Confirma exclusão?","Esta Previsão de Produção será excluída!",{"Confirma","Cancela"}) == 1

			DbSelectArea('SB1')
			_cGrupo := GetAdvFval('SB1','B1_GRUPO',FWxfilial('SB1')+ZAR->ZAR_COD,1)

			_lExiste := ExisteSZU(ZAR->ZAR_NUM)

			if !_lExiste

				//Cancela todos os empenhos
				CancEmp(ZAR->ZAR_NUM)

				// Reajusta o saldo do pre-pedido para produção
				ZZ5->(DbSetOrder(1))
				if ZZ5->(DbSeek(FWxfilial('ZZ5')+ZAR->(ZAR_PREPED+ZAR_ITEMPP)))
					reclock('ZZ5',.f.)  

					if ZAR->ZAR_EMP = 'N'
						ZZ5->ZZ5_SLDPOR := ZZ5->ZZ5_SLDPOR + ZAR->ZAR_QPPESO			
					else
						ZZ5->ZZ5_SLDPOR := ZZ5->ZZ5_SLDPOR + ZAR->ZAR_QPESOR	
					endif

					msunlock()
				ENDIF

				RecLock("ZAR",.F.)
				DbDelete()
				MsUnLock()

			endif
		EndIf
	endif

Return

//Função para botão calcular as quantidades
Static Function Calcular()
	Local _aRet := {}
	Local _lBloq := PrdBlq()
	Local _nDuplic := VerDuplic()

	DbSelectArea('SB1')

	if empty(M->ZAR_PREPED)

		_aRet := u_GJF210Q(M->ZAR_QPPESO,M->ZAR_COD)

		M->ZAR_QPPESO := _aRet[3]
		M->ZAR_QPCAIX := _aRet[1]
		M->ZAR_QPUNI  := _aRet[2]

		oDlg:refresh()

	else
		alert('Previsão de Produção derivada de um Pré-Pedido de Venda!')
	endif
	
	if _lBloq = .F.
		MsgAlert("Produto bloqueado para produção. Contate o PCP","Aviso")
		M->ZAR_COD := ""
		M->ZAR_QPPESO := 0
		Return .f.
	endif
	/*
	if (_nDuplic > 0)
		MsgAlert("Já existe lote criado para o produto " + alltrim(M->ZAR_COD) +" na data " + DToC(M->ZAR_DATA) + " gerado de forma manual.","Aviso")				
		M->ZAR_COD := ""
		M->ZAR_QPPESO := 0
		return .f.		
    endif	
	*/
return


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

//Gerencia a previsão de produção para a desossa
User Function gjf211D(cAlias,nOpc)

	//if (_cGrupo $ _cGrpMoi)
	//	Help(" ",1,"PRODUTO",,"Tipo do PA impede esta operação!",4,1)	
	//else

	if Empty(M->ZAR_COD)
		alert('Por favor, indique o codigo do produto!')
		return
	endif

	if M->ZAR_QPCAIX = 0.00
		alert('Necessário calcular quantidades!')
		return
	endif

	_aHeader1  := {'Status','Numero','Cod.Prod.','Descr.Prod.','Q.P.Caix.','Q.P.Peso','Q.R.Caix','Q.R.Peso','Dt.Desossa'}
	_aLargCol1 := {   20  ,   30   ,    30     ,     100      ,     30    ,    30    ,    30    ,    30    ,  30        }

	if pergunte(cPerg2,.t.)

		_dDataDes := mv_par01

		if empty(_dDataDes)
			alert('Necessário definir data de produçao!')
		else

			DEFINE DIALOG oDlg2 TITLE "Previsão Produção Embalagem" FROM 020,50 To 180,670 PIXEL
			// Vetor com elementos do Browse

			// Cria Browse
			oBrowse1 := TCBrowse():New(00,00,320,050,,_aHeader1,_aLargCol1,oDlg2,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

			// Seta vetor para a browse
			oBrowse1:SetArray(aBrowse1)
			// Monta a linha a ser exibina no Browse
			oBrowse1:bLine := {||{aBrowse1[oBrowse1:nAt,01],aBrowse1[oBrowse1:nAt,02],aBrowse1[oBrowse1:nAt,03],;
			aBrowse1[oBrowse1:nAT,04],aBrowse1[oBrowse1:nAT,05],aBrowse1[oBrowse1:nAT,06],;
			aBrowse1[oBrowse1:nAT,07],aBrowse1[oBrowse1:nAT,08],aBrowse1[oBrowse1:nAT,09]}}
			// Evento de clique no cabeçalho da browse
			@ 060,005     BUTTON 'Gerar' SIZE 40,10 ACTION GeraPrev()  OBJECT oBtn1
			@ 060,055     BUTTON 'Sair'  SIZE 40,10 ACTION oDlg2:end() OBJECT oBtn2

			ACTIVATE DIALOG oDlg2 CENTERED   

		endif
	endif	
	//endif

	pergunte(cPerg,.f.)

return


//Gera itens do TCBrowse
Static Function GeraBrow(_cNum)

	SZU->(DbSetOrder(5))
	if SZU->(DbSeek(FWxfilial('SZU') + _cNum))  
		While  SZU->(!Eof()) .and. SZU->ZU_FILIAL = FWxfilial('SZU') .and. SZU->ZU_PREPORC = _cNum

			aadd(aBrowse1,{SZU->ZU_FECHADO,SZU->ZU_NUM,SZU->ZU_COD,SZU->ZU_DESC,SZU->ZU_QPCAIX,SZU->ZU_QPPESO,SZU->ZU_QRCAIX,SZU->ZU_QRPESO,dtoc(SZU->ZU_DTPROD)})       

			SZU->(DbSkip())
		enddo
	elseif len(aBrowse1) = 0
		aadd(aBrowse1,{'','','','',0.00,0.00,0.00,0.00,''})   
	endif

return

//Gera Previsão de produção embalagem
Static Function GeraPrev()
	Local i
	_cGrupo := GetAdvFval('SB1','B1_GRUPO',FWxfilial('SB1') + M->ZAR_COD,1)

	//Se for produção de moida, faz um processo separado
	if (_cGrupo $ _cGrpMoi) 

		SZU->(DbSetOrder(5))
		if SZU->(DbSeek(FWxfilial('SZU') + M->ZAR_NUM))
			alert('Previsão de produção de embalagem já existente!')
		else

			//Gera vetor com as informações da matéria-prima
			_aMP := ProcessaMP(M->ZAR_COD,M->ZAR_QPPESO)
			//{_cCod,_nQuant}
			//Status Numero Codigo Descricao prev.Caix prev.peso
			aBrowse1 := {}

			for  i := 1 to len(_aMP)    
				_cNum := GetSx8num('SZU','ZU_NUM')
				ConfirmSX8()               

				_cDesMP  := GetAdvFval('SB1','B1_DESCRED',FWxfilial('SB1') + _aMP[i,1],1)
				_nPMCaix := GetAdvFval('SB1','B1_PMCAIX',FWxfilial('SB1') + _aMP[i,1],1)

				_nCaix   := round(_aMP[i,2]/_nPMCaix,0) 

				aadd(aBrowse1,{'N',_cNum, _aMP[i,1],_cDesMP,_nCaix,_aMP[i,2],0.00,0.00,dtoc(_dDataDes)} )
			next   
		endif

	else

		SZU->(DbSetOrder(5))
		if SZU->(DbSeek(FWxfilial('SZU') + M->ZAR_NUM))
			alert('Previsão de produção de embalagem já existente!')
		else

			_cNum := GetSx8num('SZU','ZU_NUM')
			ConfirmSX8()

			//Gera vetor com as informações da matéria-prima

			_aMP     := ProcessaMP(M->ZAR_COD,M->ZAR_QPPESO)
			_cDesMP  := GetAdvFval('SB1','B1_DESCRED',FWxfilial('SB1') + _aMP[4],1)
			_nPMCaix := GetAdvFval('SB1','B1_PMCAIX',FWxfilial('SB1') + _aMP[4],1)

			_nCaix   := round(_aMP[6]/_nPMCaix,0)

			//Status Numero Codigo Descricao prev.Caix prev.peso
			aBrowse1 := {}
			aadd(aBrowse1,{'N',_cNum, _aMP[4],_cDesMP,_nCaix,_aMP[6],0.00,0.00,dtoc(_dDataDes)} )

		endif

	endif	              

	GeraBrow(M->ZAR_NUM) 

	oBrowse1:SetArray(aBrowse1)

	// Monta a linha a ser exibina no Browse
	oBrowse1:bLine := {||{aBrowse1[oBrowse1:nAt,01],aBrowse1[oBrowse1:nAt,02],aBrowse1[oBrowse1:nAt,03],;
	aBrowse1[oBrowse1:nAT,04],aBrowse1[oBrowse1:nAT,05],aBrowse1[oBrowse1:nAT,06],;
	aBrowse1[oBrowse1:nAT,07],aBrowse1[oBrowse1:nAT,08],aBrowse1[oBrowse1:nAT,09]}}

	oBrowse1:DrawSelect()
	oBrowse1:refresh()
	oDlg2:refresh()


return  


//Função destinada a processar a MP a ser produzida na desossa
Static Function ProcessaMP(_cCod,_nPeso)
	Local _aRet := {}
	Local _nQuant := 0

	DbSelectArea('SB1')
	_cGrupo := GetAdvFval('SB1','B1_GRUPO',FWxfilial('SB1')+M->ZAR_COD,1)


	//Se for moida providencia a receita
	if (_cGrupo $ _cGrpMoi)   

		SG1->(DbSetOrder(6))
		SG1->(DbGoTop())
		if SG1->(DbSeek(FWxfilial('SG1') + padr(_cCod,15,'')+'RM' ))      //padl(alltrim(M->ZZ4_CODCLI),6,'0')

			while SG1->(!eof()) .and. SG1->G1_FILIAL = FWxfilial('SG1') .and. SG1->G1_COD = padr(_cCod,15,'') .and. SG1->G1_TPPORC = 'RM'

				if SG1->G1_TPPORC = 'RM'	
					_nQuant := _nPeso * SG1->G1_QUANT        
					aadd(_aRet,{SG1->G1_COMP,_nQuant})
				endif  
				SG1->(dbSkip())
			enddo  

			M->ZAR_CODMP  := 'RECEIT'
			M->ZAR_QTDMP  := _nPeso

		endif
	else          

		SG1->(DbSetOrder(1))
		SG1->(DbGoTop())
		if SG1->(DbSeek(FWxfilial('SG1') + _cCod))
			while SG1->(!eof()) .and. SG1->G1_FILIAL = FWxfilial('SG1') .and. SG1->G1_COD = _cCod

				_cTipoComp := GetAdvFval('SB1','B1_TIPO',FWxfilial('SB1')+SG1->G1_COMP,1)

				if _cTipoComp = 'PP'

					//Achou o código do produto intermediário
					_cCodPInt := GetAdvFval('SB1','B1_COD',FWxfilial('SB1')+SG1->G1_COMP,1)

					//Achou o percentual de perda do produto intermediário
					_nPerPInt := SG1->G1_PERDAA/100
					exit
				endif

				SG1->(dbSkip())
			enddo
		endif

		//Acha a quantidade de produto intermediário a produzir
		_nQtdPInt := _nPeso / (1 - _nPerPInt)
		//	_nQtdPInt := _nPeso + (_nPeso * _nPerPInt)

		//Acha o código da matéria-prima
		_cMP    := GetAdvFval('SG1','G1_COMP',FWxfilial('SG1')+_cCodPInt,1)

		//Acha o percentual de perda da matéria-prima
		_nPerMP := GetAdvFval('SG1','G1_PERDAA',FWxfilial('SG1')+_cCodPInt,1)
		_nPerMP := _nPerMP/100

		//Acha o total de matéria-prima a ser produzida na desossa
		_nQtdMP := _nQtdPInt / (1 -_nPerMP)
		//	_nQtdMP := _nQtdPInt + (_nQtdPInt * _nPerMP)

		aadd(_aRet,_cCodPInt)  //codigo produto intermediário
		aadd(_aRet,_nPerPInt)  //percentual quebra produto intermediário
		aadd(_aRet,_nQtdPInt)  //quantidade produto intermediário
		aadd(_aRet,_cMP)       //codigo matéria-prima
		aadd(_aRet,_nPerMP)    //percentual de quebra matéria-prima
		aadd(_aRet,_nQtdMP)    //quantidade final de matéria-prima

		alert('Quant. inicial:' + transform(_nPeso,'@E 999,999,999.99'))
		alert('Perc.Q. fat:' + transform(_nPerPInt,'@E 999,999,999.99'))
		alert('Quant.Q.fat:' + transform(_nQtdPInt,'@E 999,999,999.99'))
		alert('Perc.Q. MP:' + transform(_nPerMP,'@E 999,999,999.99'))
		alert('Quant.F. MP:' + transform(_nQtdMP,'@E 999,999,999.99'))

		M->ZAR_CODPI  := _aRet[1]
		M->ZAR_QTDPI  := _aRet[3]
		M->ZAR_CODMP  := _aRet[4]
		M->ZAR_CODMP2 := u_GF211AL(_aRet[4])
		M->ZAR_QTDMP  := _aRet[6]

	endif   
return _aRet       

//Gravação da previsão de produção da embalagem
Static Function GravaMP(_aBrw)

	Local i
	SZU->(DbSetOrder(5))
	if SZU->(DbSeek(FWxfilial('SZU') + M->ZAR_NUM))
		_lFlag := .f.
	else
		_lFlag := .t.
	endif               

	if !empty(_aBrw[1,2]) 
		for i := 1 to len(_aBrw)
			reclock('SZU',_lFlag)
			SZU->ZU_FILIAL   := FWxfilial('SZU')
			SZU->ZU_NUM      := _aBrw[i,2]
			SZU->ZU_DATA     := ddatabase
			SZU->ZU_DTRPRO   := ctod(_aBrw[i,9])
			SZU->ZU_DTPROD   := ctod(_aBrw[i,9])
			SZU->ZU_COD      := _aBrw[i,3]
			SZU->ZU_QPCAIX   := _aBrw[i,5]
			SZU->ZU_QPPESO   := _aBrw[i,6]
			SZU->ZU_TIPO     := 'P'
			SZU->ZU_TF       := 'N'
			SZU->ZU_ETIQ     := 'PO'
			SZU->ZU_DESC     := _aBrw[i,4]
			SZU->ZU_PREPORC  := M->ZAR_NUM
			SZU->ZU_MPPORC   := 'S'
			SZU->ZU_CONTEXA  := 'N'
			SZU->ZU_FECHADO  := 'B'
			SZU->ZU_PRIORI   := 'P'
			SZU->ZU_NOTIMP   := 'P'
			SZU->ZU_NUMETQ   := 1
			msunlock()   
		next
	endif


return


//Função criada especialmente para validar o cadastro de produto porcionado e 
//suas estruturas na inclusão manual de uma OP
//Usado no gatilho do campo ZAR_COD

User Function GF211V(_prod)


	Local _lRet     := .t.
	Local _lRet2    := .f.
	Local _nQuantPP := 0
	Local _nQuantMP := 0
	Local _nQuantRM := 0
	Local _cCodPP   := ''
	Local _cCodMP   := ''
	Local _cGrupoPA := ''

	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))

	if !SB1->(DbSeek(FWxfilial('SB1')+_prod))
		Help(" ",1,"CADASTRO01",,"Produto não encontrado!",4,1)
		_lRet := .f.
	else

		_cGrupoPA := SB1->B1_GRUPO


		//Verifica o preenchimento de campos importantes no cadastro
		if SB1->B1_PMCAIX  = 0 .or. SB1->B1_PESBAND = 0 .or. SB1->B1_QTBCAIX = 0
			Help(" ",1,"CADASTRO02",,"Campos obrigatórios no Cadastro de Produtos para este processo!",4,1)
			_lRet := .f.
		else
			SG1->(DbOrderNickName('SG1PORCION'))
			SG1->(DbGoTop())

			//Verifica se existe estrutura de produto para este PA
			if !SG1->(DbSeek(FWxfilial('SG1') + _prod))
				Help(" ",1,"ESTOQUE0 1",,"Estrutura de produto não encontrada!",4,1)
				_lRet := .f.
			else

				//Laço para encontrar na estrutura de produto o componente produto em processo (PP)
				//e produto de receita de carne moída (RM)
				while SG1->(!eof()) .and. SG1->G1_FILIAL = FWxfilial('SG1') .and. SG1->G1_COD = _prod

					//Faz a contagem de componentes PP (Produto em Processo para bife: tem que ter só 1)
					if SG1->G1_TPPORC = 'PP'
						_nQuantPP++
						_cCodPP := SG1->G1_COMP
					endif

					//Faz a contagem de componentes RM (Receita Moida)
					if SG1->G1_TPPORC = 'RM'
						_nQuantRM++
					endif


					SG1->(dbSkip())
				enddo

				//Verifica se tem apenas 1 componente PP na estrutura (exclui moida)
				/* Comentado por flavio - A Pedido de Sr Ivon para produzir códigos da embalagem aqui nos porcionados
				// Feito dia 13/01/21  
				Dia 22/01/21 - Foi identificado pela qualidade que não pode ser feito então descomentei o bloco abaixo
				*/
				if _nQuantPP <> 1 .and. !(_cGrupoPA $ _cGrpMoi)
					Help(" ",1,"ESTOQUE02",,"Divergencia na quantidade de componentes na estrutura!",4,1)
					_lRet := .f.

				elseif _nQuantRM = 0 .and. (_cGrupoPA $ _cGrpMoi)
					Help(" ",1,"ESTOQUE03",,"Divergencia na quantidade de componentes na estrutura!",4,1)
					_lRet := .f.
				endif
				
				
			endif
		endif
	endif

return _lRet

//ExecBlock para prencher quantidade em estrutura de produto
User Function GF211S()                                      
	Local _nQuant := 0.00

	SB1->(DbGoTop())
	SB1->(DbsetOrder(1))
	if SB1->(DbSeek(FWxfilial('SB1') + SG1->G1_COMP))

		_cTpPorc := M->G1_TPPORC
		_cGrupo  := SB1->B1_GRUPO
		cProduto := SB1->B1_COD

		SB1->(DbGoTop())
		SB1->(DbsetOrder(1))			
		if SB1->(DbSeek(FWxfilial('SB1') + cProduto))  //cProduto --> variável de sistema

			//Se o produto componente pertencer ao grupo de embalagens de porcionado     
			if _cGrupo = '1204'

				if _cTpPorc = 'EP'
					if SB1->B1_PESBAND = 0
						_nQuant := 0
					else
						_nQuant := 1/SB1->B1_PESBAND
					endif
				elseif _cTpPorc = 'ES'
					_nQuant := 1/SB1->B1_PMCAIX
				else
					_nQuant := 1
				endif

			endif	
		endif
	Endif 

	if _cTpPorc = "RM"
		_nQuant := M->G1_QUANT
	endif

return _nQuant    


//Função para validação do campo G1_TPPORC
User Function GF211o()  
	Local _nQuant    := 0.00   
	Local _nQuantRM  := 0.00
	Local cProduto   := M->G1_COD
	//Se for um componente (R)eceita de (M)oida...
	if M->G1_TPPORC = 'RM'
		_nQuantRM := 00
		SG1->(DbOrderNickName('SG1PORCION'))
		SG1->(DbGoTop())
		if SG1->(DbSeek(FWxfilial('SG1') + alltrim(cProduto)))
			While SG1->(!Eof()) .and. SG1->G1_FILIAL = FWxfilial('SG1') .and. cProduto = SG1->G1_COD 
				if  SG1->G1_TPPORC = 'RM'  
					_nQuant += SG1->G1_QUANT
				endif
				SG1->(DbSkip())
			enddo

			//Alert(valtype(SG1->G1_QUANT))
			//Alert(valtype(_nQuant))
			_nQuantRM := _nQuant+SG1->G1_QUANT

			if  _nQuantRM > 1
				alert('Quantidade invalida!')
				M->G1_QUANT := 0
			endif
		endif
	endif

return .t.

//Função que retorna verificação de existencia de registro na SZU (OP de desossa/embalagem)
Static Function ExisteSZU(_num)       
	Local _lRet   := .f.
	Local _aPrev  := {}
	Local i

	SZU->(DbSetOrder(5))
	if SZU->(DbSeek(FWxfilial('SZU')+_num))  
		while ZAU->(!eof()) .and. SZU->ZU_FILIAL = FWxfilial('SZU') .and. SZU->ZU_NUM = _num
			if SZU->ZU_QRCAIX <>	0 .or. SZU->ZU_QRPESO <> 0  
				Help(" ",1,"DESOSSA",,"Produção de desossa já iniciada. Não permitida a exclusão!",4,1)    			
				_lRet := .t.
			else
				aadd(_aPrev,SZU->ZU_NUM)
			endif
			SZU->(DbSkip())   
		enddo

		if !_lRet
			SZU->(DbGoTop())
			for i := 1 to len(_aPrev) 
				if SZU->(DbSeek(FWxfilial('SZU')+_aPrev[i]))
					reclock('SZU',.f.)
					DbDelete()
					msunlock() 		                         
				endif
			next  

		endif
	endif

return _lRet 

//Função que retorna o produto alternativo de MP cadastrado.
User Function GF211AL(_cod) 
	Local _alt := ''

	SGI->(DbSetOrder(1))
	if SGI->(DbSeek(FWxfilial('SGI')+_cod))      
		_alt := SGI->GI_PRODALT
	endif

Return _alt

//Para encontrar o Código da Matéria-Prima de um produto porcionado
User Function GF211MP(_cCodPA)
	Local _cCodMP   := ''
	Local _cCodPInt := ''

	SG1->(DbSetOrder(1))
	SG1->(DbGoTop())
	if SG1->(DbSeek(FWxfilial('SG1') + _cCodPA))
		while SG1->(!eof()) .and. SG1->G1_FILIAL = FWxfilial('SG1') .and. SG1->G1_COD = _cCodPA

			_cTipoComp := GetAdvFval('SB1','B1_TIPO',FWxfilial('SB1')+SG1->G1_COMP,1)

			if _cTipoComp = 'PP'
				//Achou o código do produto intermediário
				_cCodPInt := GetAdvFval('SB1','B1_COD',FWxfilial('SB1')+SG1->G1_COMP,1)

				exit
			endif

			SG1->(dbSkip())
		enddo
	endif     

	//Acha o código da matéria-prima
	_cCodMP := GetAdvFval('SG1','G1_COMP',FWxfilial('SG1')+_cCodPInt,1)

return _cCodMP       

//Função que verifica se existe relação com
//industria de porcionados
Static Function WfwPorc(nOpc)
	Local i
	SZU->(DbSetOrder(5))
	if SZU->(DbSeek(FWxfilial('SZU')+M->ZAR_NUM)) 
		_cMens := 'Esta é uma mensagem automática do sistema. Por favor não responda!' + chr(13) + chr(10)
		_cMens += 'Na data e hora da emissão deste email, o Setor de PCP da indústria de porcionados '+iif(nOpc = 3,'INCLUIU',iif(nOpc = 4,'ALTEROU','EXCLUIU'))
		_cMens += ' a ordem de produção:' + M->ZAR_NUM + chr(13) + chr(10)
		_cMens += chr(13) + chr(10)
		_cMens += 'Número:       ' + M->ZAR_NUM  +chr(13) + chr(10)
		_cMens += 'Produto:      ' + M->ZAR_COD  + ' (' + alltrim(M->ZAR_DESC) + ')' + chr(13) + chr(10)

		_cMens += 'que poderá acarretar em mudanças na ordem de produção de Matéria Prima n.: ' + SZU->ZU_NUM

		_cTit := EncodeUTF8('Worflow Frigorifico Silva - PCP: Apontamentos de Produção de Matéria Prima para Porcionado')
		_cDest := 'pcp.porcionados@frigorificosilva.com.br,giuliano@frigorificosilva.com.br,pcp@frigorificosilva.com.br'

		_aEmail := u_GJF54(_cMens,_cTit,_cDest)
		for i := 1 to len(_aEmail)
			if !_aEmail[i]
				alert('ERRO WORKFLOW ('+ str(i) +')')
			endif
		next

	endif

return

//Função que cancela os empenhos
Static Function CancEmp(_cNum)
	Local _aCaixas := {}      
	Local i := 0

	ZAS->(DbSetOrder(2))
	if ZAS->(DbSeek(FWxfilial('ZAS') + _cNum)) 
		While ZAS->(!eof()) .and. ZAS->ZAS_FILIAL = FWxfilial('ZAS') .and. ZAS->ZAS_PREPOR = _cNum

			if empty(ZAS->ZAS_DATAS) .and. empty(ZAS->ZAS_HORAS)
				aadd(_aCaixas,ZAS->ZAS_CONTRO)	              
			endif

			ZAS->(DbSkip())
		enddo
	endif    

	ZAS->(DbSetOrder(1))

	for i := 1 to len(_aCaixas)

		if ZAS->(DbSeek(FWxfilial('ZAS')+_aCaixas[i]))	
			reclock('ZAS',.f.)
			ZAS->ZAS_PREPOR := ''
			msunlock()

			u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, "Cancelado Empenho para PPP", ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))
		
		endif
	next  

return

//Função que ajusta a quantidade a ser produzida
//com base no empenho de MP já existente
User Function gf211j()
	Local _nPesoPP := 0.00
	Local _nPesoMP := 0.00
	Local _cGrupo  := ''

	DbSelectArea('SB1')
	_cGrupo := GetAdvFval('SB1','B1_GRUPO',FWxfilial('SB1')+ZAR->ZAR_COD,1)

	if _cGrupo $ _cGrpMoi
		Help(" ",1,"PRODUTO",,"Tipo do PA impede esta operação!",4,1)
	else
		//So permite fazer o ajuste se não tiver vinculo com algum lote de produção...
		if empty(ZAR->ZAR_LOTE)
			//Se a OP estiver com status (A)berto e permite empenhar/produzir MP...
			if (ZAR->ZAR_STATUS == 'A') .and. (ZAR->ZAR_EMP == 'S')
				If Aviso("Confirma ajuste?","Ao realizar ajuste de produção, não se poderá mais empenhar MP para esta OP!",{"Confirma","Cancela"}) == 1
					ZAS->(DbSetOrder(2))
					if ZAS->(DbSeek(FWxfilial('ZAS') + ZAR->ZAR_NUM))
						While ZAS->(!eof()) .and. ZAS->ZAS_FILIAL = FWxfilial('ZAS') .and. ZAS->ZAS_PREPOR = ZAR->ZAR_NUM

							if empty(ZAS->ZAS_DATAS) .and. empty(ZAS->ZAS_HORAS) .and. ZAS->ZAS_TIPO = 'MP'
								_nPesoMP += ZAS->ZAS_PESOL
							endif

							if empty(ZAS->ZAS_DATAS) .and. empty(ZAS->ZAS_HORAS) .and. ZAS->ZAS_TIPO = 'PP'
								_nPesoPP += ZAS->ZAS_PESOL
							endif

							ZAS->(DbSkip())
						enddo
					endif

					//Percentual de perda para o PP
					_nPerPInt := (GetAdvFval('SG1','G1_PERDAA',FWxfilial('SG1')+ZAR->(padr(ZAR_CODPI,15,'')+padr(ZAR_COD,15,'')),2)/100)

					//Acha o percentual de perda da matéria-prima
					_nPerMP :=  (GetAdvFval('SG1','G1_PERDAA',FWxfilial('SG1')+ZAR->(padr(ZAR_CODMP,15,'')+padr(ZAR_CODPI,15,'')),2)/100)

					//Acha a quantidade de produto intermediário a produzir
					//Atenção: Aqui soma o PP empenhado, ou seja, já produzido. Só para fins de calculo
					_nQtdPInt := (_nPesoMP * (1 - _nPerMP)) +  _nPesoPP

					//Acha o total de Produto Acabado a ser produzido
					_nQtdPA := _nQtdPInt  * (1 -_nPerPInt)

					//Quantidade de bandeja por caixa
					_nQtdBC  := GetAdvFval('SB1','B1_QTBCAIX',FWxfilial('SB1') + ZAR->ZAR_COD,1)
					//Peso unitário de cada bandeja
					_nPesoBa := GetAdvFval('SB1','B1_PESBAND',FWxfilial('SB1') + ZAR->ZAR_COD,1)

					//Cálculo do número total de bandejas
					_nTotB := _nQtdPA/_nPesoBa

					_nResto1 := MOD(_nQtdPA,_nPesoBa)

					if _nResto1 <> 0
						if  round(_nTotB,0) < _nTotB
							_nTotB := round(_nTotB,0)+1
						else
							_nTotB := round(_nTotB,0)
						endif
					endif

					//Cálculo do Número total de caixas
					_nTotCaix := _nTotB/_nQtdBC

					_nResto2 := MOD(_nTotB,_nQtdBC)

					if _nResto2 <> 0
						if round(_nTotCaix,0) < _nTotCaix
							_nTotCaix := round(_nTotCaix,0)+1
						else
							_nTotCaix := round(_nTotCaix,0)
						endif
					endif

					_nTotB   := _nTotCaix * _nQtdBC
					_nTotPes := _nTotB * _nPesoBa

					//Se existe valores empenhados para ajuste...
					if _nTotB <> 0 .and. _nTotCaix <> 0 .and. _nTotPes <> 0
						reclock('ZAR',.f.)
						ZAR->ZAR_EMP    := 'N'  //Trava definitivamente o empenho/produção de MP
						ZAR->ZAR_QPPESO :=  _nTotPes
						ZAR->ZAR_QPCAIX :=  _nTotCaix
						ZAR->ZAR_QPUNI  :=  _nTotB
						ZAR->ZAR_QTDPI  :=  _nQtdPInt
						ZAR->ZAR_QTDMP  :=  _nPesoMP + (_nPesoPP / (1 - _nPerPInt))
						msunlock()

						ZZ5->(DbSetOrder(1))
						if ZZ5->(DbSeek(FWxfilial('ZZ5') + ZAR->(ZAR_PREPED + ZAR_ITEMPP)))
							//Devolve quantidade para o saldo do pré-pedido
							_nSldDev := iif(round(ZAR->ZAR_QPPESO,0) > ZAR->ZAR_QPESOR,0,ZAR->ZAR_QPESOR - round(ZAR->ZAR_QPPESO,0))
							reclock('ZZ5',.f.)
							ZZ5->ZZ5_SLDPOR := ZZ5->ZZ5_SLDPOR + _nSldDev
							msunlock()
						endif
						msginfo('Ajuste efetivado!','OPERACAO CONCLUIDA')
					else
						msginfo('Não existe valores a serem ajustados!','OPERACAO CANCELADA')
					endif
				endif
			else
				Help(" ",1,"STATUS",,"Status da produção ou ajuste já realizado impedem esta operação!",4,1)
			endif
		else
			Help(" ",1,"LOTE",,"Ordem de Produção já vinculada a um lote de produção!",4,1)
		endif
	endif
return

//Função que atualiza o Browse das Receitas de Carne Moída
Static Function AtuBrR()  

	// Vetor com elementos do Browse
	aBrowse1 := {}		

	ZAV->(DbSetOrder(2))
	if ZAV->(DbSeek(FWxfilial('ZAV') +ZAR->ZAR_NUM)) 
		_nItem := 0
		while ZAV->(!eof()) .and. ZAV->ZAV_FILIAL = FWxfilial('ZAV') .and. ZAV->ZAV_NUM = ZAR->ZAR_NUM
			_nItem++         

			DbSelectArea('SB1')
			_cDesc :=  GetAdvFval('SB1','B1_DESC',FWxfilial('SB1')+ZAV->ZAV_COD,1)

			aadd(aBrowse1,{ZAV->ZAV_COD,;
			strzero(_nItem,3),;
			alltrim(_cDesc),;
			transform(ZAV->ZAV_QPPESO,'@E 999,999.99')})	  

			ZAV->(DbSkip())
		enddo  
	else
		aadd(aBrowse1,{'','','',''})   
	endif

	oBrowse1:SetArray(aBrowse1)

	// Monta a linha a ser exibina no Browse
	oBrowse1:bLine := {||{aBrowse1[oBrowse1:nAt,01],aBrowse1[oBrowse1:nAt,02],aBrowse1[oBrowse1:nAt,03],aBrowse1[oBrowse1:nAT,04]}}

	oBrowse1:nScrollType := 1
	oBrowse1:bLDblClick   := {|| alert(aBrowse1[oBrowse1:nAt,01]) }

	oBrowse1:DrawSelect()
	oBrowse1:refresh()
	oDlg2:refresh()

return   

//Função que traz a descrição do grupo por gatilho no ZAR_COD
User Function gf211G()
	Local _desc := ''
	Local _grp  := ''
	_grp  := GetAdvFval('SB1','B1_GRUPO',FWxfilial('SB1') + M->ZAR_COD,1)
	_desc := GetAdvFval('SBM','BM_DESC',FWxfilial('SBM') + _grp,1)
return _desc                           

//função para legenda
User Function gf211L
	BrwLegenda('OPs. Porcionados','Legenda',aCores2)
return  

Static function PrdBlq()
	lBlq := .F.
	cMSBLQL := ALLTRIM(GetAdvFVal('SB1','B1_MSBLQL',FWXFilial('SB1')+ M->ZAR_COD,1))

	if(cMSBLQL = '1')
		lBlq := .F.		
	elseif(cMSBLQL = '2')
		lBlq := .T.
	endif
Return lBlq

Static function VerDuplic()	
	cQry := "SELECT COUNT(*) AS RESULTADO "
	cQry += "FROM " + RetSQLTab('ZAR')	
	cQry += "WHERE" + RetSQLFil('ZAR')
	cQry += " AND " + retSqlDel('ZAR')
	cQry += " AND ZAR_DATA = " + DToS(M->ZAR_DATA)
	cQry += " AND ZAR_COD  = " + M->ZAR_COD
	cQry += " AND ZAR_DESCLI = 'MANUAL'"

	cQry  := ChangeQuery(cQry)    

	TCQUERY cQry NEW ALIAS "QRY"

	resul := QRY->RESULTADO	

	QRY->(dbCloseArea())
Return resul
