#INCLUDE "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±± Programa   F_pcp034    Autor   3V Ricardo           Data    03/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±± Descricao   Este programa tem por objetivo colher as informações dos   º±±
±±             recebimentos de animais por transporte.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±± Uso         Sigapcp                                                    º±±
±± Parametros: _Num : Número do recebimento.                              º±±
±± Uso         aTrans : Código da transportadora.                         º±±
±± Uso         Sigapcp                                                    º±±
±± Uso         Sigapcp                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function F_PCP034()

	Private nVlPsFri := 0
	Private area := GetArea()
	Private onde
	Private aCateg  := {}
	Private aVeic   := {}

	aCols   := {}
	aHeader := {}



	//Carrega Veiculos por Recebimento
	SZS->(dbSetOrder(1)) //ZS_FILIAL+ZS_NUMERO+ZS_PLACA+ZS_HORA
	SZS->(dbSeek( xFilial('SZD')+SZD->ZD_NUMERO ) ) 

	While !SZS->(Eof()) .AND. (SZS->ZS_NUMERO == SZD->ZD_NUMERO)
		Aadd( aVeic, { SZS->ZS_PLACA,;
		SZS->ZS_MOTOR,;
		SZS->ZS_VEIC,;
		SZS->ZS_DESTPTR,;
		SZS->ZS_QTANIM,;
		SZS->ZS_DCHPREV,;
		SZS->ZS_DASFPR,;
		SZS->ZS_VAVE,;     
		SZS->ZS_PESOFRI,;
		SZS->ZS_HORA,;
		.F. } )
		SZS->( dbSkip() )
	Enddo

	If Empty(SZD->ZD_NUMERO)
		msgbox("Nº Recebimento inválido! O número é obrigatório.")
		return
	elseif Empty(SZD->ZD_TRANSP)
		msgbox("Código da transportadora inválido! O código é obrigatório.")
		return
	endif

	//--------------------------------------------------------------//
	//  Se a matriz estiver cheia, então estamos entrando neste     //
	//  programa pela segunda vez e já tem algo digitado. Neste     //
	//  caso precisamos recuperar.                                  //
	//--------------------------------------------------------------//

	//--------------------------------------------------------------//
	//  Prepara a leitura da tabela de recebimentos por veículo     //
	//--------------------------------------------------------------//
	SZS->( dbSetOrder(1) )   // SZS - Cadastro de recebimentos de carcaças por transporte
	// ZS_FILIAL+ZS_NUMERO+ZS_PLACA+ZS_HORA                                                                                                                                    
	SZS->( dbSeek(xFilial('SZS') + SZD->ZD_NUMERO ) )

	If  SZS->( Eof() )

		Aadd( aCols, { Space(7),;  // Nº Placa do veículo                          1
		Space(40),; // Nome do motorista                            2
		Space(2),;  // Código do tipo do veículo                    3
		Space(30),; // Nome do tipo de veículo                      4
		0,;         // Número de animais neste veículo.             5
		0,;         // Distância prevista para estrada sem asfalto  6
		0,;         // Distância prevista para estrada com asfalto  7
		0.00,;      // Valor do frete para este veículo		       8        
		0.00,;      // Peso Frigorifico                             9
		Space(5),;  // Hora de recebimento                          10
		.F. } )     // Informa se esta linha do vetor foi deletada  11

	Else
		While !SZS->(Eof()) .AND. SZS->ZS_NUMERO == SZD->ZD_NUMERO

			//---------------------------------------//
			// Apanha a descrição do tipo do veiculo //
			//---------------------------------------//

			//SX5->( dbSeek( xFilial('SX5')+ 'Z3' + SZS->ZS_VEIC ) )
			//_nVeic := SX5->X5_DESCRI 

			_nVeic := Alltrim(FWGetSX5("Z3", SZS->ZS_VEIC)[1][4])

			//----------------------------------------//
			// Monta o vetor com os dados cadastrados //
			//----------------------------------------//
			Aadd( aCols, { SZS->ZS_PLACA,;    // Nº Placa do veículo                            1
			SZS->ZS_MOTOR,;    // Nome do motorista                              2
			SZS->ZS_VEIC,;     // Código do tipo do veículo                      3
			_nveic,;           // Nome do tipo de veículo (Char,18)              4
			SZS->ZS_QTANIM,;   // Número de animais neste veículo.               5
			SZS->ZS_DCHPREV,;  // Distância prevista para estrada sem asfalto    6
			SZS->ZS_DASFPR,;   // Distância prevista para estrada com asfalto    7
			SZS->ZS_VAVE,;     // Valor do frete para este veículo               8
			SZS->ZS_PESOFRI,;  // Peso Frigorifico                               9
			SZS->ZS_HORA,;     // Hora                                          10
			.F. } )            // Informa se esta linha do vetor foi deletada   11

			SZS->(dbSkip())
		Enddo		
	Endif



	//-----------------------------------------//
	// Monta o cabeçalho do grid e os formatos //
	// de display dos dados.                   //                 	
	//-----------------------------------------//
	AADD(aHeader,{ "Placa",           "ZS_PLACA",                "@!",   07,  0,                             "", " ",  "C",  "SZS"   } )
	AADD(aHeader,{ "Motorista",       "ZS_MOTOR",                "@!",   40,  0,                             "", " ",  "C",  "SZS"   } )
	AADD(aHeader,{ "Tipo Veic. ",      "ZS_VEIC",                "@!",   02,  0,                "U_At_TPVeic()", " ",  "C",  "SZS"   } )
	AADD(aHeader,{ "Descrição",     "ZS_DESTPTR",                  "",   18,  0,                              "", " ",  "C",  "SZS"   } )
	AADD(aHeader,{ "Qt.Animais",     "ZS_QTANIM",        "@E 999,999",   04,  0,                              "", " ",  "N",  "SZS"   } )
	AADD(aHeader,{ "Dist.Chão(Km)", "ZS_DCHPREV",     "@E 999,999.99",   08,  2,		                      "", " ", "N",  "SZS"   } )
	AADD(aHeader,{ "Dist.Pavm(Km)",  "ZS_DASFPR",     "@E 999,999.99",   08,  2, 			                  "", " ", "N",  "SZS"   } )
	AADD(aHeader,{ "Valor Frete",      "ZS_VAVE", "@E 999,999,999.99",   12,  2,                              "", " ", "N",  "SZS"   } )
	AADD(aHeader,{ "Peso Frigor",   "ZS_PESOFRI", "@E 999,999,999.99",   12,  2,                              "", " ", "N",  "SZS"   } )
	AADD(aHeader,{ "Hora chegada",     "ZS_HORA",             "99:99",   05,  0,                              "", " ", "C",  "SZS"   } )


	@ 128,55 To 398,597 DIALOG dProd TITLE "Recebimentos por Veículo"
	@ 4,3 To 114,260 MultiLine modify Valid OkValid()
	@ 119,224 BUTTON "_Ok" SIZE  36,16 ACTION Grava()
	@ 119,180 BUTTON "_Cancelar" SIZE  36,16 ACTION Close(dProd)
	ACTIVATE DIALOG dProd CENTERED
	RestArea(area)



