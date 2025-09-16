#INCLUDE "rwmake.ch"
#INCLUDE 'protheus.ch'
#INCLUDE 'dbtree.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "Topconn.ch"
#INCLUDE "tbiconn.ch"

Static oTmpTable
Static oTmp2Table
Static oTmp3Table

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF144    º Autor ³ Giuliano Forgiariniº Data ³  08/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Controle de entrada e saída de PA das câmaras com definiçãoº±±
±±º          ³ da localização física destes                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Camaras/PCP                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF144()

	Private cPerg1 := "GJF144"

	if !Pergunte(cPerg1,.t.)
		return
	endif

	Processa({||Montagem() },"LOCALIZAÇÃO FÍSICA","Realizando montagem da árvore...")

return

Static Function Montagem()
	Local _cLocal    := mv_par01
	Local _cTipoPal  := ''
	Local _nIDLocal  := 0
	Local _cRua      := ''
	Local _nIDRua    := 0
	Local _cPredio   := ''
	Local _nIDPredio := 0
	Local _cAndar    := ''
	Local _nIDAndar  := 0
	Local _cApto     := ''
	Local _nIDApto   := 0
	Local _cIDLocal  := ''
	Local _nCont     := 0

	Private _cTipo     := iif(mv_par02 = 1,'PA','MP')
	Private _DispLoc   := mv_par01
	Private _DispRua   := ''
	Private _DispPre   := ''
	Private _DispAnd   := ''
	Private _DispApt   := ''
	Private _DispEnd   := ''
	Private _Control   := space(11)
	Private _nCaix	   := 0
	Private _aOpcoes   := {"Entrada/Remanejo","Saída"}
	Private _nModo     := 1
	Private _aOpSeq	   := {"Padrão","Bizerba"}
	Private _nModSeq   := 1
	Private _aApto     := {}
	Private _aAndar    := {}
	Private _Mens1     := ''
	Private _Mens2     := ''
	Private aCampos    := {}
	Private aCampos2   := {}
	Private cArq
	Private cArq2
	Private cArq3
	Private aStru      := {}
	Private aStru2     := {}
	Private _nMaxApto  := 0
	Private oDlg       := nil
	Private oTree      := nil
	Private _cGrpPorc  := alltrim(GetMV('MV_GRPPORC'))
	Private cUserID	   := alltrim(RetCodUsr())

	ZZH->(DbSetOrder(1))
	ZZH->(DbGoTop())
	if !ZZH->(MsSeek(FWxfilial('ZZH')+mv_par01))
		return
	endif

	_nCont := Contagem("ZZH", " ZZH_LOCAL = '" + mv_par01  +"'")
	//_nCont := Contar("ZZH","ZZH->ZZH_FILIAL = FWxfilial('ZZH') .and. ZZH_LOCAL = mv_par01 ")

	ProcRegua(_nCont)

	ZZH->(DbGoTop())
	if !ZZH->(MsSeek(FWxfilial('ZZH')+mv_par01))
		return
	endif

	_cIDLocal := 'C' + ZZH->ZZH_LOCAL
	_cRef     := 'A' //Referencial para os andares

	Montabrow()

	_nMaxApto := u_gjf144NL(mv_par01)

	DEFINE DIALOG oDlg TITLE "Controle de Localização Física de "+_cTipo FROM 180,180 TO 800,1000 PIXEL

	//Cria a Tree
	oTree := DbTree():New(0,0,300,130,oDlg,{|| apontar()},,.T.)
	oTree:BeginUpdate()
	//Adiciona primeiro nivel a Tree
	oTree:AddItem("Camara " + ZZH->ZZH_LOCAL,_cIDLocal, "FOLDER5" ,,,,1)
	oTree:ChangeBmp("BMPTABLE","BMPTABLE",,,_cIDLocal)

	ZZH->(DbGoTop())
	ZZH->(DBSetOrder(1))
	ZZH->(MsSeek(FWxfilial('ZZH')+mv_par01))
	While ZZH->(!eof()) .and. ZZH->ZZH_FILIAL = FWxfilial('ZZH') .and. ZZH->ZZH_LOCAL = mv_par01

		incProc()

		if _cRua <> ZZH->ZZH_RUA
			If oTree:TreeSeek(_cIDLocal)
				_nIDRua++
				_cIDRua := 'R'+strzero(_nIDRua,2)       //Identificador unico do elemento da Tree (galho)
				oTree:AddItem("Rua " + ZZH->ZZH_RUA,_cIDRua, "FOLDER6" ,,,,2)
				_cRua := ZZH->ZZH_RUA
			endif
		endif

		if _cPredio <> ZZH->ZZH_PREDIO
			If oTree:TreeSeek(_cIDRua)
				_nIDPredio++
				_cIDPredio := 'P'+strzero(_nIDPredio,2) //Identificador unico do elemento da Tree (galho)
				oTree:AddItem("Predio " + ZZH->ZZH_PREDIO,_cIDPredio, "FOLDER7" ,,,,2)
				_cPredio := ZZH->ZZH_Predio
			endif
		endif

		if _cAndar <> ZZH->ZZH_ANDAR
			_cFolder := "FOLDER10"
			_cPatch  := ZZH->(ZZH_LOCAL+ZZH_RUA+ZZH_PREDIO+ZZH_ANDAR)
			_NumPal  := 0

			SZP->(DbSetOrder(2))
			if SZP->(MsSeek(FWxfilial('SZP') + _cPatch))

				_NumPal := contagem("SZP","ZP_LOCALIZ = '" + alltrim(_cPatch) + "'" )
				//_NumPal := contar("SZP","SZP->ZP_FILIAL = FWxfilial('SZP') .and. SZP->ZP_LOCALIZ = '" + alltrim(_cPatch) + "'")
				if _NumPal >= _nMaxApto
					_cFolder := "FOLDER14"
				else
					_cFolder := "FOLDER10"
				endif
			endif

			If oTree:TreeSeek(_cIDPredio)
				_nIDAndar++

				if _nIDAndar = 100 .and. _cRef = 'A'
					_nIDAndar := 1
					_cRef := 'N'
				elseif _nIDAndar = 100 .and. _cRef = 'N'
					_nIDAndar := 1
					_cRef := 'M'
				elseif _nIDAndar = 100 .and. _cRef = 'M'
					_nIDAndar := 1
					_cRef := 'O'
				endif

				_cIDAndar := _cRef + strzero(_nIDAndar,2)   //Identificador unico do elemento da Tree (galho)
				oTree:AddItem("Andar " + ZZH->ZZH_ANDAR,_cIDAndar,_cFolder,,,,2)
				_cAndar := iif(ZZH->ZZH_LOCAL = 'TA',_cIdAndar,ZZH->ZZH_ANDAR)//ZZH->ZZH_ANDAR
				//Adicionado ao vetor para procura neste durante a navegação com a propriedade oTree:GetCargo()
				aadd(_aAndar,{_cIDAndar,_cPatch})
			endif

		endif

		//Dentro dessa condicional há um laço para agilizar a construção dos aptos na Tree
		//O identificador do elemento apto não possui letra inicial pois o tamanho deste é restrito
		//e por isso foi necessário utilizar numeros (maximo 999)
		if ZZH->ZZH_LOCAL <> 'TA'	
			if ZZH->ZZH_RUA = '03'
				if !empty(_cApto)
					_cApto = ''
				endif
			endif
		endif

		if alltrim(_cApto) <> alltrim(ZZH->ZZH_APTO)
			_cFolder := "FOLDER10"
			If oTree:TreeSeek(_cIDAndar)
				_cChave := ZZH->(ZZH_FILIAL+ZZH_LOCAL+ZZH_RUA+ZZH_PREDIO+ZZH_ANDAR)
				ZZH->(dbGoTop())
				ZZH->(MsSeek(_cChave))
				while ZZH->(!eof()) .and. ZZH->(ZZH_FILIAL+ZZH_LOCAL+ZZH_RUA+ZZH_PREDIO+ZZH_ANDAR) = _cChave
					incProc()

					_cPatch  := ZZH->(ZZH_LOCAL+ZZH_RUA+ZZH_PREDIO+ZZH_ANDAR+ZZH_APTO)

					SZP->(DbSetOrder(2))
					if SZP->(MsSeek(FWxfilial('SZP') + _cPatch))
						_cFolder := "FOLDER14"
					else
						_cFolder := "FOLDER10"
					endif

					_nIDApto++

					_cIDApto := iif(ZZH->ZZH_LOCAL = 'TA','Z' + strzero(_nIDApto,2),strzero(_nIDApto,3))    //Identificador unico do elemento da Tree (galho)

					oTree:AddItem('Apto ' + ZZH->ZZH_APTO,_cIDApto,_cFolder,,,,2)
					//				if ZZH->ZZH_RUA = '03'
					//					_cApto := strzero(val(ZZH->ZZH_APTO) + 1,2)
					//				else				
					//					_cApto := ZZH->ZZH_APTO
					//				endif

					_cApto := iif(ZZH->ZZH_LOCAL = 'TA',_cIDApto,ZZH->ZZH_APTO)
					//Adicionado ao vetor para procura neste durante a navegação com a propriedade oTree:GetCargo()
					aadd(_aApto,{_cIDApto,_cPatch})
					ZZH->(DbSkip())
				enddo
			endif
		else
			ZZH->(DbSkip())
		endif

	enddo

	oTree:EndUpdate()
	oTree:TreeSeek(_cIDLocal)
	oTree:EndTree()
	//Fim da montagem da Tree

	@001,029 say 'Pallets:'
	@007,029 say 'Caixas:'
	@013,029 say 'Caixas Sortidas:'

	@001,019 say 'Camara:'
	@001,025  MSGET cpo1 VAR _DispLoc SIZE 11,11 OF oDlg

	@002,019 say 'Rua:'
	@002,025  MSGET cpo2 VAR _DispRua SIZE 11,11 OF oDlg

	@003,019 say 'Predio:'
	@003,025  MSGET cpo3 VAR _DispPre SIZE 11,11 OF oDlg

	@004,019 say 'Andar:'
	@004,025  MSGET cpo4 VAR _DispAnd SIZE 11,11 OF oDlg

	@005,019 say 'Apto:'
	@005,025  MSGET cpo5 VAR _DispApt SIZE 11,11 OF oDlg

	@007,019 say 'Endereço:'
	@008,019  MSGET cpo6 VAR _DispEnd SIZE 50,11 Picture "@R !!.!!.!!.!!.!!" OF oDlg

	@010,019 say 'Modo:'
	oRadio := TRadMenu():New(140,160,_aOpcoes,{|u| Iif(PCount()=0,_nModo,_nModo:=u)},oDlg,,{||Modos()},,,,,,100,12,,,,.T.)

	@013,019 say 'Sequencial:'
	oRadio2 := TRadMenu():New(180,160,_aOpSeq,{|u| Iif(PCount()=0,_nModSeq,_nModSeq:=u)},oDlg,,{||ModSeq()},,,,,,100,12,,,,.T.)

	//  oRadio:bSetGet := {|u| Iif(PCount()=0,_nModo,_nModo:=u)}

	@018,019 say 'Leitura:'
	@019,019  MSGET cpo7 VAR _Control SIZE 50,11 Picture VALID Leitura() OF oDlg

	@020,019 say 'Caixas lidas:'
	@020,025  MSGET cpo8 VAR _nCaix SIZE 16,11 OF oDlg

	@ 025,230 To 080,400 Browse "TMP" fields aCampos object oBrow
	oBrow:oBrowse:bldBlClick :=  {|| ClcBrow()}

	@ 100,230 To 160,400 Browse "TMP2" fields aCampos2 object oBrow2

	@ 180,230 To 257,400 Browse "TMP3" fields aCampos2 object oBrow3

	oFont  := tFont():New("courier new",,-20,,.t.,,,,)
	oSayPal1 := tSay():New(270,140,{|| _Mens1 },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,50)
	oSayPal2 := tSay():New(270,140,{|| _Mens2 },oDlg,,oFont,,,,.T.,CLR_HRED,CLR_HRED,200,50)

	cpo1:disable()
	cpo2:disable()
	cpo3:disable()
	cpo4:disable()
	cpo5:disable()
	cpo6:disable()
	cpo7:disable()
	cpo8:disable()

	@262,340 BUTTON btn00 PROMPT "Montagem" OF oDlg PIXEL ACTION ChamaBtn1()
	@276,340 BUTTON btn01 PROMPT "Consulta" OF oDlg PIXEL ACTION ChamaBtn2()
	@290,340 BUTTON btn02 PROMPT " Fechar " OF oDlg PIXEL ACTION oDlg:end()

	ACTIVATE DIALOG oDlg CENTERED

	If Select("TMP") != 0
		TMP->(DbCloseArea())
	Endif
	If(oTmpTable <> NIL)
		oTmpTable:Delete()
		oTmpTable := NIL
	EndIf

	If Select("TMP2") != 0
		TMP2->(DbCloseArea())
	Endif
	If(oTmp2Table <> NIL)
		oTmp2Table:Delete()
		oTmp2Table := NIL
	EndIf

	If Select("TMP3") != 0
		TMP3->(DbCloseArea())
	Endif
	If(oTmp3Table <> NIL)
		oTmp3Table:Delete()
		oTmp3Table := NIL
	EndIf

