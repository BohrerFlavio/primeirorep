#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF69  ºAutor  ³Giuliano Forgiarini º Data ³  14/01/08      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pesagens de peças  - Entrada da desossa                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF69()

	lOk      := .f.
	oDesc    := ''
	oDataV   := ''

	Private cCadastro := "Pesagens de Peças - Entrada da Desossa"
	Private aRotina := { {"Pesquisar"  ,"AxPesqui"  ,0,1} ,;
	{"Visualizar" ,"AxVisual"  ,0,2} ,;
	{"Produzir"   ,"u_gjf69pes",0,3} ,;
	{"Excluir"    ,"u_gjf69del('1')",0,5} }

	private cString   := "ZZD"  
	private _NumPrev  := ''
	private _cClass   := ''
	private _nProc    := 0  
	private aCampos   := {}  
	private aCampos2  := {}  
	private oFont     := tFont():New("courier new",,-20,,.t.,,,,)
	private oFont2    := tFont():New("courier new",,-16,,.t.,,,,)
	private oFont3    := tFont():New("Arial",,-50,,.t.,,,,)
	private oFont4    := tFont():New("Arial",,-30,,.t.,,,,)
	private oPesoP    := ''
	private oPesoB    := ''
	private oTTras    := ''
	private oCl       := ''          
	private oCl2      := ''
	Private cPerg     := "GJF69"
	private _nPesaD   := 1

	DbSelectArea("ZZD")
	ZZD->(DbSetOrder(2))

	if !pergunte(cPerg,.t.)
		Return
	endif

	_nPesaD := mv_par05   
	_PesaD  := iif(_nPesaD = 1,'1','2')  
	_nDest  := mv_par06

	if _nPesaD = 2
		alert('Captura de pesagem desabilitada!')
	endif

	SetKey(123,{|| gjf69par()}) // Seta a tecla F12 para acionamento dos parametros

	SET FILTER TO ZZD->ZZD_DATA = date() .and. ZZD->ZZD_FILIAL = FWxfilial('ZZD')

	mBrowse(6      ,1      ,22     ,75     ,cString, ,,,,1     ,)
	//      LIN INI,COL INI,LIN FIN,COL FIN,ALIAS  , ,,,,funcao,cores

	Set Key 123 To // Desativa a tecla F12 do acionamento dos parametros

	DbCloseArea('ZZD')

Return

