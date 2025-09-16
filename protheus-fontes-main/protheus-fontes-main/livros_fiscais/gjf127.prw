#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fileio.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGJF127  บAutor  ณGiuliano Forgiarini บ Data ณ  12/12/11     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Arquivo para importa็ใo e integra็ใo de estoque de PA em   บฑฑ
ฑฑบ          ณ arquivo DTC para SPED Fiscal                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Fiscal/Contabilidade/Custos                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User FuncTion GJF127()

	Private _nByLin  := 0
	Private _nLin    := 0
	Private _aProd   := {}

	cPerg := "GJF127"


	If ( Pergunte( cPerg,.T. ) )
		Processa({|| _aProd := Leitura(mv_par02)       },"Fazendo a leitura de arquivo TXT!","Aguarde..." )
		Processa({||           Integra(_aProd,mv_par01)},"Fazendo a integra็ใo com arquivo DTC!","Aguarde..." )

	EndIf

ReTurn( Nil )


//Fun็ใo para ler TXT
Static Function Leitura(_cArquivo)
	Local _nLidas  := 0
	Local _nPosAtu := 0
	Local _cString := ''
	Local _cStr    := ''
	Local _aLin    := {}
	Local _ValCol1 := ''
	Local _ValCol2 := ''
	Local _ValCol3 := 0
	Local _ValCol4 := 0
	Local _ValCol5 := 0

	if !file(alltrim(_cArquivo))
		MsgAlert("Arquivo TXT nใo foi encontrado! Verifique os parametros.","Atencao!")
		Return
	endif

	nHandle := FOPEN(alltrim(_cArquivo),FO_READ)
	cString := ''

	If nHandle == -1
		MsgAlert("O arquivo nao pode ser aberto! Verifique os parametros.","Atencao!")
		_lOK := .f.
		Return
	Endif

	nTamFile := fSeek(nHandle,0,FS_END)

	if nTamFile  = 0
		MsgAlert("O arquivo estแ em branco!","Atencao!")
		return
	endif

	ProcRegua(nTamFile)

	/////////////////////////////////////////////////
	//Calculo do numero de bytes para linha e colunas
	/////////////////////////////////////////////////
	fseek(nHandle,0,FS_SET)

	_nByLin := 0
	_cFim := ""
	_lFim := .t.

	//Calcula o numero de bytes por linha
	while _lFim

		_cFim := FREADSTR(nHandle,1)

		if _cFim = CHR(13)
			_cFim := FREADSTR(nHandle,1)

			if _cFim = CHR(10)
				_lFim := .f.
			endif
		endif
		if _lFim
			_nByLin++
		endif
	enddo

	_nByLin += 2

	//Calcula o numero de linhas
	fseek(nHandle,0,FS_SET)

	_cString := FREADSTR(nHandle,_nByLin)
	_nlin    := 0

	while  !empty(_cString)
		_cString :=  FREADSTR(nHandle,_nByLin)
		_nlin++
	enddo


	//La็o para definir os dados lidos do TXT
	fseek(nHandle,0,FS_SET)

	While _nLidas < _nlin

		_nLidas++
		_cStr := alltrim(FREADSTR(nHandle,_nByLin))
		_ValCol1 := substr(_cStr,1,6)                          //coluna deve iniciar na posi็ใo 1
		AADD(_aLin,{_valCol1,_nLidas})
		_ValCol2 := substr(_cStr,9,45)                         //coluna deve iniciar na posi็ใo 9
		//Nใo precisa levar a descri็ใo ao vetor
		_ValCol3 := val(strtran(substr(_cStr,mv_par03,15),',','.'))
		AADD(_aLin,{_valCol3,_nLidas})
		_valCol4 := val(strtran(substr(_cStr,mv_par04,13),',','.'))
		AADD(_aLin,{_valCol4,_nLidas})
		_valCol5 := val(strtran(substr(_cStr,mv_par05,12),',','.'))
		AADD(_aLin,{_valCol5,_nLidas})
	enddo

	//u_showarray(_aLin)

	FCLOSE(nHandle)

return _aLin



//Fun็ใo para realizar o processamento
Static Function Integra(_aLin,_arq)
	Local _cProd  := ''
	Local _nCC    := 0
	Local _nCx    := 0
	Local _nPs    := 0
	Local _lin    := 1
	Local _lFail  := .f.
	Local i
	
	dbUseArea( .T.,"ctreecdx",_arq,"INV", .T., .F. )

	for i := 1 to Len(_aLin)

		ProcRegua(Len(_aLin))

		_lFail  := .f.
		//    alert(_aLin[i,2])
		//    alert(_aLin[i,1])

		if _lin > 4
			_lin := 1
		endif

		do case
			case _lin = 1
			_cProd := alltrim(_aLin[i,1])
			_lin++

			case _lin = 2
			_nCC   := _aLin[i,1]
			_lin++

			case _lin = 3
			_nCx   := _aLin[i,1]
			_lin++

			case _lin = 4
			_nPs   := _aLin[i,1]

			/*INV->(DbGoTop())
			while INV->(!eof())
			if alltrim(INV->PRODUTO) = alltrim(_cProd)
			_lFail := .t.
			exit
			endif
			INV->(DbSkip())
			enddo
			*/   

			/*	if _lFail
			exit
			endif
			*/


			INV->(dbGoTop())
			while INV->(!eof())
				if alltrim(INV->PRODUTO) == alltrim(_cProd)
					_lFail := .t.
					exit
				endif
				INV->(dbSkip())
			enddo


			DbSelectArea('SB1')
			if !_lFail
				reclock('INV',.t.)
				INV->FILIAL     := xfilial('SB1')
				INV->PRODUTO    := _cProd
				INV->SITUACAO   := '1'
				INV->UM         := fBuscaCPO('SB1',1,xfilial('SB1')+_cProd,'B1_UM')
				INV->QUANTIDADE := _nPs
				INV->VALOR_UNIT := _nCC
				INV->TOTAL      := _nCC * _nPs
				msunlock()

			endif
			_lin++
		endcase
	next


	DbCloseArea('INV')
return

