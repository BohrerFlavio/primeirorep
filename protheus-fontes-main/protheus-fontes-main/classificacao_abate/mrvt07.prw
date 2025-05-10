#INCLUDE "rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "apvt100.ch"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MRVT07     º Autor ³Giuliano Forgiariniº Data ³  30/02/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplicação para microterminais VT-100 para informar dados deº±±
±±º          ³Produção do Abate                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Abate                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MRVT07(_usuario)
	//Local   _cLote    := ''
	Private _Lot      := ''
	Private _cNumam   := ''
	Private dAbate    := stod('')
	Private _lOk      := .t.
	Private _lOK2     := .t.
	Private _lVal	  := .t.
	Private _cModelo  := ''
	Private _nAni     := 0
	Private _cPar01   := '1'       		//Imprime costela		: 1- Sim 		| 2 - Não
	Private _cPar02   := '1'       		//Balança        		: 1- Balança 1 | 2 - Balanca 2
	Private _cPar03   := '1'       		//Impressora     		: 1- impress.1 | 2 - Impress.2
	Private _cPar04   := '1'       		//OPERACAO       		: 1- Produzir  | 2 - Pendentes  | 3 - Visualizar
	Private _cPar05   := '1'       		//Tipo de Etiqueta  	: 1- Antiga  	| 2 - Nova
	Private _cImpRe	  := '1'			//Impressora     		: 1- impress.1 | 2 - Impress.2 | 3 - Impress. PCP
	Private _cIpBal   := ''
	Private _cIpImp   := ''
	Private _lBal      := .f.            //Ativação dos parametros da balança
	Private oObj
	Private nResp      := 0
	Private _ZK_C1     := 0
	Private _ZK_C2     := 0
	Private lAviso     := Getmv('SI_AVISO')
	Private nTara      := Getmv('SI_TARA')
	Private nTaraT     := Getmv('SI_TARAT')
	Private nPesPar	   := Getmv('SI_AVISOPS')
	Private cUsrRAbt   := alltrim(Getmv('SI_USRRABT'))	// Parâmetro com usuários que podem reimprimir etiquetas de qualquer abate
	Private _cUlAvis   := GetAdvFVal('SZG','ZG_NUMAM',FWxFilial('SZG') + iif(dow(date()) = 2, DtoS(Date()-2), DtoS(Date())),2) + " "
	Private lProgRT    := Getmv('SI_PROGRT')

	//Prepara o ambiente para a rotina
	//PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'PCP' TABLES 'SZG','SZK','SZ4','SZD','SZE'

	ZAA->(DbSetOrder(2))
	ZAA->(MsSeek(FWxfilial('ZAA')+_usuario))

	if ZAA->ZAA_APL02 <> 'S'
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

	if RetCodUsr() $ cUsrRAbt
		while _lVal
			VTClear()
			VTClearBuffer()

			@ 01,05 VTSay "NUMERO DO AVISO DE MATANCA"
			@ 06,08 VTSay "[" + _cUlAvis + "]"
			@ 07,00 VTSay "Impressora:   [ ] 1:Imp1|2:Imp2|3:PCP"
			@ 06,09 VTGet _cUlAvis Pict "@!" VALID ValAbt() .and. !_lVal
			@ 07,15 VTGet _cImpRe Pict "@!" valid (_cImpRe $ '123')
			@ 16,00 VTSay "ESC para Sair"

			VTRead

			if (VTLastKey() == 27)
				VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,1000,1)
				exit
			endif

		end
		VTClear()
		VTClearBuffer()
	else
		SZG->(DbSetOrder(3))
		if !SZG->(MsSeek(FWxfilial('SZG')+'A'))
			VTAlert('Não há Abate!','Aviso',.T.,1000,1)
			return .t.
		endif
	endif

	//Interface inicial de parametros da rotina
	while _lOk
		VTClear()
		VTClearBuffer()

		@ 01,05 VTSay "PRODUCAO DO ABATE"
		@ 02,05 VTSay "Parametros Iniciais:"
		@ 04,00 VTSay "Imp.Cost.:    [ ] 1:S|2:N"
		@ 05,00 VTSay "Balança:      [ ] 1:Bal1|2:Bal2"
		@ 06,00 VTSay "Impressora:   [ ] 1:Imp1|2:Imp2"
		@ 07,00 VTSay "Tipo Etiqueta:[ ] 1:Ant.|2:Nova"
		@ 09,00 VTSay "OPERACAO:     [ ]"
		@ 10,00 VTSay "1 - Produzir"
		@ 11,00 VTSay "2 - Pendentes"
		@ 12,00 VTSay "3 - Visualizar"
		@ 15,00 VTSay "ESC para Sair"

		@ 04,15 VTGet _cPar01 Pict "@! "  valid (_cPar01 $ '12')
		@ 05,15 VTGet _cPar02 Pict "@! "  valid (_cPar02 $ '12')
		@ 06,15 VTGet _cPar03 Pict "@! "  valid (_cPar03 $ '12')
		@ 07,15 VTGet _cPar05 Pict "@! "  valid (_cPar05 $ '12')
		if RetCodUsr() $ cUsrRAbt
			@ 09,15 VTGet _cPar04 Pict "@! "  valid (_cPar04 = '3')
		else
			@ 09,15 VTGet _cPar04 Pict "@! "  valid (_cPar04 $ '123')
		endif

		VTRead

		//	Testakey()

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,1000,1)
			exit
		EndIF

		_cNumam := SZG->ZG_NUMAM

		//chama a função para conctar na balança
		conectBal()

		//Define o IP da impressora a ser utilizada
		if RetCodUsr() $ cUsrRAbt
			_cIpImp := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM') + iif(_cImpRe = '1','IABT1',iif(_cImpRe = '2','IABT2','PCP11')),1))
		else
			_cIpImp := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM') + iif(_cPar03 = '1','IABT1','IABT2'),1))			
		endif
		//_cIpImp := '10.11.20.43'
		//Chama a operação apontada
		do case
			case _cPar04 = '1'
			Lotes()
			case _cPar04 = '2'
			Pendentes()
			case _cPar04 = '3'
			Visualizar()
		endcase

	enddo

	VTClear()
	VTClearBuffer()

Return .t.

Static Function ValAbt()

	SZG->(DbSetOrder(1))
	if !SZG->(MsSeek(FWxfilial('SZG')+_cUlAvis))
		VTAlert('Abate não encontrado!','Aviso',.T.,1000,1)
		return .f.
	else
		_lVal := .f.
		_cPar04 := '3'
	endif

Return .t.

//Função para criar o browse ded produção dos lotes
Static Function Lotes()

	VTClear()
	VTClearBuffer()

	aFields := {"Z4_LOTE","Z4_NOME","Z4_CLASSIF","Z4_DESCAT","Z4_QUANT","Z4_QTREAL"}
	aHeader := {'LOTE','NOME','CL','CAT','QUA','REA'}
	//aSize   := {06,06,02,03,03,03}
	aSize   := {06,06,03,03,03,03}

	//Laço para realizar a operação
	//de escolha do lote e produção deste
	_lOk2 := .t.

	While _lOk2

		If (VTLastKey() == 27)
			VTAlert('Operação Cancelada!','Aviso de Encerramento(02)',.T.,2000,1)
			exit
		EndIf

		DbSelectArea('SZ4')
		SZ4->(DbSetOrder(1))
		SZ4->(MsSeek(FWxfilial('SZ4')+ _cNumam ))

		SET FILTER TO SZ4->Z4_FILIAL = FWxfilial('SZ4') .and. SZ4->Z4_NUMAM == _cNumam

		nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"SZ4",aHeader,aFields,aSize,"u_MR7Pro",)

		SET FILTER TO

		If (VTLastKey() == 27)
			VTAlert('Operação Cancelada!','Aviso de Encerramento(03)',.T.,2000,1)
			exit
		EndIf

		//Chama produção dos lotes
		if _lOk2
			if !Prolote()
				exit
			endif
		endif

	EndDo

return

//Função para criar o browse de dependentes
Static Function Pendentes()

	VTClear()
	VTClearBuffer()

	_lExistP := .f.

	aFields := {"Z4_LOTE","Z4_NOME","Z4_CLASSIF","Z4_DESCAT","Z4_QUANT","Z4_QTREAL"}
	aHeader := {'LOTE','NOME','CL','CAT','QUA','REA'}
	//aSize   := {06,06,02,03,03,03}
	aSize   := {06,06,03,03,03,03}

	//Laço para realizar a operação
	//de escolha do lote e produção deste
	_lOk2 := .t.

	While _lOk2

		If (VTLastKey() == 27)
			VTAlert('Operação Cancelada!','Aviso de Encerramento(02)',.T.,2000,1)
			exit
		EndIf

		DbSelectArea('SZ4')
		SZ4->(DbSetOrder(1))
		SZ4->(DbGoTop())
		SZ4->(MsSeek(FWxfilial('SZ4')+ _cNumam ))
		While SZ4->Z4_NUMAM = _cNumam

			if VerPend(SZ4->Z4_NUMAM,SZ4->Z4_LOTE)
				_Pend := 'P'
				_lExistP := .t.
			else
				_Pend := 'S'
			endif

			reclock('SZ4',.f.)
			SZ4->Z4_PEND := _Pend
			msunlock()

			SZ4->(DbSkip())
		enddo

		if _lExistP
			DbSelectArea('SZ4')
			SZ4->(DbSetOrder(5))
			SZ4->(DbGoTop())
			SZ4->(MsSeek(FWxfilial('SZ4')+ _cNumam + 'P' ))

			SET FILTER TO SZ4->Z4_FILIAL = FWxfilial('SZ4') .and. SZ4->Z4_NUMAM == _cNumam  .and. SZ4->Z4_PEND = 'P'

			nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"SZ4",aHeader,aFields,aSize,"u_MR7Pr3",)

			SET FILTER TO

			If (VTLastKey() == 27)
				VTAlert('Operação Cancelada!','Aviso de Encerramento(03)',.T.,2000,1)
				exit
			EndIf

			//Chama pendencia dos lotes
			if _lOk2
				if !Pendlote()
					exit
				endif
			endif

		else
			VTAlert('Não existem carcaças pendentes!','Aviso de Encerramento(03)',.T.,2000,1)
			_lOk2 := .f.
			exit
		endif

	EndDo

