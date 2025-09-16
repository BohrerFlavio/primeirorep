#INCLUDE "rwmake.ch"    
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF_PCP028  บAutor  ณEdison Schneider    บ Data ณ  07/08/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria็ใo do arquivo Agregar                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Pcp                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User FuncTion F_PCP028()

	Private aAnimais := {}    

	cPerg := "PCP028"

	// inicializar matriz
	aAdd( aAnimais, {0,0,0,0,0,0,0,0,0,0} )

	If ( Pergunte( cPerg,.T. ) )
		Processa( {|| Runproc() },"Montando arquivo GTA.TXT!","Aguarde..." )
	EndIf

ReTurn( Nil )

/*/
Funcao de Processamento RunPRoc()
/*/

Static Function RunPRoc()
	Local _cQuery, aDados, _cTipo, _cFile := ''   
	Local CRLF := Chr(13) + Chr(10)

	/* Cria็ใo de arquivo auxiliar de NFe, cfe parโmetros do usuแrio */             

	_cQuery := "SELECT * FROM "+RetSqlName("SD1")+" SD1 " +;
	" INNER JOIN "+RetSqlName("SC7")+" SC7 "+;
	" ON ( SD1.D1_PEDIDO = SC7.C7_NUM AND SD1.D1_ITEMPC = SC7.C7_ITEM ) "+;
	" WHERE SD1.D_E_L_E_T_ <> '*' AND SC7.D_E_L_E_T_ <> '*' " +;     
	" AND SD1.D1_FILIAL = '" + xFilial( "SD1" ) + "' " +;
	" AND SC7.C7_FILIAL = '" + xFilial( "SC7" ) + "' " +;   
	" AND SC7.C7_GRUPO  = '1000'" +;         // somente do grupo gado
	" AND SC7.C7_PRODUTO  <> '001220'" +;    // nao pega bonus
	" AND SC7.C7_NUMAM    <> ''      " +;    // tem que ter aviso de matan็a
	" AND SD1.D1_EMISSAO BETWEEN '"+DtoS( mv_par01 )+"' AND '"+DtoS( mv_par02 )+"' " +;
	" AND SD1.D1_FORNECE BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' " +;	          
	" ORDER BY SD1.D1_EMISSAO,SD1.D1_DOC,SD1.D1_FORNECE,SD1.D1_LOJA "                                         


	_cQuery := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo


	If Select("QRYAUX")<>0
		QRYAUX->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRYAUX"

	ProcRegua(LastRec())

	/* Inicializar a string de grava็ใo */
	aDados := ""

	SA2->( dbSetOrder(1) )

	dbSelecTarea( "QRYAUX" )
	dbGoTop()
	While !Eof()          

		SA2->( dbSeek(xFilial('SA2')+QRYAUX->D1_FORNECE+QRYAUX->D1_LOJA ) )

		tpAnimal := fTpAnimal( QRYAUX->C7_NUMAM, QRYAUX->C7_LOTE )
		chave := QRYAUX->(D1_EMISSAO+D1_DOC+D1_FORNECE+D1_LOJA+tpAnimal  )

		aDados += StrZero( Val(QRYAUX->D1_DOC), 9 )
		aDados += QRYAUX->D1_EMISSAO       
		aDados += Strzero(Val(SA2->A2_CGC),14) //Posicione("SA2",1,xFilial("SA2")+QRYAUX->D1_FORNECE,"SA2->A2_CGC")
		aDados += fGTA( QRYAUX->C7_NUMAM, QRYAUX->C7_LOTE )
		aDados += Left(SA2->A2_INSCR ,12) //Left( Posicione("SA2",1,xFilial("SA2")+QRYAUX->D1_FORNECE,"SA2->A2_INSCR"), 14 )
		aDados += Space(2)+tpAnimal 

		aAnimais := {}    
		aAdd( aAnimais, {0,0,0,0,0,0,0,0,0,0} )

		While !Eof() .AND. chave == QRYAUX->(D1_EMISSAO+D1_DOC+D1_FORNECE+D1_LOJA+ fTpAnimal( QRYAUX->C7_NUMAM, QRYAUX->C7_LOTE ) )
			fZK( QRYAUX->C7_NUMAM, QRYAUX->C7_LOTE )  
			dbSelecTarea( "QRYAUX" )
			dbSkip()
			IncProc()
		End

		aDados += StrZero( aAnimais[ 1, 1 ], 5 ) 
		aDados += StrZero( aAnimais[ 1, 2 ], 5 )
		aDados += StrZero( aAnimais[ 1, 3 ], 5 )
		aDados += StrZero( aAnimais[ 1, 4 ], 5 )
		aDados += StrZero( aAnimais[ 1, 5 ], 5 )
		aDados += StrZero( aAnimais[ 1, 6 ], 5 )
		aDados += StrZero( aAnimais[ 1, 7 ], 5 )
		aDados += StrZero( aAnimais[ 1, 8 ], 5 )
		aDados += StrZero( aAnimais[ 1, 9 ], 5 )
		aDados += StrZero( aAnimais[ 1, 10 ], 5 )
		aDados += " " + CRLF   

	End //While !Eof()

	/* Arquivo para a grava็ใo dos dados */
	_cTipo := "Arquivos Texto  (*.txt)   | *.txt     "
	_cFile := cGetFile( _cTipo, "Informe o nome do arquivo para grava็ใo dos dados!" )

	if _cFile <> ""
		MemoWrit( _cFile, aDados ) 
		MsgAlert("O arquivo "+_cFile+" foi gravado com sucesso!.","Atencao!")
	endif

