#INCLUDE "TOTVS.CH"
#INCLUDE 'protheus.ch'
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI221    º Autor ³ Flávio Bohrerº Data ³  23/02/25         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de recebimento de PR (Produto de Revenda)           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Recebimento nos Congelados                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function DTI221()
Private  _cMemo   := ""
Private  _cGet2   := space(06) // Peso Bruto da caixa
Private  _dGet3   := stod("") // Data de Produção
Private  _cGet4   := SPACE(2) // Local - Câmara 

Private cPerg     := "GJF215"
Private _oFont    := tFont():New("courier new",,-14,,.t.,,,,)
Private _oFont2   := tFont():New("courier new",,-22,,.t.,,,,)
Private _aItComb  := {}
Private _cCombo1  := ''

Private _cSay5    := 'Peso Bruto Caixa:'
Private _cSay6    := 'Tara Caixa: '

Private _cSay4    := 'Codigo P.Revenda:'

Private _cSay8    := 'Data de Produção:'
Private _cSay10   := 'Qtde: '


if !pergunte(cPerg,.t.)
		return
endif

_cSay6 += transform(mv_par01,'@E 9.999')
MontaCmb()  

DEFINE DIALOG oDlg TITLE "Recebimento de Produto de Revenda " FROM 180,180 TO 750,800 PIXEL