return

//Função par acriar o browse de visualização
Static Function Visualizar()

	VTClear()
	VTClearBuffer()

	aFields := {"Z4_LOTE","Z4_NOME","Z4_CLASSIF","Z4_DESCAT","Z4_QUANT","Z4_QTREAL"}
	aHeader := {'LOTE','NOME','CL','CAT','QUA','REA'}
	//aSize   := {06,06,02,03,03,03}
	aSize   := {06,06,03,03,03,03}

	//Laço para realizar a operação
	//de escolha do lote e produção deste
	_lOk2 := .t.

	While _lOk2

		If (VTLastKey() == 27)
			VTAlert('Operação Cancelada!','Aviso de Encerramento(02)',.T.,2000,1)
			exit
		EndIf

		DbSelectArea('SZ4')
		SZ4->(DbSetOrder(1))
		SZ4->(DbGoTop())
		SZ4->(MsSeek(FWxfilial('SZ4')+ _cNumam ))

		SET FILTER TO SZ4->Z4_FILIAL = FWxfilial('SZ4') .and. SZ4->Z4_NUMAM == _cNumam

		nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"SZ4",aHeader,aFields,aSize,"u_MR7Pr3",)

		SET FILTER TO

		If (VTLastKey() == 27)
			VTAlert('Operação Cancelada!','Aviso de Encerramento(03)',.T.,2000,1)
			exit
		EndIf

		//Chama visualização dos lotes
		if _lOk2
			if !Vislote()
				exit
			endif
		endif

	EndDo

return

//Função de produção dos lotes
Static Function ProLote()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	SZD->(DbSetOrder(1))
	SZE->(DbSetOrder(2))
	SZE->(MsSeek(FWxfilial('SZE')+SZ4->(Z4_NUMAM+Z4_LOTE),.f.))

	DbSelectArea("SZK")

	SZK->(DbGoTop())
	SZK->(DbSetOrder(3))
	SZK->(Msseek(FWxFilial('SZK')+SZ4->(Z4_NUMAM+Z4_LOTE),.t.))

	lSreg := .t.
	lFechado := .f.

	Do while SZK->(!eof()) .and. SZK->(ZK_FILIAL+ZK_NUMAM+ZK_LOTE)==FWxFilial('SZK')+SZ4->(Z4_NUMAM+Z4_LOTE)
		if empty(SZK->ZK_OK)
			lSReg := .f.
			_lOk2 := ProCarc()

			if !_lOk2
				return .f.
			endif
		endif

		SZK->(DbSkip())
	EndDo

	_lFechado := verAviso(SZ4->Z4_NUMAM,SZ4->Z4_LOTE)

	VTClear()
	VTClearBuffer()

	if _lFechado
		VTAlert('Produção do Abate Encerrada!!','Aviso de Encerramento(06)',.T.,2000,1)
		return .f.
	endif

	if lSreg
		VTAlert('Status fechado, não há atualização!','Aviso de Encerramento(04)',.T.,2000,1)
		return .f.
	endif

	CURSORARROW()

Return .t.

//Função de pendentes dos lotes
Static Function PendLote()

	_lOk3 := .t.

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	SZD->(DbSetOrder(1))
	SZE->(DbSetOrder(2))
	SZE->(MsSeek(FWxfilial('SZE')+SZ4->(Z4_NUMAM+Z4_LOTE),.f.))

	while _lOk3

		VTClear()
		VTClearBuffer()

		aFields := {"ZK_CONTROL"}
		aHeader := {"SEQUENCIAL CARCACA"}
		aSize   := {18}

		if VerPend(SZ4->Z4_NUMAM,SZ4->Z4_LOTE)
			_Pend := 'P'
		else
			_Pend := 'S'
		endif

		reclock('SZ4',.f.)
		SZ4->Z4_PEND := _Pend
		msunlock()

		if _Pend = 'P'
			DbSelectArea("SZK")
			SZK->(DbSetOrder(8))
			SZK->(DbGotop())
			SZK->(MsSeek(FWxfilial('SZK')+SZ4->(Z4_NUMAM+Z4_LOTE)+'P'))

			SET FILTER TO SZK->ZK_FILIAL = FWxfilial('SZK') .and. SZK->ZK_NUMAM == _cNumam .and. SZK->ZK_LOTE = SZ4->Z4_LOTE .and. SZK->ZK_OK = 'P'

			nRecno2 := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"SZK",aHeader,aFields,aSize,"u_MR7Pr2",)

			SET FILTER TO

			If (VTLastKey() == 27)
				VTAlert('Operação Cancelada!','Aviso de Encerramento(03)',.T.,2000,1)
				_lOk3 := .f.
				exit
			EndIf

			if _lOk3
				PendCarc()
			endif
		else
			VTAlert('Operação Cancelada!','Nao existem carcaças pendentes!',.T.,2000,1)
			_lOk2 := .f.
			_lOk3 := .f.
		endif
		VTClear()
		VTClearBuffer()

		CURSORARROW()

	enddo

Return .t.

//Função de visualização dos lotes
Static Function VisLote()

	_lOk3 := .t.

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	while _lOk3
		VTClear()
		VTClearBuffer()

		aFields := {"ZK_CONTROL"}
		aHeader := {"SEQUENCIAL CARCACA"}
		aSize   := {18}

		DbSelectArea("SZK")
		SZK->(DbSetOrder(2))
		SZK->(DbGotop())
		SZK->(MsSeek(FWxfilial('SZK')+SZ4->(Z4_NUMAM+Z4_LOTE)))

		SET FILTER TO SZK->ZK_FILIAL = FWxfilial('SZK') .and. SZK->ZK_NUMAM == _cNumam .and. SZK->ZK_LOTE = SZ4->Z4_LOTE

		nRecno2 := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"SZK",aHeader,aFields,aSize,"u_MR7Pr2",)

		SET FILTER TO

		If (VTLastKey() == 27)
			VTAlert('Operação Cancelada!','Aviso de Encerramento(03)',.T.,2000,1)
			_lOk3 := .f.
			exit
		EndIf

		//Chama visualização da carcaça
		if _lOk3
			VisCarc()
		endif

		VTClear()
		VTClearBuffer()

		CURSORARROW()

	enddo

Return .t.

//Função de processamento da carcaça - producao
Static Function ProCarc()
	Local _ret      := .t.
	Private ord17   := .F. // Apenas para permitir a alteracao do campo zk_obs

	lOk := .f.
	nrec := SZK->(recno())

	SZK->(DbSetOrder(4))
	SZK->(Msseek(FWxFilial('SZK')+SZ4->Z4_NUMAM,.t.))
	nControl := 1

	//Bloco par aposicionar o sequencial do lote
	Do While SZK->(!eof()) .and. SZK->(ZK_FILIAL+ZK_NUMAM) == FWxFilial('SZK')+SZ4->Z4_NUMAM
		nControl := val(SZK->(ZK_CONTROL))+1
		SZK->(dbSKIP())
	Enddo

	SZK->(DbSetOrder(3))
	DbselectArea('SZK')
	Dbgoto(nrec)

	dAbate := GetAdvFVal('SZG','ZG_DATA',FWxFilial('SZG')+ZK_NUMAM+ZK_LOTE,1)

	_ZK_OBS       := SZK->ZK_OBS
	_ZK_DESTINO   := SZK->ZK_DESTINO
	_ZK_CLASSIF   := SZK->ZK_CLASSIF
	_ZK_COBGOR    := SZK->ZK_COBGOR
	_ZK_DENT      := SZK->ZK_DENT
	_ZK_CATEG     := SZK->ZK_CATEG
	_ZK_CONFORM   := SZK->ZK_CONFORM
	_ZK_RASTRO    := SZK->ZK_RASTRO
	_ZK_TIPIFI    := SZK->ZK_TIPIFI
	_ZK_PROGRAM   := SZK->ZK_PROGRAM
	_ZK_PROGPGP   := SZK->ZK_PROGRAM	// Programa para Progepec
	_ZK_HORA      := SZK->ZK_HORA
	_ZK_CONTROL   := SZK->ZK_CONTROL
	_ZK_TUBERC    := SZK->ZK_TUBERC
	_ZK_MATURA    := 'S'//SZK->ZK_MATURA
	_ZK_PETOTAL   := SZK->ZK_PETOTAL
	_ZK_RACA	  := SZK->ZK_RACA
	_ZK_CONTUSA   := SZK->ZK_CONTUSA
	_ZK_CNTMINA   := SZK->ZK_CNTMINA
	_ZK_REGICTS   := SZK->ZK_REGICTS
	_ZK_SEXO      := SZK->ZK_SEXO
	_ZK_CDIAN1    := SZK->ZK_CDIAN1
	_ZK_CDIAN2    := SZK->ZK_CDIAN2
	_ZK_CLASESP   := SZK->ZK_CLASESP
	_ZK_CLESPAB   := SZK->ZK_CLASESP
	_ZK_C1        := 0//SZK->ZK_PECARC1
	_ZK_C2        := 0//SZK->ZK_PECARC2
	_ZK_BLACK     := SZK->ZK_BLACK
	_ZK_BRINCO    := SZK->ZK_BRINCO
	_ZK_SINC      := SZK->ZK_SINC

	If Empty(SZK->ZK_CONTROL) // caso já tenha havido pesagem
		_ZK_HORA    := time()
		_ZK_CONTROL := strzero(nControl,6)
		_ZK_TUBERC  := 'N'
	Endif

	VTClear()
	VTClearBuffer()

	_KeyD := VTSetKey(100,{|| Pesar("D") })
	_KeyE := VTSetKey(101,{|| Pesar("E") })
	_imp  := VTSetKey(109,{|| ImpEtq('I') })
	_cProx := " "

	@ 02,00 VTSay "LOTE:       " + SZ4->Z4_LOTE
	@ 03,00 VTSay "SEQUENCIAL: " + strzero(val(_ZK_CONTROL),6)
	@ 04,00 VTSay "ORDEM LOTE: " + str(SZK->ZK_ORDEM,3,0)

	@ 05,00 VTSay "GORDURA:    ["+SZK->ZK_COBGOR+"]"
	@ 06,00 VTSay "DENTICAO:   ["+SZK->ZK_DENT+"]"
	@ 07,00 VTSay "CONFORMAÇAO:["+SZK->ZK_CONFORM+"]"
	@ 08,00 VTSay "RACA:       ["+SZK->ZK_RACA+"]"
	@ 09,00 VTSay "PROGRAMA:   ["+SZK->ZK_PROGRAM+"]"
	@ 10,00 VTSay "DESTINO:    [ ] C|T|I|R|G|S"
	////
	@ 11,00 VTSay "CONTAMIN.:  [ ] S|N"
	@ 12,00 VTSay "CONTUSAO :  [ ] S|N"
	@ 13,00 VTSay "REGIAO   :  [ ] C|R|P|T|O|B"
	////
	@ 14,00 VTSay "COND.DIAN1: [ ] C|N"
	@ 15,00 VTSay "COND.DIAN2: [ ] C|N"
	@ 16,00 VTSay "CLAS.ESP.:  [ ] 1|2"
	@ 17,00 VTSay "(D)ir.["+transform(_ZK_C1,'@E 999.99')+"] (E)sq.["+transform(_ZK_C2,'@E 999.99')+"]"
	@ 18,00 VTSay "Proximo?(S) [ ]"
	@ 19,00 VTSay "ESC Sair  M Imprimir"

	@ 10,13 VTGet _ZK_DESTINO Pict "@!" VALID (_ZK_DESTINO $ 'CTIRGS')

	@ 11,13 VTGet _ZK_CNTMINA  Pict "@!" VALID (_ZK_CNTMINA $ 'SN')  .or. empty(_ZK_CNTMINA)
	@ 12,13 VTGet _ZK_CONTUSA  Pict "@!" VALID (_ZK_CONTUSA $ 'SN')  .or. empty(_ZK_CONTUSA)
	@ 13,13 VTGet _ZK_REGICTS  Pict "@!" VALID (_ZK_REGICTS $ 'CRPTOB') .or. empty(_ZK_REGICTS)

	@ 14,13 VTGet _ZK_CDIAN1  Pict "@!" VALID (_ZK_CDIAN1 $ 'CN') .or. empty(_ZK_CDIAN1)
	@ 15,13 VTGet _ZK_CDIAN2  Pict "@!" VALID (_ZK_CDIAN2 $ 'CN') .or. empty(_ZK_CDIAN2)
	@ 16,13 VTGet _ZK_CLASESP Pict "@!" VALID (_ZK_CLASESP $ '12').and. !empty(_ZK_CLASESP)
	@ 18,13 VTGet _cProx      Pict "@!" VALID (_cProx = 'S') .and. (_ZK_C1 > 50 .and. _ZK_C1 < 320  ) .and. (_ZK_C2 > 50 .and. _ZK_C2 < 320) .and. !empty(_cProx)

	VTRead

	//VTSetKey(100,_KeyD)
	//VTSetKey(101,_KeyE)
	//VTSetKey(109,_Imp)

	_KeyD := VTSetKey(100,{|| Pesar("D") })
	_KeyE := VTSetKey(101,{|| Pesar("E") })
	_imp  := VTSetKey(109,{|| ImpEtq('I') })

	If (VTLastKey() == 27)
		VTAlert('Operação Cancelada!','Aviso de Encerramento(05)',.T.,2000,1)
		_ret := .f.
	else

		//quando confirmar o apontamento já imprime
		ImpEtq('I')

		reclock('SZ4',.f.)
		SZ4->Z4_QTREAL += 1
		msunlock()

		GravSZK()

		_ZK_C1  := 0
		_ZK_C2  := 0
	endif
	VTClearBuffer()
