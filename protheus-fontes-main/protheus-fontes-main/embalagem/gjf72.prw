#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF72  ºAutor  ³Giuliano Forgiarini º Data ³  12/01/09      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de Exclusão de Caixas                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF72()

	lOk         := .f.
	oDesc       := '' 
	vNumPrev    := ''

	Private cCadastro := "Controle de Caixas e Manutenção de Estoque"
	Private aRotina := { {"Pesquisar","AxPesqui"    ,0,1} ,;
	{"Excluir"  ,"u_gjf72exc"  ,0,4}}     

	private cString := "ZZ9"   

	SetKey(123,{|| posicao()}) // Seta a tecla F12 para acionamento dos parametros

	dbSelectArea(cString)
	ZZ9->(dbSetOrder(1))

	SET FILTER TO ZZ9->ZZ9_DATA = DATE() .and. ZZ9->ZZ9_FILIAL = xfilial('ZZ9')

	mBrowse( 6, 1, 22, 75,cString,,,,,,)

	Set Key 123 To 																	// Desativa a tecla F12 do acionamento dos parametros

	DbCloseArea('ZZ9')   

Return

static function posicao()                                                        //Cria a caixa de diálogo para localizar uma caixa
	cCaixa := space(10)
	DEFINE MSDIALOG oDlg2 TITLE 'Localizar Caixa:' from 000,000 To 100,250 OF oMainWnd PIXEL
	@ 010,003 SAY  'Numero:' Object oSay1
	@ 010,025 GET cCaixa PICTURE "@!"   SIZE 40,11  VALID preenche() Object oCaixa
	@ 010,80 BMPBUTTON TYPE 1 ACTION posicao2() Object Obtn1
	@ 025,80 BMPBUTTON TYPE 2 ACTION odlg2:end() Object Obtn2
	ACTIVATE MSDIALOG oDlg2
return

static function posicao2()

	odlg2:end()
	ZZ9->(dbsetorder(3)) 

	if !(ZZ9->(dbseek(xfilial('ZZ9') + cCaixa,.t.)))
		msgbox('Caixa não encontrada!','OPERAÇÃO INCONSISTENTE!','ERRO')
	elseif ZZ9->ZZ9_DATA <> date()
		msgbox('Esta caixa não pertence a produção do dia!','OPERAÇÃO INVÁLIDA!','STOP')
		return .t.
	endif
return

static function preenche()                                                      //Função que preeche o codigo do produto com zeros
	if !empty(alltrim(cCaixa))
		cCaixa := padl(alltrim(cCaixa),10,"0")
	endif
return .t.

User Function gjf72exc()
	SZU->(dbsetorder(2))
	SZU->(dbseek(xfilial('SZU')+ZZ9->ZZ9_NUMPRE))
	//para descontar a quantidade já produzida na previsão de produção 


	if SZU->ZU_FECHADO == 'S' 
		u_gjf32(ZZ9->ZZ9_NUMPRE,'R') // função criada para realizar as movimentações internas (SD3)
	endif  

	reclock('SZU',.f.)     
	SZU->ZU_FECHADO := 'N'
	SZU->ZU_QRPESO := SZU->ZU_QRPESO - SZ8->Z8_PESO
	SZU->ZU_QRCAIX := SZU->ZU_QRCAIX - 1
	msunlock()

	SZ8->(dbsetorder(3))
	SZ8->(dbseek(xfilial('SZ8')+ZZ9->ZZ9_CONTRO))

	u_gjf17his(2,'EXCLUSAO DA PRODUCAO',.f.,'','','000011',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)  

	reclock('ZZ9',.f.)
	dbdelete()
	msunlock()   

	reclock('SZ8',.f.)
	SZ8->Z8_DATAE := date()
	SZ8->Z8_HORAE := time()
	msunlock() 

	reclock('SZ8',.f.)
	dbdelete()
	msunlock()   

	msgbox('Caixa excluída!','OPERAÇÃO REALIZADA!','INFO')  		
return .t.
