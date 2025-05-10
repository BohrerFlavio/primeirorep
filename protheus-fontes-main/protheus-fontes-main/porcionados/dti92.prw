#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI92 º Autor ³ Fabian Ferreira Maurer º Data ³  19/11/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para Criar lotes de MP no Porcionados               º±±
±±º          ³ 														      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Porcionados                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function dti92()

	dbselectarea('SB1')
	dbsetorder(1)

	campoA   := Space(06)  //campo do codigo do produto
	campoB 	 := Space(40)  //campo da descrição do corte
	campoC 	 := 0		   //Quantidade de Peso
	campoD	 := date()	   //Data de Produção
	campoE   := date() 	   //Data do Abate

	valor1 	 := Space(06) //codigo do produto
	valor2 	 := Space(40) //Descrição do corte
	valor3 	 := 0         //Quantidade de Peso
	valor4	 := date() 	  //Data de Produção
	valor5	 := date()	  //Data de Abate

	DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "ROTINA PARA CRIAR LOTES PORCIONADOS"
	//vinculação dos campos com os valores

	@ 01,01 SAY "Cod. Produto:" of telaimp
	@ 02,01 SAY "Desc. Produto:" of telaimp
	@ 03,01 SAY "Quant. Peso:" of telaimp
	@ 04,01 SAY "Data Produção:" of telaimp
	@ 05,01 SAY "Data Abate:" of telaimp

	@ 01,08 MSGET campoA VAR valor1 SIZE 30,10 F3 'SB1' OF telaimp VALID ValProd(valor1) //iif(!existcpo('SB1'),ffm01clear(),.t.) .and.
	@ 02,08 SAY valor2 of telaimp
	@ 03,08 MSGET campoC VAR valor3 SIZE 50,10  OF telaimp  picture '@E 99999999.99'   // quant em Kilo
	@ 04,08 MSGET campoD VAR valor4 SIZE 30,10  OF telaimp   // Data de Produção
	@ 05,08 MSGET campoE VAR valor5 SIZE 30,10  OF telaimp   // Data de Abate

	@ 200,25 BUTTON btn1 PROMPT "Criar Lote" SIZE 50,15 OF telaimp  pixel action Criar()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()

	//campoA:bLostFocus := {|| dti92prc() }

	//oComboBo1:disable()
	//oComboBo1:hide()

	ACTIVATE MSDIALOG telaimp CENTERED

return

Static Function ValProd(_prod)

	local _cProd 	:= _prod
	local _cParam  := GETMV('SI_PRDPORC')

	if empty(_prod)
		dti92clear()
		return .t.
	endif

	if !(alltrim(_cProd) $ _cParam)
		alert('Produto não pode ser utilizado nessa rotina!!! ')
		dti92clear()
		return .t.
	endif

	if !empty(_cProd)
		SB1->(dbseek(xfilial('SB1')+_cProd))
		valor2 := SB1->B1_DESCRED
	else
		alert('Produto inexistente!')
	endif

return .t.