Return _ret

// Função para gravar na SZK a classificação
Static Function GravSZK()
	RecLock("SZK",.F.)
		SZK->ZK_CDIAN1  := _ZK_CDIAN1
		SZK->ZK_CDIAN2  := _ZK_CDIAN2
		SZK->ZK_CLASESP := _ZK_CLASESP
		SZK->ZK_CLESPAB := _ZK_CLASESP
		SZK->ZK_TUBERC  := _ZK_TUBERC
		SZK->ZK_MATURA  := _ZK_MATURA
		SZK->ZK_PECARC1 := iif(SZK->ZK_CATEG = '003',_ZK_C1 - (nTarat - nTara),_ZK_C1) //SE FOR TOURO DESCONTA 0,300 DO PESO DA ROLDANA ANTES ESTAVA_ZK_C1 Fabian Maurer 01/02/16
		SZK->ZK_PECARC2 := iif(SZK->ZK_CATEG = '003',_ZK_C2 - (nTarat - nTara),_ZK_C2) //SE FOR TOURO DESCONTA 0,300 DO PESO DA ROLDANA ANTES ESTAVA_ZK_C2 Fabian Maurer 01/02/16
		SZK->ZK_PETOTAL := iif(SZK->ZK_CATEG = '003',_ZK_PETOTAL - (2*(nTarat - nTara)),_ZK_PETOTAL) //SE FOR TOURO DESCONTA 0,600 DO PESO DA ROLDANA ANTES ESTAVA _ZK_PETOTAL Fabian Maurer 01/02/16
		SZK->ZK_DESTINO := _ZK_DESTINO
		SZK->ZK_CONTUSA := iif(_ZK_CONTUSA != 'S' .or. empty(_ZK_CONTUSA),'N','S')
		SZK->ZK_CNTMINA := iif(_ZK_CNTMINA != 'S' .or. empty(_ZK_CNTMINA),'N','S')
		SZK->ZK_REGICTS := _ZK_REGICTS
		SZK->ZK_CLASSIF := _ZK_CLASSIF
		SZK->ZK_CONTROL := strzero(val(_ZK_CONTROL),6)
		SZK->ZK_OK      := iif(_ZK_DESTINO == 'I', 'P', 'S')
		SZK->ZK_IF      := iif(_ZK_DESTINO $ 'I/T/S', 'S', SZK->ZK_IF)
		SZK->ZK_CLASABA := _ZK_CLASSIF // memoriza o original do abate
		SZK->ZK_CLASSPH := _ZK_CLASSIF
		SZK->ZK_HORA    := time()
		SZK->ZK_PROGRAM := _ZK_PROGRAM
		SZK->ZK_PROGPGP := _ZK_PROGPGP	// Programa para Progepec
		SZK->ZK_BLACK   := _ZK_BLACK

		/* UFSM - Projeto BRC - Tabelas da Rastreabilidade */
		// confirmar se a funcao abaixo retorna a data corrente
		/* Dia 17/11/21 - Retirado esta coleta de informações. Deixado a coleta para o sistema das planilhas.
		if  GetMV('SI_BRCSTAR')		
			CriaRastAbate(_ZK_CONTROL,dAbate)
		endif
		*/

	MsUnLock()
Return

//Função de processamento da carcaça - pendentes
Static Function PendCarc()

	lOk := .f.

	_ZK_NUMAM	  := SZK->ZK_NUMAM
	_ZK_OBS       := SZK->ZK_OBS
	_ZK_DESTINO   := SZK->ZK_DESTINO
	_ZK_CLASSIF   := SZK->ZK_CLASSIF
	_ZK_COBGOR    := SZK->ZK_COBGOR
	_ZK_DENT      := SZK->ZK_DENT
	_ZK_CATEG     := SZK->ZK_CATEG
	_ZK_CONFORM   := SZK->ZK_CONFORM
	_ZK_RASTRO    := SZK->ZK_RASTRO
	_ZK_TIPIFI    := SZK->ZK_TIPIFI
	_ZK_PROGRAM   := SZK->ZK_PROGRAM
	_ZK_PROGPGP   := SZK->ZK_PROGRAM	// Programa para Progepec
	_ZK_HORA      := SZK->ZK_HORA
	_ZK_CONTROL   := SZK->ZK_CONTROL
	_ZK_TUBERC    := SZK->ZK_TUBERC
	_ZK_MATURA    := SZK->ZK_MATURA
	_ZK_PETOTAL   := SZK->ZK_PETOTAL
	_ZK_RACA	  := SZK->ZK_RACA
	_ZK_CONTUSA   := SZK->ZK_CONTUSA
	_ZK_CNTMINA   := SZK->ZK_CNTMINA
	_ZK_REGICTS   := SZK->ZK_REGICTS
	_ZK_SEXO      := SZK->ZK_SEXO
	_ZK_CDIAN1    := SZK->ZK_CDIAN1
	_ZK_CDIAN2    := SZK->ZK_CDIAN2
	_ZK_CLASESP   := SZK->ZK_CLASESP
	_ZK_CLESPAB   := SZK->ZK_CLASESP
	_ZK_C1        := SZK->ZK_PECARC1
	_ZK_C2        := SZK->ZK_PECARC2
	_ZK_PETOTAL   := SZK->ZK_PETOTAL
	_ZK_CONTROL   := SZK->ZK_CONTROL
	_ZK_HORA      := SZK->ZK_HORA
	_ZK_TUBERC    := SZK->ZK_TUBERC
	_ZK_C1        := SZK->ZK_PECARC1
	_ZK_C2        := SZK->ZK_PECARC2
	_ZK_BLACK     := SZK->ZK_BLACK
	_ZK_BRINCO    := SZK->ZK_BRINCO
	_ZK_SINC      := SZK->ZK_SINC

	VTClear()
	VTClearBuffer()

	@ 02,00 VTSay "LOTE:       " + SZ4->Z4_LOTE
	@ 03,00 VTSay "SEQUENCIAL: " + strzero(val(_ZK_CONTROL),6)
	@ 04,00 VTSay "ORDEM LOTE: " + str(SZK->ZK_ORDEM,3,0)

	@ 06,00 VTSay "GORDURA:    ["+SZK->ZK_COBGOR+"]"
	@ 07,00 VTSay "DENTICAO:   ["+SZK->ZK_DENT+"]"
	@ 08,00 VTSay "CONFORMAÇAO:["+SZK->ZK_CONFORM+"]"
	@ 09,00 VTSay "RACA:       ["+SZK->ZK_RACA+"]"
	@ 10,00 VTSay "PROGRAMA:   ["+SZK->ZK_PROGRAM+"]"
	@ 11,00 VTSay "DESTINO:    [ ] C|T|I|R|G|S"
	@ 12,00 VTSay "COND.DIAN1: ["+SZK->ZK_CDIAN1+" ]"
	@ 13,00 VTSay "COND.DIAN2: ["+SZK->ZK_CDIAN1+" ]"
	@ 14,00 VTSay "CLAS.ESP.:  ["+SZK->ZK_CLASESP+" ]"
	@ 15,00 VTSay "(D)ir.["+transform(_ZK_C1,'@E 999.99')+"] (E)sq.["+transform(_ZK_C2,'@E 999.99')+"]"

	@ 17,00 VTSay "ESC Sair"

	@ 11,13 VTGet _ZK_DESTINO Pict "@!" VALID (_ZK_DESTINO $ 'CTRGS')

	VTRead

	If (VTLastKey() == 27)
		VTAlert('Operação Cancelada!','Aviso de Encerramento(05)',.T.,2000,1)
		return .t.
	else
		RecLock("SZK",.F.)
		SZK->ZK_DESTINO := _ZK_DESTINO
		SZK->ZK_CLASSIF := iif(_ZK_DESTINO $ 'R/G','NE',_ZK_CLASSIF)
		SZK->ZK_CLASABA := iif(_ZK_DESTINO $ 'R/G','NE',_ZK_CLASSIF)
		SZK->ZK_CLASSPH := iif(_ZK_DESTINO $ 'R/G','NE',_ZK_CLASSIF)
		SZK->ZK_OK      := 'S'
		SZK->ZK_BLACK   := iif(_ZK_DESTINO $ 'T/R/S', "N", _ZK_BLACK)
		MsUnLock()

		if _ZK_DESTINO $ 'T/R/S'
			ZAJ->(DbSetOrder(1))
			ZAJ->(MsSeek(FWxFilial('ZAJ') + SZK->ZK_NUMAM + SZK->ZK_CONTROL))
			while ZAJ->(!eof()) .and. SZK->ZK_NUMAM = ZAJ->ZAJ_NUMAM .and. SZK->ZK_CONTROL = ZAJ->ZAJ_CONTRO
				RecLock("ZAJ",.F.)
				ZAJ->ZAJ_BLACK := 'N'
				ZAJ->ZAJ_DESTIN := _ZK_DESTINO
				ZAJ->ZAJ_ORIGEM := 'MRVT07'
				MsUnLock()

				ZAJ->(dbSkip())
			end
		endif
	endif

