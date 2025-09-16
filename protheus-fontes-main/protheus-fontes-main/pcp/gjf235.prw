#INCLUDE "rwmake.ch"
#INCLUDE 'protheus.ch'
#INCLUDE 'dbtree.ch' 
#INCLUDE "TOTVS.CH" 
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF235    º Autor ³ Giuliano Forgiariniº Data ³  19/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina impressão de etiquetas testeiras exclusivas para o  º±±
±±º          ³ cliente Pão de Açucar conforme layout. Para pallets e caixas±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Embalagem, expedição                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF235()
	Private  _cGet1   := space(11)
	Private  _nGet2   := 00.00
	Private  _nGet3   := 00.00
	Private  _cMemo   := ""
	Private _oFont    := tFont():New("courier new",,-14,,.t.,,,,)
	Private _cSay4    := 'Codigo Produto MP/PP:'
	Private _cSay5    := 'Peso Bruto Caixa:'
	Private _cSay6    := 'Tara Caixa: '
	Private _cSay7    := 'Prod. Terc.: '
	Private _aOpSeq	  := {"Padrão","Bizerba"}
	Private _nModSeq  := 1

	DEFINE DIALOG oDlg TITLE "Impressão de Etiquetas Testeiras Pallets/Caixas Pão de Açucar" FROM 180,180 TO 750,800 PIXEL

	_oMemo   := TMultiget():New(55,15,{|u|if(Pcount()>0,_cMemo:=u,_cMemo)},oDlg,280,130,_oFont,,,,,.T.,,,,,,.t.)

	_oSay1   := TSay():New(220,005, {|| 'Codigo da Caixa/Pallet:'}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oGet1   := TGet():New(220,140, {|u| If(PCount() > 0, _cGet1:= u, _cGet1)}, oDlg,, 009, "@!",{||Leitura()}, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet1,,,,.t.,)

	_oSay2   := TSay():New(240,005, {|| 'Tipo de Caixa:'}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)  
	oRadio 	 := TRadMenu():New(240,140,_aOpSeq,{|u| Iif(PCount()=0,_nModSeq,_nModSeq:=u)},oDlg,,{||ModSeq()},,,,,,100,40,,,,.T.)

	//_oBtn1 := TButton():New(255,200, "Imprimir", oDlg,{||Imprime(_cGet1)},40,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oBtn2 := TButton():New(255,260, "Sair"    , oDlg,{||oDlg:end()},40,20,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE DIALOG oDlg CENTERED

Return

Static Function ModSeq()
	if _nModSeq = 1
		_cGet1 := space(11)
	elseif _nModSeq = 2
		_cGet1 := space(15)
	endif

	_oGet1:refresh()
	_oGet1:CtrlRefresh()
	oDlg:refresh()
return

//Função de validação das leituras de caixas e pallets
Static Function Leitura()
	Local _lRet := .f.

	//Se o campo estiver em branco
	if empty(_cGet1)
		_lRet := .t.
	else
		//Se o tamanho do codigo for menor que 10 digitos
		if len(alltrim(_cGet1)) < 10 
			alert('Falha na leitura!')
			_lRet := .f.
		else
			//Se for pallet...
			if substr(_cGet1,1,2) == 'PA'
				SZP->(DbSetOrder(1))
				SZP->(DbGoTop())
				/*
				_cBlq := getMv('SI_BLQGPA')

				if !empty(_cBlq)
					Help(" ",1,"ERRO!",,"Atenção, há outra estação criando uma etiqueta de pallet, aguarde até que ela realize a impressão!",4,1)
					if _nModSeq = 1
						_cGet1 := space(11)
					elseif _nModSeq = 2
						_cGet1 := space(15)
					endif
					_nGet2 := 00.00
					_oGet1:CtrlRefresh()
					return .f.
				endif
				*/
				//Verifica se, afinal, o bagulho existe ou não
				if !SZP->(MsSeek(FWxfilial('SZP')+alltrim(_cGet1)))
					Help(" ",1,"ERRO!",,"Pallet não identificado!",4,1)
					if _nModSeq = 1
						_cGet1 := space(11)
					elseif _nModSeq = 2
						_cGet1 := space(15)
					endif
					_nGet2 := 00.00
					_oGet1:CtrlRefresh()
					return .f.
				endif

				//Verifica se o pallet não tá lá na puta que pariu...
				if SZP->ZP_FIL <> cFilAnt
					Help(" ",1,"ERRO",,"Pallet em outra filial!",4,1)
					if _nModSeq = 1
						_cGet1 := space(11)
					elseif _nModSeq = 2
						_cGet1 := space(15)
					endif
					_nGet2 := 00.00
					_oGet1:CtrlRefresh()
					return .f.
				endif

				//putmv('SI_BLQGPA',getComputerName())

				_lInfo := informaPeso()

				if !_lInfo .or. _nGet2 <= 0
					Help(" ",1,"ERRO",,"Informe o peso do Pallet!",4,1)
					if _nModSeq = 1
						_cGet1 := space(11)
					elseif _nModSeq = 2
						_cGet1 := space(15)
					endif
					_nGet2 := 00.00
					_oGet1:CtrlRefresh()
					//putmv('SI_BLQGPA','')
					return .f.
				endif

				_cMemo :=  padc('[ IMPRESSAO DE ETIQUETA DE PALLET PAO DE ACUCAR ]',280,' ')	+ chr(13) + chr(10)
				_cMemo += Replicate("=",68) + chr(13) + chr(10)
				_cMemo += "Codigo:      " + SZP->ZP_COD + chr(13) + chr(10)
				_cMemo += "Produto:     " + SZP->ZP_PRODUTO + chr(13) + chr(10)
				_cMemo += "Descrição:   " + GetAdvFVal('SB1','B1_DESC',FWxfilial('SB1') + SZP->ZP_PRODUTO,1,"ERRO",.T.) + chr(13) + chr(10)
				_cMemo += "Localização: " + transform(SZP->ZP_LOCALIZ,"@R !!.!!.!!.!!.!!") + chr(13) + chr(10)
				_cMemo += Replicate("=",68) + chr(13) + chr(10)

				Imprime(_cGet1)

				//putmv('SI_BLQGPA','')

				_oMemo:refresh()

				//Se for caixa...
			else
				if _nModSeq = 1
					SZ8->(DbSetOrder(3))
				else
					SZ8->(DbSetOrder(28))
				endif
				if !SZ8->(MsSeek(FWxfilial("SZ8")+alltrim(_cGet1)))
					Help(" ",1,"ERRO",,"Caixa de PA não encontrada!",4,1)
				else
					//Verifica se a caixa ainda está em estoque
					if !empty(SZ8->Z8_DATAS) .and. !empty(SZ8->Z8_HORAS)
						Help(" ",1,"NÃO PERMITIDO!",,"Caixa já encontra-se fora de estoque!",4,1)
					else
						//codigo de serie da unidade logistica, utilizado na rastreabilidade do palete
						_cSSCC   := GetAdvFVal('SZP','ZP_SSCC',FWxFilial('SZP') + alltrim(SZ8->Z8_PALLET),1,"ERRO",.T.)
						if empty(_cSSCC)
							Help(" ",1,"NÃO PERMITIDO!",,"É necessário gerar a etiqueta do pallet primeiro!",4,1)
						else
							_cMemo :=  padc('[ IMPRESSAO DE ETIQUETA DE CAIXA PAO DE ACUCAR ]',280,' ')	+ chr(13) + chr(10)
							_cMemo += Replicate("=",68) + chr(13) + chr(10)
							_cMemo += "Codigo Caixa:   " + SZ8->Z8_CONTROL + chr(13) + chr(10)
							_cMemo += "Codigo Produto: " + SZ8->Z8_COD + chr(13) + chr(10)
							_cMemo += "Descrição:      " + SZ8->Z8_DESCRI + chr(13) + chr(10)
							_cMemo += "Data Produção:  " + dtoc(SZ8->Z8_DATAP) + chr(13) + chr(10)
							_cMemo += "Peso Bruto:     " + transform(SZ8->Z8_PESOBR,"@ 999.99") + chr(13) + chr(10)
							_cMemo += "Tara:           " + transform(SZ8->Z8_TARA,"@ 9.999") + chr(13) + chr(10)
							_cMemo += "Peso Liquido:   " + transform(SZ8->Z8_PESO,"@ 999.99") + chr(13) + chr(10)
							_cMemo += Replicate("=",68) + chr(13) + chr(10)
							_oMemo:refresh()

							Imprime(SZ8->Z8_CONTROL)
						endif
					endif
				endif
			endif
		endif
	endif

return _lRet

//Função destinada a fazer a re-impressão de etiquetas
Static Function Imprime(_cCod)
	Local _produto := ''
	Local _ip 		:= ''
	Local _cesta := ''
	
	//verifica se é caixa ou Pallet
	_cesta := getComputerName()
	if (substr(_cCod,1,2) = 'PA')
		u_FB601COM(_cCod,_nGet2,_nGet3)
		//u_GJF111n('S600','IP',_ip,_cCod,_nGet2,_nGet3)
	else
		_produto := alltrim(GetAdvFVal('SZP','ZP_PRODUTO',FWxFilial('SZP')+_cCod,1,"ERRO",.T.))
		_ip	:= alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM')+_cesta,1,"ERRO",.T.))
		u_GJF111p('S600','IP',_ip,_cCod,_nGet2,_nGet3)
	endif

	if _nModSeq = 1
		_cGet1 := space(11)
	elseif _nModSeq = 2
		_cGet1 := space(15)
	endif
	_nGet2 := 00.00
	_oGet1:CtrlRefresh()

return

Static Function informaPeso()

	local _lOk := .f.        

	DEFINE MSDIALOG oDlg2 TITLE 'Peso do Pallet' from 000,000 To 100,250 PIXEL
	@ 010,002 SAY  'Peso Pallet:' Object oSayPes
	@ 010,035 GET _nGet2 PICTURE "@E 99.99" SIZE 30,6  VALID !empty(_nGet2) .and. _nGet2 > 0 Object oGet2
	@ 025,002 SAY  'Tara Strech:' Object oSayPes
	@ 025,035 GET _nGet3 PICTURE "@E 99.99" SIZE 30,6 Object oGet3
	@ 010,95 BMPBUTTON TYPE 1 ACTION (_lOk := .t.,odlg2:end()) Object ObtnPes1
	@ 025,95 BMPBUTTON TYPE 2 ACTION odlg2:end() Object ObtnPes2
	ACTIVATE MSDIALOG oDlg2 CENTERED

Return _lOk
