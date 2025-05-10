#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI13   º Autor ³ Flávio Bohrer Flores º Data ³  15/09/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao de etiqueta Interna para União Européia          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Desossa                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI13()

dbselectarea('ZZ7')
dbsetorder(1)

campoA 	:= space(06)	// Produto
campoB  := space(08)   //Data ( Abate )
campoF  := space(06)   // Lote do Abate
campoC  := space(08)   //Data da Produção
campoD 	:= 000                        					// QUANTIDADE
campoE  := 000                                 //Data de Validade
							
valor1 	:= space(06)     // Produto
valor2 	:= date(8)       //data de abate
valor3 	:= date(8)       //data da Embalagem
valor4 	:= '   '     	 //Quantidade de etiqueta
valor5	:= 000      	 // Classificação chile  
valor6	:= space(40)     //Descrição do corte
valor7 	:= space(06)     // Lote do Abate

DEFINE MSDIALOG telaimp FROM 0,0 TO 310,350 PIXEL TITLE "IMPRESSAO DE ETIQUETA INTERNA RT"
//vinculação dos campos com os valores

@ 01,01 SAY "Produto:" of telaimp
@ 02,01 SAY "Data Abate:" of telaimp  	// Buscar da Prev. Prod. Desossa   ?? 
@ 03,01 SAY "Lote:" of telaimp
@ 04,01 SAY "Data Produção:" of telaimp //
@ 05,01 SAY "Quant. Etiq.:" of telaimp
@ 06,01 SAY "Descrição Corte:" of telaimp
@ 07,01 SAY "Tara:" of telaimp
        

@ 01,08 MSGET campoA VAR valor1 SIZE 20,10 F3 'ZZ7' OF telaimp VALID iif(!existcpo('ZZ7'),dti13clear(),.t.)
@ 02,08 MSGET campoB VAR valor2 SIZE 42,10 OF telaimp //F3 'SZ2' OF telaimp VALID !Vazio() // Data Abate
@ 03,08 MSGET campoF VAR valor7 SIZE 20,10 OF telaimp   				// Lote do Abate
@ 04,08 MSGET campoC VAR valor3 SIZE 42,10 OF telaimp					// data producao  
@ 05,08 MSGET campoE VAR valor5 SIZE 20,10 OF telaimp  picture '@E 999'// quant etiqueta
@ 06,08 SAY valor6 of telaimp											// Descrição Corte
@ 07,08 MSGET campoD VAR valor4 SIZE 20,10  OF telaimp 					// Tara    


@ 120,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action dti13etq()
@ 120,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()
campoA:bLostFocus := {|| dti13prc() }
ACTIVATE MSDIALOG telaimp CENTERED

return

static function dti13clear()

	valor1 	:= space(06)     // Produto
	valor2 	:= date(8)       //data de abate
	valor3 	:= date(8)       //data da Producao
	valor4 	:= 000     		 //Quantidade de etiqueta
	valor5	:= 000      	 // Classificação chile  
	valor6	:= space(40)     //Descrição do corte
	telaimp:refresh()  
	
return

static Function dti13etq()     

if empty(valor1) .or. empty(valor2) .or. empty(valor3) .or. empty(valor4) .or. empty(valor5)
	Alert('Campos em branco!')
	return
endif

ZZ7->(dbsetorder(1))
ZZ7->(dbseek(xfilial('ZZ7')+valor1))

_nQtdCx := fBuscaCpo('SB1',1,xFilial('SB1') + alltrim(valor1),'B1_QCAIX') 
_nQetq  := _nQtdCx * valor5
_cEst := getComputerName()    
_cIp  := ''	
_cDingles  := fBuscaCPO('SB1',1,xfilial('SB1')+valor1,'B1_DINGLES') 
_cCorteIng := ZZ7->ZZ7_CORTEI 
_dtVALID := valor3+ZZ7->ZZ7_DVALID // Data de validade  
_cUP := ZZ7->ZZ7_QTUP

// fixo
//_cCodBar  := fBuscaCpo('SB1',1,xFilial('SB1') + '012462','B1_CODBAR') 
_cCodBar  := fBuscaCpo('SB1',1,xFilial('SB1') + valor1,'B1_CODBAR') 
dtVALID := valor3+60 // Data de validade

