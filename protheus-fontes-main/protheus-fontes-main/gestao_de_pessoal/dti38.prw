#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI38     ºAutor  ³Mauricio Roehrs     º Data ³  12/08/17   º±±                       
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Rotina para gerar os apontamentos conforme lançamentos dasº±±
±±º          ³  folgas feitas pelo setor de RH						      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE/SIGAPON			                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function DTI38()

	Private cPerg := "DTI38"

	if !pergunte(cPerg,.t.)
		return
	endif

	_cQuery := " SELECT ZBC_MAT, ZBC_DTREF, ZBC_HRBAIX
	_cQuery += " FROM  " + retSqlTab('ZBC')
	_cQuery += " WHERE " + retSqlFil('ZBC')
	_cQuery += " AND ZBC_DTREF BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "'"      
	_cQuery += " AND ZBC_MAT BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
	_cQuery += " AND ZBC_APONTA = 'N'  
	_cQuery += " AND " + retSqlDel('ZBC')
	_cQuery += " ORDER BY ZBC_MAT, ZBC_DTREF


	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	if msgbox('Você confirma intervalo de datas e matricula informados nos parâmetros?','ATENÇÃO, OPERAÇÃO DE ALTERAÇÃO DEFINITIVA!','YESNO')   

		Processa({||procReg()} ,"PROCESSAMENTO DE REGISTROS...","Processando Dados do Funcionario...")

		msgbox('Importação das folgas para os apontamentos finalizado com sucesso!','Integração Folgas x Apontamentos','INFO')
	else
		msgbox('Importação das folgas para os apontamentos cancelada!','Integração Folgas x Apontamentos','STOP')
	endif


return


Static Function procReg()

	dbSelectArea('SPC')
	SPC->(dbSetOrder(2))  
	_cPd409 := '409'
	_cPd463 := '463'               

	TMP->(dbGoTop()) 
	ProcRegua(TMP->(RecCount()))

	while TMP->(!eof())

		IncProc()		

		if SPC->(dbSeek(FWxFilial('SPC') + TMP->ZBC_MAT + TMP->ZBC_DTREF + _cPd409))	//verifica se há registro com a verba 409    

			_nQtdAbono := fConvHr(TMP->ZBC_HRBAIX,'H')

			reclock('SPC',.f.)
			SPC->PC_ABONO   := '015'
			SPC->PC_QTABONO := iif(SPC->PC_QUANTC < _nQtdAbono, SPC->PC_QUANTC, _nQtdAbono)//verifica se as horas de falta são menores do que a quantidade a ser
			SPC->PC_DATAALT := date()                                                      //abonada, caso for, abona somente a quantidade de faltas necessária
			SPC->PC_HORAALT := strtran(time(),':','')                                      //senão abona a quantidade lançada
			SPC->PC_USUARIO := __cUserID	//retCodUsr()
			msunlock()                                                          

			//é necessário inserir um registro nessa tabela pois ela controla os apontamentos. pois durante a leitura, caso não tenha registro nessa tabela 
			//os dados da SPC são apagando durante o reapontamento das marcações		
			reclock('SPK',.t.)
			SPK->PK_FILIAL := FWxFilial('SPK')
			SPK->PK_MAT    := TMP->ZBC_MAT
			SPK->PK_DATA   := SPC->PC_DATA
			SPK->PK_CODABO := '015'
			SPK->PK_HRSABO := iif(SPC->PC_QUANTC < _nQtdAbono, SPC->PC_QUANTC, _nQtdAbono)
			SPK->PK_CODEVE := SPC->PC_PD
			SPK->PK_CC 	   := SPC->PC_CC
			SPK->PK_FLAG   := 'I'		
			msunlock()          

			ZBC->(dbSetOrder(2))
			ZBC->(dbGoTop())
			if ZBC->(dbSeek(FWxFilial('ZBC') + TMP->ZBC_MAT + TMP->ZBC_DTREF))
				reclock('ZBC',.f.)
				ZBC->ZBC_APONTA := 'S'	
				msunlock()
			endif

		elseif SPC->(dbSeek(FWxFilial('SPC') + TMP->ZBC_MAT + TMP->ZBC_DTREF + _cPd463)) //senão verifica se há registro com a verba 463	    

			_nQtdAbono := fConvHr(TMP->ZBC_HRBAIX,'H')

			reclock('SPC',.f.)
			SPC->PC_ABONO   := '015'
			SPC->PC_QTABONO := iif(SPC->PC_QUANTC < _nQtdAbono, SPC->PC_QUANTC, _nQtdAbono)//verifica se as horas de falta são menores do que a quantidade a ser				
			SPC->PC_DATAALT := date()													   //abonada, caso for, abona somente a quantidade de faltas necessária
			SPC->PC_HORAALT := strtran(time(),':','')									   //senão abona a quantidade lançada
			SPC->PC_USUARIO := __cUserID	//retCodUsr()
			msunlock() 

			//é necessário inserir um registro nessa tabela pois ela controla os apontamentos. pois durante a leitura, caso não tenha registro nessa tabela 
			//os dados da SPC são apagando durante o reapontamento das marcações
			reclock('SPK',.t.)
			SPK->PK_FILIAL := FWxFilial('SPK')
			SPK->PK_MAT    := TMP->ZBC_MAT
			SPK->PK_DATA   := SPC->PC_DATA
			SPK->PK_CODABO := '015'
			SPK->PK_HRSABO := iif(SPC->PC_QUANTC < _nQtdAbono, SPC->PC_QUANTC, _nQtdAbono)
			SPK->PK_CODEVE := SPC->PC_PD
			SPK->PK_CC 	   := SPC->PC_CC
			SPK->PK_FLAG   := 'I'		
			msunlock()                   

			ZBC->(dbSetOrder(2))
			ZBC->(dbGoTop())
			if ZBC->(dbSeek(FWxFilial('ZBC') + TMP->ZBC_MAT + TMP->ZBC_DTREF))
				reclock('ZBC',.f.)
				ZBC->ZBC_APONTA := 'S'	
				msunlock()
			endif

		endif

		TMP->(dbSkip())
	enddo


	DbCloseArea('TMP')
	DbCloseArea('SPC')
return


Static Function GeraTMP()

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	if Select("TMP") != 0
		TMP->(dbCloseArea())
	endif

	TCQUERY _cQuery NEW ALIAS "TMP"

return
