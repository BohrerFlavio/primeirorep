#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MRVT09     ºAutor  ³Mauricio Roehrs     º Data ³  18/11/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Programa desenvolvido para conferencia de produção na    º±±
±±º          ³ embalagem                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MRVT09(_usuario)

	Private _cModelo  := ''
	Private _lOk      := .t.
	Private _cProd	   := space(10)
	Private _cPetq		:= space(12)
	Private _cCodOk	:= ''

	ZAA->(DbSetOrder(2))
	ZAA->(DbSeek(xfilial('ZAA')+_usuario))

	if ZAA->ZAA_APL10 <> 'S'
		VTAlert('Opção negada para o usuario!','Aviso',.T.,1000,1)
		return .t.
	endif


	//Define o tamanho da Tela
	_cModelo = VTModelo()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	VTClear()
	VTClearBuffer()

	while _lOk


		VTRead

		@ 01,00 VTSay "Validacao de Producao"
		@ 05,05 VTSay "Codigo da Pesagem"
		@ 06,08 VTSay "[          ]" 
		@ 07,05 VTSay "Codigo da Pre-Etq"
		@ 08,08 VTSay "[            ]"
		@ 06,09 VTGet _cProd Pict "@! " VALID ValProd()
		@ 08,09 VTGet _cPetq Pict "@! " VALID ValPetq()

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		_cProd  := space(10)
		_cPetq  := space(12)
		_cCodOk := ''      


		VTClearBuffer()
	enddo

	VTClear()
	VTClearBuffer()      

return 

Static Function ValProd()

	Local _lOk := .f.

	if empty(_cProd)
		return .f.
	endif

	_cCodOk := ''

	SZ8->(DbGoTop())
	SZ8->(DbSetOrder(3))
	if SZ8->(DbSeek(xFilial('SZ8') + _cProd))
		_cCodOk := _cProd	     
		_lOk := .t. 
	else 	                                 
		VTAlert('Caixa nao encontrada!!','ATENCAO!!',.T.,1000,1)  
		_cProd := ''
		_cProd := space(10)
		@ 12,05 VTSay space(20)
		_lOk := .f.		
	endif          

return _lOk

Static Function ValPetq()

	Local _lOk := .f.

	if empty(_cPetq)
		return .f.
	endif

	SZ8->(DbGoTop())
	SZ8->(DbSetOrder(16))
	if SZ8->(DbSeek(xFilial('SZ8') + substr(_cPetq,7,12) + dtos(dDataBase))) .and.  _cCodOk == SZ8->Z8_CONTROL 
		@ 12,05 VTSay "Conferencia OK"					
		//VTAlert('Conferencia OK!!','ATENCAO!!',.T.,1000,1)			
		_lOk 	  := .t.			
	else
		@ 12,05 VTSay space(20)
		VTAlert('Conferencia Divergente!!','ATENCAO!!',.T.,1000,1)
		_lOk 	  := .t. 		
	endif           

return _lOk
