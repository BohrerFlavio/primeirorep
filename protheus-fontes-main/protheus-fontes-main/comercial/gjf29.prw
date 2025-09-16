#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF29     ºAutor  ³Giuliano Forgiarini º Data ³  26/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Liberação de pré-carregamentos                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaoms - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF29()

	lOk := .f.
	aObjects := {}                                             //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()
	AAdd( aObjects, {100, 100, .T., .T. } )
	AAdd( aObjects, {100, 50, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	bLegenda1 :=  "ZZ3->ZZ3_STATUS == 'A'"
	bLegenda2 :=  "ZZ3->ZZ3_STATUS == 'C'"
	bLegenda3 :=  "ZZ3->ZZ3_STATUS == 'B'"
	bLegenda4 :=  "ZZ3->ZZ3_STATUS == 'E'"
	bLegenda5 :=  "ZZ3->ZZ3_STATUS == 'S'" 
	bLegenda6 :=  "ZZ3->ZZ3_STATUS == 'F'" 

	aCores2:= { { 'BR_VERDE'   ,'Aberto'    },;
	{ 'BR_AMARELO' ,'Carregando'},;
	{ 'BR_AZUL'    ,'Bloqueado' },;
	{ 'BR_VERMELHO','Encerrado' },;
	{ 'BR_LARANJA' ,'Em Espera' },;
	{ 'BR_PRETO'   ,'Faturado'} }

	aCores := { {bLegenda1,'BR_VERDE'   },;
	{bLegenda2,'BR_AMARELO' },;
	{bLegenda3,'BR_AZUL'    },;
	{bLegenda4,'BR_VERMELHO'},;
	{bLegenda5,'BR_LARANJA' },;
	{bLegenda6,'BR_PRETO'}  }

	Private cPerg   := "GJF29"
	Private cCadastro := "Liberação de Pré-Carregamentos"
	Private aRotina := { {"Visualizar","AxVisual",0,2} ,;   
	{"Alt.Data","u_gjf29Dt",0,2} ,;
	{"Liberar","u_gjf29lib",0,2} ,;
	{"Bloquear","u_gjf29blo",0,2} ,;
	{"Legenda","u_gjf29leg",0,2}}

	if !pergunte(cPerg,.t.) 
		return
	endif

	Private cString := "ZZ3"
	dbSelectArea(cString)
	ZZ3->(dbSetOrder(1))
	ZZ3->(dbgobottom()) 

	aIndZZ3   := {}						                                    //Indice para a filtragem
	cCondicao := ''

	do case
		case mv_par03 == 1
		cCondicao:=  "ZZ3->ZZ3_DTCAR >= mv_par01 .and. ZZ3->ZZ3_DTCAR <= mv_par02 "+;
		".and. ZZ3->ZZ3_STATUS != 'E' .and. ZZ3->ZZ3_STATUS != 'C' .and. ZZ3->ZZ3_STATUS != 'F' .and. ZZ3->ZZ3_FILIAL = XFILIAL('ZZ3')"
		case mv_par03 == 2
		cCondicao:=  "ZZ3->ZZ3_DTCAR >= mv_par01 .and. ZZ3->ZZ3_DTCAR <= mv_par02 .and. ZZ3->ZZ3_STATUS == 'B'"+;
		" .and. ZZ3->ZZ3_STATUS != 'E' .and. ZZ3->ZZ3_STATUS != 'C' .and. ZZ3->ZZ3_STATUS != 'F' .and. ZZ3->ZZ3_FILIAL = XFILIAL('ZZ3')"
		case mv_par03 == 3
		cCondicao:=  "ZZ3->ZZ3_DTCAR >= mv_par01 .and. ZZ3->ZZ3_DTCAR <= mv_par02 .and. ZZ3->ZZ3_STATUS == 'L'"+;
		" .and. ZZ3->ZZ3_STATUS != 'E' .and. ZZ3->ZZ3_STATUS != 'C' .and. ZZ3->ZZ3_STATUS != 'F' .and. ZZ3->ZZ3_FILIAL = XFILIAL('ZZ3')"
	end case 

	FilBrowse("ZZ3",@aIndZZ3,@cCondicao)                                        //Aplicação da filtragem	
	mBrowse(6,1,22,75,cString, ,,,,3     ,aCores,,,,{|x| AutoRefresh(x)}) 
	//      LIN INI,COL INI,LIN FIN,COL FIN,ALIAS  , ,,,,funcao,cores

	If  Len(aIndZZ3)>0
		EndFilBrw("ZZ3",@aIndZZ3)                                               //Encerra o filtro e refaz os índices padrões
	endif     

	DbCloseArea('ZZ3')   

return	 

//LIBERAÇÃO DE PRE-CARREGAMENTOS
user function gjf29lib()
	lOk := .f.
	if ZZ3->ZZ3_STATUS != 'B' 
		msgbox('Status não permite liberação do Pré-Carregamento!','LIBERAÇÃO','STOP')
		return
	endiF

	DEFINE MSDIALOG oDlg TITLE 'Liberação de Pré-Carregamento' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("ZZ3",.f.)

	obj := MsMGet():New("ZZ3" ,ZZ3->(RECNO()),3   ,     ,     ,     ,          ,aPosObj[1],              ,,,,,oDlg,,,.F. )

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||u_gjf29lOk(),oDlg:end()},{||ODlg:end()})

