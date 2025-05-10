#INCLUDE "protheus.ch"

//----------------------------------------
//Teste de FWWizardControl
//----------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} tstwiz
Exemplo básico de uso das classes FWWizardControl e FWWizardStep
Este exemplo foi desenvolvido utilizando como base 
no exemplo disponível no TDN (links comentados no início do código)

 

@author Pedro Lima
@since 29/07/2015
@version 12.1.7
/*/
//-------------------------------------------------------------------
User Function tstwiz()
Local oPanel
Local oSize := Nil
Local oStepWiz := Nil
Local oNewPag := Nil

 

//Link da classe FWWizardControl no TDN
// http://tdn.totvs.com/display/framework/FWWizardControl
//Link da classe FWWizardStep no TDN
// http://tdn.totvs.com/display/framework/FWWizardStep
//Informações adicionais sobre métodos e parâmetros podem ser obtidas através dos links acima

 

oStepWiz := FWWizardControl():New(,{600,800})//Instancia a classe FWWizard (
oStepWiz:ActiveUISteps()

//----------------------
// Pagina 1
//----------------------
oNewPag := oStepWiz:AddStep("1") //Altera a descrição do step
oNewPag:SetStepDescription("Início") //Define o título do "step"
oNewPag:SetConstruction({|Panel|cria_pg1(Panel)}) //Define o bloco de construção
oNewPag:SetNextTitle("Próximo") //Define o texto do botão de avanço
oNewPag:SetNextAction({||.T.}) //Define o bloco ao clicar no botão Próximo
oNewPag:SetCancelAction({||.T.}) //Define o bloco ao clicar no botão Cancelar

//----------------------
// Pagina 2
//----------------------
oNewPag := oStepWiz:AddStep("2", {|Panel|cria_pg2(Panel)})
oNewPag:SetStepDescription("Seleção de layouts")
oNewPag:SetNextTitle("Próximo")
oNewPag:SetNextAction({||.T.})
oNewPag:SetCancelAction({||.T.}) 
oNewPag:SetPrevAction({||.T.}) //Define o bloco ao clicar no botão Voltar
oNewPag:SetPrevTitle("Voltar")

//----------------------
// Pagina 3
//----------------------
oNewPag := oStepWiz:AddStep("3", {|Panel|cria_pn3(Panel)})
oNewPag:SetStepDescription("Seleção de clientes")
oNewPag:SetNextTitle("Próximo")
oNewPag:SetNextAction({||.T.})
oNewPag:SetPrevAction({||.T.})
oNewPag:SetPrevTitle("Voltar")
oNewPag:SetCancelAction({||.T.})

 

//----------------------
// Pagina 4
//----------------------
oNewPag := oStepWiz:AddStep("4", {|Panel|cria_pn4(Panel)})
oNewPag:SetStepDescription("Seleção de títulos")
oNewPag:SetNextTitle("Próximo")
oNewPag:SetNextAction({||.T.})
oNewPag:SetPrevAction({||.T.})
oNewPag:SetPrevTitle("Voltar")
oNewPag:SetCancelAction({||.T.})

 

//----------------------
// Pagina 5
//----------------------
oNewPag := oStepWiz:AddStep("5", {|Panel|cria_pn5(Panel)})
oNewPag:SetStepDescription("Envio das Cartas")
oNewPag:SetNextTitle("Próximo")
oNewPag:SetNextAction({||.T.})
oNewPag:SetPrevAction({||.T.})
oNewPag:SetPrevTitle("Voltar")
oNewPag:SetCancelAction({||.T.})

 

//----------------------
// Pagina 6
//----------------------
oNewPag := oStepWiz:AddStep("6", {|Panel|cria_pn6(Panel)})
oNewPag:SetStepDescription("Fim")
oNewPag:SetNextTitle("Concluir")
oNewPag:SetNextAction({||.T.})
oNewPag:SetPrevAction({||.T.})
oNewPag:SetPrevTitle("Voltar")
oNewPag:SetCancelAction({||.T.})
oNewPag:SetCancelWhen({||.F.})

 

oStepWiz:Activate()

 

oStepWiz:Destroy()

 

Return

 


//--------------------------------------------------------------------
// Início dos blocos de construçãos das páginas de cada step
//--------------------------------------------------------------------

 

//--------------------------
// Construção da página 1
//--------------------------
Static Function cria_pg1(oPanel)
Local oNo := LoadBitmap( GetResources(), "LBNO" )
Local oOk := LoadBitmap( GetResources(), "LBTIK" )
Local oLbxWiz
Local cLstBx
Local oChkTWiz
Local lChkTWiz := .F.
Local oChkIWiz
Local lChkIWiz := .F.
Local aWiz := {{.F.,"010203","MATRIX TOLDOS","UNI","000000255","01","NF","15/04/2015","153,10"},;
{.F.,"010203","MATRIX TOLDOS","UNI","000000310","05","NF","16/05/2015","215,33"},;
{.F.,"010203","MATRIX TOLDOS","UNI","000000316","","DP","20/05/2015","3.000,00"},;
{.F.,"010005","CONFECÇÔES LINHA FINA","SFG","000000441","01","NF","14/01/2015","233,00"},;
{.F.,"010005","CONFECÇÔES LINHA FINA","SFG","000000393","01","NF","17/02/2015","149,85"},;
{.F.,"010005","CONFECÇÔES LINHA FINA","SFG","000000394","02","NF","17/03/2015","149,85"},;
{.F.,"010005","CONFECÇÔES LINHA FINA","SFG","000000395","03","NF","17/04/2015","149,85"},;
{.F.,"032210","SHANGTSUNG ELETRONICS","ASP","000001025","01","DP","14/04/2015","445,00"},;
{.F.,"032210","SHANGTSUNG ELETRONICS","ASP","000001073","","DP","25/04/2015","1.025,66"},;
{.F.,"001233","ACME DEMOLIÇÕES","BUM","000000123","06","NF","30/03/2015","2.780,50"},;
{.F.,"045322","TABAJARA EMPREENDIMENTOS","CCD","000000112","01","NF","16/01/2015","115,00"},;
{.F.,"045322","TABAJARA EMPREENDIMENTOS","CCD","000000113","01","NF","16/02/2015","160,00"},;
{.F.,"003104","BEBIDAS CLONINHO LTDA","ARG","000000171","01","NF","16/01/2015","15,65"},;
{.F.,"003104","BEBIDAS CLONINHO LTDA","ARG","000000171","02","NF","16/02/2015","15,65"},;
{.F.,"003104","BEBIDAS CLONINHO LTDA","ARG","000000171","03","NF","16/03/2015","15,65"},;
{.F.,"003104","BEBIDAS CLONINHO LTDA","ARG","000000171","04","NF","16/04/2015","15,65"},;
{.F.,"003104","BEBIDAS CLONINHO LTDA","ARG","000000171","05","NF","16/05/2015","15,65"}}

 

@ 001,001 LISTBOX oLbxWiz FIELDS HEADER "","Cód. Cliente","Nome Cliente","Prefixo","Número","Parcela","Tipo","Vencimento","Valor" SIZE 400,190;
ON DBLCLICK (aWiz[oLbxWiz:nAt,1] := !aWiz[oLbxWiz:nAt,1],If(!aWiz[oLbxWiz:nAt,1],lChkTWiz := .F., ),oLbxWiz:Refresh(.f.),ApSxVerChk(@lChkTWiz,@aWiz,@oLbxWiz,@oChkTWiz));
OF oPanel PIXEL

 

oLbxWiz:SetArray(aWiz) 
oLbxWiz:bLine := {|| {If(aWiz[oLbxWiz:nAt,1],oOK,oNO),aWiz[oLbxWiz:nAt,2],;
aWiz[oLbxWiz:nAt,3],;
aWiz[oLbxWiz:nAt,4],;
aWiz[oLbxWiz:nAt,5],;
aWiz[oLbxWiz:nAt,6],;
aWiz[oLbxWiz:nAt,7],;
aWiz[oLbxWiz:nAt,8],;
aWiz[oLbxWiz:nAt,9]}}

 

oLbxWiz:bRClicked := { || AEVAL(aWiz,{|x|x[1]:=!x[1]}),oLbxWiz:Refresh(.F.) }
oLbxWiz:bLDblClick := { || aWiz[oLbxWiz:nAt,1] := !aWiz[oLbxWiz:nAt,1],If(!aWiz[oLbxWiz:nAt,1],lChkTWiz := .F., ),oLbxWiz:Refresh(.f.),ApSxVerChk(@lChkTWiz,@aWiz,@oLbxWiz,@oChkTWiz) }

 

@ 195,020 CHECKBOX oChkTWiz VAR lChkTWiz PROMPT "Marcar Todos" SIZE 62, 10 OF oPanel PIXEL 
oChkTWiz:blClicked := {|| AEval( aWiz,{|x,y| x[1] := lChkTWiz , If(lChkTWiz, (lChkIWiz := .F.,oChkIWiz:Refresh()), )})} 
@ 195,100 CHECKBOX oChkIWiz VAR lChkIWiz PROMPT "Inverter Marca" SIZE 62, 10 OF oPanel PIXEL 
oChkIWiz:blClicked := {|| AEval( aWiz,{|x,y| x[1] := !x[1]}), lChkTWiz := (Ascan(aWiz,{|x|!x[1]}) == 0), oChkTWiz:Refresh()}

 

Return

 


//--------------------------
// Construção da página 2
//--------------------------
Static Function cria_pg2(oPanel)

 

Return


//--------------------------
// Construção da página 3
//--------------------------
Static Function cria_pn3(oPanel)

 

Return

 

//--------------------------
// Construção da página 4
//--------------------------
Static Function cria_pn4(oPanel)

 

Return

 

//--------------------------
// Construção da página 5
//--------------------------
Static Function cria_pn5(oPanel)
Local oFont
Local oSay

 

oFont:= TFont():New(,,-25,.T.,.T.,,,,,)

 

oSayTop := TSay():New(10,15,{|| "Envio de Cartas de Cobrança"},oPanel,,oFont,,,,.T.,CLR_BLUE,)
oSayBottom1 := TSay():New(35,10,{|| "Clique em 'Próximo' para efetivar o envio das cartas, conforme as seleções efetuadas anteriormente"},oPanel,,,,,,.T.,CLR_BLUE,)

 

Return

 

//--------------------------
// Construção da página 6
//--------------------------
Static Function cria_pn6(oPanel)
Local oBtnLog

 

oFont:= TFont():New(,,-25,.T.,.T.,,,,,)
// Apresenta o tSay com a fonte Courier New
oSayTop := TSay():New(10,15,{|| "Envio de Cartas de Cobrança efetuado com sucesso"},oPanel,,oFont,,,,.T.,CLR_BLUE,)
oSayBottom1 := TSay():New(35,10,{|| "Consulte o log de envio para mais detalhes"},oPanel,,,,,,.T.,CLR_BLUE,)

 

oBtnLog := TButton():New(180,330, "Log de Envio",oPanel,{||Alert("Log de Processo")}, 60,20,,,.F.,.T.,.F.,,.F.,,,.F. )

 

Return

 

//Fim do exemplo de uso das classe FWWizardControl e FWWizardStep
