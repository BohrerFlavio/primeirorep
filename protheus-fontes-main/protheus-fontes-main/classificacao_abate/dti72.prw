#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI72     ºAutor  ³Flávio º Data ³  25/10/18   			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de Validação de Caixa/Pallet do carregamento        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


/*
  Verificação de Status de Pré-Carregamentos e Pré-Pedidos
*/
User Function dti72st(_mod,_cPc)

Local _lRet 	:= .T.
Local _cStatC 	:= ''

	_cStatC := fBuscaCPO('ZZ3',2,xfilial('ZZ3')+_cPc,'ZZ3_STATUS')	
	ZZ4->(dbSeek(xFilial('ZZ4') + _cPc))	
	//alert(ZZ4->ZZ4_STATUS +' - '+ ZZ4->ZZ4_PRECAR +' - '+ ZZ4->ZZ4_NUM )
	
	do Case
		/* Verificação para Pré-Pedido e Pré-Carregamento
			E gravação do início do précarregamento*/
		Case _mod == 1			
			// A=Aberto;C=Carregando...;E=Encerrado;S=Espera;B=Bloqueado;F=Faturado  		
			if alltrim(_cStatC) $ "C|B|E|F" 
				msgbox('Status do Pré-Carregamento não permite esta operação!','OPERAÇÃO NEGADA!','STOP')
				return .f.
			Endif
			
			//  ----L=Liberado;C=Carregando...;E=Encerrado;S=Espera;B=Bloqueado;F=Faturado;I=Importado;P=Portal;R=Producao 
			If  alltrim(ZZ4->ZZ4_STATUS) $ 'C|E|B|F|I|P|R' //'L|S'
				msgbox('Status do Pré-Pedido não permite esta operação!','OPERAÇÃO NEGADA!','STOP')
				return .f.
			Endif
			//alert('Passou - 236')
			reclock('ZZ4',.f.)
				ZZ4->ZZ4_STATUS := 'C'
				ZZ4->ZZ4_LOCAR  := getComputerName()
			msunlock()
			
			ZZ3->(dbsetorder(2))
			if ZZ3->(dbseek(xfilial('ZZ3')+alltrim(ZZ4->ZZ4_PRECAR)))
				//alert('244-Carregamento- :'+ ZZ3->ZZ3_NUM)
				reclock('ZZ3',.f.)
				
				if ZZ3->ZZ3_STATUS = 'A'
					ZZ3->ZZ3_DTINI := dDataBase()
					ZZ3->ZZ3_HINI  := time()
				endif
				
				ZZ3->ZZ3_STATUS := 'C'
				ZZ3->ZZ3_LOCAR  := getComputerName()				
				
				msunlock()
	
			endif
			return .t.
			
		Return _lRet
		/* Rotina para liberar precarregamento e Pre pedido quando fecha  janela */ 
		Case _mod == 2
			
			reclock('ZZ4',.f.)
				ZZ4->ZZ4_STATUS := 'S'
				ZZ4->ZZ4_LOCAR := ' '
			msunlock()
			
			/* Continuar*/
			
		Return _lRet
			
		
	
	Endcase
	


Return _lRet


User Function dti72exc(_cPreC,_cZZ4ST,_cZZ3ST,_cZZ4NUM)

/* Variávies
_cPreC = ZZ4_PRECAR
 _cZZ4ST = Status
 _cZZ3ST = Status
 
*/
	Private aRotina  := {}
	Private cCadastro := ''
	Private cString := ''
	area := getarea()

	aObjects := {}                                                                
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()
		
	
	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	cCadastro := "Exclusão de Caixas do Pré-Carregamento: " + _cPreC
	aRotina := { { "Pesquisa", "AxPesqui"   , 0, 1},{ "Excluir" , "u_dti72e" , 0, 4}}

	cString := 'ZZ6'
	
	if _cZZ3ST <> 'S'
		msgbox('Status do Pré-Carregamento não permite essa operação!','OPERAÇÃO NEGADA!','STOP')
		return .f.
	elseif  _cZZ4ST <> 'S'
		msgbox('Status do Pré-Pedido não permite essa operação!','OPERAÇÃO NEGADA!','STOP')
		return .f.
	else
		u_gjf31his('Acesso Exclusão de Caixas')
	endif
	
	dbSelectArea(cString)
	ZZ6->(dbSetOrder(5))
	ZZ6->(dbgotop())
	
	cCondicao3 := "ZZ6_FILIAL = '" + xfilial('ZZ6') + "' AND ZZ6_PRECAR = '"+ _cPreC + "' AND ZZ6_PREPED = '" + _cZZ4NUM + "'"
	mBrowse(6,1,22,75,'ZZ6',,,,,,,,,,,,,,cCondicao3)
	u_gjf31his('Exclusao de Caixas.  Retorno tela Pre-Carregamentos')

	restarea(area)
	

Return .t.

/*Nova estratégia Deixar interface igual e só ajustar supostas rotinas com problema*/

