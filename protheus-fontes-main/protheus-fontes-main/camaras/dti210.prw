/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI201            º Autor ³ Lucas Bolzan º Data ³ 04/04/24  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Coloca em estoque as cCxaBizs geradas pela linha 5 Bizerba º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Porcionados                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

USER FUNCTION DTI210(cCxaBiz, cCamara)
	DBSelectArea('ZAS')
	DBSetOrder(15)
	if ZAS->(MsSeek(FWxfilial('ZAS')+alltrim(cCxaBiz)))
		reclock('SZ8',.t.)
			SZ8->Z8_FILORI    := cFilAnt
			SZ8->Z8_FIL       := cFilAnt
			SZ8->Z8_FILIAL    := FWxfilial('SZ8')
			SZ8->Z8_ID        := substr(ZAS->ZAS_CONTRO,3,8)
			SZ8->Z8_CONTROL   := ZAS->ZAS_CONTRO
			SZ8->Z8_CODORI    := ZAS->ZAS_COD
			SZ8->Z8_COD       := ZAS->ZAS_COD
			SZ8->Z8_DATA      := ZAS->ZAS_DTPROD
			SZ8->Z8_DATAP     := ZAS->ZAS_DTPROD
			SZ8->Z8_HORA      := ZAS->ZAS_HORA
			SZ8->Z8_TIPO      := 'P'
			SZ8->Z8_TF        := 'N'
			SZ8->Z8_QUANT     := GetAdvFVal('SB1','B1_QTBCAIX',FWxfilial('SB1')+ZAS->ZAS_COD,1)
			SZ8->Z8_PESO      := ZAS->ZAS_PESOL
			SZ8->Z8_TARA      := ZAS->ZAS_TARA
			SZ8->Z8_PESOBR    := ZAS->ZAS_PESOB
			SZ8->Z8_ETIQ      := 'P'
			SZ8->Z8_DATAVAL   := ZAS->ZAS_DTPROD + ZAS->ZAS_VALID
			SZ8->Z8_DESCRI    := GetAdvFVal('SB1','B1_DESCRED',FWxfilial('SB1')+ZAS->ZAS_COD,1)
			SZ8->Z8_DTENTES   := date()
			SZ8->Z8_LOTEPOR   := ZAS->ZAS_LOTE
			SZ8->Z8_BATEL  	  := ZAS->ZAS_BATEL
			SZ8->Z8_PALLET    := ''
			//SZ8->Z8_PREPORC   := ZAS->ZAS_PREPOR
			//SZ8->Z8_NUMPREV   := ZAS->ZAS_PREEMB
			//SZ8->Z8_PREDES    := ZAS->ZAS_PREDES
			SZ8->Z8_INV 	  := 'X'
			SZ8->Z8_PESFIX    := ZAS->ZAS_PESFIX
			SZ8->Z8_ORIGEM    := 'P'
			SZ8->Z8_BALAN     := ZAS->ZAS_LIN
			SZ8->Z8_LOCAL 	  := AllTrim(cCamara)
			SZ8->Z8_CHKCARR   := ''
			SZ8->Z8_CHKPCAR   := ''
			SZ8->Z8_SETPRO    := ZAS->ZAS_SETPRO
			SZ8->Z8_FARM      := ZAS->ZAS_FARM
			SZ8->Z8_SEQBIZE   := AllTrim(cCxaBiz)
		msunlock()
	
		reclock('ZAS',.f.)
		DbDelete()
		msunlock()
	endif
RETURN ZAS->ZAS_CONTRO
