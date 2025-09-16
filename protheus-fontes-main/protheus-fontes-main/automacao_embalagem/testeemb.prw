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
±±ºPrograma  ³GJF110    º Autor ³ Giuliano Forgiariniº Data ³  17/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Rotina de controle de automação da embalagem                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAPCP                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function EMBTESTE()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	private oFont     := tFont():New("courier new",,-36,,.t.,,,,)
	private oFont2    := tFont():New("courier new",,-24,,.t.,,,,)     
	private oFont3    := tFont():New("courier new",,-24,,,,,,)     
	Private oCodigo   := ''
	Private oDescri   := ''
	Private oTitPB    := 'Peso Bruto:' 
	Private oPB       := 0
	Private oTitTa    := 'Tara:' 
	Private oTa       := 0
	Private oTitPL    := 'Peso Liq.:'
	Private oPL       := 0
	Private oMens1    := ''
	Private oMens2    := ''
	Private oStatus   := ''
	Private _cCodPro  := '' 
	Private _cSeqPETQ := '' 
	Private _nQuant   := 0
	Private _nPeso    := 0
	Private _nPesoL   := 0
	Private _nTara    := 0 
	Private _cPreEmb  := ''
	Private _cPreDes  := ''
	Private _testPes  := 40 
	Private _cControl := ''      
	Private nHdll     := 0   
	Private _lFailCon := .f.   
	Private _nTamZA9  := 0
	Private _nRejeite := 1  
	Private _cStrBal  := ''
	Private _nTime    := 1000   //tempo em milissegundos usado para frear o loop de produção

	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" //MODULO "FAT" TABLES "SA1", "SB1"

	_nRejeite := 1
	//Private _lProduz  := .t.
	//Bloco que apaga os logs deixando os ultimos 100 registros
	ZA9->(DbSetOrder(1))
	ZA9->(DbGoTop())  

	_nTamZA9 := ZA9->(RecCount()) 

	//Inicia a DLL para ativação da rele
	_nHd := ExecInDllOpen('rele.dll')  

	//Abre conexão para porta serial COM1 

	if !MSOpenPort(nHdll,"COM1:9600,s,8,1") 
		//falha 2 
		alert('Falha comunicação COM!(2)' )  
		oStatus := '[Falha conexão porta COM]'        
		_lFailCon := .t.  
		MsClosePort(nHdll) 
	endif

	DEFINE MSDIALOG oAut TITLE 'AUTOMAÇÃO DE PESAGEM E ETIQUETAGEM DE CAIXAS DE PA' from 000,000 To 500,800  PIXEL

	oTimer1 := TTimer():New(02, {|| Proc01() }, oAut) 

	oGrupo1  := tGroup():New(05, 10, 60, 390,'Dados do Produto', oAut,,, .t.)

	oSayCod  := tSay():New(015,020,{|| oCodigo },oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30) 
	oSayDesc := tSay():New(035,020,{|| oDescri },oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30) 

	oSayMens1 := tSay():New(070,020,{|| oMens1},oAut,,oFont2,,,,.T.,,,350,30) 
	oSayMens2 := tSay():New(070,020,{|| oMens2},oAut,,oFont2,,,,.T.,CLR_HRED,CLR_HRED,350,30) 

	oGrupo2  := tGroup():New(100, 10, 130, 390,'Dados da Pesagem', oAut,,, .t.)

	oSayTPB  := tSay():New(110,015,{|| oTitPB },oAut,,oFont2,,,,.T.,,,200,30)  
	oSayPB   := tSay():New(110,100,{|| oPB    },oAut,,oFont3,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)  

	oSayTTa   := tSay():New(110,160,{|| oTitTa },oAut,,oFont2,,,,.T.,,,200,30) 
	oSayTa    := tSay():New(110,200,{|| oTa    },oAut,,oFont3,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)  

	oSayTPL   := tSay():New(110,250,{|| oTitPL },oAut,,oFont2,,,,.T.,,,350,30) 
	oSayPL    := tSay():New(110,325,{|| oPL    },oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30) 

	oSayStat  := tSay():New(230,005,{|| oStatus},oAut,,oFont3,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30) 

	//@ 150,005 To 240,295 Browse "ZA9"  fields aCampos object oBrow 
	@ 150,010 To 220,390 Browse "ZA9" object oBrow

	@ 230,200  BUTTON 'Iniciar'  SIZE 40,15 ACTION Iniciar()  OBJECT oBtn1
	@ 230,245  BUTTON 'Parar'    SIZE 40,15 ACTION Parar()    OBJECT oBtn2
	@ 230,290  BUTTON 'Sair'     SIZE 40,15 ACTION oAut:end() OBJECT oBtn3

	ACTIVATE MSDIALOG oAut CENTERED

	MsClosePort(nHdll) 

	RESET ENVIRONMENT

