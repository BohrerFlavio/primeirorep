#INCLUDE "rwmake.ch"
#INCLUDE 'protheus.ch'
#INCLUDE 'dbtree.ch' 
#INCLUDE "TOTVS.CH" 
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF227    º Autor ³ Giuliano Forgiariniº Data ³  16/09/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Mapa de acompanhamento de produção contra-pedidos de venda º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e Porcionados                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF227()      

	Private aBrowse1  := {}
	Private _cGrpMoi  := GetMV('SI_GRPMOI')
	Private cPerg := "GJF227"


	If !Pergunte(cPerg,.T.)
		Return
	Endif    
	//      1         2          3         4      5        6          7           8              9             10               11         12   13
	aHeader1  := {'Pre-pedido','Data PP','Item','Cod. Cliente','Loja','Nome','Produto','Descrição','Quant. Peso','Quant. Caixas','Solic.Prod.?','Dt. Ger. OP','OP','Lote','Dt. Prod. Lote'}
	aLargCol1 := {40          ,  40     ,20    ,40            ,20    ,90    ,40       ,70         ,40           ,40             ,20               ,40          ,50   ,50   ,40}

	DEFINE DIALOG oDlg TITLE "Mapa de Pedidos de Venda X Produção Porcionados" FROM 020,105 To 500,1350 PIXEL

	oBrowse1 := TCBrowse():New(005,005,610,200,,aHeader1,aLargCol1,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )  

	GeraTMP()

	@ 220,350  BUTTON 'Sair'  SIZE 40,10 ACTION oDlg:end() OBJECT oBtn1

	ACTIVATE DIALOG oDlg CENTERED   



Static Function GeraTMP()
	aBrowse1 := {}

	ZZ4->(DbsetOrder(10))
	if ZZ4->(DbSeek(xfilial('ZZ4') + dtos(mv_par01),.T.))
		while ZZ4->(!eof()) .and. ZZ4->ZZ4_FILIAL = xfilial('ZZ4') .and. ZZ4->ZZ4_DATA <= mv_par02  

			if  ZZ4->ZZ4_TIPOPR <> 'P' .or. ZZ4->ZZ4_STATUS $ 'E/F'
				ZZ4->(DbSkip()) 
				loop
			endif

			ZZ5->(DbSetOrder(1))
			if  ZZ5->(DbSeek(xfilial('ZZ5') + ZZ4->ZZ4_NUM))
				While ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = xfilial('ZZ5') .and. ZZ5->ZZ5_NUM = ZZ4->ZZ4_NUM     

					if  mv_par03 = 1
						if empty(ZZ5->ZZ5_SOLPRO)
							ZZ5->(DbSkip())
							loop
						endif  
					elseif mv_par03 = 2
						if !empty(ZZ5->ZZ5_SOLPRO)
							ZZ5->(DbSkip())
							loop
						endif  
					endif

					aadd(aBrowse1,{ZZ5->ZZ5_NUM,;
					dtoc(ZZ4->ZZ4_DATA),;
					ZZ5->ZZ5_ITEM,;
					ZZ4->ZZ4_CODCLI,;
					ZZ4->ZZ4_LOJA,;
					ZZ4->ZZ4_NOME,;
					alltrim(ZZ5->ZZ5_COD),;
					ZZ5->ZZ5_DESC,;
					transform(ZZ5->ZZ5_QPPESO,'@E 999,999.99'),;
					transform(ZZ5->ZZ5_QPCAIX,'@E 999,999'),;
					iif(!empty(ZZ5->ZZ5_SOLPRO),'Sim','Nao'),;
					space(10),;
					space(10),;
					space(10),;
					space(10)})

					ZAR->(DbSetOrder(5))  
					if ZAR->(DbSeek(xfilial('ZAR') + ZZ5->(ZZ5_NUM+ZZ5_ITEM)))  

						while ZAR->(!eof()) .and. ZAR->ZAR_FILIAL = xfilial('ZAR') .and. ZAR->(ZAR_PREPED+ZAR_ITEMPP) =  ZZ5->(ZZ5_NUM+ZZ5_ITEM)                        

							//{'Pre-pedido','Item','Cod. Cliente','Loja','Nome','Produto','Descrição','Quant. Peso','Quant. Caixas','Solic.Produção?','Dt.Ger.OP','OP','Lote','Dt.Prod'} 

							_cDtProd := dtoc(fBuscaCPO('ZAU',1,xfilial('ZAU') + ZAR->ZAR_LOTE,'ZAU_DTPROD'))

							_nPos := aScan(aBrowse1,{|aVal|aVal[1] = ZAR->ZAR_PREPED .and. aVal[3] = ZAR->ZAR_ITEMPP})	

							if _nPos <> 0
								aBrowse1[_nPos,12] := dtoc(ZAR->ZAR_DATA)
								aBrowse1[_nPos,13] := ZAR->ZAR_NUM										   
								aBrowse1[_nPos,14] := ZAR->ZAR_LOTE 
								aBrowse1[_nPos,15] := _cDtProd
							endif

							ZAR->(Dbskip())														
						enddo
					endif
					ZZ5->(DbSkip())
				enddo																	
			endif
			ZZ4->(DbSkip())
		enddo
	else
		aadd(aBrowse1,{'','','','','','','','','','','','','','',''})
	endif

	oBrowse1:SetArray(aBrowse1)

	// Monta a linha a ser exibina no Browse
	oBrowse1:bLine := {||{aBrowse1[oBrowse1:nAt,01],aBrowse1[oBrowse1:nAt,02],aBrowse1[oBrowse1:nAt,03],;
	aBrowse1[oBrowse1:nAT,04],aBrowse1[oBrowse1:nAT,05],aBrowse1[oBrowse1:nAT,06],;
	aBrowse1[oBrowse1:nAt,07],aBrowse1[oBrowse1:nAt,08],aBrowse1[oBrowse1:nAt,09],;
	aBrowse1[oBrowse1:nAT,10],aBrowse1[oBrowse1:nAT,11],aBrowse1[oBrowse1:nAT,12],;
	aBrowse1[oBrowse1:nAT,13],aBrowse1[oBrowse1:nAT,14],aBrowse1[oBrowse1:nAT,15]}}

	oBrowse1:nScrollType := 1
	oBrowse1:bLDblClick   := {|| ResLote(aBrowse1[oBrowse1:nAt,13])}
	oBrowse1:DrawSelect()
	oBrowse1:refresh()
	oDlg:refresh()