Return .t.

//Função de processamento da carcaça - Visualizar
Static Function VisCarc()

	lOk   := .f.
	_cImp := 'S'

	_ZK_NUMAM	  := SZK->ZK_NUMAM
	_ZK_OBS       := SZK->ZK_OBS
	_ZK_DESTINO   := SZK->ZK_DESTINO
	_ZK_CLASSIF   := SZK->ZK_CLASSIF
	_ZK_COBGOR    := SZK->ZK_COBGOR
	_ZK_DENT      := SZK->ZK_DENT
	_ZK_CATEG     := SZK->ZK_CATEG
	_ZK_CONFORM   := SZK->ZK_CONFORM
	_ZK_RASTRO    := SZK->ZK_RASTRO
	_ZK_TIPIFI    := SZK->ZK_TIPIFI
	_ZK_PROGRAM   := SZK->ZK_PROGRAM
	_ZK_PROGPGP   := SZK->ZK_PROGRAM	// Programa para Progepec
	_ZK_HORA      := SZK->ZK_HORA
	_ZK_CONTROL   := SZK->ZK_CONTROL
	_ZK_TUBERC    := SZK->ZK_TUBERC
	_ZK_MATURA    := SZK->ZK_MATURA
	_ZK_PETOTAL   := SZK->ZK_PETOTAL
	_ZK_RACA	  := SZK->ZK_RACA
	_ZK_CONTUSA   := SZK->ZK_CONTUSA
	_ZK_CNTMINA   := SZK->ZK_CNTMINA
	_ZK_REGICTS   := SZK->ZK_REGICTS
	_ZK_SEXO      := SZK->ZK_SEXO
	_ZK_CDIAN1    := SZK->ZK_CDIAN1
	_ZK_CDIAN2    := SZK->ZK_CDIAN2
	_ZK_CLASESP   := SZK->ZK_CLASESP
	_ZK_CLESPAB   := SZK->ZK_CLASESP
	_ZK_C1        := SZK->ZK_PECARC1
	_ZK_C2        := SZK->ZK_PECARC2
	_ZK_PETOTAL   := SZK->ZK_PETOTAL
	_ZK_CONTROL   := SZK->ZK_CONTROL
	_ZK_HORA      := SZK->ZK_HORA
	_ZK_TUBERC    := SZK->ZK_TUBERC
	_ZK_BLACK     := SZK->ZK_BLACK
	_ZK_BRINCO    := SZK->ZK_BRINCO
	_ZK_SINC      := SZK->ZK_SINC

	VTClear()
	VTClearBuffer()

	@ 02,00 VTSay "LOTE:       " + SZ4->Z4_LOTE
	@ 03,00 VTSay "SEQUENCIAL: " + strzero(val(_ZK_CONTROL),6)
	@ 04,00 VTSay "ORDEM LOTE: " + str(SZK->ZK_ORDEM,3,0)

	@ 06,00 VTSay "GORDURA:    ["+SZK->ZK_COBGOR+"]"
	@ 07,00 VTSay "DENTICAO:   ["+SZK->ZK_DENT+"]"
	@ 08,00 VTSay "CONFORMAÇAO:["+SZK->ZK_CONFORM+"]"
	@ 09,00 VTSay "RACA:       ["+SZK->ZK_RACA+"]"
	@ 10,00 VTSay "PROGRAMA:   ["+SZK->ZK_PROGRAM+"]"
	@ 11,00 VTSay "DESTINO:    ["+SZK->ZK_DESTINO+"] C|T|I|R|G|S"
	@ 12,00 VTSay "COND.DIAN1: ["+SZK->ZK_CDIAN1+"]"
	@ 13,00 VTSay "COND.DIAN2: ["+SZK->ZK_CDIAN1+"]"
	@ 14,00 VTSay "CLAS.ESP.:  ["+SZK->ZK_CLASESP+"]"
	@ 15,00 VTSay "(D)ir.["+transform(_ZK_C1,'@E 999.99')+"] (E)sq.["+transform(_ZK_C2,'@E 999.99')+"]"
	@ 16,00 VTSay "Imprimir?(S)[ ]"
	@ 17,00 VTSay "ESC Sair"

	@ 16,13 VTGet _cImp  Pict "@!" VALID (_cImp = 'S')

	VTRead

	If (VTLastKey() == 27)
		VTAlert('Operação Cancelada!','Aviso de Encerramento(05)',.T.,2000,1)
		return .t.
	elseif RetCodUsr() = "000498"
		ImpEtq('I')
		GravSZK()
	else
		ImpEtq('R')
	endif
Return .t.

//Função para tratar o browse
User function MR7Pro(modo)
	if VTLastkey()==27
		VTAlert('Operação Cancelada!','Aviso de Encerramento(00)',.T.,2000,1)
		//VTBeep(3)
		_lOk   := .f.
		_lOk2  := .f.
		_lOk3  := .f.
		return 0
	elseif VTLastkey()==13
		return 1
	endif
return

//Função para tratar o browse
User function MR7Pr2(modo)
	if VTLastkey()==27
		VTAlert('Operação Cancelada!','Aviso de Encerramento(00)',.T.,2000,1)
		//VTBeep(3)
		_lOk2  := .f.
		_lOk3  := .f.
		return 0
	elseif VTLastkey()==13
		return 1
	endif
return

//Função para tratar o browse
User function MR7Pr3(modo)
	if VTLastkey()==27
		VTAlert('Operação Cancelada!','Aviso de Encerramento(00)',.T.,2000,1)
		//VTBeep(3)
		_lOk2  := .f.
		return 0
	elseif VTLastkey()==13
		return 1
	endif
return

//função de captura de peso
Static Function Captura(v)

	cBuffer := ""
	nQtd = oObj:Receive( cBuffer,1000)
	if( nQtd >= 0 )
		_cPeso := substr(cBuffer,7,4)
		nPeso  := val(_cPeso)/10
		v      := npeso - nTara
	endif

	_ZK_PETOTAL := _ZK_C1 + _ZK_C2

Return nPeso

//função separada para capturar peso com a balança nova
Static Function newCaptura(_cLado)

	local _nTam     := getMv('SI_QTSTR')//parametro com valor total de strings de peso a serem armazenadas para tratamento
	local _nStrOk   := 0
	local aStrings  := {}
	local aPesos    := {}
	local nPeso 	:= 0
	local _nMaior   := 0
	local _nCont    := 0
	local cPeso     := ""
	local cC        := ""
	local _cBuffer  := ""
	local _nPesosOk := 0
	Local i
	Local j

	//verifica qual tecla foi utilizada e zera as variaveis
	if _cLado = 'D'
		_ZK_C1 := 0
	else
		_ZK_C2 := 0
	endif

	//bloco que armazena as strings que tiverem o peso estável
	for i:=1 to _nTam
		_cBuffer := ""
		nQtd 	   := oObj:Receive( @_cBuffer, 1000 )
		if "3p" $ alltrim(_cBuffer) .or. "p`" $ alltrim(_cBuffer) //SE TIVER "3P" NA STRING QUER DIZER QUE É UM PESO ESTAVEL
			aAdd(aStrings,_cBuffer)
			_nStrOk++
		endif
	next

	//verifica se o buffer não esta sendo retornado em branco, caso esteja reconecta na balança
	if empty(_cBuffer)
		conectBal()
	endif
	//bloco para tratamento das strings com peso estável
	for i:= 1 to len(aStrings) //_nStrOk
		do Case
			Case at("p`",aStrings[i])> 0
			cPeso := substr(aStrings[i],at("p`",aStrings[i])+2,6)
			cC := "`"

			Case at("`",aStrings[i]) > 0
			cPeso := substr(aStrings[i],at("`",aStrings[i])+1,6)
			cC := "`"

			Case at("p ",aStrings[i])> 0
			cPeso := substr(aStrings[i],at("p ",aStrings[i])+2,6)
			cC := " "

			Otherwise
			cPeso :='000000'
			cC := ""
		Endcase

		cPeso := substr(aStrings[i],at("`",aStrings[i])+1,6)
		cPeso := substr(aStrings[i],at(cC,aStrings[i])+1,6)
		nPeso := val(cPeso)/(10)
		if nPeso > 0 //adiciona no vetor de pesos ok somente pesos acima de zero
			aAdd(aPesos,nPeso)
			_nPesosOk++
		endif
	next

	//bloco para tratamento de incidencias, ou seja, utiliza somente o peso que tiver mais incidencias dentro do vetor
	for i:= 1 to len(aPesos)//_nPesosOk
		_nCont := 0
		for j:=1 to len(aPesos)//_nPesosOk
			if aPesos[i] == aPesos[j]
				_nCont++
			endif
		next

		if _nCont > _nMaior
			nPeso   := aPesos[i] - nTara
			_nMaior := _nCont
		endif
	next

