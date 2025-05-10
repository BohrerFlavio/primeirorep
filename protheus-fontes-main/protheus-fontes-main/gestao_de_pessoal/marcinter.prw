#INCLUDE "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MarcInter ºAutor  ³3v                  º Data ³  05/18/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gerar marcacoes referentes a intervalos de lanches          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function marcInter()

	If MsgBox ("Confirma processo?","Escolha","YESNO")
		Processa( {|| runProc() },"Aguarde processando registros..." )
	Endif

Return
//
//
//
Static Function runProc()

	Private dataDe  := ctod('21/04/2006')
	Private dataAte := ctod('15/05/2006')

	turno := {}

	dbSelectArea('SPJ')//tab horario
	dbSetOrder(1)

	//              num    1s      2e     3s    4e

	dbSeek(xFilial('SPJ')+'001')
	AADD( turno, { '001', PJ_SAIDA1 , PJ_ENTRA2 , PJ_SAIDA3, PJ_ENTRA4  } )

	dbSeek(xFilial('SPJ')+'013')
	AADD( turno, { '013', PJ_SAIDA1 , PJ_ENTRA2 , PJ_SAIDA3, PJ_ENTRA4  } )

	dbSeek(xFilial('SPJ')+'014')
	AADD( turno, { '014', PJ_SAIDA1 , PJ_ENTRA2 , PJ_SAIDA3, PJ_ENTRA4  } )

	dbSeek(xFilial('SPJ')+'015')
	AADD( turno, { '015', PJ_SAIDA1 , PJ_ENTRA2 , PJ_SAIDA3, PJ_ENTRA4  } )

	dbSeek(xFilial('SPJ')+'016')
	AADD( turno, { '016', PJ_SAIDA1 , PJ_ENTRA2 , PJ_SAIDA3, PJ_ENTRA4  } )

	dbSeek(xFilial('SPJ')+'017')
	AADD( turno, { '017', PJ_SAIDA1 , PJ_ENTRA2 , PJ_SAIDA3, PJ_ENTRA4  } )

	dbSeek(xFilial('SPJ')+'021')
	AADD( turno, { '021', PJ_SAIDA1 , PJ_ENTRA2 , PJ_SAIDA3, PJ_ENTRA4  } )

	dbSeek(xFilial('SPJ')+'027')
	AADD( turno, { '027', PJ_SAIDA1 , PJ_ENTRA2 , PJ_SAIDA3, PJ_ENTRA4  } )

	dbSeek(xFilial('SPJ')+'031')
	AADD( turno, { '031', PJ_SAIDA1 , PJ_ENTRA2 , PJ_SAIDA3, PJ_ENTRA4  } )

	dbSeek(xFilial('SPJ')+'032')
	AADD( turno, { '032', PJ_SAIDA1 , PJ_ENTRA2 , PJ_SAIDA3, PJ_ENTRA4  } )


	dbSelectArea('SRA')
	dbSetOrder(1)
	dbGotop()
	ProcRegua(SRA->( Reccount() ) )
	Do While !Eof()


		onde := ASCAN( turno, {|reg| reg[1] == SRA->ra_tnotrab } )
		If  onde  <> 0  // condicoes para gerar as marcacoes
			dbSelectArea('SP8')
			dbSetOrder(2) // filial+mat+data+hora
			dbSeek( xFilial('SP8')+SRA->RA_MAT+DTOS( datade ) ,.T.)

			Do While !Eof() .AND. SRA->RA_MAT == SP8->P8_MAT .AND. SP8->P8_DATA <= dataAte

				lMarca := .F. // se achou alguma marcacao para este dia/funcionario
				dData := SP8->P8_DATA

				Do While !Eof() .AND. SRA->RA_MAT == SP8->P8_MAT .AND. SP8->P8_DATA == dData
					// Troca marcacoes existentes
					If SP8->P8_TPMARCA == '1S'
						RecLock('SP8',.F.)
						SP8->P8_TPMARCA := '2S'
						MsUnlock()
						lMarca := .T.
						ordem := SP8->P8_ORDEM
					ElseIf SP8->P8_TPMARCA == '2E'
						RecLock('SP8',.F.)
						SP8->P8_TPMARCA := '3E'
						MsUnlock()
						lMarca := .T.
						ordem := SP8->P8_ORDEM
					ElseIf SP8->P8_TPMARCA == '2S'
						If  turno[onde,5] <> 0  // tem 8 marcacoes
							RecLock('SP8',.F.)
							SP8->P8_TPMARCA := '4S'
							MsUnlock()
							lMarca := .T.
							ordem := SP8->P8_ORDEM
						Else   // tem 6 marcacoes
							RecLock('SP8',.F.)
							SP8->P8_TPMARCA := '3S'
							MsUnlock()
							lMarca := .T.
							ordem := SP8->P8_ORDEM
						Endif
					Endif
					dbSkip() // proxima marcacao 
					recSp8 := recno()
				Enddo            
				Adicionar()   // adiciona marcacoes do dia
				dbGoto( recsp8 )
			Enddo         // proximo dia
		Endif

		dbSelectArea('SRA')
		dbSkip()
		IncProc()
	Enddo


