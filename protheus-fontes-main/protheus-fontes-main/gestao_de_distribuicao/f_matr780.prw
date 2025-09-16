//#INCLUDE "MATR780.CH"

User Function f_Matr780()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Define Variaveis                                             ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
LOCAL wnrel
LOCAL tamanho:= "M"
LOCAL titulo := OemToAnsi("Cliente x Produto")	//"Estatisticas de Vendas (Cliente x Produto)"
LOCAL cDesc1 := OemToAnsi("Este programa ira emitir a relacao das compras efetuadas pelo Cliente")	//"Este programa ira emitir a relacao das compras efetuadas pelo Cliente,"
LOCAL cDesc2 := OemToAnsi("totalizando por produto e escolhendo a moeda forte para os Valores")	//"totalizando por produto e escolhendo a moeda forte para os Valores."
LOCAL cDesc3 := ""
LOCAL cString:= "SD2"

PRIVATE aReturn := { OemToAnsi("Zebrado"), 1,OemToAnsi("Administracao"), 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nomeprog:="MATR780"
PRIVATE nLastKey := 0
PRIVATE cPerg   := "MR780A"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Verifica as perguntas selecionadas                           ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
pergunte(cPerg,.F.)

titulo := "ESTATISTICAS DE VENDAS (Cliente X Produto)"	//"ESTATISTICAS DE VENDAS (Cliente X Produto)"
Cabec1 := "CLIENTE   RAZAO SOCIAL"	//"CLIENTE   RAZAO SOCIAL"
Cabec2 := "PRODUTO             DESCRICAO                  NOTA FISCAL EMISSAO     QUANTIDADE   PRECO UNITARIO            TOTAL VENDEDOR"	//"PRODUTO             DESCRICAO                  NOTA FISCAL EMISSAO     QUANTIDADE   PRECO UNITARIO            TOTAL VENDEDOR"
// 123456789012345 123456789012345678901234567890 123456/123 12/12/1234 123456789012 1234567890123456 1234567890123456 123456/123456/123456/123456/123456

wnrel:="MATR780"

wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.T.)

If nLastKey==27
	dbClearFilter()
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	dbClearFilter()
	Return
Endif

RptStatus({|lEnd| C780Imp(@lEnd,wnRel,cString)},Titulo)

Return

Static Function C780Imp(lEnd,WnRel,cString)

LOCAL CbTxt
LOCAL CbCont,cabec1,cabec2,cabec3
LOCAL nTotCli1:= 0,nTotCli2:=0,nTotGer1 := 0,nTotGer2 := 0
LOCAL nTotFam1:= 0,nTotFam2:=0
LOCAL nOrdem
LOCAL tamanho:= "M"
LOCAL limite := 132
LOCAL titulo := OemToAnsi("ESTATISTICAS DE VENDAS (Cliente X Produto)")	//"ESTATISTICAS DE VENDAS (Cliente X Produto)"
LOCAL cDesc1 := OemToAnsi("Este programa ira emitir a relacao das compras efetuadas pelo Cliente,")	//"Este programa ira emitir a relacao das compras efetuadas pelo Cliente,"
LOCAL cDesc2 := OemToAnsi("totalizando por produto e escolhendo a moeda forte para os Valores.")	//"totalizando por produto e escolhendo a moeda forte para os Valores."
LOCAL cDesc3 := ""
LOCAL cMoeda
LOCAL nAcN1  := 0, nAcN2 := 0, nV := 0
LOCAL cClieAnt := "", cProdAnt := ""
LOCAL lContinua := .T. , lProcessou := .F. , lNewProd := .T.
LOCAL cMascara :=GetMv("MV_MASCGRD")
LOCAL nTamRef  :=Val(Substr(cMascara,1,2))
LOCAL nTamLin  :=Val(Substr(cMascara,4,2))
LOCAL nTamCol  :=Val(Substr(cMascara,7,2))
LOCAL cProdRef :=""
LOCAL nTotQuant:=0
LOCAL nReg     :=0
LOCAL cFiltro  := ""
Local cEstoq := IIf( (mv_par13 == 1),"S",IIf( (mv_par13 == 2),"N","SN" ))
Local cDupli := IIf( (mv_par14 == 1),"S",IIf( (mv_par14 == 2),"N","SN" ))
Local cArqTrab1, cArqTrab2, cCondicao1
Local aDevImpr := {}
Local cVends   := ""
Local nVend    := FA440CntVend()
Local nDevQtd 	:=0
Local nDevVal 	:=0
Local aDev		:={}
Local nIndD2    :=0
Local cQuery, aStru
Local lNfD2Ori   := .F.
#IFDEF TOP
	Local nj := 0
