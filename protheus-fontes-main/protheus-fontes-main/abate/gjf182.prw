#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF182     º Autor ³ Giuliano Forgiarini Data ³  08/08/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função para inclusão de registros individuais de penduradosº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PCP, Abate, Desossa, Expedições, Comercial                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


///Gera registros na tabela ZAJ
User Function GJF182(_n)

	Local _cCodT := '005016'
	Local _cCodD := '005020'
	Local _cCodC := '005018'
	Local i

	/*
	//Codigos para Programa Hereford
	if M->ZK_PROGRAM = '002'
	_cCodT := '006273'  //Traseiro
	_cCodD := '007892'  //Dianteiro
	_cCodC := '006463'  //Costela

	//Codigos para Programa Angus
	elseif M->ZK_PROGRAM = '006'
	_cCodT := '006272'  //Traseiro
	_cCodD := '007891'  //Dianteiro
	_cCodC := '006464'  //Costela
	endif
	*/ 

	ProcRegua(_n)

	for i := 1 to _n

		IncProc()

		if mv_par06 = 1  // dianteiro , traseiro e costela

			_cLado := iif (i = 1  .or. i = 3 .or. i = 5,'00','01')

			if i <= 2
				_cCodBar := GJF182p(M->ZK_NUMAM,M->ZK_LOTE,M->ZK_CONTROL,'D',iif(_cLado = '00','D','E'),_cCodD,iif(_cLado = '00',M->ZK_CDIAN2,M->ZK_CDIAN1),M->ZK_PROGRAM,M->ZK_PECARC1,M->ZK_PECARC2,M->ZK_BLACK)
			elseif i > 2 .AND. i <= 4
				_cCodBar := GJF182p(M->ZK_NUMAM,M->ZK_LOTE,M->ZK_CONTROL,'T',iif(_cLado = '00','D','E'),_cCodT,'',M->ZK_PROGRAM,M->ZK_PECARC1,M->ZK_PECARC2,M->ZK_BLACK)
			elseif i > 4 .AND. i <=6
				_cCodBar := GJF182p(M->ZK_NUMAM,M->ZK_LOTE,M->ZK_CONTROL,'C',iif(_cLado = '00','D','E'),_cCodC,'',M->ZK_PROGRAM,M->ZK_PECARC1,M->ZK_PECARC2,M->ZK_BLACK)
			endif

		else // dianteiro e traseiro

			_cLado := iif(i = 1  .or.  i = 3,'00','01')

			if i <= 2
				_cCodBar := GJF182p(M->ZK_NUMAM,M->ZK_LOTE,M->ZK_CONTROL,'D',iif(_cLado = '00','D','E'),_cCodD,iif(_cLado = '00',M->ZK_CDIAN2,M->ZK_CDIAN1),M->ZK_PROGRAM,M->ZK_PECARC1,M->ZK_PECARC2,M->ZK_BLACK)
			else
				_cCodBar := GJF182p(M->ZK_NUMAM,M->ZK_LOTE,M->ZK_CONTROL,'T',iif(_cLado = '00','D','E'),_cCodT,'',M->ZK_PROGRAM,M->ZK_PECARC1,M->ZK_PECARC2,M->ZK_BLACK)
			endif
		endif 

	next

return


user function gjf182hs(pTipo,pDesc)

	reclock('ZAK',.t.)
	ZAK->ZAK_FILIAL := FWxfilial('ZAK')
	ZAK->ZAK_CONTRO := ZAJ->ZAJ_NUM
	ZAK->ZAK_DATA   := date()
	ZAK->ZAK_HORA   := time()
	ZAK->ZAK_DESC   := pDesc 
	ZAK->ZAK_USAR   := cUserName
	ZAK->ZAK_EST    := getComputerName()

	if pTipo == 1
		ZAK->ZAK_TIPO   := 'E'
	elseif pTipo == 2
		ZAK->ZAK_TIPO   := 'S'
	elseif pTipo == 3
		ZAK->ZAK_TIPO   := 'M'
	endif   

	MsUnLock()

return


User Function AJZAJ()
	local _cNumam := '01014113'
	local i

	SZK->(DbSetOrder(4))
	SZK->(DbGotop())
	SZK->(MsSeek(FWxfilial('SZK')+_cNumam))

	while SZK->ZK_FILIAL = FWxfilial('SZK') .and. SZK->ZK_NUMAM = _cNumam

		if SZK->ZK_PETOTAL = 0
			SZK->(DbSkip())
			loop
		endif

		for i := 1 to 6

			_cLado := iif (i = 1  .or. i = 3 .or. i = 5,'00','01')

			if i <= 2
				_cCodBar := u_GJF182(SZK->ZK_NUMAM,SZK->ZK_LOTE,SZK->ZK_CONTROL,'D',iif(_cLado = '00','D','E'),'005020')
			elseif i > 2 .AND. i <= 4
				_cCodBar := u_GJF182(SZK->ZK_NUMAM,SZK->ZK_LOTE,SZK->ZK_CONTROL,'T',iif(_cLado = '00','D','E'),'005016')
			elseif i > 4 .AND. i <=6
				_cCodBar := u_GJF182(SZK->ZK_NUMAM,SZK->ZK_LOTE,SZK->ZK_CONTROL,'C',iif(_cLado = '00','D','E'),'005018')
			endif

		next

		SZK->(DbSkip())

	enddo

	alert('ok')