Static Function Criar()

	Local _nQpCaix := 0 //Quantidade Prevista de Caixa
	Local _nPmCaix := 0 // Peso médio da Caixa
	Local _nQpUni  := 0 //Quantidade Prevista Unidades
	Local _cPrdPor := valor1
	local _dDtProd := valor4
	local _dDtAbt  := valor5

	_nPmCaix := FBuscaCPO('SB1',1,xfilial('SB1')+_cPrdPor,'B1_PMCAIX')
	_nQpCaix := Valor3 / _nPmCaix

	_nQpUni := FBuscaCPO('SB1',1,xfilial('SB1')+_cPrdPor,'B1_QCAIX')

	_cNum := GetSx8num('ZAU','ZAU_NUM')
	ConfirmSx8()

	_cDescRed := FBuscaCPO('SB1',1,xfilial('SB1')+_cPrdPor,'B1_DESCRED')

	_cDesC := FBuscaCPO('SB1',1,xfilial('SB1')+_cPrdPor,'B1_DESC')

	_nCodTar := FBuscaCPO('SB1',1,xfilial('SB1')+_cPrdPor,'B1_CTARAP')
	_nTP := FBuscaCPO('ZAB',1,xfilial('ZAB')+_nCodTar,'ZAB_TARA')

	_dVal := FBuscaCPO('SB1',1,xfilial('SB1')+_cPrdPor,'B1_VALID')

	_cImpCom := FBuscaCPO('SB1',1,xfilial('SB1')+_cPrdPor,'B1_IMPCOM')

	_cLayEtq :=  FBuscaCPO('SB1',1,xfilial('SB1')+_cPrdPor,'B1_LAYETQ')

	_cMolde := FBuscaCPO('SB1',1,xfilial('SB1')+_cPrdPor,'B1_MOLDE')

	_nGrama := FBuscaCPO('SB1',1,xfilial('SB1')+_cPrdPor,'B1_GRAMAT')

	_nGramatu := FBuscaCPO( 'SB1' ,1,xfilial( 'SB1' ) + _cPrdPor, 'B1_GRAMATU' )
	_nGordura := FBuscaCPO( 'SB1' ,1,xfilial( 'SB1' ) + _cPrdPor, 'B1_GORDURA' )
	_nProcRot := FBuscaCPO( 'SB1' ,1,xfilial( 'SB1' ) + _cPrdPor, 'B1_PROCROT' )
	_nIngredi := FBuscaCPO( 'SB1' ,1,xfilial( 'SB1' ) + _cPrdPor, 'B1_INGREDI' )
	_nPORCI01 := FBuscaCPO( 'SB1' ,1,xfilial( 'SB1' ) + _cPrdPor, 'B1_PORCI01' )
	_nPORCI02 := FBuscaCPO( 'SB1' ,1,xfilial( 'SB1' ) + _cPrdPor, 'B1_PORCI02' )
	_nPORCI03 := FBuscaCPO( 'SB1' ,1,xfilial( 'SB1' ) + _cPrdPor, 'B1_PORCI03' )
	_nPORCI04 := FBuscaCPO( 'SB1' ,1,xfilial( 'SB1' ) + _cPrdPor, 'B1_PORCI04' )
	_nPORCI05 := FBuscaCPO( 'SB1' ,1,xfilial( 'SB1' ) + _cPrdPor, 'B1_PORCI05' )

	_cEanCli := FBuscaCPO('SB1',1,xfilial('SB1')+_cPrdPor,'B1_EANCLI')
	_cCodBar := FBuscaCPO('SB1',1,xfilial('SB1')+_cPrdPor,'B1_CODBAR')

	reclock('ZAU',.t.)
	ZAU->ZAU_FILIAL  := xfilial('ZAU')
	ZAU->ZAU_STATUS  := 'A'      //ok
	ZAU->ZAU_STATW   := 'A'      //ok
	ZAU->ZAU_STATT   := 'A'      //ok
	ZAU->ZAU_STATF   := 'A'      //ok
	ZAU->ZAU_NUM     := _cNum
	ZAU->ZAU_QPPESO  := Valor3   //ok
	ZAU->ZAU_QPCAIX  := _nQpCaix //ok
	ZAU->ZAU_QPUNI   := _nQpUni  //??
	ZAU->ZAU_QTDMP   := Valor3 // 	Não tem MP então vai o mesmo valor que vai ser produzido
	ZAU->ZAU_CODPI   := _cPrdPor
	ZAU->ZAU_CODMP   := _cPrdPor
	//ZAU->ZAU_QTDPI   := _nQtdPI
	ZAU->ZAU_DTPROD  := _dDtProd   //ok
	ZAU->ZAU_COD     := _cPrdPor 	 //OK
	ZAU->ZAU_PRCCLI  := _nPrcCli
	ZAU->ZAU_IMLOTE  := strtran(dtoc(_dDtProd),'/','')+substr(_cNum,5,6) //ok
	ZAU->ZAU_IMPROD  := _cDescRed //ok
	ZAU->ZAU_DESC    := alltrim(_cDesC) //ok
	ZAU->ZAU_IMTARA  := alltrim(transform(_nTP,'@E 9.999')) //ok
	ZAU->ZAU_TARA    := _nTP //ok
	ZAU->ZAU_IMVAL   := dtoc(_dDtProd + _dVAL) //ok
	ZAU->ZAU_IMPRC   := 0
	ZAU->ZAU_IMPCOM  := _cImpCom //ok
	ZAU->ZAU_LAYETQ  := alltrim(_cLayEtq) //ok
	ZAU->ZAU_DTABAT  := _dDtAbt //ok
	ZAU->ZAU_PROREF  := 'N' //ok
	ZAU->ZAU_WFW     := 'N' //ok
	ZAU->ZAU_MOLDE   := _cMolde //ok
	ZAU->ZAU_GRAMAT  := _nGrama //ok
	ZAU->ZAU_CTRLP   := 'L' //ok
	ZAU->ZAU_IMCBAR  := iif(!empty(_cEanCli),substr(_cEanCli,1,12),substr(_cCodBar,1,12))
	ZAU->ZAU_TIPOPR  := 'MP'

	ZAU->ZAU_GRAMATU := _nGramatu
	ZAU->ZAU_GORDURA := _nGordura
	ZAU->ZAU_PROCROT := _nProcRot
	ZAU->ZAU_INGREDI := _nIngredi
	ZAU->ZAU_PORCI01 := _nPORCI01
	ZAU->ZAU_PORCI02 := _nPORCI02
	ZAU->ZAU_PORCI03 := _nPORCI03
	ZAU->ZAU_PORCI04 := _nPORCI04
	ZAU->ZAU_PORCI05 := _nPORCI05

	msunlock()

	alert('Lote Criado com Sucesso!')
	dti92clear()

return

static function dti92clear()
	valor1   := Space(06)
	valor2   := Space(40)
	valor3   := 0
	valor4   := stod('')
	valor5	 := stod('')
	telaimp:refresh()
return