User Function dti72v(_nMod,_cCaixa,_cPrePed,_cPreCar,_cCodcli,_cLojCli,_cTpOper,_cCL)
          
	Local _lCarPal  := GetMv('SI_CARPAL') //parametro que libera ou bloqueia o carregamento por pallet 
	Local _nNCaix 	:= 0
	Local _nPeso  	:= 0
	Local _nPesoBr  := 0
	Local _cProd 	:= ''
	Local _cItem	:= ''
	Local _cPriori	:= '' 
	Local _lVerit   := .f.
	Local _lItemA   := .f.
	Local _lItemEn  := .f.
	Local _lClass   := ''
	Local _cPallet	:= ''
	Local _lForaDt 	:= ''
	Local _cQrpeso 	:= 0
	Local _cQppeso  := 0
	Local _cQrCx 	:= 0 
	Local _cQpCx	:= 0
	Local _nTolera 	:= 0
	Local _nCod		:= '' 
	Local _cDescr 	:= ''
	Local _cLi 		:= 'N'
	Local _nPesCai	:= 0
	
	/* Validar se foi código da caixa */
	
			
	SZP->(DbSelectArea("SZP"))
	ZZ5->(DbSelectArea("ZZ5"))
	SZ8->(DbSelectArea("SZ8"))  
	SB1->(dbselectarea('SB1'))		
	s := .f.
	
	/* Validar se   for carregar ""Própria ou De terceiro ou Peça ""*/
	do case
		case _nMod = 1
		/*  Caixas Próprias */
			
			/* Laço para limpar mensagems da tela inicial de validação */
			if empty(_cCaixa)
				
					atbrow(_nCod)
					s := .t.
					return s
					
			endif
			
			/* Área de Busca de informações gerais */
				
			If 	substr(_cCaixa,1,2) <> 'PA'
				
				/* Função muito importante para quando o coletor ler só uma parte do código, então ela preenche com zeros a esquerda*/
				_cCaixa := padl(alltrim(_cCaixa),10,'0')
				
				/*		Validação da caixa		*/
				SZ8->(dbSelectArea("SZ8"))
				SZ8->(dbsetorder(3))
				SZ8->(DbGoTop())
						
				if empty(SZ8->(DbSeek(xfilial('SZ8') + _cCaixa)))
					
					mensER := 'CAIXA ' + _cCaixa +  ' INEXISTENTE!'
					mensOK := ' '
					oSayDesc1:SetText(mensOK)
					oSayDesc2:SetText(mensER)					
					oEnc:refresh()
					SomErr()
					return .f.
				endif
				
				SZ8->(DbSetOrder(3)) 
				SZ8->(DbSeek(xfilial('SZ8') + _cCaixa))
				_cProd  := alltrim(SZ8->Z8_COD )				
				
				
			Elseif substr(_cCaixa,1,2) = 'PA'
				
				/* Verificar se temos caixas no PALLET */
				SZP->(DbSetOrder(1))
				SZP->(DbSeek(xfilial('SZP') + _cCaixa))
				
				SZ8->(DbSetOrder(19)) 				
				if empty(SZ8->(DbSeek(xfilial('SZ8') + cFilAnt + _cCaixa)))
				
					SomErr()
					msgbox('Caixas não encontradas no Pallet!','OPERACAO INVALIDA!','STOP')
					return .f.
					
				endif
				
				_cProd  := alltrim(SZP->ZP_PRODUTO)	
							
			Endif
			
			/* Busca de informações do carregamento */
			ZZ5->(dbsetorder(2))
			ZZ5->(dbseek(xfilial('ZZ5')+_cPrePed+_cProd))
			if _cProd = alltrim(ZZ5->ZZ5_COD)
				_lVerit := .t.
				if ZZ5->ZZ5_STATUS = 'E'
					_lItemA := .t.
				else
					_lItemA := .f.
				endif
			endif
			
			
			_cItem 	 := alltrim(ZZ5->ZZ5_ITEM)
			_cPriori := alltrim(ZZ5->ZZ5_PRIORI)
			_cQrpeso := ZZ5->ZZ5_QRPESO
			_cQppeso := ZZ5->ZZ5_QPPESO
			_cQrCx 	 := ZZ5->ZZ5_QRCAIX     
			_cQpCx   := ZZ5->ZZ5_QPCAIX
			_nTolera := ZZ5->ZZ5_TOLERA
			_nCod	 := alltrim(ZZ5->ZZ5_COD)
			_cDescr	 := alltrim(ZZ5->ZZ5_DESC)
			
			/* Verificação de Ítens 
					 	Se já atendido ou inexistente já corta as verificações */
			if  _lItemA
					mensER := 'ITEM - '+_cItem+' Produto: '+_cProd+' DO PEDIDO JÁ ATENDIDO!'
					_cLi := 'S'
			elseif !_lVerit
					mensER := 'PRODUTO - '+ alltrim(SZ8->Z8_COD) +' INEXISTENTE NO PRE-PEDIDO!'
					_cLi := 'S'
			endif
			
			If _cLi = 'S'
			
				mensOK := ' '
				oSayDesc1:SetText(mensOK)
				oSayDesc2:SetText(mensER)
				oEnc:refresh()
				SomErr()
				return .f.
			
			Endif	

			if substr(_cCaixa,1,2) = 'PA'
				
				if !_lCarPal
				
					SomErr()
					msgbox('Operação de carregamento por pallet bloqueada!','OPERACAO INVALIDA!','STOP')
					return .f.
					
				endif	
				
				/* 	Esta busca não esta acontecendo 
					Mistério 		*/	
					
				//alert(SZP->(DbSeek(xfilial('SZP')+alltrim(_cCaixa))	))
				//alert(alltrim(_cCaixa))
				SZP->(DbSetOrder(1))
				if !(SZP->(DbSeek(xfilial('SZP') + alltrim(_cCaixa))))
				
					SomErr()
					msgbox('Pallet inexistente!','OPERACAO INVALIDA!','STOP')				
					return .f.
					
				Endif	
				
				/* Verificação se produto está Atendido ou encerrado */
				 
				if  !_lVerit
					SomErr()
					msgbox(' Produto: '+_cProd+' inexistente neste Pedido!','OPERAÇÃO INVALIDA!','STOP')
					return .f.
				elseif _lItemA
					SomErr()
					msgbox('Item - '+_cItem+' Produto: '+_cProd+' do pedido já atendido!','OPERAÇÃO INVALIDA!','STOP')
					return .f.
				endif
				
				if _lItemEn  // Tete quando item já todo atendido ?? a fazer
					SomErr()
					msgbox('Item- '+_cItem+'  do pedido '+_cPrePed+' já encerrado!','OPERAÇÃO INVALIDA!','STOP')
					return .f.
				endif
				
				/*  variáveis de soma dos pesos bruto e líquido das caixas do PALLET */
				_nPeso   := 0
				_nPesoBr := 0
				
				/*  Contagem das caixas no PALLET */
				
				
				SZ8->(DbGoTop())
				SZ8->(DbSetOrder(19)) 				
				SZ8->(DbSeek(xfilial('SZ8') + cFilAnt + _cCaixa))
				_nPesCai := SZ8->Z8_PESO
				While SZ8->(!eof()) .and. SZ8->Z8_FILIAL = xfilial('SZ8');
				 .and. 	SZ8->Z8_FIL = cFilAnt .and. alltrim(SZ8->Z8_PALLET) = _cCaixa

					_lClass  := VerClassif(alltrim(SZ8->Z8_CLASSIF),_cPrePed,_cCL)							
					_lForaDt := VerDtPr(_cPrePed,_cItem)
				
					/* verificaçãod a data de produção das caixas caso o parâmetro SI_VERPROD Esteja setado */ 
					
					if !empty(_lForaDt)
						
						/*  Retirado as janelinhas e abrir erro na interface
						
						SomErr2()
						msgbox('Caixa ( - '+SZ8->Z8_CONTROL+' - ) fora do int. de produção de datas definido!','OPERAÇÃO INVALIDA!','STOP')
						Return .t.
						
						*/
						mensER := 'Caixa ( - '+SZ8->Z8_CONTROL+' - ) fora do int. de produção de datas definido!'
						mensOK := ' '
						oSayDesc1:SetText(mensOK)
						oSayDesc2:SetText(mensER)					
						oEnc:refresh()
						oCar:refresh()                                               
						oBrow:oBrowse:refresh()
						
						SomErr2()
						return .f.
						
					endif
								
					/* Para caixas fora da data de Classificação estipulada o sistema não carrega o PALLET */			
					if  !empty(_lClass)					
						
						/*  Retirado as janelinhas e abrir erro na interface
						SomErr()
						msgbox('Caixa'+SZ8->Z8_CONTROL+' do carregamento de exportação sem habilitação/Cassificação!','HABILITAÇÃO!','STOP')				
						return .t.
						*/
						mensER := 'Cx: '+SZ8->Z8_CONTROL+' do carreg. de export. sem Cassificação!'
						mensOK := ' '
						oSayDesc1:SetText(mensOK)
						oSayDesc2:SetText(mensER)					
						oEnc:refresh()
						SomErr2()
						return .f.
						
					endif
					
					_nNCaix++
					_nPeso   += SZ8->Z8_PESO
					_nPesoBr += SZ8->Z8_PESOBR
					
					SZ8->(DbSkip())
				
				enddo
				
				
							
				ZZ5->(dbsetorder(2))
				ZZ5->(dbseek(xfilial('ZZ5')+_cPrePed+_cProd))
				do case
										
					case _cPriori = 'P'
					     /*   Primeira verificação se peso de tolerância foi atingido    */
						
						if _cQrpeso + _nPeso > (_cQppeso * (1 + (_nTolera * 0.01)))
							
							_lItemEn := .t.
							
							mensER := 'EXCEDEU PESAGEM PARA A CARGA!'
							mensOK := ' '
							oSayDesc1:SetText(mensOK)
							oSayDesc2:SetText(mensER)					
							oEnc:refresh()
							SomErr()
							return .f.
							
						Endif
						
						reclock('ZZ5',.f.)         
							ZZ5->ZZ5_QRPESO += _nPeso
							ZZ5->ZZ5_QRPESB += _nPesoBr
							ZZ5->ZZ5_QRCAIX += _nNCaix
						msunlock()
						CarC += _nNCaix
						
						/* Aqui preciso comparar com a ZZ5 */
						if ZZ5->ZZ5_QRPESO + _nPesCai >= (_cQppeso * (1 + (_nTolera * 0.01)))
							reclock('ZZ5',.f.)
								ZZ5->ZZ5_STATUS := 'E'
							msunlock()
							_lItemEn := .t.						
						endif
						
					case _cPriori = 'C'
						
						if (_cQrCx + _nNCaix) > (_cQpCx  * (1 + (ZZ5->ZZ5_TOLERA * 0.01)))
						
							mensER := 'Excedeu número de caixas para carga!'
							mensOK := ' '
							oSayDesc1:SetText(mensOK)
							oSayDesc2:SetText(mensER)					
							oEnc:refresh()
							SomErr()
							return .f.
							
						endif
						
						reclock('ZZ5',.f.)                                     //Caso a prioridade do carregamento seja por peso,...
							ZZ5->ZZ5_QRPESO += _nPeso
							ZZ5->ZZ5_QRPESB += _nPesoBr
							ZZ5->ZZ5_QRCAIX += _nNCaix
						msunlock()
						
						CarC += _nNCaix

						if ZZ5->ZZ5_QRCAIX >= (ZZ5->ZZ5_QPCAIX  * (1 + (ZZ5->ZZ5_TOLERA * 0.01)))
							reclock('ZZ5',.f.)
							ZZ5->ZZ5_STATUS := 'E'
							msunlock()
							_lItemEn := .t.
							
						endif
					
					case _cPriori = 'A'
						
						if (_cQrpeso + _nPeso > (_cQppeso * (1 + (_nTolera * 0.01)))) 
							
							//Verifica as quantidades do PP para encerra-lo
														
							mensER := 'Excedeu o Peso das caixas para carga!'
							mensOK := ' '
							oSayDesc1:SetText(mensOK)
							oSayDesc2:SetText(mensER)					
							oEnc:refresh()
							SomErr()	
							return .f.
							
						Endif
						If  (_cQrCx + _nNCaix > (_cQpCx  * (1 + (_nTolera * 0.01))))
						
							mensER := 'Excedeu número de caixas para esta Carga!'
							mensOK := ' '
							oSayDesc1:SetText(mensOK)
							oSayDesc2:SetText(mensER)					
							oEnc:refresh()
							SomErr()
							return .f.
							
						Endif
						/* Já pega antes , mas vou deixar por descargo*/
						if alltrim(ZZ5->ZZ5_STATUS) = 'E'
						
						 	SomErr()
							msgbox('Pesagem para este Ítem encerrada!','TOLERANCIA ULTRAPASSADA!','STOP')
							return .f.
							
						Endif
						 
						reclock('ZZ5',.f.)         
							ZZ5->ZZ5_QRPESO += _nPeso
							ZZ5->ZZ5_QRPESB += _nPesoBr
							ZZ5->ZZ5_QRCAIX += _nNCaix
						msunlock()
						CarC += _nNCaix
						
						/*  Após Gravar os registros do Pallet Acima  verificar */
						if (ZZ5->ZZ5_QRPESO + _nPesCai  >= (_cQppeso * (1 + (_nTolera * 0.01))))  .OR.  (ZZ5->ZZ5_QRCAIX +1 >= (_cQpCx  * (1 + (_nTolera * 0.01))))
							
							reclock('ZZ5',.f.)
								ZZ5->ZZ5_STATUS := 'E'
							msunlock()
							_lItemEn := .t.
							
						endif
					
				Endcase
				
				SZ8->(DbSetOrder(19))
				SZ8->(DbGotop())
				SZ8->(DbSeek(xfilial('SZ8') + cFilAnt + _cCaixa))
				While SZ8->(!eof()) .and. SZ8->Z8_FILIAL = xfilial('SZ8') .and. ;
				SZ8->Z8_FIL = cFilAnt .and.	SZ8->Z8_PALLET = _cCaixa
				
					/* Grava dados na SZ8 ZZ6 */					
					GrDados('C',SZ8->Z8_CONTROL ,_cPreCar,_cPrePed,_cItem,_cTpOper)
					/*  Parte do Picking - Somente para Santa Maria */ 
					
					Picking(_cPreCar,alltrim(SZ8->Z8_CARPICK),_cCaixa)
					u_gjf17his(2,'CARREG. PED. ' + _cPrePed,.f.,'','','000016',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)  //Grava histórico de carregamento da caixa
					/* Sistema inclui na ZAO os produtos e correlação com clientes 
					*/ 					
					u_AtuZAO(_cCodcli,_cLojCli,SZ8->Z8_NUMPREV,SZ8->Z8_COD,SZ8->Z8_DESCRI)
					
					SZ8->(DbSkip())
				Enddo
				
				/* Tratamento do Pallet */
				
				dt72PA(1,_cCaixa)
				
				atbrow(_nCod)
			
				execsom()
				mensER := space(1)                                           
				mensOK := ' PALLET ' + _cCaixa + ' CARREGADO!'
				oSayDesc1:SetText(mensOK)
				oSayDesc2:SetText(mensER)
				aCols := {}
				u_gjf31col2(1)
				
				
				return .f.
						
				
			Else
			/* Validar Caixas */
		
				/* Verificando se caixa está no estoque */
				
				if empty(SZ8->Z8_DATAS) .AND. empty(SZ8->Z8_HORAS)  
					
					/* Conforme contato com Lider Comercial (Rodrigo) - Reserva de caixas não esta mais sendo utilizada  
					 Dia 27/11/18 - Ajuste de retirada feito por Flávio
					if !ResCai(_cPrePed)
															
						mensER := 'Essa caixa está reservada ou item requer reserva!'
						mensOK := ' '
						oSayDesc1:SetText(mensOK)
						oSayDesc2:SetText(mensER)
						oEnc:refresh()
						SomErr()
						return .f.
						
					endif
					*/
					/*  VerClassif(alltrim(SZ8->Z8_CLASSIF),_cPrePed,_cCL)	 */
					_lClass := VerClassif(alltrim(SZ8->Z8_CLASSIF),_cPrePed,_cCL)
					
					if  !empty(_lClass)					
						/* Quando tiver uma caixa fora da data de Classificação estipulada o sistema não carrega o PALLET */
						
						mensER := 'Caixa'+SZ8->Z8_CONTROL+' do carregamento de exportação sem habilitação/Cassificação!'
						mensOK := ' '
						oSayDesc1:SetText(mensOK)
						oSayDesc2:SetText(mensER)
						oEnc:refresh()
						SomErr()
						return .f.
						
					endif
					
					_lForaDt := VerDtPr(_cPrePed,_cItem)
					
					if !empty(_lForaDt)
						
						/* Quando tiver uma caixa fora da data de produção estipulada o sistema não carrega o PALLET */
						SomErr2()					
						mensER := 'Caixa ( - '+SZ8->Z8_CONTROL+' - ) fora do int. de produção de datas definido!'
						mensOK := ' '
						oSayDesc1:SetText(mensOK)
						oSayDesc2:SetText(mensER)
						oEnc:refresh()						
						Return .f.
			
					Endif
					
					/* valida o picking somente para santa maria*/ 
					Picking(_cPreCar,alltrim(SZ8->Z8_CARPICK),_cCaixa)
					
					
					do case
						
						case _cPriori = 'P'
						
							if (_cQrpeso  > (_cQppeso * (1 + (_nTolera * 0.01))))
							
								reclock('ZZ5',.f.)
									ZZ5->ZZ5_STATUS := 'E'
								msunlock()	
				
								mensER := 'Excedeu pesagem deste Ítem para carga!'
								mensOK := ' '							
								oSayDesc1:SetText(mensOK)
								oSayDesc2:SetText(mensER)
								oEnc:refresh()
								_lItemEn := .t.
								SomErr()
								return .f.
		
							Endif
						
							reclock('ZZ5',.f.)                                    
								ZZ5->ZZ5_QRPESO += SZ8->Z8_PESO
								ZZ5->ZZ5_QRPESB += SZ8->Z8_PESOBR
								ZZ5->ZZ5_QRCAIX += 1
							msunlock()
							CarC++
				
							if ZZ5->ZZ5_QRPESO >= (_cQppeso * (1 + (_nTolera * 0.01)))
								
								reclock('ZZ5',.f.)
									ZZ5->ZZ5_STATUS := 'E'
								msunlock()
								_lItemEn := .t.
							
							endif							
							
						case _cPriori = 'A'
														
							if (_cQrpeso   >= (_cQppeso * (1 + (_nTolera * 0.01)))) 
							    
								mensER := 'Excedeu o Peso das caixas para carga!'
								mensOK := ' '							
								oSayDesc1:SetText(mensOK)
								oSayDesc2:SetText(mensER)
								oEnc:refresh()
								_lItemEn := .t.
								
								reclock('ZZ5',.f.)
									ZZ5->ZZ5_STATUS := 'E'
								msunlock()
								return .f.
							
							Endif
								
							If  (_cQrCx  >= (_cQpCx  * (1 + (_nTolera * 0.01))))
								
								mensER := 'Excedeu número de caixas para esta Carga!'
								mensOK := ' '							
								oSayDesc1:SetText(mensOK)
								oSayDesc2:SetText(mensER)
								oEnc:refresh()
								_lItemEn := .t.
								SomErr()
								
								reclock('ZZ5',.f.)
									ZZ5->ZZ5_STATUS := 'E'
								msunlock()
								
								return .f.
							
							Endif
							
							/* Já pega antes , mas vou deixar por descargo*/
							if alltrim(ZZ5->ZZ5_STATUS) = 'E'
							 	SomErr()
								msgbox('Pesagem para este Ítem encerrada!','TOLERANCIA ULTRAPASSADA!','STOP')
								
								return .f.
							Endif
							
							
							reclock('ZZ5',.f.)         
								ZZ5->ZZ5_QRPESO += SZ8->Z8_PESO
								ZZ5->ZZ5_QRPESB += SZ8->Z8_PESOBR
								ZZ5->ZZ5_QRCAIX += 1
							msunlock()
							CarC++
							
							if (ZZ5->ZZ5_QRPESB  >= (_cQppeso * (1 + (_nTolera * 0.01)))) .OR.  (ZZ5->ZZ5_QRCAIX   >= (_cQpCx  * (1 + (_nTolera * 0.01))))
							    
							    _lItemEn := .t.                          
								return .f.
							
							Endif
						
						
						case _cPriori = 'C'
							
							 
							if (_cQrCx )  >= (_cQpCx  * (1 + (_nTolera * 0.01)))
								
								mensER := 'Excedeu número de caixas para carga!'
								mensOK := ' '							
								oSayDesc1:SetText(mensOK)
								oSayDesc2:SetText(mensER)
								oEnc:refresh()
								SomErr()
								reclock('ZZ5',.f.)
									ZZ5->ZZ5_STATUS := 'E'
								msunlock()
								_lItemEn := .t.
								return .f.
							endif
							
							reclock('ZZ5',.f.)                                    
								ZZ5->ZZ5_QRPESO += SZ8->Z8_PESO
								ZZ5->ZZ5_QRPESB += SZ8->Z8_PESOBR
								ZZ5->ZZ5_QRCAIX += 1
							msunlock()
							CarC++
							
							if ZZ5->ZZ5_QRCAIX  >= (_cQpCx  * (1 + (_nTolera * 0.01)))
								
								reclock('ZZ5',.f.)
									ZZ5->ZZ5_STATUS := 'E'
								msunlock()
								_lItemEn := .t. 
								return .f.
							endif
							
					endcase
					
					/* Atualiza o Browser */
					atbrow(_nCod)
					
					_cPallet := SZ8->Z8_PALLET
					//alert(_cPallet)
					/* Grava dados na SZ8 ZZ6 */					
					GrDados('C',_cCaixa ,_cPreCar,_cPrePed,_cItem,_cTpOper)
					
					/* Grava movimentação de carregamento da caixa na SZV */				
					u_gjf17his(2,'CARREG. PED. ' + _cPrePed,.f.,'','','000016',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)         
					
					/* Atualiza a correlação de caixas plasticas x clientes na ZAO 
					Rever esta função
					*/
					u_AtuZAO(_cCodcli,_cLojCli,SZ8->Z8_NUMPREV,SZ8->Z8_COD,SZ8->Z8_DESCRI)
					
					execsom()
					mensER := space(1)                                           
					mensOK := ' CAIXA ' + _cCaixa + ' CARREGADA!'
					oSayDesc1:SetText(mensOK)
					oSayDesc2:SetText(mensER)
					
					aCols := {}
					u_gjf31col2(1)
					oCar:refresh()                                               
					oEnc:refresh()
					oBrow:oBrowse:refresh()
					
					if  _lItemEn
						execsom()                                               
						msgbox('Item '+_cItem + ' ('+_cDescr+') do pedido '+ _cPrePed +;
							' atendido!','ATENÇÃO','INFO')
					endif
					
					/* Verificação do Pallet, se ficou vazio deleta.
					Caso PALLET tenha ficado com alguma caixa não faz nada*/
					
					dt72PA(2,_cPallet)
					
					return .f.
				/*  Aviso de caixa carregada */
				else
				
					mensER := 'CAIXA ' + _cCaixa +  ' JÁ CARREGADA EM: ' + alltrim(SZ8->Z8_PRECAR)+' - Pré-Pedido : '+ alltrim(SZ8->Z8_PREPED)
					mensOK := ' '
					
					oSayDesc1:SetText(mensOK)
					oSayDesc2:SetText(mensER)
					oEnc:refresh()
					SomErr()
					return .f.
					
				Endif
				
				
			Endif
			
			
		case _nMod = 2
		/* _nMod=2  -  Caixas Terceiros 
		Ainda estã na rotina antiga (Fonte - GJF31)
		Continuar...*/
		
			
		
							
		case _nMod = 3
		/* _nMod=3  -  Peças 
		Ainda estã na rotina antiga (Fonte - GJF31)
		Continuar....*/
		
	
	Endcase		
				