Return

//função para teste
Static Function contar()
	PUTMV('SI_TESTE',GETMV('SI_TESTE')+1)
return


//Função que dá início aos processos
//ativando os timers 
Static Function Iniciar() 
	oTimer1:Activate()      //Timer do processo de leitura
	oStatus := '[Processo Ativado...]'   
	oSayStat:SetText(oStatus)
	oAut:refresh() 
Return

//Função da pára os processo
//cessando os timers
Static Function Parar() 
	if _lFailCon
		_lFailCon := .f.
	endif	
	oTimer1:DeActivate()   //Timer do processo de leitura 
	oStatus := '[Processo Parado]' 
	oSayStat:SetText(oStatus)
	oAut:refresh() 
	//oTimer2:DeActivate()
return

//Função que vai fazer a pesagem das caixas 
//Utiliza porta COM3
Static Function Captura()  
	local _cString  := ''

	if !MsRead(nHdll,@_cString) 
		//falha 3
		alert('Falha comunicação COM!(3)' ) 
		_lFailCon := .t.
		MsClosePort(nHdll)  
		return _cString
	endif  

return _cString


//Função que realiza o rejeite da caixa
//executando a DLL da relé duas vezes
//com parametros para ligar e logo desligar
Static Function  Rejeite(_par,_m1,_m2)
	if _par = 1
		//modo mecânico
		//	_nHd := ExecInDllOpen('rele.dll')  

		if _nHd = -1  
			//falha 4
			alert('Não abriu a DLL!(4)')
			return
		endif

		cRetDLL := ExecInDLLRun( _nHd,1,'')  
		sleep(1500)
		cRetDLL := ExecInDLLRun( _nHd,2,'')   

		//	ExecInDLLClose(_nHd)
	else
		//modo etiqueta     
		//Manda imprimir uma etiqueta com os motivos do rejeite
		u_GJF111c("S600","COM3:9600,n,8,1",_m1,_m2)

	endif

Return


