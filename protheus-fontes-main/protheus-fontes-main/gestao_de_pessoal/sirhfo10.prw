#INCLUDE "rwmake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SIRHFO10º Autor Flávio Bohrer           Data ³  12/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de Fórmulas Para a folha de pagamento		          º±±
±±º          ³ Para não calcular quando mes = 31 						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP10 IDE                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/     

USER FUNCTION  SIRHFO10()    

	Private _dMes   := substr(dtoc(ddatabase),4,2)//month(ddatabase) 
	Private _dAno   := year(ddatabase)
	Private _dDia	 := Day(RCF->RCF_DTFIM) 
	Private _dMonth := substr(dtoc(ddatabase),4,2)
	Private _cRCFDataFim                          

	// Tentando deletar as verbas 090 e 091  para um caso em particular no cálculo da folha 
	_nHrs910:=fBuscaPD("910","H")
	_nVal910:=fBuscaPD("910")
	_nVal090:=fBuscaPD("090")
	_nVal091:=fBuscaPD("091")

	_dDTFim   := fbuscaCPO('RCF',1,xfilial('RCF')+alltrim(STR(YEAR(ddatabase))) + _dMonth,'RCF_DTFIM') 

	if (Day(_dDTFim)  == Day(SRA->RA_VCTEXP2)) .and. substr(dtoc(_dDTFim),4,2) == _dMes .and.  year(_dDTFim) == _dAno 
		fDelPD("090") 
		fDelPD("091") 
		fGeraVerba("101",_nVal910,_nHrs910,,,"D","C",,,,.T.)     	
	endif


RETURN 
