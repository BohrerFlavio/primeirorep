#INCLUDE "rwmake.ch" 
#INCLUDE "apwebex.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function p_dcad(__aCookies, __aPostParms, __nProcID, __aProcParms, __cHTTPPage)
	Local cHTML:= ""
	Local i:= 0
	Local cCli:= ""
	Local cLoja:= ""

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1"

	For i := 1 To Len(__aProcParms)  
		If Alltrim(__aProcParms[i, 1]) == 'cliente'
			cCli:= __aProcParms[i, 2]
		EndIf
		If Alltrim(__aProcParms[i, 1]) == 'loja'
			cLoja:= __aProcParms[i, 2]
		EndIf
	Next i

	If !Empty(cCli) .AND. !Empty(cLoja)
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+cCli+cLoja)
		If Found()
			cHTML:= "<html>"
			cHTML+= "<link rel='stylesheet' type='text/css' href='estilo2.css'>"  
			cHTML+= "<link rel='shortcut icon' href='imagens/silva.ico'>"
			cHTML+= "<p><img border='0' src='imagens/logo2.jpg'><br><br>"
			cHTML+= "<input type='button' value='Fechar' onclick='window.close()' /><br>"
			cHTML+= "<center><b>Dados Cadastrais<b></center><br><br>"
			cHTML+= "<table border='1px' width='100%' style='border-collapse:collapse;border-left:1px solid;border-right:1px solid; border-top:1px solid; border-bottom:1px solid;'>"
			cHTML+= "<tr>"
			cHTML+= "<td><input type='text' readonly='readonly' style='border:none;' value='Endereco' /></td>"
			cHTML+= "<td style='text-align:left;'><input type='text' readonly='readonly' style='border:none;' size='60' value='"+SA1->A1_END+"' /></td>"
			cHTML+= "</tr>"
			cHTML+= "<tr>"
			cHTML+= "<td><input type='text' readonly='readonly' style='border:none' value='Municipio' /></td>"
			cHTML+= "<td style='text-align:left;'><input type='text' readonly='readonly' style='border:none;' size='60' value='"+SA1->A1_MUN+"' /></td>"
			cHTML+= "</tr>"
			cHTML+= "<tr>"
			cHTML+= "<td><input type='text' readonly='readonly' style='border:none' value='Estado' /></td>"
			cHTML+= "<td style='text-align:left;'><input type='text' readonly='readonly' style='border:none;' size='60'  value='"+SA1->A1_EST+"' /></td>"
			cHTML+= "</tr>"
			cHTML+= "<tr>"
			cHTML+= "<td><input type='text' readonly='readonly' style='border:none' value='E-mail' /></td>"
			cHTML+= "<td style='text-align:left;'><input type='text' readonly='readonly' style='border:none;' size='60' value='"+SA1->A1_EMAIL+"' /></td>"
			cHTML+= "</tr>"
			cHTML+= "<tr>"
			cHTML+= "<td><input type='text' readonly='readonly' style='border:none' value='Fone' /></td>"
			cHTML+= "<td style='text-align:left;'><input type='text' readonly='readonly' style='border:none;' size='60' value='"+SA1->A1_DDD+" "+SA1->A1_TEL+"' /></td>"
			cHTML+= "</tr>"
			cHTML+= "<tr>"
			dbSelectArea("SE4")
			dbSetOrder(1)
			dbSeek(xFilial("SE4")+SA1->A1_COND)
			cHTML+= "<td><input type='text' readonly='readonly' style='border:none' value='Condicao Pagamento' /></td>"
			cHTML+= "<td style='text-align:left;'><input type='text' readonly='readonly' style='border:none;' size='60' value='"+SA1->A1_COND+" - "+SE4->E4_DESCRI+"' /></td>"
			cHTML+= "</tr>"
			cHTML+= "<tr>"
			cHTML+= "<td><input type='text' readonly='readonly' style='border:none' value='Forma cobranca' /></td>"
			cHTML+= "<td style='text-align:left;'><input type='text' readonly='readonly' style='border:none;' size='60' value='"+IIF(SA1->A1_FORMREC=="1", "(R$)Dinheiro", IIF(SA1->A1_FORMREC=="2", "(CH)Cheque", IIF(SA1->A1_FORMREC=="3", "(BL)Boleto", IIF(SA1->A1_FORMREC=="4", "(DP)Deposito Bancario", ""))))+"' /></td>"
			cHTML+= "</tr>"
			cHTML+= "</table>"
			cHTML+= "</html>"
		Else
			cHTML:= "<p><img border='0' src='imagens/logo2.jpg'><br>"
			cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Nenhum cliente selecionado.</b></font></td><input type='button' value='Fechar' onclick='window.close()' />"
		EndIf
	Else
		cHTML:= "<p><img border='0' src='imagens/logo2.jpg'><br>"
		cHTML+= "<b><td bgcolor='#000000'><font face='arial' size='3'>Nenhum cliente selecionado.</b></font></td><input type='button' value='Fechar' onclick='window.close()' />"
	EndIf

	RESET ENVIRONMENT

Return cHTML
