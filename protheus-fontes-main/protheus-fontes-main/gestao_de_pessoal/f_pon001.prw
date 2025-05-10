#INCLUDE "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PON001    ºAutor  ³3v Technology       º Data ³  05/25/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gerar arquivo para reserva de refeições                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Sigapon                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function F_Pon001()

	cPerg := "PON001"

	if !Pergunte(cPerg,.T.)
		return
	endif
	Private  datade  := mv_par01
	Private  cPath   := mv_par02
	Private  tiporef := mv_par03

	Private cIndexName := CriaTrab(NIL,.F.)
	Private cFilter    := ' P5_TIPOREF == "'+tiporef+'" .AND. P5_DATA = dataDe  ' // utilizar somente reservas
	Private cIndexKey  := ' P5_FILIAL + DTOS(P5_DATA) + P5_MAT '                                  // indexa pela data
	IndRegua("SP5", cIndexName, cIndexKey,, cFilter, "Aguarde. Selecionando Registros....")
	DbSelectArea("SP5")

	cNedi  := Rtrim(cPath)+'R'+Strtran(DTOC(datade),'/','')+'.txt'

	nHdl    := fCreate(cNedi)
	If nHdl == -1
		Msgbox("Não foi possível criar arquivo: " +cNedi ,"Atenção!",'INFO')
		Return
	Endif
	Processa( {|| GeraSp5() },"Aguarde","Gerando reservas por apontamento ...")
	RetIndex("SP5") // retorna o indice original

	Processa( {|| GeraSra() },"Aguarde","Gerando reservas por cadastro ...")

	fClose(nHdl)
	Msgbox('EDI gerado em: ' + cNedi, 'reserva.txt', 'INFO')

	//----------------------------------
	// Gerar Cadastro dos funcionarios

	cNedi2 := Rtrim(cPath)+'C'+Strtran(DTOC(datade),'/','')+'.txt'
	Private nHdl2 := fCreate(cNedi2)
	If nHdl2 == -1
		Msgbox("Não foi possível criar arquivo: " +cNedi2 ,"Atenção!",'INFO')
		Return
	Endif
	Processa( {|| GeraCad() },"Aguarde","Gerando cadastro de funcionarios...")
	fClose(nHdl2)
	Msgbox('EDI gerado em: ' + cNedi2, 'cadastro.txt', 'INFO')
Return
//
//
//

/*
Function GeraSp5()
gerar as marcacoes de reserva a partir do sp5-refeitório
lido do relógio
*/

Static Function GeraSp5()
	ProcRegua( 400 )
	dbGotop()
	Do While !Eof()

		cLin :=  replicate('0',9)+;                  //  inicia com 9 zeros
		Strzero(Val(SP5->P5_MAT),6)+;                //  matricula  com 6 posicoos
		Strzero(day(SP5->P5_DATA),2)+;               //  dia
		Strzero(month(SP5->P5_DATA),2)+;             //  mes
		Right(Dtoc(SP5->P5_DATA),2)+;                //  ano com 2 digitos
		Strzero(Val(Left (transform(SP5->P5_HORA,'99.99'),2)) ,2)+;
		Strzero(Val(Right(transform(SP5->P5_HORA,'99.99'),2)) ,2)

		grava(cLin)
		dbSkip()
		IncProc()
	Enddo