#ENDIF
Private cSD1, cSD2
Private nIndD1  :=0
Private nDecs:=msdecimais(mv_par09)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Seleciona ordem dos arquivos consultados no processamento    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
SF1->(dbsetorder(1))
SF2->(dbsetorder(1))
SB1->(dbSetOrder(1))
SA7->(dbSetOrder(2))

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Monta o Cabecalho de acordo com o tipo de emissao            ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
titulo := "ESTATISTICAS DE VENDAS (Cliente X Produto)"	//"ESTATISTICAS DE VENDAS (Cliente X Produto)"
Cabec1 := "CLIENTE  RAZAO SOCIAL"	//"CLIENTE  RAZAO SOCIAL"
Cabec2 := "PRODUTO             DESCRICAO                       NOTA FISCAL      EMISSAO    QUANTIDADE    PRECO UNITARIO          TOTAL"	//"PRODUTO             DESCRICAO                       NOTA FISCAL      EMISSAO    QUANTIDADE    PRECO UNITARIO          TOTAL"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Variaveis utilizadas para Impressao do Cabecalho e Rodape    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

cMoeda := "Valores em"+GetMV("MV_SIMB"+Str(mv_par09,1))		//"Valores em "
titulo := titulo+" "+cMoeda

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Cria filtro para impressao das devolucoes                    ?
//?*** este filtro possui 208 posicoes  ***                     ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
dbSelectArea("SD1")
cArqTrab1  := CriaTrab( "" , .F. )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Query para SQL                 ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cSD1   := "SD1TMP"
aStru  := dbStruct()
AADD( aStru, { "B1_FAM","C",3,0 } )
cQuery := " SELECT SD1.*,B1_FAM FROM " + RetSqlName("SD1") + " SD1 ,"+RetSqlName("SB1") + " SB1 ," + RetSqlName("SA2") + " SA2 "
cQuery += " WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND "
cQuery += " SA2.A2_FILIAL = '"+xFilial("SA2")+"' AND "
cQuery += " SD1.D1_FORNECE BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' AND "
cQuery += " SD1.D1_DTDIGIT BETWEEN '"+DtoS(mv_par03)+"' AND '"+DtoS(mv_par04)+ "' AND "
cQuery += " SD1.D1_COD BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' AND "
cQuery += " SD1.D1_COD  = SB1.B1_COD AND "
cQuery += " SD1.D1_FORNECE  = SA2.A2_COD AND "
cQuery += " SD1.D1_LOJA  = SA2.A2_LOJA AND "
cQuery += " SD1.D1_TIPO = 'D' AND "
cQuery += " (SB1.B1_FAM BETWEEN '"+mv_par18+"' AND '"+mv_par19+ "') AND "
if !empty(mv_par21)
	cQuery += " SA2.A2_EST = '"+mv_par21+"' AND "
endif
If mv_par22 == 1  
	cQuery += " SUBSTRING(SB1.B1_GRUPO,1,2) <> '56'  AND "
ElseIf mv_par22 == 2
	cQuery += " SUBSTRING(SB1.B1_GRUPO,1,2) = '56'  AND "
Endif
cQuery += "  NOT ("+IsRemito(3,'SD1.D1_TIPODOC')+ ") AND "
cQuery += " SD1.D_E_L_E_T_ <> '*' AND "
cQuery += " SA2.D_E_L_E_T_ <> '*' AND "
cQuery += " SB1.D_E_L_E_T_ <> '*'  "
cQuery += " ORDER BY SD1.D1_FILIAL,SD1.D1_FORNECE,SB1.B1_FAM,SA2.A2_EST,SD1.D1_COD"
cQuery := ChangeQuery(cQuery)
testey := cQuery
MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'SD1TRB', .F., .T.)},OemToAnsi("Selecionado registros...")) //"Selecionado registros"
For nj := 1 to Len(aStru)
	If aStru[nj,2] != 'C'
		TCSetField('SD1TRB', aStru[nj,1], aStru[nj,2],aStru[nj,3],aStru[nj,4])
	EndIf
Next nj
A780CriaTmp(cArqTrab1, aStru, cSD1, "SD1TRB")
IndRegua(cSD1,cArqTrab1,"D1_FILIAL+D1_FORNECE+B1_FAM+D1_COD",,".T.","Selecionando Registros...")		//"Selecionando Registros..."