Static Function Leitura()
	_cNumPrev := ''
	_cPreDes  := ''
	//_cCodPro  := substr(_cString,2,6)
	_cCodPro  := '000833'    //Codigo do produto da pre-etiqueta
	//_cSeqPETQ := substr(_cString,8,13)    //Sequencial da pré-etiqueta
	_cSeqPETQ := '000000'   //Sequencial da pré-etiqueta

	oCodigo   := ''
	oDescri   := ''
	oMens1    := ''
	oMens2    := ''
	_cID      := ''



	oCodigo := _cCodPro

	SB1->(DbSetOrder(1))

	//Verificação se o produto existe
	if !SB1->(DbSeek(xfilial('SB1')+_cCodPro))
		oSayCod:SetText(oCodigo)
		oDescri := ''
		oSayDesc:SetText(oDescri)
		//falha 5         
		_me1 := 'Produto Inexistente(5)'
		_me2 := 'Rejeite acionado'                      
		rejeite(_nRejeite,_me1,_me2)    	
		Mensagens('',_me1,'FA',_me2,5,_cStrBal,_cCodPro)
		_cLimpa := captura() 	
		sleep(_nTime)           

		return .f.  
	endif    

	DbSelectArea('SB1')
	_cSegUM := FBuscaCPO('SB1',1,xfilial('SB1')+alltrim(_cCodPro),'B1_SEGUM') 
	oDescri := FBuscaCPO('SB1',1,xfilial('SB1')+alltrim(_cCodPro),'B1_DESCRED')   

	//2º Verificar se a segunda unidade de medida está OK 
	DbSelectArea('SB1')

	if _cSegUM = 'PC'
		oMens1 := ''   
		oSayCod:SetText(oCodigo) 
		oSayDesc:SetText(oDescri)        

		//Falha 6 
		_me1 := 'Este produto não é embalado em caixas!(6)'
		_me2 := 'Rejeite acionado'                      
		rejeite(_nRejeite,_me1,_me2) 
		Mensagens('',_me1,'FA',_me2,6,_cStrBal,_cCodPro)
		_cLimpa := captura()       
		sleep(_nTime)
		return .f.  
	endif


	//4º Verificar se existe previsão de produção do produto
	_cQuery := " SELECT COUNT(ZU_COD) AS CONTA, ZU_COD AS CODIGO,ZU_NUM AS NUM, ZU_PREDES AS PREDES FROM "+RetSqlName("SZU")+" SZU "
	_cQuery += " WHERE SZU.D_E_L_E_T_ <> '*' "
	_cQuery += "  AND SZU.ZU_COD     = '"  + _cCodPro
	_cQuery += "' AND SZU.ZU_DTRPRO  = '"  + DTOS(date())
	_cQuery += "' AND SZU.ZU_FECHADO = 'N' "
	_cQuery += "  AND SZU.ZU_FECHADO <> 'B' "
	_cQuery += "  AND (SZU.ZU_TIPO = 'P' OR (SZU.ZU_TIPO = 'R' AND SZU.ZU_REPAUT = 'S') )"
	_cQuery += "  AND SZU.ZU_FILIAL = '"  + xfilial("SZU") + "'"
	_cQuery += "  GROUP BY ZU_COD, ZU_NUM,ZU_PREDES"

	_cQuery := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("VER")<>0
		VER->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "VER"
	if VER->CONTA = 0
		oSayCod:SetText(oCodigo)
		oSayDesc:SetText(oDescri)
		//Falha 7
		_me1 := 'Produção inexistente para esse produto!(7)'
		_me2 :=	'Rejeite acionado'                     
		rejeite(_nRejeite,_me1,_me2)  
		Mensagens('',_me1,'FA',_me2,7,_cStrBal,_cCodPro)
		/* */
		//		if !(chr(03) $ _cString) .or. !(chr(02) $ _cString)
		_cLimpa := captura()       
		//		endif

		sleep(_nTime)

		return .f.


		_cPreEmb := VER->NUM
		_cPreDes := VER->PREDES

		VER->(dbclosearea())	
	endif

	//5º Coletar os dados necessários do produto para registro de produção 

	if !empty(oCodigo) 
		oSayCod:SetText(oCodigo)
		oSayDesc:SetText(oDescri)  
		oMens1 := ''          
		oSayMens1:SetText(oMens1)
		oMens2 := '' 
		oSayMens2:SetText(oMens2)
		oAut:refresh()   
	endif

return .t. 

//Função destinada a executar o processo nº 01
//Captura do codigo, pesagem, atualização da previsão e
//registro de produção

