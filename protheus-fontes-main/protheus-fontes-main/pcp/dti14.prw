#INCLUDE "rwmake.ch"
#INCLUDE 'protheus.ch'
#INCLUDE 'dbtree.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI14    º Autor ³ Mauricio Roehrs º Data ³  21/09/16 				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina impressão de etiquetas testeiras exclusivas para 		  		  º±±
±±º          ³ atender a União Européia. Layout exclusivo para caixas				   ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Embalagem, expedição, Camaras                              		      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI14()
	Private  _cGet1   := space(11)
	Private  _nGet2   := 00.00
	Private  _nGet3   := 00.00
	Private  _cMemo   := ""
	Private _oFont    := tFont():New("courier new",,-14,,.t.,,,,)
	Private _cSay4    := 'Codigo Produto MP/PP:'
	Private _cSay5    := 'Peso Bruto Caixa:'
	Private _cSay6    := 'Tara Caixa: '
	Private _cSay7    := 'Prod. Terc.: '

	DEFINE DIALOG oDlg TITLE "Impressão de Etqs. Testeiras para Caixas União Européia" FROM 180,180 TO 750,800 PIXEL

	_oMemo   := TMultiget():New(55,15,{|u|if(Pcount()>0,_cMemo:=u,_cMemo)},oDlg,280,130,_oFont,,,,,.T.,,,,,,.t.)

	_oSay1   := TSay():New(220,005, {|| 'Codigo da Caixa:'}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oGet1   := TGet():New(220,140, {|u| If(PCount() > 0, _cGet1:= u, _cGet1)}, oDlg,, 009, "@!",{||Leitura()}, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet1,,,,.t.,)

	_oBtn2 := TButton():New(255,260, "Sair"    , oDlg,{||oDlg:end()},40,20,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE DIALOG oDlg CENTERED

Return


//Função de validação das leituras de caixas e pallets
Static Function Leitura()

	Local _lRet := .f.

	_cBlq := getMv('SI_BLQGPA')

	if !empty(_cBlq)
		Help(" ",1,"ERRO!",,"Atenção, há outra estação criando uma etiqueta de pallet, aguarde até que ela realize a impressão!",4,1)
		_cGet1 := space(11)
		_nGet2 := 00.00
		_oGet1:CtrlRefresh()
		return .f.
	endif

	//Se o campo estiver em branco
	if empty(_cGet1)
		_lRet := .t.
	else

		//Se o tamanho do codigo for menor que 10 digitos
		if len(alltrim(_cGet1)) < 10
			alert('Falha na leitura!')
			_lRet := .f.
		else

			SZ8->(DbSetOrder(3))
			if !SZ8->(MsSeek(FWxfilial("SZ8")+alltrim(_cGet1)))
				Help(" ",1,"ERRO",,"Caixa de PA não encontrada!",4,1)
			else

				//Verifica se a caixa ainda está em estoque
				if !empty(SZ8->Z8_DATAS) .and. !empty(SZ8->Z8_HORAS)
					Help(" ",1,"NÃO PERMITIDO!",,"Caixa já encontra-se fora de estoque!",4,1)
				else

					_cMemo :=  padc('[ IMPRESSAO DE ETIQUETA DE CAIXA UNIAO EUROPEIA ]',280,' ')	+ chr(13) + chr(10)
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

					putmv('SI_BLQGPA',getComputerName())

					Imprime(_cGet1)

					putmv('SI_BLQGPA','')
				endif
			endif
		endif
	endif

return _lRet


//Função destinada a fazer a re-impressão de etiquetas
Static Function Imprime(_cCod)
	Local _produto := ''

	_cEst := getComputerName()

	_produto := alltrim(GetAdvFVal('SZP','ZP_PRODUTO',FWxFilial('SZP')+_cCod,1))

	etiqueta(_cCod,_nGet2,_nGet3)

	_cGet1 := space(11)
	_nGet2 := 00.00
	_oGet1:CtrlRefresh()

return


//Etiqueta para caixas
Static Function etiqueta(_cControl,_pesoPallet,_taraStrech)

	Local cPrinter  := ''
	Private _sPl 	:= Chr(13) + Chr(10)
	Private _cCmd   := ""   

	//aglutina pesos e soma quantidades
	SZ8->(dbSetOrder(3))
	SZ8->(dbGoTop())
	if SZ8->(MsSeek(FWxFilial('SZ8') + _cControl))

		_nPesLiq  := 0.00
		_nPesBrt  := 0.00
		_nQtdCx   := 0
		_nTaraEmb := 0.00
		_dDtValid := SZ8->Z8_DATAVAL	
		_cCodProd := SZ8->Z8_COD  
		_dDtEmb   := SZ8->Z8_DATAP

		_codExp   := getMv('SI_CODEXP')			         

		if alltrim(_cCodProd) $ _codExp			          
			_dDtProd  := SZ8->Z8_DATAP	
		else
			SZ2->(DbSetOrder(2))
			if  SZ2->(MsSeek(FWxfilial('SZ2')+SZ8->Z8_PREDES))
				_dDtProd := SZ2->Z2_DATAABT 
			endif		
		endif

		_nPesLiq  := SZ8->Z8_PESO
		_nPesBrt  := SZ8->Z8_PESOBR

		_nTaraTot := SZ8->Z8_TARA

		_nQtdCx   := SZ8->Z8_QUANT

		_cEst := getComputerName()

		/*if _cEst == 'CAM04' 
			cPrinter	:= AllTrim(GetMv("PM_ETQZBR")) 	
		elseif _cEst == 'DTI08' .or. _cEst == 'DTI05' .or. _cEst == 'EXP07' .or. _cEst == 'DTI12' .or. _cEst == 'AMX90' .or. _cEst == 'DTI03' 
			cPrinter	:= AllTrim(GetMv("c")) 	
		elseif _cEst == 'EXP17' //VERIFICAR SE REALMENTE EH ESTA MAQUINA	
			cPrinter	:= AllTrim(GetMv("PM_ETQZB4"))
		elseif _cEst == 'MDS02'  .or. _cEst == 'DTI02' //IMPRESSORA DOS MIUDOS 02
			cPrinter	:= AllTrim(GetMv("PM_ZBRUA1"))
		elseif _cEst == 'DTI13'
			cPrinter	:= AllTrim(GetMv("PM_ZBRUA2"))/// Criado em 15/03/22 para troca de versão 12.1.33
		else
			cPrinter	:= AllTrim(GetMv("PM_ETQZB2"))
		endif*/
		cPrinter := Alltrim(GetAdvFVal('ZAM','ZAM_PATHPS',FWxFilial('ZAM')+_cEst,1))

		SB1->(dbSetOrder(1))
		SB1->(dbGoTop())
		SB1->(MsSeek(FWxFilial('SB1') + _cCodProd))
		// IdentIficador do Produto
		_cDescSif 	:= SB1->B1_DESCSIF
		_cDescUE    := SB1->B1_DESCUE
		_cDscIngIf  := SB1->B1_DINGLES

		//descrições
		_cDescri    := SB1->B1_DESCRED//portugues	
		_cDescIng   := SB1->B1_DESCING//Ingles
		_cDescFra   := SB1->B1_DESCFRA//Frances
		_cDescEsp   := SB1->B1_DESCESP//Espanhol
		_cDescAle   := SB1->B1_DESCALE//Alemão
		_cDescIta   := SB1->B1_DESCITA//Espanhol

		_codTrEmb   := SB1->B1_CTARAP
		_codTrCx    := SB1->B1_CTARASE
		_cMensTemp  := SB1->B1_MENETQ2
		_cMensSIF   := SB1->B1_MENETQ1

		_nTrEmb 	:= GetAdvFVal('ZAB','ZAB_TARA',FWxFilial('ZAB') + alltrim(_codTrEmb),1)
		_nTaraCx  	:= GetAdvFVal('ZAB','ZAB_TARA',FWxFilial('ZAB') + alltrim(_codTrCx),1)
		_cTemp      := SB1->B1_TEMPERA

		_nTaraEmb   := _nQtdCx * _nTrEmb	

		//Peso Liquido
		_cPesLiq := alltrim(strtran(transform(_nPesLiq,'@E 99.999'),',',''))

		//Peso Bruto
		_cPesBrt := alltrim(strtran(transform(_nPesBrt,'@E 99.999'),',',''))

		//Total de Caixas no Pallet
		_cTotCx := transform(_nQtdCx,'@E 99')

		//Tara Total
		_nTotTara := _nTaraTot

		//Data de validade
		_sDtValid := dtos(_dDtValid)
		_cDtValid := alltrim(substr(_sDtValid,3,6))

		//Data de produção
		_sDtProd := dtos(_dDtProd)
		_cDtProd := alltrim(substr(_sDtProd,3,6))

		//Nº de registro de processador - Nº do Registro do Fornecedor no Sif com Iso do Pais(076+1733)
		_cIf := getMv('MV_NUMIF')
		_cIa7030 := '0760' + alltrim(_cIf)

		//Lote das caixas do palete
		_cLote := alltrim(_cDtProd)

		_cCod13  	:= SB1->B1_CODBAR 
		_cProdEAN14 := getMV('SI_CDEAN14')
		_cPrdEan142 := getMV('SI_CEAN142')

		_cDigVerific:= refazEan('9' + substr(_cCod13,1,12))
		_cCodBar 	:= alltrim('9' + substr(_cCod13,1,12) + _cDigVerifc)

		_cDataAM := DTOC(_dDtProd)//data do aviso de matança
		_cRastro := _cIf + strtran(_cDataAM,'/','') +'0000'

		etqCxPv()                     

		// Arquivo da etiqueta
		Memowrite("\etiquetas\etq601com.tmp",_cCmd)
		cComando := "I:\etq601com.bat "+ AllTrim(cPrinter)
		//MemoWrite("C:\TEMP\cComando.txt", cComando)

		WinExec(cComando)

		sleep(1000)	
	else
		alert('CAIXA NÃO ENCONTRADA!')
	endif

return


//função para gerar etiqueta da caixa peso variavel pão de açucar
Static Function etqCxPv()

	_cCmd += "" + _sPl

	// Setup Etiqueta em ZPL
	_cCmd += "CT~~CD,~CC^~CT~" + _sPl
	_cCmd += "^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR2,2~SD15^JUS^LRN^CI0^XZ" + _sPl
	_cCmd += "^XA" + _sPl
	_cCmd += "^MMT" + _sPl
	_cCmd += "^PW831" + _sPl
	_cCmd += "^LL1678" + _sPl
	_cCmd += "^LS0" + _sPl

	// Código GS1-128
	//_cCmd += "^BY2,2,120^FT600,1575^BCB,,N,N,,N" + _sPl//1589 //200
	//_cCmd += "^FD>;>801" + AllTrim(_cCodBar) + "3103" + StrZero(Val(_cPesLiq),6) + "37>6" + alltrim(_cTotCx) +"7031"+_cIa7030+"^FS"+ _sPl
	//_cCmd += "^FT635,1575^A0B,25,24^FD(01)" + AllTrim(_cCodBar) + "(3103)" + StrZero(Val(_cPesLiq),6) + "(37)" + alltrim(_cTotCx) + "(7031)"+_cIa7030+"^FS" + _sPl


	_cCmd += "^BY2,2,120^FT600,1550^BCB,,N,N,,N" + _sPl//1589 //200
	_cCmd += "^FD>;>801" + AllTrim(_cCodBar) + "3103" + StrZero(Val(_cPesLiq),6) + "37>6" + alltrim(_cTotCx) +">810" + _cLote +"^FS"+ _sPl
	_cCmd += "^FT635,1550^A0B,25,24^FD(01)" + AllTrim(_cCodBar) + "(3103)" + StrZero(Val(_cPesLiq),6) + "(37)" + alltrim(_cTotCx) + "(10)" + _cLote + "^FS" + _sPl


	//_cCmd += "^BY2,2,120^FT769,1575^BCB,,N,N,,N" + _sPl //197
	//_cCmd += "^FD>;>87030" + _cIa7030 + "7031"+_cIa7030+"11" + _cDtProd + "17" + _cDtValid + "426076^FS" + _sPl
	//_cCmd += "^FT802,1575^A0B,25,24^FD(7030)" + _cIa7030 + "(7031)" + _cIa7030 + "(11)" + _cDtProd + "(17)" + _cDtValid + "(426)076^FS" + _sPl


	_cCmd += "^BY2,2,120^FT769,1550^BCB,,N,N,,N" + _sPl //197
	_cCmd += "^FD>;>811" + _cDtProd + "17" + _cDtValid + ">8426076>87030" + _cIa7030 + ">87031"+_cIa7030+"^FS" + _sPl
	_cCmd += "^FT802,1550^A0B,25,24^FD(11)" + _cDtProd + "(17)" + _cDtValid + "(426)076(7030)" + _cIa7030 + "(7031)" + _cIa7030 + "^FS" + _sPl


	//CARIMBO DO SIF
	_cCmd += "^FO32,512^GFA,36480,36480,00060,:Z64:"
	_cCmd += "eJzsXb+P3MixJjmk+HADvHFgYjKvcA4M2IAneqmGB+xC6RoYXkcHKHRmB0vRcKCd8GXvX9jw4AOsCw3fA0Z4Dp3cA075wJFgGyfBkaBbLN1V/bu7usnZc2JgS5DEIdn8pl"
	_cCmd += "jd1VXV1TVZ9kAP9EAP9EAP9EAP9EAP9EAP9EAP9ED/bvTR7/77vk2rrut292v68Qj0l3u0LMuOAXXn5emNV6Ok05vmnaLLk9tuxvHuLx//lOPendq0YkPX8v851/3ViW2X4/hGHbw/E"
	_cCmd += "ZbzaQ5PFPI4HuVRMY6vTmlZMrZr9XdgXRu/NaSthkXgU5o2mtvw0xRtxlvn0z/mN837vrU/D/0JfWsc9/bHg/sxjet24vyUPl14uKdIuGZuT6qG+T1r6eEUJ3TpQJ7N/J619eW5md2zqsFHKfu"
	_cCmd += "5DL+8DU6t7vbz2hLddy7DC2sMKSqIcxRxaQYquWLzGF5RinEbvgOKyNE6bwgX4zvi7GJ8PKNtPlD6uBrmDKUV3Ye2c7p01f2A+jazlHTkjUa+jkvrK3LCref0rO0NebqYozsiuimfo7NiHWh"
	_cCmd += "Did17fh+5MKNHL2KPX0z36CbGVj7dozevYlcmJ4cqLkauxSZMrW0Ud3ucxI1eaqZe9CLebVdTI6lyZ16b6ik763vg5gm9lHgV8uHx3rOYMCyTepi1ybY5qSQlXe+TbZvUKI12dU"
	_cCmd += "F1SjucvUm2ZVdt/OI6LeCz1CCtPyTbJrXwhIDvHqeujjfRS6UUb2yUVkkB52mOkiO4Sg/RpIqu0xKsUyOp/nWy7UXqa53dJNsmX0fTZhk1+6q2KdztPstS086LxDUQYOLZFUsoaP7cI"
	_cCmd += "tWj4XtFCKac5LSTmvu/D+4wgZvo0CC/ZWq6OzvG2+5gkKY0VhwX+usmpSnrOC57xi8PimECI6E5Vkew35T634c35PGBBKwaZ/c03J84uAQtorgldJuql74QNWjy+Ox8fQMT8PglfiiI951H"
	_cCmd += "hS+4UZENirc82qEf4VNH6euTdhx8M5LWjP9Trll/Dp9qqvOy80jbGt/wVoYzSEM92qGFAdUI7562PKI21hmqwY307reUnFffRtqKSbAe0EGqSDepHmK42Gu4gN/hf9R7riOdTnoEuRAw"
	_cCmd += "PY6jHVoKT0ToVuQ4LuiOVapnPmUg2bURb4l/xGFEY6nBucCY2YE2LCMCrj6Tz0ABd3bXbTSbEW2mJ9+3nOFCv+bHGN9R73dFz9CVmnzZ0Ld5L/2kcneeXQy9+hYxXMXKchz3S/WaV+P"
	_cCmd += "t/jDqsGFEY2lzseK8VsrS4t27taKykQ6tJ33O3nEjgfjx+C1Eg/+xFxfpjrVuFS5ju7U0pCs2sI7/HcSgLivapjzbqyPO30EGcBb8+APgfpBX6anfdFUMO4tvYcLQ6jPZ1jyRD2ElXh"
	_cCmd += "H9vvudDtm92AcNHVyuspQhzUczF27XDSqCNYXLe7QR7xcYctfD2bwViyxOqu5197U4bCSvOgjdkLhcWxXycNTsrVC6gPt3eeKGaAo2rDKfGFPjtObSZcM5BKTFCd0LnO9sGYsGd3Ob/QxZ1fxS"
	_cCmd += "uGhsyEMtTui/IpSj1DVtcpD8bt/JoawFfiSaQk+t5GiRiwuc/msnA1oqJFs/o74zH5m1ZGarQ+wcd3GwcWsS99K4g5WejAJ+K0pxgLqqpX/0n1pbBfxSLkVZt9CRBZ+ldoPXHBc/MIVLKQ5g5Gy"
	_cCmd += "Uw/agJgWOmzn8kgoLBNcpY0PrLsWvno5JnwEEt1WLNpujhbv9u4WbUb4KQ9xBWFBVK8+u+ecLrqoulHzz50RbGJjXo4zwf7SXZzcSzkzHlMICfrpgRbDpfoHfw5ynFMeTPfLrBZpX4nNhzhO4JRh"
	_cCmd += "XFVfEIvqsRnIt5MoFrywrRuDC83JQijf2WTkvrczSBuGriP4SLAhKuUq28TB0GB8Jub01qlkCI+7GTEOEwhITTcUFPDhG8gWeX5tz63AgSZ+6OIzUqs1HwY0OrrTWQ4bhX2NwUFEdNS4XUyugB"
	_cCmd += "O5a9hs++Q6OdV7qf2TbcCBpwynsWy4twoGk2ej0IKaJUBwmZrJJrzXnYczH8NixPuVfE76KFYybWOMO34Z5Wh7ym1t9OIlbvE3jXvu4lmHMJWzGqBjLpbXIn4cmtMVvuBx4GD9P4Np2U+Xw+w"
	_cCmd += "PvDRALDb81uPZSQsG72RHtyQSuvaxgzXX10Pdd33ORa0+Q+UEud5oxT16orAYzqAPT3bETc4NbaXtSd+OAXyckVgS4by3cn/i4VSQwWfPhzNj5OTOB6ae+CR2LXAg7dp99MWq0QHGIVxsai00"
	_cCmd += "nhGutlwUDeBGJTHLFvAH9ZfylCO5FuHbUXGVVb9tXSpNbhGpyEXqZ2/dy6jW4gcKqvpb9OHeXB7V99Vp3gIDf+sh5ugYr52MX912Am/vqG8ziNRtwhcEWc2Bf8Ts+JXAxhLR0By/YdYcJXGld4"
	_cCmd += "VC1+2tgT/K2n3ltYVY9A9ytO/GH9lXoEoLy64fnnN3eycfh8sW4xyfmbOCagXUFE+DKm/dXUuRfWK/Bd5Ea1Eq7vPJmo0YHPbRUc7/X/2gPRs5N9tLLfFKL7i+VfxTignXF9fJ5zrqB2Qp4zfV"
	_cCmd += "UWaJLbM55uE8A94MwsOxevQrsq5DfDrrzTqonC7dS9pVlZ/r8voBR9D57NI7/59g5crXfSdGpI7hDfzHY/PITyKKdsePzK3FrzqxrX60kvxbWisK9BPY+cfiVlpWzjkbwW3PxclyOYeMWN/Dv"
	_cCmd += "z39vnfL5/ZQ7SOwSzeWnTrpK5dt1vC2Fu+dD6TbIzgnIwwWvp+GaCqLPyYg7fok47uJUXD46ay7Cjg/Tmggyl/apyr2Ozi/H3Y7vpnEXHi7yK0J1zlJ7TrSlcLl2vuZG2zTu0X3UDoYqDNPWDTyXR"
	_cCmd += "MCZwOV9Noe+PImbe7jo7GOkzuW38ZVi5pgj+PENvufFeOfhbgjfgcCt2GUNw9TBXRO2dO4aWAuBW4NuXrr6KnQPSH4vKX671/586/ELIuPjF3Gd8cudhzDE7uHuwHS8Qi381NHPDEKTruHl8"
	_cCmd += "4u4788E7t7BHQMrxLWJ8D1LV9CLPIcxAI/fGnFFePClPR9t7hwbVtAv3bYtrhyx4dJLnmw6zm+/a+2bPX4BF+YiMHS8efAQMvwb5xMMjVww5ueKNoGDSPALUZU34Hg7uaK3WQHv2hGyiwv8"
	_cCmd += "lqzn4uVD2LY31ruy4lPy0Nnj2H3tGKhbwcS/cPN/MY/kKw78fh/Dxahj81n3yrEsMhFfz/2oB4GbbT7oZRyLX9G57LxvArcERC5l+zVCzkbZgZNkMewa0KsYrsibObhWF4Er7WffnoRzr5"
	_cCmd += "234PJrgjQL1/mVcbONg/tbp+0acqtKGKYVc0S5FtEs5kjdxTUmk7dOpvKEvojjmqhy5Q7WRod5ovzauI/tCypOmP3cwnVDdkZF1W6uc6PY7Cx+XflauHvnApkX5eIaE8Lzfsx89ENzMsav"
	_cCmd += "R5tpXCroiKTCWo5v7DpIUdwZ/EYDVuT6mHv3j2K4M/iN41LrY24I+l/Fb2VfoOwr71s+sXCLbIqi8nWzrEpqe4rbG2zc6QTcKL8NmQ8cuxtwzeGMXPYYv3kyODmBG1nodu7e0"
	_cCmd += "0/imulEfi0OZuwKeeJ8Mvwyx/2lyZWvxl3O2XDkjjrFAU619+V3Fq77nvWIfOotL5TtufozhbvwN1itxgP8ORzG/zUn3dGulwNhprX5bcL4ZAz32l9O2ei4qHXaxZX8QujZi18"
	_cCmd += "xRRaum2b3QnHnwc7BlRyEawtz+S2uQ1t5OZPfqmO9t/Moq4ah67vexSX683YMcbPNd1lAIb/Yl197WiNvulyQd7eLC/7C3Y8DXMIhdHFhRm0Yxppd3JKbW5LMyZBfXBsMnF8qDcvF"
	_cCmd += "VVZymFdPZSAF/IKb8iF0uqdxrwAXRm4Q3KAS3knc/X1wteF8b35vshCXSrQP5MsN5x2RVUel2QXyzdHtuwdup5I2An6pFEKK3zviPU/jPsdNg/1VWzvBuoxOmaT4pfrVbH67bwh+w7bh"
	_cCmd += "+IVxdJwMIgG58+CnsO7HB+8uFOekfaVw39wDV/F7Gc8Ide/2cDG+8bc5uO78C/qqY6znnv3JuGi5kPqZotDeyO28shNwxXz0q5m4hH2Fsy8xXAMJk/Yz4M7YN+fiCg7yqbV9527vSSqEN"
	_cCmd += "UGk/YwTMJ2paEegXX6VxM6o8BzS1vo6pL+AgQwy3J7H7Q3dU2D96DHR1gk/0P4CipjM7LLjGzH/d0vzm8B1/IVJfmP+fkHzWyRwW33I6M3cNm4svsEtyH1GkL1oFItvzNkYGY1vFG8fT"
	_cCmd += "7V1ce2sSDJzzxnDUX6zYp9NkMdvS99F08x4DkmxuBknj98288mLT9q4N/863JBi8cnMXz6YxHXk6z6Wf/QVdBzX26ix+EOAS8RjI7hdYHMQ8XZJXshqEa4YevH2Z+a4c8VXXwU2lneDh"
	_cCmd += "et5hMvbIK8jXF+Q5O/kRn4dXGp9QZC/YYLg11tPeYb/gSAdTZxhPp1ndBHrKRHcaX6dDCT30gn8+huQJvmtDAtN52bpVFfZwpUvsV4maevhEvwenU8Wv351kUl+ZToSpJJtJ+VLrEvK3"
	_cCmd += "b/M2wIcypdY/81ExtPBM3RCfklctDX8+XeSX8St0bjy41eT/ML6ftb1Q3/1ib/vCMava1RT/IJxdRvsOyL4vXHbipQjbl5d+FuAQ349XMziBrv97k++PRnyq7LvFe4VH7toPj/1C0/UH"
	_cCmd += "XcknHhO7eGCqscw0p99/285/vG78buvvjJqmsjfUFtRvLYqozCZn8Nx/3odJgOrTEbz+v18FQxwdG3Ve9oZMyjBqraysoj8HKiaU4f+wnISVziEbRMWQ5rLL+D6CxnT/HIDOh8YJLgHW"
	_cCmd += "XuMDdxNTORfIb93kMDhuykhv0Q+Ut51lPWcT/ILjtn13bzSQD4u8vscnP52sq2/uHYmcVczcOn8OghHTuIGEY+Vxt0Tt7v0xLsFDCz2vKR3hXq4Pr9gYEHaZnK7s2xL508m637otj6/9"
	_cCmd += "RF2hMr4VXrFjMwXBVyMX1VEC+P/knmqZzI+WVArG8b/DXAhP1Ys77eRnb/xfGALl6wrtnhr8oGDvNxfwy6rFvi9oGIcltVF5iFL3CWJa+UDU3nI0Jdz3B0Ztk3xKxLdjjKY9Cpom8x/5"
	_cCmd += "uw03IzKYTGBCEnmJuxB5rcD7jIWw9rs9RGV3151/+/sjYxQ6B+/2AOuCJ2ldUeQzw8ZDVw5wxJDz8L6V5nxgMvuWfC0vYgiYXQ0BUvvX9C5+3QkSd/ZEriP7omL/MI8a3aCxnDD3s5xC"
	_cCmd += "wl7k2xLVDvBcQsWVpBO5+OG/MJ+HDR0psovBmoD+S3RwDr3ghmlIvmZ2Ad0pnD3p+M2l9R2uiy0Nwhc2D74K87t0b9QfCtI5XsT1Wxg21g3XIUPrfsB/yh9Rex4rnEAE5sSfXsjsr+MS"
	_cCmd += "g4N+CX2lxX89T0imgb2FbWfbhca5OI7euu/xH66ZM0Wm4iQU7R0jm9fUe9kLq5vbQDZVoSbLxm/T5HFB10jQVJsf6gk3wW2idzQbuEmNTSFa6khNsStrPxTQnmbDdTWdnaibWz/r7ycU"
	_cCmd += "tHk/t9a44bZBZnZqUmWWDEhjrpjoY5Wsx9ZsGAmLs2vHh8V+MGxy9H93QbXN3UKtfPafD2LDCO4zt96T1b7rdbeBSTDyEioaW1fkbhGcJTJoe0rMlJtcN8SJscEruZ3GM4D96xW+pnmV"
	_cCmd += "+tmzuzGn/tNfYYbqq2Vk+RnjcLJb8QBPbL1wOQQQdHNQtntdGReKyIQZVDYrTr37nJx1RPB5Q+qX/6Hf5dDmpPOqlzgU6T+huYEeN3ENBatxmUXrnbgGsTqiUZKjWnJvXwXV9GREmdyh"
	_cCmd += "IoQR6yeaKRmX33E/7bj23fQj2jcSEUoORMyrBeUs842s/Q2FXZJljjLVbkg7LpbN/1alVeJlLATostlCMsawT/MTNAy5krg1mOlrIyAC+jeKrwUKQglVhHqbmBw0GiNVcG2MxnWKmMFsK"
	_cCmd += "4/R9w7VFZGwJtb/DJ4XMfMTeSpksrK7Lpqdph1Jr5DbGLGukyrO+7rHoFfJUn+2rfKiYjVZRIVU9d9CxvNsrU2qPiBtq9qf2+oxv0guMOBpKck2O0NYVpk/+yvkbaY64wbQjtrSzf07K5"
	_cCmd += "rRP+O1r9CZmBvN+9TZjsBJMrwY6FIopURK1hYwA2hQ1sNuqAKazl0LvSzk+tvExaZWqHS2K/0jLS4wyrMAjdachOF16AdDYHKVp+FJeFGpHi0kbbo6a1wJ9DRqgAl4s+4ipZHy0/jHv4a"
	_cCmd += "k7B2TO/3lesLmOhe9dEChYiLO82OB427tHG/i+FmIuGM3/KZ6w9B4AP5rX4Ra5rVkt+FncZh8xuvX4eRixqVcz9oXH5iPXB++yxh3AtTJ4a7msBFX0WnJhH8JiqqwmOxSqxtcHDAH/M+h"
	_cCmd += "vzCC4nhXskSo6wz9fmBX5Av9OdE8BJc2wW48wcr7L66RV2NuIl6nKL+5E7XsFP8wlDGkZvK3cHoNw5gY+dIXBxHqcq1wA/MRoOVJlv3Wd+LIklBJNYmmPoBwLZj+Ys/fJCb2lMxiEZvm3"
	_cCmd += "QSWNDg+ibZrVTNIOhXxsxZjAVuVn0XnfQlbzvYJrpb22uEFepmsbMwhQu+/Hb8cmP7RwX27QNUaUzWcRUdeueazyLtDrLA05ksL27EILIL9G90ObtkzCXnM1EF9czsJWDG5+McbK5E9Uk"
	_cCmd += "gmAp9q7047AXkRCHmbhdW0Knw5GVi8hUE2uElFcN6nJGRHJugLhD+aIp9spQ9ap0Sr0iPXcYChWefk6cVyT3ttBwnEpVy7Lr0DoaCNtkt3Cso0deSz02LV7xosvLkdJ3tXGzyjnyndNvv"
	_cCmd += "g5s97ejK9GVWEoWRvIePkVJxc+qoQ20+Wo4T5b3h6a8iF4rpn7qIFFycUJKCovX5l9P1+aN1ief8HkFMii+P020jFdyraOlYi7ZfkqeJWjMhRcQ4KzE6YiLP+t2HSJX2Zmr0Im7kdy7m/"
	_cCmd += "PwSXY5i3u9r0L8couNXaVwWJtSBSX0+9esLQGQG9HLeL9WQS94zf/OJLEg883dbKmIBqZr7C0j/E4qS3J5K0ff4fRyi6879eZysDOvwV/SSIUVbf4LfzpMuUBCdnJXlL8j/RaCPZ+S8K6"
	_cCmd += "qYu8DQnfR7T17K6Cm4/qa6qTVDm1xLx/+5qzQNDoMxA4Smpfc7YsfYjQS5Cyqz9jTYUObNLieXSP8JAAD//0NF4UhHboSi7ykkBPbDSy1czTzcAHYOliih6W8sAHbENejwjQck6gW3okP"
	_cCmd += "BVxASn4dgALFBk8Tr+EAAvjOUZGsR86CkRS4UuIaXlpeX4psqxAP2EzP9jQMw4psnJAgIb+XHBZDPkR0Fo2AUjIJRMApGwSgYBaNgFAwgAABhxNzN:5942"
	//FIM DO CARIMBO


	//Informações do Produto
	_cCmd += "^FT44,1565^A0B,28,28^FH\^FD" + alltrim(_cDscIngIf) + "^FS"
	_cCmd += "^FT72,1565^A0B,20,19^FH\^FD " + alltrim(_cDescUE) + "^FS"                                           
	_cCmd += "^FT101,1565^A0B,17,16^FH\^FD" + alltrim(_cDescIng) + "/" + alltrim(_cDescAle) + "/" + alltrim(_cDescIta) + "/" + alltrim(_cDescEsp) + "/" + alltrim(_cDescFra) + "/" + _cDescri + "^FS"
	_cCmd += "^FT133,1565^A0B,20,19^FH\^FDCODE PRODUIT/C\E3DIGO DE PRODUCTO^FS"
	_cCmd += "^FT157,1565^A0B,20,19^FH\^FDCODICE PRODOTTO/PRODUCT CODE/PRODUKTCODE^FS"
	_cCmd += "^FT181,1565^A0B,20,19^FH\^FDCODIGO PRODUTO:^FS"
	_cCmd += "^FT179,1380s^A0B,20,19^FH\^FD" + AllTrim(_cCodBar) + "^FS"


	//Rastreabilidade
	_cCmd += "^FT28,531^A0B,17,16^FH\^FDTraceability Code/Ruckverfolgbarkeitscode/Codice Tracciabilita^FS"
	_cCmd += "^FT49,531^A0B,17,16^FH\^FDCodigo De Rastreo/Code Tracabilit\88/Codigo de Rastreabilidade^FS"
	_cCmd += "^FT70,531^A0B,17,16^FH\^FDCodigo De  Rastreabilidade:^FS"
	_cCmd += "^FT72,164^A0B,20,19^FH\^FD" + alltrim(_cRastro) + "^FS"
	_cCmd += "^FT133,531^A0B,23,24^FH\^FDBRAZILIAN BEEF^FS"

	//Data de Producao
	_cCmd += "^FT197,531^A0B,17,16^FH\^FDProduction Date-Batch/Produktion Datum-Reihe^FS"
	_cCmd += "^FT218,531^A0B,17,16^FH\^FDData di Produzione-Lotto/Fecha de Produccion-Lot^FS"
	_cCmd += "^FT239,531^A0B,17,16^FH\^FDDate de Production-Fournee/Data de Producao-Lote:^FS"
	_cCmd += "^FT234,133^A0B,20,19^FH\^FD" + DToC(_dDtProd) + "^FS"


	//Data de Validade                   
	_cCmd += "^FT284,531^A0B,20,19^FH\^FDExpiration Date/Ablaufdatum^FS"
	_cCmd += "^FT308,531^A0B,20,19^FH\^FDData di Scadenza/Fecha de Validez^FS"
	_cCmd += "^FT332,531^A0B,20,19^FH\^FDDate d'Expiration/Data de Validade:^FS"
	_cCmd += "^FT329,133^A0B,20,19^FH\^FD" + DToC(_dDtValid) + "^FS"

	//Peso Bruto
	_cCmd += "^FT392,531^A0B,20,16^FH\^FDPoids BRUT/PESO BRUTO/PESO LORDO^FS"
	_cCmd += "^FT416,531^A0B,20,16^FH\^FDGROSS WEIGHT/BRUTTOGEWICHT^FS"
	_cCmd += "^FT440,531^A0B,20,16^FH\^FDPESO BRUTO:^FS"
	_cCmd += "^FT436,193^A0B,23,24^FH\^FD" + Transform(_nPesBrt,"@E 999,999.999") + "^FS"
	_cCmd += "^FT434,64^A0B,23,24^FH\^FDkg^FS"

	//Peso Liquido
	_cCmd += "^FT491,531^A0B,20,19^FH\^FDPOIDS NET/PESO NETO/PESO NETTO^FS"
	_cCmd += "^FT515,531^A0B,20,19^FH\^FDNET WEIGHT/NET WEIGHT^FS"
	_cCmd += "^FT539,531^A0B,20,19^FH\^FDPESO LIQUIDO:^FS"
	_cCmd += "^FT533,193^A0B,23,24^FH\^FD" + Transform(_nPesLiq,"@E 999,999.999") + "^FS"
	_cCmd += "^FT532,64^A0B,23,24^FH\^FDkg^FS"


	//Temperatura
	_cCmd += "^FT567,533^A0B,17,16^FH\^FDConservation Temperature/Schutztemperatur/Temperatura di Conservazione^FS"
	_cCmd += "^FT588,533^A0B,17,16^FH\^FDTemperatura de Conservacion/Temp\82rature de Conservation^FS"
	_cCmd += "^FT609,533^A0B,17,16^FH\^FDTemperatura de Conservacao:^FS"
	_cCmd += "^FT614,192^A0B,23,24^FH\^FD" + alltrim(_cTemp) + "\A7C^FS"


	//Complementares
	_cCmd += "^FO637,32^GB0,499,2^FS"
	_cCmd += "^FT674,531^A0B,23,16^FH\^FDPRODUCT OF BRAZIL -  ORIGINAL NON EU^FS"
	_cCmd += "^FT702,531^A0B,23,16^FH\^FDSLAUGHTERED IN BRAZIL - CUT IN BRAZIL   SIF 1733^FS"
	_cCmd += "^FT730,531^A0B,23,16^FH\^FDFRIGORIFICO SILVA IND. E COM. LTDA - CNPJ : 88728027/0001-46^FS"
	_cCmd += "^FT758,531^A0B,23,16^FH\^FDBR 392, Km 08, Passo das Tropas Santa Maria - RS / Brasil^FS"
	_cCmd += "^FT786,531^A0B,23,16^FH\^FDhttp://www.bestbeef.com.br/^FS"
	//_cCmd += "^FT814,531^A0B,23,16^FH\^FD" + alltrim(_cMensSIF) + "^FS"
	//_cCmd += "^FT814,531^A0B,17,16^FH\^FD" + alltrim(_cMensSIF) + "^FS"
	_cCmd += "^FT814,531^A0B,08,14^FH\^FD" + alltrim(_cMensSIF) + "^FS"
	_cCmd += "^PQ1,0,1,Y^XZ"


return

//Função destinada para refazer o digito verificador do EAN13
static function refazEan(cCod13)
	Local nOdd := 0
	Local nEven := 0 
	Local nI
	Local nDig  
	Local nMul := 10 
	For nI := 1 to 13
		If (nI%2) == 0
			nEven += val(substr(cCod13,nI,1))
		Else
			nOdd += val(substr(cCod13,nI,1))
		Endif
	Next
	nDig := nEven + (nOdd*3)
	While nMul<nDig
		nMul += 10 
	Enddo
Return strzero(nMul-nDig,1)
