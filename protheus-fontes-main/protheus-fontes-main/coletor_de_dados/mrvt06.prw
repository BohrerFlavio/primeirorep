#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MRVT06     º Autor ³Mauricio Roehrsº ³ Data ³09/09/13	     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplicação para microterminais VT-100 para rotina de        º±±
±±º          ³ apontamento de produção na entrada/saida da desossa        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//Função para produção na entrada da desossa
User Function MRVT06(_usuario)

	Private _cModelo  := '' 
	Private _cPar01   := space(06) 		//Codigo do Produto
	Private _cPar02   := '1'       		//Destino 1 - Desossa | 2 - Charque | 3 - Moida
	Private _cPar03   := '3.700'   		//Tara
	Private _cPar04   := '1'		 		//Operação 1 - Entrada | 2 - Saida
	Private _cPar05   := space(03)      //Quantidade
	Private _cPar06   := '      '   		//Peso Bruto
	Private _lOk      := .t.
	Private prox      := 0

	dbSelectArea('SZO')
	SZO->(dbSetorder(1))  // tipo+data+sequen
	SZO->( dbSeek(xFilial('SZO')+'E'+DTOS(ddatabase) ) )
	Do While !SZO->(Eof()) .AND. SZO->ZO_DATA == ddatabase .AND. SZO->ZO_TIPO == 'E'
		prox := Val( SZO->ZO_SEQUEN )
		SZO->( dbSkip() )
	Enddo
	prox++

	ZAA->(DbSetOrder(2))
	ZAA->(DbSeek(xfilial('ZAA')+_usuario))

	if ZAA->ZAA_APL05 <> 'S'
		VTAlert('Opção negada para o usuario!','Aviso',.T.,1000,1)
		return .t.
	endif

	//Define o tamanho da Tela
	_cModelo = VTModelo()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	VTClear()
	VTClearBuffer()

	while _lOk

		@ 01,05 VTSay "PRODUCAO DESOSSA"
		@ 02,05 VTSay "Entrada/Saida"
		@ 03,05 VTSay "Parametros Iniciais:"
		@ 05,00 VTSay "Produto:    [      ]"      
		@ 06,00 VTSay "Destino:    [ ] 1:D|2:C|3:M"
		@ 07,00 VTSay "Tara:       [     ] " 
		@ 08,00 VTSay "Operacao:   [ ] 1:E|2:S"            

		@ 16,00 VTSay "ESC para Sair"	

		@ 05,13 VTGet _cPar01 Pict "@! "       valid !empty(_cPar01) .and. ValProd(_cPar01)
		@ 06,13 VTGet _cPar02 Pict "@! "       valid (_cPar02 $ '123')
		@ 07,13 VTGet _cPar03 Pict "@! 9.999"  valid (val(_cPar02) > 0.00 .and. val(_cPar02) < 9.99)  
		@ 08,13 VTGet _cPar04 Pict "@! "   	   valid (_cPar04 $ '12')
		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		while _lOk
			@ 09,00 VTSay "Quantidade: [   ]"   
			@ 10,00 VTSay "Peso Bruto: [      ]"   
			@ 09,13 VTGet _cPar05 Pict "@!"			   valid CompQnt()
			@ 10,13 VTGet _cPar06 Pict "@! 999.99"     valid ValPes()
			VTRead    

			If (VTLastKey() == 27)
				VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
				_cPar01 := space(6)	 
				_cPar05 := space(3)
				_cPar06 := '      ' 				
				VTClear()
				VTClearBuffer()	 		  
				exit       
			else
				VTAlert('Confirma apontamento? (Enter:Sim,Esc:Nao)','Atencao',.T.)

				If (VTLastKey() == 27)
					VTAlert('Operação Cancelada!','Aviso de Encerramento(04)',.T.,100,1)
					_cPar01 := space(6)	 
					_cPar05 := space(3)
					_cPar06 := '      ' 					
					VTClear()
					VTClearBuffer()	 		  
					exit     				
				else
					if  empty(_cPar05) .or. empty(_cPar06)
						VTAlert('Nenhum campo preenchido!','Operação cancelada!',.T.,100,1) 
					else
						//Produz(_quant,_pesoB, _tara,  _prod,  _dest,  _tipo)
						Produz(_cPar05,_cPar06,_cPar03,_cPar01,_cPar02,_cPar04)
					endif
				endif
			endif

			_cPar05 := space(3)
			_cPar06 := '      '

		enddo	 

	enddo

return 

Static Function ValProd(_cProd)
	Local _lOk := .f.

	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))
	SB1->(DbGoTop())
	if SB1->(DbSeek(xFilial('SB1') + padl(alltrim(_cProd),6,'0')))
		if SB1->B1_TIPO $ 'PA/PR' .and. SB1->B1_SEGUM = 'PC' .and. SB1->B1_MSBLQL = '2' 
			_cPar01 := padl(alltrim(_cPar01),6,'0')
			@ 05,13 VTSay _cPar01
			_lOk := .t.		
		endif
	endif									   

return _lOk  

Static Function CompQnt()	 

	if val(_cPar05) <= 0 .or. empty(_cPar05)
		return .f.  
	endif

	_cPar05 := padl(alltrim(_cPar05),3,'0')
	@ 09,13 VTSay _cPar05	 


return .t. 

Static Function ValPes()    


	If (VTLastKey() == 5)  //SE SETA PRA CIMA 
		_cPar05 := space(3)
		_cPar06 := '      ' 					 											
		@ 09,13 VTSay _cPar05
		@ 10,13 VTSay _cPar06
	endif  

	If (VTLastKey() == 27)
		VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
		_cPar01 := space(6)	 
		_cPar05 := space(3)
		_cPar06 := '      ' 				
		VTClear()
		VTClearBuffer()	 		            
		@ 05,13 VTGet _cPar01	   									
	endif


	if (val(_cPar06) <= 0.00) .or. (val(_cPar06) > 1000) .or. (empty(_cPar06))
		return .f.
	endif	

return .t.


Static Function Produz(_quant,_pesoB,_tara,_prod,_dest,_tipo)     

	RECLOCK('SZO',.t.)
	SZO->ZO_FILIAL  := xFilial('SZO')
	SZO->ZO_HORA    := time()
	SZO->ZO_QUANT   := val(_quant)
	SZO->ZO_PESOL   := val(_pesob) - val(_tara)     
	SZO->ZO_PROD    := _prod
	SZO->ZO_DEST    := iif(_dest = '1','D',iif(_dest = '2','C','M'))
	SZO->ZO_DATA    := date()
	SZO->ZO_PESOB   := val(_pesob)
	SZO->ZO_TARA    := val(_tara)
	SZO->ZO_TIPO    := iif(_tipo = '1','E','S')
	SZO->ZO_SEQUEN  := STRZERO(prox,6)
	MsUnlock()  
	prox++
//endif