Return s


/* Grupo de regras para determinar a classificação da caixa e verificar se fecha com a classificação de caixas para o  carregamento */
Static Function VerClassif(_cC,_cPP,_cZZ4Cla)
	
	Local _lClas := '' // Equivala ao terno
	/*
	_cC = CClassificação da Caixa
	_cPP = Nr do Pré-Pedido 
	_cZZ4Cla = Classificação vinda da ZZ4
	*/
	
	if empty(_cZZ4Cla)
		
		_lClas := ''				
		return _lClas
	endif

	if (AllTrim(_cZZ4Cla) $ 'RT/RU/HK') .and. empty(_cC)      // $ esta contido
	
		_lClas := 'Caixa Sem Classificacao, não pode ser Carregada'
		return _lClas
		
	endif

	Do Case
		case AllTrim(_cZZ4Cla) = 'RT'
			if AllTrim(_cC) = 'RT'
			
				_lClas := ''
				
			endif
		case AllTrim(_cZZ4Cla) = 'RU'
			if AllTrim(_cC) $ 'RT/RU'
			
				_lClas := ''
				
			endif
		case AllTrim(_cZZ4Cla) = 'HK'
			if AllTrim(_cC) $ 'RT/RU/HK'
			
				_lClas := ''
				
			endif
		otherwise
	
		_lClas := 'Caixas com classificação Diferente da Classificação do Carregamento, Não pode ser carregada'
	endcase
	