/* 
Dados da gjf241 
ImpEtq4(_cProd,_nEtq,_dDtProd,_cTaraP, _cMerc) 
*/

/*
if alltrim(_cEst) == 'PCA02' .or. alltrim(_cEst) == 'PEX01'
	_cIp := alltrim(fBuscaCpo('ZAM',1,xFilial('ZAM')+'IREF1','ZAM_IP'))	
	//_cIp := alltrim(fBuscaCpo('ZAM',1,xFilial('ZAM')+'IPAL1','ZAM_IP'))	
	MSCBPRINTER('S600','IP',,,,,_cIp) //Impressão por IP
else
	MSCBPRINTER('S600','LPT1')
endif     
*/

MSCBPRINTER('S600','IP',,,,,'10.0.0.171')
MSCBCHKSTATUS(.t.)
//        nr etiq
MSCBBEGIN(_nQetq,6,15)

     
f00		:="19,13" 
f01     :="35,32"
f02		:="16,20" 
f03     :="28,32"  // DAS DATAS   
f04     :="60,80"
f05		:="45,50"
f06		:="21,19"  
f07		:="20,15"
f08		:="18,35"
f09		:="22,29"
fonte_mlr3 :="45,20"
   
//MSCBBOX(1,10,56,25,4) 
// descrição do Corte
t0 		:= len(alltrim(_cDingles))
pos0 	:= 34-t0
t1 		:= len(alltrim(ZZ7->ZZ7_DESC))
pos1 	:= 34-t1    
t2		:=len(alltrim(_cCorteIng))
pos2	:= 34-t2   
t3		:=len(substr(alltrim(valor6),1,20))
pos3	:=34-t3  
t4		:=len(alltrim(_cUP))
pos4	:=34-t4

MSCBSAY(pos0,9,_cDingles,"N","0",f09)
MSCBSAY(pos1,12,alltrim(ZZ7->ZZ7_DESC),"N","0",f09)
MSCBSAY(1,15,_cCorteIng,"N","0",f02) // nome do corte 31          
MSCBSAY(pos4,18,_cUP,"N","0",f09)
MSCBSAY(pos3,21,substr(alltrim(valor6),1,20),"N","0",f09)   

// Ordem das línguas  "Frances | Espanhol | Italiano | Inglês | Alemão | Português"
// Primeiro Bloco
MSCBSAY(1,27,"Date Production/Fecha De Produccione","N","0",f09)
MSCBSAY(1,30,"Data Di Produzione/Production Date","N","0",f09)
MSCBSAY(1,33,"Produktion Datum","N","0",f09)
MSCBSAY(1,36,"Data De Producao:","N","0",f09)
MSCBSAY(31,36,substr(dtos(valor2),7,2)+'/'+substr(dtos(valor2),5,2)+'/'+substr(dtos(valor2),3,2),"N","0",f09) //Data da producao

// Segundo Bloco  (dsitãncia entre blocos = 7)
MSCBSAY(1,43,"Date De Conditionnement-Fournee","N","0",f09)
MSCBSAY(1,46,"Fecha de Embalaje-Lot/Data di Conferezionamento-Lotto","N","0",f09)
MSCBSAY(1,49,"Packing Date-Batch/Pack Datum-Reihe","N","0",f09)
MSCBSAY(1,52,"Data de Embalagem-Lote :","N","0",f09)
MSCBSAY(44,52,substr(dtos(valor3),7,2)+'/'+substr(dtos(valor3),5,2)+'/'+substr(dtos(valor3),3,2),"N","0",f09) //Data validade