return

//BLOQUEIO DE PRE-CARREGAMENTOS
user function gjf29blo()

	if ZZ3->ZZ3_STATUS != 'A' .and. ZZ3->ZZ3_STATUS != 'S'
		msgbox('Status não permite bloqueio do Pré-Carregamento!','BLOQUEIO','STOP')
		return
	endiF

	DEFINE MSDIALOG oDlg TITLE 'Bloqueio de Pré-Carregamento' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("ZZ3",.f.)

	obj := MsMGet():New("ZZ3" ,ZZ3->(RECNO()),3   ,     ,     ,     ,          ,aPosObj[1],              ,,,,,oDlg,,,.F. )

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||u_gjf29bOk(),ODlg:end()},{||ODlg:end()})

return

//Função que confirma o bloqueio do pre-carregamento	
User Function gjf29lOk()

	stt := 'A'
	ZZ4->(dbsetorder(1))
	if ZZ4->(dbseek(xfilial('ZZ4') + ZZ3->ZZ3_NUM))
		while ZZ4->(!eof()) .and. ZZ4->ZZ4_FILIAL = xfilial('ZZ4') .and. ZZ4->ZZ4_PRECAR == ZZ3->ZZ3_NUM
			ZZ5->(dbseek(xfilial('ZZ5') + ZZ4->ZZ4_NUM))
			while ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = xfilial('ZZ5') .and. ZZ5->ZZ5_NUM == ZZ4->ZZ4_NUM
				if !empty(ZZ5->ZZ5_QRCAIX) .or. !empty(ZZ5->ZZ5_QRPESO)
					stt := 'S'
					exit
				else
					stt := 'A'
				endif
				ZZ5->(dbskip())
			enddo
			ZZ4->(dbskip())
		enddo
	else
		msgbox('Pre-Carregamento não possui Pre-Pedidos vinculados!','LIBERAÇÃO','STOP')
		return .f.
	endif

	//Para verificar se houve pesagem do caminhão antes de carregar!
	_lPesar := GetMv("MV_PESVEIC")
	_lDiv   := .f.

	if _lPesar
		if ZZ3->ZZ3_PESAR = 'S'
			_nFaixaIni := 0
			_nFaixaFim := 0

			datapes := ''
			stpes   := .f.

			if ZZ3->ZZ3_PESAR = 'S'
				SZT->(dbsetorder(1))

				if SZT->(dbseek(xfilial('SZT')+ZZ3->ZZ3_PLACA))
					while SZT->(!eof()) .and. SZT->ZT_FILIAL = xfilial('SZT') .and. SZT->ZT_PLACA == ZZ3->ZZ3_PLACA
						if SZT->ZT_STATUS == 'PA'

							DA3->(DbSetOrder(3))
							if DA3->(DbSeek(xfilial('DA3')+ZZ3->ZZ3_PLACA))

								if DA3->DA3_TARA = 0.00  .and. DA3->DA3_FROVEI = '1'
									msgbox('Tara do veículo não cadastrada!','DADOS DO VEICULO INSUFICIENTES','STOP')
									return .f.
								endif

								if DA3->DA3_FROVEI = '1'
									if (SZT->ZT_PESOE > (DA3->DA3_TARA + 40)) .or. (SZT->ZT_PESOE < (DA3->DA3_TARA - 40))
										msgbox('Diferença de peso excede 20kg!','LIBERAÇÃO NAO AUTORIZADA','STOP')
										return .f.
									endif                   
								endif
								/*
								if DA3->DA3_TARA = 0.00
								msgbox('Tara do veículo não cadastrada!','DADOS DO VEICULO INSUFICIENTES','STOP')
								return .f.
								endif

								if (SZT->ZT_PESOE > (DA3->DA3_TARA + 30)) .or. (SZT->ZT_PESOE < (DA3->DA3_TARA - 30))
								msgbox('Será feita a liberação mas com registro em histórico!','FORA DA FAIXA DE PESO INICIAL TOLERADA','ERRO')
								u_gjf31his('Fora da faixa de tara do veículo')
								if !_lDiv
								u_gjf29wfw(ZZ3->ZZ3_NUM,SZT->ZT_PESOE,DA3->DA3_TARA)
								_lDiv := .t.
								endif	
								endif
								*/
							else
								msgbox('Cadastro do veículo não encontrado!','AVISO DE INCONSISTENCIA','INFO')
							endif

							if msgbox('Confirma Liberação de Carregamento com pesagem inicial de ' + transform(SZT->ZT_PESOE,'@E 999,999.99')+' ?',;
							'CONFIRMA LIBERAÇÃO?','YESNO')

								datapes := SZT->ZT_DATAE
								stpes := .t.
							else
								return
							endif
						endif
						SZT->(dbskip())
					enddo
					if stpes
						if datapes != ddatabase
							msgbox('Pesagem não confere com a data de carga! ','CONFERIR PESAGEM','STOP')
							return .f.
						endif
					else
						msgbox('Primeira pesagem do caminhão não encontrada!','ATENÇÃO','STOP')
						return .f.
					endif
				else
					msgbox('Primeira pesagem do caminhão não encontrada!','ATENÇÃO','STOP')
					return .f.
				endif
			endif
		endif
	endif

	reclock('ZZ3',.f.)
	ZZ3->ZZ3_STATUS	 := stt
	ZZ3->ZZ3_USULIB   := cUserName
	ZZ3->ZZ3_DATLIB   := date()
	ZZ3->ZZ3_HORLIB   := time()
	msunlock()   


