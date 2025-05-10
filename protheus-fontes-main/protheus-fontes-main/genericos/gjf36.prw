#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF36     º Autor ³Giuliano Forgiarini º Data ³  10/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotinas de validações e automações em campos               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Rotinas do PCP em geral                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


//Validação na inclusão de um item de produto em
//um pre-pedido de venda
User Function gjf36b() 
	Local _cGrpMoi := ''
	Local _lMoi    := .f.
	Local _nRM     := 0
	Local _nPP     := 0
	Local _cTPorc  := ''

	if !empty(M->ZZ5_COD)
		M->ZZ5_COD  := padl(alltrim(M->ZZ5_COD),6,'0')
	endif
	if !existcpo('SB1')
		return .f.
	endif

	DbSelectArea('SB1')    
	SB1->(DbSetOrder(1))
	SB1->(Dbseek(xfilial('SB1') + M->ZZ5_COD))


	if cFilant = '00'

		_cGrpMoi := GetMV('SI_GRPMOI')

		_cPorc  := fBuscaCPO('SBM',1,xfilial('SBM') + SB1->B1_GRUPO,'BM_PORC')

		if SB1->B1_GRUPO $ _cGrpMoi
			_lMoi := .t.
		endif

		if !empty(_cPorc)
			//Verificação de campos básicos
			if SB1->B1_LOCPAD <> '01'
				Help(" ",1,"PORCIONADO",,"Campo B1_LOCPAD preenchido com informação errada!",4,1)
				return .f.
			elseif SB1->B1_SEGUM <> 'CX'
				Help(" ",1,"PORCIONADO",,"Segunda unidade de medida!(B1_SEGUM)",4,1)
				return .f.
			elseif SB1->B1_PMCAIX <= 0
				Help(" ",1,"PORCIONADO",,"Problema com o apontamento do peso medio da caixa!(B1_PMCAIX)",4,1)
				return .f.
			elseif SB1->B1_QCAIX <= 0
				Help(" ",1,"PORCIONADO",,"Problema com o apontamento da quantidade de itens por caixa!(B1_QCAIX)",4,1)
				return .f.
			elseif !_lMoi
				if empty(SB1->B1_CORORI)
					Help(" ",1,"PORCIONADO",,"Problema com o apontamento do corte de origem!(B1_CORORI)",4,1)
					return .f.
				endif
			elseif SB1->B1_PESBAND <= 0
				Help(" ",1,"PORCIONADO",,"Problema com o apontamento do peso por unidade!(B1_PESBAND)",4,1)
				return .f.
			elseif SB1->B1_QTBCAIX <= 0
				Help(" ",1,"PORCIONADO",,"Problema com o apontamento número de unidades por caixa!(B1_QTBCAIX)",4,1)
				return .f.
			endif

			if _lMoi

				SG1->(DbSetOrder(6))
				SG1->(DbGoTop())
				if SG1->(DbSeek(xfilial('SG1') + padr(alltrim(M->ZZ5_COD),15,'')+'RM' ))      //padl(alltrim(M->ZZ4_CODCLI),6,'0')

					while SG1->(!eof()) .and. SG1->G1_FILIAL = xfilial('SG1') .and. SG1->G1_COD = padr(alltrim(M->ZZ5_COD),15,'') .and. SG1->G1_TPPORC = 'RM'

						if SG1->G1_TPPORC = 'RM'
							_nRM++
						endif
						SG1->(dbSkip())
					enddo

				endif

				if _nRM  = 0
					Help(" ",1,"ESTRUTURA",,"Cadastro de itens da receita de moida!",4,1)
					return .f.
				endif

			else

				SG1->(DbSetOrder(1))
				SG1->(DbGoTop())
				if SG1->(DbSeek(xfilial('SG1') + M->ZZ5_COD))
					while SG1->(!eof()) .and. SG1->G1_FILIAL = xfilial('SG1') .and. SG1->G1_COD = M->ZZ5_COD

						_cTipoComp := fBuscaCPO('SB1',1,xfilial('SB1')+SG1->G1_COMP,'B1_TIPO')

						if _cTipoComp = 'PP' .and. SG1->G1_TPPORC = 'PP'

							//Achou o código do produto intermediário
							_cCodPInt := SG1->G1_COMP

							_nPP++
						endif

						SG1->(dbSkip())
					enddo
				endif

				if _nPP <> 1
					Help(" ",1,"ESTRUTURA",,"Cadastro de PP na estrutura do produto (Verificar os campos G1_TPPORC e B1_TIPO)!",4,1)
					return .f.
				endif

				//Acha o código da matéria-prima
				_cMP  := fBuscaCPO('SG1',1,xfilial('SG1') + _cCodPInt,'G1_COMP')

				if empty(_cMP)
					Help(" ",1,"ESTRUTURA",,"Cadastro de MP na estrutura do produto não encontrada!",4,1)
					return .f.
				endif

				_cTPorc  := fBuscaCPO('SG1',1,xfilial('SG1') + _cMP,'G1_TPPORC')

				if _cTPorc <> 'MP'
					Help(" ",1,"ESTRUTURA",,"Cadastro de MP na estrutura do produto (Verificar o campo G1_TPPORC)!",4,1)
					return .f.
				endif
			endif

		endif
	endif