return


Static Function ResLote(_cLote)
	Local _cResL := ''



	ZAU->(DbSetOrder(1)) 
	if  ZAU->(DbSeek(xfilial('ZAU') + _cLote))

		_cResL := 'PESO: ' + chr(13) + chr(10)
		_cResL += 'Previsto   : ' + alltrim(transform(ZAU->ZAU_QPPESO,'@E 999,999.99')) + chr(13) + chr(10)
		_cResL += 'Realizado : ' + alltrim(transform(ZAU->ZAU_QRPESF,'@E 999,999.99')) + chr(13) + chr(10)	

		_cResL += 'CAIXAS: ' + chr(13) + chr(10)
		_cResL += 'Previsto   : ' + alltrim(transform(ZAU->ZAU_QPCAIX,'@E 999,999')) + chr(13) + chr(10)
		_cResL += 'Realizado : ' + alltrim(transform(ZAU->ZAU_QRCAIF,'@E 999')) + chr(13) + chr(10)	

		_cResL += 'UNIDADES: ' + chr(13) + chr(10)
		_cResL += 'Previsto   : ' + alltrim(transform(ZAU->ZAU_QPUNI,'@E 999,999')) + chr(13) + chr(10)
		_cResL += 'Realizado : ' + alltrim(transform(ZAU->ZAU_QRUNI,'@E 999,999')) + chr(13) + chr(10)	


		@ 00,00 To 130,220 Dialog oDlgMemo Title "Resultados:"
		@ 005,005 Get _cResL Size 100,040 MEMO Object oMemo      
		@ 050,025 BUTTON botao1 PROMPT "Fechar" OF oDlgMemo PIXEL ACTION oDlgMemo:end()
		Activate Dialog oDlgMemo  CENTERED


	endif

return