Return  _lClas

Static Function VerDtPr(_cPP,_cIt)
	
	ret  := ''
	
	if GetMV('SI_VERPROD')
		//Verifica se o usuário setou no item do pre-pedido
		//para que seja feita a verificação
		if !empty(ZZ5->ZZ5_DTPINI) .and. !empty(ZZ5->ZZ5_DTPFIM)
			if  (SZ8->Z8_DATAP < ZZ5->ZZ5_DTPINI .OR. SZ8->Z8_DATAP > ZZ5->ZZ5_DTPFIM)
				ret := 'Dta Fora Intervalo'
			endif
		endif
	endif
	
Return ret

Static Function atbrow(_cC)


	If !empty(alltrim(_cC))
		
		DbSelectArea('TMP')
		TMP->(DbGoTop())
		while TMP->(!eof())
			if alltrim(TMP->COD) = alltrim(_cC)
				TMP->CREAL := ZZ5->ZZ5_QRCAIX
				TMP->PREAL := ZZ5->ZZ5_QRPESO
			endif
			TMP->(DbSkip())
		enddo
		
		TMP->(DbGoTop())
		
	endif
	//alert('1492')
	mensER := ' '
	mensOK := ' '							
	oSayDesc1:SetText(mensOK)
	oSayDesc2:SetText(mensER)
	oEnc:refresh()
	oCar:refresh()                                               
	oBrow:oBrowse:refresh()