dbSeek(xFilial("SD1"))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Monta filtro para processar as vendas por cliente            ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
DbSelectArea("SD2")
cFiltro := SD2->(dbFilter())
If Empty(cFiltro)
	bFiltro := { || .T. }
Else
	cFiltro := "{ || " + cFiltro + " }"
	bFiltro := &(cFiltro)
Endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Monta filtro para processar as vendas por cliente            ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cArqTrab2  := CriaTrab( "" , .F. )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Query para SQL                 ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cSD2   := "SD2TMP"
aStru  := dbStruct()
AADD( aStru, { "B1_FAM","C",3,0 } )
cQuery := " SELECT SD2.*,B1_FAM FROM " + RetSqlName("SD2") + " SD2 ,"+ RetSqlName("SB1") + " SB1 ," + RetSqlName("SA1") + " SA1 "
cQuery += " WHERE SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "
cQuery += " SA1.A1_FILIAL ='" + xFilial("SA1") +"' AND"
cQuery += " (SD2.D2_CLIENTE BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') AND "
cQuery += " (SD2.D2_EMISSAO BETWEEN '"+DTOS(mv_par03)+"' AND '"+DTOS(mv_par04)+"') AND "
cQuery += " (SD2.D2_COD     BETWEEN '"+ mv_par05+"' AND '"+mv_par06+"') AND "
cQuery += " SD2.D2_COD      = SB1.B1_COD AND "
cQuery += " SD2.D2_CLIENTE  = SA1.A1_COD AND "
cQuery += " SD2.D2_LOJA     = SA1.A1_LOJA AND "
cQuery += " SB1.B1_FAM BETWEEN '"+mv_par18+"' AND '"+mv_par19+ "' AND "

If !empty(mv_par21)
	cQuery += " SA1.A1_EST = '"+mv_par21+"'  AND "
endif
If mv_par22 == 1  
	cQuery += " SUBSTRING(SB1.B1_GRUPO,1,2) <> '56'  AND "
ElseIf mv_par22 == 2
	cQuery += " SUBSTRING(SB1.B1_GRUPO,1,2) = '56'  AND "
Endif
cQuery += " SD2.D2_TIPO <> 'B' AND SD2.D2_TIPO <> 'D' AND "
cQuery += " NOT ("+IsRemito(3,'SD2.D2_TIPODOC')+ ") AND "
cQuery += " SD2.D_E_L_E_T_ <> '*' AND "
cQuery += " SA1.D_E_L_E_T_ <> '*' AND "
cQuery += " SB1.D_E_L_E_T_ <> '*'  "
cQuery += " ORDER BY SD2.D2_FILIAL,SD2.D2_CLIENTE, SB1.B1_FAM,SA1.A1_EST,SD2.D2_COD,SD2.D2_ITEM"
cQuery := ChangeQuery(cQuery)
testex := cQuery

MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),'SD2TRB', .F., .T.)},OemToAnsi("Selecionado Registros")) 	//"Seleccionado registros"
For nj := 1 to Len(aStru)
	If aStru[nj,2] != 'C'
		TCSetField('SD2TRB', aStru[nj,1], aStru[nj,2],aStru[nj,3],aStru[nj,4])
	EndIf
Next nj


A780CriaTmp(cArqTrab2, aStru, cSD2, "SD2TRB")
IndRegua(cSD2,cArqTrab2,"D2_FILIAL+D2_CLIENTE+B1_FAM+D2_COD+D2_SERIE+D2_DOC+D2_ITEM",,".T.","Selecionando Registros...")//"Selecionando Registros..."


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Verifica se aglutinara produtos de Grade                     ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
SetRegua(RecCount())		// Total de Elementos da regua

If ( (cSD2)->D2_GRADE=="S" .And. MV_PAR12 == 1)
	lGrade := .T.
	bGrade := { || Substr((cSD2)->D2_COD, 1, nTamref) }
Else
	lGrade := .F.
	bGrade := { || (cSD2)->D2_COD }
Endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?Procura pelo 1o. cliente valido                              ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial()+mv_par01, .t.)