Return
//
//
/**
* Function GeraSra()
gerar as marcacoes de reserva a partir do sra - líderes no grupo sra
funcionarios que nao batem cartao
*/
Static Function GeraSra()
	dbSelectArea('SRA')
	dbSetOrder(1)
	ProcRegua( SRA->( Reccount() ) )
	dbGotop()
	Do While !Eof()
		If SRA->RA_REFAUT == 'S' .AND.  SRA->RA_TNOTRAB == '999' .AND. RA_SITFOLH $ ' FA'

			retornou := .f.
			If SRA->RA_SITFOLH == 'A'
				//verificar se o funcionario já retornou de afastamento
				SR8->( dbSetOrder(1) )
				SR8->( dbSeek(xFilial('SR8')+SRA->RA_MAT )  )
				While !SR8->(Eof()) .AND. SRA->RA_MAT  == SR8->R8_MAT  //.AND. SR8->R8_FILIAL == xFilial('SR8')
					retornou  := ( !Empty( SR8->R8_DATAFIM )  .AND.  SR8->R8_DATAFIM < ddatabase  )
					SR8->(dbSkip())
				Enddo
			Endif

			If SRA->RA_SITFOLH $ ' F' .or. retornou
				cLin :=  replicate('0',9)+;                  //  inicia com 9 zeros
				Strzero(Val(SRA->RA_MAT),6)+;                //  matricula  com 6 posicoos
				Strzero(day(datade),2)+;               //  dia
				Strzero(month(datade),2)+;             //  mes
				Right(Dtoc(datade),2)+;                //  ano com 2 digitos
				Strzero(Val(Left (transform(6.00,'99.99'),2)) ,2)+;   // hora fixa com 06:00
				Strzero(Val(Right(transform(6.00,'99.99'),2)) ,2)
				grava(cLin)
			Endif
		Endif
		dbSkip()
		IncProc()
	Enddo
Return
//
//
Static function grava(CLin)
	clin2 := cLin + char(13)+chr(10)
	If fWrite(nHdl,cLin2,Len(cLin2)) != Len(cLin2)
		Msgbox("Ocorreu um erro na gravação de: "+cNedi,"Atenção!",'INFO')
		Return .f.
	Endif
Return .t.
//
//
//
Static function grava2(CLin)
	clin2 := cLin + char(13)+chr(10)

	If fWrite(nHdl2,cLin2,Len(cLin2)) != Len(cLin2)
		Msgbox("Ocorreu um erro na gravação de: "+cNedi,"Atenção!",'INFO')
		Return .f.
	Endif
Return .t.
//
//
//
/**
* Function GeraCad()
gerar o cadastro as a partir do sra
*/
Static Function geraCad()

	dbSelectArea('SPE')
	dbSetOrder(1)

	dbSelectArea('SRA')
	dbSetOrder(1)

	ProcRegua( SRA->( Reccount() ) )
	dbGotop()
	Do While !Eof()

		SPE->(dbSeek(xFilial('SPE')+SRA->RA_MAT ) )

		matProv := Space(6)
		If SPE->( Found() )
			//Procura ultimo cracha provisorio
			While ! SPE->( Eof() )
				SPE->( dbSkip() )
				If SPE->PE_MAT <> SRA->RA_MAT  // era o ultimo
					SPE->( dbSkip(-1) ) // volta pra o ultimo
					If SPE->PE_DATAFIM >= ddatabase  // testa a data limite
						matProv := STRZERO(VAL(SPE->PE_MATPROV),6)
					Endif
					Exit
				Endif
			Enddo
		Endif

		If SRA->RA_FILIAL  == '00' .AND.  RA_SITFOLH $ ' FA'

			retornou := .f.
			If SRA->RA_SITFOLHA == 'A'
				//verificar se o funcionario já retornou de afastamento
				SR8->( dbSetOrder(1) )
				SR8->( dbSeek(xFilial('SR8')+SRA->RA_MAT )  )
				While !SR8->(Eof()) .AND. SRA->RA_MAT  == SR8->R8_MAT  .AND. SR8->R8_FILIAL == xFilial('SR8')
					retornou  := ( !Empty( SR8->R8_DATAFIM )  .AND.  SR8->R8_DATAFIM < ddatabase  )
					SR8->(dbSkip())
				Enddo
			Endif

			If SRA->RA_SITFOLH <> 'A' .OR. retornou
				cLin := Strzero(Val(SRA->RA_MAT),6)+';'+;                //  matricula  com 6 posicoos
				SRA->RA_NOME+';'+;                                       //  nome
				matProv+';'+;                                            //  cracha provisorio
				DTOS(SRA->RA_NASC)+';'+;                                 //  data de nascimento
				DTOS(SPE->PE_DATAFIM)+';'+;                              //  data validade
				cEmpAnt                                                  //  Empresa
				grava2(cLin)
			Endif
		Endif

		dbSkip()
		IncProc()
	Enddo
Return