return nPeso

//Função auxiliar para captura de peso
Static Function Pesar(_v)

	if  _cPar02 == '1'//se for balança 1
		if _v = 'D'
			if lAviso
				_ZK_C1 := nPesPar
			else
				_ZK_C1 := newCaptura(_v)
			Endif
		else
			if lAviso
				_ZK_C2 := nPesPar
			else
				_ZK_C2 := newCaptura(_v)
			endif
		endif

		_ZK_PETOTAL := _ZK_C1 + _ZK_C2

	elseif _cPar02 == '2' //senão é balança 2 antiga

		if _v = 'D'
			//_ZK_C1 := capb2(_v)
			if lAviso
				_ZK_C1 := nPesPar
			else
				_ZK_C1 := newCaptura(_v)
			Endif
		else
			//_ZK_C2 := capb2(_v)
			if lAviso
				_ZK_C2 := nPesPar
			else
				_ZK_C2 := newCaptura(_v)
			endif
		endif

		_ZK_PETOTAL := _ZK_C1 + _ZK_C2

	endif

	@ 17,00 VTSay "(D)ir.["+transform(_ZK_C1,'@E 999.99')+"] (E)sq.["+transform(_ZK_C2,'@E 999.99')+"]"

	VTClearBuffer()

return

//Função que chama impressão e classificação
Static Function ImpEtq(cFunc)

	If cFunc == 'I'
		classifica()
		imprime()
	ElseIf cFunc == 'R'
		reimprime()
	EndIf

Return

//Função de classificação da carcaça
static function classifica()

	Local _cCateg := ""
	//Local _nIdade := 0
	//Local _cDent  := ""
	Local _cNum   := ""
	Local _cDiv   := 'N'

	_ZK_CLASSIF := SZ4->Z4_CLASSIF

	if _ZK_CLASSIF $ 'USA/RT' .and. _ZK_CLASESP = '2'
		_ZK_CLASSIF := 'HK'
	endif

	if _ZK_CLASSIF = 'RT' .and. empty(_ZK_BRINCO)
		_ZK_CLASSIF := 'HK'
	elseif _ZK_CLASSIF = 'RT' .and. !empty(_ZK_BRINCO)
		_cCateg := GetAdvFVal('ZRT','ZRT_CATEG',FWXFilial('ZRT')+SZ4->Z4_NUMAM+SZ4->Z4_LOTE,1)
		_cNum   := GetAdvFVal('ZRT','ZRT_NUM',FWXFilial('ZRT')+SZ4->Z4_NUMAM+SZ4->Z4_LOTE,1)
		//_nIdade := GetAdvFVal('ZRI','ZRI_IDADE',FWXFilial('ZRI')+_ZK_BRINCO+_cNum,2) // trocar para idade
		_cDiv   := GetAdvFVal('ZRI','ZRI_DIVGTA',FWXFilial('ZRI')+_ZK_BRINCO+_cNum,2) // trocar para idade

		/*Do Case
			Case _nIdade < 18.0
				_cDent := '0'
			Case _nIdade >= 18.0 .and. _nIdade <= 24.0
				_cDent := '2'
			Case _nIdade >= 25.0 .and. _nIdade <= 30.0
				_cDent := '4'
			Case _nIdade >= 31.0 .and. _nIdade <= 42.0
				_cDent := '6'
			Case _nIdade > 42.0
				_cDent := '8'
		EndCase*/

		if _ZK_CATEG != _cCateg
			_ZK_CLASSIF := 'HK'
		//elseif _ZK_DENT != _cDent
			//_ZK_CLASSIF := 'HK'
		endif

		if _cDiv = 'S' .or. alltrim(_ZK_SINC) = 'S'
			_ZK_CLASSIF := 'HK'
		endif
	endif

	if _ZK_CLASSIF = 'BR' .or. _ZK_DESTINO $ 'I/T/S'
		_ZK_CLASSIF := 'BR'
		_ZK_CLASESP := '2'
	endif

	if _ZK_CLASSIF = 'NE' .or. _ZK_DESTINO $ 'R/G'
		_ZK_CLASSIF := 'NE'
	endif

	classifPGP()

	//Classificação específica para programas
	if (_ZK_CATEG = '003' .and. _ZK_PROGRAM != '008') .or. _ZK_PROGRAM = '019'

		_ZK_PROGRAM := '019' //Definição com Adriana e PCP
		_ZK_CATEG := '003'

	elseif substr(_ZK_COBGOR,1,1) = '1' .and. _ZK_CATEG != '003'

		_ZK_PROGRAM := '001' //Definição com a PROGEPEC e Diretoria

	elseif ((_ZK_CATEG = "001" .and. _ZK_PETOTAL >= 210.0) .or. (_ZK_CATEG = "002" .and. _ZK_PETOTAL >= 180.0))

		if _ZK_DENT <= '4'
			if substr(_ZK_COBGOR,1,1) >= '2'
				if (_ZK_PROGRAM $ "002/022")
					_ZK_PROGRAM := "002"
				elseif (_ZK_PROGRAM $ "006/021")
					_ZK_PROGRAM := "006"
				elseif empty(_ZK_PROGRAM) .or. _ZK_PROGRAM = "008"
					_ZK_PROGRAM := "020"
				endif
			elseif substr(_ZK_COBGOR,1,1) = '2'
				if empty(_ZK_PROGRAM) .or. _ZK_PROGRAM = "008"
					_ZK_PROGRAM := "020"
				endif
			endif
		else
			if (_ZK_PROGRAM $ "008/020") .or. empty(_ZK_PROGRAM)
				_ZK_PROGRAM := "013"
			endif
		endif

	elseif ((_ZK_CATEG = "001" .and. _ZK_PETOTAL < 210.0) .or. (_ZK_CATEG = "002" .and. _ZK_PETOTAL < 180.0))

		if _ZK_DENT <= '4'
			if substr(_ZK_COBGOR,1,1) >= '2'
				if _ZK_PROGRAM = "022"
					_ZK_PROGRAM := "002"
				elseif _ZK_PROGRAM = "021"
					_ZK_PROGRAM := "006"
				elseif (_ZK_PROGRAM $ "008/020") .or. empty(_ZK_PROGRAM)
					_ZK_PROGRAM := "013"
				endif
			elseif substr(_ZK_COBGOR,1,1) = '2'
				if (_ZK_PROGRAM $ "008/020") .or. empty(_ZK_PROGRAM)
					_ZK_PROGRAM := "013"
				endif
			endif
		else
			if (_ZK_PROGRAM $ "008/020") .or. empty(_ZK_PROGRAM)
				_ZK_PROGRAM := "013"
			endif
		endif

	elseif empty(_ZK_PROGRAM) .or. _ZK_PROGRAM = "008"

		_ZK_PROGRAM := "013"

	endif

	if (alltrim(_ZK_DENT) $ '0|2|4') .and. (substr(_ZK_COBGOR,1,1) $ '3|4|5') .and. (alltrim(_ZK_PROGRAM) $ '002|022|021|006') .and. (_ZK_PETOTAL >= 240.0 .and. _ZK_PETOTAL <= 260.0) .and. !(_ZK_DESTINO $ "T/R/S")
		_ZK_BLACK   := 'S'
	else
		_ZK_BLACK   := 'N'
	endif
Return

//Função de validações de programa da Progepec
Static Function classifPGP()

	if (_ZK_CATEG = '003' .and. _ZK_PROGRAM != '008') .or. _ZK_PROGRAM = '019'

		_ZK_PROGPGP := '019'
		_ZK_CATEG := '003'

	elseif substr(_ZK_COBGOR,1,1) = '1' .and. _ZK_CATEG != '003'

		_ZK_PROGPGP := '001'

	elseif (_ZK_CATEG != "003" .and. _ZK_PETOTAL >= 180.0) .and. (empty(_ZK_PROGRAM) .or. _ZK_PROGRAM = '020') .and. _ZK_DENT <= '4' .and. substr(_ZK_COBGOR,1,1) >= '2'

		_ZK_PROGPGP := '020'

	elseif !empty(_ZK_PROGRAM)

		if _ZK_PROGRAM = '022'
			_ZK_PROGPGP := '002'
		elseif _ZK_PROGRAM = '021'
			_ZK_PROGPGP := '006'
		else
			_ZK_PROGPGP := _ZK_PROGRAM
		endif

	else

		_ZK_PROGPGP := '013'

	endif

Return

//Função que manda imprimir
Static Function imprime()

	dAbate := GetAdvFVal('SZG','ZG_DATA',FWxFilial('SZG')+SZ4->(Z4_NUMAM + Z4_LOTE),1)

	_nCont	:=	1

	// Se impressão costelas sim
	if _cPar01 = '1'
		_nImp := 6
	else
		_nImp := 4
	endif
	/* Função que cria o registro na ZAJ */
	u_gf182C(_nImp)

	area := getarea()

	if _cPar05 = '1'
		etqOld(_nImp)
	elseif _cPar05 = '2'
		etqNew(_nImp)
	endif

	restarea(area)

Return

Static function reimprime()
	dAbate := GetAdvFVal('SZG','ZG_DATA',FWxFilial('SZG')+SZ4->(Z4_NUMAM + Z4_LOTE),1)

	// Se impressão costelas sim
	if _cPar01 = '1'
		_nImp := 6
	else
		_nImp := 4
	endif
	area := getarea()

	if _cPar05 = '1'		
		etqOld(_nImp)		
	elseif _cPar05 = '2'
		etqNew(_nImp)
	endif

	restarea(area)