Return 

//Gera registros na tabela ZAJ  para coletores de dados
User Function gf182C(_n)

	Local _cCodT := '005016'
	Local _cCodD := '005020'
	Local _cCodC := '005018'
	Local i

	/*
	//Codigos para Programa Hereford
	if _ZK_PROGRAM = '002'
	_cCodT := '006273'  //Traseiro
	_cCodD := '007892'  //Dianteiro
	_cCodC := '006463'  //Costela

	//Codigos para Programa Angus
	elseif _ZK_PROGRAM = '006'
	_cCodT := '006272'  //Traseiro
	_cCodD := '007891'  //Dianteiro
	_cCodC := '006464'  //Costela
	endif
	*/

	ProcRegua(_n)

	for i := 1 to _n

		IncProc()

		if _cPar01 = '1' // dianteiro , traseiro e costela

			_cLado := iif (i = 1  .or. i = 3 .or. i = 5,'00','01')

			if i <= 2
				_cCodBar := GJF182p(SZ4->Z4_NUMAM,SZ4->Z4_LOTE,_ZK_CONTROL,'D',iif(_cLado = '00','D','E'),_cCodD,iif(_cLado = '00',_ZK_CDIAN2,_ZK_CDIAN1),_ZK_PROGRAM,_ZK_C1,_ZK_C2,_ZK_BLACK,_ZK_DESTINO)		  
			elseif i > 2 .AND. i <= 4
				_cCodBar := GJF182p(SZ4->Z4_NUMAM,SZ4->Z4_LOTE,_ZK_CONTROL,'T',iif(_cLado = '00','D','E'),_cCodT,'',_ZK_PROGRAM,_ZK_C1,_ZK_C2,_ZK_BLACK,_ZK_DESTINO)
			elseif i > 4 .AND. i <=6
				_cCodBar := GJF182p(SZ4->Z4_NUMAM,SZ4->Z4_LOTE,_ZK_CONTROL,'C',iif(_cLado = '00','D','E'),_cCodC,'',_ZK_PROGRAM,_ZK_C1,_ZK_C2,_ZK_BLACK,_ZK_DESTINO)
			endif

		else // dianteiro e traseiro  

			_cLado := iif(i = 1  .or.  i = 3,'00','01')

			if i <= 2
				_cCodBar := GJF182p(SZ4->Z4_NUMAM,SZ4->Z4_LOTE,_ZK_CONTROL,'D',iif(_cLado = '00','D','E'),_cCodT,iif(_cLado = '00',_ZK_CDIAN2,_ZK_CDIAN1),_ZK_PROGRAM,_ZK_C1,_ZK_C2,_ZK_BLACK,_ZK_DESTINO)			
			else
				_cCodBar := GJF182p(SZ4->Z4_NUMAM,SZ4->Z4_LOTE,_ZK_CONTROL,'T',iif(_cLado = '00','D','E'),_cCodD,'',_ZK_PROGRAM,_ZK_C1,_ZK_C2,_ZK_BLACK,_ZK_DESTINO)
			endif
		endif 

	next

	//VTAlert('Processo realizado!','Registros ZAJ realizados!',.T.,500,1)

return 


