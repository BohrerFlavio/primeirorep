#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  GJF160     º Autor ³ Giuliano Forgiariniº Data ³  10/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Tela de auxilio a manutenção do cadastro de clientes para  º±±
±±º          ³ agilidade no processo                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Financeiro                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF160()

	private  _ItRisc     := CTBCBOX('A1_RISCO') 
	private  _cRisc      := SA1->A1_RISCO
	private  _ItForm     := CTBCBOX('A1_FORMREC') 
	private  _cForm      := SA1->A1_FORMREC
	private _ItBloq      := CTBCBOX('A1_SIBLQL')  
	private _ItBlPo      := CTBCBOX('A1_POBLQL')  
	private  _cBloq      := SA1->A1_SIBLQL 
	private _cConPag  	:= SA1->A1_COND
	private _cVend    	:= SA1->A1_VEND
	private _mObs     	:= SA1->A1_OBSCLI 
	private _cLimCred 	:= SA1->A1_LC
	private _dLimCred 	:= SA1->A1_VENCLC
	Private _dDTFundacao := SA1->A1_DATAFU
	Private _cEmail		:= SA1->A1_EMAIL   
	Private _cCnpj       := SA1->A1_CGC   
	Private _cBloqP      := SA1->A1_POBLQL     
	Private _cSIMot      := SA1->A1_SIMOTBL

	@ 116,010 To 625,425 Dialog oDlgC Title "Informações de Cadastro do Cliente"
	@ 000,001 SAY 'Observacoes:'  
	@ 010,001 GET _mObs Size 205,065 MEMO Object oMemo 
	@ 006,001 SAY 'Fundacao:        ' 
	@ 077,050 MSGET _dDTFundacao PICTURE "99/99/99" OF oDlgC PIXEL   
	@ 007,001 SAY 'E-mail:          ' 
	@ 090,050 MSGET _cEmail  SIZE 100,10 OF oDlgC PIXEL 

	@ 009,001 SAY 'Vendedor:        '
	@ 116,050 MSGET _cVend  PICTURE "@!" SIZE 10,08 F3 "SA3" OF oDlgC PIXEL          
	@ 010,001 SAY 'Form.Receb.:
	@ 129,050 COMBOBOX _cForm items _ItForm SIZE 120,08 of oDlgC PIXEL               
	@ 011,001 SAY 'Bloq.Movim.:     '                                             
	@ 142,050 COMBOBOX _cBloq items _ItBlPo SIZE 40,08 of oDlgC PIXEL     
	@ 012,001 SAY 'Bloq.Portal:     '                                             
	@ 155,050 COMBOBOX _cBloqP items _ItBloq SIZE 40,08 of oDlgC PIXEL     

	@ 013,001 SAY 'Cond. Pagto:     '
	@ 168,050 MSGET _cConPag  PICTURE "@!" SIZE 10,08 F3 "SE4" OF oDlgC PIXEL          


	@ 014,001 SAY 'Limite Credito:  '    
	@ 181,050 MSGET _cLimCred PICTURE "@E 999,999,999.99"  OF oDlgC PIXEL
	@ 015,001 SAY 'Vencto. Credito: ' 
	@ 194,050 MSGET _dLimCred PICTURE "99/99/99" OF oDlgC PIXEL 
	@ 016,001 SAY 'Risco:           '                                             
	@ 207,050 COMBOBOX _cRisc items _ItRisc SIZE 40,08 of oDlgC PIXEL 
	@ 017,001 SAY 'CNPJ/CPF:        '
	@ 220,050 MSGET _cCnpj  SIZE 100,10 OF oDlgC PIXEL               

	@ 210,170 BMPBUTTON TYPE 1 ACTION salvar() Object Obtn1
	@ 225,170 BMPBUTTON TYPE 2 ACTION oDlgC:end() Object Obtn2
	Activate Dialog oDlgC CENTERED
Return 

Static Function Salvar()
	reclock('SA1',.f.)
	SA1->A1_COND    := _cConPag
	SA1->A1_LC      := _cLimCred
	SA1->A1_VENCLC  := _dLimCred
	SA1->A1_RISCO   := _cRisc
	SA1->A1_VEND    := _cVend
	SA1->A1_OBSCLI  := _mObs   
	SA1->A1_DATAFU  := _dDTFundacao 
	SA1->A1_EMAIL   := _cEmail
	SA1->A1_FORMREC := _cForm 
	SA1->A1_SIDTBL  := iif( (_cBloq <> SA1->A1_SIBLQL) .and. (_cBloq = '1') ,ddatabase,SA1->A1_SIDTBL) 
	SA1->A1_SIMOTBL := iif( (_cBloq <> SA1->A1_SIBLQL) .and. (_cBloq = '1') ,'Manual',SA1->A1_SIMOTBL) 
	SA1->A1_SIBLQL  := _cBloq    
	SA1->A1_PODTBL  := iif( (_cBloqP <> SA1->A1_POBLQL ) .and. (_cBloqP = '1') ,ddatabase,SA1->A1_PODTBL) 
	SA1->A1_POMOTBL := iif( (_cBloqP <> SA1->A1_POBLQL ) .and. (_cBloqP = '1') ,'Manual',SA1->A1_POMOTBL) 
	SA1->A1_POBLQL  := _cBloqP
	msunlock() 

	oDlgC:end()
	Return    

Return