return

Static Function etqOld(_n) 

	_Font01 	:= "60,60"
	_Font02 	:= "70,70"
	_Font03 	:= "60,60"
	_nCont	:=	1
	_nPeso   := 0.00
	_cSPeso := 'N'
	_nPerTras  := GetMV('SI_%TRAS')
	_nPerDian  := GetMV('SI_%DIAN')
	_nPerCost  := GetMV('SI_%COST')

	//ZAJ->(DbSetOrder(1))
	ZAJ->(DbSetOrder(13))
	ZAJ->(DbGoTop())

	if ZAJ->(MsSeek(FWxfilial('ZAJ')+SZ4->Z4_NUMAM + _ZK_CONTROL))
		//************************Impressão das Etiquetas***************************
		//VTAlert(_cIpImp,'Enviando impressão...',.T.,500,1)
		while ZAJ->(!eof()) .and. ZAJ->ZAJ_FILIAL = cFilant .and. ZAJ->ZAJ_NUMAM = SZ4->Z4_NUMAM .and. ZAJ->ZAJ_CONTRO = _ZK_CONTROL

			if ZAJ->ZAJ_REGORI <> '0000000000'
				ZAJ->(DbSkip())
				loop
			endif

			MSCBPRINTER('S600','IP',,,,,_cIpImp)
			MSCBCHKSTATUS(.f.)
			MSCBBEGIN(1,6)

			MSCBBOX(01,16,60,33)

			//Lado
			MSCBSAY(50, 17,ZAJ->ZAJ_LADO,"N","0","100,100")

			//Codigo de Barras
			MSCBSAYBAR(13,01,ZAJ->ZAJ_NUM,"N","C",10,,.t.,,,3,3,.t.)
			MSCBSAYBAR(08,17,ZAJ->ZAJ_NUM,"N","C",10,,.t.,,,3,3,.t.)

			MSCBBOX(01,35,14,48)
			MSCBSAY(3, 36,'Gord',"N","E","8,8")
			if _ZK_COBGOR = "2+"
				MSCBSAY(3, 40,_ZK_COBGOR,"N","0",_Font01)
			else
				MSCBSAY(6, 40,_ZK_COBGOR,"N","0",_Font01)
			endif

			MSCBBOX(17, 35,31,48)
			MSCBSAY(20, 36,'Dent',"N","E","8,8")
			//MSCBSAY(23, 40, iif(M->ZK_CLASESP = '1','7',M->ZK_DENT),"N","0",_Font01)
			/*// Alteração efetuada para norma de exportação para o Egito
			if M->ZK_CLASESP = '1' .AND. M->ZK_DENT = '8'
			MSCBSAY(23, 40,'7',"N","0",_Font01)
			elseif M->ZK_CLASESP = '1' .AND. M->ZK_DENT != '8'
			MSCBSAY(23, 40,iif(M->ZK_DENT = '1','DL',M->ZK_DENT),"N","0",_Font01)
			elseif M->ZK_CLASESP = '2'
			MSCBSAY(23, 40,'8',"N","0",_Font01)
			endif
			//MSCBSAY(23, 40, '7',"N","0",_Font01)
			// se clasespm = 1  (exporta para o egito e aparece na etiqueta 7 dentes)
			// se clasespm = 2  (não exporta e aparece 8 dentes na etiqueta)*/

			MSCBSAY(23, 40,_ZK_DENT,"N","0",_Font01)

			/*
			MSCBBOX(34, 35,46,48)
			MSCBSAY(35, 36,'Conf',"N","E","8,8")
			MSCBSAY(40, 40,_ZK_CONFORM,"N","0",_Font01)

			MSCBBOX(48, 35,60,48)
			MSCBSAY(50, 36,'Tip',"N","E","8,8")
			MSCBSAY(50, 40,_ZK_TIPIFI,"N","0",_Font01)
			*/

			MSCBBOX(34, 35,60,48)
			_nPesoI := iif(ZAJ->ZAJ_CORORI = 'T',_nPerTras * iif(ZAJ->ZAJ_LADO = 'E',_ZK_C1,_ZK_C2),;
			iif(ZAJ->ZAJ_CORORI = 'D',_nPerDian * iif(ZAJ->ZAJ_LADO = 'E',_ZK_C1,_ZK_C2),;
			_nPerCost * iif(ZAJ->ZAJ_LADO = 'E',_ZK_C1,_ZK_C2)))

			_nPeso := _nPesoI - (_nPesoI * 0.02)  // -2% de frio

			MSCBSAY(35, 36,'Peso',"N","E","8,8")
			MSCBSAY(40, 40,transform(_nPeso,'@E 999.99'),"N","0",_Font01)

			MSCBBOX(02,50,60,70)
			MSCBLINEV(39,50,70)
			MSCBLINEH(39,60,60)

			MSCBSAY(03, 52,'SEQ.',"N","E","8,8")
			MSCBSAY(13, 52,_ZK_CONTROL,"N","0",_Font02)

			_cDescri := ZAJ->ZAJ_DESCRI
			MSCBSAY(03, 62,_cDescri,"N","0",_Font01)

			MSCBSAY(40, 52,'Abate',"N","E","8,8")
			MSCBSAY(40, 55,SZ4->Z4_NUMAM,"N","E","8,8")

			MSCBSAY(41, 62,'Lote',"N","E","8,8")
			MSCBSAY(41, 66,SZ4->Z4_LOTE,"N","E","8,8")

			MSCBBOX(02,72,60,77)
			MSCBSAY(02,73, GetMv("MV_NUMIF") + strtran(dtoc(dAbate),'/','') +'0000',"N","E","8,8")

			MSCBBOX(02,79,30,89)
			MSCBSAY(03,80,'SIF',"N","E","8,8")
			MSCBSAY(07,84,GetMv("MV_NUMIF"), "N","E","28,15")

			MSCBBOX(32,79,60,89)
			MSCBSAY(33,80,'Data Abate',"N","E","8,8")
			MSCBSAY(37,84,dtoc(dAbate),"N","E","28,15")

			nL := 125

			//Private _cRaca := GetAdvFVal('ZA8', 'ZA8_DESC', FWxFilial('ZA8')+alltrim(_ZK_RACA), 1)

			MSCBBOX(02,93,60,98)
			If _ZK_OBS == '0'  //ok
				MSCBSAY(03,94, 'SISBOV:'+ _ZK_RASTRO ,"N","E","8,8")
			Endif
			_cCateg := GetAdvFVal('SZ5','Z5_DESC',FWxfilial('SZ5')+ _ZK_CATEG,1)

			if _ZK_BLACK = 'S' //if _ZK_PROGRAM == '014'	//programa black
				progBlack := GetAdvFVal('SZ6', 'Z6_DESC', FWxFilial('SZ6')+iif(_ZK_PROGRAM = '022', '002', iif(_ZK_PROGRAM = '021', '006', _ZK_PROGRAM)), 1)
				MSCBBOX(02,100,60,109)
				MSCBSAY(03,101,_cCateg,"N","0",_Font01)
				MSCBBOX(02,110,60,120)
				MSCBSAY(04,111,'BL-'+substr(progBlack,1,8),"N","0",_Font01)
				MSCBBOX(02,124,60,144)// quadrado
				if _ZK_CLASSIF = "USA"
					MSCBSAY(01,125,_ZK_CLASSIF,"N","0","180,300")
				else
					MSCBSAY(10,125,_ZK_CLASSIF,"N","0","180,300")
				endif
			else
				nomeProg := GetAdvFVal('SZ6', 'Z6_DESC', FWxFilial('SZ6')+_ZK_PROGRAM, 1)
				MSCBBOX(02,100,60,109)
				MSCBSAY(03,101,_cCateg,"N","0",_Font01)
				MSCBBOX(02,124,60,144)// quadrado
				if _ZK_CLASSIF = "USA"
					MSCBSAY(01,125,_ZK_CLASSIF,"N","0","180,300")
				else
					MSCBSAY(10,125,_ZK_CLASSIF,"N","0","180,300")
				endif
				MSCBBOX(02,110,60,120)
				If !Empty(_ZK_PROGRAM)
					MSCBSAY(07,111,substr(nomeProg,1,11), "N","0",_Font01)// aqui esta sendo modificado
				endif
			endif
			//Aqui imprime a Classificação Especial
			//if _ZK_CLASESP = '1' .and. (AllTrim(_ZK_CLASSIF) != 'NE' .or. AllTrim(_ZK_CLASSIF) != 'USA') .and. _ZK_DENT > '4'
			/*if _ZK_CLASESP = '2' .and. !(AllTrim(_ZK_CLASSIF) $ 'NE/BR') .and. _ZK_DENT > '4'
				MSCBBOX(16,145,45,120)
				MSCBSAY(17,147,'HK',"N","0","200,200")
			elseif _ZK_CLASESP = '1' .and. AllTrim(_ZK_CLASSIF) = 'USA'
				MSCBBOX(16,145,45,120)
				MSCBSAY(17,147,'USA',"N","0","200,200")
			elseif _ZK_CLASESP = '2' .and. AllTrim(_ZK_CLASSIF) = 'BR'
				MSCBBOX(16,145,45,120)
				MSCBSAY(17,147,'BR',"N","0","200,200")
			elseif _ZK_CLASESP = '1' .and. !(AllTrim(_ZK_CLASSIF) $ 'NE/BR') .and. _ZK_DENT <= '4' 
				MSCBBOX(16,145,45,120)
				MSCBSAY(17,148,'CN',"N","0","200,200")
			endif*/

			MSCBBOX(16,145,45,128)
			MSCBSAY(17,147,_ZK_CLASSIF,"N","0","150,150")

			if !empty(_ZK_BRINCO)
				MSCBSAY(03,163,"Brinco","N","E","8,8")
				MSCBSAY(03,167,_ZK_BRINCO,"N","0",_Font01)
			endif

			//MSCBSAYBAR(20,172,ZAJ->ZAJ_NUM,"N","C",10,,.t.,,,3,3,.t.)

			_cProd := GetAdvFVal('SZ4','Z4_VPROD',FWxfilial('SZ4')+ZAJ->(ZAJ_NUMAM+ZAJ_LOTE),1)
			_nQtd := GetAdvFVal('SZ4','Z4_IPROD',FWxfilial('SZ4')+ZAJ->(ZAJ_NUMAM+ZAJ_LOTE),1)
			_nQtd2 := GetAdvFVal('SZ4','Z4_IPROD2',FWxfilial('SZ4')+ZAJ->(ZAJ_NUMAM+ZAJ_LOTE),1)

			/* Dia 17/09/21 - Pedido Matheus Silva
				Gerar regra de quantidade 
				Marcar a quantidade de animais 	 p/imprimir na etiqueta
			*/
			if alltrim(_cProd) = 'S'  .AND.  _nQtd > 0 .and. _nQtd2 < (_nQtd * 6)
				SZ4->(DbSetOrder(1))
				SZ4->(DbGoTop())
				//_cNome := GetAdvFVal('SZ4','Z4_NOME',FWxfilial('SZ4')+ZAJ->(ZAJ_NUMAM+ZAJ_LOTE),1)
				_nQtd2 := _nQtd2 + 1
				//  gravar no campo  - Z4_IPROD2 
				if SZ4->(MsSeek(FWxFilial('SZ4') + ZAJ->(ZAJ_NUMAM+ZAJ_LOTE)))
					_nTotal := _ZK_C1 + _ZK_C2
					if  ( _nTotal >= SZ4->Z4_PECARC1 .AND. _nTotal <= SZ4->Z4_PECARC2) 
						if substr(_ZK_COBGOR,1,1) >= SZ4->Z4_COBGOR .AND. substr(_ZK_COBGOR,1,1) <= SZ4->Z4_COBGOR2
							if _ZK_DENT >= SZ4->Z4_DENT .AND. _ZK_DENT <= SZ4->Z4_DENT2
								if _ZK_RACA >= SZ4->Z4_RACA .AND. _ZK_RACA <= SZ4->Z4_RACA2
									reclock('SZ4',.f.)      
										SZ4->Z4_IPROD2 :=  _nQtd2							
									msunlock()  
									MSCBSAY(02,170,'CLIENTE :',"N","0","32,30")								
									MSCBSAY(05,175,substr(SZ4->Z4_NOMECLI,1,29),"N","0",_Font03)
									MSCBSAY(05,181,substr(SZ4->Z4_NOMECLI,30,25),"N","0",_Font03)
									MSCBSAYBAR(20,190,ZAJ->ZAJ_NUM,"N","C",10,,.t.,,,3,3,.t.)
									_nQtd2 := 0
									_nCont := 1
									_cSPeso := 'S'
								Endif
							Endif
						Endif
					Endif
				Endif
			Else

				MSCBSAYBAR(05,184,ZAJ->ZAJ_NUM,"R","C",10,,.t.,,,3,3,.t.)
				MSCBSAYBAR(20,175,ZAJ->ZAJ_NUM,"N","C",10,,.t.,,,3,3,.t.)
				MSCBSAYBAR(20,191,ZAJ->ZAJ_NUM,"N","C",10,,.t.,,,3,3,.t.)

			Endif

			MSCBSAYBAR(20,212,ZAJ->ZAJ_NUM,"N","C",10,,.t.,,,3,3,.t.)
			if _nCont = 0

				MSCBSAYBAR(05,184,ZAJ->ZAJ_NUM,"R","C",10,,.t.,,,3,3,.t.)
				MSCBSAYBAR(20,175,ZAJ->ZAJ_NUM,"N","C",10,,.t.,,,3,3,.t.)
				MSCBSAYBAR(20,191,ZAJ->ZAJ_NUM,"N","C",10,,.t.,,,3,3,.t.)

			Endif

			/* Dia 25/09/21 Solicitado por Matheus Silva
				- Se for o nome do cliente na etiqueta não pode ir o peso
			*/
			if _cSPeso = "N"
				
				MSCBBOX(34, 35,60,48)
				_nPesoI := iif(ZAJ->ZAJ_CORORI = 'T',_nPerTras * iif(ZAJ->ZAJ_LADO = 'E',_ZK_C1,_ZK_C2),;
				iif(ZAJ->ZAJ_CORORI = 'D',_nPerDian * iif(ZAJ->ZAJ_LADO = 'E',_ZK_C1,_ZK_C2),;
				_nPerCost * iif(ZAJ->ZAJ_LADO = 'E',_ZK_C1,_ZK_C2)))

				_nPeso := _nPesoI - (_nPesoI * 0.02)  // -2% de frio

				MSCBSAY(35, 36,'Peso',"N","E","8,8")
				MSCBSAY(40, 40,transform(_nPeso,'@E 999.99'),"N","0",_Font01)
			else
				MSCBBOX(34, 35,60,48)
			Endif

			//****************************  FIM  *****************************************
			//MSCBSAY(13,285,"DTI","N","0","100,190")

			MSCBEND()
			MSCBCLOSEPRINTER()

			ZAJ->(DbSkip())

			sleep(250)
		enddo
		//VTAlert('Fim de processo!','Impressão  enviada',.T.,1000,1)
		sleep(1000)
	endif