Return

//Função que é executada ao selecionar qualquer item da Tree
Static Function Apontar()
	Local _cIDApto
	Local _nPos
	Local _cChave

	if  oTree:Nivel() = 5 //Se o nivel for 5 (Aptos) aponta o endereço...
		cpo7:enable()
		_cIDApto := oTree:GetCargo()
		_nPos    := aScan(_aApto,{|aVal|aVal[1] = _cIDApto})  //Pega a posição encontrada no vetor
		_cChave  := FWxfilial('ZZH')+_aApto[_nPos][2]         //com a posição do vetor monta a chave

		ZZH->(DbSetOrder(1))
		ZZH->(DbGoTop())
		if ZZH->(MsSeek(_cChave))
			_DispRua := ZZH->ZZH_RUA
			_DispPre := ZZH->ZZH_PREDIO
			_DispAnd := ZZH->ZZH_ANDAR
			_DispApt := ZZH->ZZH_APTO
			_DispEnd := ZZH->ZZH_DESCRI
		endif

		AtuBrow(_DispEnd)

		cpo7:SetFocus()

	elseif oTree:Nivel() = 4 //Se o nivel for 4 (Andares) também aponta o endereço...
		cpo7:enable()
		_cIDAndar:= oTree:GetCargo()
		_nPos := aScan(_aAndar,{|aVal|aVal[1] = _cIDAndar}) //Pega a posição encontrada no vetor
		_cChave := FWxfilial('ZZH')+_aAndar[_nPos][2]         //com a posição do vetor monta a chave

		ZZH->(DbSetOrder(1))
		ZZH->(DbGoTop())
		if ZZH->(MsSeek(_cChave))
			_DispRua := ZZH->ZZH_RUA
			_DispPre := ZZH->ZZH_PREDIO
			_DispAnd := ZZH->ZZH_ANDAR
			_DispApt := '00'
			_DispEnd := ZZH->(ZZH_LOCAL+ZZH_RUA+ZZH_PREDIO+ZZH_ANDAR) + '00'
		endif

		AtuBrow(_DispEnd)

		cpo7:SetFocus()

	else  //Se não for nivel 5 nem 4 não habilita leitura e limpa os campos e browses

		if _nModo <> 1
			cpo7:enable()
		else
			cpo7:disable()
		endif

		_DispRua := ''
		_DispPre := ''
		_DispAnd := ''
		_DispApt := ''
		_DispEnd := ''
	endif

	_nCaix := 0

	cpo1:Refresh()
	cpo2:Refresh()
	cpo3:Refresh()
	cpo4:Refresh()
	cpo5:Refresh()
	cpo6:Refresh()
	cpo8:Refresh()
	oBrow:oBrowse:refresh()
	oBrow2:oBrowse:refresh()
	oDlg:Refresh()

return

