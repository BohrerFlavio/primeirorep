#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CalcFrete º Autor ³ MARCEL V. MARIANI  º Data ³  03/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ FUNCAO USADA PARA CALCULAR VALOR DO FRETE NA ROTINA        º±±
±±º          ³ f_PCP010                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CalcFrete(Opcao)

	Local	cValFrete := 0
	Local	cKMFrete  := 0
	Private ret

	cKMFrete := GDFieldGet('ZS_DCHPREV',n)+GDFieldGet('ZS_DASFPR',n) //(M->ZS_DCHPREV + M->ZS_DASFPR)

	//cKMFrete := cKMFrete/2 

	SZH->( dbSetOrder(2) )  
	SZH->( dbSeek(xFilial('SZH') + SZD->ZD_TRANSP + GDFieldGet('ZS_VEIC',n)))

	Do Case
		Case ( cKMFrete <= SZH->ZH_KM1 ) .And. (SZH->ZH_CALC1 == "T")  
		cValFrete := SZH->ZH_VL1 
		Case ( cKMFrete <= SZH->ZH_KM1 ) .And. (SZH->ZH_CALC1 == "M")
		cValFrete := (SZH->ZH_VL1 * cKMFrete)
		Case ( cKMFrete > SZH->ZH_KM1 ) .And. ( cKMFrete <= SZH->ZH_KM2 ) .And. (SZH->ZH_CALC2 == "T")
		cValFrete := SZH->ZH_VL2
		Case ( cKMFrete > SZH->ZH_KM1 ) .And. ( cKMFrete <= SZH->ZH_KM2 ) .And. (SZH->ZH_CALC2 == "M")
		cValFrete := (SZH->ZH_VL2 * cKMFrete)		
		Case ( cKMFrete > SZH->ZH_KM2 ) .And. ( cKMFrete <= SZH->ZH_KM3 ) .And. (SZH->ZH_CALC3 == "T")
		cValFrete := SZH->ZH_VL3
		Case ( cKMFrete > SZH->ZH_KM2 ) .And. ( cKMFrete <= SZH->ZH_KM3 ) .And. (SZH->ZH_CALC3 == "M")
		cValFrete := (SZH->ZH_VL3 * cKMFrete)		
	EndCase

Return cValFrete