return
		
		
Static Function GrDados(_nTipo,_cCx,_cPcar,_cPPed,_cIt,_cTpOp)

/* Variável " _nTipo" criada para diferenciar quando é 
peso
Automático
caixa
 _cCx = Caixa / PALLET
 _cPcar = Pré-Carregamento
 _cPPed = Pré-èdido
 _cIt	= Ítem

*/
	//alert('965 - '+_cTpOp)
	
	If _nTipo = 'C'
		
		SZ8->(DbSelectArea("SZ8")) 
		SZ8->(DbSetOrder(3)) 
		SZ8->(DbSeek(xfilial('SZ8') + alltrim(_cCx)))
		
		reclock('SZ8',.f.)
		SZ8->Z8_DATAS   := date()                                        
		SZ8->Z8_HORAS   := time()                                       
		SZ8->Z8_PREPED  := _cPPed
		SZ8->Z8_ITEM    := _cIt
		SZ8->Z8_PRECAR  := _cPcar
		SZ8->Z8_PALLET  := ''                                           
		SZ8->Z8_LOCALIZ := ''                                           
		SZ8->Z8_LOCAL   := ''                                          
		SZ8->Z8_TPROC   := '0'
		SZ8->Z8_DEST    := 'E'
		
		if _cTpOp = 'T'
				
				SZ8->Z8_DTRANSF := date()
			
		endif
		msunlock()
		
		if _cTpOp = 'T'
			u_GJF134(1,_cCx,'S',date(),SZ8->Z8_COD,SZ8->Z8_PESO,_cPcar,cFilAnt,_cPPed,_cIt,SZ8->Z8_DATA,'')
		endif
		/* Tabela para a Interface */
	
		reclock('ZZ6',.t.)
			ZZ6->ZZ6_CONTRO := SZ8->Z8_CONTROL
			ZZ6->ZZ6_COD    := SZ8->Z8_COD
			ZZ6->ZZ6_PREPED := _cPPed
			ZZ6->ZZ6_ITEM   := _cIt
			ZZ6->ZZ6_PRECAR := _cPcar
			ZZ6->ZZ6_PESO   := SZ8->Z8_PESO
			ZZ6->ZZ6_PESOBR := SZ8->Z8_PESOBR
			ZZ6->ZZ6_TARA   := SZ8->Z8_TARA
			ZZ6->ZZ6_QUANT  := SZ8->Z8_QUANT                                       //Grava data do carregamento
			ZZ6->ZZ6_DATAS  := date()                                        //Grava hora do carregamento
			ZZ6->ZZ6_HORAS  := time()
			ZZ6->ZZ6_DESCRI := SZ8->Z8_DESCRI                                     //Grava numero e item do PP na caixa
			ZZ6->ZZ6_FILIAL := cFilAnt
		msunlock()
		
		//Alert('966 - Passou verificar ')
		//Return .f.
		
	Endif	
		
	
	