While SA1->( ! EOF() .AND. A1_COD <= MV_PAR02 ) .AND. lContinua .AND. SA1->A1_FILIAL == xFilial("SA1") 
    
    xCli := SA1->A1_COD
    While !Eof() .AND. xFilial('SA1')==SA1->A1_FILIAL .AND. SA1->A1_COD == xCli
       dbSkip()
    Enddo
    dbSkip(-1)// ultima loja do cliente
	
	If lEnd
		@Prow()+1,001 Psay "Cancelado pelo operador"	//"CANCELADO PELO OPERADOR"
		lContinua := .F.
		Exit
	EndIf
	
	lNewCli := .T.
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//?Procura pelas saidas daquele cliente                     ?
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	DbSelectArea(cSD2)
	If DbSeek(xFilial("SD2")+SA1->A1_COD)
		lRet:=ValidMasc((cSD2)->D2_COD,MV_PAR11)
		
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//?Montagem da quebra do relatorio por  Cliente             ?
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		cClieAnt := SA1->A1_COD
		
		lNewProd := .T.
		lNewCli  := .T.
		nTotCli1 := 0
		nTotCli2 := 0
		
		While !Eof() .and. ;
			((cSD2)->(D2_FILIAL+D2_CLIENTE)) == (xFilial("SD2")+cClieAnt) 
			//+cLojaAnt) - rps
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//?Verifica Se eh uma tipo de nota valida                   ?
			//?Verifica intervalo de Codigos de Vendedor                ?
			//?Valida o produto conforme a mascara                      ?
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			lRet:=ValidMasc((cSD2)->D2_COD,MV_PAR11)
			If	! Eval(bFiltro) .Or. !A780Vend(@cVends,nVend) .Or. !lRet //.or. SD2->D2_TIPO$"BD" ja esta no filtro
				dbSkip()
				Loop
			EndIf
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//?Impressao do Cabecalho.                                  ?
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If Li > 55
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
				lProcessou := .T.
			EndIf
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//?Impressao da quebra por familia silva                    ?
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			cFamAnt := (cSD2)->B1_FAM
			lNewFam := .T.
			nTotFam1 := 0
			nTotFam2 := 0
			
			While ! Eof() .And. ;
				(cSD2)->(D2_FILIAL + D2_CLIENTE +  B1_FAM ) == ;
				( xFilial("SD2") + cClieAnt   +  cFamAnt )
				IncRegua()
				
				
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
				//?Impressao da quebra por produto e NF                     ?
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
				cProdAnt := (cSD2)->D2_COD
				lNewProd := .T.
				
				While ! Eof() .And. ;
					(cSD2)->(D2_FILIAL + D2_CLIENTE + B1_FAM + D2_COD  ) == ;
					( xFilial("SD2") + cClieAnt +  cFamAnt  +  cProdAnt )
					
					IncRegua()
					
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
					//?Avalia TES                                               ?
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
					lRet:=ValidMasc((cSD2)->D2_COD,MV_PAR11)
					If !AvalTes((cSD2)->D2_TES,cEstoq,cDupli) .Or. !Eval(bFiltro) .Or. !lRet
						dbSkip()
						Loop
					Endif
					
					If !A780Vend(@cVends,nVend)
						dbskip()
						Loop
					Endif
					
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
					//?Impressao  dos dados do Cliente                          ?
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
					If lNewCli
						
						If Li > 51
							cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
							lProcessou := .T.
						EndIf
						
						@ Li,000 Psay Repli('-',132)
						Li++
						@ Li,000 Psay (cSD2)->D2_CLIENTE+"   "+SA1->A1_NOME
						If !Empty(SA1->A1_OBSERV)
							Li++
							@ Li,000 Psay "Obs.: "+SA1->A1_OBSERV		//"Obs.: "
						EndIf
						Li++
						lNewCli := .F.
					Endif
					
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
					//?Impressao do Cabecalho.                                  ?
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
					If li > 55
						cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
						@ Li,000 Psay Repli('-',132)
						Li++
						@ Li,000 Psay (cSD2)->D2_CLIENTE+"   "+SA1->A1_NOME
						If !Empty(SA1->A1_OBSERV)
							Li++
							@ Li,000 Psay "Obs.: "+SA1->A1_OBSERV		//"Obs.: "
						EndIf
						Li+=2
					EndIf
					
					
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
					//?Impressao  do nome da familia silva                      ?
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
					If lNewFam
						If Li > 51
							cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
							lProcessou := .T.
						EndIf
						
						@ Li,000 Psay Repli('-',132)
						Li++
						@ Li,000 Psay 'Fam:'+(cSD2)->B1_FAM+"-"+LEFT(POSICIONE("SX5",1,XFILIAL("SX5")+'PS'+(cSD2)->B1_FAM,"X5_DESCRI"),10)
						Li++
						lNewFam := .F.
					Endif
					
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
					//?Faz Impressao de Codigo e Descricao Do Produto.          ?
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
					If lNewProd
						lNewProd := .F.
						Li+=2
						@Li ,  0 Psay Eval(bGrade)
						SB1->(dbSeek(xFilial("SB1")+(cSD2)->D2_COD))
						If mv_par16 = 1
							@li , 16 Psay Substr(SB1->B1_DESC,1,30)
						Else
							If SA7->(dbSeek(xFilial("SA7")+(cSD2)->(D2_COD+D2_CLIENTE+D2_LOJA)))
								@li , 16 Psay Substr(SA7->A7_DESCCLI,1,30)
							Else
								@li , 16 Psay Substr(SB1->B1_DESC,1,30)
							Endif
						EndIf
					EndIf
					
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
					//?Tratamento das devolucoes   ?
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
					nDevQtd :=0
					nDevVal :=0
					
					If mv_par10 == 1 //inclui Devolucoes
						SomaDev(@nDevQtd, @nDevVal , @aDev)
					EndIf
					
					nTotQuant := (cSD2)->D2_QUANT
					
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
					//?Imprime os dados da NF                                   ?
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
				
					if mv_par20 == 1
						SF2->(dbSeek(xFilial("SF2")+(cSD2)->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)))
						@Li , 48 Psay (cSD2)->(D2_DOC+'/'+D2_SERIE)
						@Li , 65 Psay (cSD2)->D2_EMISSAO
						@Li , 76 Psay nTotQuant          PICTURE PesqPictqt("D2_QUANT",12)
					endif
					
					nAcN1 += nTotQuant
					
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
					//?Faz Verificacao da Moeda Escolhida e Imprime os Valores  ?
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
					nVlrUnit := xMoeda((cSD2)->D2_PRCVEN,SF2->F2_MOEDA,MV_PAR09,(cSD2)->D2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
					if mv_par20 == 1
						@Li , 89 Psay nVlrUnit           PICTURE PesqPict("SD2","D2_PRCVEN",16,mv_par09)
					endif
					
					If (cSD2)->D2_TIPO $ "CIP"
						if mv_par20 == 1
							@Li ,106 Psay nVlrUnit        PICTURE PesqPict("SD2","D2_TOTAL",16,mv_par09)
						endif
						nAcN2 += nVlrUnit
					Else
						If (cSD2)->D2_GRADE == "S" .And. MV_PAR12 == 1 // Aglutina Grade
							nVlrTot:= nVlrUnit * nTotQuant
							if mv_par20 == 1
								@Li ,106 Psay nVlrTot         PICTURE PesqPict("SD2","D2_TOTAL",16,mv_par09)
							endif
						Else
							//
							nVlrTot:=xmoeda((cSD2)->D2_TOTAL,SF2->F2_MOEDA,mv_par09,(cSD2)->D2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
							if mv_par20 == 1
								@Li ,106 Psay nVlrTot         PICTURE PesqPict("SD2","D2_TOTAL",16,mv_par09)
							endif
						EndIf
						nAcN2 += nVlrTot
					EndIf
					
					A780Vend(@cVends,nVend)
					if mv_par20 ==1
						@Li, 123 Psay Subs(cVends,1,7)
						For nV := 8 to Len(cVends)
							li ++
							@Li, 105 Psay Subs(cVends,nV,27)
							nV += 27
						Next
					endif
					
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
					//?Imprime as devolucoes do produto selecionado             ?
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
					If nDevQtd!=0
						Li++
						@Li,053 Psay "DEV" // "DEV"
						nVlrTot:= nDevVal
						@Li,076 Psay nDevQtd          PICTURE "@)"+PesqPictqt("D2_QUANT",12)
						@Li,106 Psay nVlrTot          PICTURE "@)"+PesqPict("SD2","D2_TOTAL",16,mv_par09)
						nAcN1+= nDevQtd
						nAcN2+= nVlrTot
					EndIf
					if mv_par20 == 1
						Li++
					endif
					nTotQuant := 0
					dbSkip()
					
				EndDo
				
				
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
				//?Acumula o total por familia                              ?
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
				nTotFam1 += nAcN1
				nTotFam2 += nAcN2
				
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
				//?Acumula o total geral do relatorio                       ?
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
				nTotGer1 += nAcN1
				nTotGer2 += nAcN2
				
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
				//?Acumula o total por cliente                              ?
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
				nTotCli1 += nAcN1
				nTotCli2 += nAcN2
				
				
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
				//?Imprime o total do produto selecionado                   ?
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
				If nAcN1#0 .Or. nAcN2#0	.Or. nDevQtd#0
					Li++
					@Li ,  07 Psay "Total do Produto - "+cProdAnt	//"TOTAL DO PRODUTO - "
					@Li ,  52 Psay "---->"
					@Li ,  76 Psay nAcN1 PICTURE PesqPictqt("D2_QUANT",12)
					@Li , 106 Psay nAcN2 PICTURE PesqPict("SD2","D2_TOTAL",16,mv_par09)
					nAcN1 := 0
					nAcN2 := 0
					cProdAnt := (cSD2)->D2_COD
				EndIf
				
				
			Enddo
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//?Imprime o total da familia                               ?
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If nTotFam1#0 .Or. nTotFam2#0
				Li+=2
				@Li ,  00 Psay "TOTAL DA FAMILIA  - "+cFamAnt
				@Li ,  52 Psay "---->"
				@Li ,  76 Psay nTotFam1 PICTURE PesqPictqt("D2_QUANT",12)
				@Li , 106 Psay nTotFam2 PICTURE PesqPict("SD2","D2_TOTAL",16,mv_par09)
				li+=2
			EndIf
			
			
		EndDo
		
		
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//?Ocorreu quebra por cliente                               ?
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		If !(lNewCli)
			LI+=2
			@Li , 07 Psay "Total do Cliente - "+cClieAnt	//"TOTAL DO CLIENTE - "
			@Li , 52 Psay "---->"
			@Li , 76 Psay nTotCli1 PICTURE PesqPictqt("D2_QUANT",16)
			@Li ,104 Psay nTotCli2 PICTURE PesqPict("SD2","D2_TOTAL",18,mv_par09)
			LI++
		EndIf
		cClieAnt := ""
		
		nTotCli1 := 0
		nTotCli2 := 0
		
	EndIf
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	//?Procura pelas devolucoes dos clientes que nao tem NF SAIDA  ?
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	nTotCli1 := 0
	nTotCli2 := 0
	
	DbSelectArea(cSD1)
	If DbSeek(xFilial("SD1")+SA1->A1_COD+SA1->A1_LOJA)
		lRet:=ValidMasc((cSD1)->D1_COD,MV_PAR11)
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//?Procura as devolucoes do periodo, mas que nao pertencem  ?
		//?as NFS ja impressas do cliente selecionado               ?
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		If mv_par10 == 1  // Inclui Devolucao
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴커
			//?Soma Devolucoes          ?
			//읕컴컴컴컴컴컴컴컴컴컴컴컴켸
			While (cSD1)->(D1_FILIAL + D1_FORNECE + D1_LOJA) == ;
				( xFilial("SD1") + SA1->A1_COD+ SA1->A1_LOJA)  .AND. ! Eof()
				lRet:=ValidMasc((cSD1)->D1_COD,MV_PAR11)
				
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
				//?Verifica Vendedores da N.F.Original ?
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
				
				dbSelectArea("SD2")
				nSavOrd := IndexOrd()
				dbSetOrder(3)
				CtrlVndDev := .F.
				lNfD2Ori   := .F.
				
				dbSeek(xFilial("SD2")+(cSD1)->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD))
				While !Eof() .And. (xFilial("SD2")+(cSD1)->(D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD)) == ;
					D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD
					
					lRet:=ValidMasc((cSD1)->D1_COD,MV_PAR11)
					
					If !Empty((cSD1)->D1_ITEMORI) .AND. AllTrim((cSD1)->D1_ITEMORI) != D2_ITEM .Or. !lRet .Or. !Eval(bFiltro)
						dbSkip()
						Loop
					Else
						CtrlVndDev := A780Vend(@cVends,nVend)
						If Ascan(aDev,D2_CLIENTE + D2_LOJA + D2_COD + D2_DOC + D2_SERIE + D2_ITEM) > 0
							lNfD2Ori := .T.
						EndIf
					Endif
					dbSkip()
				End
				
				dbSetOrder(nSavOrd)
				dbSelectArea(cSD1)
				
				If !(CtrlVndDev) .Or. lNfD2Ori
					dbSkip()
					Loop
				EndIf
				
				lProcessou := .t.
				
				If li > 55
					cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
				EndIf
				
				If lNewCli
					
					If li > 51
						cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
					EndIf
					
					@ Li,000 Psay Repli('-',132)
					
					Li++
					@ Li,000 Psay SA1->A1_COD
					@ Li,009 Psay SA1->A1_NOME
					If !Empty(SA1->A1_OBSERV)
						Li++
						@ Li,000 Psay "Obs.: "+SA1->A1_OBSERV		//"Obs.: "
					EndIf
					
					Li+=2
					
					lNewCli := .F.
					
				EndIf
				
				LI++
				SF1->(dbSeek(xFilial("SF1")+(cSD1)->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)))
				@Li ,  0 Psay (cSD1)->D1_COD
				@li , 16 Psay "DEV" //"DEV"
				@Li , 48 Psay (cSD1)->(D1_DOC+'/'+D1_SERIE) // VERIFICAR PORQUE -
				nVlrTot:=xMoeda((cSD1)->(D1_TOTAL-D1_VALDESC),SF1->F1_MOEDA,mv_par09,(cSD1)->D1_DTDIGIT,nDecs,SF1->F1_TXMOEDA)
				@Li,076 Psay -(cSD1)->D1_QUANT PICTURE "@)"+PesqPictqt("D1_QUANT",12)
				@Li,106 Psay -nVlrTot           PICTURE "@)"+PesqPict("SD1","D1_TOTAL",16,mv_par09)
				nTotCli1 -= (cSD1)->D1_QUANT
				nTotCli2 -= nVlrTot
				nTotGer1 -= (cSD1)->D1_QUANT
				nTotGer2 -= nVlrTot
				
				dbSkip()
			EndDo
			
			If (nTotCli1 != 0) .or. (nTotCli2 != 0)
				LI+=2
				@Li , 07 Psay "TOTAL DO CLIENTE - "+SA1->A1_COD	//"TOTAL DO CLIENTE - "
				@Li , 52 Psay "---->"
				@Li , 76 Psay nTotCli1 PICTURE "@)"+PesqPictqt("D2_QUANT",16)
				@Li ,104 Psay nTotCli2 PICTURE "@)"+PesqPict("SD2","D2_TOTAL",18,mv_par09)
			EndIf
			
		EndIf
		
	Endif
	
	
	DbSelectArea("SA1")
	DbSkip()