Static Function adicionar()
	If lMarca // gera as marcaçoes adicionais para o dia
		RecLock('SP8',.T.)
		SP8->P8_TPMARCA := '1S'
		SP8->P8_FILIAL  := xFilial('SP8')
		SP8->P8_MAT     := SRA->RA_MAT
		SP8->P8_DATA    := dData
		SP8->P8_HORA    := turno[onde,2]
		SP8->P8_CC      := SRA->RA_CC
		SP8->P8_ORDEM   := ordem
		SP8->P8_FLAG    := 'I'
		SP8->P8_APONTA  := 'N'
		SP8->P8_TURNO   := SRA->ra_tnotrab
		SP8->P8_RELOGIO := '01'
		MsUnlock()
		//------------
		RecLock('SP8',.T.)
		SP8->P8_TPMARCA := '2E'
		SP8->P8_FILIAL  := xFilial('SP8')
		SP8->P8_MAT     := SRA->RA_MAT
		SP8->P8_DATA    := dData
		SP8->P8_HORA    := turno[onde,3]
		SP8->P8_CC      := SRA->RA_CC
		SP8->P8_ORDEM   := ordem
		SP8->P8_FLAG    := 'I'
		SP8->P8_APONTA  := 'N'
		SP8->P8_TURNO   := SRA->ra_tnotrab
		SP8->P8_RELOGIO := '01'
		MsUnlock()
		//------------

		If  turno[onde,5] <> 0  // tem 8 marcacoes
			RecLock('SP8',.T.)
			SP8->P8_TPMARCA := '3S'
			SP8->P8_FILIAL  := xFilial('SP8')
			SP8->P8_MAT     := SRA->RA_MAT
			SP8->P8_DATA    := dData
			SP8->P8_HORA    := turno[onde,4]
			SP8->P8_CC      := SRA->RA_CC
			SP8->P8_ORDEM   := ordem
			SP8->P8_FLAG    := 'I'
			SP8->P8_APONTA  := 'N'
			SP8->P8_TURNO   := SRA->ra_tnotrab
			SP8->P8_RELOGIO := '01'
			MsUnlock()
			//------------
			RecLock('SP8',.T.)
			SP8->P8_TPMARCA := '4E'
			SP8->P8_FILIAL  := xFilial('SP8')
			SP8->P8_MAT     := SRA->RA_MAT
			SP8->P8_DATA    := dData
			SP8->P8_HORA    := turno[onde,5]
			SP8->P8_CC      := SRA->RA_CC
			SP8->P8_ORDEM   := ordem
			SP8->P8_FLAG    := 'I'
			SP8->P8_APONTA  := 'N'
			SP8->P8_TURNO   := SRA->ra_tnotrab
			SP8->P8_RELOGIO := '01'
			MsUnlock()
		Endif
	Endif
Return

/*-------------------------------------

1E          1S     2E         2S

1E  1s 2e   2S     3E  3s 4e  4S


Mudar:

1S -> 2S
2E -> 3E
2S -> 4S

incluir :

1s
2e
3s
4e


*/
