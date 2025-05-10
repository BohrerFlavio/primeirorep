#INCLUDE "rwmake.ch"
#INCLUDE 'protheus.ch'
#INCLUDE 'dbtree.ch' 
#INCLUDE "TOTVS.CH" 
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF221    º Autor ³ Giuliano Forgiariniº Data ³  18/08/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Consulta de Lotes de produção                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP porcionados                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF221()          

	Private _oFont   := tFont():New("courier new",,-14,,.t.,,,,)   
	Private _cGrpMoi := GetMV('SI_GRPMOI')
	Private  _cGet1  := space(10)  
	Private  _cMemo  := ""

	DEFINE DIALOG oDlg TITLE "Consulta de Lotes de Produção" FROM 180,180 TO 700,800 PIXEL

	_oSay0   := TSay():New(05,20, {|| "Lote:"}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)  

	_oGet1   := TGet():New(05,40, {|u| If(PCount() > 0, _cGet1:= u, _cGet1)}, oDlg,, 009, "@!",{||Leitura()}, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet1,,,,.t.,)

	_oMemo   := TMultiget():New(55,15,{|u|if(Pcount()>0,_cMemo:=u,_cMemo)},oDlg,280,130,_oFont,,,,,.T.,,,,,,.t.)

	_oBtn1 := TButton():New(235,260, "Sair"    , oDlg,{||oDlg:end()},40,20,,,.F.,.T.,.F.,,.F.,,,.F. ) 

	ACTIVATE DIALOG oDlg CENTERED  

Return                                             

