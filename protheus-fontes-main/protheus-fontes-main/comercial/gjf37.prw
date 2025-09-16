#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF37     º Autor ³Giuliano Forgiarini º Data ³  06/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Liberação de pré-pedidos de venda - modelo II              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAOMS                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF37()

	Private cPerg   := "GJF37"
	Private cCadastro := "Previsão de Gerenciamento de Pré-carregamentos e Pré-pedidos"
	private aRotina :={}        

	area := getarea() 
	_aArqTrb := {}

	if !pergunte(cPerg,.t.)
		return
	endif

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	dbSelectarea('ZZ4')
	ZZ4->(dbSetOrder(1))

	aStru := dbStruct()   
	aadd(aStru,{"ZZ4_PLACA" , "C",   7, 0,   "@!", 'Placa'})
	aadd(aStru,{"ZZ4_DESCO"  , "C",   3, 0,   "@!", 'Desconto'})

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado 
	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMP->(dbCloseArea())
	//Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )
	//TMP->(dbgotop())

	If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	ZZ4->(dbgotop()) 
	ZZ4->(dbseek(xfilial('ZZ4')+mv_par01))                                   //Esse laço serve para atribuir ao TMP os valores
	while ZZ4->(!eof()) .and. ZZ4->ZZ4_PRECAR = mv_par01 .and. ZZ4->ZZ4_FILIAL = xfilial('ZZ4') 

		if !(ZZ4->ZZ4_STATUS $ 'B/I')
			ZZ4->(dbskip())
			loop 
		endif

		_des := .f.
		ZZ5->(dbsetorder(1))
		ZZ5->(dbseek(xfilial('ZZ5')+ZZ4->ZZ4_NUM))                                //Para verificar se existe desconto no pre-pedido
		while ZZ5->(!eof()) .and. alltrim(ZZ5->ZZ5_NUM) = alltrim(ZZ4->ZZ4_NUM) .and. ZZ5->ZZ5_FILIAL = xfilial('ZZ5') 
			if !empty(ZZ5->ZZ5_TPBONI)
				_des := .t.
			endif
			ZZ5->(dbskip())
		enddo
		DbSelectArea('TMP')
		reclock('TMP',.t.)
		TMP->ZZ4_NUM    := ZZ4->ZZ4_NUM
		TMP->ZZ4_CODCLI := ZZ4->ZZ4_CODCLI
		TMP->ZZ4_LOJA   := ZZ4->ZZ4_LOJA
		TMP->ZZ4_NOME   := ZZ4->ZZ4_NOME
		TMP->ZZ4_MARCA  := ZZ4->ZZ4_MARCA
		TMP->ZZ4_PRECAR := ZZ4->ZZ4_PRECAR
		TMP->ZZ4_PLACA  := fbuscaCPO('ZZ3',2,xfilial('ZZ4')+ZZ4->ZZ4_PRECAR,'ZZ3_PLACA') 
		TMP->ZZ4_DESCO  := iif(_des,"Sim","Nao")
		TMP->ZZ4_OK     := SPACE(1)
		msunlock()
		ZZ4->(dbskip())
	enddo

	aCampos := {} 
	AADD(aCampos,{"ZZ4_OK"      ,  "@X",       "OK"           })
	AADD(aCampos,{"ZZ4_NUM"     ,  "@X",       "Numero"       })
	AADD(aCampos,{"ZZ4_CODCLI"  ,  "@X",       "Cod. Cliente" })
	AADD(aCampos,{"ZZ4_LOJA"    ,  "@X",       "Loja"         })
	AADD(aCampos,{"ZZ4_NOME "   ,  "@!",       "Descricao"    })
	AADD(aCampos,{"ZZ4_MARCA"   ,  "@E 99",    "Marca"        })
	AADD(aCampos,{"ZZ4_PRECAR"  ,  "@X",       "Zona"         })
	AADD(aCampos,{"ZZ4_PLACA"   ,  "@X",       "Placa"        })
	AADD(aCampos,{"ZZ4_DESCO"   ,  "@X",       "Desconto?"    })

	aRotina := {{"Liberar", "u_gjf37lib(_des)"  , 0 , 4 , 0 , NIL }} 

	cCadastro := 'Vincular Pré-pedidos'
	dbselectarea('TMP')
	//IndRegua("TMP",cArq,"ZZ4_NUM+ZZ4_CODCLI+ZZ4_LOJA",,,"Selecionando Registros...") //ordena
	TMP->(dbgotop())

	MarkBrowse("TMP","ZZ4_OK",,aCampos,,'S')                              //Mostra os campos do TMP no MarkBrow

	restarea(area)

	If Select('ZZ3')<>0                                                           
		ZZ3->(dbCloseArea())
	Endif

	If Select('ZZ4')<>0                                                          
		ZZ4->(dbCloseArea())
	Endif

	If Select('ZZ5')<>0                                                          
		ZZ5->(dbCloseArea())
	Endif

	If Select('TMP')<>0                                                          
		TMP->(dbCloseArea())
	Endif

	aRotina := {}

