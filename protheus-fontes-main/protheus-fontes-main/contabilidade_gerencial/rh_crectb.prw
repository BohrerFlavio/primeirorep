#INCLUDE "PROTHEUS.CH"

User Function RH_CRECTB()
	
cAlias:=Alias()

_cCtCrPr  := Space(20)  // RV_CTDFMTR Débito Produção Matriz.
_cCtCrPF  := Space(20)   
_cCtCrAF  := Space(20)  
_cCtCrCO  := Space(20)
_cCtCrAM  := Space(20)
_cCtCrAD  := Space(20)
/*  GUIA cONTABILIZAÇÃO INDUSTRIA*/
_cCtCPRO  := Space(20)
_cCtCCOM  := Space(20)
_cCtCRED  := Space(20)
/*  GUIA cONTABILIZAÇÃO TRANSPORTADORA */
_cCtPROD  := Space(20)
_cCCCOM   := Space(20)
_cCtCADM  := Space(20)



_cConta    :=space(20)
_cVerba   := SRZ->RZ_PD
_cCCusto  := ALLTRIM(SRZ->RZ_CC)

//if !pergunte(cPerg,.t.)
//		return
//endif


DbSelectArea("SRV")
DBSetorder(1)
DbSeek(xFilial("SRV") + _cVerba)

If Found()
	
	/*  GUIA cONTABILIZAÇÃO */
	_cCtCrPr  := SRV->RV_CTCFMTR   
	_cCtCrPF  := SRV->RV_CTCFPRO   
	_cCtCrAF  := SRV->RV_CTCFCOM  
	_cCtCrCO  := SRV->RV_CTCFCON
	_cCtCrAM  := SRV->RV_CTCFADM
	_cCtCrAD  := SRV->RV_CTCFRGR
	/*  GUIA cONTABILIZAÇÃO INDUSTRIA*/
	_cCtCPRO  := SRV->RV_CTCGPRO
	_cCtCCOM  := SRV->RV_CTACRED
	_cCtCRED  := SRV->RV_CTCGADM
	
	/*  GUIA cONTABILIZAÇÃO TRANSPORTADORA */
	_cCtPROD  := SRV->RV_CTCTPROD
	_cCCCOM   := SRV->RV_CTCTCOM
	_cCtCADM  := SRV->RV_CTCTADM
Endif

IF cEmpAnt = '01''
	
	If Left(_cCCusto,3) == "113"
		//_cConta := _cCtaDFr					//RV_CTDFMTR Débito Produção Matriz
	
			_cConta := _cCtCrPr
		
	ElseIf Left(_cCCusto,3) == "112"
		//_cConta := _cCtaDCo				// RV_CTDFCOM Débito Comercial Matriz
			
			_cConta := _cCtCrAF
		
	ElseIf Left(_cCCusto,3) == "111"
		
			_cConta := _cCtCrAM
		
		
	Endif
	
Endif

IF cEmpAnt = '01'
	
	If Left(_cCCusto,3) == "123"
		
		//_cConta := _cCtaDPr				// RV_CTDFPRO Débito Produção Filial	
				
			_cConta := _cCtCrPF
		
		
	ElseIf Left(_cCCusto,3) == "122"
		
		//_cConta := _cCtaDCG			   // RV_CTDFCON Débito Comercial Filial
		
			_cConta := _cCtCrCO
			
						
	ElseIf Left(_cCCusto,3) == "121"
		//_cConta := _cCtaDRG					// RV_CTDFRGR Débito Administração Filial
		
			_cConta := _cCtCrAD
		
	
	endif
	
endif

if cEmpAnt = '07'
	
	If Left(_cCCusto,3) == ""              	
		_cConta := _cCtPROD
	ElseIf Left(_cCCusto,3) == "111"         
		_cConta := _cCtPROD
		
	Endif
Endif

if cEmpAnt = '08'
	
	If Left(_cCCusto,3) == "112"               // Centros de Custo do Setor Comercial
		
		_cConta := _cCtCCOM
	ElseIf Left(_cCCusto,3) == "111"           // Centros de Custo do Setor Administração
		
		_cConta := _cCtCRED
	ElseIf Left(_cCCusto,3) == "113"           // Centros de Custo do Setor Produção
		_cConta := _cCtCPRO

	endif
Endif
DbSelectArea(cAlias)
Return(_cConta)
