#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF56     º Autor ³Giuliano Forgiarini º Data ³  23/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de desconsideração de Ph de carcaças                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF56()

	LOCAL nOpca	:=0
	LOCAL aSays:={}, aButtons:={}
	Private cCadastro := "Desconsideração da Maturação"
	Private cPerg   := "GJF56"

	AADD (aSays, "  Esta rotina tem como objetivo realizar a desconsideração de Ph de    ")  //
	AADD (aSays, "  determinada câmara apontada conforme os parametros da mesma,         ")  //
	AADD (aSays, "  classificando-as sumariamente como NE.                               ")  //

	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. ) } } )
	FormBatch( cCadastro, aSays, aButtons )
	If nopca == 1
		Pergunte(cPerg,.f. )
		Processa({||DPhSZ8()},"DESCONSIDERAÇÃO DE MATURAÇAO","Realizando operação nos registros de carcaça...")

	Endif

return

Static Function DPhSZ8()
	ProcRegua(SZK->(reccount()))
	SZK->(dbsetorder(4))
	if SZK->(dbseek(xfilial('SZK')+mv_+par01))	
		while SZK->(!eof()) .and. SZK->ZK_NUMAM = mv_par01 
			_flag := .f.
			incregua()

			if SZK->ZK_LOCAL != mv_par02
				SZK->(dbskip())
				loop
			endif

			reclock('SZK',.f.)  
			if AllTrim(SZK->ZK_CLASABA) = 'NE'
				SZK->ZK_CLASSIF := 'NE' 
			else 
				SZK->ZK_CLASSIF := 'HK' 
			endif
			SZK->ZK_MATURA  := 'N'                                
			msunlock() 

			if SZK->ZK_PROCD <> 0 .and. SZK->ZK_PROCT <> 0    

				SZ2->(DbSetOrder(4))  
				if SZ2->(DbSeek(xfilial('SZ2')+SZK->(ZK_NUMAM+ZK_OPCORD)))
					reclock('SZ2',.f.)
					SZ2->Z2_QPPECA := SZ2->Z2_QPPECA - 2
					SZ2->Z2_QRPESO := SZ2->Z2_QPPESO - (SZK->ZK_PETOTAL * 0.38)
					msunlock()
				endif  

				if SZ2->(DbSeek(xfilial('SZ2')+SZK->(ZK_NUMAM+ZK_OPCORT)))
					reclock('SZ2',.f.)
					SZ2->Z2_QPPECA := SZ2->Z2_QPPECA - 2 
					SZ2->Z2_QRPESO := SZ2->Z2_QPPESO - (SZK->ZK_PETOTAL * 0.48)
					msunlock()
				endif

				RecLock('SZK',.F.)			
				SZK->ZK_OPCORD := ''
				SZK->ZK_OPCORT := '' 
				MsUnlock()
				_flag := .t.
			endif

			if _flag
				Alert('Carcaça número '+alltrim(SZK->ZK_CONTROL) + ' desvinculada de Previsão de Produção para a Desossa!')
			endif
		enddo
		msgbox('Câmara ' + mv_par02 + ' com a maturação desconsiderada!','OPERAÇÃO REALIZADA!','INFO')
	endif    

return
