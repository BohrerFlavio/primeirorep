#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} XML_IQF
Função para geração de XML das etiquetas da linha IQF
@author 	Evandro Mugnol
@since 		Mar/2022
@return 	Nil, Função não tem retorno
@obs 		N/A
/*/
//-------------------------------------------------------------------
User Function XML_IQF()

	Private _oTela, _oCancel, _oConfir
	Private _cTitulo    := OemToAnsi("Parâmetros p/ geração XML etiq. linha IQF")
	Private _oFtArial24 := TFont():New ("Arial"      , 10, 24)
	Private _oFtArial30 := TFont():New ("Arial"      , 10, 34)
	Private _oFCourier  := TFont():New ("Courier New",   , 24,,.T.)
	Private _cCodPrd   	:= Space(09)
	Private _cNomArq   	:= Space(10)

	DEFINE MSDIALOG _oTela TITLE _cTitulo FROM C(0), C(0) TO C(350), C(400) PIXEL

	@ C(015), C(010) SAY "Informe os parâmetros abaixo para geração de XML"		Size C(300), C(12) FONT _oFtArial30 COLOR CLR_HRED 	PIXEL OF _oTela
	@ C(030), C(010) SAY "referente impressão de etiquetas da linha IQF  "		Size C(300), C(12) FONT _oFtArial30 COLOR CLR_HRED 	PIXEL OF _oTela

	@ C(050), C(010) SAY "Produto"		                                  	  	Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN	PIXEL OF _oTela
	@ C(050), C(080) MSGET _cCodPrd Picture "@!"  F3 'SB1'	               		Size C(080), C(10) FONT _oFCourier  COLOR CLR_HBLUE	PIXEL OF _oTela
	@ C(070), C(010) SAY "Nome Arq. a Gerar"                       	   			Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN	PIXEL OF _oTela
	@ C(070), C(080) MSGET _cNomArq Picture "@!"							   	Size C(060), C(10) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela
	@ C(072), C(140) SAY ".XML"				                      	   			Size C(020), C(10) FONT _oFtArial24 COLOR CLR_GREEN	PIXEL OF _oTela

	DEFINE SBUTTON FROM C(150), C(100) TYPE 1 OBJECT _oConfir ENABLE OF _oTela	ACTION (_bOk := .T., _Process())
	DEFINE SBUTTON FROM C(150), C(150) TYPE 2 OBJECT _oCancel ENABLE OF _oTela	ACTION (_bOk := .T., _oTela:End())

	ACTIVATE MSDIALOG _oTela CENTERED                                                                        

Return

// Efetua Processamento dos Dados Informados
Static Function _Process()

	Local cPath    := ""
	Local cArqPesq := ""
	Local _lClose  := .T.
	Local nHandle  := 0			// Indicador de arquivo de exportação aberto

	If !Empty(_cCodPrd) .And. !Empty(_cNomArq)

		DbSelectArea("ZZ7")
		DbSetOrder(1)
		MsSeek(xFilial("ZZ7") + _cCodPrd)
		If Found()

			// Verifica o caminho a ser gravado o arquivo
			FWAlertInfo("Informe na tela seguinte o local onde deseja gravar o arquivo XML", "LOCAL PARA GRAVAÇÃO ARQUIVO XML")		
			cDir  := GetTempPath()
			cPath := tFileDialog( "All files (*.*) | All Text files (*.txt) ",'Local para gravação...', , , .F., GETF_LOCALHARD + GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_RETDIRECTORY)
			cArqPesq := cPath + "\" + AllTrim(_cNomArq) + ".xml"
				
			// Cria um arquivo do tipo *.xml
			nHandle := FCREATE(cArqPesq, 0)
			
			// Verifica se o arquivo pode ser criado, caso contrário um alerta será exibido
			If FERROR() <> 0
				Alert("Não foi possível abrir ou criar o arquivo: " + _cNomArq + ".xml")
			Else
				cArqXML := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + CRLF	
				cArqXML += '<Label>' + CRLF
				cArqXML += '<Label_Lay_out>\LAYOUT1.lbl</Label_Lay_out>' + CRLF
				cArqXML += '<Cod.Produto>'+AllTrim(ZZ7->ZZ7_CODPRO)+'</Cod.Produto>' + CRLF
				cArqXML += '<Desc.Prod.>'+AllTrim(ZZ7->ZZ7_DESC)+'</Desc.Prod.>' + CRLF
				cArqXML += '<Tipo.Corte.>'+AllTrim(ZZ7->ZZ7_CORTE)+'</Tipo.Corte.>' + CRLF
				cArqXML += '<Mens.SIF.>'+AllTrim(ZZ7->ZZ7_MSIF)+'</Mens.SIF.>' + CRLF
				cArqXML += '<Val.Cal.QtdP>'+AllTrim(ZZ7->ZZ7_CALQTP)+'</Val.Cal.QtdP>' + CRLF
				cArqXML += '<Val.Cal.VD.>'+AllTrim(ZZ7->ZZ7_CALVD)+'</Val.Cal.VD.>' + CRLF
				cArqXML += '<Carboidr.Qtp>'+AllTrim(ZZ7->ZZ7_CARQTP)+'</Carboidr.Qtp>' + CRLF
				cArqXML += '<Carb.VD>'+AllTrim(ZZ7->ZZ7_CARVD)+'</Carb.VD>' + CRLF
				cArqXML += '<Prot.Qtd.P.>'+AllTrim(ZZ7->ZZ7_PROQTP)+'</Prot.Qtd.P.>' + CRLF
				cArqXML += '<Prot.VD>'+AllTrim(ZZ7->ZZ7_PROVD)+'</Prot.VD>' + CRLF
				cArqXML += '<Gord.Totais>'+AllTrim(ZZ7->ZZ7_GTQTP)+'</Gord.Totais>' + CRLF
				cArqXML += '<Gord.Totais>'+AllTrim(ZZ7->ZZ7_GTVD)+'</Gord.Totais>' + CRLF
				cArqXML += '<Gord.Sat.>'+AllTrim(ZZ7->ZZ7_GSQTP)+'</Gord.Sat.>' + CRLF
				cArqXML += '<Gord.Sat.VD>'+AllTrim(ZZ7->ZZ7_GSVD)+'</Gord.Sat.VD>' + CRLF
				cArqXML += '<Colest.Qtd.P>'+AllTrim(ZZ7->ZZ7_COLQTP)+'</Colest.Qtd.P>' + CRLF
				cArqXML += '<Colest.VD.>'+AllTrim(ZZ7->ZZ7_COLVD)+'</Colest.VD.>' + CRLF
				cArqXML += '<Fib.Alim.Qtd>'+AllTrim(ZZ7->ZZ7_FIAQTP)+'</Fib.Alim.Qtd>' + CRLF
				cArqXML += '<Fibr.Ali.VD>'+AllTrim(ZZ7->ZZ7_FIAVD)+'</Fibr.Ali.VD>' + CRLF
				cArqXML += '<Calcio.Qtd.P>'+AllTrim(ZZ7->ZZ7_CACQTP)+'</Calcio.Qtd.P>' + CRLF
				cArqXML += '<Calcio.VD>'+AllTrim(ZZ7->ZZ7_CACVD)+'</Calcio.VD>' + CRLF
				cArqXML += '<Ferro.Qtd.P.>'+AllTrim(ZZ7->ZZ7_FERQTP)+'</Ferro.Qtd.P.>' + CRLF
				cArqXML += '<Ferro.VD.>'+AllTrim(ZZ7->ZZ7_FERVD)+'</Ferro.VD.>' + CRLF
				cArqXML += '<Sodio.Qtd.P.>'+AllTrim(ZZ7->ZZ7_SODQTP)+'</Sodio.Qtd.P.>' + CRLF
				cArqXML += '<Sodio.VD>'+AllTrim(ZZ7->ZZ7_SODVD)+'</Sodio.VD>' + CRLF
				cArqXML += '<Tara.Prim.>'+AllTrim(ZZ7->ZZ7_TARAP)+'</Tara.Prim.>' + CRLF
				cArqXML += '<Dias.Validad>'+AllTrim(CValToChar(ZZ7->ZZ7_DVALID))+'</Dias.Validad>' + CRLF
				cArqXML += '<Lipidios>'+AllTrim(ZZ7->ZZ7_LIPID)+'</Lipidios>' + CRLF
				cArqXML += '<Gras.Pol.Ins>'+AllTrim(ZZ7->ZZ7_GRAPI)+'</Gras.Pol.Ins>' + CRLF
				cArqXML += '<AC.Gra.Trans>'+AllTrim(ZZ7->ZZ7_ACGTR)+'</AC.Gra.Trans>' + CRLF
				cArqXML += '<ParteComest>'+AllTrim(ZZ7->ZZ7_PRTCOM)+'</ParteComest>' + CRLF
				cArqXML += '<Ingredientes1>'+AllTrim(ZZ7->ZZ7_INGRED)+'</Ingredientes1>' + CRLF
				cArqXML += '<Ingredientes2>'+AllTrim(ZZ7->ZZ7_INGRE2)+'</Ingredientes2>' + CRLF
				cArqXML += '<Descr.Det>'+AllTrim(ZZ7->ZZ7_DES1)+'</Descr.Det>' + CRLF
				cArqXML += '<Temp.Carne>'+AllTrim(ZZ7->ZZ7_TEMP)+'</Temp.Carne>' + CRLF
				cArqXML += '<Des.Nutri>'+AllTrim(ZZ7->ZZ7_NUTRI)+'</Des.Nutri>' + CRLF
				cArqXML += '<Des.Nutri2>'+AllTrim(ZZ7->ZZ7_NUTRI2)+'</Des.Nutri2>' + CRLF
				cArqXML += '<Des.Nutri3>'+AllTrim(ZZ7->ZZ7_NUTRI3)+'</Des.Nutri3>' + CRLF
				cArqXML += '<Refrigerador>'+AllTrim(ZZ7->ZZ7_CONS)+'</Refrigerador>' + CRLF
				cArqXML += '<Congelador>'+AllTrim(ZZ7->ZZ7_CONS2)+'</Congelador>' + CRLF
				cArqXML += '<Freezer>'+AllTrim(ZZ7->ZZ7_CONS3)+'</Freezer>' + CRLF
				cArqXML += '<Ingredientes1>'+AllTrim(ZZ7->ZZ7_OBS)+'</Ingredientes1>' + CRLF
				//cArqXML += '<Ingredientes2>'+AllTrim(ZZ7->ZZ7_XXXXX)+'</Ingredientes2>' + CRLF
				cArqXML += '<Alergicos>'+AllTrim(ZZ7->ZZ7_OBS2)+'</Alergicos>' + CRLF
				cArqXML += '<Produzido>'+AllTrim(ZZ7->ZZ7_OBS3)+'</Produzido>' + CRLF
				cArqXML += '<Distribuido1>'+AllTrim(ZZ7->ZZ7_OBS4)+'</Distribuido1>' + CRLF
				//cArqXML += '<Distribuido2>'+AllTrim(ZZ7->ZZ7_XXXXX)+'</Distribuido2>' + CRLF
				cArqXML += '</Label>' + CRLF


				// Verifica se foi possível gravar o arquivo, caso não seja possível, uma
				// mensagem de alerta será exibida na tela
				If(FWRITE(nHandle, cArqXML) == 0) 
					MsgAlert("Não foi possível gravar o arquivo!")
				EndIf
			
				// Fecha o arquivo gravado
				FCLOSE(nHandle)
			EndIf		
		Else
			// Alimenta a variável com conteúdo da mensagem em HTML
			cMsgHTML := '<h1><font color="#0000FF">Atenção</font></h1>'
			cMsgHTML += '<h3><br><font color="#FF0000"><b>Não encontrado produto na tabela da Informações Nutricionais.</font></b></h3>'

			MsgAlert(cMsgHTML)
			_lClose := .F.
		Endif
	Else
		// Alimenta a variável com conteúdo da mensagem em HTML
		cMsgHTML := '<h1><font color="#0000FF">Atenção</font></h1>'
		cMsgHTML += '<h3><br><font color="#FF0000"><b>Todos os parâmetros devem estar preenchidos.</font></b></h3>'

		MsgAlert(cMsgHTML)
		_lClose := .F.
	Endif

	If _lClose
		_oTela:End()
	EndIf

Return
