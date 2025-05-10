#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI27     ºAutor  ³Mauricio Roehrs     º Data ³  13/03/17   º±±                       
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Rotina para leitura do arquivo de inventario para         º±±
±±º          ³  preenchimento dos respectivos campos na tabela SB9        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SPED FISCAL / CONTABILIDADE                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function dti27()

	Private cPerg := "DTI27"

	if !pergunte(cPerg,.t.)
		return
	endif


	dbUseArea( .T.,"ctreecdx", "\system\"+alltrim(mv_par01)+".dtc","INV", .T., .F. )

	Processa({||procReg()} ,"PROCESSAMENTO DE REGISTROS...","Processando Dados dos Produtos...")

	msgbox('Ajuste dos Produtos Finalizado com Sucesso!','Ajuste de Inventário','INFO')

return


Static Function procReg()

	dbSelectArea('SB1')
	dbSelectArea('SB9')

	INV->(dbGoTop()) 

	ProcRegua(INV->(RecCount()))

	while INV->(!eof())

		//IncProc('Processando dados do produto: ' + INV->PRODUTO)
		IncProc()

		if empty(INV->PRODUTO)
			INV->(dbSkip())
			loop	    
		endif

		_cLocPad := fBuscaCpo('SB1',1,xFilial('SB1') + alltrim(INV->PRODUTO),'B1_LOCPAD')	
		_cTipo   := fBuscaCpo('SB1',1,xFilial('SB1') + alltrim(INV->PRODUTO),'B1_TIPO')		

		if !(_cTipo $ 'PA/PP')
			INV->(dbSkip())
			loop    	         
		endif

		SB9->(dbSetOrder(1))
		SB9->(dbGoTop())
		if !SB9->(dbSeek(xFilial('SB9') + padr(INV->PRODUTO,15," ")+alltrim(_cLocPad)+dtos(mv_par02)))

			reclock('SB9',.t.)   
			SB9->B9_FILIAL := xFilial('SB9')                              
			SB9->B9_COD    := INV->PRODUTO
			SB9->B9_DATA   := mv_par02
			SB9->B9_LOCAL  := _cLocPad
			SB9->B9_CUSTD  := INV->VALOR_UNIT
			SB9->B9_CM1    := INV->VALOR_UNIT
			SB9->B9_QINI   := INV->QUANTIDADE
			SB9->B9_VINI1  := INV->TOTAL 								
			msunlock()

		else  

			reclock('SB9',.f.)
			SB9->B9_CUSTD := INV->VALOR_UNIT
			SB9->B9_CM1   := INV->VALOR_UNIT
			SB9->B9_QINI  := INV->QUANTIDADE
			SB9->B9_VINI1 := INV->TOTAL 						
			msunlock()

		endif
		INV->(dbSkip())
	enddo

	DbCloseArea('INV')
	DbCloseArea('SB1')
	DbCloseArea('SB9')
return