return

// Layout novo para etiqueta do abate conforme pedido em reunião dia 13/12/2016
Static Function etqNew(_n)

	_Font00 		:= "35,35"
	_Font01 		:= "60,60"
	_Font02 		:= "55,55"
	_Font02_2 		:= "65,65"
	_Font03 		:= "80,80"
	_Font04     	:= "30,30"
	_Font05			:= "06,06"
	_Font06 	   	:= "55,55"
	_Font07			:= "29,29"
	_Font08			:= "26,26"
	_Font09			:= "45,45"
	_Font10			:= "28,28"
	_Font11 		:= "148,125"

	_nCont	:=	1
	_nPeso   := 0.00
	dValid   := dAbate + 15
	_nPerTras  := GetMV('SI_%TRAS')
	_nPerDian  := GetMV('SI_%DIAN')
	_nPerCost  := GetMV('SI_%COST')

	//ZAJ->(DbSetOrder(1))
	ZAJ->(DbSetOrder(13))
	ZAJ->(DbGoTop())

	if ZAJ->(MsSeek(FWxfilial('ZAJ')+SZ4->Z4_NUMAM + _ZK_CONTROL))

		//************************Impressão das Etiquetas***************************

		while ZAJ->(!eof()) .and. ZAJ->ZAJ_FILIAL = cFilant .and. ZAJ->ZAJ_NUMAM = SZ4->Z4_NUMAM .and. ZAJ->ZAJ_CONTRO = _ZK_CONTROL

			if ZAJ->ZAJ_REGORI <> '0000000000'
				ZAJ->(DbSkip())
				loop
			endif

			MSCBPRINTER('S600','IP',,,,,_cIpImp)

			MSCBCHKSTATUS(.f.)
			MSCBBEGIN(1,6)

			//--------------------------------------------------------------------------

			MSCBSAY(9, 244,_ZK_COBGOR,"B","0",_Font06)
			MSCBSAY(9, 221,iif(_ZK_DENT = '0','DL',_ZK_DENT),"B","0",_Font06)
			MSCBSAY(9, 203,_ZK_CONFORM,"B","0",_Font06)
			_cSexo := GetAdvFVal('SZ5','Z5_SEXO',FWxfilial('SZ5')+ _ZK_CATEG,1)
			if _cSexo = 'M'
				MSCBSAY(10,183,'MACHO',"B","0",_Font04)
			elseif _cSexo = 'F'
				MSCBSAY(10,183,'FEMEA',"B","0",_Font04)
			else
				MSCBSAY(10,183,'----',"B","0",_Font04)
			endif

			_nPesoI := iif(ZAJ->ZAJ_CORORI = 'T',_nPerTras * iif(ZAJ->ZAJ_LADO = 'E',_ZK_C1,_ZK_C2),;
			iif(ZAJ->ZAJ_CORORI = 'D',_nPerDian * iif(ZAJ->ZAJ_LADO = 'E',_ZK_C1,_ZK_C2),;
			_nPerCost * iif(ZAJ->ZAJ_LADO = 'E',_ZK_C1,_ZK_C2)))

			_nPeso := _nPesoI - (_nPesoI * 0.02)  // -2% de frio

			MSCBSAY(22,236,SZ4->Z4_NUMAM,"B","0",_Font00)
			MSCBSAY(22, 216,SZ4->Z4_LOTE,"B","0",_Font00)

			If _ZK_OBS == '0'  //ok
				MSCBSAY(22,181,_ZK_RASTRO ,"B","0","30,30")
			Endif

			_cCateg := GetAdvFVal('SZ5','Z5_COD',FWxfilial('SZ5')+ _ZK_CATEG,1)

			Private _cPrograma   := _ZK_PROGRAM
			Private nomePrograma := GetAdvFVal('SZ6', 'Z6_DESC', FWxFilial('SZ6')+_cPrograma, 1)

			if _ZK_PROGRAM = '006'
				if  (alltrim(_ZK_DENT) $ "0|2|4") .AND.  (_ZK_PETOTAL >= 230)
					MSCBSAY(30,236,'BLACK',"B","0",_Font02)
				Else
					MSCBSAY(30,232,'ANGUS',"B","0",_Font02)
				Endif
			elseif _cCateg $ '004/005'
				MSCBSAY(30,231,'BUFALO',"B","0",_Font02)
			else
				If !Empty(nomePrograma) .and. nomePrograma != '001'
					// Ajuste solicitado pelo Sr Matheus Silva para Impressão de etiquetas com Black - Dia 03/11/2016  - Flávio
					//If _ZK_PROGRAM = '002'                  .AND. (alltrim(_ZK_DENT) $ "0|2|4") .AND.  (_ZK_PETOTAL >= 230)
					If (alltrim(_ZK_PROGRAM) $ '002|006|021') .AND. (alltrim(_ZK_DENT) $ "0|2|4") .AND.  (_ZK_PETOTAL >= 230)
						MSCBSAY(30,236,'BLACK',"B","0",_Font02)
					Else
						iif( _ZK_PROGRAM = '002',MSCBSAY(30,227,substr(nomePrograma,6,12), "B","0",_Font02),iif(_ZK_PROGRAM = '011' ,MSCBSAY(30,227,substr(nomePrograma,6,12),"B","0",_Font02),MSCBSAY(30,227,alltrim(nomePrograma),"B","0",_Font02)))
					Endif
				endif
			endif

			MSCBSAY(33,211,_ZK_CONTROL,"B","0",_Font00)
			MSCBSAY(30,190,_ZK_CLASSIF,"B","0",_Font02)
			// 1º Cod de barras
			MSCBSAYBAR(40,231,ZAJ->ZAJ_NUM,"B","C",10,,.t.,,,2,2,.t.)
			MSCBSAY(42,214,ZAJ->ZAJ_LADO,"B","0",_Font02_2)

			//Aqui imprime a Classificação Especial
			if _ZK_CLASESP = '1' .and. (AllTrim(_ZK_CLASSIF) != 'NE' .or. AllTrim(_ZK_CLASSIF) != 'USA') .and. _ZK_DENT > '4'
				MSCBBOX(16,145,45,120)
				MSCBSAY(17,147,'HK',"N","0","200,200")
			elseif _ZK_CLASESP = '1' .and. AllTrim(_ZK_CLASSIF) = 'USA'
				MSCBBOX(16,145,45,120)
				MSCBSAY(17,147,'USA',"N","0","200,200")
			elseif _ZK_CLASESP = '1' .and. AllTrim(_ZK_CLASSIF) != 'NE' .and. _ZK_DENT <= '4' 
				MSCBBOX(16,145,45,120)
				MSCBSAY(17,148,'CN',"N","0","200,200")
			endif

			MSCBSAY(55,211, 'COD.RAST :' + GetMv("MV_NUMIF") + strtran(dtoc(dAbate),'/','') +'0000',"B","0",_Font00)
			//sai peso aprox
			MSCBSAYBAR(8,75,ZAJ->ZAJ_NUM,"N","C",10,,.t.,,,2,2,.t.)

			if  _cCateg $ '004/005'
				MSCBSAY(5, 10,'Carne Resfriada de Bubalino C/Osso',"B","0",_Font00)
				//MSCBSAY(52,111,'0118',"B","0",_Font10)
				MSCBSAY(52,111,'0118/1733',"B","0",_Font10)
			else
				MSCBSAY(5, 11,'Carne Resfriada de Bovino C/Osso',"B","0",_Font00)
				//MSCBSAY(52,111,'0077',"B","0",_Font10)
				MSCBSAY(52,111,'0077/1733',"B","0",_Font10)
			endif

			_cDescri := ZAJ->ZAJ_DESCRI
			MSCBSAY(14, 36,_cDescri,"B","0",_Font01)

			If ZAJ->ZAJ_COD = '005016'
				MSCBSAY(22,40,'TRAS.SERROTE',"B","0",_Font07)
				MSCBSAY(29,42,'TRAS.CAPOTE',"B","0",_Font07)
				MSCBSAY(36,45,'COXA BOLA',"B","0",_Font07)
				MSCBSAY(22,06,'COXA C/ ALCAT.',"B","0",_Font07)
			elseif  ZAJ->ZAJ_COD = '005018'
				MSCBSAY(22,50,'CAPOTE',"B","0",_Font07)
				MSCBSAY(29,39,'COSTELA S/VAZIO',"B","0",_Font08)
				MSCBSAY(36,40,'LOMBO C/COSTELA',"B","0",_Font10)
			elseif ZAJ->ZAJ_COD = '005020'
				MSCBSAY(22,49,'PALETA',"B","0",_Font07)
				MSCBSAY(29,49,'AGULHA',"B","0",_Font07)
				MSCBSAY(36,39,'DIANT.S/ PEITO',"B","0",_Font07)
			endif

			MSCBSAY(36, 19,'Peso Aprox.:',"B","0",_Font07)
			MSCBSAY(36, 5,transform(_nPeso,'@E 999.99'),"B","0",_Font09)
			//Codigo de Barras  descrito
			MSCBSAY(57,27,'Cod. Barras: ' + ZAJ->ZAJ_NUM,"B","0",_Font00)
			MSCBSAY(47,47,dtoc(dAbate),"B","0",_Font00)
			MSCBSAY(47,15,dtoc(dValid),"B","0",_Font00)

			nL := 125

			//****************************  FIM  *****************************************

			MSCBEND()
			MSCBCLOSEPRINTER()

			ZAJ->(DbSkip())

			sleep(250)
		enddo

		sleep(1000)

	endif