//Função de validação das leituras de caixas e pallets
Static Function Leitura()
	Local _lRet := .f.
	Local i

	//Se o campo estiver em branco
	if empty(_cGet1)
		_lRet := .t.
	else

		//Se o tamanho do codigo for menor que 10 digitos
		if len(alltrim(_cGet1)) < 10
			_lRet := .f.
		else
			ZAU->(DbSetOrder(1))
			if ZAU->(DbSeek(xfilial('ZAU')+_cGet1))   

				DbSelectArea('SB1')
				_cGrupo := fBuscaCPO('SB1',1,xfilial('SB1')+ZAR->ZAR_COD,'B1_GRUPO')

				_cMemo :=  padc('[ LOTE DE PRODUÇÃO N.:' + ZAU->ZAU_NUM +  ']',280,' ')	+ chr(13) + chr(10)
				_cMemo += Replicate("=",065) + chr(13) + chr(10)
				_cMemo += "Codigo Produto:            " + ZAU->ZAU_COD + chr(13) + chr(10)
				_cMemo += "Descrição Produto:         " + ZAU->ZAU_DESC + chr(13) + chr(10)
				_cMemo += "Data de Produção:          " + dtoc(ZAU->ZAU_DTPROD) + chr(13) + chr(10)    
				_cMemo += Replicate("-",065) + chr(13) + chr(10)	
				if !(_cGrupo $ _cGrpMoi)	
					_cMemo += "Consumo de Materia Prima:  " + chr(13) + chr(10)    
					_cMemo += "Previsto:                  " + transform(ZAU->ZAU_QTDMP,'@E 999,999.99') + chr(13) + chr(10)    
					_cMemo += "Realizado:                 " + transform(ZAU->ZAU_QTDMP,'@E 999,999.99') + chr(13) + chr(10)        
					_cMemo += "Status Fatiadoras:         " + iif(ZAU->ZAU_STATF = 'A','Stand by',iif(ZAU->ZAU_STATF = 'S','Parado',iif(ZAU->ZAU_STATF = 'R','Em Processo','Produção encerrada'))) + chr(13) + chr(10) 				 			
					_cMemo += iif(ZAU->ZAU_STATF $ 'R/S','Linha :' + ZAU->ZAU_LINF,'') + chr(13) + chr(10)   
				else
					_cMemo += "Receita Carne Moida:  " + chr(13) + chr(10)       
					ZAV->(DbSetOrder(2))  
					if ZAV->(DbSeek(xfilial('ZAV')+ZAU->ZAU_NUM))           
						while ZAV->(!eof()) .and. ZAV->ZAV_FILIAL = xfilial('ZAV') .and. ZAV->ZAV_NUM = ZAU->ZAU_NUM
							_cDescRec := fBuscaCPO('SB1',1,xfilial('SB1')+ZAV->ZAV_COD,'B1_DESCRED')
							_cMemo += ZAV->ZAV_ITEM + "   " + alltrim(ZAV->ZAV_COD) + ": " + _cDescRec + chr(13) + chr(10)                                               
							_cMemo += "Previsto:                  " + transform(ZAV->ZAV_QPPESO,'@E 999,999.99') + chr(13) + chr(10)    
							_cMemo += "Realizado:                 " + transform(ZAV->ZAV_QRPESO,'@E 999,999.99') + chr(13) + chr(10)   					   
							ZAV->(DbSkip())
						enddo
					endif
				endif
				_cMemo += Replicate("-",65) + chr(13) + chr(10)	
				_cMemo += "Produção WPL (Unidades):   " + chr(13) + chr(10)  
				_cMemo += "Previsto:                  " + transform(ZAU->ZAU_QPUNI,'@E 999,999.99') + chr(13) + chr(10)    
				_cMemo += "Realizado:                 " + transform(ZAU->ZAU_QRUNI,'@E 999,999.99') + chr(13) + chr(10)     
				_cMemo += "Status WPL:                " + iif(ZAU->ZAU_STATW = 'A','Stand by',iif(ZAU->ZAU_STATW = 'S','Parado',iif(ZAU->ZAU_STATW = 'R','Em Processo','Produção encerrada'))) + chr(13) + chr(10) 				 
				_cMemo += iif(ZAU->ZAU_STATW $ 'R/S','Linha :' + ZAU->ZAU_LINW,'') + chr(13) + chr(10)   
				_cMemo += Replicate("-",65) + chr(13) + chr(10)	
				_cMemo += "Produção Testeiras:        "  + chr(13) + chr(10)  
				_cMemo += "Previsto Caixas:           " + transform(ZAU->ZAU_QPCAIX,'@E 999,999.99') + chr(13) + chr(10)    
				_cMemo += "Previsto Peso:             " + transform(ZAU->ZAU_QPPESO,'@E 999,999.99') + chr(13) + chr(10)    
				_cMemo += "Realizado Caixas:          " + transform(ZAU->ZAU_QRCAIX,'@E 999,999.99') + chr(13) + chr(10)      
				_cMemo += "Realizado Peso:            " + transform(ZAU->ZAU_QRPESO,'@E 999,999.99') + chr(13) + chr(10) 
				_cMemo += "Status Testeira:           " + iif(ZAU->ZAU_STATT = 'A','Stand by',iif(ZAU->ZAU_STATT = 'S','Parado',iif(ZAU->ZAU_STATT = 'R','Em Processo','Produção encerrada'))) + chr(13) + chr(10) 		
				_cMemo += iif(ZAU->ZAU_STATT $ 'R/S','Linha :' + ZAU->ZAU_LINT,'') + chr(13) + chr(10)   		
				_cMemo += Replicate("-",65) + chr(13) + chr(10)
				if !(_cGrupo $ _cGrpMoi)			             
					_aQuebras := {}
					_cMemo += "Quebras:  " + chr(13) + chr(10) 
					ZAS->(DbSetOrder(9))
					if ZAS->(DbSeek(xfilial('ZAS')+ZAU->ZAU_LOTE + 'QF'))
						while ZAS->(!eof()) .and. ZAS->ZAS_FILIAL = xfilial('ZAS') .and. ZAS->ZAS_LOTE = ZAU->ZAU_NUM  .and. ZAS->ZAS_TIPO $ 'QR/QF'
							if ZAS->ZAS_TIPO $ 'QR/QF'
								_nPos := aScan(_aQuebras,{|aVal|aVal[1] = ZAS->ZAS_TIPO})
								if _nPos <> 0
									_aQuebras[_nPos,2] += ZAS->ZAS_PESOL         
								else
									aadd(_aQuebras,{ZAS->ZAS_TIPO,ZAS->ZAS_PESOL}) 							
								endif
							endif	
							ZAS->(DbSkip())
						enddo
						for i := 1 to len(_aQuebras)
							_cMemo += iif(_aQuebras[i,1] = 'QF','Quebra Fatiadoras: ' + transform(_aQuebras[i,2],'@E 999,999.99'),;
							'Quebra Refile:     ' + transform(_aQuebras[i,2],'@E 999,999.99')) + chr(13) + chr(10)				
						next
					endif
				endif

				_cMemo += Replicate("=",65) + chr(13) + chr(10)
			else
				_cMemo := " Lote não encontrado!"
			endif
			_oMemo:refresh()

		endif
	endif

	_cGet1 := space(10)
	_oGet1:CtrlRefresh()   

return _lRet

