#INCLUDE "topconn.ch"         
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"                                                                           
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch" 
#INCLUDE "tbiconn.ch"
#INCLUDE "totvs.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF223   º Autor ³ Giuliano Forgiariniº Data ³  20/08/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Rotina de visualização de produção final nas linhas de      º±±
±±º          ³embalagem secundária                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PCP Porcionados                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function POR_01()
	u_POR_00('001')
Return

User Function POR_02()
	u_POR_00('002')
Return

User Function POR_03()
	u_POR_00('003')
Return

User Function POR_04()
	u_POR_00('004')
Return

User Function POR_00(_cLin)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	private oFont     := tFont():New("ARIAL",,18,,.t.,,,,)
	Private oFont2    := tFont():New("courier new",,-36,,.t.,,,,)    
	private oFont3    := tFont():New("courier new",,-24,,,,,,) 
	Private _cLinha   := ''
	//Private _aItems   := {'001','002','003','004'}
	Private _cLinha   := _cLin
	Private _nID      := 0  
	Private oLinha    := 'Linha: ' + _cLinha
	Private _cMemo    := ''


	//RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" MODULO "ACD" //TABLES "SA1", "SB1"
	//aTables := {'ZAJ','SZ2'}
	//RPCSetEnv('01','00','industria','industria',"ACD","U_POR_00",aTables,,,,)



	DEFINE MSDIALOG oAut TITLE 'ACOMPANHAMENTO DE PESAGEM E ETIQUETAGEM DE CAIXAS DE PA' from 000,000 To 600,800  PIXEL

	oSayLinha := tSay():New(05,10,{|| oLinha  },oAut,,oFont,,,,.T.,,,200,30)  

	oMemo     := TMultiget():New(20,05,{|u|if(Pcount()>0,_cMemo:=u,_cMemo)},oAut,390,275,oFont2,,,,,.T.,,,,,,.t.)

	oTimer    := TTimer():New(02, {|| Exib()}, oAut)  //Timer para exibição da produção da EMB01          

	oTimer:Activate()

	ACTIVATE MSDIALOG oAut CENTERED

	RESET ENVIRONMENT

Return

//Funções para buscar último registro da tabela de logs ZAF
Static Function Exib()
	//4º Verificar se existe previsão de produção do produto       
	_cQuery := " SELECT * "
	_cQuery += " FROM " + RetSqlTab("ZAF")
	_cQuery += " WHERE ZAF_ID = (SELECT MAX(ZAF_ID)"
	_cQuery += " FROM " + RetSqlTab("ZAF")
	_cQuery += " WHERE " + RetSQLFil("ZAF")
	_cQuery += " AND ZAF_LIN  = '"+padr(_cLinha,5)+"'"
	_cQuery += " AND ZAF_DATA = '" + DTOS(date()) + "'"
	_cQuery += " AND " + RetSQLDel("ZAF") 

	_cQuery := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("VER1")<>0
		VER1->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "VER1"

	_cMemo := chr(13) + chr(10)
	DbSelectArea('ZAU')
	ZAU->(DbSetOrder(4))
	if ZAU->(DbSeek(xfilial('ZAU')+alltrim(_cLinha)))
		_cMemo += 'LOTE   : ' + ZAU->ZAU_NUM + chr(13) + chr(10)  
		_cMemo += 'PRODUTO: ' + alltrim(ZAU->ZAU_COD) + ' ' + alltrim(ZAU->ZAU_DESC)  + chr(13) + chr(10)     
		_cMemo +=  chr(13) + chr(10)  

		if VER1->ZAF_ID <> _nID
			_nID := VER1->ZAF_ID  

			_cMemo += 'PESO BRUTO  : [' + transform(VER1->ZAF_PESOB,'@E 999.999') + ']  '+ chr(13) + chr(10)
			_cMemo += 'TARA        : [' + transform(VER1->ZAF_TARA ,'@E 999.999') + ']  '+ chr(13) + chr(10)
			_cMemo += 'PESO LIQUIDO: [' + transform(VER1->(ZAF_PESOB - ZAF_TARA) ,'@E 999.999') + ']  ' + chr(13) + chr(10)
			_cMemo += chr(13) + chr(10)
			
			if VER1->ZAF_STATUS = 'FA'
				//Inicio da inha adicionada por Lucas Bolzan 07/10/22
				u_dti154()
				//Fim da linha adicionada por Lucas Bolzan 07/10/22
				_cMemo += '##### REJEITE ACIONADO #####'+ chr(13) + chr(10)
				_cMemo += alltrim(VER1->ZAF_DESC)  + chr(13) + chr(10)				
			else    
				_cMemo += 'Registro efetivado com sucesso!'+ chr(13) + chr(10)				
				_cMemo += chr(13) + chr(10) 
			endif
			_cMemo += '[' + alltrim(VER1->ZAF_STRING) + ']'
			oMemo:refresh()
			oAut:refresh() 
		endif 
	endif
Return  
