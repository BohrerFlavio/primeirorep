#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "TOTVS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF45     º Autor ³Giuliano Forgiarini º Data ³  03/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para liberação dos pre-carregamentos e pre-pedidos  º±±
±±º          ³ de venda quando o sistema cair                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Expedições                                                  º±±                                                                       
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


User Function GJF45()

	lOk := .f.
	Private aCores   := {}
	Private aCores2  := {}

	aObjects := {}                                            // dimensao janelas
	aPosObj  := {}
	aInfo    := {}

	aSizeAut := MsAdvSize()
	AAdd( aObjects, {100, 100, .T., .T. } )
	AAdd( aObjects, {100, 50, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	bLegenda1 :=  "ZZ3->ZZ3_STATUS == 'A'"
	bLegenda2 :=  "ZZ3->ZZ3_STATUS == 'C'"
	bLegenda3 :=  "ZZ3->ZZ3_STATUS == 'B'"
	bLegenda4 :=  "ZZ3->ZZ3_STATUS == 'E'"
	bLegenda5 :=  "ZZ3->ZZ3_STATUS == 'S'"
	bLegenda6 :=  "ZZ3->ZZ3_STATUS == 'F'"

	aCores2:= { {'BR_VERDE'   ,'Aberto'    },;
	{'BR_AMARELO' ,'Carregando'},;
	{'BR_AZUL'    ,'Bloqueado' },;
	{'BR_VERMELHO','Encerrado' },;
	{'BR_LARANJA' ,'Em Espera' } ,;
	{'BR_PRETO' ,'Faturado ' }}

	aCores := { {bLegenda1, 'BR_VERDE'   },;
	{bLegenda2, 'BR_AMARELO' },;
	{bLegenda3, 'BR_AZUL'    },;
	{bLegenda4, 'BR_VERMELHO'},;
	{bLegenda5, 'BR_LARANJA' },;
	{bLegenda6, 'BR_PRETO' }}

	Private cPerg   := "GJF26"
	Private cCadastro := "Previsão de Gerenciamento de Pré-carregamentos e pré-pedidos"
	Private aRotina  := MenuDef()                             // Chamada da funcao menudef() que contem aRotina

	if !pergunte(cPerg,.t.)
		return
	endif

	Private cString := "ZZ3"  

	aIndZZ3   	:= {}						                                    //Indice para a filtragem
	cCondicao := "ZZ3->ZZ3_STATUS = 'C' .and. ZZ3->ZZ3_FILIAL = '" + xfilial('ZZ3') + "'"  //String para filtro
	FilBrowse("ZZ3",@aIndZZ3,@cCondicao)                                        //Aplicação da filtragem

	dbSelectArea(cString)
	ZZ3->(dbSetOrder(1))
	ZZ3->(dbgobottom())

	mBrowse(6,1,22,75,cString, ,,,,2     ,aCores)
	//      LIN INI,COL INI,LIN FIN,COL FIN,ALIAS  , ,,,,funcao,cores    

	If ( Len(aIndZZ3)>0 )
		EndFilBrw("ZZ3",aIndZZ3)                                                    //Encerra o filtro e refaz os índices padrões
	endif     

	If Select('ZZ3')<>0                                                           
		ZZ3->(dbCloseArea())
	Endif

	If Select('ZZ4')<>0                                                          
		ZZ4->(dbCloseArea())
	Endif

return


User Function gjf45L()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	if !msgbox('Esta rotina irá liberar as cargas em status "Carregando". Continuar?','ATENÇÃO','YESNO')
		return
	endif
	reclock('ZZ3',.f.)
	ZZ3->ZZ3_STATUS := 'S'
	msunlock() 

	ZZ4->(dbsetorder(1))
	if ZZ4->(dbseek(xfilial('ZZ4')+ZZ3->ZZ3_NUM))
		do while ZZ4->(!eof()) .and. ZZ4->ZZ4_FILIAL = xfilial('ZZ4') .and. ZZ4->ZZ4_PRECAR = ZZ3->ZZ3_NUM
			if ZZ4->ZZ4_STATUS != 'C'
				ZZ4->(dbskip())
				loop
			else
				reclock('ZZ4',.f.)
				ZZ4->ZZ4_STATUS = 'S'
				msunlock()
			endif
			ZZ4->(dbskip())
		enddo
	else
		alert('Nao encontrou pre-pedidos!')
	endif


	msgbox('Procedimento realizado com sucesso!','FIM DE PROCEDIMENTO','INFO')

Return


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
	Private aRotina := { {"Pesquisar"    , "AxPesqui"    , 0 , 1 , 0 , .F. } ,;
	{"Liberar"       , "u_gjf45L"  , 0 , 4 , 0 , NIL } ,;
	{"Legenda"      , "u_gjf45lPC"  , 0 , 2 , 0 , NIL } }

Return aRotina

User Function gjf45lPC
	BrwLegenda('Pré-Carregamentos','Legenda',aCores2)
return

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dia 19/11/21 - Flávio B. Flôres - Abertura de  carregamento         ³
	//³ OBS - Rotina criada para utilizar quando carregamento foi encerrado ³
	//³ por engano pelo pessoal das Expedições                  	        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

User Function gjf45RA()

	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cPerg   := "GJF45RA"
	                       
	if !pergunte(cPerg,.t.)
		return
	endif
	if !msgbox('Esta rotina irá Reabrir o carregamento'+alltrim(mv_par01)+' em status "Encerrado". Continuar?','ATENÇÃO','YESNO')
		return
	endif

	
	ZZ3->(dbSetOrder(2))
	ZZ3->(dbGoTop())
	if ZZ3->(dbSeek(xFilial('ZZ3') + alltrim(mv_par01)))

		if ZZ3->ZZ3_STATUS = "E"

			reclock('ZZ3',.f.)
				ZZ3->ZZ3_STATUS := 'S'
			msunlock() 
			msgbox('Carregamento Liberado com sucesso!','FIM DE PROCEDIMENTO','INFO')

		Elseif ZZ3->ZZ3_STATUS = "F"

			msgbox('Não Permitido - Carregamento já faturado!','FIM DE PROCEDIMENTO','INFO')
			return

		Endif

	Endif
	

Return