return

//função que verifica se existem carcaças pendentes no lote
Static Function VerPend(_Numam,_Lote)
	Local _ret:= .f.
	area := getarea()
	SZK->(DbSetOrder(2))
	SZK->(DbGoTop())
	SZK->(MsSeek(FWxfilial('SZK')+_Numam+_Lote))
	While SZK->(!eof()) .and. SZK->ZK_FILIAL = FWxfilial('SZK') .and. SZK->ZK_NUMAM = _Numam .and. SZK->ZK_LOTE = _Lote
		if SZK->ZK_OK = 'P'
			_ret := .t.
			exit
		endif
		SZK->(DbSkip())
	enddo
	restarea(area)
return  _ret

Static Function verAviso(_Numam,_Lote)

	Local _lEncer := .t.
	DbSelectArea('SZ4')
	SZ4->(DbSetOrder(1))
	SZ4->(DbGoTop())

	if SZ4->(MsSeek(FWxFilial('SZ4') + _Numam))
		while SZ4->(!eof()) .and. SZ4->Z4_NUMAM = _Numam
			if SZ4->Z4_QTREAL < SZ4->Z4_QUANT
				_lEncer := .f.
			endif
			SZ4->(DbSkip())
		enddo
	endif

	if _lEncer
		DbSelectArea('SZG')
		SZG->(DbSetOrder(1))
		SZG->(DbGoTop())
		if SZG->(MsSeek(FWxFilial('SZG') + _Numam))
			reclock('SZG',.f.)
			SZG->ZG_STATUS := 'E'
			msunlock()

			VTAlert('Aguarde o Processamento dos registros... ','Aviso',.T.,1500,1)

			u_GJF233(SZG->ZG_NUMAM)

			VTAlert('Processamento finalizado com sucesso!','Aviso',.T.,1000,1)
		endif
	endif

return _lEncer

//função para conectar na balança
Static Function conectBal()

	//Define o IP da balança a se utilizada
	_cIpBal := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM') + iif(_cPar02 = '1','BABT1','BABT2'),1))

	if empty(_cIpBal)
		vtalert('Endereço IP da balança não encontrado!')
		return
	endif

	//Se a balança já estiver conectada, disconecta.....
	if _lBal
		oObj:CloseConnection()
	endif

	oObj  := tSocketClient():New()
	nResp := oObj:Connect( 9092, _cIpBal,1000)  //9092
	nResp := oObj:Send( 'Teste' )

	_lBal := .t.

return

User Function ziprod2()
	SZ4->(DbSetOrder(1))
	SZ4->(DbGoTop())
	if SZ4->(MsSeek(FWxFilial('SZ4') + M->(Z4_NUMAM+Z4_LOTE)))					
		reclock('SZ4',.f.)      
			SZ4->Z4_IPROD2 :=  0
		msunlock()  
	Endif 
RETURN .T.

Static function capb2(_cLado)

	local _nTam     := getMv('SI_QTSTR')//parametro com valor total de strings de peso a serem armazenadas para tratamento
	Local i
	local _cBuffer  := ""
	local aStrings  := {}
	local _nStrOk   := 0
	Local _nCont 	:= 0
	Local _nDados 	:= 0 
	Local _nSomaPeso := 0 
	Local nPeso 	:= 0
	Local nPesof 	:= 0
	//verifica qual tecla foi utilizada e zera as variaveis
	if _cLado = 'D'
		_ZK_C1 := 0
	else
		_ZK_C2 := 0
	endif

	//bloco que armazena as strings que tiverem o peso estável
	
	for i:=1 to _nTam
		_cBuffer := ""
		nQtd 	   := oObj:Receive( _cBuffer, 1000 )
		if 'E' $ alltrim(_cBuffer)
			aAdd(aStrings,_cBuffer)
			_nStrOk++
		endif
	next
	//bloco para tratamento das strings com peso estável
	for i:= 1 to len(aStrings) 
		do Case						
			Case 'E' $  alltrim(aStrings[i])
				_D1 := strtran(substr(alltrim(aStrings[i]),1,5),',','.')	
				_nDados := val(_D1)
				_nSomaPeso += _nDados				
				_nCont++
			Otherwise
			cPeso :='000000'			
		Endcase
	next

	if _nCont > 0
		_nPesoMedio := _nSomaPeso / _nCont
		if _nPesoMedio > 50
			nPeso := _nPesoMedio
			_nPesoMedio := 0
			_nSomaPeso := 0
			_nCont := 0
		endif
	endif
	nPesof := nPeso - nTara

return nPesof


Static Function getJson(ZAJ_CONT,ZAJDATA)
	local jJson
	jJson := JsonObject():New()

	jJson["USUARIO"] := "usuario@protheus"	                     
	jJson["SENHA"] := "admin"
	jJson["ZAJ_CONTRO"] := ZAJ_CONT
	jJson["ZAJ_DATA"] := ZAJDATA

return jJson:ToJson()

Static function CriaRastAbate(ZAJ_CONT,ZAJDATA)

	Local aHeader as array
	Local cResource as char
	Local cServer as char
	Local cPort as char
	Local cURI as char
	Local oRestClient as object
	// chamar mct3
	// C:\TOTVS12\Protheus12_Teste\bin\appserver-mct3\appserver.exe -console
	// telnet 10.0.20.7 1099
	aHeader := {} 
	cResource := "/protheus/abate" 
	//cServer := "10.0.20.7" // URL (IP) DO SERVIDOR
	cServer := "10.0.20.9"
	cPort := "80" // PORTA DO SERVIÇO REST
	cURI := "http://" + cServer + "/api" // URI DO SERVIÇO REST
	oRestClient := FwRest():New(cURI)
	
	AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
	AAdd(aHeader, "Accept: application/json")
	AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")
	

	oRestClient:setPath(cResource)
	oRestClient:SetPostParams(getJson(ZAJ_CONT,ZAJDATA))
	
	oRestClient:Post(aHeader)
	FreeObj(oRestClient)
	
return

Static function showResult(cValue)
	if IsBlind()
		//Conout(cValue)
	else
		MsgInfo(cValue)
	endif
return