return .t.


User Function gjf37lib(_des)

	ZZ4->(dbsetorder(1))         
	TMP->(dbgotop())   

	marc := .f.     

	while TMP->(!eof())                                                           //O campo com 'S' significa que o registro foi assinalado
		if TMP->ZZ4_OK = 'S'                                                      // no MarkBrow
			marc := .t.
			ZZ4->(dbsetorder(2))
			if ZZ4->(dbseek(xfilial()+TMP->ZZ4_NUM))    
				if  !gjf37v()
					msgbox('Cliente ('+ZZ4->ZZ4_CODCLI + '-'+ZZ4->ZZ4_LOJA + ')'+;
					' com situação financeira irregular!','OPERACAO IRREGULAR!','ERRO') 
					marc := .f. 
					TMP->(dbskip())
					loop
				endif  
				if  !gjf37d()
					msgbox('Pre-Pedido ' + ZZ4->ZZ4_NUM +;
					' possui desconto!','OPERACAO IRREGULAR!','ERRO') 
					marc := .f.
					TMP->(dbskip())
					loop
				endif

				reclock('ZZ4',.f.)
				ZZ4->ZZ4_STATUS := 'L'
				msunlock()
			endif
		else
			TMP->(dbskip())
			loop
		endif
		TMP->(dbskip())
	enddo  

	if marc
		msgbox('Liberação realizada!',"CONFIRMAÇÃO","INFO")  
		closebrowse() 
	else
		msgbox('Não houveram Pré-pedidos selecionados!','OPERACAO NULA','INFO')  
	endif

return .t.

Static Function gjf37v()
	area := getarea()    

	//para verificação da situação do cliente
	//cQuery := "SELECT SA1.A1_COD, SA1.A1_LOJA, SA1.A1_MSBLQL FROM "+RetSqlName("SA1")+" SA1 " +;
	//" WHERE SA1.D_E_L_E_T_ <> '*' " +;
	//"  AND SA1.A1_COD     = '" + ZZ4->ZZ4_CODCLI + "'";
	//"  AND SA1.A1_FILIAL     = '" + xfilial('SA1') + "'" +;
	//"  AND SA1.A1_LOJA    = '" + ZZ4->ZZ4_LOJA +"'

	cQuery := " SELECT A1_COD, A1_LOJA, A1_MSBLQL
	cQuery += " FROM " + retSqlTab("SA1") 
	cQuery += " WHERE " + retSqlFil("SA1") 
	cQuery += " AND A1_LOJA = '" + ZZ4->ZZ4_LOJA + "'"
	cQuery += " AND A1_COD = '" + ZZ4->ZZ4_CODCLI + "'"
	cQuery += " AND " + retSqlDel("SA1")

	cQuery := ChangeQuery(cQuery)  



	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("CLI")<>0
		CLI->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "CLI"

	if CLI->A1_MSBLQL == '1' 
		sit := .f.
	else                                                             
		sit := .t.
	endif

	CLI->(dbclosearea())
	restarea(area)

	if ZZ4->ZZ4_LIBCRE = 'B'
		msgbox('Entre em contato com o setor Financeiro!','LIMITE DE CREDITO EXCEDIDO!','STOP')
		sit := .f.
	endif

return(sit)


Static Function gjf37d()
	area := getarea()    

	//para verificação do desconto
	cQuery2 := "SELECT COUNT(*) AS DESCONTO FROM "+RetSqlName("ZZ5")+" ZZ5 " +;
	" WHERE ZZ5.D_E_L_E_T_ <> '*' " +;   
	" AND ZZ5.ZZ5_TPBONI  <> ' ' " +; 
	" AND ZZ5.ZZ5_FILIAL '" + xfilial('ZZ5') + "'"+; 
	" AND ZZ5.ZZ5_NUM    = '" + ZZ4->ZZ4_NUM +"'"
	cQuery2 := ChangeQuery(cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("DES")<>0
		DES->(dbCloseArea())
	Endif

	TCQUERY cQuery2 NEW ALIAS "DES"

	if DES->DESCONTO == 0
		sit2 := .t.
	else                                                             
		sit2 := .f.
	endif

	DES->(dbclosearea())
	restarea(area)

return(sit2)