//Leitura das caixas/pallets
Static Function Leitura()

	if empty(_Control)
		Return .t.
	endif

	_cTipoPal := substr(_Control,1,2)

	if _cTipoPal $ 'PA/MP' //Se for pallet...

		//Para verficar as quantidades nos locais
		SZP->(DbSetOrder(2))
		SZP->(DbGoTop())

		_nPal1 := contagem("SZP","ZP_LOCALIZ = '" + alltrim(_DispEnd) + "'")
		//	_nPal1 :=  contar("SZP","SZP->ZP_FILIAL = FWxfilial('SZP') .and. SZP->ZP_LOCALIZ = '" + alltrim(_DispEnd) + "'")
		_nPal2 := contagem("SZP","ZP_LOCALIZ LIKE '%" +substr(alltrim(_DispEnd),1,8) + "%'")
		//	_nPal2 :=  contar("SZP","SZP->ZP_FILIAL = FWxfilial('SZP') .and. '" + substr(alltrim(_DispEnd),1,8) + "' $ SZP->ZP_LOCALIZ ")

		if oTree:Nivel() = 4 .and. _nModo = 1
			if _nPal1 >= _nMaxApto .or. _nPal2 >= _nMaxApto
				SomErr(1)
				_cMens1 := ''
				_cMens2 := 'Andar cheio!'
				oSayPal1:SetText(_cMens1)
				oSayPal2:SetText(_cMens2)
				oDlg:refresh()
				return .f.
			endif
		elseif oTree:Nivel() = 5 .and. _nModo = 1
			if _nPal1 = 1 .or. _nPal2 >= _nMaxApto
				SomErr(1)
				_cMens1 := ''
				_cMens2 := 'Apto cheio!'
				oSayPal1:SetText(_cMens1)
				oSayPal2:SetText(_cMens2)
				oDlg:refresh()
				return .f.
			endif
		endif

		//Fim da verificação das quantidades por locais

		SZP->(DbSetOrder(1))
		SZP->(DbGoTop())

		if !SZP->(MsSeek(FWxfilial('SZP')+alltrim(_Control)))
			SomErr(1)
			_cMens1 := ''
			_cMens2 := 'Pallet não identificado!'
			oSayPal1:SetText(_cMens1)
			oSayPal2:SetText(_cMens2)
			oDlg:refresh()
			return .f.
		endif

		_cCamArm := GetAdvFVal('NNR','NNR_FARM',FWxFilial('NNR')+mv_par01,1)
		_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+SZP->ZP_PRODUTO,1) 
		_cFarm  := GetAdvFVal('SBM','BM_FARM',FWxfilial('SBM')+_cGrupo,1)

		//Bloco para verificar se o produto esta sendo armazenado da forma correta na camara correta	
		if !empty(_cCamArm)
			if alltrim(_cFarm) <> alltrim(_cCamArm)
				SomErr(2)    
				//conout('Linha 465 - > !!')      
				_cMens1 := ''
				_cMens2 := 'Forma de armazenamento do produto nao condiz com o tipo de camara!'
				oSayPal1:SetText(_cMens1)
				oSayPal2:SetText(_cMens2)
				oDlg:refresh()
				return .f.					
			endif	     	
		endif

		if SZP->ZP_FIL <> cFilAnt
			SomErr(1)
			_cMens1 := ''
			_cMens2 := 'Pallet em estoque fora da unidade!'
			oSayPal1:SetText(_cMens1)
			oSayPal2:SetText(_cMens2)
			oDlg:refresh()
			return .f.
		endif

		if _cTipo <> _cTipoPal
			SomErr(1)
			_cMens1 := ''
			_cMens2 := 'Tipo de prod. escolhida no parametro nao corresponde ao tipo de prod. do Pallet'
			oSayPal1:SetText(_cMens1)
			oSayPal2:SetText(_cMens2)
			oDlg:refresh()
			return .f.
		endif

		//Se há alguma falha no apontamento do endereço...
		if empty(_DispEnd) .and. _nModo = 1
			SomErr(1)
			_cMens1 := ''
			_cMens2 := 'Falha no apontamento do endereço!'
			oSayPal1:SetText(_cMens1)
			oSayPal2:SetText(_cMens2)
			oDlg:refresh()
			return .f.
		endif

		//Para definir a cor das pastas da tree
		_nPosApto  := 0
		_nPosAndar := 0
		_cargo     := ''

		//Se a caixa já está locada em alguma localização física...
		if SZP->ZP_LOCALIZ <> _DispEnd
			_nPosApto   := aScan(_aApto,{|aVal|aVal[2]  = SZP->ZP_LOCALIZ})  //Pega a posição encontrada no vetor dos apartamentos
			_nPosAndar  := aScan(_aAndar,{|aVal|aVal[2] = SZP->ZP_LOCALIZ})  //Pega a posição encontrada no vetor dos andares

			//Se conseguiu identificar o ID corretamente
			if _nPosApto <> 0
				_cargo := _aApto[_nPosApto][1]
			elseif _nPosAndar <> 0
				_cargo := _aAndar[_nPosAndar][1]
			endif

			if !empty(_cargo)
				oTree:ChangeBmp( "FOLDER10", "FOLDER10",,,_cargo)
				oDlg:refresh()
			endif
		endif

		//Se for entrada e estiver no nivel dos apartamentos, pinta de preto
		if _nModo = 1 .and. oTree:Nivel() = 5
			_cIDApto := oTree:GetCargo()
			oTree:ChangeBmp( "FOLDER14", "FOLDER14",,,_cIDApto )
			oDlg:refresh()
		endif

		//Ajusta a localização nas caixas
		//Se for PA...
		if _cTipo = 'PA' .and. _cTipoPal = 'PA'
			SZ8->(DbSetOrder(19))
			SZ8->(DbGoTop())
			if SZ8->(MsSeek(FWxfilial('SZ8')+cFilAnt+alltrim(_Control)))

				while SZ8->(!eof()) .and. SZ8->Z8_FIL = cFilAnt .and. SZ8->Z8_PALLET = alltrim(_Control)

					// Verifica se as caixas passaram da validade
					SomErr(VerifGrp(SZ8->Z8_COD))

					if cUserID != "000914"
						if (!empty(SZ8->Z8_PRECAR) .or. !empty(SZ8->Z8_PREPED) .or. !empty(SZ8->Z8_ITEM) .or. !empty(SZ8->Z8_DATAS) .or. !empty(SZ8->Z8_HORAS)) .and. !(SZ8->Z8_MOTBAIX $ "COLETA/SEQUESTRO")
							SomErr(1)
							_cMens1 := ''
							_cMens2 := 'Caixa fora de estoque!'
							oSayPal1:SetText(_cMens1)
							oSayPal2:SetText(_cMens2)
							return .f.
						endif
					endif

					reclock('SZ8',.f.)
					if cUserID = "000914" // Usuário "inventario"
						SZ8->Z8_DATAS := stod("")
					endif
					SZ8->Z8_LOCALIZ := iif(_nModo = 1,_DispEnd,'')
					SZ8->Z8_LOCAL   := iif(_nModo = 1,substr(_DispEnd,1,2),'')
					SZ8->Z8_INV		:= 'X'
					SZ8->Z8_CHKCARR := ''
					SZ8->Z8_CHKPCAR := ''
					msunlock()

					if _nModo = 1
						u_gjf17his(3,'End. local:' + _DispEnd,.f.,'','','000003',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
					elseif _nModo = 2
						u_gjf17his(3,'Remov. local:' + _DispEnd,.f.,'','','000004',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
					endif

					SZ8->(DbSkip())
				enddo
			endif
			//Ser for MP...
		elseif _cTipo = 'MP' .and. _cTipoPal = 'MP'
			ZAS->(DbSetOrder(6))
			ZAS->(DbGoTop())
			if ZAS->(MsSeek(FWxfilial('ZAS') + alltrim(_Control)))
				while ZAS->(!eof()) .and. ZAS->ZAS_FILIAL = FWxfilial('ZAS') .and. ZAS->ZAS_PALLET = alltrim(_Control)

					reclock('ZAS',.f.)
					ZAS->ZAS_LOCALI := iif(_nModo = 1,_DispEnd,'')
					ZAS->ZAS_LOCAL  := iif(_nModo = 1,substr(_DispEnd,1,2),'')
					msunlock()

					ZAS->(DbSkip())
				enddo
			endif

		endif
		//Fim do ajuste das localizações nas caixas

		//Pega a localização antiga
		_cLocAnt := SZP->ZP_LOCALIZ

		//Grava a localização no pallet...
		reclock('SZP',.f.)
		SZP->ZP_LOCALIZ := iif(_nModo = 1,_DispEnd,'')
		SZP->ZP_HORA    := time() //Adicionado por Mauricio dia 12/11/2013 para armazenar a hora de gravação do pallet
		msunlock()

		ExecSom()
		_cMe := 'Pallet ' + alltrim(SZP->ZP_COD) + ' apontado para o endereço ' + _DispEnd
		_cMs := 'Pallet ' + alltrim(SZP->ZP_COD) + ' retirado do endereço ' + _DispEnd
		_cMens1 := iif(_nModo = 1,_cMe,_cMs)
		_cMens2 := ''
		oSayPal1:SetText(_cMens1)
		oSayPal2:SetText(_cMens2)

		if oTree:Nivel() = 4

			_nPal1 := 0
			_nPal:= contagem("SZP","ZP_LOCALIZ = '" + alltrim(_DispEnd) + "'")

			//	_cIDApto := oTree:GetCargo()
			if _nPal1 >= _nMaxApto
				oTree:ChangeBmp( "FOLDER14", "FOLDER14",,,_cIDApto )
			else
				oTree:ChangeBmp( "FOLDER10", "FOLDER10",,,_cIDApto )
			endif
			oDlg:refresh()
		endif

		_nPal2 := 0
		_nPal2 := contagem("SZP","ZP_LOCALIZ LIKE '%"+ substr(alltrim(_DispEnd),1,8) + "%'")

		_nPosAndar  := aScan(_aAndar,{|aVal|aVal[2] = substr(alltrim(_DispEnd),1,8)})  //Pega a posição encontrada no vetor dos andares

		_cargo := _aAndar[_nPosAndar][1]
		if _nPal2 >= _nMaxApto
			oTree:ChangeBmp( "FOLDER14", "FOLDER14",,,_cargo)
		else
			oTree:ChangeBmp( "FOLDER10", "FOLDER10",,,_cargo)
		endif

		if !empty(_cLocAnt)

			_nPal3 := 0
			_nPal3 := contagem("SZP","ZP_LOCALIZ like '%" +  substr(alltrim(_cLocAnt),1,8) + "%'")
			//_nPal3 := contar("SZP","SZP->ZP_FILIAL = FWxfilial('SZP') .and. '" + substr(alltrim(_cLocAnt),1,8) + "' $ SZP->ZP_LOCALIZ ")
			_nPosAndar  := aScan(_aAndar,{|aVal|aVal[2] = substr(alltrim(_cLocAnt),1,8)})  //Pega a posição encontrada no vetor dos andares
			_cargo := _aAndar[_nPosAndar][1]

			if _nPal3 >= _nMaxApto
				oTree:ChangeBmp( "FOLDER14", "FOLDER14",,,_cargo)
			else
				oTree:ChangeBmp( "FOLDER10", "FOLDER10",,,_cargo)
			endif

		endif
		oDlg:refresh()
		_Control := space(11)

		AtuBrow(_DispEnd)

		//Se a leitua indicar ser uma caixa...
	else
		//Se a caixa for um PA...
		if _cTipo = "PA" //.and. _cTipoPal = "PA"
			SZ8->(DbGoTop())
			ZAS->(DbSetOrder(1))
			ZAS->(DbGoTop())

			if _nModSeq = 1
				SZ8->(DbSetOrder(3))
				_lSZ8 := SZ8->(MsSeek(FWxfilial('SZ8')+alltrim(_Control)))
			else
				SZ8->(DbSetOrder(28))
				if SZ8->(MsSeek(FWxfilial('SZ8')+alltrim(_Control)))
					_Control := SZ8->Z8_CONTROL
					_lSZ8 := .T.
				else
					_cControl := U_DTI210(_Control, "")
					_cLinha   := GetAdvFVal('ZAS','ZAS_LIN',FWxFilial('ZAS') + _cControl,1)
					if !empty(_cControl)
						u_gjf17his(1,'ENTRADA ESTOQUE - ' + _cLinha,.f.,'','','000012', _cControl)
						_Control := _cControl
						SZ8->(DbSetOrder(3))
						_lSZ8 := SZ8->(MsSeek(FWxfilial('SZ8')+alltrim(_Control)))
					else
						_lSZ8 := .F.
					endif
				endif
			endif

			_lZAS := ZAS->(MsSeek(FWxfilial('ZAS')+alltrim(_Control)))

			if !_lSZ8 .and. !_lZAS
				SomErr(1)
				_cMens1 := ''
				_cMens2 := 'Caixa não identificada!'
				oSayPal1:SetText(_cMens1)
				oSayPal2:SetText(_cMens2)
				return .f.
			endif

			// Se a caixa for armazenada em câmaras incorretas - MP em câmara PA ou PA em câmara MP
			if _lSZ8 .or. (ZAS->ZAS_TIPO = 'PA' .and. mv_par01 = '21')
				if mv_par01 = '21'
					SomErr(2)
					_cMens1 := ''
					_cMens2 := 'Produto acabado destinado a camara incorreta!'
					oSayPal1:SetText(_cMens1)
					oSayPal2:SetText(_cMens2)
					oDlg:refresh()
					return .f.
				endif
			elseif _lZAS
				if ZAS->ZAS_TIPO = 'MP' .and. mv_par01 = '23'
					SomErr(2)
					_cMens1 := ''
					_cMens2 := 'Produto MP destinado a camara incorreta!'
					oSayPal1:SetText(_cMens1)
					oSayPal2:SetText(_cMens2)
					oDlg:refresh()
					return .f.
				endif
			endif

			//Bloco para verificar se o produto esta sendo armazenado da forma correta na camara correta
			if _lZAS
				_cCamArm := GetAdvFVal('NNR','NNR_FARM',FWxFilial('NNR')+mv_par01,1)
				_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+ZAS->ZAS_COD,1)
			elseif _lSZ8
				_cCamArm := GetAdvFVal('NNR','NNR_FARM',FWxFilial('NNR')+mv_par01,1)
				_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+SZ8->Z8_COD,1)
			endif
			_cFarm  := GetAdvFVal('SBM','BM_FARM',FWxfilial('SBM')+_cGrupo,1)

			if _lZAS
				if alltrim(_cFarm) <> alltrim(_cCamArm) .and. !empty(mv_par01)
					SomErr(2)
					_cMens1 := ''
					_cMens2 := 'Forma de armazenamento do produto nao condiz com o tipo de camara!'
					oSayPal1:SetText(_cMens1)
					oSayPal2:SetText(_cMens2)
					oDlg:refresh()
					return .f.	
				endif
			elseif _lSZ8
				if alltrim(_cFarm) <> alltrim(_cCamArm) .and. !empty(mv_par01)
					SomErr(2)
					_cMens1 := ''
					_cMens2 := 'Forma de armazenamento do produto nao condiz com o tipo de camara!'
					oSayPal1:SetText(_cMens1)
					oSayPal2:SetText(_cMens2)
					oDlg:refresh()
					return .f.	
				endif
			endif

			_lFora := .f.

			if _lZAS
				if (!empty(ZAS->ZAS_DATAS) .or. !empty(ZAS->ZAS_HORAS)) .and. !(ZAS->ZAS_MOTS $ "COLETA/SEQUESTRO")
					_lFora := .t.
				endif
			elseif _lSZ8
				if (!empty(SZ8->Z8_DATAS) .or. !empty(SZ8->Z8_HORAS) .or. !empty(SZ8->Z8_PRECAR) .or. !empty(SZ8->Z8_PREPED) .or. !empty(SZ8->Z8_ITEM)) .and. !(SZ8->Z8_MOTBAIX $ "COLETA/SEQUESTRO")
					_lFora := .t.
				endif
			endif

			if cUserID != "000914"
				if _lFora
					SomErr(2)
					_cMens1 := ''
					_cMens2 := 'Caixa já encontra-se fora do estoque!'
					oSayPal1:SetText(_cMens1)
					oSayPal2:SetText(_cMens2)
					oDlg:refresh()
					return .f.
				endif
			endif

			if _lSZ8 .and. SZ8->Z8_FIL <> cFilAnt
				SomErr(1)
				_cMens1 := ''
				_cMens2 := 'Caixa em estoque fora da unidade!'
				oSayPal1:SetText(_cMens1)
				oSayPal2:SetText(_cMens2)
				oDlg:refresh()
				return .f.
			endif

			//Modo = 1: entrada/remanejo na camara
			//Modo = 2: saída da camara
			_cPallet := SZ8->Z8_PALLET

			//Se há alguma falha no apontamento do endereço...
			if empty(_DispEnd) .and. _nModo = 1
				SomErr(1)
				_cMens1 := ''
				_cMens2 := 'Falha no apontamento do endereço!'
				oSayPal1:SetText(_cMens1)
				oSayPal2:SetText(_cMens2)
				oDlg:refresh()
				return .f.
			endif

			if _lZAS
				if (ZAS->ZAS_DTPROD + ZAS->ZAS_VALID) < (date()+7)
					SomErr(2)
					//FWAlertWarning("Caixa a menos de 7 dias da validade!", "ALERTA")
				endif
			elseif _lSZ8
				if _cGrupo $ _cGrpPorc .and. SZ8->Z8_DATAVAL < (date()+7)
					SomErr(2)
				elseif !(_cGrupo $ _cGrpPorc) .and. SZ8->Z8_DATAVAL < (date()+30)
					SomErr(2)
					FWAlertWarning("Caixa a menos de 30 dias da validade!", "ALERTA")
				endif
			endif

			// Verifica se as caixas passaram da validade
			if _lSZ8 
				SomErr(VerifGrp(SZ8->Z8_COD))
			endif

			if _lZAS
				if ZAS->ZAS_TIPO = 'PA'

					_cCostPrc := getMV('SI_COSTPRC')

					_dDtAbate := GetAdvFval('ZAU','ZAU_DTABAT',FWxFilial('ZAU') + ZAS->ZAS_LOTE,1) //GetAdvFval('SZ2','Z2_DATAABT',FWxFilial('SZ2') + ZAS->ZAS_PREDES,2)

					reclock('SZ8',.t.)
					SZ8->Z8_FILORI    := cFilAnt
					SZ8->Z8_FIL       := cFilAnt
					SZ8->Z8_FILIAL    := FWxfilial('SZ8')
					SZ8->Z8_ID        := substr(ZAS->ZAS_CONTRO,3,8)
					SZ8->Z8_CONTROL   := ZAS->ZAS_CONTRO
					SZ8->Z8_CODORI    := ZAS->ZAS_COD
					SZ8->Z8_COD       := ZAS->ZAS_COD
					SZ8->Z8_DATA      := ZAS->ZAS_DTPROD
					SZ8->Z8_DATAP     := ZAS->ZAS_DTPROD
					SZ8->Z8_HORA      := ZAS->ZAS_HORA//time()
					SZ8->Z8_TIPO      := 'P'
					SZ8->Z8_TF        := 'N'
					SZ8->Z8_QUANT     := GetAdvFval('SB1','B1_QTBCAIX',FWxfilial('SB1')+ZAS->ZAS_COD,1)
					SZ8->Z8_PESO      := ZAS->ZAS_PESOL
					SZ8->Z8_TARA      := ZAS->ZAS_TARA
					SZ8->Z8_PESOBR    := ZAS->ZAS_PESOB
					SZ8->Z8_ETIQ      := 'P'
					SZ8->Z8_LOCAL     := mv_par03
					SZ8->Z8_DATAVAL   := iif(alltrim(ZAS->ZAS_COD) $ _cCostPrc,_dDtAbate + ZAS->ZAS_VALID, ZAS->ZAS_DTPROD + ZAS->ZAS_VALID) //ZAS->ZAS_DTPROD + ZAS->ZAS_VALID
					SZ8->Z8_DESCRI    := GetAdvFval('SB1','B1_DESCRED',FWxfilial('SB1')+ZAS->ZAS_COD,1)
					SZ8->Z8_DTENTES   := date()
					SZ8->Z8_LOTEPOR   := ZAS->ZAS_LOTE
					SZ8->Z8_BATEL     := ZAS->ZAS_BATEL
					SZ8->Z8_PREPORC   := ZAS->ZAS_PREPOR
					SZ8->Z8_NUMPREV   := ZAS->ZAS_PREEMB
					SZ8->Z8_PREDES    := ZAS->ZAS_PREDES
					SZ8->Z8_PESFIX    := ZAS->ZAS_PESFIX
					SZ8->Z8_ORIGEM    := 'P'
					SZ8->Z8_BALAN     := ZAS->ZAS_LIN
					SZ8->Z8_INV    	  := 'X'
					SZ8->Z8_SETPRO    := ZAS->ZAS_SETPRO
					SZ8->Z8_FARM      := ZAS->ZAS_FARM
					msunlock()

					SZW->(dbsetorder(2))
					SZW->(DbGoTop())
					if SZW->(Msseek(FWxfilial('SZW') + alltrim(ZAS->ZAS_CONTRO)))
						reclock('SZW',.f.)
						SZW->ZW_HORAS   := time()
						SZW->ZW_DATAS   := date()
						SZW->ZW_OPERA   := cUserName
						msunlock()
					endif

					ZAU->(DbSetOrder(1))
					if ZAU->(MsSeek(FWxfilial('ZAU') + SZ8->Z8_LOTEPOR))
						reclock('ZAU',.f.)
						ZAU->ZAU_QRPESF += SZ8->Z8_PESO
						ZAU->ZAU_QRCAIF++

						if ZAU->ZAU_QRPESF >= ZAU->ZAU_QPPESO
							ZAU->ZAU_STATT  := 'E'
							ZAU->ZAU_STATUS := 'E'
							ZAU->ZAU_WFW    := 'E'
						endif
						msunlock()
					endif

					reclock('ZAS',.f.)
					DbDelete()
					msunlock()
				else
					reclock('ZAS',.f.)
					ZAS->ZAS_LOCAL := mv_par01
					msunlock()
				endif
			endif

			_nCaix++
			cpo8:Refresh()

			reclock('SZ8',.f.)
			if cUserID = "000914" // Usuário "inventario"
				SZ8->Z8_DATAS := stod("")
			endif
			SZ8->Z8_PALLET  := ''
			SZ8->Z8_LOCALIZ := iif(_nModo = 1,_DispEnd,'')
			SZ8->Z8_LOCAL   := iif(_nModo = 1,substr(_DispEnd,1,2),'')
			SZ8->Z8_INV	    := 'X'
			SZ8->Z8_CHKCARR := ''
			SZ8->Z8_CHKPCAR := ''
			msunlock()

			if _nModo = 1
				u_gjf17his(3,'End. local:' + _DispEnd,.f.,'','','000003',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
			elseif _nModo = 2
				u_gjf17his(3,'Remov. local:' + _DispEnd,.f.,'','','000004',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
			endif

			//Verifica se o pallet que estava associado à caixa não está vazio
			//e estiver  função o exclui
			u_gjf31PA(_cPallet)

			ExecSom()
			_cMe := 'Caixa ' + alltrim(SZ8->Z8_CONTROL) + ' apontada para o endereço ' + _DispEnd
			_cMs := 'Caixa ' + alltrim(SZ8->Z8_CONTROL) + ' retirada do endereço ' + _DispEnd
			_cMens1 := iif(_nModo = 1,_cMe,_cMs)
			_cMens2 := ''
			oSayPal1:SetText(_cMens1)
			oSayPal2:SetText(_cMens2)

			oDlg:refresh()

			_Control := space(11)

			AtuBrow(_DispEnd)

			// Ser for matéria-prima
		elseif _cTipo = "MP" //.and. _cTipoPal = "MP"
			ZAS->(DbSetOrder(1))
			ZAS->(DbGoTop())
			if !ZAS->(MsSeek(FWxfilial('ZAS')+alltrim(_Control)))
				SomErr(1)
				_cMens1 := ''
				_cMens2 := 'Caixa não identificada!'
				oSayPal1:SetText(_cMens1)
				oSayPal2:SetText(_cMens2)
				return .f.
			endif

			if ZAS->ZAS_TIPO = 'MP' .and. mv_par01 = '23'
				SomErr(2)
				_cMens1 := ''
				_cMens2 := 'Matéria prima destinada a camara incorreta!'
				oSayPal1:SetText(_cMens1)
				oSayPal2:SetText(_cMens2)
				oDlg:refresh()
				return .f.
			elseif ZAS->ZAS_TIPO = 'PA' .and. mv_par01 = '21'
				SomErr(2)
				_cMens1 := ''
				_cMens2 := 'Produto acabado destinado a camara incorreta!'
				oSayPal1:SetText(_cMens1)
				oSayPal2:SetText(_cMens2)
				oDlg:refresh()
				return .f.
			endif

			//Bloco para verificar se o produto esta sendo armazenado da forma correta na camara correta
			_cCamArm := GetAdvFVal('NNR','NNR_FARM',FWxFilial('NNR')+mv_par01,1)
			_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+ZAS->ZAS_COD,1) 
			_cFarm  := GetAdvFVal('SBM','BM_FARM',FWxfilial('SBM')+_cGrupo,1) 

			if !empty(_cCamArm)
				if alltrim(_cFarm) <> alltrim(_cCamArm)
					SomErr(2)                                                                   
					_cMens1 := ''
					_cMens2 := 'Forma de armazenamento do produto nao condiz com o tipo de camara!'
					oSayPal1:SetText(_cMens1)
					oSayPal2:SetText(_cMens2)
					oDlg:refresh()
					return .f.					
				endif	     	
			endif

			if cUserID != "000914"
				if (!empty(ZAS->ZAS_DATAS) .or. !empty(ZAS->ZAS_HORAS)) .and. !(ZAS->ZAS_MOTS $ "COLETA/SEQUESTRO")
					SomErr(1)
					_cMens1 := ''
					_cMens2 := 'Caixa fora de estoque!'
					oSayPal1:SetText(_cMens1)
					oSayPal2:SetText(_cMens2)
					return .f.
				endif
			endif

			//Modo = 1: entrada/remanejo na camara
			//Modo = 2: saída da camara
			_cPallet := ZAS->ZAS_PALLET

			//Se há alguma falha no apontamento do endereço...
			if empty(_DispEnd) .and. _nModo = 1
				SomErr(1)
				_cMens1 := ''
				_cMens2 := 'Falha no apontamento do endereço!'
				oSayPal1:SetText(_cMens1)
				oSayPal2:SetText(_cMens2)
				oDlg:refresh()
				return .f.
			endif

			_nCaix++
			cpo8:Refresh()

			reclock('ZAS',.f.)
			ZAS->ZAS_PALLET  := ''
			ZAS->ZAS_LOCALI := iif(_nModo = 1,_DispEnd,'')
			ZAS->ZAS_LOCAL   := iif(_nModo = 1,substr(_DispEnd,1,2),'')
			msunlock()

			//Verifica se o pallet que estava associado à caixa não está vazio
			//e estiver  função o exclui
			u_gjf31PA(_cPallet)

			ExecSom()
			_cMe := 'Caixa ' + alltrim(ZAS->ZAS_CONTRO) + ' apontada para o endereço ' + _DispEnd
			_cMs := 'Caixa ' + alltrim(ZAS->ZAS_CONTRO) + ' retirada do endereço ' + _DispEnd
			_cMens1 := iif(_nModo = 1,_cMe,_cMs)
			_cMens2 := ''
			oSayPal1:SetText(_cMens1)
			oSayPal2:SetText(_cMens2)

			oDlg:refresh()

			_Control := space(11)

			AtuBrow(_DispEnd)

		endif
	endif

Return .f.

Static function VerifGrp(cCod)

	_grupo := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+alltrim(cCod),1)
	_dtValCO := date() + 12
	_dtValSO := date() + 35

	if (_grupo $ "0002/0004/0008/0009/0031/0033/0036/0038/5500/6500/6600" .or. substr(_grupo, 1, 2) $ "52/62") .and. SZ8->Z8_DATAVAL <= _dtValCO
		_cMens1 := ''
		_cMens2 := 'Caixa de fora da validade (produto com osso)!'
		oSayPal1:SetText(_cMens1)
		oSayPal2:SetText(_cMens2)
		oDlg:refresh()
		return 2
	elseif (_grupo $ "0001/0003/0006/0030/0032/0037/5510" .or. substr(_grupo, 1, 2) $ "51/61") .and. SZ8->Z8_DATAVAL <= _dtValSO
		_cMens1 := ''
		_cMens2 := 'Caixa de fora da validade (produto sem osso)!'
		oSayPal1:SetText(_cMens1)
		oSayPal2:SetText(_cMens2)
		oDlg:refresh()
		return 2
	endif