EndDo

If lProcessou
	If li > 55
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	EndIf
	Li+=2
	@Li , 07 Psay "T O T A L  G E R A L         ---->"		//"T O T A L   G E R A L                        ---->"
	@Li , 76 Psay nTotGer1 PICTURE "@)"+PesqPictqt("D2_QUANT",16)
	@Li ,104 Psay nTotGer2 PICTURE "@)"+PesqPict("SD2","D2_TOTAL",18,mv_par09)
	roda(cbcont,cbtxt,tamanho)
Endif

dbSelectArea("SD1")
dbClearFilter()
RetIndex("SD1")

dbSelectArea("SD2")
dbClearFilter()
RetIndex("SD2")

(cSD1)->(DbCloseArea())
(cSD2)->(DbCloseArea())
fErase(cArqTrab1+OrdBagExt())
fErase(cArqTrab2+OrdBagExt())
#IFDEF TOP
	fErase(cArqTrab1+GetDbExtension())
	fErase(cArqTrab2+GetDbExtension())
#ENDIF

If aReturn[5] = 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
EndIf

MS_FLUSH()

Return .T.

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽?
굇?un뇚o    ?A780Vend ?Autor ?Rogerio F. Guimaraes  ?Data ?28.10.97 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙?
굇?escri뇚o ?Verifica Intervalo de Vendedores                           낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙?
굇?Uso      ?MATR780			                                          낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽?
/*/
Static Function A780Vend(cVends,nVend)
Local cAlias:=Alias(),sVend,sCampo
Local lVend, cVend, cBusca
Local nx
lVend  := .F.
cVends := ""
// Nao tem Alias na frente dos campos do SD2 para poder trabalhar em DBF e TOP
cBusca := xFilial("SF2")+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA
dbSelectArea("SF2")
If dbSeek(cBusca)
	cVend := "1"
	For nx := 1 to nVend
		sCampo := "F2_VEND" + cVend
		sVend := FieldGet(FieldPos(sCampo))
		If !Empty(sVend)
			cVends += IIf(Len(cVends)>0,"/","") + sVend
		EndIf
		If sVend >= mv_par07 .And. sVend <= mv_par08
			lVend := .T.
		EndIf
		cVend := Soma1(cVend, 1)
	Next
EndIf
dbSelectArea(cAlias)
Return(lVend)

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽?
굇?un뇚o    ?SomaDev  ?Autor ?Claudecino C Leao     ?Data ?28.09.98 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙?
굇?escri뇚o ?Soma devolucoes de Vendas                                  낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙?
굇?Uso      ?MATR780			                                          낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽?
/*/
Static Function SomaDev(nDevQtd, nDevVal, aDev )

