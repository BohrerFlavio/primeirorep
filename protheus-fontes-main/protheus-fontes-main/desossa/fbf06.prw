#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fbf06   º Autor ³ Flávio Bohrer Flores º Data ³  25/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao de tiqueta interna para GO    /Zaffari           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Desossa                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FBF06()

	dbselectarea('ZZ7')
	dbsetorder(1)

	campoA  := '      '  //campo do codigo do produto
	campoB  := '        ' //campo da data da produção
	campoC 	:= '                                      '  //campo da descrição do corte
	campoD 	:= '   ' // campo da tara para impressão na etiqueta
	campoE 	:= 000
	//campoF 	:= {"     ","Macho","Femea","XXXXX"}//sexo
	campoG	:= space(08)
	campoH := 0

	_dDTMaior := date() + 4
	_dDTMenor := date() - 15

	valor1 	:= '      ' 	//codigo do produto
	valor2 	:= date()   	//data de produção
	valor3 	:= '                   ' //Descrição do corte
	valor4 	:= '   '   //Tara
	valor5 	:= 000     //Quantidade de etiqueta
	valor6 	:= 'XXXXX'  //Sexo
	valor7	:= date() //data de embalagem
	valor8 := 0 //qtd etq


	DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "IMPRESSAO DE ETIQUETA INTERNA"
	//vinculação dos campos com os valores

	@ 01,01 SAY "Produto:" of telaimp
	@ 02,01 SAY "Data Produção:" of telaimp
	@ 03,01 SAY "Data Embalagem:" of telaimp
	@ 04,01 SAY "Descrição Corte:" of telaimp
	@ 05,01 SAY "Tara:" of telaimp
	@ 06,01 SAY "Quant. Caixas:" of telaimp
	//@ 07,01 SAY "Sexo:" of telaimp
	@ 07,01 SAY "Qtd.Etiquetas:" of telaimp

	@ 01,08 MSGET campoA VAR valor1 SIZE 20,10 F3 'ZZ7' OF telaimp VALID iif(!existcpo('ZZ7'),fbf06clear(),.t.)
	/*Dia 28/11/22 - Retirado a validação de limite de data pela urgência solicitada para a impressão - Provavelmente
	 essas regras de validação de data vão precisar ser emparelahdas com o Fonte que o Lucas esta trabalhando.*/
	//@ 02,08 MSGET campoB VAR valor2 SIZE 40,10  OF telaimp //valid valor2 >= _dDTMenor .and. valor2 <= _dDTMaior// data producao	
	@ 02,08 MSGET campoB VAR valor2 SIZE 40,10  OF telaimp 
	@ 03,08 MSGET campoG VAR valor7 SIZE 40,10  OF telaimp valid valor7 >= _dDTMenor .and. valor7 <= _dDTMaior// data embalagem
	@ 04,08 SAY valor3 of telaimp
	//@ 05,08 MSGET campoD VAR valor4 SIZE 20,10  OF telaimp // Tara
	@ 05,08 SAY transform(valor4,'@E 99') + ' g' of telaimp
	@ 06,08 MSGET campoE VAR valor5 SIZE 20,10  OF telaimp  picture '@E 999' VALID QuantEtq(valor5)  // quant etiqueta
	//@ 07,08 COMBOBOX valor6 items campoF SIZE 40,08 OF telaimp      // Sexo
	@ 07,08 SAY	transform(valor8,'@E 999') OF telaimp
	@ 200,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action fbf06etq()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()
	campoA:bLostFocus := {|| fbf06prc() }
	
	ACTIVATE MSDIALOG telaimp CENTERED

return


static function fbf06prc()
	ZZ7->(dbsetorder(1))
	if ZZ7->(dbseek(xfilial('ZZ7')+valor1))
		valor3 := ZZ7->ZZ7_CORTE
	endif
	// Ini tara 
	dbSelectArea('SB1')

	// Inicio bloco inserido por Fabian Maurer para levar a tara automatica do cadastro de produto, solicitação Matheus Silva dia 07/08/17
	_nTaraP := FBuscaCPO('SB1',1,xfilial('SB1')+ alltrim(valor1),'B1_CTARAP')      // Linhas inseridas para buscar"_NTARAp"
	_nTP    := FBuscaCPO('ZAB',1,xfilial('ZAB')+alltrim(_nTaraP),'ZAB_TARA')  // os campos de codigo das taras primarias
	//valor4  := transform(_nTP,'@E 9.999')
	valor4  := (_nTP * 1000)

	telaimp:refresh()
