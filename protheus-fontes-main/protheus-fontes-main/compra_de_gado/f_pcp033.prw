#INCLUDE "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F_pcp033  º Autor ³ AP6 IDE            º Data ³  24/06/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Pesos por categoria no recebimento                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function F_PCP033()

	Private area := GetArea()

	aCols   := {}   
	aHeader := {}


	SZR->(dbSetOrder(1)) //ZS_FILIAL+ZS_NUMERO+ZS_PLACA+ZS_HORA
	SZR->(dbSeek( xFilial('SZD')+SZD->ZD_NUMERO ) ) 

	//--------------------------------------------------------------//
	//  Prepara a leitura da tabela de peso por categoria           //
	//--------------------------------------------------------------//
	SZR->( dbSetOrder(1) )   // SZS - Cadastro de recebimentos de carcaças por transporte
	// ZS_FILIAL+ZS_NUMERO+ZS_PLACA+ZS_HORA                                                                                                                                    
	SZR->( dbSeek(xFilial('SZR') + SZD->ZD_NUMERO ) )

	If  SZR->( Eof() )

		Aadd( aCols, { Space(10) ,;  // Categoria                                   1
		0,;          // Peso propriedade                            2
		Space(3) ,;  // Rastreado?                                  3
		0,;         // Peso Frigorifico                            4
		.F. } )     // Informa se esta linha do vetor foi deletada  5

	Else
		While !SZR->(Eof()) .AND. SZR->ZR_RECEB == SZD->ZD_NUMERO


			//----------------------------------------//
			// Monta o vetor com os dados cadastrados //
			//----------------------------------------//
			_cCateg := fBuscaCPO('SZ5',1,xfilial('SZ5')+SZR->ZR_CATEG,'Z5_DESC')
			Aadd( aCols, { _cCateg  ,;  
			SZR->ZR_PESO   ,;
			iif(SZR->ZR_RASTRO = 'S','Sim','Nao') ,;  
			SZR->ZR_PESOFRI,; 
			.F. } )     

			SZR->(dbSkip())
		Enddo		
	Endif


	AADD(aHeader,{ "Categoria","ZR_DESC",                "",   10,  0,  ""     ,   " ",  "C",  "SZ5"    } )
	AADD(aHeader,{ "Peso prop","ZR_PESO",   "@e 9,999,999.99",  12,  2,  ""     ,   " ",  "N",  "SZR"    } )
	AADD(aHeader,{ "Rastreado","RASTRO",               "!@",  03,  0,  ""     ,   " ",  "C",      } )
	AADD(aHeader,{ "Peso frig","ZR_PESOFRI","@e 9,999,999.99",  12,  2,  ""     ,   " ",  "N",  "SZR"    } )


	@ 128,55 To 398,597 DIALOG dProd TITLE "Pesos por categoria"
	@ 4,3 To 114,260 MultiLine Modify         
	@ 119,185 BUTTON "_Cancelar" SIZE  36,16 ACTION Close(dProd)
	@ 119,224 BUTTON "_Ok" SIZE  36,16 ACTION Grava()
	ACTIVATE DIALOG dProd CENTERED
	RestArea(area)

Return


Static Function Grava() 
	Local i
	SZR->(DbSetOrder(1))
	SZR->(DbSeek(xfilial('SZR')+SZD->ZD_NUMERO))
	for i := 1 to len(aCols)
		_cCateg   := fBuscacPO('SZ5',2,xfilial('SZ5')+GDFieldGet('ZR_DESC',i),'Z5_COD')
		_cRastro  := iif(GDFieldGet('ZR_RASTRO',i)='Sim','S','N')  
		if SZR->(DbSeek(xfilial('SZR')+SZD->ZD_NUMERO+_cCateg+_cRastro))
			reclock('SZR',.f.)
			SZR->ZR_PESO    := GDFieldGet('ZR_PESO',i)
			SZR->ZR_PESOFRI := GDFieldGet('ZR_PESOFRI',i)
			msunlock()
		endif
	next
	Close(dProd)