//PRODUCAO - PESAGEM
user function gjf69pes()

	Private prox  := 0 
	Private campo := space(24)
	Private valor := space(24)

	dbSelectArea('SZO')
	SZO->(dbSetorder(1))  // tipo+data+sequen
	SZO->( MsSeek(FWxFilial('SZO')+'E'+DTOS(ddatabase) ) )
	Do While !SZO->(Eof()) .AND. SZO->ZO_DATA == ddatabase .AND. SZO->ZO_TIPO == 'E'
		prox := Val( SZO->ZO_SEQUEN )
		SZO->( dbSkip() )
	Enddo
	SZO->( dbSkip(-1) )
	prox++

	pergunte(cPerg,.f.)

	_nTara := mv_par02

	criaTMP()

	DEFINE MSDIALOG oDlg TITLE 'Pesagem de Produto Acabado' from 0,0 To 550,600 PIXEL

	oSayDesc   := tSay():New(100,010,{|| oDesc },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30) 
	oSayOK     := tSay():New(080,180,{||  oCl },oDlg,,oFont3,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30) 
	oSayOK2    := tSay():New(120,160,{||  oCl2 },oDlg,,oFont4,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30) 
	oSayTTras  := tSay():New(110,005,{|| oTTras},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayPesoB  := tSay():New(120,005,{|| oPesoB},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayPesoP  := tSay():New(130,005,{|| oPesoP},oDlg,,oFont2,,,,.T.,,,200,30)

	@ 06,02 SAY "Leitura:"  

	@ 06,05 MSGET campo VAR valor SIZE 80,11 OF oDlg VALID gjf69v()

	@ 150,005 To 240,295 Browse "TMP"  fields aCampos object oBrow 

	oBrow:oBrowse:refresh()

	@ 245,240  BUTTON 'Abandonar'  SIZE 57,20 ACTION ODlg:end()  OBJECT oBtn2

	ACTIVATE MSDIALOG oDlg CENTERED //ON INIT EnchoiceBar(oDlg,{||gjf17ok()},{||ODlg:end()})

return


//Para excluir uma pesagem
user function gjf69del(_mod, _cNum)
	ZAJ->(dbsetorder(2))
	ZAJ->(DbGoTop())
	if ZAJ->(Msseek(FWxfilial('ZAJ')+_cNum))

		SZ2->(dbsetorder(2))
		SZ2->(DbGoTop())
		if SZ2->(Msseek(FWxfilial('SZ2')+ZAJ->ZAJ_PREDES))
		//para descontar a quantidade já produzida na previsão de produção

			reclock('SZ2',.f.)
			if SZ2->Z2_STATUS = 'E'
				SZ2->Z2_STATUS := 'I'
			endif
			SZ2->Z2_QRPESO := SZ2->Z2_QRPESO - ZAJ->ZAJ_PESO
			SZ2->Z2_QRPECA := SZ2->Z2_QRPECA - 1
			msunlock()
		endif

		ZZD->(DbSetOrder(4))
		ZZD->(DbGoTop())
		if ZZD->(MsSeek(FWxfilial('ZZD')+ZAJ->ZAJ_NUM))
			reclock('ZZD',.f.)
			DBdelete()
			msunlock()
		endif

		SZO->(DbSetOrder(3))
		SZO->(DbGoTop())
		if SZO->(MsSeek(FWxfilial('SZO')+ZAJ->ZAJ_NUM))
			reclock('SZO',.f.)
			DbDelete()
			msunlock()
		endif

		RecLock('ZAJ',.f.)
		ZAJ->ZAJ_DATAS := stod('')
		ZAJ->ZAJ_HORAS := ''
		msunlock()

		u_gjf182hs(1,"EXCL.PROD.DES.")

		if _mod = '1'
			apmsginfo("Operação realizada com sucesso!","Exclusão")
		endif
	endif
return


static function gjf69pre(_mod, _Tara)
	//função para atualizar a quantidade produzida na previsão de produção

	SZ2->(DbSetOrder(2))
	if !SZ2->(MsSeek(FWxfilial('SZ2')+ZAJ->ZAJ_PREDES))
		if _mod = '1'
			alert('ERRO - Localização da Previsão de Produção Desossa!')
		else
			u_MR05NA('ERRO - Prev. Prod. Des.!')	
		endif
		return .f.
	else 

		_qPrevP   := SZ2->Z2_QPPECA
		_qRealP   := SZ2->Z2_QRPECA

		_qPrevPP  := iif(empty(ZAJ->ZAJ_ZAPNUM),SZ2->Z2_QPPESO,0.00)
		_qPrevPR  := iif(empty(ZAJ->ZAJ_ZAPNUM),SZ2->Z2_QRPESO,0.00) 

		if SZ2->Z2_QPPECA = _qRealP + 1
			reclock('SZ2',.f.)
			SZ2->Z2_STATUS := 'E' 
			msunlock()
			if _mod = '1'
				msgbox('Previsao de Produção de número ' + alltrim(ZAJ->ZAJ_PREDES) + 'realizada completamente!','ATENÇÃO!','INFO')
			else
				u_MR05NA('Prev.Prod. ' + alltrim(ZAJ->ZAJ_PREDES)  + ' completa!')		
			endif
		endif

		reclock('SZ2',.f.)
		SZ2->Z2_QRPECA := _qRealP + 1
		SZ2->Z2_QRPESO := iif(empty(ZAJ->ZAJ_ZAPNUM),SZ2->Z2_QRPESO +  (_nPeso - _Tara),0.00)  

		if SZ2->Z2_STATUS = 'A'
			SZ2->Z2_STATUS := 'I'
		endif
		MsUnLock()

	endif
return .t.

// para capturar o peso    
// _mod = 1 -> utilização da função em rotina para PC
// _mod = 2 -> utilização da função em rotina para coletor de dados
user Function gjf69cap(_mod)

	nPeso := 0

	if _mod = '1'
		nHdll := 0

		if !MSOpenPort(nHdll,mv_par03)
			msgbox("Não foi possível pegar informações da porta!",,"STOP")
			lOk := .f.
			Return 0
		endif

		cText := space(15)
		if !MsRead(nHdll,@cText)
			msgbox("Não foi possível pegar informações da porta!",,"STOP")
			lOk := .f.
			Return 0
		endif

		inkey(1)
		if empty(cText)
			inkey(1)
			cText := space(15)
			MsRead(nHdll,@cText)
		endif

		do Case
			Case at("p`",cText)> 0
			cPeso := substr(cText,at("p`",cText)+2,6)
			cC := "`"

			Case at("`",cText) > 0
			cPeso := substr(cText,at("`",cText)+1,6)
			cC := "`"

			Case at("p ",cText)> 0
			cPeso := substr(cText,at("p ",cText)+2,6)
			cC := " "

			Otherwise
			cPeso :='000000'
			cC := ""
		Endcase

		cPeso := substr(cText,at("`",cText)+1,6)
		cPeso := substr(cText,at(cC,cText)+1,6)

		nPeso := val(cPeso)/(10**mv_par04)

		if valtype(nPeso) == 'N'
			v := npeso
		else
			v     := 0
			nPeso := 0
		endif
		msClosePort(nHdll)
		lOk := .t.

	else

		//conecta
		conectBal()    

		//captura
		nPeso := newCaptura()

	endif

Return nPeso


//função separada para capturar peso com a balança nova
Static Function newCaptura()

	local _nTam     := getMv('SI_QTSTR')//parametro com valor total de strings de peso a serem armazenadas para tratamento
	local _nStrOk   := 0	        
	local aStrings  := {}
	local aPesos    := {}
	local _nPeso 	:= 0
	local _nMaior   := 0
	local _nCont    := 0
	local cPeso     := ""
	local cC        := ""
	local _cBuffer  := ""
	local _nPesosOk := 0	 		              		     
	local i
	local j         	

	//bloco que armazena as strings que tiverem o peso estável
	for i:=1 to _nTam                    	                 
		_cBuffer := ""	 
		nQtd 	   := oObj:Receive( @_cBuffer, 1000 )		
		if "3p" $ alltrim(_cBuffer)//SE TIVER "3P" NA STRING QUER DIZER QUE É UM PESO ESTAVEL			
			aAdd(aStrings,_cBuffer)   	
			_nStrOk++
		endif					
	next

	//verifica se o buffer não esta sendo retornado em branco, caso esteja reconecta na balança
	if empty(_cBuffer)
		conectBal()		                        	
	endif

	//bloco para tratamento das strings com peso estável             
	for i:= 1 to len(aStrings) //_nStrOk
		do Case
			Case at("p`",aStrings[i])> 0
			cPeso := substr(aStrings[i],at("p`",aStrings[i])+2,6)
			cC := "`"

			Case at("`",aStrings[i]) > 0
			cPeso := substr(aStrings[i],at("`",aStrings[i])+1,6)
			cC := "`"

			Case at("p ",aStrings[i])> 0
			cPeso := substr(aStrings[i],at("p ",aStrings[i])+2,6)		
			cC := " "

			Otherwise
			cPeso :='000000'
			cC := ""
		Endcase

		cPeso := substr(aStrings[i],at("`",aStrings[i])+1,6)
		cPeso := substr(aStrings[i],at(cC,aStrings[i])+1,6)
		_nPeso := val(cPeso)/(10)              
		if _nPeso > 0 //adiciona no vetor de pesos ok somente pesos acima de zero
			aAdd(aPesos,_nPeso)		
			_nPesosOk++
		endif
	next        

	//bloco para tratamento de incidencias, ou seja, utiliza somente o peso que tiver mais incidencias dentro do vetor
	for i:= 1 to len(aPesos)//_nPesosOk
		_nCont := 0
		for j:=1 to len(aPesos)//_nPesosOk
			if aPesos[i] == aPesos[j]
				_nCont++					
			endif		
		next            

		if _nCont > _nMaior 
			_nPeso  := aPesos[i] - _nTara
			_nMaior := _nCont
		endif      			                        		
	next                       

return _nPeso


//função para conectar na balança
Static Function conectBal()

	//Define o IP da balança a se utilizada
	//_cIpBal := alltrim(GetAdvFVal('ZAM',1,FWxFilial('ZAM') + iif(_cPar02 = '1','BABT1','BABT2'),'ZAM_IP'))

	if empty(_cIpBal)	
		vtalert('Endereço IP da balança não encontrado!')
		return
	endif

	//Se a balança já estiver conectada, disconecta...

	if _lBal
		oObj:CloseConnection()
	endif                                                

	oObj  := tSocketClient():New()            
	nResp := oObj:Connect( 9092, _cIpBal,1000)  //9092		
	nResp := oObj:Send( 'Teste' )                

	_lBal := .t.

return


//Função que controla a validação da carcaça
static function gjf69v()

	//Parametro de classificação especial
	local _cClasEsp := GetMv('SI_CLASESP')

	_NumPrev := ''

	if empty(valor)
		return .t.
	endif


	SZK->(DbSetorder(4))

	ZAJ->(DbSetOrder(2))
	if !ZAJ->(MsSeek(FWxfilial('ZAJ')+alltrim(valor)))
		alert('Codigo de carcaça não identificado!')
		return .f.
	else

		_cRastro := ZAJ->(ZAJ_NUMAM + ZAJ_CONTRO)
		_cProd   := ZAJ->ZAJ_COD
		_cLado   := ZAJ->ZAJ_LADO
		_cCorOri := ZAJ->ZAJ_CORORI

		if !SZK->(MsSeek(FWxfilial('SZK') + _cRastro ))
			//Função que determina os labelas da tela de produção
			DefLbl1()
			msgbox('Carcaça inexistente!','OPERAÇÃO INVALIDA!','STOP')
			Return .f.
		else
			_lcontrol := .t.
		endif

	endif

	if empty(SZK->ZK_CLASSIF)
		//Função que determina os labels da tela de produção
		DefLbl1()
		alert('Problema na classificação da carcaça. Recolha a etiqueta e envie ao DTI!')
		SomErr()
		return .f.
	endif

	_NumPrev := ''

	//Criado parametro para classificação especial genérica em carcaças
	//se por algum motivo em especial precisar classificar as carcaças
	//utiliza-se esse mecanismo para controlar a entrada das peças na
	//desossa com essa classificação   (SI_CLASESP)
	//Não inclui nessa verificação a costela
	/*
	if _cClasEsp = 'S' .and. _cCorOri <> 'C'
	//if SZK->ZK_CLASESP <> '1' .and. AllTrim(SZK->ZK_CLASSIF) = 'NE'
	if SZK->ZK_CLASESP = '2' .or. AllTrim(SZK->ZK_CLASSIF) = 'NE'
	DefLbl1()
	msgbox('Classificação especial impede a produção desta peça!','PARAMETRO DE CLASSIFICAÇÃO ESPECIAL ATIVADO!','STOP')
	Return .f.
	endif
	elseif _cClasEsp = 'N'
	if SZK->ZK_CLASESP = '1' .and. AllTrim(SZK->ZK_CLASSIF) <> 'NE'
	DefLbl1()
	msgbox('Classificação especial impede a produção desta peça!','PARAMETRO DE CLASSIFICAÇÃO ESPECIAL ATIVADO!','STOP')
	Return .f.
	endif
	endif
	*/
	if !empty(ZAJ->ZAJ_DATAS) .and. !empty(ZAJ->ZAJ_HORAS)
		DefLbl1()
		msgbox('Peça já processada ou fora de estoque!','OPERAÇÃO IRREGULAR!','STOP')
		Return .f.
	endif

	//if ZAJ->ZAJ_CORORI <> 'C'


	SZ2->(DbSetOrder(2))   

	//Se existe reserva de carcaça
	if SZ2->(MsSeek(FWxfilial('SZ2') + ZAJ->ZAJ_PREDES))
		if  date() < SZ2->Z2_DTPROD  .or. date() > SZ2->(Z2_DTPROD + Z2_DIASVAL)
			//Função que define os labels na tela de produção
			DefLbl1()
			msgbox('Previsão de produção não existente!','OPERAÇÃO INVÁLIDA!','STOP')
			return .f.
		endif

		if SZ2->Z2_STATUS = 'B' .or. SZ2->Z2_STATUS = 'E'
			//Função que determina os labelas da tela de produção
			DefLbl1()
			msgbox('Previsão de Produção bloqueada ou já encerrada!','OPERAÇÃO INVÁLIDA!','STOP')
			return .f.
		endif

		_NumPrev := ZAJ->ZAJ_PREDES

		//Se não existe reserva de carcaça
	else

		do case
			case AllTrim(SZK->ZK_CLASSIF) = 'RT'
			_cClass := "('RT','RU','HK','NE')"
			case AllTrim(SZK->ZK_CLASSIF) = 'RU'
			_cClass := "('HK','RU','HK')"
			case AllTrim(SZK->ZK_CLASSIF) = 'HK'
			_cClass := "('HK','NE')"
			case AllTrim(SZK->ZK_CLASSIF) = 'NE'
			_cClass := "('NE')"
		endcase

		//para verificação se existe previsao de produção
		_cQuery := "  SELECT Z2_DIASVAL AS DIAS, Z2_CORORI AS CORORI,Z2_NUM AS NUM FROM "+RetSqlTab("SZ2")
		_cQuery += "  WHERE " + RetSQLFil('SZ2')
		//verificações iniciais
		_cQuery += "  AND Z2_RESERV  = 'N'"
		_cQuery += "  AND Z2_STATUS <> 'E' AND Z2_STATUS <> 'B' "
		_cQuery += "  AND Z2_CORORI  = '" + alltrim(ZAJ->ZAJ_CORORI) + "'"
		_cQuery += "  AND Z2_DTPROD <= '" + DTOS(ddatabase) + "'"
		_cQuery += "  AND Z2_NUMAM   = '" + SZK->ZK_NUMAM + "'"

		//verifica se é apenas por dentição
		_cQuery += "  AND ((Z2_PRIORID  = 'D') OR"
		//verifica se é por rastreabilidade, programa ou ambos
		_cQuery += "  ((  Z2_CLASSIF IN " + _cClass
		_cQuery += "  AND Z2_TIPIFI  = '" + SZK->ZK_TIPIFI + "'"
		_cQuery += "  AND Z2_PRIORID  = 'R') OR ("
		_cQuery += "      Z2_PRIORID  = 'P'"
		_cQuery += "  AND Z2_PROGRAM  = '" + SZK->ZK_PROGRAM + "') OR ("
		_cquery += "      Z2_PRIORID  = 'A'"
		_cQuery += "  AND Z2_PROGRAM  = '" + SZK->ZK_PROGRAM + "'"
		_cQuery += "  AND Z2_CLASSIF IN " + _cClass
		_cQuery += "  AND Z2_TIPIFI  = '" + SZK->ZK_TIPIFI + "')) OR"
		//inclui na verificação a categoria
		_cQuery += "   (( Z2_CLASSIF IN " + _cClass
		_cQuery += "  AND Z2_TIPIFI  = '" + SZK->ZK_TIPIFI + "'"
		_cQuery += "  AND Z2_PRIORID  = 'R' AND Z2_CATEG = '" + SZK->ZK_CATEG + "') OR ("
		_cQuery += "      Z2_PRIORID  = 'P' AND Z2_CATEG = '" + SZK->ZK_CATEG + "'"
		_cQuery += "  AND Z2_PROGRAM  = '" + SZK->ZK_PROGRAM + "') OR ("
		_cquery += "      Z2_PRIORID  = 'A' AND Z2_CATEG = '" + SZK->ZK_CATEG + "'"
		_cQuery += "  AND Z2_PROGRAM  = '" + SZK->ZK_PROGRAM + "'"
		_cQuery += "  AND Z2_CLASSIF IN " + _cClass
		_cQuery += "  AND Z2_TIPIFI  = '" + SZK->ZK_TIPIFI + "')) OR"

		//inclui na verificação classificação especial
		_cQuery += "   (Z2_PRIORID  = 'C') OR"

		//inclui na verificação a dentição
		_cQuery += "   (( Z2_CLASSIF IN " + _cClass
		_cQuery += "  AND Z2_TIPIFI  = '" + SZK->ZK_TIPIFI + "'"
		_cQuery += "  AND Z2_PRIORID  = 'R' AND Z2_CATEG = '" + SZK->ZK_CATEG + "' AND Z2_DENT = '" + SZK->ZK_DENT + "') OR ("
		_cQuery += "      Z2_PRIORID  = 'P' AND Z2_CATEG = '" + SZK->ZK_CATEG + "' AND Z2_DENT = '" + SZK->ZK_DENT + "'"
		_cQuery += "  AND Z2_PROGRAM  = '" + SZK->ZK_PROGRAM + "') OR ("
		_cquery += "      Z2_PRIORID  = 'A' AND Z2_CATEG = '" + SZK->ZK_CATEG + "' AND Z2_DENT = '" + SZK->ZK_DENT + "'"
		_cQuery += "  AND Z2_PROGRAM  = '" + SZK->ZK_PROGRAM + "'"
		_cQuery += "  AND Z2_CLASSIF IN " + _cClass
		_cQuery += "  AND Z2_TIPIFI  = '" + SZK->ZK_TIPIFI + "')))"
		_cQuery += "  AND " + RetSQLDel('SZ2')
		_cQuery += "  ORDER BY Z2_CORORI, Z2_NUM"
		_cQuery := ChangeQuery(_cQuery)

		//	* Mostrar a consulta */
		//	@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//	@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
		//	Activate Dialog oDlgMemo

		If Select("DES")<>0
			DES->(dbCloseArea())
		Endif

		TCQUERY _cQuery NEW ALIAS "DES"

		DES->(DbGotop())
		while DES->(!eof())
			SZ2->(DbSetOrder(2))
			SZ2->(MsSeek(FWxfilial('SZ2')+DES->NUM))

			if ddatabase > SZ2->(Z2_DTPROD + Z2_DIASVAL)
				DES->(DbSkip())
				loop
			else

				_NumPrev := DES->NUM
				exit
			endif

			DES->(DbSkip())
		enddo

		if empty(_NumPrev)
			//Função que determina os labels da tela de produção
			DefLbl1()

			msgbox('Produção não prevista para esse produto ou já encerrada!','NAO É POSSIVEL PRODUZIR!','STOP')
			DES->(dbclosearea())

			return .f.
		endif

	endif
	//endif


	DbSelectArea('SB1')

	_cTPTrase := iif(ZAJ->ZAJ_CORORI = 'T',iif(mv_par01 = 1,'E','L'),'')
	_cDest    := iif(_nDest = 2,'C','D')

	oCl   := SZK->ZK_CLASSIF
	oCl2  := GetAdvFVal('SZ6','Z6_DESC',FWxfilial('SZ6')+SZK->ZK_PROGRAM,1)
	oDesc := GetAdvFVal('SB1','B1_DESCRED',FWxfilial('SB1')+ZAJ->ZAJ_COD,1)
	oSayDesc:SetText(oDesc)
	oSayOk:SetText(oCl)
	oSayOk2:SetText(oCl2)

	u_gjf69pro('1',_PesaD,_nTara,_cTPTrase,_cDest )

	oSayTTras:SetText(oTTras)
	oSayPesoP:SetText(oPesoP)
	oSayPesoB:SetText(oPesoB)

	criaTMP()

	oBrow:oBrowse:refresh()
	oDlg:Refresh()

return .f.

//Função que define os labelas 
//na tela de produção
Static Function DefLbl1()
	SomErr()
	oCl   := '' 
	oCl2  := ''           
	oDesc := ''
	oSayDesc:SetText(oDesc)
	oSayOk:SetText(oCl)
	oSayOk2:SetText(oCl2)
return 

//Função que define os labelas 
//na tela de produção em lote
Static Function DefLbl2()
	SomErr()
	oCl   := '' 
	oCl2  := ''           
	oDesc := ''
	oSayDescL:SetText(oDesc)
	oSayOkL:SetText(oCl)
	oSayOk2L:SetText(oCl2)
return              


//Função que efetiva a produção
// _mod = 1 -> utilização da função em rotina para PC
// _mod = 2 -> utilização da função em rotina para coletor de dados
User Function gjf69pro(_mod,    _PD  , _T ,    _TPT  ,   _D  )
	//   modo, Hab.Bal.,Tara,Tipo Tras.,Destino
	Local _cCorLDes := alltrim(GETMV('SI_CORLDES'))

	SZK->(DbSetOrder(4))
	_nPeso  := 0.00
	_nPesoI := 0.00
	_nPesoB := 0.00          
	_nPesoL := 0.00

	if _PD = '1'
		sleep(500)
		_nPeso := u_gjf69cap(_mod)

	elseif empty(ZAJ->ZAJ_ZAPNUM) //verifica se a carcaça não é de terceiro
		SZK->(MsSeek(FWxfilial('SZK')+ZAJ->(ZAJ_NUMAM + ZAJ_CONTRO)))

		/*_nPeso := iif(ZAJ->ZAJ_CORORI = 'T',0.4966 * iif(ZAJ->ZAJ_LADO = 'E',SZK->ZK_PECARC1,SZK->ZK_PECARC2),;
		iif(ZAJ->ZAJ_CORORI = 'D',0.3672 * iif(ZAJ->ZAJ_LADO = 'E',SZK->ZK_PECARC1,SZK->ZK_PECARC2),;
		0.1362 * iif(ZAJ->ZAJ_LADO = 'E',SZK->ZK_PECARC1,SZK->ZK_PECARC2)))*/

		_nPerTras  := GetMV('SI_%TRAS')
		_nPerDian  := GetMV('SI_%DIAN')
		_nPerCost  := GetMV('SI_%COST')

		_nPesoI := iif(ZAJ->ZAJ_CORORI = 'T',_nPerTras * iif(ZAJ->ZAJ_LADO = 'E',SZK->ZK_PECARC1,SZK->ZK_PECARC2),;
		iif(ZAJ->ZAJ_CORORI = 'D',_nPerDian * iif(ZAJ->ZAJ_LADO = 'E',SZK->ZK_PECARC1,SZK->ZK_PECARC2),;
		_nPerCost * iif(ZAJ->ZAJ_LADO = 'E',SZK->ZK_PECARC1,SZK->ZK_PECARC2))) 

		_nPeso := _nPesoI - (_nPesoI * 0.02)  // -2% de frio	          

	endif

	if _nPeso < 10 .and. _PD = '1'    
		if _mod = '1'
			//Função para definição dos label
			DefLbl1()
			msgbox('Peso capturado inconsistente!','PROBLEMAS NA PESAGEM','STOP')
		else
			u_MR05NA('Peso capturado inconsistente!')	
		endif
		return .f.
	endif

	if ZAJ->ZAJ_CORORI <> 'C' .and. !(alltrim(ZAJ->ZAJ_COD) $ _cCorLDes)  //Costela não precisa de previsão de produção
		gjf69pre(_mod,_T)            									  //Atualiza previsão
	endif      

	if empty(ZAJ->ZAJ_ZAPNUM)
		if _PD = '1'
			_nPesoL := _nPeso - _T
			_nPesoB := _nPeso
		else		
			_nPesoB := _nPeso + _T
			_nPesoL := _nPeso
		endif
	endif

	if _mod = '1' 
		iif(_TPT = 'E',oTTras := 'Tipo Traseiro: Estreito',iif(_TPT = 'L', oTTras := 'Tipo Traseiro: Largo',oTTras := ''))
		oPesoP := 'Peso Liquido: ' + transform(_nPesoL,'@E 99.999')
		oPesoB := 'Peso Bruto:   ' + transform(_nPeso ,'@E 99.999')
	elseif empty(ZAJ->ZAJ_ZAPNUM)
		_cPesoL := transform(_nPesoL,'@E 99.999')
		_cPesoB := transform(_nPeso ,'@E 99.999') 
	endif

	reclock('ZZD',.t.)
	ZZD->ZZD_CONTRO  := ZAJ->ZAJ_NUM
	ZZD->ZZD_DATA    := date()
	ZZD->ZZD_HORA    := time()
	ZZD->ZZD_TPTRAS  := _TPT
	ZZD->ZZD_FILIAL  := FWxfilial('ZZD')
	ZZD->ZZD_RASTRO  := iif(empty(ZAJ->ZAJ_ZAPNUM),ZAJ->(ZAJ_NUMAM + ZAJ_CONTRO),"")
	ZZD->ZZD_COD     := ZAJ->ZAJ_COD
	ZZD->ZZD_DESCRI  := ZAJ->ZAJ_DESCRI
	ZZD->ZZD_EXPORT  := iif(empty(ZAJ->ZAJ_ZAPNUM),SZK->ZK_CLASSIF,"")
	ZZD->ZZD_TIPIFI  := iif(empty(ZAJ->ZAJ_ZAPNUM),SZK->ZK_TIPIFI,"")
	ZZD->ZZD_PESOB   := iif(empty(ZAJ->ZAJ_ZAPNUM),_nPesoB,ZAJ->ZAJ_PESO+_T)
	ZZD->ZZD_PESOP   := iif(empty(ZAJ->ZAJ_ZAPNUM),_nPesoL,ZAJ->ZAJ_PESO)
	ZZD->ZZD_TARA    := _T    
	ZZD->ZZD_PREV    := _NumPrev 
	ZZD->ZZD_LADO    := ZAJ->ZAJ_LADO 
	ZZD->ZZD_DEST    := _D  
	ZZD->ZZD_CORORI  := ZAJ->ZAJ_CORORI
	msunlock()

	DbCloseArea('SZK')

	RecLock('SZO',.T.)
	SZO->ZO_FILIAL  := FWxFilial('SZO')
	SZO->ZO_DATA    := date()
	SZO->ZO_HORA    := time()
	SZO->ZO_DEST    := _D
	SZO->ZO_PROD    := ZAJ->ZAJ_COD
	SZO->ZO_QUANT   := 1.00  
	SZO->ZO_TARA    := _T
	SZO->ZO_PESOB   := iif(empty(ZAJ->ZAJ_ZAPNUM),_nPesoB,ZAJ->ZAJ_PESO+_T)
	SZO->ZO_PESOL   := iif(empty(ZAJ->ZAJ_ZAPNUM),_nPesoL,ZAJ->ZAJ_PESO)
	SZO->ZO_TIPO    := 'E'   //entrada
	SZO->ZO_SEQUEN  := STRZERO(prox,6) 
	SZO->ZO_NUM     := ZAJ->ZAJ_NUM
	prox++
	MsUnlock()

	_cPredes := iif(empty(ZAJ->ZAJ_PREDES),_NumPrev,ZAJ->ZAJ_PREDES)

	reclock('ZAJ',.f.)
	ZAJ->ZAJ_PREDES := _cPredes
	ZAJ->ZAJ_DATAS  := date()
	ZAJ->ZAJ_HORAS  := time() 
	ZAJ->ZAJ_PESO   := iif(empty(ZAJ->ZAJ_ZAPNUM),_nPesoL,ZAJ->ZAJ_PESO)
	ZAJ->ZAJ_PESOB  := iif(empty(ZAJ->ZAJ_ZAPNUM),_nPesoB,ZAJ->ZAJ_PESO+_T)
	ZAJ->ZAJ_TARA   := _T  
	ZAJ->ZAJ_TPTRAS := _TPT  
	ZAJ->ZAJ_DEST   := _D
	msunlock()  

	//Aqui, varre as Prev. de embalagem vinculadas
	//verfica se a prioridade é por peça e incrementa
	//no campo ZU_QPQUANT
	//Modificado pelo Giuliano dia 14/01/16
	SZU->(DbGoTop())
	SZU->(DbSetOrder(4))
	if SZU->(MsSeek(FWxfilial('SZU')+_cPredes))       
		while  SZU->(!eof()) .and. SZU->ZU_FILIAL = FWxfilial('SZU') .and. SZU->ZU_PREDES = _cPredes

			if SZU->ZU_PRIORI = 'E'      
				reclock('SZU',.f.)
				SZU->ZU_QPQUANT++
				SZU->ZU_FECHADO := 'N'
				msunlock()
			endif

			SZU->(DbSkip())
		enddo
	endif

	/////////////////////////////////////////////////////
	/////////////////BLOCO EM CONSTRUÇÃO/////////////////
	/////////////////BY GIULIANO/////////////////////////
	/////////////////////////////////////////////////////
	if ZAJ->ZAJ_CORORI = 'T'
		_cCodOri := '005016'
	elseif ZAJ->ZAJ_CORORI = 'D'
		_cCodOri := '005020'
	elseif  ZAJ->ZAJ_CORORI = 'C'
		_cCodOri := '002018'
	endif

	ZB9->(DbGoTop())
	ZB9->(DbSetOrder(1))
	if ZB9->(MsSeek(FWxfilial('ZB9')+_cPredes))       
		while ZB9->(!eof()) .and. ZB9->ZB9_FILIAL = FWxfilial('ZB9') .and. ZB9->ZB9_PREDES = _cPredes

			reclock('ZB9',.f.)
			ZB9->ZB9_QPPECA++
			msunlock()   

			ZB9->(DbSkip())
		enddo
	else     
		SG1->(DbSetOrder(2))
		if SG1->(MsSeek(FWxfilial('SG1') + _cCodOri))
			while SG1->(!eof()) .and. SG1->G1_FILIAL = FWxfilial('SG1') .and. SG1->G1_COMP = _cCodOri

				DbSelectArea('SB1')
				_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1') + SG1->G1_COD,1)

				if _cGrupo = '9000'
					reclock('ZB9',.t.)
					ZB9->ZB9_FILIAL := FWxfilial('ZB9')
					ZB9->ZB9_CODPP  := SG1->G1_COD
					ZB9->ZB9_PREDES := _cPredes
					ZB9->ZB9_QPPECA := 1
					msunlock()
				endif

				SG1->(DbSkip())
			enddo
		endif  

	endif
	/////////////////////////////////////////////////////
	////////////FIM DO BLOCO EM CONSTRUÇÃO///////////////
	/////////////////////////////////////////////////////

	if (empty(ZAJ->ZAJ_DTCORT))
		gravDtCort(ZAJ->ZAJ_NUM)
	endif        

	u_gjf182hs(2,'PROD. DESOSSA')

	if _mod = '1'	
		ExecSom()  
	endif

Return       

Static Function gravDtCort(_codBar)

	ZAJ->(DbGoTop())
	ZAJ->(DbSetOrder(9)) //num + numam + control
	if ZAJ->(MsSeek(FWxFilial('ZAJ')+alltrim(_codBar))) .and. len(alltrim(_codBar)) = 10

		_cNumam 	 := ZAJ->ZAJ_NUMAM
		_cControl := ZAJ->ZAJ_CONTRO
		_cLado    := ZAJ->ZAJ_LADO

		if empty(ZAJ->ZAJ_ZAPNUM)//se este campo estiver em branco significa que NÃO é carcaça de terceiro		

			ZAJ->(dbSetOrder(1))
			ZAJ->(MsSeek(FWxFilial('ZAJ') + _cNumam + _cControl))
			while ZAJ->(!eof()) .and. (FWxFilial('ZAJ') == ZAJ->ZAJ_FILIAL) .and. (ZAJ->ZAJ_NUMAM == _cNumam) .and. (ZAJ->ZAJ_CONTRO == _cControl)  	

				if ZAJ->ZAJ_LADO != _cLado
					ZAJ->(dbSkip())
					loop	   
				endif            

				reclock('ZAJ',.f.)               
				ZAJ->ZAJ_DTCORT := dDataBase
				msunlock()
				ZAJ->(dbSkip())	
			enddo        

		else

			reclock('ZAJ',.f.)
			ZAJ->ZAJ_DTCORT := dDataBase
			msunlock()

		endif

	endif

return

Static Function gjf69par()
	pergunte(cPerg,.t.)

	_nTara     := mv_par02
	_nDest     := mv_par06 
	_nPesaD    := mv_par05
Return

Static Function SomErr()
	WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0)
return

static function execsom()                                                           //Serve para executar o som ao ler caixa ou peça
	WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE.WAV',0)

return


//Rotina para criar o arquivo temporário 
//para totalizadores de peças processadas
Static Function  criaTMP()

	//If Select('TMP')<>0                                                         
	//	DbSelectArea('TMP')
	//	DbCloseArea('TMP')
	//endif

	_aArqTrb := {}

	aCampos := {}
	aadd(aCampos,{"COD"   ,"Codigo"   ,"@!"       })
	aadd(aCampos,{"DESCRI","Descricao","@!"       })
	aadd(aCampos,{"TPTRAS","Tipo"     ,"@!"       })
	aadd(aCampos,{"QUANT" ,"Quant"    ,"@E 9,999"   })
	aadd(aCampos,{"PESOP" ,"Peso"     ,"@E 999,999.99"})
	aadd(aCampos,{"DEST"  ,"Destino"  ,"@!"})

	aStru := {}
	aadd(aStru,{"COD"    , "C",  06, 0,   "@!"           ,'Codigo'   })
	aadd(aStru,{"DESCRI" , "C",  30, 0,   "@!"           ,'Descricao'})
	aadd(aStru,{"TPTRAS" , "C",  10, 0,   "@!"           ,'Tipo Tras.'})  
	aadd(aStru,{"QUANT"  , "N",  06, 0,   "@E 999,999"   ,'Quant.'})
	aadd(aStru,{"PESOP"  , "N",  09, 2,   "@E 999,999.99",'Peso  '})  
	aadd(aStru,{"DEST"   , "C",  15, 0,   "@!"           ,'Destino'})  


	cQuery := " SELECT ZZD_COD AS COD, ZZD_DESCRI AS DESCRI, ZZD_TPTRAS AS TPTRAS,ZZD_DEST AS DEST, SUM(ZZD_PESOP) AS PESOP, COUNT(*) AS QUANT "
	cQuery += " FROM "  + RetSqlTab("ZZD") 
	cQuery += " WHERE " + RetSqlFil("ZZD") + " AND  "
	cQuery += " ZZD_DATA = '" + dtos(date()) + "' AND " +RetSQLDel('ZZD')
	cQuery += " GROUP BY ZZD_COD, ZZD_DESCRI, ZZD_TPTRAS, ZZD_DEST "
	cQuery += " ORDER BY ZZD_COD "
	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery1 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	cQuery := ChangeQuery(cQuery)

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "QRY"

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	//dbcreate(cArq,aStru)
	//Cria a estrutura do vetor no TMP criado
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)


	QRY->(DbGoTop())

	While QRY->(!eof())
		DbSelectArea('TMP')
		reclock('TMP',.t.)
		TMP->COD    := QRY->COD
		TMP->DESCRI := QRY->DESCRI
		TMP->TPTRAS := iif(QRY->TPTRAS = 'E','Estreito',iif(QRY->TPTRAS = 'L','Largo',''))
		TMP->QUANT  := QRY->QUANT
		TMP->PESOP  := QRY->PESOP
		TMP->DEST   := iif(QRY->DEST = 'D','Desossa','Carregamento')
		msunlock()

		QRY->(DbSkip())
	enddo

	TMP->(DbGoTop())

Return 