return .t.

//Função auxiliar para digitar e validar o codigo do produto
//na previsão de produção de embalagem (gjf24)
User Function GJF36c()

	if !empty(M->ZU_COD)
		M->ZU_COD  := padl(alltrim(M->ZU_COD),6,'0')
	endif
	if !existcpo('SB1')
		return .f.
	endif

	DbSelectArea('SB1')
	_cGrupo    := fBuscaCPO('SB1',1,xfilial('SB1')+M->ZU_COD,'B1_GRUPO')
	_cCodTara  := fBuscaCPO('SB1',1,xfilial('SB1')+M->ZU_COD,'B1_CTARASE')    

	DbSelectArea('ZAB')
	_cProdut := fBuscaCPO('ZAB',1,xfilial('ZAB')+_cCodTara,'ZAB_PRODUT')

	//Verifica se é do grupo de MP para moida recorte	
	if _cGrupo <> '4007'

		SG1->(DbSetOrder(1))
		SG1->(DbGoTop())
		if  !SG1->(DbSeek(xfilial('SG1')+ M->ZU_COD))
			msgbox('Produto sem estrutura cadastrada','CADASTRO INCOMPLETO!','INFO')
			return .f.
		endif

	endif
	/*
	if !(_cGrupo $ '4006/4007')
	ZZ7->(DbSetOrder(1))
	if !ZZ7->(DbSeek(xfilial('ZZ7') + M->ZU_COD))
	msgbox('Produto sem cadatro de Etiqueta Interna!','CADASTRO INCOMPLETO!','INFO')
	endif
	endif
	*/
	if empty(_cProdut)
		msgbox('Necessários o apontamento do codigo de Tara Secundaria no cadastro de produto!','CADASTRO INCOMPLETO!','INFO')
		return .f.
	endif

	//Verifica se o codigo das taras está preenchido com o codigo dos produtos de caixas

return .t.


User Function GJF36d()

	if !empty(M->ZU_PREDES)

		if empty(M->ZU_COD) .and.  !empty(M->ZU_PREDES)
			alert('Produto não informado!')
			return .f.
		endif

		if !empty(M->ZU_PREDES)
			M->ZU_PREDES  := padl(alltrim(M->ZU_PREDES),10,'0')
			_cPreDes      := padl(alltrim(M->ZU_PREDES),10,'0')
		endif

		_cCorOri:= fBuscaCPO('SB1',1,xfilial('SB1')+M->ZU_COD,'B1_CORORI')
		_cCorte := alltrim(fBuscaCPO('SZ2',2,xfilial('SZ2')+_cPreDes,'Z2_CORORI'))

		if _cCorOri $ 'R/E/P'
			return .t.
		endif

		Do case
			case _cCorte = 'T'
			if _cCorOri <> 'T'
				alert('Produto a ser produzido não condiz com previsão de desossa!')
				return .f.
			endif
			case _cCorte = 'D'
			if _cCorOri <> 'D'
				alert('Produto a ser produzido não condiz com previsão de desossa!')
				return .f.
			endif
		endcase

		if !existcpo('SZ2')
			return .f.
		endif

	endif
return .t.

//Utilizado na correlação de codigos para EDI
User Function GJF36e()
	if !empty(M->ZA1_COD)
		M->ZA1_COD  := padl(alltrim(M->ZA1_COD),6,'0')
	endif
	if !existcpo('SB1')
		return .f.
	endif

return .t.

//Utilizado na correlação de codigos para EDI
User Function GJF36f()
	if !empty(M->ZA1_CODCLI)
		M->ZA1_CODCLI  := padl(alltrim(M->ZA1_CODCLI),14,'0')
	endif

return .t.

