#INCLUDE "rwmake.ch" 
#INCLUDE "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF140    º Autor ³ Giuliano Forgiariniº Data ³  30/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Processamento de distribuição de carcaças                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF140()
	local nOpca	:=0
	local aSays:={}, aButtons:={}

	Private cCadastro := "Processamento de distribuição de carcaças"
	Private _lOk      := .t.
	Private cPerg     := "GJF140"

	AADD (aSays, "  Esta rotina tem como objetivo realizar a distribuição de  ")  //
	AADD (aSays, "  carcaças (traseiro, dianteiro e costela) de acordo com    ")  //
	AADD (aSays, "  as regras cadastradas para gerenciamento de produção.      ")  //

	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} ) 
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. ) } } )                                                                
	FormBatch( cCadastro, aSays, aButtons )  

	Pergunte(cPerg,.f. )

	If nopca == 1  
		Processa({||Distribui() },"DISTRIBUIÇÃO DE PEÇAS","Realizando processamento dos dados ")  
	endif

return 

Static Function Distribui()

	Local _cRegra := ''
	Local _lRec   := .f.
	Local i       := 0

	DbSelectArea('SZG')
	SZG->(DbSetOrder(1))

	if SZG->(DbSeek(xfilial('SZG')+mv_par01))
		_dDtAbate := SZG->ZG_DATA
	else
		alert('Abate Inexistente!')
		return .f.
	endif

	SZG->(DbSetOrder(2))

	for i := 0 to mv_par02 

		if SZG->(DbSeek(xfilial('SZG')+dtos(_dDtAbate-i)))
			_nTotAnim := SZG->ZG_QTDTOT
		else
			loop
		endif

		SZK->(DbGoTop())
		SZK->(DbSetOrder(2))
		SZK->(DbSeek(xfilial('SZK')+SZG->ZG_NUMAM))

		ProcRegua(_nTotAnim)

		//Para excluir todos os registros do aviso de matança em questão
		ZZB->(DbSetOrder(1))
		ZZB->(DbGoTop())
		if ZZB->(DbSeek(xfilial('ZZB') + SZG->ZG_NUMAM))
			While ZZB->(!eof()) .and. ZZB->ZZB_FILIAL = xfilial('ZZB') .and. ZZB->ZZB_NUMAM = SZG->ZG_NUMAM
				reclock('ZZB',.f.)
				ZZB->ZZB_QTSYST := 0
				ZZB->ZZB_QTSYSD := 0
				ZZB->ZZB_QTSYSC := 0
				ZZB->ZZB_QUANTT := 0
				ZZB->ZZB_QUANTD := 0
				ZZB->ZZB_QUANTC := 0
				ZZB->ZZB_QREALD := 0
				ZZB->ZZB_QREALT := 0
				ZZB->ZZB_QREALC := 0
				msunlock()
				ZZB->(DbSkip())
			enddo
		endif

		ZZB->(DbGoTop())

		While SZK->(!eof()) .and. SZK->ZK_FILIAL = xfilial('SZK') .and. SZK->ZK_NUMAM = SZG->ZG_NUMAM

			incproc('Processando Abate nº ' + SZK->ZK_NUMAM + ' carcaça nº ' + SZK->ZK_CONTROL)

			//Inicio da aplicação das regras. Caso alguma for encontrada então aplica-se e cai fora
			ZZ8->(DbGoTop())
			ZZ8->(DbSetOrder(1))
			if ZZ8->(DbSeek(xfilial('ZZ8')))
				While ZZ8->(!eof()).and. ZZ8->ZZ8_FILIAL = xfilial('ZZ8')

					//Se estiver desativada então ignora a regra
					if ZZ8->ZZ8_STATUS = 'D'
						ZZ8->(DbSkip())
						loop
					endif

					_cRegra := 'SZK->(' + alltrim(ZZ8->ZZ8_REGRA) + ')'

					if &_cRegra
						ZZB->(DbSetOrder(1))
						if ZZB->(DbSeek(xfilial('ZZB') + SZG->ZG_NUMAM + ZZ8->ZZ8_COD))

							//Se existe lançamento de distribuição entao o flag aponta para não criar novo registro
							_lRec := .f.
						else
							//Se nao existe lançamento de distribuição entao o flag aponta para criar novo registro
							_lRec := .t.
						endif

						reclock('ZZB',_lRec)
						if  _lRec     //Se não achou vai então incluir um novo registro...
							ZZB->ZZB_FILIAL := xfilial('ZZB')
							ZZB->ZZB_NUM    := _cID :=  GetSx8num('ZZB','ZZB_NUM')
							ConfirmSX8()
							ZZB->ZZB_NUMAM  := SZG->ZG_NUMAM
							ZZB->ZZB_REGRA  := ZZ8->ZZ8_COD
							ZZB->ZZB_DATA   := SZG->ZG_DATA
							ZZB->ZZB_STATUS := 'A'
							ZZB->ZZB_DESCRI := ZZ8->ZZ8_DESCRI
							ZZB->ZZB_QTSYST := 2
							ZZB->ZZB_QTSYSD := 2
							ZZB->ZZB_QTSYSC := 2
							ZZB->ZZB_QUANTT := 2 - SZK->ZK_PROCT
							ZZB->ZZB_QUANTD := 2 - SZK->ZK_PROCD
							ZZB->ZZB_QUANTC := 2 - SZK->ZK_PROCC
							ZZB->ZZB_QREALD := SZK->ZK_PROCD
							ZZB->ZZB_QREALT := SZK->ZK_PROCT
							ZZB->ZZB_QREALC := SZK->ZK_PROCC
						else
							ZZB->ZZB_QTSYST += 2
							ZZB->ZZB_QTSYSD += 2
							ZZB->ZZB_QTSYSC += 2
							ZZB->ZZB_QUANTT += 2 - SZK->ZK_PROCT
							ZZB->ZZB_QUANTD += 2 - SZK->ZK_PROCD
							ZZB->ZZB_QUANTC += 2 - SZK->ZK_PROCC
							ZZB->ZZB_QREALD += SZK->ZK_PROCD
							ZZB->ZZB_QREALT += SZK->ZK_PROCT
							ZZB->ZZB_QREALC += SZK->ZK_PROCC
							if  ZZB->ZZB_QUANTT = 0 .and. ZZB->ZZB_QUANTD = 0 .and. ZZB->ZZB_QUANTC = 0
								ZZB->ZZB_STATUS := 'E'
							endif
						endif
						msunlock()

						//Se encontrou a regra, aplica ela e cai fora do laço da ZZ8 (exit)
						exit
					endif

					ZZ8->(DbSkip())
				enddo
			endif

			SZK->(DbSkip())
		enddo

	next

Return