return 0

//Funções de Som
static function ExecSom()
	WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE3.WAV',0)
return

Static Function SomErr(_erro)
	if _erro = 1
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0)
	elseif _erro = 2
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEEDT.WAV',0)
	endif
return

Static Function Modos()
	Local _nN := oTree:Nivel()

	/*oSayPal1 := tSay():New(270,140,{|| _Mens1 },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,50)
	oSayPal2 := tSay():New(270,140,{|| _Mens2 },oDlg,,oFont,,,,.T.,CLR_HRED,CLR_HRED,200,50)
	oSayPal1:SetText('')
	oSayPal2:SetText('')
	oDlg:refresh() */

	if _nModo = 1 .and. _nN < _nMaxApto
		cpo7:disable()
	elseif (_nModo = 1 .and. _nN >=_nMaxApto) .or. _nModo = 2
		cpo7:enable()
		cpo7:SetFocus()
	endif

	oDlg:refresh()

return

Static Function ModSeq()
	if _nModSeq = 1
		_Control := space(11)
	elseif _nModSeq = 2
		_Control := space(15)
	endif

	cpo7:refresh()
	oDlg:refresh()
return

//Função para a montagem dos dois browses
Static Function montabrow()

	aArqTmp := {}  
	aArqTmp2 := {}  
	aArqTmp3 := {}  

	aadd(aCampos,{"NUMERO" ,"Pallet"    ,""})
	aadd(aCampos,{"COD"    ,"Produto"   ,""})
	aadd(aCampos,{"DESCRI" ,"Descricao" ,""})
	aadd(aCampos,{"DATAP"  ,"Data"      ,""})
	aadd(aCampos,{"TIPO"   ,"Tipo"      ,""})

	aadd(aCampos2,{"CONTROL" ,"Caixa"    ,""})
	aadd(aCampos2,{"COD"    ,"Produto"   ,""})
	aadd(aCampos2,{"DESCRI" ,"Descricao" ,""})
	aadd(aCampos2,{"DATAP"  ,"Dt. Prod." ,""})
	aadd(aCampos2,{"DATAV"  ,"Dt. Val."  ,""})
	
	If Select("TMP") <= 0
		aadd(aArqTmp,{"NUMERO" 		, "C",  10, 0,})
		aadd(aArqTmp,{"COD"  		, "C",  06, 0,})
		aadd(aArqTmp,{"DESCRI" 		, "C",  30, 0,})
		aadd(aArqTmp,{"DATAP"  		, "D",  08, 0,})
		aadd(aArqTmp,{"TIPO"   		, "C",  02, 0,})

		If(oTmpTable <> NIL)
			oTmpTable:Delete()
			oTmpTable := NIL
		EndIf

		oTmpTable := FWTemporaryTable():New("TMP")
		oTmpTable:SetFields(aArqTmp)
		oTmpTable:Create()
	EndIf


	If Select("TMP2") <= 0
		aadd(aArqTmp2,{"CONTROL"	, "C",  10, 0})
		aadd(aArqTmp2,{"COD"    	, "C",  06, 0})
		aadd(aArqTmp2,{"DESCRI" 	, "C",  30, 0})
		aadd(aArqTmp2,{"DATAP"  	, "D",  08, 0})
		aadd(aArqTmp2,{"DATAV"  	, "D",  08, 0})

		If(oTmp2Table <> NIL)
			oTmp2Table:Delete()
			oTmp2Table := NIL
		EndIf

		oTmp2Table := FWTemporaryTable():New("TMP2")
		oTmp2Table:SetFields(aArqTmp2)
		oTmp2Table:Create()
	Endif
	
	If Select("TMP3") <= 0
		aadd(aArqTmp3,{"CONTROL"	, "C",  10, 0})
		aadd(aArqTmp3,{"COD"    	, "C",  06, 0})
		aadd(aArqTmp3,{"DESCRI" 	, "C",  30, 0})
		aadd(aArqTmp3,{"DATAP"  	, "D",  08, 0})
		aadd(aArqTmp3,{"DATAV"  	, "D",  08, 0})

		If(oTmp3Table <> NIL)
			oTmp3Table:Delete()
			oTmp3Table := NIL
		EndIf

		oTmp3Table := FWTemporaryTable():New("TMP3")
		oTmp3Table:SetFields(aArqTmp3)
		oTmp3Table:Create()
	Endif

