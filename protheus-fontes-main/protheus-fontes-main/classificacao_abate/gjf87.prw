#INCLUDE "rwmake.ch"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁGJF87     ╨ Autor Ё AP6 IDE            ╨ Data Ё  26/06/09   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao Ё Relatorio de carcaГas nЦo-reservadas para a desossa        ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Qualidade, PCP (SIGAPCP)                                   ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

User Function GJF87()

	alert('Este relatorio deverА ser refeito!')

return

/*
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Declaracao de Variaveis                                             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "que listarА as carcaГas nЦo-reservadas para as     "
Local cDesc3         := "previsУes de produГЦo da desossa"
Local cPict          := ""
Local titulo       := "CarcaГas NЦo-Reservadas para Desossa"
Local nLin         := 80

Local Cabec1       := "Seq. C.Abt C.Ph  Motivo    Status                                | Seq. C.Abt C.Ph  Motivo    Status"
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite           := 132
Private tamanho          := "M"
Private nomeprog         := "GJF87" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18
Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "GJF87" // Coloque aqui o nome do arquivo usado para impressao em disco 
Private cPerg       := "GJF87"

Private cString := "SZK"
pergunte(cPerg,.F.)
dbSelectArea("SZK")
dbSetOrder(6)
DbGoTop()

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta a interface padrao com o usuario...                           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processamento. RPTSTATUS monta janela com a regua de processamento. Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem
Local _lNumam := .f.
Local _dNumam   
Local _cLinha
Local _lLin := 1

dbSelectArea(cString)
SZK->(dbSetOrder(4))

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё SETREGUA -> Indica quantos registros serao processados para a regua Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

SetRegua(RecCount())

SZK->(dbGoTop())
SZK->(DbSeek(xfilial('SZK')+mv_par01))

While SZK->(!EOF()) .and. xfilial('SZK') = SZK->ZK_FILIAL .and. SZK->ZK_NUMAM = mv_par01

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica o cancelamento pelo usuario...                             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

If lAbortPrint
@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
Exit
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Impressao do cabecalho do relatorio. . .                            Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

If nLin > 75 // Salto de PАgina. Neste caso o formulario tem 55 linhas...
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nLin := 9
Endif

if  !empty(SZK->ZK_OPCORT) .and. !empty(SZK->ZK_OPCORD)
SZK->(DbSkip())
loop
endif  

if !_lNumam 
_dNumam := alltrim(dtoc(fBuscaCPO('SZG',1,xfilial('SZG')+SZK->ZK_NUMAM,'ZG_DATA')))
@ nlin,02 psay 'Aviso de MatanГa n.: ' + SZK->ZK_NUMAM
nlin++
@nlin,02 psay 'Data do Aviso:        ' + _dNumam
_lNumam = !_lNumam
nlin += 2
endif 

_cLinha := SZK->ZK_CONTROL + '  ' +  SZK->ZK_CLASABA + '  ' + SZK->ZK_CLASSIF

if SZK->ZK_CLASSIF <> SZK->ZK_CLASABA .and.;
SZK->ZK_DESTINO <> 'G'      .and.;
SZK->ZK_DESTINO <> 'S'      .and.;
SZK->ZK_MATURA <> 'N'
_cLinha += '  Desc. Ph'
else
_cLinha += '          '
endif  

do case
case empty(SZK->ZK_OPCORT) .and. !empty(SZK->ZK_OPCORD)
_cLinha += '  ' + 'Traseiros nЦo-reservados '
case !empty(SZK->ZK_OPCORT) .and. empty(SZK->ZK_OPCORD) 
_cLinha += '  ' + 'Dianteiros nЦo-reservados'
otherwise
_cLinha += '  ' + 'Traseiros e Dianteiros nЦo-reservados'
endcase

if _lLin = 1
@nlin,00 psay _cLinha
_lLin := 2
elseif _lLin = 2
@nlin,65 psay '| '+_cLinha
_lLin := 1
nlin++		
endif

SZK->(dbSkip())
EndDo

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Finaliza a execucao do relatorio...                                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

SET DEVICE TO SCREEN

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se impressao em disco, chama o gerenciador de impressao...          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

If aReturn[5]==1
dbCommitAll()
SET PRINTER TO
OurSpool(wnrel)
Endif

MS_FLUSH()

Return
*/
