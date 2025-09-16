#INCLUDE "rwmake.ch"
#INCLUDE 'protheus.ch'
#INCLUDE 'dbtree.ch' 
#INCLUDE "TOTVS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR05    º Autor ³ Mauricio Roehrsº Data ³  11/10/12   	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Limpeza de Pallets										  º±±
±±º          ³ 															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Camaras/PCP                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MLR05()
	Processa({||Processar() },"PROCESSAMENTO DE PALLETS","Realizando processamento de limpeza..." )                             
return

Static Function Processar()
	DbSelecTarea('SZP')
	SZP->(DbSetOrder(1))
	SZP->(DbGoTop())        
	SZP->(DbSeek(xfilial('SZP')))
	ProcRegua(SZP->(RecCount()))

	while !(eof()) .and. SZP->ZP_FILIAL = xfilial('SZP')    

		incproc('Processando pallet numero:' + SZP->ZP_COD)

		SZ8->(DbSetOrder(19))
		if !SZ8->(DbSeek(xfilial('SZ8')+cFilAnt+SZP->ZP_COD))		
			MsgRun("Aguarde... Realizando contagem de registro " + SZP->ZP_COD ,,{||  Apagar() })
		endif         

		SZP->(DbSkip())
	enddo   

return 

Static Function Apagar()
	RecLock('SZP',.f.)
	DbDelete()
	msunlock()  
	//sleep(1000)
return


//reorganiza a localização nas caixas da sz8 com base nos pallets
User Function MLR05b()
	Processa({||Proces() },"PROCESSAMENTO DE CAIXAS","Calculando..." )                             
return

Static Function Proces()
	DbSelecTarea('SZP')
	SZP->(DbSetOrder(1))
	SZP->(DbGoTop())        

	ProcRegua(SZP->(RecCount())) 

	_nRegs := SZP->(RecCount())
	while SZP->(!(eof()))

		incproc('Processando caixa numero:' + str(_nRegs) )

		if empty(SZP->ZP_LOCALIZ)
			SZP->(DbSkip())
			loop
		endif

		SZ8->(DbSetOrder(19))
		SZ8->(DbGoTop())
		ZAS->(DbSetOrder(6))
		ZAS->(DbGoTop())

		if SZ8->(DbSeek(xfilial('SZ8')+cFilAnt+alltrim(SZP->ZP_COD) ))	

			While SZ8->(!eof()) .and. SZ8->Z8_FILIAL = xfilial('SZ8') .and. SZ8->Z8_FIL = cFilAnt .and. alltrim(SZ8->Z8_PALLET) = alltrim(SZP->ZP_COD)

				if !empty(SZ8->Z8_DATAS) .and. !empty(SZ8->Z8_HORAS)
					SZ8->(DbSkip())
					loop
				endif	                          

				if alltrim(SZ8->Z8_PALLET) = alltrim(SZP->ZP_COD)
					RecLock('SZ8',.f.)
					SZ8->Z8_LOCALIZ := SZP->ZP_LOCALIZ
					SZ8->Z8_LOCAL	 := substr(SZP->ZP_LOCALIZ,1,2)
					msunlock()
				endif


				SZ8->(DbSkip())
			enddo

		elseif ZAS->(DbSeek(xfilial('ZAS')+alltrim(SZP->ZP_COD) ))	
			While ZAS->(!eof()) .and. ZAS->ZAS_FILIAL = xfilial('ZAS') .and. alltrim(ZAS->ZAS_PALLET) = alltrim(SZP->ZP_COD)

				if !empty(ZAS->ZAS_DATAS) .and. !empty(ZAS->ZAS_HORAS)
					ZAS->(DbSkip())
					loop
				endif	                          

				if alltrim(ZAS->ZAS_PALLET) = alltrim(SZP->ZP_COD)
					RecLock('ZAS',.f.)
					ZAS->ZAS_LOCALI  := SZP->ZP_LOCALIZ
					ZAS->ZAS_LOCAL	 := substr(SZP->ZP_LOCALIZ,1,2)
					msunlock()
				endif


				ZAS->(DbSkip())
			enddo	

		endif         

		SZP->(DbSkip())
	enddo   

return 


