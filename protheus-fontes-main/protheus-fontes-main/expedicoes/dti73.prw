#INCLUDE "rwmake.ch"
#INCLUDE 'protheus.ch'
#INCLUDE 'dbtree.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI73    º Autor ³ Mauricio Roehrsº Data ³  05/11/18	      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para carregar os pallets na rotina do carregamento  º±±
±±º          ³ 															   ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ expedição		                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function dti73(_cPrecar,_cPreped)
	Private  _cGet1   := space(11)
	Private  _nGet2   := 00.00
	Private  _nGet3   := 00.00
	Private  _cMemo   := ""
	Private _oFont    := tFont():New("courier new",,-14,,.t.,,,,)
	Private _cSay4    := 'Codigo Produto MP/PP:'
	Private _cSay5    := 'Peso Bruto Caixa:'
	Private _cSay6    := 'Tara Caixa: '
	Private _cSay7    := 'Prod. Terc.: '

	Private _nModo    := 1
	Private _aOpcoes  := {"Carregar","Excluir"}

	Private aCampos := {}
	Private aStru:= {}

	criaTEMP(_cPrecar,_cPreped)

	DEFINE DIALOG oDlg2 TITLE "Carregamento de Pallets" FROM 180,180 TO 750,835 PIXEL

	_oMemo   := TMultiget():New(10,15,{|u|if(Pcount()>0,_cMemo:=u,_cMemo)},oDlg2,280,100,_oFont,,,,,.T.,,,,,,.t.)

	_oSay0   := TSay():New(210,18, {|| "Opções: "}, oDlg2,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oRadio  := TRadMenu():New(210,80,_aOpcoes,{|u| Iif(PCount()==0,_nModo,_nModo:=u)},oDlg2,,{||Modos()},,,,,,150,12,,,,.T.,.T.)//{||Modos()}

	_oSay1   := TSay():New(230,005, {|| 'Codigo do Pallet:'}, oDlg2,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oGet1   := TGet():New(230,140, {|u| If(PCount() > 0, _cGet1:= u, _cGet1)}, oDlg2,, 009, "@!",{||Leitura(_cPrecar, _cPreped)}, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet1,,,,.t.,)

	@ 0120,005 To 205,420 Browse "TMPP"  fields aCampos object oiBrowse
	
	_oGet1:setFocus()
	oDlg2:refresh()
	
	//_oSay2   := TSay():New(240,005, {|| 'Peso do Pallet:'}, oDlg2,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	//_oGet2   := TGet():New(240,140, {|u| If(PCount() > 0, _cGet2:= u, _cGet2)}, oDlg2,, 009, "@E 99.99",, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet2,,,,.t.,)

	//_oBtn1 := TButton():New(255,200, "Imprimir", oDlg2,{||Imprime(_cGet1)},40,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oBtn2 := TButton():New(255,260, "Sair"    , oDlg2,{||oDlg2:end()},40,20,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE DIALOG oDlg2 CENTERED

	TMPP->(dbCloseArea())
Return

//Função de validação das leituras de pallets
Static Function Leitura(_cPrecar,_cPreped)

	if _nModo = 1
		_lRet := carrega(_cPrecar,_cPreped)
	elseif _nModo = 2
		_lRet := exclui(_cPrecar,_cPreped)
	endif

return _lRet

static function modos()

	_cGet1:= space(11)
	_cMemo := ''
	_oGet1:refresh()
	_oMemo:refresh()
	oDlg2:refresh()

return

Static Function criaTEMP(_cPrecar,_cPreped)

	//_area       := getarea()
	aStru 		:= {}

	cQuery := " SELECT ZBF_NUM, ZBF_DATAS, ZBF_HORAS, ZBF_USRCAR, ZBF_PESO
	cQuery += " FROM " + retSqlTab('ZBF')
	cQuery += " WHERE " + retSqlFil('ZBF')
	cQuery += " AND ZBF_PRECAR = '" + _cPrecar + "' AND ZBF_PREPED = '" + _cPreped + "'"
	cQuery += " AND " + retSqlDel('ZBF')
	cQuery += " ORDER BY ZBF_NUM"

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlg2Memo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlg2Memo

	cQuery := ChangeQuery(cQuery)

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "QRY"

	//area := getarea()

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	dbSelectarea('QRY')

	_aArqTrb := {}
	aStru := dbStruct()
	aadd(aStru,{"NUMERO" , "C",  10, 0,    "" , 'Numero'  	})
	aadd(aStru,{"DTINC"  , "D",  8,  0,    "" , 'Data'    	})
	aadd(aStru,{"HORA"   , "C",  5,  0,    "" , 'Hora'    	})
	aadd(aStru,{"PESO"   , "N",  5,  2,    "" , 'Peso'    	})
	aadd(aStru,{"USUAR"  , "C",  6,  0,    "" , 'Cod.Usuar.'})
	aadd(aStru,{"NOME"   , "C",  20, 0,    "" , 'Nome'    	})

	//dbcreate(cArq,aStru)
	//If Select("TMPP")!=0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMPP->(dbCloseArea())
	//Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMPP", .F. , .F. )

	If Select('TMPP')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TMPP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMPP", aStru, {}, @_aArqTrb)

	PswOrder(2) // ordena pelo nome de usuário

	QRY->(dbGoTop())
	while QRY->(!eof())

		PswSeek(AllTrim(QRY->ZBF_USRCAR)) // Posiciona no usuário desejado
		cNomeUsr := PswRet()[1][2] // Recebe o nome do do usuário.
		cNome    := PswRet()[1][4] // Recebe o nome completo do usuário.

		DbSelectArea("TMPP")
		reclock("TMPP",.t.)
		TMPP->NUMERO  := QRY->ZBF_NUM
		TMPP->DTINC   := STOD(QRY->ZBF_DATAS)
		TMPP->HORA    := QRY->ZBF_HORAS
		TMPP->PESO    := QRY->ZBF_PESO
		TMPP->USUAR   := QRY->ZBF_USRCAR
		TMPP->NOME    := cNome
		msunlock()

		QRY->(dbskip())

	enddo

	aadd(aCampos,{"NUMERO" ,"Numero    	"  	,""   		})
	aadd(aCampos,{"DTINC"  ,"Data      	"  	,"@E 99/99/99" })
	aadd(aCampos,{"HORA"   ,"Hora		" 	,"@!" 		})
	aadd(aCampos,{"PESO"   ,"Peso 		" 	,"@E 99.99" })
	aadd(aCampos,{"USUAR"  ,"Cod.Usuar. " 	,"@!" 		})
	aadd(aCampos,{"NOME"   ,"Nome   	"   ,"@!"   	})

	TMPP->(dbgotop())

	//@ 008,005 say 'Total de Caixas: ' + transform(_nTotCaix,'@E 999,999')
	//@ 008,030 say 'Total de Peso: '   + transform(_nTotPeso,'@E 999,999,999.99')

	//dbclosearea("TMPP")
	//dbclosearea('PRO')

	//
	//QRY->(dbCloseArea())

	//restarea(_area)

return

static function carrega(_cPrecar,_cPreped)

	Local _lRet := .f.

	//Se o campo estiver em branco
	if empty(_cGet1)
		_lRet := .t.
	else
		//Se o tamanho do codigo for menor que 10 digitos
		if len(alltrim(_cGet1)) < 10
			alert('Falha na leitura!')
			SomErr()
		else

			ZBF->(DbSetOrder(1))
			if !ZBF->(MsSeek(FWxfilial("ZBF")+alltrim(_cGet1)))
				Help(" ",1,"ERRO",,"Pallet não encontrado!",4,1)
				SomErr()
			else

				//Verifica se a caixa ainda está em estoque
				if !empty(ZBF->ZBF_DATAS) .or. !empty(ZBF->ZBF_HORAS)
					Help(" ",1,"NÃO PERMITIDO!",,"Pallet já encontra-se fora de estoque!",4,1)
					SomErr()
				else

					reclock('ZBF',.f.)
					ZBF->ZBF_PRECAR := _cPrecar
					ZBF->ZBF_PREPED := _cPreped
					ZBF->ZBF_HORAS  := time()
					ZBF->ZBF_DATAS  := ddatabase
					ZBF->ZBF_USRCAR := retCodUsr()
					msunlock()

					PswOrder(1) // ordena pelo nome de usuário
					PswSeek(AllTrim(ZBF->ZBF_USRCAR)) // Posiciona no usuário desejado
					cNomeUsr := PswRet()[1][2] // Recebe o nome do do usuário.
					cNome    := PswRet()[1][4] // Recebe o nome completo do usuário.

					TMPP->(dbGoTop())
					reclock('TMPP',.t.)
					TMPP->NUMERO  := ZBF->ZBF_NUM
					TMPP->DTINC   := ZBF->ZBF_DATAS
					TMPP->HORA    := ZBF->ZBF_HORAS
					TMPP->PESO    := ZBF->ZBF_PESO
					TMPP->USUAR    := ZBF->ZBF_USRCAR
					TMPP->NOME    := cNome
					msunlock()

					_cMemo :=  padc('[ PALLET CARREGADO ]',68,' ')	+ chr(13) + chr(10)
					_cMemo += Replicate("=",68) + chr(13) + chr(10)
					_cMemo += "Codigo do Pallet: 	  " + ZBF->ZBF_NUM + chr(13) + chr(10)
					_cMemo += "Data do Carregamento:  " + dtoc(ZBF->ZBF_DATAS) + chr(13) + chr(10)
					_cMemo += "Hora do Carregamento:  " + ZBF->ZBF_HORAS + chr(13) + chr(10)
					_cMemo += "Peso do Pallet:   	  " + transform(ZBF->ZBF_PESO,"@ 999.99") + chr(13) + chr(10)
					_cMemo += "Usuario:          	  " + cUserName + chr(13) + chr(10)
					_cMemo += Replicate("=",68) + chr(13) + chr(10)
					_oMemo:refresh()

					TMPP->(dbGoTop())
					oDlg2:refresh()
					oiBrowse:oBrowse:refresh()
					execsom()

					//_oGet1:setFocus()

				endif
			endif
		endif
	endif

	_cGet1:= space(11)
	_oGet1:Refresh()
	oDlg2:refresh()

return _lRet

static function exclui(_cPrecar,_cPreped)

	Local _lRet := .f.

	//Se o campo estiver em branco
	if empty(_cGet1)
		_lRet := .t.
	else

		//Se o tamanho do codigo for menor que 10 digitos
		if len(alltrim(_cGet1)) < 10
			alert('Falha na leitura!')
			SomErr()
		else

			ZBF->(DbSetOrder(1))
			if !ZBF->(MsSeek(FWxfilial("ZBF")+alltrim(_cGet1)))
				Help(" ",1,"ERRO",,"Pallet não encontrado!",4,1)
				SomErr()
			else

				//Verifica se a caixa ainda está em estoque
				if empty(ZBF->ZBF_DATAS) .or. empty(ZBF->ZBF_HORAS)
					Help(" ",1,"NÃO PERMITIDO!",,"Pallet já encontra-se em estoque!",4,1)
					SomErr()
				else

					if ZBF->ZBF_PRECAR <> _cPrecar .or. ZBF->ZBF_PREPED <> _cPreped
						Help(" ",1,"NÃO PERMITIDO!",,"Pallet não pertence a este pre-pedido!",4,1)
						SomErr()
					else

						_cMemo :=  padc('[ PALLET EXCLUIDO ]',68,' ')	+ chr(13) + chr(10)
						_cMemo += Replicate("=",68) + chr(13) + chr(10)
						_cMemo += "Codigo do Pallet: 	  " + ZBF->ZBF_NUM + chr(13) + chr(10)
						_cMemo += "Data do Carregamento:  " + dtoc(ZBF->ZBF_DATAS) + chr(13) + chr(10)
						_cMemo += "Hora do Carregamento:  " + ZBF->ZBF_HORAS + chr(13) + chr(10)
						_cMemo += "Peso do Pallet:   	  " + transform(ZBF->ZBF_PESO,"@ 999.99") + chr(13) + chr(10)
						_cMemo += "Usuario:          	  " + cUserName + chr(13) + chr(10)
						_cMemo += Replicate("=",68) + chr(13) + chr(10)
						_oMemo:refresh()

						reclock('ZBF',.f.)
						ZBF->ZBF_PRECAR := ''
						ZBF->ZBF_PREPED := ''
						ZBF->ZBF_HORAS  := ''
						ZBF->ZBF_DATAS  := stod('')
						ZBF->ZBF_USRCAR := ''
						msunlock()

						PswOrder(1) // ordena pelo nome de usuário
						PswSeek(AllTrim(ZBF->ZBF_USRCAR)) // Posiciona no usuário desejado
						cNomeUsr := PswRet()[1][2] // Recebe o nome do do usuário.
						cNome    := PswRet()[1][4] // Recebe o nome completo do usuário.

						u_dtilog(cFilAnt, "DTI73", "Exclusão do Pallet -> " + ZBF->ZBF_NUM + " | Carreg. -> " + ZBF->ZBF_PRECAR, "E")

						TMPP->(dbGoTop())
						reclock('TMPP',.f.)
						dbDelete()
						msunlock()

						TMPP->(dbGoTop())
						oDlg2:refresh()
						oiBrowse:oBrowse:refresh()
						execsom()
						//_oGet1:setFocus()
					endif
				endif
			endif
		endif
	endif

	_cGet1:= space(11)
	_oGet1:Refresh()
	oDlg2:refresh()
return

static function execsom()

	WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE.WAV',0)

return

Static Function SomErr()

	WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0)

return
