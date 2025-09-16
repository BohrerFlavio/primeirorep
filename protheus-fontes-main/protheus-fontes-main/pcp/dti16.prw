#INCLUDE "rwmake.ch"
#INCLUDE 'protheus.ch'
#INCLUDE 'dbtree.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI16    º Autor ³ Mauricio Roehrs º Data ³  07/11/16 	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de consumo de produtos para a produção de charque   º±±
±±º          ³ 															   ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP, Camaras, Expedicao, Producao                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI16()
	Private  _cGet1   := space(11)
	Private  _nGet2   := 00.00
	Private  _nGet3   := 00.00
	Private  _cMemo   := ""
	Private _oFont    := tFont():New("courier new",,-14,,.t.,,,,)
	Private _oFont2   := tFont():New("courier new",,-21,,.t.,,,,)
	Private _cSay4    := 'Codigo Produto MP/PP:'
	Private _cSay5    := 'Peso Bruto Caixa:'
	Private _cSay6    := 'Tara Caixa: '
	Private _cSay7    := 'Prod. Terc.: '
	Private _nCont 	:= 0


	DEFINE DIALOG oDlg TITLE "Consumo de Produtos para o Charque" FROM 180,180 TO 750,800 PIXEL

	_oMemo   := TMultiget():New(55,15,{|u|if(Pcount()>0,_cMemo:=u,_cMemo)},oDlg,280,130,_oFont,,,,,.T.,,,,,,.t.)

	_oSay1   := TSay():New(220,005, {|| 'Codigo da Caixa:'}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oGet1   := TGet():New(220,140, {|u| If(PCount() > 0, _cGet1:= u, _cGet1)}, oDlg,, 009, "@!",{||Leitura()}, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet1,,,,.t.,)
	_oSay2   := TSay():New(240,005, {|| 'Contagem de caixas:'}, oDlg,, _oFont2,,,, .T.,, CLR_WHITE, 200, 20)
	_oSay3   := TSay():New(240,140, {|| '0'}, oDlg,, _oFont2,,,, .T.,, CLR_WHITE, 200, 20)



	_oBtn2 := TButton():New(255,260, "Sair"    , oDlg,{||oDlg:end()},40,20,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE DIALOG oDlg CENTERED

Return


//Função de validação das leituras de caixas
Static Function Leitura()

	Local _lRet := .f.

	//Se o campo estiver em branco
	if empty(_cGet1)
		_lRet := .t.
	else

		//Se o tamanho do codigo for menor que 10 digitos
		if len(alltrim(_cGet1)) < 10
			Sinv(2)			
			alert('Falha na leitura!')
			_lRet := .f.
		else


			SZ8->(DbSetOrder(3))
			if !SZ8->(DbSeek(xfilial("SZ8")+alltrim(_cGet1))) 
				Sinv(2)			
				Help(" ",1,"ERRO",,"Caixa não encontrada!",4,1)
				_cGet1 := space(11)
				_oGet1:refresh()
			else

				//Verifica se a caixa ainda está em estoque
				if !empty(SZ8->Z8_DATAS) .and. !empty(SZ8->Z8_HORAS)                        
					Sinv(2)			
					Help(" ",1,"NÃO PERMITIDO!",,"Caixa já encontra-se fora de estoque!",4,1)
					_cGet1 := space(11)
					_oGet1:refresh()
				else

					_cMemo :=  padc('[ CAIXA DESTINADA PARA O CHARQUE ]',280,' ')	+ chr(13) + chr(10)
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

					_nCont++				             

					_oSay3:setText(transform(_nCont,'@E 999'))				             
					Sinv(1)    				
					grava(_cGet1)				
					_cGet1 := space(11)
					_oGet1:refresh()
				endif
			endif
		endif
	endif

return _lRet


//Função destinada a fazer a re-impressão de etiquetas
Static Function grava(_cCod)

	_cID :=  GetSx8num('ZZZ','ZZZ_CONTRO')
	ConfirmSx8()      

	_nPesoLiq := SZ8->Z8_PESO
	_nPesoBrt := SZ8->Z8_PESOBR
	_cCodPrd  := '005023'
	_cControl := _cID
	_cOrig    := SZ8->Z8_ORIGEM
	_cRegOri  := SZ8->Z8_CONTROL
	_cPrdOri  := SZ8->Z8_COD
	_dDtEntr  := date()
	_cHrEntr  := time()


	reclock('SZ8',.f.)
	SZ8->Z8_DATAS 		:= date()
	SZ8->Z8_HORAS 		:= time()
	SZ8->Z8_DEST  		:= 'C' //destino charque
	SZ8->Z8_LOCAL 		:= ''
	SZ8->Z8_LOCALIZ 	:= ''
	SZ8->Z8_PALLET 	:= ''
	msunlock()    


	reclock('ZZZ',.t.)    
	ZZZ->ZZZ_FILIAL := xFilial('ZZZ')
	ZZZ->ZZZ_CONTRO := _cControl
	ZZZ->ZZZ_CODPRO := _cCodPrd
	ZZZ->ZZZ_PESLIQ := _nPesoLiq
	ZZZ->ZZZ_PESBRT := _nPesoBrt
	ZZZ->ZZZ_ORIGEM := _cOrig
	ZZZ->ZZZ_REGORI := _cRegOri
	ZZZ->ZZZ_PRDORI := _cPrdOri
	ZZZ->ZZZ_DATAE  := _dDtEntr
	ZZZ->ZZZ_HORAE  := _cHrEntr	
	msunlock()	

	u_gjf17his(2,'ENVIADO P/ CHARQUE',.f.,'','','000023',SZ8->Z8_CONTROL)

return

static function Sinv(t)                                                           //Serve para executar o som ao ler caixa ou peça 
	do case
		case t = 1	
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE.WAV',0)
		case t = 2
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0)
		case t = 3
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE3.WAV',0) 
	endcase
return