return

static function fbf06clear()
	valor1   := '      '
	valor2   := date()
	valor3   := '                    '
	valor4   := '   '
	valor5   :=000
	valor6   := '     '
	telaimp:refresh()

return

static Function fbf06etq()
	if empty(valor1) .or. empty(valor2) .or. empty(valor3) .or. empty(valor4) .or. empty(valor5)
		Alert('Campos em branco!')
		return
	endif
	ZZ7->(dbsetorder(1))
	ZZ7->(dbseek(xfilial('ZZ7')+valor1))

	_nQtdCx := fBuscaCpo('SB1',1,xFilial('SB1') + alltrim(valor1),'B1_QCAIX')
	_nQetq  := _nQtdCx * valor5

	_cEst := getComputerName()
	dbselectarea('ZAM')
	ZAM->(dbSetOrder(2))
	if ZAM->(dbSeek(xFilial('ZAM') + alltrim(_cEst)))
		_cIp := alltrim(ZAM->ZAM_IP)
	endif
	
	//se não achou o ip na tabela imprime pela porta paralela
	if empty(_cIp)
		MSCBPRINTER('S600','LPT1')
	else
		MSCBPRINTER('S600','IP',,,,,_cIp) //Impressão por IP
	endif

	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(_nQetq,6,15)  // Usar variavel no primeiro campo, para a quantidade de etiquetas VALOR5

	// LDia 22/10/22 - Solicitação de Ajuste de formação da data de validade

	dtVALID :=  valor2+ZZ7->ZZ7_DVALID // Data de validade
	/*
	_nDias := fBuscaCPO('SB1',1,xfilial('SB1') + alltrim(ZZ7->ZZ7_CODPRO),'B1_VALID')		
	_dDtprod := BuscaDT(ZZ7->ZZ7_CODPRO)
	if  empty(_dDtprod)
		// Se não tiver produção lançada 
		dtVALID := DATE()+_nDias
		
	Else		
		dtVALID := _nDias+stod(_dDtprod)
	endif
	*/
	
	fontecorte      :="22,29"
	fontedesc       :="22,29"
	fonteNomeCorte  :="28,35"
	fonteNomeCorte1 :="18,35"
	fonteData       :="16,35"
	fonteMesTemp    :="22,15"
	fonteMesTemp1   :="19,13"
	fonteInscSIF    :="19,16"
	fonteInfNutri1  :="8,10"
	fonteInfNutri2  :="16,18"
	fonteNutri3     :="16,9"
	fonteNutri4     :="19,10"
	fontelinha9     :="14,14"
	fonte3          :="16,13"
	t:=len(alltrim(ZZ7->ZZ7_DESC))
	pos:=42-t
	MSCBSAY(2,pos,ZZ7->ZZ7_DESC,"B","0",fonteDesc)
	pos2:=0
	t2:=len(alltrim(valor3))
	pos2:=42-t2
	MSCBSAY(9,pos2,alltrim(valor3),"B","0",fontecorte) // nome do corte
	MSCBSAY(16,52,substr(dtos(valor2),7,2)+'/'+substr(dtos(valor2),5,2)+'/'+substr(dtos(valor2),3,2),"B","0",fonteData) //Data da producao
	

	_sif04 := GetMV('SI_SIFET04')
	_sif07 := GetMV('SI_SIFET07')
	_sif07_2 := GetMv('SI_SIFTE07')
	_sif12 := GetMV('SI_SIFET12')
	_sif18 := GetMV('SI_SIFET18')
	_MSIF  := substr(ZZ7->ZZ7_MSIF,1,4)

	if (_MSIF $ _sif07) .or. (_MSIF $ _sif07_2)
		MSCBSAY(15,5,'MANTER RESFRIADA DE 0 a 7 GRAUS CELSIUS',"B","0",fonteMesTemp1)
	elseif _MSIF $ _sif12
		MSCBSAY(15,5,'MANTER CONGELADA A -12 GRAUS CELSIUS',"B","0",fonteMesTemp)
	elseif _MSIF $ _sif18
		MSCBSAY(15,5,'MANTER CONGELADA A -18 GRAUS CELSIUS',"B","0",fonteMesTemp)
	elseif _MSIF $ _sif04
		MSCBSAY(15,5,'MANTER RESFRIADA DE 0 a 4 GRAUS CELSIUS',"B","0",fonteMesTemp1)
	endif


	MSCBSAY(21,52,substr(dtos(dtVALID),7,2)+'/'+substr(dtos(dtVALID),5,2)+'/'+substr(dtos(dtVALID),3,2),"B","0",fonteData) //Data validade
	//MSCBSAY(21,24,valor6,"B","0",fonteNomeCorte1)// Sexo
	MSCBSAY(21,13,str(valor4) +'g',"B","0",fonteNomeCorte1)//tara
	MSCBSAY(23,9,'REGISTRO NO MINISTERIO DA AGRICULTURA/SIF/DIPOA SOB Nr '+ZZ7->ZZ7_MSIF,"B","0",fonteInscSIF)

		// Primeira linha
	MSCBSAY(32,26,ZZ7->ZZ7_GOVE,"B","0",fonteInfNutri1) //QUANTO MAIOR O X MAIS PRA FRENTE
	MSCBSAY(32,37,ZZ7->ZZ7_GOKCAL,"B","0",fonteInfNutri1)
	MSCBSAY(32,02,ZZ7->ZZ7_GOGS,"B","0",fonteInfNutri1)
	MSCBSAY(32,19,ZZ7->ZZ7_GOGSG,"B","0",fonteInfNutri1)

	//       Y  X
	// Segunda linha
	MSCBSAY(38,27,ZZ7->ZZ7_GOC,"B","0",fonteInfNutri1)
	MSCBSAY(38,37,ZZ7->ZZ7_GOCG,"B","0",fonteInfNutri1)
	MSCBSAY(38,02,ZZ7->ZZ7_GOGT,"B","0",fonteInfNutri1)
	MSCBSAY(38,19,ZZ7->ZZ7_GOGTG,"B","0",fonteInfNutri1)

	//       Y  X
	// Terceira linha
	MSCBSAY(44,26,ZZ7->ZZ7_GOP,"B","0",fonteInfNutri1)
	MSCBSAY(44,43,ZZ7->ZZ7_GOPG,"B","0",fonteInfNutri1)
	MSCBSAY(44,02,ZZ7->ZZ7_GOFA,"B","0",fonteInfNutri1)
	MSCBSAY(44,19,ZZ7->ZZ7_GOFAG,"B","0",fonteInfNutri1)

	//       Y  X
	// Quarta linha
	MSCBSAY(50,26,ZZ7->ZZ7_GOGTO,"B","0",fonteInfNutri1)
	MSCBSAY(50,46,ZZ7->ZZ7_GOGTOG,"B","0",fonteInfNutri1)
	MSCBSAY(50,02,ZZ7->ZZ7_GOS,"B","0",fonteInfNutri1)
	MSCBSAY(50,19,ZZ7->ZZ7_GOSG,"B","0",fonteInfNutri1)

	MSCBEND()
	MSCBCLOSEPRINTER()
	fbf06clear()


	msgbox('Impressão de Etiquetas em Andamento!','Impressão','INFO')

