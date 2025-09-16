#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF92   º Autor ³ Giuliano Forgiarini  º Data ³  20/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ R10 - Relatorio de Rastreabilidade - Peças sem destino     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Qualidade e PCP (SIGAPCP)                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF92()

	alert('Este relatorio deverá ser reformulado. Acione o DTI!')


return  

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
Local cDesc2         := "de com destino não definido para fins de conferencia"
Local cDesc3         := " de rastreabilidade e estoque de peças proprias     "
Local cPict          := ""
Local titulo         := "QUARTOS EM ESTOQUE"
Local nLin           := 80                         

Local Cabec1         := "Dados do Aviso de Matança"                   
Local Cabec2         := "  Sequenc. Clas. Peça    Destino          Sequenc. Clas. Peça    Destino          Sequenc. Clas. Peça    Destino"

Local imprime        := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 132
Private tamanho      := "M"
Private nomeprog     := "GJF92" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := "GJF92"
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "GJF92" // Coloque aqui o nome do arquivo usado para impressao em disco    


pergunte(cPerg,.F.)

wnrel := SetPrint('SZK',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)


If nLastKey == 27
Return
Endif

SetDefault(aReturn,'SZK')

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
Local _lLin  := 1  
Local _nT    := 0
Local _nD    := 0
Local nNUMAN 
Local nTESTE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea('SZK')
SZK->(DbSetOrder(6))
SZK->(dbGoTop())
SZK->(DbSeek(xfilial('SZK')+mv_par01)) 

SZK->(SetRegua(RecCount()))

Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nLin := 9 
nNUMAN	:= SZK->ZK_NUMAM
@nlin,02 psay 'Aviso de Matança nr.: ' + nNUMAN
nlin += 2 
/*
//Modificação solicitada adicionar no filtro do lote ao lote

While SZK->(!EOF()) .and. SZK->ZK_FILIAL = xfilial('SZK') .and. SZK->ZK_NUMAM >= mv_par01  .and. SZK->ZK_NUMAM <= mv_par02 

incregua()    
// acrescentado                                                        


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o cancelamento pelo usuario...                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lAbortPrint
@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
Exit
Endif

If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nLin := 9
Endif   
// caso esteja fora do intervalo dos lotes delimitado pula fora
IF (SZK->ZK_LOTE < mv_par04 .or. SZK->ZK_LOTE > mv_par05)
dbskip()
loop
endif


if !empty(mv_par03)
if mv_par02 <> SZK->ZK_CLASSIF
SZK->(DbSkip())
loop	     
endif
endif 
// se dianteiro e traseiro processados pula
if SZK->ZK_PROCD >= 2 .and. SZK->ZK_PROCT >= 2
SZK->(DbSkip())
loop
endif 

if SZK->ZK_PROCD < 2

for i:= 1 to (2 - SZK->ZK_PROCD)
if _lLin = 1
@nlin,02 psay SZK->ZK_CONTROL + '   ' +  SZK->ZK_CLASSIF + '   ' + 'Dianteiro' + '   ' + SZK->ZK_DESTINO
_lLin := 2 
elseif _lLin = 2
@nlin,42 psay SZK->ZK_CONTROL + '   ' +  SZK->ZK_CLASSIF + '   ' + 'Dianteiro' + '   ' + SZK->ZK_DESTINO
_lLin := 3
elseif _lLin = 3
@nlin,82 psay SZK->ZK_CONTROL + '   ' +  SZK->ZK_CLASSIF + '   ' + 'Dianteiro' + '   ' + SZK->ZK_DESTINO
_lLin := 1
nlin++
endif 
_nD++
next
endif		
if SZK->ZK_PROCT < 2   
for i:= 1 to (2 - SZK->ZK_PROCT) 
if _lLin = 1    
@nlin,02 psay SZK->ZK_CONTROL + '   ' +  SZK->ZK_CLASSIF + '   ' + 'Traseiro ' + '   ' + SZK->ZK_DESTINO
_lLin := 2
elseif _lLin = 2
@nlin,42 psay SZK->ZK_CONTROL + '   ' +  SZK->ZK_CLASSIF + '   ' + 'Traseiro ' + '   ' + SZK->ZK_DESTINO
_lLin := 3
elseif _lLin = 3
@nlin,82 psay SZK->ZK_CONTROL + '   ' +  SZK->ZK_CLASSIF + '   ' + 'Traseiro ' + '   ' + SZK->ZK_DESTINO 
_lLin := 1
nlin++
endif 
_nT++
next
endif


SZK->(dbSkip()) // Avanca o ponteiro do registro no arquivo 

EndDo
nlin++
@nlin,02 psay 'Total de Traseiros:  ' + transform(_nT,'@E 9,999')
nlin++
@nlin,02 psay 'Total de Dianteiros: ' + Transform(_nD,'@E 9,999')


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbCloseArea('SZK')

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