Return

//Limpa e habilita o browse.
//Função desenvolvida para a mudança
//de foco da tree
Static Function HabBrow(_opc)
	if _opc = 1

		aArqTmp := {}  
		aArqTmp2 := {}  
		aArqTmp3 := {}  

		If Select("TMP") != 0
			TMP->(DbCloseArea())

			aadd(aArqTmp,{"NUMERO" 	, "C",  10, 0,})
			aadd(aArqTmp,{"COD"    	, "C",  06, 0,})
			aadd(aArqTmp,{"DESCRI" 	, "C",  30, 0,})
			aadd(aArqTmp,{"DATAP"  	, "D",  08, 0,})
			aadd(aArqTmp,{"TIPO"   	, "C",  02, 0,})

			If(oTmpTable <> NIL)
				oTmpTable:Delete()
				oTmpTable := NIL
			EndIf

			oTmpTable := FWTemporaryTable():New("TMP")
			oTmpTable:SetFields(aArqTmp)
			oTmpTable:Create()

			oBrow:oBrowse:refresh()
			oDlg:refresh()
		Endif

		If Select("TMP2") != 0
			TMP2->(DbCloseArea())

			aadd(aArqTmp2,{"CONTROL"	, "C",  10, 0})
			aadd(aArqTmp2,{"COD"    	, "C",  06, 0})
			aadd(aArqTmp2,{"DESCRI" 	, "C",  30, 0})
			aadd(aArqTmp2,{"DATAP"  	, "D",  08, 0})
			aadd(aArqTmp2,{"DATAV"  	, "D",  08, 0})
	
			If(oTmp2Table <> NIL)
				oTmp2Table:Delete()
				oTmp2Table := NIL
			EndIf
	
			oTmp2Table := FWTemporaryTable():New("TMP2")
			oTmp2Table:SetFields(aArqTmp2)
			oTmp2Table:Create()

			oBrow2:oBrowse:refresh()
			oDlg:refresh()
		Endif

		If Select("TMP3") != 0
			TMP3->(DbCloseArea())

			aadd(aArqTmp3,{"CONTROL"	, "C",  10, 0})
			aadd(aArqTmp3,{"COD"    	, "C",  06, 0})
			aadd(aArqTmp3,{"DESCRI" 	, "C",  30, 0})
			aadd(aArqTmp3,{"DATAP"  	, "D",  08, 0})
			aadd(aArqTmp3,{"DATAV"  	, "D",  08, 0})
	
			If(oTmp3Table <> NIL)
				oTmp3Table:Delete()
				oTmp3Table := NIL
			EndIf
	
			oTmp3Table := FWTemporaryTable():New("TMP3")
			oTmp3Table:SetFields(aArqTmp3)
			oTmp3Table:Create()

			oBrow3:oBrowse:refresh()
			oDlg:refresh()
		Endif

	elseif _opc = 2

		aArqTmp2 := {}  

		If Select("TMP2") != 0
			TMP2->(DbCloseArea())

			aadd(aArqTmp2,{"CONTROL"	, "C",  10, 0})
			aadd(aArqTmp2,{"COD"    	, "C",  06, 0})
			aadd(aArqTmp2,{"DESCRI" 	, "C",  30, 0})
			aadd(aArqTmp2,{"DATAP"  	, "D",  08, 0})
			aadd(aArqTmp2,{"DATAV"  	, "D",  08, 0})

			If(oTmp2Table <> NIL)
				oTmp2Table:Delete()
				oTmp2Table := NIL
			EndIf

			oTmp2Table := FWTemporaryTable():New("TMP2")
			oTmp2Table:SetFields(aArqTmp2)
			oTmp2Table:Create()

			oBrow2:oBrowse:refresh()
			oDlg:refresh()
		Endif
	endif