Static Function GJF182p(_cNumam,_cLote,_cControl,_cCorOri,_cLado,_cCod,_cDiant,_cProgram,_Peso1,_Peso2,_Black,_Dest)
	local _cNum := ''

	//local area := getarea()
	ZAJ->(DbSetOrder(1))
	if !ZAJ->(MsSeek(FWxFilial('ZAJ') + _cNumam + _cControl + _cCorOri + _cLado ))

		_cNum := GetSx8num('ZAJ','ZAJ_NUM')
		ConfirmSX8()

		if _cCorOri = 'T'
			_cDescri := GetAdvFVal('SZ6','Z6_DESREDT',FWxfilial('SZ6') + _cProgram,1)
		elseif _cCorOri = 'D'
			_cDescri := GetAdvFVal('SZ6','Z6_DESREDD',FWxfilial('SZ6') + _cProgram,1)
		elseif _cCorOri = 'C'
			_cDescri := GetAdvFVal('SZ6','Z6_DESREDC',FWxfilial('SZ6') + _cProgram,1)
		endif   

		/* bloco comentado por Giuliano e inserido o bloco acima na data de 13/01/16
		do case
		case _cCorOri = 'D' .and. _cProgram = '001'
		_cDescri := 'DIANT.MG.'
		case _cCorOri = 'T' .and. _cProgram = '001'
		_cDescri := 'TRAS.MG.'
		case _cCorOri = 'C' .and. _cProgram = '001'
		_cDescri := 'COST.MG.'
		case _cCorOri = 'T' .and. _cProgram = '002'
		_cDescri := 'TRAS. HE'
		case _cCorOri = 'D' .and. _cProgram = '002' //_cCod = '007892'
		_cDescri := 'DIANT. HE'
		case _cCorOri = 'C' .and. _cProgram = '002' //_cCod = '006463'
		_cDescri := 'COST. HE'
		case _cCorOri = 'D' .and. _cProgram = '005' //_cCod = '006463'
		_cDescri := 'DIANT. CZ'
		case _cCorOri = 'T' .and. _cProgram = '005' //_cCod = '006463'
		_cDescri := 'TRAS. CZ'
		case _cCorOri = 'C' .and. _cProgram = '005' //_cCod = '006463'
		_cDescri := 'COST. CZ'
		case _cCorOri = 'T' .and. _cProgram = '006' //_cCod = '006272'
		_cDescri := 'TRAS. AN'
		case _cCorOri = 'D' .and. _cProgram = '006' //_cCod = '007891'
		_cDescri := 'DIANT. AN'
		case _cCorOri = 'C' .and. _cProgram = '006' //_cCod = '006464'
		_cDescri := 'COST. AN'
		case _cCorOri = 'D' .and. _cProgram = '007' //_cCod = '006464'
		_cDescri := 'DIANT.CARR'
		case _cCorOri = 'T' .and. _cProgram = '007' //_cCod = '006464'
		_cDescri := 'TRAS.CARR'
		case _cCorOri = 'C' .and. _cProgram = '007' //_cCod = '006464'
		_cDescri := 'COST.CARR'
		case _cCorOri = 'D' .and. _cProgram = '008' //_cCod = '006464'
		_cDescri := 'DIANT.TOUR.'
		case _cCorOri = 'T' .and. _cProgram = '008' //_cCod = '006464'
		_cDescri := 'TRAS.TOUR.'
		case _cCorOri = 'C' .and. _cProgram = '008' //_cCod = '006464'
		_cDescri := 'COST.TOUR.'
		case _cCorOri = 'D' .and. _cProgram = '010' //_cCod = '006464'
		_cDescri := 'DIANT.TERN.'
		case _cCorOri = 'T' .and. _cProgram = '010' //_cCod = '006464'
		_cDescri := 'TRAS.TERN.'
		case _cCorOri = 'C' .and. _cProgram = '010' //_cCod = '006464'
		_cDescri := 'COST.TERN.'
		case _cCorOri = 'D' .and. _cProgram = '011' //_cCod = '006464'
		_cDescri := 'DIANT.BRAN.'
		case _cCorOri = 'T' .and. _cProgram = '011' //_cCod = '006464'
		_cDescri := 'TRAS.BRAN.'
		case _cCorOri = 'C' .and. _cProgram = '011' //_cCod = '006464'
		_cDescri := 'COST.BRAN.'
		*/
		do case
			case _cCorOri = 'T' .and. empty(_cProgram)  //_cCod = '000030'
			_cDescri := 'TRASEIRO'
			case _cCorOri = 'D' .and. empty(_cProgram)  //_cCod = '000031'
			_cDescri := 'DIANTEIRO'
			case _cCorOri = 'C' .and. empty(_cProgram)  //_cCod = '000032'
			_cDescri := 'COSTELA'
		endcase

		_nPerTras  := GetMV('SI_%TRAS')
		_nPerDian  := GetMV('SI_%DIAN')
		_nPerCost  := GetMV('SI_%COST')

		_nPesoI := iif(_cCorOri = 'T',_nPerTras * iif(_cLado = 'E',_Peso1,_Peso2),;
		iif(_cCorOri = 'D',_nPerDian * iif(_cLado = 'E',_Peso1,_Peso2),;
		_nPerCost * iif(_cLado = 'E',_Peso1,_Peso2))) 

		_nPeso := _nPesoI// - (_nPesoI * 0.02)  // -2% de frio

		if _Dest $ "T/R"
			_Black := "N"
		endif

		reclock('ZAJ',.t.)
		ZAJ->ZAJ_FILIAL  := FWxfilial('ZAJ')
		ZAJ->ZAJ_CONTRO  := _cControl
		ZAJ->ZAJ_COD     := _cCod
		ZAJ->ZAJ_DESCRI  := _cDescri
		ZAJ->ZAJ_CORORI  := _cCorOri
		ZAJ->ZAJ_NUMAM   := _cNumam
		ZAJ->ZAJ_LOTE    := _cLote
		ZAJ->ZAJ_NUM     := _cNum
		ZAJ->ZAJ_LADO    := _cLado
		ZAJ->ZAJ_NIVEL   := 0
		ZAJ->ZAJ_REGORI  := '0000000000'
		ZAJ->ZAJ_CDIAN   := _cDiant
		ZAJ->ZAJ_DATA    := date()
		ZAJ->ZAJ_PESO    := _nPeso
		ZAJ->ZAJ_BLACK	 := _Black
		msunlock()

		u_gjf182hs(1,"PROD. DO ABATE")
	else
		_cNum := ZAJ->ZAJ_NUM 
	endif

	//restarea(area)
	//VTAlert('ZAJ-> '+_cNum + '  Control-> ' + _cControl,'giuliano',.T.,2000,1)

Return _cNum         
