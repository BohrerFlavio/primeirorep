#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF15     º Autor ³Giuliano Forgiarini º Data ³  04/06/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Relatório de reatreabilidade - produção da desossa          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF15()

	alert('Este relatório deverá ser reformulado!. Acione o DTI!')

return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de rastreabilidade indicando a produção na entrada "
Local cDesc3         := "da desossa com as carcaças desossadas com rastro.  "
Local cPict          := ""
Local titulo       := "RASTREABILIDADE III - Entrada da Desossa"
Local nLin         := 80

Local Cabec1       := "Data P.:  Rastro:                Peça:            Des.: Or.: Peso:    Hora:"
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite           := 80
Private tamanho          := "P"
Private nomeprog         := "GJF15" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18
Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey        := 0
Private cPerg       := "GJF15"
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "GJF15" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := "SC2"

pergunte(cPerg,.F.)



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
Return
Endif

SetDefault(aReturn,cString)

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

Local nOrdem

dbSelectArea(cString)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetRegua(RecCount())

SC2->(dbsetorder(11))
SC2->(dbGoTop())
SC2->(dbseek(xfilial()+mv_par01,.t.))
item := SC2->C2_ITEM
// Salto de Página. Neste caso o formulario tem 55 linhas...
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nlin := 8

flag3 := .f.
while SC2->(!eof()) .and. (SC2->C2_NUMAM = mv_par01)
if SC2->C2_NUM < mv_par02 .or. SC2->C2_NUM > mv_par03
SC2->(dbskip())
loop
endif
Tp   := 0
peso := 0
DI   := 0
TR   := 0
TNE  := 0
TEX  := 0
TRA  := 0
THK  := 0
TCH  := 0
DNE  := 0
DEX  := 0
DRA  := 0
DHK  := 0
DCH  := 0
PTL := 0
PTE := 0
PD  := 0
dia := ""
mes := ""
ano := ""
abate := ""
rastro := ""
if SC2->C2_ITEM != item
SC2->(DBSKIP())
loop
endif

op := SC2->C2_NUM
SZN->(dbsetorder(5))
SZN->(dbgotop())
SZN->(dbseek(xfilial()+op,.t.))
flag1 := .f.

while SZN->(!eof()) .and. (SZN->ZN_NUMCOR = op)
incregua()
do case
case mv_par04 = 1
if SZN->ZN_PARTE = "D"
SZN->(dbskip())
loop
endif
case mv_par04 = 2
if SZN->ZN_PARTE = "T"
SZN->(dbskip())
loop
endif
endcase
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o cancelamento pelo usuario...                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lAbortPrint
@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
Exit
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do cabecalho do relatorio. . .                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nLin := 8
Endif

if flag1 = .f.
nlin++
@nlin,05 psay "OP N.: "+op
@nlin,20 psay "Destino: "+SZN->ZN_EXPORT
@nlin,35 psay "Gerada em: "+transform(SC2->C2_EMISSAO,"@E ##/##/##") + "    " + "Aviso: " + SC2->C2_NUMAM
flag1 := .t.
nlin := nlin + 2
endif
dAbate   := dtos(Posicione("SZG", 1, xFilial("SZG") + SC2->C2_NUMAM, "ZG_DATA")) 
datAbate := substr(dAbate,7,2)+substr(dAbate,5,2)+substr(dAbate,3,2)
@nlin,00 psay SZN->ZN_DATA
@nlin,10 psay "1733" + datAbate + "0000" + substr(SZN->ZN_RASTRO,15,6)

if SZN->ZN_PARTE = "T"
TR++
if SZN->ZN_TPTRASE = "E"
@nlin,33 psay "Traseiro Estreito"
PTE := PTE + SZN->ZN_PESOP
else
@nlin,33 psay "Traseiro Largo"
PTL := PTL + SZN->ZN_PESOP
endif
else
@nlin,33 psay "Dianteiro"
PD := PD + SZN->ZN_PESOP
DI++
endif
seq := substr(SZN->ZN_RASTRO,15,6)
clas   := Posicione("SZK", 6, xFilial("SZK") + mv_par01 + seq, "ZK_CLASSIF")
@nlin,51 psay AllTrim(clas)
@nlin,56 psay SZK->ZK_LOCAL
if SZN->ZN_PARTE = "T"
do case
case AllTrim(clas) ="NE"
TNE++
case AllTrim(clas) ="EX"
TEX++
case AllTrim(clas) ="HK"
THK++
case AllTrim(clas) ="RA"
TRA++
case AllTrim(clas) ="CH"
TCH++
endcase
else
do case
case AllTrim(clas) ="NE"
DNE++
case AllTrim(clas) ="EX"
DEX++
case AllTrim(clas) ="HK"
DHK++
case AllTrim(clas) ="RA"
DRA++
case AllTrim(clas) ="CH"
DCH++
endcase
endif

@nlin,60 psay SZN->ZN_PESOP picture '@E 999.99'
@nlin,69 psay SZN->ZN_HORA
nLin++ // Avanca a linha de impressao
Tp++
peso += SZN->ZN_PESOP
flag3 := .t.
SZN->(dbSkip()) // Avanca o ponteiro do registro no arquivo)EndDo

