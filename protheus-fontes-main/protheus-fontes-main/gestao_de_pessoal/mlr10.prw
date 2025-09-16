#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMLR10  บAutor  ณMauricio Roehrs   บ Data ณ   11/04/13	     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajuste das batidas(ponto)Duplicadas na Tabela SPG			  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Departamento Pessoal - Medida Paliativa                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MLR10()   
	private _lProcessa := .t.
	Processa({||Limpeza() },"LIMPEZA DE PONTOS DUPLICADOS","Corrigindo Pontos Duplicados..." )                             
Return

Static Function Limpeza()
	while _lProcessa
		Processar()
	enddo
return                

static function Processar()	
	Local _cMat   := ''
	Local _nConta := 0
	Local _cData  := ''
	Local _nHora  := 0


	_cQuery := " SELECT PG_MAT AS MAT, PG_DATA AS DATAB, PG_HORA AS HORA, COUNT(PG_MAT) AS NUMERO"
	_cQuery += " FROM " + RetSQLTab('SPG') "
	_cQuery += " WHERE " + RetSQLFil('SPG') + " AND PG_DATA <> '' AND PG_HORA <> 0 AND PG_MOTIVRG <> '' AND" 
	_cQuery += " PG_DATA BETWEEN '20121216' AND '20130115' AND " + RetSqlDel('SPG')
	_cQuery += " GROUP BY PG_MAT, PG_DATA, PG_HORA"
	_cQuery += " HAVING COUNT(PG_MAT) > 1"
	_cQuery += " ORDER BY PG_MAT, PG_DATA, PG_HORA"

	//BETWEEN '20121216' AND '20130115'
	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif

	_cQuery := ChangeQuery(_cQuery)
	TCQUERY _cQuery NEW ALIAS "QRY"

	//DbSelectArea('SPG')
	DbSelectArea('QRY')
	QRY->(DbGoTop())

	_nCont := 0
	while QRY->(!eof())
		_nCont++
		QRY->(DbSkip())
	enddo

	if _nCont = 0
		_lProcessa := .f.
	endif

	QRY->(DbGoTop())

	ProcRegua(QRY->(RecCount()))

	_cMat  := QRY->MAT                                                                          
	_cData := QRY->DATAB
	_nHora := QRY->HORA


	if _lProcessa
		while QRY->(!eof())

			incproc('Processando Matricula Nบ: ' + QRY->MAT)

			SPG->(DbSetOrder(2))
			if	SPG->(DbSeek(xfilial('SPG')+QRY->(MAT+DATAB+cvaltochar(HORA))))
				while SPG->(!eof()) .and. SPG->PG_FILIAL     = xfilial('SPG') .and.;
				SPG->PG_MAT        = QRY->MAT       .and.;
				dtos(SPG->PG_DATA) = QRY->DATAB     .and.;
				SPG->PG_HORA       = QRY->HORA

					if !empty(SPG->PG_MOTIVRG)
						//	alert('Vai excluir...' + '|   |' + SPG->PG_MAT + '|   |' + dtoc(SPG->PG_DATA) + '|   |' + cvaltochar(SPG->PG_HORA))
						RecLock('SPG',.f.)
						DbDelete()
						msunlock()
						exit
					endif

					SPG->(DbSkip())
				enddo

			endif
			QRY->(DbSkip())
		enddo
	endif

return	
