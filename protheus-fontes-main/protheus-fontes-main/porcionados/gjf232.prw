#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF232     ºAutor  ³Giuliano Forgiariniº Data ³  05/10/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Relatorio de rastreabilidade - RECALL - relacionando os  º±±
±±º          ³   detalhes de produção de cada lote produzido              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Porcionados qualidade PCP                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function GJF232()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatório"
	Local cDesc2         := "de ratreabilidade para fins de conferencia com base"
	Local cDesc3         := "em determinado lote de produção"
	Local cPict          := " - RECALL - "
	Local titulo         := "RP01 - RASTREABILIDADE DE LOTE DE PRODUÇÃO"
	Local Cabec1         := ""
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd           := {}  
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "GJF232" 
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}   
	Private nLastKey     := 0                  

	//Vai usar o mesmo grupo de produtos GJF222
	Private cPerg   		:= "GJF232"
	Private _cGrpMoi     := GetMV('SI_GRPMOI') 
	Private _cGrupo      := ''
	Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "GJF232" 
	Private _aBatidas  	:= {}      

	if !pergunte(cPerg,.t.)
		return
	endif


	wnrel := SetPrint('ZAU',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZAU')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	ZAU->(SetRegua(RecCount()))

	ZAU->(DbSetOrder(1))
	ZAU->(dbGoTop())
	if ZAU->(DbSeek(xfilial('ZAU') + mv_par01))

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


		If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		DbSelectArea('SB1')
		_cGrupo := fBuscaCPO('SB1',1,xfilial('SB1') + ZAU->ZAU_COD,'B1_GRUPO')      

		@nlin,001 psay 'LOTE DE PRODUÇÃO NR.: ' + ZAU->ZAU_NUM + '  PRODUTO: ' + ZAU->ZAU_COD + ' (' + alltrim(ZAU->ZAU_DESC) + ')'  
		nlin++
		@nlin,001 psay 'DATA DE PRODUÇÃO: ' + dtoc(ZAU->ZAU_DTPROD) + '   DATA DE ABATE: ' + dtoc(ZAU->ZAU_DTABAT) + '   DATA DE VALIDADE: ' + ZAU->ZAU_IMVAL       
		nlin++
		@nlin,001 psay 'PRODUÇÃO: Peso(kg): ' + transform(ZAU->ZAU_QRPESF,'@E 999,999.99') +;
		'  Caixas: ' + transform(ZAU->ZAU_QRCAIF,'@E 999') +;
		'  Unidades: ' + transform(ZAU->ZAU_QRUNI,'@E 999,999')
		nlin+=2                    

		@nlin,001 psay 'CAIXAS DE PRODUTO ACABADO PRODUZIDAS: '      

		nlin++

		SZ8->(DbSetOrder(25))
		if SZ8->(DbSeek(xfilial('SZ8') + cFilAnt +  ZAU->ZAU_NUM))
			while SZ8->(!eof()) .and. SZ8->Z8_FILIAL = xfilial('SZ8') .and. SZ8->Z8_FIL = cFilant .and. SZ8->Z8_LOTEPOR = ZAU->ZAU_NUM

				If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9
				Endif

				_cPlaca := fBuscaCPO('ZZ3',2,xfilial('ZZ3') + SZ8->Z8_PRECAR,'ZZ3_PLACA')
				_cCodCli := ''
				_cLj     := ''   
				_cNome   := ''

				ZZ4->(DbSetOrder(2))
				if ZZ4->(DbSeek(xfilial('ZZ4') + SZ8->Z8_PREPED)) .and. !empty(SZ8->Z8_PREPED)
					_cCodCli := ZZ4->ZZ4_CODCLI
					_cLj     := ZZ4->ZZ4_LOJA 
					_cNome   := ZZ4->ZZ4_NOME           
				endif

				@nlin,001 psay SZ8->Z8_CONTROL
				@nlin,013 psay SZ8->Z8_HORA
				@nlin,019 psay transform(SZ8->Z8_PESOBR,'@E 99.99')
				@nlin,026 psay transform(SZ8->Z8_TARA,'@E 9.999')
				@nlin,033 psay transform(SZ8->Z8_PESO,'@E 99.99')				
				@nlin,041 psay SZ8->Z8_DATAS							
				@nlin,051 psay transform(SZ8->Z8_HORAS,'99:99')
				@nlin,059 psay _cPlaca					
				@nlin,068 psay SZ8->Z8_PREPED
				@nlin,076 psay SZ8->Z8_ITEM
				@nlin,082 psay _cCodCli + '/'+_cLj
				@nlin,093 psay alltrim(_cNome)
				nlin++

				SZ8->(DbSkip())
			enddo	

		endif			

		nlin+=2                    

		@nlin,001 psay 'BATELADA DE MATERIA-PRIMA: '

		nlin++

		ZAS->(DbSetOrder(12))

		if _cGrupo $ _cGrpMoi

			ZAV->(DbSetOrder(2))
			if ZAV->(DbSeek(xfilial('ZAV') + ZAU->ZAU_NUM))
				while ZAV->(!eof()) .and. ZAV->ZAV_FILIAL = xfilial('ZAV') .and. ZAV->ZAV_NUM = ZAU->ZAU_NUM        

					@nlin,001 psay 'BATELADA DE MATERIA-PRIMA: ' + ZAV->ZAV_BATEL
					nlin++

					if ZAS->(DbSeek(xfilial('ZAS') + ZAV->ZAV_BATEL))

						If nLin > 65 // Salto de Página. Neste caso o formulario tem 55 linhas...
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9
						Endif

						if ZAS->ZAS_TIPO <> 'MP'
							ZAS->(DbSkip())
							loop
						endif

						@nlin,001 psay ZAS->ZAS_CONTRO
						@nlin,015 psay dtoc(ZAS->ZAS_DTPROD)
						@nlin,025 psay dtoc(ZAS->(ZAS_DTPROD + ZAS_VALID))
						@nlin,030 psay transform(ZAS->ZAS_PESOB,'@E 99.99')
						@nlin,037 psay transform(ZAS->ZAS_TARA,'@E 9.999')
						@nlin,045 psay transform(ZAS->ZAS_PESOL,'@E 99.99')			
						@nlin,053 psay ZAS->ZAS_HORAS									

					endif  

					ZAV->(DbSkip())
				enddo	
			else


			endif
		endif
	endif		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return