Static Function Proc01()

	_cString := ''

	//Limpeza das variáveis principais
	_cCodPro  := ''
	_cControl := ''
	_nQuant   := 0
	_nPMPec   := 0.00
	_nPeso    := 0.00
	_nPesoL   := 0.00
	_nTara    := 0.00
	_cPreEmb  := ''
	_cPreDes  := ''
	_cStrBal  := ''
	_cSeqPETQ := ''
	_lProduz  := .t.  
	_cFim     := ''


	//Verifica validação da leitura do codigo
	leitura()


	_nPeso := 20 

	//Verificação se o ultimo caractere verificador
	//da string existe  


	//Se peso zerado exclui a leitura do codigo
	//do produto invalidando a pesagem
	if _nPeso <= 0
		//Falha 8
		_me1 := 'Peso Inexistente!(8)'
		_me2 := 'Rejeite acionado'                      
		rejeite(_nRejeite,_me1,_me2)
		Mensagens('',_me1,'FA',_me2,8,_cStrBal,_cCodPro)
		_cLimpa := captura()  
		sleep(_nTime)     
		return .f.
	else

		DbSelectArea('SB1')
		SB1->(DbSetOrder(1))
		if !SB1->(DbSeek(xfilial('SB1')+_cCodPro))
			//Se entrou nessa condição é porque houve falha
			//então o rejeite deve ser acionado pois a caixa
			//já passou
			//Falha 9
			_me1 := 'Falha na Pesagem!(9)'
			_me2 := 'Rejeite acionado'                      
			rejeite(_nRejeite,_me1,_me2) 
			Mensagens('',_me1,'FA',_me2,9,_cStrBal,_cCodPro)
			sleep(_nTime)

			return .f.
		endif

		DbSelectArea('SB1')

		_nQuant := SB1->B1_QCAIX                                                                                
		_nPMPec := FBuscaCPO('SB1',1,xfilial('SB1')+SB1->B1_COD,'B1_PMPEC')       //Busca o peso médio por peças
		_nTaraS := FBuscaCPO('SB1',1,xfilial('SB1')+SB1->B1_COD,'B1_CTARASE')     //Linhas inseridas para buscar
		_nTS    := fBuscaCPO('ZAB',1,xfilial('ZAB')+alltrim(_nTaraS),'ZAB_TARA')  // os campos de codigo das taras secundaria 

		//_nTS    := SB1->B1_TARAS   Linha substituida pelas 2 de cimaque trasforman a tara para codigo
		_nTaraP := FBuscaCPO('SB1',1,xfilial('SB1')+SB1->B1_COD,'B1_CTARAP')      // Linhas inseridas para buscar"_NTARAp"
		_nTP    := FBuscaCPO('ZAB',1,xfilial('ZAB')+alltrim(_nTaraP),'ZAB_TARA')  // os campos de codigo das taras primarias
		//_nTP    := SB1->B1_TARAP   Linha substituida pelas 2 de cima que trasforman a tara para codigo
		_nTara  := _nTS + (_nTP * _nQuant)
		_nPesoL := _nPeso - _nTara

		//Linha para determinar a quantidade de peças por caixa conforme o peso médio de peças
		//Se o campo B1_PMPEC (Cadastro de produtos - pasta Silva) estiver preenchido, faz o calculo
		_nQuant := iif(_nPMPec <> 0.00,round(_nPesoL/_nPMPec,0),_nQuant) 			

		if _nPesoL <= 0
			_me1 := 'Peso Inconsistente por tara!(14)'
			_me2 := 'Rejeite acionado'                       
			rejeite(_nRejeite,_me1,_me2) 
			Mensagens('',_me1,'FA',_me2,14,_cStrBal,_cCodPro)
			sleep(_nTime)
			return .f.
		endif

		//Bloco para validar o peso capturado com a tara da embalagem
		do case
			//Caixa pequena
			case (_nTS >= 0.400 .and. _nTS <= 0.520)
			if !(_nPesoL >= 5 .and. _nPesoL <= 18)
				//Falha 10
				_me1 := 'Peso Inconsistente por tara!(10)'
				_me2 := 'Rejeite acionado'                       
				rejeite(_nRejeite,_me1,_me2) 
				Mensagens('',_me1,'FA',_me2,10,_cStrBal,_cCodPro)
				sleep(_nTime)
				return .f.
			endif
			//Caixa grande
			case (_nTS >= 0.800 .and. _nTS <= 1.040)
			if !(_nPesoL >= 10 .and. _nPesoL <= 31)
				//Falha 11
				_me1 := 'Peso Inconsistente por tara!(11)'
				_me2 := 'Rejeite acionado'                       
				rejeite(_nRejeite,_me1,_me2) 
				Mensagens('',_me1,'FA',_me2,11,_cStrBal,_cCodPro)
				sleep(_nTime)
				return .f.
			endif
			//Caixa plástica
			case (_nTS >= 2.100 .and. _nTS <= 2.355)
			if !(_nPesoL >= 2 .and. _nPesoL <= 40)
				//Falha 12
				_me1 := 'Peso Inconsistente por tara!(12)'
				_me2 := 'Rejeite acionado'                       
				rejeite(_nRejeite,_me1,_me2)
				Mensagens('',_me1,'FA',_me2,12,_cStrBal,_cCodPro)
				sleep(_nTime)
				return .f.
			endif
			//Caso não haja nenhuma situação prevista de tara
			otherwise
			_me1 := 'Tara desconhecida!(13)'
			_me2 := 'Rejeite acionado'		  
			rejeite(_nRejeite,_me1,_me2)
			Mensagens('',_me1,'FA',_me2,13,_cStrBal,_cCodPro)
			sleep(_nTime) 
			return .f.
		endcase
		//Fim do bloco de validação do peso pela tara das embalagem

		oPB := transform(_nPeso,'@E 999.99')
		oTa := transform(_nTara,'@E 999.99')
		oPL := transform(_nPesoL,'@E 999.99')

		oSayPB:SetText(oPB)
		oSayTa:SetText(oTa)
		oSayPL:SetText(oPL)
	endif

	Previsao()     //Função que verifica e atualiza a Previsão de Produção

	Registro()     //Função que realiza o registro da pesagem

	//MsClosePort(nHdll)

	Etiqueta()     //função que realiza a impressão da etiqueta

	RegEven('Registro efetivado','OK','Etiqueta enviada',0,_cStrBal,_cCodPro)
	//MSOpenPort(nHdll,mv_par01)

	ZA9->(DbGotop())

	oAut:refresh()


	sleep(_nTime)