return

//Função para atualizar o browse
Static Function AtuBrow(_end)

	HabBrow(1)

	SZP->(DbSetOrder(2))
	SZP->(DbGoTop())
	if SZP->(MsSeek(FWxfilial('SZP') + alltrim(_end)))
		DbSelectArea('SB1')
		While SZP->(!eof()) .and. SZP->ZP_FILIAL = FWxfilial('SZP') .and. SZP->ZP_LOCALIZ = alltrim(_end)

			if _cTipo <> SZP->ZP_TIPO
				SZP->(DbSkip())
				loop
			endif

			reclock('TMP',.t.)
			TMP->NUMERO := SZP->ZP_COD
			TMP->COD    := SZP->ZP_PRODUTO
			TMP->DESCRI := GetAdvFVal('SB1','B1_DESC',FWxfilial('SB1')+alltrim(SZP->ZP_PRODUTO),1)
			TMP->DATAP  := SZP->ZP_DATA
			TMP->TIPO   := SZP->ZP_TIPO
			msunlock()

			SZP->(DbSkip())
		enddo
	endif
	TMP->(DbGoTop())

	//Se for PA...
	if _cTipo = 'PA' //.and. TMP->TIPO = 'PA'
		SZ8->(DbSetOrder(19))
		SZ8->(DbGoTop())
		if SZ8->(MsSeek(FWxfilial('SZ8')+cFilAnt+alltrim(TMP->NUMERO)))
			While SZ8->(!eof()) .and. SZ8->Z8_FILIAL = FWxfilial('SZ8') .and.;
			SZ8->Z8_FIL = cFilAnt .and.;
			SZ8->Z8_PALLET =  alltrim(TMP->NUMERO)

				if (!empty(SZ8->Z8_DATAS) .or. !empty(SZ8->Z8_HORAS) .or. !empty(SZ8->Z8_PRECAR) .or. !empty(SZ8->Z8_PREPED) .or. !empty(SZ8->Z8_ITEM)) .and. !(SZ8->Z8_MOTBAIX $ "COLETA/SEQUESTRO")
					SZ8->(DbSkip())
					loop
				endif

				reclock('TMP2',.t.)
				TMP2->CONTROL := SZ8->Z8_CONTROL
				TMP2->COD     := alltrim(SZ8->Z8_COD)
				TMP2->DESCRI  := alltrim(SZ8->Z8_DESCRI)
				TMP2->DATAP   := SZ8->Z8_DATAP
				TMP2->DATAV   := SZ8->Z8_DATAVAL
				msunlock()

				SZ8->(DbSkip())
			enddo
		endif

		TMP2->(DbGoTop())

		SZ8->(DbSetOrder(20))
		SZ8->(DbGoTop())

		if SZ8->(MsSeek(FWxfilial('SZ8')+cFilAnt+alltrim(_end)))
			While SZ8->(!eof()) .and. SZ8->Z8_FILIAL = FWxfilial('SZ8') .and.;
			SZ8->Z8_FIL = cFilAnt .and.;
			SZ8->Z8_LOCALIZ =  alltrim(_end)

				if (!empty(SZ8->Z8_DATAS) .or. !empty(SZ8->Z8_HORAS) .or. !empty(SZ8->Z8_PRECAR) .or. !empty(SZ8->Z8_PREPED) .or. !empty(SZ8->Z8_ITEM)) .and. !(SZ8->Z8_MOTBAIX $ "COLETA/SEQUESTRO")
					SZ8->(DbSkip())
					loop
				endif

				if !empty(SZ8->Z8_PALLET)
					SZ8->(DbSkip())
					loop
				endif

				reclock('TMP3',.t.)
				TMP3->CONTROL := SZ8->Z8_CONTROL
				TMP3->COD     := alltrim(SZ8->Z8_COD)
				TMP3->DESCRI  := alltrim(SZ8->Z8_DESCRI)
				TMP3->DATAP   := SZ8->Z8_DATAP
				TMP3->DATAV   := SZ8->Z8_DATAVAL
				msunlock()
				SZ8->(DbSkip())
			enddo
		endif

		TMP3->(DbGoTop())

		//Se for MP...
	elseif _cTipo = 'MP' //.and. TMP->TIPO = 'MP'
		ZAS->(DbSetOrder(6))
		ZAS->(DbGoTop())
		if ZAS->(MsSeek(FWxfilial('ZAS')+alltrim(TMP->NUMERO)))
			While ZAS->(!eof()) .and. ZAS->ZAS_FILIAL = FWxfilial('ZAS') .and.;
			ZAS->ZAS_PALLET =  alltrim(TMP->NUMERO)

				if (!empty(ZAS->ZAS_DATAS) .or. !empty(ZAS->ZAS_HORAS)) .and. !(ZAS->ZAS_MOTS $ "COLETA/SEQUESTRO")
					ZAS->(DbSkip())
					loop
				endif

				reclock('TMP2',.t.)
				TMP2->CONTROL := ZAS->ZAS_CONTRO
				TMP2->COD     := alltrim(ZAS->ZAS_COD)
				TMP2->DESCRI  := alltrim(ZAS->ZAS_DESC)
				TMP2->DATAP   := ZAS->ZAS_DTPROD
				TMP2->DATAV   := (ZAS->ZAS_DTPROD + ZAS->ZAS_VALID)
				msunlock()
				ZAS->(DbSkip())
			enddo
		endif

		TMP2->(DbGoTop())

		ZAS->(DbSetOrder(7))
		ZAS->(DbGoTop())

		if ZAS->(MsSeek(FWxfilial('ZAS')+alltrim(_end)))
			While ZAS->(!eof()) .and. ZAS->ZAS_FILIAL = FWxfilial('ZAS') .and.;
			ZAS->ZAS_LOCALI =  alltrim(_end)

				if (!empty(ZAS->ZAS_DATAS) .or. !empty(ZAS->ZAS_HORAS)) .and. !(ZAS->ZAS_MOTS $ "COLETA/SEQUESTRO")
					ZAS->(DbSkip())
					loop
				endif

				if !empty(ZAS->ZAS_PALLET)
					ZAS->(DbSkip())
					loop
				endif

				reclock('TMP3',.t.)
				TMP3->CONTROL := ZAS->ZAS_CONTRO
				TMP3->COD     := alltrim(ZAS->ZAS_COD)
				TMP3->DESCRI  := alltrim(ZAS->ZAS_DESC)
				TMP3->DATAP   := ZAS->ZAS_DTPROD
				TMP3->DATAV   := (ZAS->ZAS_DTPROD + ZAS->ZAS_VALID)
				msunlock()
				ZAS->(DbSkip())
			enddo
		endif

		TMP3->(DbGoTop())

	endif

	oBrow:oBrowse:refresh()
	oBrow2:oBrowse:refresh()
	oBrow3:oBrowse:refresh()