ReTurn

/*--------------------------------------------------------------------------------------------------------
Funcao......: fZK( _cNumAm, _cLote )
Autor.......: Edison Schneider - 20/04/2007
Parametros..: < _cNumAm > Numero da ordem de abate            
< _cLote  > Numero do lote
Retorno.....: Matriz contendo as informa็๕es sobre a quantidade/idade dos animais
Objetivo....: Obter informa็๕es sobre a quantidade, idade e sexo dos animais abatidos.
Observacoes.: Nenhuma.
Alteracoes..: Nenhuma.
--------------------------------------------------------------------------------------------------------*/
Static Function fZK( _cNumAm, _cLote )
	Local _sAlias := Alias()

	dbSelecTarea( "SZK" )
	dbSetOrder( 3 )
	dbSeek( xFilial( "SZK" ) + _cNumAm + _cLote ) 
	do while !Eof() .And. SZK->ZK_NUMAM = _cNumAm .And. SZK->ZK_LOTE = _cLote
		do Case   //Anexo I - Conversใo das idades
			Case SZK->ZK_DENT = "0"   //0-dente de leite	4 meses
			if SZK->ZK_SEXO = "M"
				aAnimais[ 1, 1 ] += 1
			else
				aAnimais[ 1, 2 ] += 1
			endif
			Case SZK->ZK_DENT = "2"   //2-dois dentes	4 a 12 meses
			if SZK->ZK_SEXO = "M"
				aAnimais[ 1, 3 ] += 1
			else
				aAnimais[ 1, 4 ] += 1
			endif        
			Case SZK->ZK_DENT = "4"   //4-quatro dentes	12 a 24 meses
			if SZK->ZK_SEXO = "M"
				aAnimais[ 1, 5 ] += 1
			else
				aAnimais[ 1, 6 ] += 1
			endif         
			Case SZK->ZK_DENT = "6"   //6-seis dentes	At้ 36 meses          
			if SZK->ZK_SEXO = "M"
				aAnimais[ 1, 7 ] += 1
			else
				aAnimais[ 1, 8 ] += 1
			endif         
			Case SZK->ZK_DENT = "8"   //8-oito dentes	Acima de 36 meses
			if SZK->ZK_SEXO = "M"
				aAnimais[ 1, 9 ] += 1
			else
				aAnimais[ 1, 10 ] += 1
			endif         
		endCAse

		dbSkip()
	enddo
	dbSelectArea(_sAlias)
ReTurn ( aAnimais )

/*--------------------------------------------------------------------------------------------------------
Funcao......: fGTA( _cNumAm, _cLote )
Autor.......: Edison Schneider - 20/04/2007
Parametros..: < _cPC >   Numero da ordem de abate           
< _cItem > Numero do Lote
Retorno.....: N๚mero da GTA
Objetivo....: Obter o n๚mero da GTA cfe o Pedido de Compras/Item cadastrado no arquivo de NFe (SD1)
Observacoes.: Nenhuma.
Alteracoes..: Nenhuma.
--------------------------------------------------------------------------------------------------------*/
Static Function fGTA( _cNumAm, _cLote )
	Local _cGTA   := "000000",;
	_sAlias := Alias()

	dbSelecTarea( "SZE" )
	dbSetOrder( 2 )
	dbSeek( xFilial( "SZE" ) + _cNumAm + _cLote )
	//If Found()
	//     dbSelecTarea( "SZD" )
	//     dbSetOrder( 1 )
	//     dbSeek( xFilial( "SZD" ) + SZE->ZE_NUMERO )
	//     If Found()
	_cGTA := Left(SZE->ZE_GTA,6)   //ZE_GTA TEM 50 CARACTERES ???????
	//    EndIf
	//EndIf

	dbSelectArea(_sAlias) 
ReTurn ( _cGTA )

/*--------------------------------------------------------------------------------------------------------
Funcao......: fTpAnimal( _cNumAm, _cLote )
Autor.......: Edison Schneider - 20/04/2007
Parametros..: < _cPC >   Numero da ordem de abate            
< _cItem > Numero do Lote
Retorno.....: Esp้cie do Animal
Objetivo....: Obter a descri็ใo da esp้cie do animal.
Observacoes.: Nenhuma.
Alteracoes..: Nenhuma.
--------------------------------------------------------------------------------------------------------*/
Static Function fTpAnimal( _cNumAm, _cLote )
	Local _cTpAni := Space( 10 ),;
	_sAlias := Alias()

	dbSelecTarea( "SZE" )
	dbSetOrder( 2 )
	dbSeek( xFilial( "SZE" ) + _cNumAm + _cLote )
	If Found()
		dbSelecTarea( "SZ5" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "SZ5" ) + SZE->ZE_CATEG )
		If Found()
			_cTpAni := Left( fDesc("SX5","Z4"+sz5->Z5_GRUPO,"X5_DESCRI"), 10 )
		EndIf
	EndIf

	dbSelectArea(_sAlias) 
ReTurn ( _cTpAni )
