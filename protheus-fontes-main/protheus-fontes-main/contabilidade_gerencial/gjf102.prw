#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGJF102    บ Autor ณ Giuliano Forgiariniบ Data ณ  28/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Aplica o codigo de reten็ใo aos tํtulos TX                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCP/SIGAOMS                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function GJF102()
	local nOpca	:=0
	local aSays:={}, aButtons:={}

	Private cCadastro := "Ajuste de C๓digos de Reten็ใo para Titulos TX"
	Private aCampos := {} 
	Private aStru   := {}
	Private _nCaixDev := 0
	Private _nCaixRet := 0       
	Private _nCaixInv := 0
	Private _nCaixTot := 0
	Private cPerg := "GJF102"

	AADD (aSays, "  Esta rotina tem como objetivo realizar o ajuste em titulos do   ")  //
	AADD (aSays, "  tipo TX na tabela SE2 (Contas a Pagar) aplicando a estes o      ")  //
	AADD (aSays, "  codigo correto de reten็ใo com base no campo E2_TITPAI.          ")  //


	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. ) } } )
	FormBatch( cCadastro, aSays, aButtons )
	If nopca == 1  
		Processa({||Ajuste()},"AJUSTE DO CODIGO DE RETENวรO","Realizando ajuste na tabela SE2...")  
	endif

return 

Static Function Ajuste()

	Local _cForn    := ''
	Local _cCodRet  := ''
	Local _cNaturez := ''

	cQuery := " SELECT COUNT(*) AS QUANT" +;
	" FROM "+RetSqlName("SE2")+" SE2"+;
	" WHERE " +;
	" (SE2.E2_EMISSAO BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' " + ") AND "+;
	" SE2.D_E_L_E_T_ <> '*' AND "+;
	" SE2.E2_FILIAL = '" + xFilial( "SE2" ) + "' " 

	cQuery := ChangeQuery(cQuery)

	//    * Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("DIRF") != 0
		DIRF->(dbCloseArea())
	Endif


	TCQUERY cQuery NEW ALIAS "DIRF"



	SE2->(DbSetOrder(5))
	SE2->(DbGoTop())
	SE2->(DbSeek(xfilial('SE2')+dtos(mv_par01),.t.))

	ProcRegua(DIRF->QUANT) 

	While SE2->(!eof()) .and. SE2->E2_FILIAL = xfilial('SE2') .and. SE2->E2_EMISSAO <= mv_par02  

		incproc() 

		if SE2->E2_TIPO <> 'TX' .or. SE2->E2_DIRF <> '1' .or. empty(SE2->E2_TITPAI)
			SE2->(DbSkip())
			loop
		endif  

		_cForn    := substr(SE2->E2_TITPAI,17,8)
		_cCodRet  := fBuscaCPO('SA2',1,xfilial('SA2')+_cForn,'A2_CODRET')  
		_cNaturez := alltrim(SE2->E2_NATUREZ) 

		if !empty(_cCodRet)

			if _cNaturez $ '120315/120309/120311/120312' 
				_cCodRet := '5952'
			endif

			reclock('SE2',.f.)
			SE2->E2_CODRET := _cCodRet
			msunlock()

		else
			SE2->(DbSkip())
			loop	
		Endif

		SE2->(DbSkip())
	enddo	     


Return