// Terceiro Bloco
MSCBSAY(1,59,"Consommer Le Product de Preference Avant/Fecha de Envase","N","0",f09)
MSCBSAY(1,62,"Prodotto Deve Essere Consumato Entro/Expiration Date","N","0",f09)
MSCBSAY(1,65,"Lagertemperatur Mindestens Haltbar Bis/Data de Validade:","N","0",f09)
MSCBSAY(89,65,substr(dtos(dtVALID),7,2)+'/'+substr(dtos(dtVALID),5,2)+'/'+substr(dtos(dtVALID),3,2),"N","0",f09) //Data VENC. 

  
_sif04 		:= GetMV('SI_SIFET04')
_sif07 		:= GetMV('SI_SIFET07')
_sif07_2 	:= GetMv('SI_SIFTE07')
_sif12 		:= GetMV('SI_SIFET12')
_sif18 		:= GetMV('SI_SIFET18')
_MSIF  		:= substr(ZZ7->ZZ7_MSIF,1,4)


	
// Quarto Bloco
MSCBSAY(1,70,"USO AUTORIZADO PELO SIF/DIPOA SOB N 087/1733","N","0",f06) //USO AUTORIZADO

if  _MSIF $ _sif18 

    // Validar esta parte com a exportação
	MSCBSAY(1,75,"At -18C The Product Should Be Consumed Until/Bei -18C Lagertemperatur Mindestens Haltbar Bis","N","0",f00)
	MSCBSAY(1,78,"A -18C Prodotto Deve Essere Consumato Entro/A -18C El Producto Debe Consumirse Hasta","N","0",f00)
	MSCBSAY(1,81,"A -18C Le Produit Peut Etre Consommee Jusqu'à/A -18C O Produto Deve Ser Consumido Até","N","0",f00)	

elseif _MSIF $ _sif07 .or. _MSIF $_sif07_2 //_MSIF $ _sif04	         
	
	MSCBSAY(1,75,"Bewear Temperatuur/Temperature de Conservation","N","0",f09)
	MSCBSAY(1,78,"Conservare a/Keep Refrigered/Gekuhll bei Zwischen","N","0",f09) 
	MSCBSAY(1,81,"Conservar Entre:","N","0",f09)
	MSCBSAY(28,81,"0 - 4 graus Celcius","N","0",f09) 
endif  

// Quinto Bloco

MSCBSAY(1,88,"Code Tracabilitê/Codigo De Rastreo/Codice Tracciabilita","N","0",f09)
MSCBSAY(1,91,"Traceability code/Ruckverfolgbarkeitscode","N","0",f09)
MSCBSAY(1,94,"Codigo De  Rastreabilidade:","N","0",f09)
MSCBSAY(52,94,'1733'+substr(dtos(valor2),7,2)+substr(dtos(valor2),5,2)+substr(dtos(valor2),3,2)+'0000',"N","0",f09)

// Código de Barras

MSCBSAYBAR(67,138,_cCodBar,"N","MB07",8,.F.,.T.,.F.,"C",2,1,.F.)


// Sexto Bloco
//MSCBBOX(1,72,56,90,3)

MSCBSAY(1,101,"Poids Conditionnement//Peso Del Envase/Imballa peso","N","0",f09) 
MSCBSAY(1,104,"Packing Weight/Verpackungsgewicht","N","0",f09) 
MSCBSAY(1,107,"Peso Da Embalagem:","N","0",f09)
MSCBSAY(32,107,alltrim(valor4)+'g',"N","0",f08)//tara

// Sexto Bloco
MSCBSAY(1,112,"Abattu/Slaglel I/Macellato in","N","0",f09)
MSCBSAY(1,115,"Slaughtered in/Geslacht/Abatido Em: BRAZIL","N","0",f09)

// Sétimo Bloco
MSCBSAY(1,122,"Decoupe/Uilgesneden/Confezionato In","N","0",f09)
MSCBSAY(1,125,"Cut in/Opskeret I/Desmancha Em: BRAZIL","N","0",f09)

// Oitavo Bloco
MSCBSAY(1,132,"Source/Fuente/Fonte/Origin","N","0",f09)
MSCBSAY(1,135,"Quelle/Origem: BRAZIL","N","0",f09)



MSCBEND()
MSCBCLOSEPRINTER()
dti13clear()


msgbox('Impressão de Etiquetas em Andamento!','Impressão','INFO')

return

static function dti13prc()
	ZZ7->(dbsetorder(1))
	if ZZ7->(dbseek(xfilial('ZZ7')+valor1))
		valor6 := ZZ7->ZZ7_CORTE
	endif
	telaimp:refresh()
return