Local DtMoedaDev  := (cSD2)->D2_EMISSAO

If (cSD1)->(dbSeek(xFilial("SD1")+(cSD2)->(D2_CLIENTE + D2_LOJA + D2_COD )))
	//旼컴컴컴컴컴컴컴컴컴컴컴컴커
	//?Soma Devolucoes          ?
	//읕컴컴컴컴컴컴컴컴컴컴컴컴켸
	While (cSD1)->(D1_FILIAL+D1_FORNECE+D1_LOJA+D1_COD) == (cSD2)->( xFilial("SD2")+D2_CLIENTE+D2_LOJA+D2_COD).AND.!(cSD1)->(Eof())
		
		DtMoedaDev  := IIF(MV_PAR17 == 1,(cSD1)->D1_DTDIGIT,(cSD2)->D2_EMISSAO)
		
		SF1->(dbSeek(xFilial("SF1")+(cSD1)->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)))
		
		If (cSD1)->(D1_NFORI + D1_SERIORI + AllTrim(D1_ITEMORI)) == (cSD2)->(D2_DOC   + D2_SERIE   + D2_ITEM )
			
			Aadd(aDev, (cSD1)->(D1_FORNECE + D1_LOJA + D1_COD + D1_NFORI + D1_SERIORI + AllTrim(D1_ITEMORI)))
			nDevQtd -= (cSD1)->D1_QUANT
			nDevVal -=xMoeda((cSD1)->(D1_TOTAL-D1_VALDESC),SF1->F1_MOEDA,mv_par09,DtMoedaDev,nDecs+1,SF1->F1_TXMOEDA)
			
		ElseIf mv_par15 == 2 .And. (cSD1)->D1_DTDIGIT < (cSD2)->D2_EMISSAO .And.;
			(cSD1)->(D1_NFORI + D1_SERIORI + AllTrim(D1_ITEMORI)) < ;
			(cSD2)->(D2_DOC   + D2_SERIE   + D2_ITEM ) .And.;
			Ascan(aDev, (cSD1)->(D1_FORNECE + D1_LOJA + D1_COD + D1_NFORI + D1_SERIORI + AllTrim(D1_ITEMORI))) == 0
			
			Aadd(aDev, (cSD1)->(D1_FORNECE + D1_LOJA + D1_COD + D1_NFORI + D1_SERIORI + AllTrim(D1_ITEMORI)))
			nDevQtd -= (cSD1)->D1_QUANT
			nDevVal -=xMoeda((cSD1)->(D1_TOTAL-D1_VALDESC),SF1->F1_MOEDA,mv_par09,DtMoedaDev,nDecs+1,SF1->F1_TXMOEDA)
			
		EndIf
		
		(cSD1)->(dbSkip())
		
	EndDo
	
