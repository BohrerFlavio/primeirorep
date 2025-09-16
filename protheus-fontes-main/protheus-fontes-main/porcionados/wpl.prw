#INCLUDE "topconn.ch"         
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"                                                                           
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch" 
#INCLUDE "tbiconn.ch"
#INCLUDE "totvs.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WPL     ºAutor  ³Giuliano Forgiarini º Data ³  08/06/15     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Codigo fonte do JOB para atualização dos dados de produção  º±±
±±º          ³(envio e recebimento) dos equipamentos WPL Bizerba          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Linha de embalaegens primárias porcionados                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function WPL()
	Local i
	Private _aLotes := {}           
	Privat _Linha   := ''

	RPCSetType(3) //não consome licença.

	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" MODULO "PCP"

	_aLotes := u__WPLGet()      

	for i := 1 to len(_aLotes)     

		ZAU->(DbSetOrder(1))
		if  ZAU->(DbSeek(xfilial('ZAU')+_aLotes[i,3]))  
			if !empty(ZAU->ZAU_LINW)
				reclock('ZAU',.f.)
				ZAU->ZAU_QRUNI  := val(_aLotes[i,13])
				ZAU->ZAU_FLWPL  := val(_aLotes[i,29])
				ZAU->ZAU_TIPSEC := val(_aLotes[i,20]) 
				ZAU->ZAU_STATW  := _aLotes[i,08] 

				if ZAU->ZAU_STATW = 'E'   
					_Linha := ZAU->ZAU_LINW		
					ZAU->ZAU_LINW := ''
				endif
				msunlock()

				if ZAU->ZAU_DELWPL <> 'S'   

					if ZAU->ZAU_CTRLP = 'E'
						u__WPLDel(_Linha)
					elseif ZAU->ZAU_CTRLP = 'T'   

						_nT := round(ZAU->ZAU_QPUNI * ZAU->ZAU_TOLER/100,0)     

						if ZAU->ZAU_QRUNI >= _nT
							u__WPLDel(_Linha) 			
						endif

					endif 
				endif	

			endif  

		endif     

	next

	RESET ENVIRONMENT

Return


//Função para consumo do método getDataZAU010 como objetivo de gerar 
//um vetor com os lotes  para atualização da tabela ZAU010 on-line
User Function _WPLGet()

	Local _aRet := {} 
	Local i

	//O campo ZAU_FLWPL: -1 = Todos, 0 = por enviar, 1 = em produção, 2 = em pausa, 3 = finalizado
	// O withSchema é um opcional tecnico para o integrador     


	BEGIN SEQUENCE

		_oWS := WSbizFSWebService():New()
		_oWS:nZAU_FILIAL := 1
		_oWS:nZAU_LINHA  := 0
		_oWS:nDIAS       := 1
		_oWS:cZAU_NUM    := '0'  
		_oWS:nZAU_FLWPL  := -1
		_oWS:nwithSchema := 0
		_oWS:getDataZAU010() 

		oXML := _oWS:oWSgetDataZAU010Result 

		oTipo := XmlGetChild(oXML:_GETDATAZAU010RESULT:_DOCUMENTELEMENT, 2 )   

		_cTipo := valtype(oTipo)

		if _cTipo <> "U"
			if _cTipo == "O"
				XmlNode2Arr( oXML:_GETDATAZAU010RESULT:_DOCUMENTELEMENT:_ERP_ZAU010_FILTER, "_ERP_ZAU010_FILTER" )
			endif

			oXML := XmlChildEx(oXML:_GETDATAZAU010RESULT:_DOCUMENTELEMENT, "_ERP_ZAU010_FILTER")

			for i := 1 to len(oXML)    
				aadd(_aRet,{oXML[i]:_SID:Text,       oXML[i]:_ZAU_FILIAL:Text, oXML[i]:_ZAU_NUM:Text,   oXML[i]:_ZAU_DTPROD:Text, oXML[i]:_ZAU_COD:Text,   oXML[i]:_ZAU_PLU:Text,;
				oXML[i]:_ZAU_LINHA:Text, oXML[i]:_ZAU_STATUS:Text, oXML[i]:_ZAU_PRCCLI:Text,oXML[i]:_ZAU_QPPESO:Text, oXML[i]:_ZAU_QRPESO:Text,oXML[i]:_ZAU_QPUNI:Text,;
				oXML[i]:_ZAU_QRUNI:Text, oXML[i]:_ZAU_QPCAIX:Text, oXML[i]:_ZAU_QRCAIX:Text,oXML[i]:_ZAU_TARA:Text,   oXML[i]:_ZAU_IMCBAR:Text,oXML[i]:_ZAU_PESBAN:Text,;
				oXML[i]:_ZAU_CODCLI:Text,oXML[i]:_ZAU_TIPSER:Text, oXML[i]:_ZAU_IMPROD:Text,oXML[i]:_ZAU_IMLOTE:Text, oXML[i]:_ZAU_IMTARA:Text,oXML[i]:_ZAU_IMVAL:Text,;
				oXML[i]:_ZAU_IMPRC:Text, oXML[i]:_ZAU_IMPCOM:Text, oXML[i]:_ZAU_LAYETQ:Text,oXML[i]:_ZAU_FLERP:Text,  oXML[i]:_ZAU_FLWPL:Text, oXML[i]:_ModifiedDate:Text})
			next
		endif

	END SEQUENCE

Return _aRet



//Função para consumo do método DeletePLUCustomer_toDevice como objetivo de 
//excluir o PLU da maquina apontada
User Function _WPLDel(_linha)
	Local _nDev       := 0
	Local _lStatusDel := .f.

	if _linha = '001'
		_nDev := 1
	else
		_nDev := 2
	endif 

	//Consumo do metodo DeletePLUCustomer_toDevice 

	BEGIN SEQUENCE

		_oWS:ndeviceID   := _nDev
		_oWs:nPlu        := val(ZAU->ZAU_COD)
		_oWs:nCustomerID := 0

		_oWS:DeletePLUCustomer_toDevice()

		_lStatusDel := _oWs:lDeletePLUCustomer_toDeviceResult

		if _lStatusDel  
			reclock('ZAU',.f.)
			ZAU->ZAU_DELWPL := 'S'
			msunlock()
		endif 

	END SEQUENCE

Return
