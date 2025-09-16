#INCLUDE "rwmake.ch"   
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR25     ºAutor  ³Mauricio Roehrs     º Data ³  25/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Fonte destinado ao apontamento de feriados no sabado       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestão de Pessoal                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function MLR25
	Local _aArqTrb    := {} // inicializa o array do arquivo
	
	Private _dData 	:= dDataBase - 30
	Private lInverte	:= .f.
	Private cMark    	:= GetMark()  
	Private oMark
	Private marc      := .f.     

	SP3->(DbGoTop())   
	//cArq  := CriaTrab( Nil, .F. ) 

	//aStru := dbStruct() 

	aStru := {}
	AADD(aStru,{"P3_SABFERI"  ,"C"	,2		,0	})
	AADD(aStru,{"P3_DATA"	  ,"D"  	,8   	,0 })    
	AADD(aStru,{"P3_DESC"     ,"C"	,30	,0	})    

	//dbcreate(cArq,aStru)        //Cria a estrutura do vetor no TMP criado 
	// ProcData 04/2023 - Chamada para criação do arquivo de trabalho
	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	If Select('TMP')<>0   		//Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
	Endif

	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )  //Manda usar o TMP     


	TMP->(DbGoTop())
	SP3->(DbSetOrder(1))
	SP3->(DbGoTop())
	//Seleciona Registros para arquivo temporario
	while SP3->(!eof()) .and. xFilial('SP3') = SP3->P3_FILIAL

		//se o sabado já foi marcado ignora	
		if !empty(SP3->P3_SABFERI)
			SP3->(DbSkip())
			loop
		endif

		//destinado para mostrar um limite de até 30 dias atras		
		if SP3->P3_DATA < _dData
			SP3->(DbSkip())
			loop
		endif

		reclock('TMP',.t.)
		TMP->P3_DATA    := SP3->P3_DATA
		TMP->P3_DESC 	 := SP3->P3_DESC
		msunlock()

		SP3->(DbSkip()) 			  	                  				
	enddo             

	aCampos := {}      

	AADD(aCampos,{"P3_SABFERI"  ,, "Feriado?"		,"@!"   })
	AADD(aCampos,{"P3_DATA"     ,, "Data"   		,"@!"   })
	AADD(aCampos,{"P3_DESC"     ,, "Descricao"	,"@!"   })

	dbselectarea('TMP')

	TMP->(dbgotop())    
	DEFINE MSDIALOG oDlg TITLE "Feriados no sabado" From 9,0 To 400,1000 PIXEL
	oMark := MsSelect():New("TMP","P3_SABFERI","",aCampos,@lInverte,@cMark,{17,1,160,500},,,,,) 
	oMark:bMark := {| | Disp()}        

	//TButton():New(170, 020, "Marcar Todos"  , oDlg,{|| mlr20Sel()   	},40,020,,,.F.,.T.,.F.,,.F.,,,.F. )   
	TButton():New(170, 070, "Gerar"        	, oDlg,{|| mlr25gera()	 	},40,020,,,.F.,.T.,.F.,,.F.,,,.F. )   
	TButton():New(170, 390, "Sair"            , oDlg,{|| oDlg:end()	   },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg CENTERED  

	// ProcData 04/2023 - Chamada para fechar arquivo de trabalho
	u_arqtrb ("FechaTodos",,,, @_aArqTrb) 	

return 


Static Function Disp()

	RecLock("TMP",.F.)
	if Marked("P3_SABFERI")
		TMP->P3_SABFERI := cMark
	else          
		TMP->P3_SABFERI := ""
	endif             
	msunlock() 
	oMark:oBrowse:Refresh()

Return .t.      


Static Function mlr25Gera()

	SP3->(dbsetorder(1))
	TMP->(dbgotop()) 

	while TMP->(!eof()) 
		if !empty(TMP->P3_SABFERI)   	
			marc := .t.

			SP3->(dbsetorder(1))		
			if SP3->(dbseek(xfilial('SP3')+dtos(TMP->P3_DATA)))
				reclock('SP3',.f.)								
				SP3->P3_SABFERI := 'S'													
				msunlock()			
			endif			
		endif
		TMP->(dbskip())
	enddo

	if marc
		msgbox('Sabado feriado apontado com sucesso!',"CONFIRMAÇÃO","INFO")  
	else
		msgbox('Não houveram feriados selecionados!',"OPERACAO NULA",'INFO')  
	endif	

	oDlg:end()
return .t.    