return

//Função para atualizar o browse
Static Function ClcBrow()

	HabBrow(2)

	//Se for PA...
	if _cTipo = 'PA' .and. TMP->TIPO = 'PA'
		SZ8->(DbSetOrder(19))
		SZ8->(DbGoTop())

		if SZ8->(MsSeek(FWxfilial('SZ8')+cFilAnt+alltrim(TMP->NUMERO)))
			While SZ8->(!eof()) .and. SZ8->Z8_FILIAL = FWxfilial('SZ8') .and.;
			SZ8->Z8_FIL = cFilAnt .and.;
			SZ8->Z8_PALLET =  alltrim(TMP->NUMERO)

				reclock('TMP2',.t.)
				TMP2->CONTROL := SZ8->Z8_CONTROL
				TMP2->COD     := alltrim(SZ8->Z8_COD)
				TMP2->DESCRI  := alltrim(SZ8->Z8_DESCRI)
				TMP2->DATAP   := SZ8->Z8_DATAP
				TMP2->DATAV   := SZ8->Z8_DATAVAL
				msunlock()
				SZ8->(DbSkip())
			enddo
		endif
		//Se for MP...
	elseif _cTipo = 'MP' .and. TMP->TIPO = 'MP'

		ZAS->(DbSetOrder(6))
		ZAS->(DbGoTop())

		if ZAS->(MsSeek(FWxfilial('ZAS') + alltrim(TMP->NUMERO)))
			While ZAS->(!eof()) .and. ZAS->ZAS_FILIAL = FWxfilial('ZAS') .and.;
			ZAS->ZAS_PALLET =  alltrim(TMP->NUMERO)

				reclock('TMP2',.t.)
				TMP2->CONTROL := ZAS->ZAS_CONTRO
				TMP2->COD     := alltrim(ZAS->ZAS_COD)
				TMP2->DESCRI  := alltrim(ZAS->ZAS_DESC)
				TMP2->DATAP   := ZAS->ZAS_DTPROD
				TMP2->DATAV   := (ZAS->ZAS_DTPROD + ZAS->ZAS_VALID)
				msunlock()
				ZAS->(DbSkip())
			enddo
		endif
	endif

	TMP2->(DbGoTop())

	oBrow:oBrowse:refresh()
	oBrow2:oBrowse:refresh()