return .t.

//Função que confirma o bloqueio do pre-carregamento para carga
User function gjf29bOk()

	ZZ4->(dbsetorder(1))
	if ZZ4->(dbseek(xfilial()+ZZ4->ZZ4_PRECAR))
		stt := 'B'
	endif
	reclock('ZZ3',.f.)
	ZZ3->ZZ3_STATUS := stt
	msunlock()
	ODlg:end()
return .t.

user Function gjf29leg()
	BrwLegenda('Pre-Carregamentos',"Legenda",aCores2)
return

////Funções para atualização do mBrowse////
Static Function AutoRefresh(oDlg)
	Local oTimer
	oTimer := TTimer():New(2, {|| PBrow() }, oDlg)  
	oTimer:Activate()
Return .T.

////Funções para atualização do mBrowse////
Static Function PBrow()
	oBrowse := getObjBrow() 
	oBrowse:default() 
	oBrowse:refresh()
Return  

//Função para worflow
User Function gjf29wfw(_Precar,_Peso,_Tara) 

	local _area    := getarea()
	local _data    := ''
	local _hora    := ''
	local _usuario := '' 
	local _placa   := '' 
	local _obs     := ''
	local i
	
	ZZ3->(DbSetOrder(2))
	ZZ3->(DbSeek(xfilial('ZZ3')+_Precar))
	_placa   := ZZ3->ZZ3_PLACA
	_data    := dtoc(date())  
	_usuario := alltrim(ZZ3->ZZ3_USULIB)
	_hora    := time()  
	_Obs     := ZZ3->ZZ3_OBS

	_cMens := 'Esta é uma mensagem automática do sistema. Por favor não responda!' + chr(13) + chr(10) 
	_cMens += 'Na data e hora da emissão deste email, o pre-carregamento abaixo foi liberado com divergencia de peso inicial:' + chr(13) + chr(10) 
	_cMens +=   chr(13) + chr(10) 
	_cMens += 'Pre-Carregamento: ' + _PreCar + ' (' + _placa + ') ' + alltrim(_obs) + chr(13) + chr(10) 
	_cMens += 'Data Liberação: ' + _data + chr(13) + chr(10) 
	_cMens += 'Hora Liberação: ' + _hora + chr(13) + chr(10) 
	_cMens += 'Responsável Liberação: ' + _usuario + chr(13) + chr(10)   
	_cMens += 'Tara nominal: ' + transform(_Tara,'@E 999,999,999.99') + chr(13) + chr(10) 
	_cMens += 'Peso acusado: ' + transform(_Peso,'@E 999,999,999.99') + chr(13) + chr(10)    
	_cTit  := 'Workflow Frigorífico Silva: Aviso do pre-carregamento ' + alltrim(_Precar) +  ' liberado com divergência'
	_cDest := 'financeiro@frigorificosilva.com.br,'
	//_cDest  += 'faturamento@frigorificosilva.com.br,faturamento2@frigorificosilva.com.br' Alterado para os novos integrantes do Faturamento - feito por Flávio dia 28/08/2017
	_cDest := 'andrea.almeida@frigorificosilva.com.br,julio.labrea@frigorificosilva.com.br,fabio.bastos@frigorificosilva.com.br'
	_aEmail := u_GJF54(_cMens,_cTit,_cDest)

	for i := 1 to len(_aEmail)
		if !_aEmail[i]
			alert('ERRO WORKFLOW ('+ str(i) +')')
		endif
	next

	restarea(_area)	  
return


User Function gjf29Dt()

	Local _dDtProd := ZZ3->ZZ3_DTCAR

	DEFINE MSDIALOG oDlg2 TITLE 'Alterar Data Carreg.' from 000,000 To 150,250 OF oMainWnd PIXEL  
	@ 009,002 SAY  'Data de Cadastro: ' Object oSay1
	@ 009,065 SAY   dtoc(ZZ3->ZZ3_DATA) Object oSay2
	@ 021,002 SAY  'Data Carregamento:' Object oSay3
	@ 021,065 GET _dDtProd  SIZE 50,10 PICTURE "99/99/99"  VALID !empty(_dDtProd) Object oData1

	@ 055,090 BMPBUTTON TYPE 1 ACTION odlg2:end() Object Obtn2
	ACTIVATE MSDIALOG oDlg2   

	reclock('ZZ3',.f.)
	ZZ3->ZZ3_DTCAR := iif(empty(_dDtProd),ZZ3->ZZ3_DTCAR,_dDtProd)
	msunlock()
	return .t.   

return