enddo
if flag3 = .t.
Cabec1:= '------------------------ RESUMO DA PRODUÇÃO DA DESOSSA --------------------------'
Cabec(Titulo,Cabec1,'',NomeProg,Tamanho,nTipo)
nLin := 10
@nlin,05 psay "N. Peças:...................................................   "+Transform(Tp,"@E ###,###")
nlin++
@nlin,05 psay "Peso Total:................................................."+transform(peso,"@E ###,###.##")
nlin += 2
if mv_par04 != 2
@nlin,05 psay "N. Traseiros.................................................."+Transform(TR,"@E ####,###")
nlin++
if PTL !=0
@nlin,05 psay "Peso Total Traseiro L:......................................"+Transform(PTL,"@E ###,###.##")
nlin++
endif
if PTE != 0
@nlin,05 psay "Peso Total Traseiro E......................................."+Transform(PTE,"@E ###,###.##")
nlin++
endif
if TNE != 0
@nlin,010 psay "Traseiros NE:.........................................."+transform(TNE,"@E #,###")
nlin++
endif
if THK != 0
@nlin,10 psay "Traseiros HK:..........................................."+transform(THK,"@E #,###")
nlin++
endif
if TRA != 0
@nlin,10 psay "Traseiros RA:..........................................."+transform(TRA,"@E #,###")
nlin++
endif
if TCH != 0
@nlin,10 psay "Traseiros CH:..........................................."+transform(TCH,"@E #,###")
nlin++
endif
nlin++
endif
if mv_par04 != 1
@nlin,05 psay "N. Dianteiros :................................................"+Transform(DI,"@E ###,###")
nlin++
@nlin,05 psay "Peso Total Dianteiros:......................................"+Transform(PD,"@E ###,###.##")
nlin++
if DNE != 0
@nlin,10 psay "Dianteiros NE:.........................................."+transform(DNE,"@E #,###")
nlin++
endif

if DHK != 0
@nlin,10 psay "Dianteiros HK:.........................................."+transform(DHK,"@E #,###")
nlin++
endif
if DRA != 0
@nlin,10 psay "Dianteiros RA:.........................................."+transform(DRA,"@E #,###")
nlin++
endif
if DCH != 0
@nlin,10 psay "Dianteiros CH:.........................................."+transform(DCH,"@E #,###")
nlin++
endif
nlin++
endif
endif
///////////////// APURAÇÃO DIÁRIA
_cQuery := "SELECT COUNT(ZN_ORDEM)AS CONT,ZN_DATA AS DAT,SUM(ZN_PESOP)AS PESO,ZN_PARTE AS PARTE,ZN_TPTRASE AS TPTRASE" +;
" FROM "+RetSqlName("SZN")+" SZN " +;
" WHERE SZN.D_E_L_E_T_ <> '*' " +;
" AND SZN.ZN_NUMCOR =  " + op   +;
" GROUP BY ZN_DATA,ZN_PARTE,ZN_TPTRASE" +;
" ORDER BY ZN_DATA,ZN_PARTE,ZN_TPTRASE"
_cQuery := ChangeQuery(_cQuery)

//	* Mostrar a consulta */
//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
//Activate Dialog oDlgMemo

/*
If Select("DSO")<>0
DSO->(dbCloseArea())
Endif
TCQUERY _cQuery NEW ALIAS "DSO"
dia := ''
nlin++

@nlin,00 psay '---------------------------------------------------------------------------------'
nlin++  
@nlin,01 psay 'PRODUCAO POR DIA:'
@nlin,45 psay 'Quant.'
@nlin,55 psay 'Kg.'
nlin++ 
@nlin,00 psay '---------------------------------------------------------------------------------'
nlin += 2

while DSO->(!eof())
if mv_par04 = 1
if parte = 'D'
DSO->(dbskip())
loop
endif
endif

if mv_par04 = 2
if parte = 'T'
DSO->(dbskip())
loop
endif
endif

if dia != DSO->DAT
@nlin,01 psay STOD(DSO->DAT)
dia := DSO->DAT
endif
if parte == 'D'
@nlin,13 psay 'Dianteiro'
else
@nlin,13 psay 'Traseiro'
endif
do case
case parte = 'T' .and. tptrase = 'L'
@nlin,28 psay 'Largo'
case parte = 'T' .and. tptrase = 'E'
@nlin,28 psay 'Estreito'
case parte = 'T' .and. (tptrase != 'E' .and. tptrase != 'L')
@nlin,28 psay 'S/Classif.'
end case
@nlin,40 psay cont picture '@E 999,999'
@nlin,50 psay peso picture '@E 999,999.99'
nlin++

DSO->(dbskip())
enddo
DSO->(dbclosearea())
dbselectarea('SC2')
///////////////////// FIM DA APURAÇÃO DIÁRIA

SC2->(dbskip())

enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
dbCommitAll()
SET PRINTER TO
OurSpool(wnrel)
Endif

MS_FLUSH()

Return
*/