return .t.



//Faz a verificação de previsão
static function previsao()

	SZU->(DbSetOrder(2))
	if !SZU->(DbSeek(xfilial('SZU')+_cPreEmb))
		//	Falha 13 
		_me1 := 'Produção inexistente para esse produto!(14)'
		_me2 := 'Rejeite acionado'                         
		rejeite(_nRejeite,_me1,_me2)     
		Mensagens('',_me1,'FA',_me2,13,_cStrBal,_cCodPro)  
		sleep(_nTime)
		return .f.
	endif                    

	_cCExat   := SZU->ZU_CONTEXA
	qPrevC    := SZU->ZU_QPCAIX
	qRealC    := SZU->ZU_QRCAIX 
	qPrevP    := SZU->ZU_QPPESO
	qRealP    := SZU->ZU_QRPESO
	qPrevQ    := SZU->ZU_QPQUANT 
	qRealQ    := SZU->ZU_QRQUANT

	overflow  := .f.
	overflow2 := .f.

	//Implementado campo ZU_TOLERA para tolerancias, onde o valor default é 10%. Caso não queira tolerancia 
	//o PCP deverá zerar o campo na Previsão de Produção
	do case
		case SZU->ZU_PRIORI = "C"                
		if SZU->(ZU_QPCAIX + round(ZU_QPCAIX *(ZU_TOLERA/100),0)) <= qRealC + 1    
			if _cCExat = 'S'                      //Variavel que determina se o cumprimento da previsão deve ser exato ou não
				overflow := .t.                    //se a previsão foi cumprida, então o overflow determina o seu encerramento  
			endif
		endif
		case SZU->ZU_PRIORI = "P"
		if SZU->(ZU_QPPESO + ZU_QPPESO * (ZU_TOLERA/100))  <= qRealP + _nPesoL
			if _cCExat = 'S'                      //Variavel que determina se o cumprimento da previsão deve ser exato ou não
				overflow := .t.                    //se a previsão foi cumprida, então o overflow determina o seu encerramento  
			endif
		endif
		case SZU->ZU_PRIORI = "A"
		if (SZU->(ZU_QPPESO + ZU_QPPESO * (ZU_TOLERA/100)) <= qRealP + _nPesoL) .or. ;
		(SZU->(ZU_QPCAIX + ZU_QPCAIX * round((ZU_TOLERA/100),0)) <= qRealC + 1)
			if _cCExat = 'S'                      //Variavel que determina se o cumprimento da previsão deve ser exato ou não
				overflow := .t.                    //se a previsão foi cumprida, então o overflow determina o seu encerramento  
			endif
		endif              
		case SZU->ZU_PRIORI = "E"                //se a previsão for por peças. Não há tolerancia para peças
		if (qRealQ + _nQuant) > qPrevQ
			Mensagens('','Produção encerrada antecipadamente!','OK','Programação PCP',0,_cStrBal,_cCodPro)  
			if _cCExat = 'S'                      //Variavel que determina se o cumprimento da previsão deve ser exato ou não
				overflow := .t.                    //se a previsão foi cumprida, então o overflow determina o seu encerramento  
			endif
			overflow2 := .t.
		endif
	endcase

	reclock('SZU',.f.)

	if !overflow2  
		SZU->ZU_QRCAIX  := qRealC + 1
		SZU->ZU_QRPESO  := qRealP + _nPesoL
		SZU->ZU_QRQUANT := qRealQ + _nQuant
	endif     

	if overflow .or. overflow2
		SZU->ZU_FECHADO := 'S'
	endif

	MsUnLock()

	/*
	if overflow
	Mensagens('','Previsão de Produção totalmente atendida!','OK','Programação PCP',0)  
	endif
	*/
	ret := iif(overflow2,.f.,.t.)