/* Parte Superior - Cabeçalho */
_oSay0   := TSay():New(10,24, {|| "Operação de recebimento"}, oDlg,, _oFont2,,,, .T.,, CLR_WHITE, 200, 20)
_oSay1   := TSay():New(22,34, {|| " Produto P/Revenda "}, oDlg,, _oFont2,,,, .T.,, CLR_WHITE, 200, 20)
_oSay2   := TSay():New(05,220, {|| "Local Destino: "}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
_oGet4   := TGet():New(05,280, {|u| If(PCount() > 0, _cGet4:= u, _cGet4)}, oDlg,, 009,PesqPict("NNR","NNR_CODIGO"),, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,"NNR", _cGet4,,,,.t.,.f.)


/* Corpo - Centro */
_oMemo   := TMultiget():New(55,15,{|u|if(Pcount()>0,_cMemo:=u,_cMemo)},oDlg,280,130,_oFont,,,,,.T.,,,,,,.t.)

/* Parte Inferior / Botões */

// Código do Produto p/Revenda 
_oSay4   := TSay():New(220,015, {||_cSay4}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
_oCombo1 := TComboBox():New(216,140,{|u|if(PCount()>0,_cCombo1:=u,_cCombo1)}, _aItComb ,150,20,oDlg,,{||SetProd(_cCombo1)},,,,.T.,,,,,,,,,'_cCombo1')

// Peso Bruto Caixa - Descrição
_oSay5   := TSay():New(200,015, {||_cSay5} , oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
_oGet2   := TGet():New(200,100, {|u| If(PCount() > 0, _cGet2:= u, _cGet2)}, oDlg,, 009, "@E 99.999",, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet2,,,,.t.,)

// Tara da Caixa - Descrição
_oSay6   := TSay():New(200,150, {||_cSay6} , oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)


// Data de Produção - Descrição 
_oSay8   := TSay():New(235,015, {||_cSay8}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 100)
_oGet3   := TGet():New(235,090, {|u| If(PCount() > 0,_dGet3:=u,_dGet3)}, oDlg,, 009, "@D 99/99/99",, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,,"_dGet3",,,,.t.,)



_oBtn1 := TButton():New(260,200, "Produzir", oDlg,{||Produzir()},40,20,,,.F.,.T.,.F.,,.F.,,,.F. )
_oBtn2 := TButton():New(260,260, "Sair"    , oDlg,{||oDlg:end()},40,20,,,.F.,.T.,.F.,,.F.,,,.F. )

ACTIVATE DIALOG oDlg CENTERED

Return



Static Function Produzir()
    _nPesoL := val(_cGet2) - mv_par01
	lok := '.T.'
    //   MessageBox("Iniciando Função Produzir !!",,0)
    
    DbSelectArea('SB1')
	DbSetOrder(1)
    DbSeek(xfilial('SB1')+_cCombo1)
    
    _cFarm := GetAdvFval('SBM','BM_FARM',FWxfilial('SBM')+SB1->B1_GRUPO,1)
   
	// Se computador não cadastrado não produzir e avisar na tela 
	_cEst := getComputerName()
	_cUsuario := cUserName
	dbselectarea('ZAM')
	ZAM->(dbSetOrder(2))
	If !(ZAM->(dbSeek(xFilial('ZAM') + alltrim(_cEst))))
	 	
		_cMemo :=  padc('[ PRODUÇÃO DE CAIXA PR ]',68,' ')	+ chr(13) + chr(10)
		_cMemo += Replicate("=",68) + chr(13) + chr(10)
		_cMemo += "!!!Computador não cadastrado para produzir !!   "+ chr(13) + chr(10)
		_cMemo += "Solicite ao setor de TI o cadastro do COMPUTADOR-"+_cEst+ chr(13) + chr(10)   
		_cMemo += " !!!!  Caixa não vai ser IMPRESSA  !!!!  "+ chr(13) + chr(10)
		_cMemo += Replicate("=",68) + chr(13) + chr(10)
		
		SomErr()

		Return
	
	endif

    _cID :=  GetSx8num('SZ8','Z8_ID')
	ConfirmSx8()
    _cContro := '00' + _cID
    reclock('SZ8',.t.)
		SZ8->Z8_FILIAL  := xfilial('SZ8')
		SZ8->Z8_CONTROL := _cContro
		SZ8->Z8_COD     := _cCombo1
		SZ8->Z8_DESCRI  := SB1->B1_DESCRED
		SZ8->Z8_DATA    := _dGet3
		SZ8->Z8_DATAP   := _dGet3
		SZ8->Z8_HORA    := time()
		SZ8->Z8_TF      := 'N'
		SZ8->Z8_ETIQ    := 'P'
		SZ8->Z8_DATAVAL := _dGet3+SB1->B1_VALID
		SZ8->Z8_PESO    := _nPesoL 
		SZ8->Z8_PESOBR  := val(_cGet2)
		SZ8->Z8_TARA    := mv_par01
		SZ8->Z8_TARAS   := mv_par01	
		SZ8->Z8_QUANT   := SB1->B1_QCAIX
		SZ8->Z8_ID      := _cID	
		SZ8->Z8_FILORI  := '00'
		SZ8->Z8_FIL     := '00'
		SZ8->Z8_ORIGEM  := 'O'
		SZ8->Z8_FARM    := _cFarm
		SZ8->Z8_CODORI  := _cCombo1
		SZ8->Z8_MDESP   := 'N'
		SZ8->Z8_TIPO    := 'O' // Como é um produto de revenda eu estou marcando com 'O' para diferenciar dos demais		
		SZ8->Z8_LOCAL   := _cGet4
		SZ8->Z8_OBS := 'Produto de Revenda'+'- Usuario - '+_cUsuario+' Est - '+_cEst		
	msunlock()
	
	/* Log de criação da caixa */
	dbSelectArea('ZA9')
	ZA9->(DbSetOrder(1))
	ZA9->(DbGotop())
	RegEv('Registro efetivado','OK','Etiqueta enviada',0,SZ8->Z8_COD ,_cEst,SZ8->Z8_PESOBR,SZ8->Z8_TARAS,_cUsuario,_cContro)	
		
    _cMemo :=  padc('[ PRODUÇÃO DE CAIXA PR ]',68,' ')	+ chr(13) + chr(10)
    _cMemo += Replicate("=",68) + chr(13) + chr(10)
    _cMemo += "Codigo Caixa:   " + SZ8->Z8_CONTROL + chr(13) + chr(10)
    _cMemo += "Codigo Produto: " + SZ8->Z8_COD + chr(13) + chr(10)    
    _cMemo += "Descrição:      " + SZ8->Z8_DESCRI + chr(13) + chr(10)
    _cMemo += "Data Produção:  " + dtoc(SZ8->Z8_DATAP) + chr(13) + chr(10)
    _cMemo += "Peso Bruto:     " + transform(SZ8->Z8_PESOBR,"@ 999.999") + chr(13) + chr(10)    
    _cMemo += "Tara:           " + transform(SZ8->Z8_TARAS,"@ 9.999") + chr(13) + chr(10)
    _cMemo += "Peso Liquido:   " + transform(SZ8->Z8_PESO,"@ 999.999") + chr(13) + chr(10)    
    
    Imprime('S600','IP',_cContro,SZ8->Z8_COD, SZ8->Z8_QUANT,SZ8->Z8_PESOBR,SZ8->Z8_PESO,SZ8->Z8_TARA,;
	'','',SZ8->Z8_MDESP,SZ8->Z8_DATAP,SZ8->Z8_ETIQ,SZ8->Z8_DATAVAL,1,'',ZAM->ZAM_IP,'',SZ8->Z8_HORA)
	_cMemo += "Caixa:   " + SZ8->Z8_CONTROL +' Impressa !!'+ chr(13) + chr(10)
	_cMemo += Replicate("=",68) + chr(13) + chr(10)
	
	_oMemo:refresh()

Return


Static Function MontaCmb()

	Local _cQuery := ''
	Local _cGrupo := "'6121'" 
	
		_cQuery := " SELECT * FROM " + RetSQLTab('SB1') + " WHERE " + RetSQLFil('SB1')
		_cQuery += " AND B1_TIPO = 'PR' AND B1_GRUPO IN(" + _cGrupo + ") "
        _cQuery += " AND B1_LOCCONS = '02' "
		_cQuery += " AND " + RetSQLDel('SB1') + " ORDER BY B1_DESC "

		_cQuery := ChangeQuery(_cQuery)


		If Select("TMP") != 0
			TMP->(dbCloseArea())
		Endif

		TCQUERY _cQuery NEW ALIAS "TMP"

		TMP->(DbGotop())

		_aItComb := {}

		while TMP->(!eof())
			aadd(_aItComb,alltrim(TMP->B1_COD)+'='+TMP->B1_DESC)
			TMP->(DBSkip())
		enddo

		_cCombo1  := _aItComb[1]
	

return

Static Function SetProd(cProd)

	_oSay4:SetText(_cSay4 + cProd)

return



Static Function Imprime(modeloi,porta,_cContro,_cCod,_quant,_pesob,_pesol,_tara,v1,v2,_TF,_datap,_etq,_dataval,_nNumEtq,_Lote,_ip,_cSeq,_Hora)
	
	_ip := alltrim(ZAM->ZAM_IP)
	U_GJF111f(modeloi,porta,_cContro,_cCod, _quant,_pesob,_pesol,_tara,v1,v2,_TF,_datap,_etq,_dataval,_nNumEtq,_Lote,_ip,_cSeq,_Hora)
	/*                   1      2        3      4     5      6     7      8     9        10     11    12   13     14       15      16    17   18   19     20 */
		
return 

Static Function RegEv(_desc,_status,_resp,_cod,_prod,_cEst,_pesob,_tara,_cUsuario,_cContro)

	Local _nID := ZA9->(RecCount()) + 1

	reclock('ZA9',.t.)
		ZA9->ZA9_FILIAL := FWxfilial('ZA9')
		ZA9->ZA9_ID     := _nID
		ZA9->ZA9_DESC   := _desc
		ZA9->ZA9_DATA   := date()
		ZA9->ZA9_HORA   := time()
		ZA9->ZA9_STATUS := _status
		ZA9->ZA9_COD    := _cod
		ZA9->ZA9_RESP   := _resp
		ZA9->ZA9_STRING := 'Caix.'+_cContro+' /U:'+_cUsuario+'-'+_cEst	
		ZA9->ZA9_PROD   := _prod
		ZA9->ZA9_EMB    := _cEst
		ZA9->ZA9_PESOB  := _pesob
		ZA9->ZA9_TARA   := _tara
	msunlock()

return

Static Function SomErr()
	WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0)
	//WINEXEC('C:\smartclient_TECNICO_Teste\sndrec32.exe /play /close /embedding C:\smartclient_TECNICO_Teste\GEER.WAV',0)
return

Static Function Leitura()
	Local _lRet := .f.

	//Se o campo estiver em branco
	if empty(_cGet1)
		_lRet := .t.
	else

		execsom()

		//Se o tamanho do codigo for menor que 10 digitos
		if len(alltrim(_cGet1)) < 10
			SomErr()
			alert('Falha na leitura!')
			_lRet := .f.
		else						
				
				
					//Verifica se a caixa ainda está em estoque
					if !empty(ZAS->ZAS_DATAS) .and. !empty(ZAS->ZAS_HORAS)
						SomErr()
						Help(" ",1,"NÃO PERMITIDO!",,"Caixa já encontra-se fora de estoque!",4,1)
					elseif _nModo = 1 .and. !empty(dtos(ZAS->ZAS_DTRMP)) //.and. !empty(ZAS->ZAS_LOCAL) .and. ZAS->ZAS_LOCAL == _cGet4
						SomErr()						
					else
						if _nModo = 1
							reclock('ZAS',.f.)
							ZAS->ZAS_LOCALI := iif(_nModo2 = 1,_DispEnd,'')
							ZAS->ZAS_LOCAL  := iif(_nModo2 = 1,substr(_DispEnd,1,2),_cGet4)
							ZAS->ZAS_DTRMP  := ddatabase
							msunlock()

							u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, "Recebimento Caixas", ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))

						elseif _nModo = 4
							Imprime(_cGet1)
						endif
						
						_cProd := GetMV('SI_PRODRX')
						
						if alltrim(ZAS->ZAS_COD) $ _cProd
							U_GJF111x(alltrim(ZAS->ZAS_CONTRO))
						endif
						_cMemo :=  padc('[ ENTRADA  EM  ESTOQUE  DE CAIXA DE MP ]',280,' ')	+ chr(13) + chr(10)
						_cMemo += Replicate("=",68) + chr(13) + chr(10)
						_cMemo += "Codigo Caixa:   " + ZAS->ZAS_CONTRO + chr(13) + chr(10)
						_cMemo += "Codigo Produto: " + ZAS->ZAS_COD + chr(13) + chr(10)
						_cMemo += "Descrição:      " + ZAS->ZAS_DESC + chr(13) + chr(10)
						_cMemo += "Data Produção:  " + dtoc(ZAS->ZAS_DTPROD) + chr(13) + chr(10)
						_cMemo += "Peso Bruto:     " + transform(ZAS->ZAS_PESOB,"@ 999.99") + chr(13) + chr(10)
						_cMemo += "Tara:           " + transform(ZAS->ZAS_TARA,"@ 9.999") + chr(13) + chr(10)
						_cMemo += "Peso Liquido:   " + transform(ZAS->ZAS_PESOL,"@ 999.99") + chr(13) + chr(10)
						_cMemo += "Origem:         " + iif(ZAS->ZAS_TERC = 'S','Terceiro','Propria') + chr(13) + chr(10)
						_cMemo += "OP Porcionado:  " + ZAS->ZAS_PREPOR + chr(13) + chr(10)
						_cMemo += "Local Destino:  " + ZAS->ZAS_LOCAL + chr(13) + chr(10)
						_cMemo += iif(_nModo2 = 1,"Endereço:       " + ZAS->ZAS_LOCALI + chr(13) + chr(10),'')
						_cMemo += Replicate("=",68) + chr(13) + chr(10)
						_oMemo:refresh()
					endif							
		endif
	endif

	_cGet1 := space(11)
	_oGet1:CtrlRefresh()
return _lRet

Return
