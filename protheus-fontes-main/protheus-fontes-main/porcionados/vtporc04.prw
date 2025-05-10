#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³vtPorc03     º Autor ³Mauricio Roehrsº   Data ³  15/08/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplicação para microterminais VT-100 para rotina de        º±±
±±º          ³ saida do pulmao do refile para porcionados.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//Função para Inventario
User Function vtPorc04(_usuario)

	Local  _cPar01    := '1'
	Private _cModelo  := ''
	Private _lOk      := .t.
	Private _cCod 	   := ''
	Private lin := 1

	ZAA->(DbSetOrder(2))
	ZAA->(DbSeek(xfilial('ZAA')+_usuario))

	if ZAA->ZAA_APL15 <> 'S'
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


	while _lOk

		VTRead

		@ 01,05 VTSay "Selecione o Destino"
		@ 02,05 VTSay "1-Prod | 2-Desoss: [ ]"
		@ 02,25 VTGet _cPar01 Pict "@!" VALID !empty(_cPar01) .and. (_cPar01 $ '1/2')

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF                                       

		aponta(_cPar01)

		VTClearBuffer()		
	enddo

	VTClear()
	VTClearBuffer()

Return


Static Function aponta(_cDest)
	VTClear()
	VTClearBuffer()

	while _lOk

		_cCod := Space(11)

		VTRead

		@ 01,07    VTSay "Saida do Pulmao"
		@ 02,08    VTSay "Destino: "+ iif(_cDest =='1','Prod.','Desos')
		@ lin+2,07 VTSay "Codigo da Caixa"
		@ lin+3,08 VTSay "[           ]"
		@ lin+3,09 VTGet _cCod Pict "@!" VALID leitura(_cDest)

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF                                       

		VTClearBuffer()		
	enddo

	VTClear()
	VTClearBuffer()

Return

Static Function leitura(_cDest)

	if empty(_cCod)
		return .t.
	endif      

	ZAS->(dbSetOrder(1))
	ZAS->(dbGoTop())
	if !ZAS->(dbSeek(xFilial('ZAS')+_cCod))
		mensagem('Caixa inexistente!')      
		return .t.
	else                        

		//verifica se produto está em estoque
		if !empty(ZAS->ZAS_DATAS) .or. !empty(ZAS->ZAS_HORAS)		
			mensagem('Caixa fora de estoque!')       
			return .t.	
		endif	   

		//esta rotina não permite dar saida de materia prima
		if ZAS->ZAS_TIPO == 'MP'
			mensagem('Tipo de Prod. nao permitido!')		
			return .t.	
		endif

		//se ja for carne refilada e tentar enviar para desossa tranca.
		if ZAS->ZAS_TIPO == 'PP' .and. _cDest == '2'
			mensagem('Nao permitido retorno','De Carne Refil. p/ desossa!')		
			return .t.	     	
		endif


		//se for quebra e tentar produzir tranca, pois isso é moida e deverá ser consumido em outra rotina.	
		//if ZAS->ZAS_TIPO $ ('QR/QF') .and. _cDest == '1'    
		//mensagem('Prod. Moida utilize Cons. Moida')
		//return .t.	                     
		//endif		                   

		grava(_cCod, _cDest)
		mensagem(ZAS->ZAS_DESC, "BAIXADO!")

	endif

return .t.

Static Function grava(_cod, _cDest)

	ZAS->(dbSetOrder(1))
	ZAS->(dbGoTop())
	if ZAS->(dbSeek(xFilial('ZAS')+_cod))	
		reclock('ZAS',.f.)
		ZAS->ZAS_DATAS := date()
		ZAS->ZAS_HORAS := time()		
		ZAS->ZAS_DEST  := iif(_cDest == '1','P','D')	
		msunlock()	
		
		u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, iif(_cDest == '1','Saída para Produção','Saída para Desossa'), ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))
			
	endif     

return                              


Static Function mensagem(_cMens,_cMens2) 

	Local _branco := space(50)

	VTBeep(1)                  
	@lin+1,00 VTSay _branco 
	@lin+2,00 VTSay _branco 	
	@lin+3,00 VTSay _branco 
	@lin+4,00 VTSay _branco
	@lin+5,00 VTSay _branco
	@lin+6,00 VTSay _branco	 
	@lin+7,00 VTSay _branco
	@lin+8,00 VTSay _branco

	@lin+3,08 VTSay _cCod	
	@lin+4,03 VTSay _cMens 
	@lin+5,03 VtSay _cMens2

	_cCod := Space(11)      

return .f.   