Return		
		

/* Funçao para exclusão de pallet caso não tenha mais caixas */ 
Static Function dt72PA(_nT,_Pallet)
	
	if !empty(_Pallet)
		
		SZP->(DbSetOrder(1))
		if SZP->(DbSeek(xfilial('SZP')+_Pallet))
			/*  */
			if _nT = 2
				do case
					case SZP->ZP_TIPO == 'PA'
						SZ8->(DbSetOrder(19))
						SZ8->(DbGoTop())
						if !SZ8->(DbSeek(xfilial('SZ8') + cFilAnt + SZP->ZP_COD))
							reclock('SZP',.f.)
							DbDelete()
							msunlock()
						endif
					case SZP->ZP_TIPO == 'MP'
						ZAS->(DbSetOrder(6))
						ZAS->(DbGoTop())
						if !ZAS->(DbSeek(xFilial('ZAS') + SZP->ZP_COD))
							reclock('SZP',.f.)
							dbDelete()
							msunlock()
						endif
				endcase
			
			Elseif _nT = 1
			
				RecLock('SZP',.f.)
					SZP->(DbDelete())
				MsUnlock()
				
			Endif
		
		endif
		
	endif

return		
		
Static Function ResCai(_cPP)
	_ret := .f.
	/* Se caixa estiver reservada só deve ser carregar no Pré-pedido que ela foi reservada  */
	if !empty(SZ8->Z8_RESERVA)                                
		if  SZ8->Z8_RESERVA = _cPP
			_ret := .t.
		else
			/* Se for False não vai deixar carregar a caixa acusando o aviso*/
			_ret := .f.
		endif
	elseif empty(SZ8->Z8_RESERVA) .and. ZZ5->ZZ5_RESERV = 'S'  //Se a caixa não estiver reservada e for obrigatoria a reserva no item...
		/* Se for False não vai deixar carregar a caixa acusando o aviso*/
		_ret := .f.
	elseif empty(SZ8->Z8_RESERVA) .and. ZZ5->ZZ5_RESERV = 'N'  //Se a caixa não for reservada e não for obrigatoria a reserva no item...
		_ret := .t.
	endif
	