return

Static Function buscaDt(_cProd)

//Acrescentadona linha 591 a validação Z8_ENCONTR = '' para não deixar separar caixas nao encontradas no estoque. Fabian Maurer 27/11/18
	_cQuery5 := " SELECT TOP 1 ZU_NUM, ZU_DTPROD
	_cQuery5 += " FROM  " + retSqlTab('SZU')
	_cQuery5 += " WHERE " + retSqlFil('SZU')
	_cQuery5 += " AND ZU_COD = '" + _cProd + "'"
	_cQuery5 += " AND   " + retSqlDel('SZU')
	_cQuery5 += " ORDER BY ZU_NUM DESC

	_cQuery5  := ChangeQuery(_cQuery5)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery5 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY5") != 0
		QRY5->(dbCloseArea())
	Endif

	TCQUERY _cQuery5 NEW ALIAS "QRY5"
	
	QRY5->(dbGoTop())
	

return (QRY5->ZU_DTPROD)

STATIC FUNCTION QuantEtq()
	
	_nQTD   := 0
	_nQtdCx := fBuscaCpo('SB1',1,xFilial('SB1') + alltrim(valor1),'B1_QCAIX')
	_nQetq  := _nQtdCx * valor5
	_nQTD   := _nQetq
	valor8  := _nQTD

RETURN 