EndIf
Return .t.
/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커굇
굇?uncao    ?780CriaTmp?Autor ?Rubens Joao Pante     ?Data ?04/07/01 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑굇
굇?escri뇚o ?ria temporario a partir da consulta corrente (TOP)          낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?Uso      ?ATR780 (TOPCONNECT)                                         낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽*/
Static Function A780CriaTmp(cArqTmp, aStruTmp, cAliasTmp, cAlias)
Local nI, nF, nPos
Local cFieldName := ""
Local _aArqTrb      := {} // ProcData 04/2023

nF := (cAlias)->(Fcount())

// ProcData 04/2023 - Chamada para criacao do arquivo de trabalho
U_ArqTrb("Cria", cArqTmp, cAliasTmp, {}, @_aArqTrb)	
	
//dbCreate(cArqTmp,aStruTmp)
//DbUseArea(.T.,,cArqTmp,cAliasTmp,.T.,.F.)

(cAlias)->(DbGoTop())
While ! (cAlias)->(Eof())
	(cAliasTmp)->(DbAppend())
	For nI := 1 To nF
		cFieldName := (cAlias)->( FieldName( ni ))
		If (nPos := (cAliasTmp)->(FieldPos(cFieldName))) > 0
			(cAliasTmp)->(FieldPut(nPos,(cAlias)->(FieldGet((cAlias)->(FieldPos(cFieldName))))))
		EndIf
	Next
	(cAlias)->(DbSkip())
End
(cAlias)->(dbCloseArea())
DbSelectArea(cAliasTmp)
Return Nil



/*/--------------------
PS: Tabela de familias silva