return _ret		
		
Static Function Picking(_cPC,_cZ8CP,_cCai)

/*
Parte do Picking somente para santa maria  - Autor Maurício 
Dia 20/11/18 - Alterado por Flávio para colocar em uma função separada
	
	Variáveis
_cPC = Pré-Carregamento
_cZ8CP = Informação do campo Z8_CARPICK
*/
	if cFilAnt == '00'
		if substr(_cCai,1,2) = 'PA'
			/*  Se PALLET */
			
				if empty(_cZ8CP) //verifica se a caixa foi separada
					//SomErr()
					//msgbox('Caixas do pallet nao foram separadas para carregamento!','SEPARAÇÃO DE CAIXAS!','STOP')
					u_gjf17his(4,'TENTATIVA DE CARREGAMENTO DO PALLET '+ _cCai +' NAO SEPARADO, CARREG: ' + _cPC,.f.,'','','000014',,,,SZ8->Z8_PALLET)
					//return .f.
				elseif !empty(_cZ8CP) //caso a caixa tenha sido separada
					/*verifica se foi separada para o carregamento em questão*/
					if _cPC <> _cZ8CP 
						//SomErr()
						//msgbox('Caixas do pallet foram separadas para outro carregamento!','SEPARAÇÃO DE CAIXAS!','STOP')
						u_gjf17his(4,'TENTATIVA DE CARREGAMENTO DO PALLET '+ _cCai +' JA SEPARADO PARA OUTRO CARREG: ' + _cPC,.f.,'','','000015',,,,SZ8->Z8_PALLET)
						//return .f.
					endif
				endif
			
		Else
				/*  Se Caixa */
				if empty(_cZ8CP)//verifica se a caixa foi separada
					//SomErr()
					//msgbox('Caixa nao foi separada para carregamento!','SEPARAÇÃO DE CAIXAS!','STOP')
					u_gjf17his(4,'TENTATIVA DE CARREGAMENTO DE CX NAO SEPARADA, CARREG: ' + _cPC,.f.,'','','000017',SZ8->Z8_CONTROL)
					//return .f.
				elseif !empty(_cZ8CP) //caso a caixa tenha sido separada
					if _cPC <> _cZ8CP //verifica se foi separada para o carregamento em questão
						//SomErr()
						//msgbox('Caixa foi separada para outro carregamento!','SEPARAÇÃO DE CAIXAS!','STOP')
						u_gjf17his(4,'TENTATIVA DE CARREGAMENTO DE CX JA SEPARADA P OUTRO CARREG: ' + _cPC,.f.,'','','000018',SZ8->Z8_CONTROL)
						//return .f.
					endif
				endif
		
		Endif
		
	Endif