return

User Function gjf144NL(_local)
	Local _nQtdApto   := 0
	Local _nQtdAptoM  := 0

	ZZH->(DbSetOrder(1))
	if ZZH->(MsSeek(FWxfilial('ZZH')+_local))
		while  ZZH->(!eof()) .and. ZZH->ZZH_FILIAL = FWxfilial('ZZH') .and. ZZH->ZZH_LOCAL = _local
			_nQtdApto := val(ZZH->ZZH_APTO)

			if  _nQtdApto > _nQtdAptoM
				_nQtdAptoM := _nQtdApto
			endif

			ZZH->(DbSkip())
		enddo

		ZZH->(DbSetOrder(1))
		ZZH->(MsSeek(FWxfilial('ZZH')+_local))

	endif

return _nQtdAptoM

//_nCont := Contar("ZZH","ZZH->ZZH_FILIAL = FWxfilial('ZZH') .and. ZZH_LOCAL = mv_par01 ")
//contar("SZP","SZP->ZP_FILIAL = FWxfilial('SZP') .and. SZP->ZP_LOCALIZ = '" + alltrim(_cPatch) + "'")

//	_nPal1 :=  contar("SZP","SZP->ZP_FILIAL = FWxfilial('SZP') .and. SZP->ZP_LOCALIZ = '" + alltrim(_DispEnd) + "'")
//	_nPal1 := contar("SZP","SZP->ZP_FILIAL = FWxfilial('SZP') .and. SZP->ZP_LOCALIZ = '" + alltrim(_DispEnd) + "'")

//	_nPal2 :=  contar("SZP","SZP->ZP_FILIAL = FWxfilial('SZP') .and. '" + substr(alltrim(_DispEnd),1,8) + "' $ SZP->ZP_LOCALIZ ")

//	_nPal3 := contar("SZP","SZP->ZP_FILIAL = FWxfilial('SZP') .and. '" + substr(alltrim(_cLocAnt),1,8) + "' $ SZP->ZP_LOCALIZ ")

Static Function Contagem(_cAlias,_regra)
	Local _nCont
	cQuery := " SELECT COUNT(*) AS CONTAGEM FROM " + REtSQLTab(_cAlias)
	cQuery += " WHERE " + RetSQLFil(_cAlias) + " AND " +  _regra + " AND "  +  RetSQLDel(_cAlias)

	cQuery := ChangeQuery(cQuery)

	If Select("CON") != 0
		CON->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "CON"

	_nCont := CON->CONTAGEM

return _nCont


Static Function ChamaBtn1()
	area := GetArea()
	u_gjf145()
	restarea(area)
	pergunte(cPerg1,.f.)
return

Static Function chamaBtn2()
	area := GetArea()
	u_GJF146()
	restarea(area)
	pergunte(cPerg1,.f.)
return