//--------------------------------------------------------//
// Função de validação dos dados cadastrados no grid.     //
//--------------------------------------------------------//
Static Function OkValid() 
Return .T.

//      Empty(aCols[ix,6])   // Número de animais neste veículo.
//
//
//--------------------------------------------------//
// Função que Apanha a descrição do tipo do veiculo //
//--------------------------------------------------//

User Function At_TPVeic()
	Private ret
	ret  := .F.   
	SZH->( dbSetOrder(2) )
	SZH->( dbSeek(xFilial('SZH') + SZD->ZD_TRANSP + M->ZS_VEIC ) )
	If SZH->( found() )
		//SX5->( dbSeek( xFilial('SX5')+ 'Z3' + M->ZS_VEIC ) ) 
		//aCols[n,4] := SX5->X5_DESCRI         // n é variável reservada de aCols e indica a posição atual do cursor
		aCols[n,4] := Alltrim(FWGetSX5("Z3", M->ZS_VEIC)[1][4])
		ret := .T.
	Endif

Return ret 


Static Function Grava() 
	Local i
	SZS->(DbSetOrder(1))
	SZS->(DbSeek(xfilial('SZS')+SZD->ZD_NUMERO))
	for i := 1 to len(aCols)
		_cPlaca := GDFieldGet('ZS_PLACA',i)
		_cHora  := GDFieldGet('ZS_HORA',i) 
		if SZS->(DbSeek(xfilial('SZS')+SZD->ZD_NUMERO+_cPlaca+_cHora))
			reclock('SZS',.f.)
			SZS->ZS_DCHPREV := GDFieldGet('ZS_DCHPREV',i)
			SZS->ZS_DASFPR  := GDFieldGet('ZS_DASFPR',i)
			SZS->ZS_MOTOR   := GDFieldGet('ZS_MOTOR',i)
			SZS->ZS_VEIC    := GDFieldGet('ZS_VEIC',i)
			SZS->ZS_VAVE    := GDFieldGet('ZS_VAVE',i)
			SZS->ZS_DESTPTR := GDFieldGet('ZS_DESTPTR',i)
			SZS->ZS_PESOFRI := GDFieldGet('ZS_PESOFRI',i)
			msunlock()
		endif
	next
	Close(dProd)

Return
