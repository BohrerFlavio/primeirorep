#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "Fileio.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FBF50  ºAutor  ³Flávio Bohrer Flôres   º Data ³  08/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ajuste de Base das  Refeições                              º±±
±±º          ³ Para dias em feriado e  Lanches de Sábado                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FBF50()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := ""
	Local cDesc2         := " "
	Local cDesc3         := ""
	Local cPict          := ""
	Local titulo         := "Ajuste de Refeições"
	Local nLin           := 80

	Local Cabec1       := " "

	Local Cabec2       := " "

	Local imprime      := .T.
	Local aOrd := {}   
	Private lEnd         		:= .F.
	Private lAbortPrint  		:= .F.
	Private CbTxt        		:= ""
	Private limite           	:= 80
	Private tamanho          	:= "M"
	Private nomeprog         	:= "FBF50" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            	:= 18
	Private aReturn          	:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        	:= 0
	Private cPerg   				:= "FBF50"

	Private wnrel      		:= "FBF50" // Coloque aqui o nome do arquivo usado para impressao em disco    


	pergunte(cPerg,.F.)

	wnrel := SetPrint('SP5',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  


	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SP5')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	/* Ajuste de Feriados	    */
	if MV_PAR02 = 1 

		ajuste(mv_par01,1)	  	 
	elseif mv_par02 = 2/* Ajuste Lanches    */

		ajuste(mv_par01,2)	  	 
	endif

	Alert("** Processo Finalisado **")	

Return

// Função que ajusta refeições dos Feriados
Static Function ajuste(_dData,_nTipo)
	Local _cTipoRef := '01'
	Local _cValRef  := 0
	Local _cRelogio := '04'  

	DbSelectArea('SP5')
	SP5->(dbgotop())
	SP5->(dbsetorder(1))

	if _nTipo = 1           // Refeição feriados

		while SP5->(!eof())

			if SP5->P5_TIPOREF = '01'  .AND. SP5->P5_DATA = _dData

				reclock('SP5',.f.)
				SP5->P5_TIPOREF  := '03'
				SP5->P5_RELOGIO  := _cRelogio
				SP5->P5_DESCFUN  := _cValRef
				SP5->P5_GERAFOL  := 'N'
				SP5->P5_PD		 := '908'
				SP5->P5_PDEMPR   := '707'
				msunlock()

			endif
			SP5->(dbskip())

		enddo

	elseif _nTipo = 2 // lanche sábado 

		while SP5->(!eof())

			if SP5->P5_TIPOREF = '03'  .AND. SP5->P5_DATA = _dData	

				if (P5_HORA >= 4 .AND. P5_HORA <= 9 ).or.( P5_HORA >= 14.31 .AND. P5_HORA <= 18 )

					reclock('SP5',.f.)
					SP5->P5_TIPOREF := '04' //(03 para 04)
					P5_PD 			:= '912' //(de 908 para 912) 
					SP5->P5_PDEMPR 	:= '707'
					P5_VALREF  		:= 2 //(valor de 5.53 para 2.00)
					P5_DESCFUN 		:= 2 //(valor de 0.00  para 2.00)
					SP5->P5_GERAFOL := 'S'
					P5_RELOGIO 		:= '03' //(04 para 03)
					msunlock()
				endif	
			endif
			SP5->(dbskip())

		enddo
	endif

	DbCloseArea('SP5')

Return     