Return

User Function dti72e()


	if APMsgNOYES('Confirma exclusão de caixa? Mesmo','EXCLUSAO')
	
		SZ8->(dbsetorder(3))
		if SZ8->(dbseek(xfilial('SZ8')+ZZ6->ZZ6_CONTRO)) .and. SZ8->Z8_FIL = ZZ6->ZZ6_FILIAL
			
			ZZ5->(dbsetorder(1))
			if ZZ5->(dbseek(xfilial('ZZ5')+alltrim(SZ8->Z8_PREPED+SZ8->Z8_ITEM)))
				
				reclock('ZZ5',.f.)
				ZZ5->ZZ5_QRCAIX := ZZ5->ZZ5_QRCAIX - 1
				ZZ5->ZZ5_QRPESO := ZZ5->ZZ5_QRPESO - SZ8->Z8_PESO
				ZZ5->ZZ5_QRPESB := ZZ5->ZZ5_QRPESB - SZ8->Z8_PESOBR
				ZZ5->ZZ5_STATUS := ''
				msunlock()
			else
				alert('Item de Pré-pedido não localizado!...verifique com o comercial !')
				return
			endif
			
			u_GJF134(2,alltrim(SZ8->Z8_CONTROL),'E',DDATABASE,SZ8->Z8_PESO,alltrim(SZ8->Z8_PRECAR),alltrim(SZ8->Z8_FIL),alltrim(SZ8->Z8_PREPED),alltrim(SZ8->Z8_ITEM),SZ8->Z8_DATA,'')
			u_gjf17his(1,'EXCL. PED. ' + ZZ5->ZZ5_NUM,.f.,'','','000013',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
			u_gjf17his(4,'CAIXA SEPARADA E EXCLUIDA DO PEDIDO: ' + ZZ5->ZZ5_NUM,.f.,'','','000019',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
			
			reclock('SZ8',.f.)
			SZ8->Z8_PREPED  := ''
			SZ8->Z8_ITEM    := ''
			SZ8->Z8_PRECAR  := ''
			SZ8->Z8_DATAS   := STOD('')
			SZ8->Z8_HORAS   := ''
			SZ8->Z8_DEST    := ''
			SZ8->Z8_PICKING := ''
			SZ8->Z8_CARPICK := ''
			if ZZ4->ZZ4_TPOPER = 'T'
				SZ8->Z8_DTRANSF:= STOD('')
			endif
			msunlock()

			reclock('ZZ6',.f.)
			dbdelete()
			msunlock()
			
			
		Endif
	
	Endif

Return .t.


				
User Function dti72epp(_cPreP,_cZ4ST,_cZ4CC,_cZ4Loj,_cPreC)

/* Variáveis

_cPreP = ZZ4_NUM = Pre-Pedido 
_cZ4ST = ZZ4_STATUS 
_cZ4CC =  ZZ4_CODCLI
_cZ4Loj =  ZZ4_LOJA
_cPreC =  ZZ4_PRECAR = Pre-Carregamento 

*/

Local _lFal := .f.

	

	if _cZ4ST = 'C' .or. _cZ4ST = 'F' .or. _cZ4ST = 'E'
		
		SomErr2()
		msgbox('Status não permite essa operação!','OPERAÇÃO IRREGULAR','ERRO')
		
		return .f.
	endif	
	
	ZZ5->(dbsetorder(1))
	if ZZ5->(dbseek(xfilial('ZZ5')+_cPreP))
		While ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = xfilial('ZZ5') .and. ZZ5->ZZ5_NUM = _cPreP
			if ZZ5->ZZ5_STATUS != 'E'
				_lFal := .t.
			endif
			ZZ5->(dbskip())
		enddo
	endif
	
	if _lFal
		
		SomErr()
		if !msgbox('Pedido ' + alltrim(_cPreP) + ' será encerrado com falta! Continuar?','ATENÇÃO','YESNO')
			Return
		else
			
			//Alert('Pre-Pedido:'+_cPreP+' ZZ4 STATUS: '+_cZ4ST+' Cliente: '+_cZ4CC+' Loja: '+_cZ4Loj+'Pré Carregamento:'+_cPreC)
			u_gjf31wfw(_cPreP,_cZ4CC,_cZ4Loj,_cPreC)
		endif
	endif
	
	/*  Conforme contato com Lider Comercial (Rodrigo) - Reserva de caixas não esta mais sendo utilizada  
		Dia 27/11/18 - Ajuste de retirada feito por Flávio 
		
		u_gjf28CRes(_cPreP)
	*/
	reclock('ZZ4',.f.)
	ZZ4->ZZ4_DTFIM  := date()
	ZZ4->ZZ4_HFIM   := time()
	ZZ4->ZZ4_STATUS := 'E'
	msunlock()
	
	if _lFal
		u_gjf31his('Pre-pedido ' + alltrim(_cPreP) + ' encerrado com falta','')
	else
		u_gjf31his('Pre-pedido ' + alltrim(_cPreP) + ' encerrado','')
	endif

	msgbox('Pedido encerrado com sucesso!','OPERAÇÃO REALIZADA','INFO')

	If Select("ZZ5")<>0
		ZZ5->(dbCloseArea())
	Endif

Return 



Static Function SomErr
	WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0)
return

Static Function SomErr2
	WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEEDT.WAV',0)
return
