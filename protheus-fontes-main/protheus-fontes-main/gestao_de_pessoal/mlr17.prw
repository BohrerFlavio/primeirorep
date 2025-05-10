#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMLR17    บ Autor ณ Mauricio Roehrs em 16/07/2013            บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Ajuste de verbas no fechamento mensal da folha, para       บฑฑ
ฑฑบ          ณ Calculo do Dissidio                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestใo de Pessoal		                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function MLR17()
	Local i
	Private _cMat  := ''
	Private _cPd   := '' 
	Private _aMat  := {}
	Private _aMat2 := {} 
	Private _cTab  := "RC011306"

	/*#######################################
	#Query principal onde sใo selecionados  #
	#os registros principais para calculo e #
	#montado o vetor com as informa็๕es     #
	#######################################*/
	_cQuery := " SELECT RC_MAT, RC_VALOR,RC_DATA,RC_CC,RC_TIPO2 "
	_cQuery += " FROM " + _cTab
	_cQuery += " WHERE RC_FILIAL = '00' "
	_cQuery += " AND RC_PD = '891'
	_cQuery += " AND RC_MAT IN(SELECT RC_MAT FROM " + _cTab + " WHERE RC_FILIAL = '00' AND RC_PD = '126') "
	_cQuery += " AND RC_MAT IN(SELECT RC_MAT FROM " + _cTab + " WHERE RC_FILIAL = '00' AND RC_PD = '105') "
	_cQuery += " AND " + _cTab + ".D_E_L_E_T_ <> '*' "

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	TMP->(DbGoTop())                   
	while TMP->(!eof())	    	        

		_nPos := aScan(_aMat,{|aVal|aVal[1] = TMP->RC_MAT})

		if _nPos = 0
			aadd(_aMat,{TMP->RC_MAT,TMP->RC_VALOR - 135.6,TMP->RC_DATA,RC_CC,TMP->RC_TIPO2})
		endif 

		TMP->(DbSkip())

	enddo

	alert('Gerou  vetor(1): ' + str(len(_aMat)) + ' registros')

	/*#######################################
	#Query Secundaria onde sใo selecionados #
	#os registros de horas somente da verba #
	#126 dos funcionarios selecionados na   #
	#primeira query e montado um segundo    #
	#com as respectivas horas para posterior#
	#calculo                                #
	#######################################*/
	_cQuery := " SELECT RC_MAT, RC_HORAS"
	_cQuery += " FROM " + _cTab
	_cQuery += " WHERE RC_FILIAL = '00' "
	_cQuery += " AND RC_PD = '126' AND RC_MAT IN ("
	_cQuery += " SELECT RC_MAT"
	_cQuery += " FROM " + _cTab
	_cQuery += " WHERE RC_FILIAL = '00' "
	_cQuery += " AND RC_PD = '891'
	_cQuery += " AND RC_MAT IN(SELECT RC_MAT FROM " + _cTab + " WHERE RC_FILIAL = '00' AND RC_PD = '126') "
	_cQuery += " AND RC_MAT IN(SELECT RC_MAT FROM " + _cTab + " WHERE RC_FILIAL = '00' AND RC_PD = '105') "
	_cQuery += " AND " + _cTab + ".D_E_L_E_T_ <> '*')"
	_cQuery += " AND " + _cTab + ".D_E_L_E_T_ <> '*' "                             

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	TMP->(DbGoTop())
	while TMP->(!eof())

		_nPos := aScan(_aMat2,{|aVal|aVal[1] = TMP->RC_MAT})

		if _nPos = 0
			aadd(_aMat2,{TMP->RC_MAT,TMP->RC_HORAS})
		endif 

		TMP->(DbSkip())

	enddo

	alert('Gerou  vetor(2): ' + str(len(_aMat2)) + ' registros')

	/*#######################################
	#Query para contagem dos registros para #
	#ser feito em seguida o "INSERT INTO"   #
	#com as informa็๕es da primeira query e #
	#do primeiro vetor _aMat                #
	#######################################*/
	_cQuery := " SELECT COUNT(*) AS REGISTROS "
	_cQuery += " FROM " + _cTab

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

	_nReg := TMP->REGISTROS

	for i := 1 to len(_aMat)   
		_nReg++
		_cInsert := "INSERT INTO " + _cTab + " (RC_FILIAL,RC_MAT,RC_PD,RC_TIPO1,RC_VALOR,RC_DATA,RC_CC,RC_TIPO2,R_E_C_N_O_) "
		_cInsert += "VALUES ('00','" + _aMat[i,1] + "','998','V',"+ str(_aMat[i,2]) +",'"+_aMat[i,3]+"','"+_aMat[i,4]+"','"+_aMat[i,5]+"',"+str(_nReg)+")"

		If (TCSQLExec(_cInsert) < 0)
			Return MsgStop("TCSQLError() " + TCSQLError())
		EndIf
	next

	/*################################################
	#Percorre todo o segundo vetor (_aMat2)     		 #
	#para fazer o "UPDATE" do campo RC_VALOR    		 #
	#da verba 998 criada pelo "INSERT INTO"     		 # 
	#com base nas informa็๕es geradas pela      		 #  
	#primeira query e pelo primeiro vetor(_aMat).	 # 
	#calculo para descobrir o salario mensal original#
	################################################*/
	for i := 1 to len(_aMat2)   

		_cQuery := " SELECT RC_VALOR
		_cQuery += " FROM  " + _cTab
		_cQuery += " WHERE RC_FILIAL = '00' "
		_cQuery += " AND RC_PD = '998' AND  RC_MAT = '" + _aMat2[i,1] + "'"
		_cQuery += " AND " + _cTab + ".D_E_L_E_T_ <> '*' " 

		MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

		_cUpdate := " UPDATE " + _cTab + " SET RC_VALOR = (RC_VALOR / 30) * " + str(_aMat2[i,2])
		_cUpdate += " WHERE RC_FILIAL = '00' AND RC_PD = '998' AND RC_MAT = '" + _aMat2[i,1] + "'"  

		If (TCSQLExec(_cUpdate) < 0)
			Return MsgStop("TCSQLError() " + TCSQLError())
		EndIf

	next

	alert('Concluํdo!')
return 

Static Function GeraTMP()   

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

return
