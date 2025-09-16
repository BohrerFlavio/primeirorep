#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MRVT03     º Autor ³Mauricio Roehrsº   Data ³  03/08/12     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplicação para microterminais VT-100 Controle de Camaras   º±±
±±º          ³ do Abate                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


User Function MRVT03(_usuario)
	Private lOk       := .t. 
	Private _cModelo  := ''
	Private _cCod     := ''
	Private _cCam	  := space(02)
	Private _cListcam := GetMv("SI_CAMABT")  

	ZAA->(DbSetOrder(2))
	ZAA->(MsSeek(FWxfilial('ZAA')+_usuario))

	if ZAA->ZAA_APL03 <> 'S'
		VTAlert('Opção negada para o usuario!','Aviso',.T.,1000,1)
		return .t.
	endif

	//Define o tamanho da tela
	_cModelo = VTModelo()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	VTClear()
	VTClearBuffer()
	
	while lOk

		_cCod := Space(11)
		
		@ 01,05 VTSay "Controle de Camaras"
		@ 02,13 VTSay "De"
		@ 03,05 VTSay "Resfriamento do Abate"
		@ 06,05 VTSay "Codigo da Caraca"
		@ 07,02 VTSay "[           ]
		@ 05,00 VTSay "Camara:[  ] "
		@ 05,08 VTGet _cCam Pict "@!" VALID _cCam $ _cListCam
		@ 07,03 VTGet _cCod Pict "@!" VALID ValCam02()

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		VTClearBuffer()
	enddo

	VTClear()
	VTClearBuffer()
return


Static Function ValCam02()

	_cNumam   := ''
	_cControl := ''

	if empty(_cCod)
		return .t.
	endif

	ZAJ->(DbGoTop())
	ZAJ->(DbSetOrder(2))
	if ZAJ->(MsSeek(FWxFilial('ZAJ')+alltrim(_cCod))) .and. len(alltrim(_cCod)) = 10
		_cNumam	  := ZAJ->ZAJ_NUMAM
		_cControl := ZAJ->ZAJ_CONTRO

		if ZAJ->ZAJ_CORORI = "C"
			SZK->(DbGoTop())
			SZK->(DbSetOrder(4))
			if SZK->(MsSeek(FWxfilial('SZK')+alltrim(_cNumam)+alltrim(_cControl)))

				VTAlert('Confirma apontamento? (Enter:Sim,Esc:Nao)','Atencao',.T.)

				If (VTLastKey() == 27)
					VTAlert('Operação Cancelada!','Aviso de Encerramento(04)',.T.,100,1)
					NaoAchou('Operação Cancelada!')			
					_cCod := Space(11)
					_cNumam   := ''
					_cControl := ''		
					return .f.
				else
					if SZK->ZK_CLASESP = '1' .and. AllTrim(SZK->ZK_CLASABA) != 'NE'
						VTAlert('Confirma maturação? (Enter:Sim,Esc:Nao)','Atencao',.T.)
						if (VTLastKey() == 27)
							Reclock('SZK',.f.)
							SZK->ZK_CLASESP := '2'
							SZK->ZK_CLESPAB := '2'
							SZK->ZK_LOCAL := _cCam
							Msunlock()
							SimAchou()
							return .f.
						else
							Reclock('SZK',.f.)
							SZK->ZK_LOCAL := _cCam
							Msunlock()
						endif
					else
						Reclock('SZK',.f.)
						SZK->ZK_LOCAL := _cCam
						Msunlock()
					endif
				endif     

				SimAchou()

				return .t.
			endif
		else
			VTAlert('Corte invalido! Não é costela!','Atencao',.T.)
			VTBeep(2)
		endif
	else
		//	VTAlert('Carcaca Nao Encontrada(2)','Aviso!',.T.,500,1)
		NaoAchou('Carcaça não encontrada!')
		_cNumam   := ''
		_cControl := ''
	endif

return .f.      


Static Function NaoAchou(_cMens)
	VTBeep(1)

	@09,00 VTSay Space(30)
	@10,00 VTSay "Cod. Etq.:   "+Space(30)
	@10,14 VTSay _cCod
	@11,00 VTSay ''+Space(30)
	@12,00 VTSay ''+Space(30)
	@13,00 VTSay ''+Space(30)
	@11,00 VTSay _cMens + Space(30)

	_cCod := Space(11)
return .f.  


Static Function SimAchou()

	@09,00 VTSay "CARCACA ARMAZENADA!"
	@10,00 VTSay "Cod. Etq.:   "
	@11,00 VTSay "Abate: "
	@12,00 VTSay "Sequencial:   "
	@13,00 VTSay "Camara: "
	@10,14 VTSay _cCod
	@11,14 VTSay _cNumam
	@12,14 VTSay _cControl
	@13,14 VTSay _cCam// + "/" + AllTrim(STR(QuerySQL(_cCod,_cCam)))
	@14,00 VTSay "Carcaças na camara " + _cCam + ": "+ AllTrim(STR(QuerySQL(_cCod,_cCam)))

	_cCod := Space(11)
	_cNumam   := ''
	_cControl := ''
return .f.

Static Function QuerySQL(cCod,cCam)
	_cQRY := "SELECT COUNT(*) AS CONTADOR "
	_cQRY += "FROM " + retSqlTab('SZK')
	_cQRY += "INNER JOIN " + retSqlTab('ZAJ') + " ON ZAJ_NUMAM = ZK_NUMAM"
	_cQRY += "WHERE " + retSqlFil('SZK') + " AND " + retSqlFil('ZAJ')
	_cQRY += " AND " + retSqlDel('SZK') + " AND " + retSqlDel('ZAJ')
	_cQRY += " AND	ZAJ_NUM = '" + cCod + "' AND	ZK_LOCAL = '" + cCam + "'"

	_cQRY := ChangeQuery(_cQRY)

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQRY NEW ALIAS "QRY"

	n := QRY->CONTADOR
return n
