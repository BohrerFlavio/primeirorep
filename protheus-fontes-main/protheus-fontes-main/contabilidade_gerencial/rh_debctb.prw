#INCLUDE "PROTHEUS.CH"

User Function RH_DEBCTB()
cAlias:=Alias()


_cCtaDFr := Space(20)  // RV_CTDFMTR Débito Produção Matriz.
_cCtaDPr  := Space(20) // RV_CTDFPRO Débito Produção Filial
_cCtaDCo  := Space(20) // RV_CTDFCOM Débito Comercial Matriz
_cCtaDCG := Space(20)  // RV_CTDFCON Débito Comercial Filial
_cCtaDAd  := Space(20) // RV_CTDFADM Débito Administração Matriz
_cCtaDRG := Space(20)  // RV_CTDFRGR Débito Administração Filial
_cCtaCPr := Space(20)  // RV_CTCFPRO Crédito Produção Filial
_cCtaCFr := Space(20)  // RV_CTCFMTR Crédito Produção filial
_cCtaCCm := Space(20)  // RV_CTCFCOM Crédito Comercial Matriz
_cCtaCCo := Space(20)  // RV_CTCFCON Crédito Comercial filial
_cCtaCAd := Space(20)  // RV_CTCFADM Crédito Administração Matriz
_cCtaCRG := Space(20)  // RV_CTCFRGR Crédito Administração filial
_cCtaDPrT := Space(20) // Débito produção
_cCtaDbcT := Space(20) // Débito Comercial
_cCtaDbaT := Space(20) // Débito Administração
_cCtacPrT := Space(20) // crédito produção
_cCtacrcT := Space(20) // rédito Comercial
_cCtacraT := Space(20) // crédito Administração
_cCtaAdm  := Space(20)
_cCtaCom  := Space(20)
_cCtaSer  := Space(20)
_cCtaCred := Space(20)



_cConta    :=space(20)
_cVerba   := SRZ->RZ_PD
_cCCusto  := ALLTRIM(SRZ->RZ_CC)

DbSelectArea("SRV")
DBSetorder(1)
DbSeek(xFilial("SRV") + _cVerba)

If Found()
	
	_cCtaDPr  := SRV->RV_CTDFPRO  // RV_CTDFPRO Débito Produção Filial
	_cCtaDCo  := SRV->RV_CTDFCOM  // RV_CTDFCOM Débito Comercial Matriz
	_cCtaDAd  := SRV->RV_CTDFADM  // RV_CTDFADM Débito Administração Matriz
	_cCtaDFr  := SRV->RV_CTDFMTR // RV_CTDFMTR Débito Produção Matriz
	_cCtaDCG  := SRV->RV_CTDFCON // RV_CTDFCON Débito Comercial Filial
	_cCtaDRG  := SRV->RV_CTDFRGR // RV_CTDFRGR Débito Administração Filial
	_cCtaDPrT := SRV->RV_CTDTPRO  // Débito produção
	_cCtaDbcT := SRV->RV_CTDTCOM //Débito Comercial
	_cCtaDbaT := SRV->RV_CTDTADM //Débito Administração
	_cCtacPrT := SRV->RV_CTCTPRO//  crédito produção
	_cCtacrcT := SRV->RV_CTCTCOM //crédito Comercial
	_cCtacraT := SRV->RV_CTCTADM   //crédito Administração
	_cCtaPrd  := SRV->RV_CTAPRD
	_cCtaAdm  := SRV->RV_CTAADM
	_cCtaCom  := SRV->RV_CTACOM
	
Endif

IF cEmpAnt = '01''
	
	If Left(_cCCusto,3) == "113"
		/*Regra de Contabilização INSS 13 Patronal*/
		if mv_par02 = 2 .AND. _cVerba $ '742|743|744'
			_cConta := '4102024002'
		else
			_cConta := _cCtaDFr
		Endif
	
		//_cConta := _cCtaDFr					//RV_CTDFMTR Débito Produção Matriz
	ElseIf Left(_cCCusto,3) == "112"
		/*Regra de Contabilização INSS 13 Patronal*/
		if mv_par02 = 2 .AND. _cVerba $ '742|743|744'
			_cConta := '4103014002'
		else	
			_cConta := _cCtaDCo
		Endif
		
		//_cConta := _cCtaDCo				// RV_CTDFCOM Débito Comercial Matriz
	ElseIf Left(_cCCusto,3) == "111"
		if mv_par02 = 2 .AND. _cVerba $ '742|743|744'
			_cConta := '4104014002'
		else
			_cConta := _cCtaDAd
		Endif		
		//_cConta := _cCtaDAd				// RV_CTDFADM Débito Administração Matriz
	Endif
Endif

IF cEmpAnt = '01'
	
	If Left(_cCCusto,3) == "123"
		
		/*Regra de Contabilização INSS 13 Patronal*/
		if mv_par02 = 2 .AND. _cVerba $ '742|743|744'
			_cConta := '4102024002'
		else		
			_cConta := _cCtaDPr
		Endif
		//_cConta := _cCtaDPr				// RV_CTDFPRO Débito Produção Filial
	ElseIf Left(_cCCusto,3) == "122"
		/*Regra de Contabilização INSS 13 Patronal*/
		if mv_par02 = 2 .AND. _cVerba $ '742|743|744'
			_cConta := '4103014002'
		else
			_cConta := _cCtaDCG
		Endif
		//_cConta := _cCtaDCG					// RV_CTDFCON Débito Comercial Filial
	ElseIf Left(_cCCusto,3) == "121"
		
		/*Regra de Contabilização INSS 13 Patronal*/
		if mv_par02 = 2 .AND. _cVerba $ '742|743|744'
			_cConta := '4104014002'
		else
			_cConta := _cCtaDRG
		Endif
		//_cConta := _cCtaDRG					// RV_CTDFRGR Débito Administração Filial
	endif
	
endif


if cEmpAnt = '07'
	
	If Left(_cCCusto,3) == ""               // Centros de Custo do Setor
		_cConta := _cCtaDPrT
	ElseIf Left(_cCCusto,3) == "111"           // Centros de Custo do Setor
		_cConta := 	_cCtaDPrT
Endif
Endif

if cEmpAnt = '08'
	
	If Left(_cCCusto,3) == "112"               // Centros de Custo do Setor Comercial
		_cConta := _cCtaCom
	ElseIf Left(_cCCusto,3) == "111"           // Centros de Custo do Setor Administração
		_cConta := _cCtaAdm
	ElseIf Left(_cCCusto,3) == "113"           // Centros de Custo do Setor Produção
		_cConta := _cCtaPrd

	endif
Endif
DbSelectArea(cAlias)
Return(_cConta)
