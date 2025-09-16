#INCLUDE "rwmake.ch"                                                                   
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "topconn.ch"    

/*                                                                          
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                        
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF195    ºAutor  ³Giuliano Forgiarini º Data ³  03/12/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cadastro e manutenção de romaneios de embarque de gado      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Compra de gado                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF195()

	lOk := .f.

	aObjects := {}                                            // dimensao janelas
	aPosObj  := {}
	aInfo    := {}

	aSizeAut := MsAdvSize()
	AAdd( aObjects, {100, 100, .T., .T. } )
	AAdd( aObjects, {100, 50, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	bLegenda1 :=  "ZAQ->ZAQ_STATUS == 'A'"
	bLegenda2 :=  "ZAQ->ZAQ_STATUS == 'B'"  

	aCores2:= { {'BR_VERDE'   ,'Autorizado' },;
	{'BR_AMARELO' ,'Bloqueado'}}

	aCores := { {bLegenda1, 'BR_VERDE'   },;
	{bLegenda2, 'BR_AMARELO' }}            


	Private cPerg    := "GJF195"

	Private cCadastro := "Cadastro e Manutenção de Romaneios de Embarque de GAdo"
	Private aRotina  := MenuDef()                             // Chamada da funcao menudef() que contem aRotina

	if !pergunte(cPerg,.t.)
		return
	endif
	//Indice para a filtragem
	cCondicao := "(ZAQ_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "') AND "
	cCondicao += "(ZAQ_DATAEM BETWEEN '" + dtos(mv_par03) + "' AND '" + dtos(mv_par04) + "')"


	dbSelectArea("ZAQ")
	ZZ3->(DbSetOrder(1))
	ZZ3->(DbGoTop())

	//mbrowse sem a função AutoRefresh para atualizar o browse automaticamente
	mBrowse(6,1,22,75,"ZAQ", ,,,,2,aCores,,,,,,,,cCondicao) 


	If Select('ZAQ')<>0                                                           
		ZAQ->(dbCloseArea())
	Endif

return


//Inclusão do romaneio
User Function gjf195i()
	Local nCont
	lOk := .f.                       

	DEFINE MSDIALOG oDlg TITLE 'Romaneio de Embarque de Gado' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL    

	RegToMemory("ZAQ",.T.)

	obj := MsMGet():New("ZAQ" ,ZAQ->(RECNO()),3,,,,,aPosObj[1],,,,,,oDlg,,,.F. )

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||TaOk()},{||NaoTaOk()})

	If lOk  

		begin transaction

			recLock('ZAQ',.T.)

			For nCont := 1 To FCount()
				If "FILIAL"$Field(nCont)
					FieldPut(nCont,xFilial("ZAQ"))
				Else
					FieldPut(nCont,M->&(FIELDNAME(nCont)))
				Endif
			Next nCont                       

			ConfirmSx8()

			MsUnLock()   

		end transaction
	else

		RollBackSx8()

	endif

return

//Alteração do romaneio de embarque de gado
User Function gjf195a()  
	Local nCont
	lOk := .f.     

	DEFINE MSDIALOG oDlg TITLE 'Romaneio de Embarque de Gado' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL  

	RegToMemory("ZAQ",.f.)

	obj := MsMGet():New("ZAQ", ZAQ->(RECNO()),4,,,,,aPosObj[1],,,,,,oDlg,,,.F. )

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||TaOk()},{||NaoTaOk()})

	If lOk                                                                                                     
		begin transaction
			recLock('ZAQ',.f.)
			For nCont := 1 To FCount()
				If "FILIAL"$Field(nCont)
					FieldPut(nCont,xFilial("ZAQ"))
				Else
					FieldPut(nCont,M->&(FIELDNAME(nCont)))
				Endif
			Next nCont
			MsUnLock()
		end transaction
	endif

return 

static function TaOk()
	lOk := .t.
	oDlg:end()
return lOk


static function NaoTaOk()
	lOk := .f.
	Odlg:end()
Return lOk

//EXCLUSAO DE UM PRE-CARREGAMENTO
User Function gjf195e()

	if APMSGYESNO('Confirma Exclusão do Romaneio?','ATENÇÃO')               
		reclock('ZAQ',.f.)                                                     
		dbdelete()
		msunlock()
	endif                        

return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MENUDEF  ³ Autor ³ Evandro Mugnol        ³ Data ³21/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Isola opcoes de menu para que as opcoes da rotina possam   ³±±
±±³          ³ ser lidas pelas bibliotecas framework da Versao 10         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ <Vide Parametros Formais>                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³      ³                                        ³±±
±±³              ³  /  /  ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Array contendo as Rotinas a executar do programa      ³
	//³ ----------- Elementos contidos por dimensao ------------     ³
	//³ 1. Nome a aparecer no cabecalho                              ³
	//³ 2. Nome da Rotina associada                                  ³
	//³ 3. Usado pela rotina                                         ³
	//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
	//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
	//³    2 - Simplesmente Mostra os Campos                         ³
	//³    3 - Inclui registros no Bancos de Dados                   ³
	//³    4 - Altera o registro corrente                            ³
	//³    5 - Remove o registro corrente do Banco de Dados          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  


	Private aRotina := { {"Pesquisar"  , "AxPesqui"   , 0 , 1 , 0 , .F. } ,;
	{"Visualizar" , "AxVisual"   , 0 , 2 , 0 , NIL } ,;
	{"Incluir"    , "u_gjf195i"  , 0 , 3 , 0 , NIL } ,;
	{"Alterar"    , "u_gjf195a"  , 0 , 4 , 0 , NIL } ,;
	{"Excluir"    , "u_gjf195e"  , 0 , 5 , 0 , NIL }}
Return aRotina