return  ret


//Função realiza o registro da produção
//na tabela SZ8 e demais tabelas
Static Function Registro()
	Local _cNumBal
	Local _nDiasVal      
	Local _cDesc 
	Local _cClassif


	//Setar a previsão de produção
	SZU->(DbSetOrder(2))
	if !SZU->(DbSeek(xfilial('SZU')+_cPreEmb))
		return .f.
	endif

	//Setar o cadastro do produto
	DbSelectArea('SB1')    
	SB1->(DbSetOrder(1))
	if !SB1->(DbSeek(xfilial('SB1')+_cCodPro))
		return .f.
	endif

	_nDiasVal  := SB1->B1_VALID
	_cDesc     := SB1->B1_DESCRED  
	_cClassif  := fBuscaCPO('SZ2',2,xfilial('SZ2')+_cPreDes,'Z2_CLASSIF')

	_cID :=  GetSx8num('SZ8','Z8_ID')
	ConfirmSx8()

	_cControl := '00' + _cID

	reclock('SZ8',.t.)
	SZ8->Z8_FILORI    := cFilAnt
	SZ8->Z8_FIL       := cFilAnt
	SZ8->Z8_FILIAL    := xfilial('SZ8')
	SZ8->Z8_ID        := _cID
	SZ8->Z8_CONTROL   := _cControl
	SZ8->Z8_CODORI    := _cCodPro
	SZ8->Z8_COD       := _cCodPro
	SZ8->Z8_DATA      := date()
	SZ8->Z8_DATAP     := SZU->ZU_DTPROD
	SZ8->Z8_HORA      := time()
	SZ8->Z8_TIPO      := SZU->ZU_TIPO
	SZ8->Z8_TF        := SZU->ZU_TF
	SZ8->Z8_QUANT     := _nQuant
	SZ8->Z8_PESO      := _nPesoL
	SZ8->Z8_TARA      := _nTara
	SZ8->Z8_PESOBR    := _nPeso
	SZ8->Z8_ETIQ      := SZU->ZU_ETIQ
	SZ8->Z8_DATAVAL   := SZU->ZU_DTPROD + _nDiasVal
	SZ8->Z8_BALAN     := getComputerName()
	SZ8->Z8_DESCRI    := _cDesc
	SZ8->Z8_OPERA     := cUserName
	SZ8->Z8_NUMPREV   := _cPreEmb
	SZ8->Z8_PREDES    := _cPreDes 
	SZ8->Z8_MDESP     := 'N'
	SZ8->Z8_CLASSIF   := _cClassif   
	SZ8->Z8_SEQPETQ   := _cSeqPETQ 
	SZ8->Z8_DTENTES   := date()  
	SZ8->Z8_LOTE      := SZU->ZU_LOTE
	msunlock()            

	//grava o histórico da caixa
	u_gjf17his(1,'PRODUCAO',.f.,'','','000012')  

	//Ajusta estoque atual
	u_gjf17EST(SZ8->Z8_COD,1,SZ8->Z8_PESO,cFilAnt)             

