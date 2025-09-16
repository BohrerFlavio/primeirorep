#INCLUDE "rwmake.ch"

User Function FB_RH1CTB()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ FB_RH1CTB³ Autor ³ Evandro Mugnol        ³ Data ³ 09.11.11 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Contabilizacao da folha de pagamento utilizado nos lanctos ³±±
	±±³          ³ padroes AXX                                                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³ Especifico para Frigorifico Silva                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   Data   ³ Programador   ³Manutencao Efetuada                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	if cEmpAnt = '08'

		_aArea := GetArea()

		_cCtaAdm  := Space(20)
		_cCtaCom  := Space(20)
		_cCtaSer  := Space(20)
		_cCtaCred := Space(20)

		_cVerba   := SRZ->RZ_PD
		_cCCusto  := SRZ->RZ_CC

		DbSelectArea("SRV")
		DBSetorder(1)
		DbSeek(xFilial("SRV") + _cVerba)
		If Found()
			_cCtaPrd  := SRV->RV_CTAPRD
			_cCtaAdm  := SRV->RV_CTAADM
			_cCtaCom  := SRV->RV_CTACOM
		Else
			MsgAlert("Nao foi encontrado contas contabeis para a Verba " + _cVerba)
		Endif

		If Left(_cCCusto,3) == "112"               // Centros de Custo do Setor Comercial
			_cConta := _cCtaCom
		ElseIf Left(_cCCusto,3) == "111"           // Centros de Custo do Setor Administração
			_cConta := _cCtaAdm
		ElseIf Left(_cCCusto,3) == "113"           // Centros de Custo do Setor Produção
			_cConta := _cCtaPrd
		Else
			_cConta := _cCtaCred
		Endif

		RestArea(_aArea)
	endif

	/* 
	
	Inclusão feita por solicitação do Claudioir dia 17/01/19 para Contabilização 
	Testar no frigo e transp
	Compilar quando Fabiane Liberar 
	Dia 20/05/19 - Efetuando testes
	*/
	//-- Início do ajuste
/*
	if cEmpAnt = '01'
		
		_aArea := GetArea()

		_cCtaDPr  := Space(20) // RV_CTDFPRO
		_cCtaDCo  := Space(20) // RV_CTDFCOM
		_cCtaDAd  := Space(20) // RV_CTDFADM
		
		_cCtaCPr := Space(20)  // RV_CTCFPRO
		_cCtaCCm := Space(20)  // RV_CTCFCOM
		_cCtaCAd := Space(20)  // RV_CTCFADM
						
		_cCtaCCo := Space(20)  // RV_CTCFCON
		_cCtaCFr := Space(20)  // RV_CTCFMTR
		_cCtaCRG := Space(20)  // RV_CTCFRGR
		
		_cCtaDFr := Space(20)  // RV_CTDFMTR
		_cCtaDRG := Space(20)  // RV_CTDFRGR
		_cCtaDCo := Space(20)  // RV_CTDFCON
		
		_cVerba   := SRZ->RZ_PD
		_cCCusto  := SRZ->RZ_CC
		
		DbSelectArea("SRV")
		DBSetorder(1)
		DbSeek(xFilial("SRV") + _cVerba)
		
		If Found()
			
			_cCtaDPr  := SRV->RV_CTDFPRO  // Conta Debito Produção Frigo
			_cCtaDCo  := SRV->RV_CTDFCOM  // Conta Debito Comercial Frigo
			_cCtaDAd  := SRV->RV_CTDFADM  // Conta Debito Administrativo Frigo
			
			_cCtaCPr := SRV->RV_CTCFPRO  // nao vai cc
			_cCtaCCm := SRV->RV_CTCFCOM  // nao vai cc
			_cCtaCAd := SRV->RV_CTCFADM  // nao vai cc
					
			_cCtaCCo := SRV->RV_CTCFCON  // nao vai cc
			_cCtaCFr := SRV->RV_CTCFMTR  // nao vai cc
			_cCtaCRG := SRV->RV_CTCFRGR  // nao vai cc
			
			_cCtaDFr := SRV->RV_CTDFMTR // Conta Debito Frigorífico
			_cCtaDRG := SRV->RV_CTDFRGR // Conta Debito Rio Grande
			_cCtaDCo := SRV->RV_CTDFCON // Conta Debito COnfinamento
			
		Else
			MsgAlert("Nao foi encontrado contas contabeis para a Verba " + _cVerba)
		Endif
		
		
		if cFilAnt = '01'
		
			If Left(_cCCusto,3) == "113"            // Centros de Custo do Setor ...
				_cConta := _cCtaDPr					// SRV->RV_CTDFPRO						
			ElseIf Left(_cCCusto,3) == "112"        // Centros de Custo do Setor ...
				_cConta := _cCtaDCo					// SRV->RV_CTDFCOM				
			ElseIf Left(_cCCusto,3) == "111"        // Centros de Custo do Setor ...
				_cConta := _cCtaDAd					// SRV->RV_CTDFADM					
			Elseif Left(_cCCusto,3) == "113"  			// Centros de Custo do Setor ...
				_cConta := _cCtaCPr					// SRV->RV_CTCFPRO				
			Elseif Left(_cCCusto,3) == "112"  		// Centros de Custo do Setor ...
				_cConta := _cCtaCCm					// SRV->RV_CTCFCOM
			Elseif Left(_cCCusto,3) == "111"  			// Centros de Custo do Setor ...
				_cConta := _cCtaCAd					// SRV->RV_CTCFADM				
			Endif
			
			
		elseif cFilAnt = '02'
			
			If Left(_cCCusto,3) == "123"            // Centros de Custo do Setor ...
				_cConta := _cCtaDPr					// SRV->RV_CTDFPRO							
			ElseIf Left(_cCCusto,3) == "122"        // Centros de Custo do Setor ...
				_cConta := _cCtaDCo					// SRV->RV_CTDFCOM
			ElseIf Left(_cCCusto,3) == "121"        // Centros de Custo do Setor ...
				_cConta := _cCtaDAd					// SRV->RV_CTDFADM					
			endif
			
			
		elseif cFilAnt = '03'
			
			If Left(_cCCusto,3) == "133"            // Centros de Custo do Setor ...
				_cConta := _cCtaDPr					// SRV->RV_CTDFPRO									
			endif
			
		Endif
								
		RestArea(_aArea)
				
	endif
	
	
	if cEmpAnt = '07'
		
		_aArea := GetArea()

		_cCtaDPr  := Space(20) // RV_CTDTADM  - Cta. Deb. Adm.
		_cCtaDCo  := Space(20) // RV_CTCTADM - Cta. Cred.Adm.
		
		_cVerba   := SRZ->RZ_PD
		_cCCusto  := SRZ->RZ_CC

		DbSelectArea("SRV")
		DBSetorder(1)
		DbSeek(xFilial("SRV") + _cVerba)
		
		If Found()
			
			_cCtaDPr  := SRV->RV_CTDTADM 
			_cCtaDCo  := SRV->RV_CTCTADM
			
		Else
			MsgAlert("Nao foi encontrado contas contabeis para a Verba " + _cVerba)
		Endif
		// Falta Fabiane me ajudar nos centros de custo aqui 
		If Left(_cCCusto,3) == ""               // Centros de Custo do Setor 
			_cConta := _cCtaDPr
		ElseIf Left(_cCCusto,3) == "111"           // Centros de Custo do Setor 
			_cConta := _cCtaDCo
		
		Endif

		RestArea(_aArea)
		
	Endif
	//-- Fim do ajuste 
	*/
	
Return(_cConta)