//Utilizado para buscar o Gerente do vendedor para Pedido de Venda
User Function GJF36G()
	local _cCliLj := M->(C5_CLIENTE+C5_LOJACLI)
	Local _cVend  := ''
	Local _cGeren := ''
	Local _nComis := 0

	_cVend  := Fbuscacpo('SA1',1,xfilial('SA1')+_cCliLj,'A1_VEND')
	_cGeren := Fbuscacpo('SA3',1,xfilial('SA3')+_cVend,'A3_GEREN')

	if !Empty(_cGeren)
		_nComis := Fbuscacpo('SA3',1,xfilial('SA3')+_cGeren,'A3_COMIS')
		M->C5_COMIS2 := _nComis
	endif

return _cGeren

User Function GJF36h()
	M->N1_VLAQUIS := M->D1_TOTAL
return .t.


User Function GJF36i()
	if !empty(M->DA1_CODPRO)
		M->DA1_CODPRO  := padl(alltrim(M->DA1_CODPRO),6,'0')
	endif 


	//As funções abaixo foram tiradas da validação padrão do campo
	if !A093Prod() .or. !OmsaGrPrd()
		return .f.
	endif 

return .t.

//Função para bloquear a troca de condição de pagamento ao classificar uma pre-nota
User Function GJF36j()
	local area  := getarea()
	Local ret   := .t.
	if FunName() $ 'MATA103'
		SF1->(DbSetOrder(1))
		if SF1->(DbSeek(xfilial('SF1')+CNFISCAL+CSERIE+CA100FOR+CLOJA)) .and. empty(SF1->F1_STATUS) .and. !empty(CCONDICAO)
			SD1->(DbSetOrder(1))
			SD1->(DbSeek(xfilial('SD1')+CNFISCAL+CSERIE+CA100FOR+CLOJA))  
			SC7->(DbSetOrder(1))
			if SC7->(DbSeek(xfilial('SC7') + SD1->(D1_PEDIDO+D1_ITEMPC))) 
				if CCONDICAO <> SC7->C7_COND
					CCONDICAO := SC7->C7_COND
					ret := .f.  
				endif
			endif
		endif   
	endif

	restarea(area)

return ret    

User Function GJF36k()
	if !empty(M->ZY_COD)
		M->ZY_COD  := padl(alltrim(M->ZY_COD),6,'0')
	endif
	if !existcpo('SB1')
		return .f.
	endif

	dbselectarea('SB1')
	_cTipo := FBuscaCPO('SB1',1,xfilial('SB1')+M->ZY_COD,'B1_TIPO')

	if _cTipo <> 'PA'
		return .f.
	endif 

return .t.   

//Sugere o local padrão de armazenamento 
//conforme o grupo de produto
User Function GJF36L()
	Local _cLoc := ''

	do case
		case M->B1_GRUPO = '4006'                //MP Porcionados Propria
		_cLoc := '20'
		case M->B1_GRUPO = '1004'                //MP porcionados 
		_cLoc := '21'
		case substr(M->B1_GRUPO,1,2) = '40'      //PP porcionados
		_cLoc := '22'
		case substr(M->B1_GRUPO,1,3) = '561'    //PA porcionados
		_cLoc := '23'
		case substr(M->B1_GRUPO,1,3) = '562'    //PA porcionados
		_cLoc := '24' 
		case substr(M->B1_GRUPO,1,2) = '12'     //Material de embalagem	
		_cLoc := '02'                                              
		case M->B1_GRUPO = '1306'               //Material de TI
		_cLoc := '07'
		otherwise       
		if !empty(M->B1_LOCPAD)
			_cLoc := M->B1_LOCPAD		
		else 	
			_cLoc := '01'		
		endif		
	endcase


return _cLoc 

user function gjf36M()

	if !empty(M->ZZ5_PRDALT)
		M->ZZ5_PRDALT  := padl(alltrim(M->ZZ5_PRDALT),6,'0')
	endif

	ZAL->(dbSetOrder(1))
	ZAL->(dbGoTop())                                
	if !ZAL->(dbSeek(xFilial('ZAL') + padr(alltrim(gdFieldGet('ZZ5_COD')),14,"") + padr(alltrim(M->ZZ5_PRDALT),14,"")))
		alert('Não há correlação de produto alternativo cadastrado!')
		return .f.
	endif

return .t.


/*/{Protheus.doc} User Function blqCxEmb
	(Função para bloquear previsão de caixas na op de embalagem)
	@type  Function
	@author Mauricio Roehrs
	@since 24/01/2023
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
User Function blqCxEmb(_cCodProd,_cPriori)

	local _cOk := 'ok'

	_cCadMerc    := fBuscaCPO('SB1',1,xfilial('SB1')+_cCodProd,'B1_CADMERC')

	if alltrim(_cCadMerc) == 'U'
		_cOk := 'nOk'
	elseif _cPriori == 'E'
		_cOk := 'nOk'
	endif
	
Return _cOk
	
