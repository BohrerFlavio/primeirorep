#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMRVT00     บ Autor ณMauricio Roehrsบ   Data ณ  02/08/12     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Aplica็ใo para microterminais VT-100 para informar dados deบฑฑ
ฑฑบ          ณ de para selecionar qual rotina serแ executada              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

//Tela de Abertura do coletor
User Function MRVT00()          
	Private _cModelo := ''
	Private _lOk     := .t.
	Private _cOper   := ''

	//RPCSetType(3) //nใo consome licen็a
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'ACD' TABLES 'SZG','SZK','SZ4','SZD','SZE','SZ8','SB1','ZAA','SZP','ZAJ','SZL','ZAS'

	//RpcSetEnv( "empresa","filial", "usuario", "Senha", "Ambiente", "Rotina", aTabelas, , , ,  )

	//aTables := {'SZG','SZK','SZ4','SZD','SZE','SZ8','SB1','ZAA','SZP','ZAJ','SZL'}
	//RPCSetEnv('01','00','industria','industria',"ACD","U_MRVT00",aTables,,,,)

	dGetData := MSDate()
	TRealIni := Time()

	_cModelo = VTModelo()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	VTClear()
	VTClearBuffer()

	aUser     := VTGetsenha(@dGetData,TRealIni) 
	_cCodUser := aUser[1,1]

	//VTAlert(aUser[1,1],'Aviso de Encerramento(01)',.T.,500,1)

	DbSelectArea('ZAA')
	ZAA->(DbSetOrder(2))
	if !ZAA->(DbSeek(xfilial('ZAA')+_cCodUser))
		VTAlert('Usuแrio nใo habilitado!','Aviso',.T.,500,1)
		return
	endif

	DbSelectArea('ZAA')
	ZAA->(DbSetOrder(2))
	if ZAA->(DbSeek(xfilial('ZAA')+_cCodUser))
		if ZAA->ZAA_STATUS == 'B'
			VTAlert('Usuแrio Bloqueado!','Aviso',.T.,500,1)  
			return
		endif
	endif	

	//conout(UsrRetName())
	//conout(_cCodUser)
	//conout('linha 81->')
	VTClear()
	VTClearBuffer()
	while _lOk

		_cOper:=Space(02)
		@ 01,00    VTSay "Digite a op็ใo de opera็ใo   "
		@ 02,00    VTSay "a ser realizada no processo: "     
		@ 03,00    VTSay "                             "    
		@ 04,00    VTSay "                             "  
		_nlin := 5 
		@ _nlin,00 VTSay "OPERAวรO: [  ]                "
		_nlin++  

		if ZAA->ZAA_APL01 = 'S' 
			@ _nlin,00 VTSay "01 - Tipifica็ใo Abate        "
			_nlin++
		endif
		if ZAA->ZAA_APL02 = 'S'
			@ _nlin,00 VTSay "02 - Producao Abate	         "
			_nlin++
		endif
		if ZAA->ZAA_APL03 = 'S'
			@ _nlin,00 VTSay "03 - Camaras do Abate         "
			_nlin++
		endif
		if ZAA->ZAA_APL04 = 'S'
			@ _nlin,00 VTSay "04 - Producao Desossa         " 
			_nlin++
		endif 
		if ZAA->ZAA_APL05 = 'S'
			@ _nlin,00 VTSay "05 - Entr/Saida Desos.        "	
			_nlin++
		endif  
		if ZAA->ZAA_APL06 = 'S'
			@ _nlin,00 VTSay "06 - Movim. de Camaras        "
			_nlin++
		endif    
		if ZAA->ZAA_APL07 = 'S'
			@ _nlin,00 VTSay "07 - Inventario               "
			_nlin++
		endif
		if ZAA->ZAA_APL08 = 'S'
			@ _nlin,00 VTSay "08 - Estocagem                "
			_nlin++
		endif     
		if ZAA->ZAA_APL09 = 'S'
			@ _nlin,00 VTSay "09 - Impr.Etq.Interna         "
			_nlin++
		endif
		if ZAA->ZAA_APL10 = 'S'
			@ _nlin,00 VTSay "10 - Valid. Producao          "
			_nlin++
		endif
		if ZAA->ZAA_APL11 = 'S'
			@ _nlin,00 VTSay "11 - Devolucoes               "
			_nlin++
		endif
		if ZAA->ZAA_APL12 = 'S'
			@ _nlin,00 VTSay "12 - Apontamento de PH        "
			_nlin++
		endif
		if ZAA->ZAA_APL16 = 'S'
			@ _nlin,00 VTSay "13 - Entrada do Corte         "
			_nlin++
		endif
		if ZAA->ZAA_APL17 = 'S'
			@ _nlin,00 VTSay "14 - Prod. do corte(Desmonte) "
			_nlin++
		endif
		if ZAA->ZAA_APL18 = 'S'
			@ _nlin,00 VTSay "15 - Prod. do corte(Montagem) "
			_nlin++
		endif
		if ZAA->ZAA_APL19 = 'S'
			@ _nlin,00 VTSay "16 - Separa็ใo de Caixas      "
			_nlin++
		endif
		if ZAA->ZAA_APL21 = 'S'
			@ _nlin,00 VTSay "17 - Cameras Carca็as          "
			_nlin++
		endif
		if ZAA->ZAA_APL22 = 'S'
			@ _nlin,00 VTSay "18 - Costelas em Proc. Producao"
			_nlin++
		endif
		if ZAA->ZAA_APL23 = 'S'
			@ _nlin,00 VTSay "19 - Pesagem na Desosssa"
			_nlin++
		endif
		if ZAA->ZAA_APL24 = 'S'
			@ _nlin,00 VTSay "20 - Rendimento Costela"
			_nlin++
		endif
		if ZAA->ZAA_APL25 = 'S'
			@ _nlin,00 VTSay "21 - Producao de Pendurados"
			_nlin++
		endif
		if ZAA->ZAA_APL27 = 'S'
			@ _nlin,00 VTSay "22 - Valida็ใo de etiquetas EMBALAGEM"
			_nlin++
		endif
		if ZAA->ZAA_APL28 = 'S'
			@ _nlin,00 VTSay "23 - Valida็ใo de caixas Carregadas"
			_nlin++
		endif
		if ZAA->ZAA_APL29 = 'S'
			@ _nlin,00 VTSay "24 - Valida็ใo de brincos Abate"
			_nlin++
		endif
		if ZAA->ZAA_APL19 = 'S'
			@ _nlin,00 VTSay "25 - Etiqueta % Gordura"
			_nlin++
		endif
		if ZAA->ZAA_APL31 = 'S'
			@ _nlin,00 VTSay "26 - Etiqueta Interna"
			_nlin++
		endif

		@ 16,00 VTSay "ESC para Sair"

		@ 05,11 VTGet _cOper Pict "@!" VALID (_cOper $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/15/16/17/18/19/20/21/22/23/24/25/26")

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplica็ใo Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		DbSelectArea('SZ4')
		SET FILTER TO
		SZ4->(DbCloseArea())

		DbSelectArea('SZK')
		SET FILTER TO
		SZ4->(DbCloseArea())
		//VTAlert('Opcao invalida!','Aten็ใo!!',.T.,500,1)	
		_cOper := alltrim(_cOper)
		do case
			case _cOper == '01'     //Tipifica็ใo abate
			u_gfvt01(_cCodUser)
			case _cOper == '02'     //Produ็ใo do Abate 
			u_mrvt07(_cCodUser)
			case _cOper == '03'     //Camaras do abate
			u_mrvt03(_cCodUser)
			case _cOper == '04'     //Producao desossa
			u_mrvt05(_cCodUser)
			case _cOper == '05'     //Entrada/Saida Desossa
			u_mrvt06(_cCodUser)
			case _cOper == '06'     //Movimenta็ใo de Camaras
			u_mrvt01(_cCodUser)
			case _cOper == '07'     //Inventario
			u_mrvt02(_cCodUser)
			case _cOper == '08'     //Estocagem
			u_mrvt04(_cCodUser)
			case _cOper == '09'     //Etiqueta Interna
			u_mrvt08(_cCodUser)
			case _cOper == '10'     //Valida็ใo de Produ็ใo
			u_mrvt09(_cCodUser)
			case _cOper == '11'     //Devolucoes
			u_mrvt10(_cCodUser)
			case _cOper == '12'     //Apontamento de PH
			u_mrvt11(_cCodUser)
			case _cOper == '13'     //Entrada do Corte
			u_mrvt12(_cCodUser)
			case _cOper == '14'     //Corte - Desmontagem
			u_mrvt13(_cCodUser)
			case _cOper == '15'     //Corte - Montagem
			u_mrvt14(_cCodUser)
			case _cOper == '16'     //Controle de Cameras Para Carca็as
			u_mrvt15(_cCodUser)
			case _cOper == '17'     //Separa็ใo de Caixas
			u_mrvt16(_cCodUser)
			case _cOper == '18'		//costelas em processo de producao
			u_mrvt17(_cCodUser)
			case _cOper == '19'		//costelas em processo de producao
			u_mrvt18(_cCodUser)
			case _cOper == '20'		//rendimento costela
			u_mrvt19(_cCodUser)
			case _cOper == '21'		//Produ็ใo de Pendurados
			u_mrvt20(_cCodUser)
			case _cOper == '22'		//Valida็ใo de etiquetas EMBALEGEM
			u_mrvt21(_cCodUser)
			case _cOper == '23'		//Valida็ใo de caixas carregadas
			u_mitfs007(_cCodUser)
			case _cOper == '24'		//Valida็ใo de brincos no Abate
			u_mrvt22(_cCodUser)
			case _cOper == '25'		//Rotina nova
			u_mrvt23(_cCodUser)
			case _cOper == '26'		//Rotina nova
			u_mrvt24(_cCodUser)
			otherwise
			VTAlert('Opcao invalida!','ATENCAO!',.T.,500,1)
		endcase

		VTCLear()
		VTClearBuffer()
	enddo

	VTCLear()
	VTClearBuffer()

	RESET ENVIRONMENT
Return
