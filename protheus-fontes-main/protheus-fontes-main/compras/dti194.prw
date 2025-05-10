#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI194  º Autor ³ Lucas Bolzan         º Data ³  12/12/23   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Libera pedidos para nova cotação                           º±±
±±º          ³ Elimina residuos                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Compras (SIGACOM)                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION DTI194()
    PRIVATE cAlias := 'SC7'
    
    PRIVATE cNumPed := SPACE(6)
    PRIVATE cNItem  := SPACE(3)
    PRIVATE nCount := 0

    IF MSGNOYES( "Deseja colocar no ar todos os ítens do pedido?", '' )
        MSGINFO( "Selecione qualquer item do pedido que deseja liberar.", " " )
        PRIVATE aRotina := { {"Coloca no ar"    ,"U_DTI194s"   ,0,4}}        
    ELSE
        MSGINFO( "Selecione o pedido e o nº do item desejado.", " " )
        PRIVATE aRotina := { {"Coloca no ar"    ,"U_DTI194n"   ,0,4}}        
    ENDIF

	dbSelectArea(cAlias)
	dbSetOrder(1)

	mBrowse(6, 1, 22, 75, cAlias)
RETURN

USER FUNCTION DTI194s() //SIM
    cNumPed := SC7->C7_NUM    
    SC7->(dbGoTop())
    SC7->(DBSEEK(FWXFilial('SC7')+cNumPed))

    WHILE SC7->(!EOF()) .AND. (SC7->C7_NUM = cNumPed)
        RECLOCK('SC7',.F.)
            SC7->C7_ENCER   := ""   //Pedido Encerrado
            SC7->C7_RESIDUO := ""   //PC com Residuo Eliminado
            SC7->C7_CONAPRO := "L"  //Controle de Aprovacao            
        MSUNLOCK()
        SC7->(DbSkip())
    ENDDO
    MSGINFO( "Todos os itens do pedido " + cNumPed + " foram liberados", '' )
RETURN

USER FUNCTION DTI194n() //NÂO
    cNumPed := SC7->C7_NUM
    cNItem := SC7->C7_ITEM

    WHILE SC7->(!EOF()) .AND. (SC7->C7_NUM = cNumPed) .AND. SC7->C7_ITEM = cNItem        
            RECLOCK('SC7',.F.)
            SC7->C7_ENCER   := ""   //Pedido Encerrado
            SC7->C7_RESIDUO := ""   //PC com Residuo Eliminado
            SC7->C7_CONAPRO := "L"  //Controle de Aprovacao            
            MSUNLOCK()
            SC7->(DbSkip())        
    ENDDO
    MSGINFO( "O item " + cNItem + " do pedido " + cNumPed + " foi liberado.", '' )
RETURN