return .t.

Static Function Etiqueta()

	Local _cModo := GetMV('SI_MIMPEMB')

	SZ8->(DbSetOrder(3))
	if SZ8->(DbSeek(xfilial('SZ8')+_cControl))  
		if _cModo = '1'   //Modo Automação
			u_GJF111b("S600","COM3:19200,n,8,1",SZ8->Z8_CONTROL,SZ8->Z8_COD,SZ8->Z8_QUANT,SZ8->Z8_PESOBR,SZ8->Z8_PESO,;  
			SZ8->Z8_TARA,SZ8->Z8_PREDES,SZ8->Z8_CLASSIF,SZ8->Z8_TF,SZ8->Z8_DATAP,SZ8->Z8_ETIQ,SZ8->Z8_DATAVAL,1,SZ8->Z8_LOTE) 
		elseif _cModo = '2' //Modo manual
			u_GJF111a("S600","COM3:9600,n,8,1",SZ8->Z8_CONTROL,SZ8->Z8_COD,SZ8->Z8_QUANT,SZ8->Z8_PESOBR,SZ8->Z8_PESO,;  
			SZ8->Z8_TARA,SZ8->Z8_PREDES,SZ8->Z8_CLASSIF,SZ8->Z8_TF,SZ8->Z8_DATAP,SZ8->Z8_ETIQ,SZ8->Z8_DATAVAL,1) 
		endif 		      
	endif
return .t.         

//Função destinada a gravar os eventos da automação
Static Function RegEven(_desc,_status,_resp,_cod,_string,_prod) 

	Local _nID := ZA9->(RecCount()) + 1        

	ZA9->(DbSetOrder(1))

	reclock('ZA9',.t.)
	ZA9->ZA9_FILIAL := xfilial('ZA9')
	ZA9->ZA9_ID     := _nID
	ZA9->ZA9_DESC   := _desc
	ZA9->ZA9_DATA   := date()
	ZA9->ZA9_HORA   := time()
	ZA9->ZA9_STATUS := _status 
	ZA9->ZA9_COD    := _cod
	ZA9->ZA9_RESP   := _resp 
	ZA9->ZA9_STRING := _String 
	ZA9->ZA9_PROD   := _prod
	msunlock()  

	oBrow:oBrowse:refresh()
	oAut:refresh()  
return     

//Função destinada a apagar os exentos da automação
Static Function ExcEven()
	ZA9->(DbSetOrder(1))
	ZA9->(DbGoTop())
	While ZA9->(!eof())
		reclock('ZA9',.f.)
		dbdelete()
		msunlock()
		ZA9->(DbSkip())
	enddo 
	oBrow:oBrowse:refresh()
	oAut:refresh()  

return  


//Função para racionalizar as mensagens de tela
Static Function Mensagens(_mens1,_mens2,_even1,_even2,_cod,_String,_Prod)
	oMens1 := _mens1          
	oSayMens1:SetText(oMens1)
	oMens2 := _mens2 
	oSayMens2:SetText(oMens2)
	oAut:refresh() 
	RegEven(oMens2,_even1,_even2,_cod,_String,_Prod)
return
