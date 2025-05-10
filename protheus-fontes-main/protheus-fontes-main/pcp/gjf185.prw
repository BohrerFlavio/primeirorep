#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"   
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF185    ºAutor  ³Giuliano Forgiarini º Data ³  29/01/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de encerramento automatico das previsões de produção º±±
±±º          ³do setor de embalagem                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PCP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF185()

LOCAL nOpca	       :=0
LOCAL aSays        :={}, aButtons:={}
Private cCadastro  := "Encerramento automatico das previsões de produção - embalagem"   
Private _dUlMes    := GetMv('MV_ULMES')
Private _aLog      := {} 
Private _aSZU      := {}
Private _cLog      := ''

cPerg := "GJF185"
Pergunte(cPerg,.f.)
AADD (aSays, "  Este programa tem como objetivo realizar automaticamente o   ")  //
AADD (aSays, "  encerramento das previsões de produção do setor de embalagem ")  //
AADD (aSays, "  e efetivar requisições de embalagens para baixa automatica   ")
AADD (aSays, "  do seu saldo mediante os parametros apontados.               ")  //

AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. ) } } )

FormBatch( cCadastro, aSays, aButtons )

If nopca == 1                                                                                                                  
	Processa({||ProcSZU() },"FECHAMENTO DE PRODUÇÃO","Selecionando produção..." )     	       
	Processa({||Processar() },"FECHAMENTO DE PRODUÇÃO","Realizando processamento..." )                             

MostraLog(_aLog)
	
Endif
Return

//Função destinada ao fechamento da produção
//com realização da movimentação interna - requisição 
//ao almoxarifado das embalagens
Static Function Processar()
local i := 1
Local _lConfOper := .t.
Local _aGer      := {}

//	aadd(_aSZU,{SZU->ZU_NUM,SZU->ZU_QRCAIX,SZU->ZU_DTRPRO})
_Cont := len(_aSZU)

ProcRegua(_Cont) 

for i := 1 to _Cont

	incproc('Processando Previsão de Produção número: ' + _aSZU[i,1])
		
	ZAN->(DbSetOrder(1))
	ZAN->(DbGoTop())
	if ZAN->(DbSeek(xfilial('ZAN')+_aSZU[i,1]))
		lConfOper := .t.	
		while ZAN->(!eof()) .and. ZAN->ZAN_FILIAL = xfilial('ZAN') .and. ZAN->ZAN_PREEMB = _aSZU[i,1]			 
			//Verifica se existe baixa em aberto
			if ZAN->ZAN_OK <> 'S' .And. _aSZU[i,2] <> 0
				//Verifica se existe saldo para seguir adiante
				if VerSB2(ZAN->ZAN_COD,_aSZU[i,2])
					//Faz a movimentação interna de requisição retornando .T. se realizada ou .F. se não realizada      
					                 //Produto    //Quant    //Data    //Num pre-emb.
					_aGer := GeraMov(ZAN->ZAN_COD,_aSZU[i,2],_aSZU[i,3],_aSZU[i,1])        		
					_lConfOper := _aGer[1,2]  
				else
					_aGer := {{'',.f.}}
					_cLog := "Sem Saldo SB2'
					_lConfOper := .f.
				endif
			else
				_aGer := {{'',.f.}}
				_cLog := "Encerrada ZAN'
				_lConfOper := .f.
			endif			
			
			//Se a operação de movimentação foi realizada, dá Ok no bagulho.
			if _lConfOper
				reclock('ZAN',.f.)
				ZAN->ZAN_DOC   := _aGer[1,1]
				ZAN->ZAN_OK    := 'S'  
				ZAN->ZAN_QUANT := _aSZU[i,2]
				msunlock()
				/*
				reclock('SZU',.f.)
				SZU->ZU_FECHADO := 'S'
				msunlock()
				 */
				_cLog := "Operacao realizada'
			endif
			ZAN->(DbSkip())
		enddo 
		
	else
		_aGer := {{'',.f.}}
		_cLog := "Opa!'
		_lConfOper := .f.
	endif
	
	//Vetor de log de ocorrencia
	
	AADD(_aLog,{_lConfOper,_aSZU[i,1],iif(_lConfOper,'OK','FA'),_aGer[1,1],_cLog})

next

return


//Função que seleciona os registros da SZU
Static Function ProcSZU()

Local _lConfOper := .t.
Local _aGer      := {}   
Local _CodEmb    := ''  
Local _CodGrp    := ''

SZU->(DbSetOrder(1))
SZU->(DbGoTop())
SZU->(DbSeek(xfilial('SZU')+dtos(mv_par01),.t.))

_Cont := Contagem()

ProcRegua(_Cont) 

while  SZU->(!eof()) .and. SZU->ZU_FILIAL = xfilial('SZU') .and. SZU->ZU_DTRPRO <= mv_par02

	incproc('Selecionando Previsão de Produção número: ' + SZU->ZU_NUM)
	
	//Verifica se o mes tá aberto (MV_ULMES)
	if _dUlMes > SZU->ZU_DTRPRO
		//Vetor de log de ocorrencia
		_cLog := 'Mes fechado (MV_ULMES)'
		AADD(_aLog,{.f.,SZU->ZU_NUM,'FA','',_cLog})
		SZU->(DbSkip())
		Loop
	endif	 
	
	_CodEmb := fBuscaCPO('ZAN',1,xfilial('ZAN')+SZU->ZU_NUM,'ZAN_COD')     	
	DbSelectArea('SB1')	 
	_CodGrp := fBuscaCPO('SB1',1,xfilial('SB1')+_CodEmb,'B1_GRUPO')      
	
	if _CodGrp = '1202'
		//Vetor de log de ocorrencia
		_cLog := 'Prod. Caixas plásticas'
		AADD(_aLog,{.f.,SZU->ZU_NUM,'FA','',_cLog})
		SZU->(DbSkip())
		Loop	
	endif
	
	aadd(_aSZU,{SZU->ZU_NUM,SZU->ZU_QRCAIX,SZU->ZU_DTRPRO})
	SZU->(DbSkip())      
enddo

return

Static Function Contagem()
Local _nTotal := 0

_cQuery := "SELECT COUNT(*) AS TOT "
_cquery += "FROM " + RetSQLTab("SZU") 
_cQuery += "WHERE " 
_cQuery += RetSQLFil('SZU') + " AND ZU_DTRPRO BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "' AND " + RetSQLDel('SZU')

_cQuery  := ChangeQuery(_cQuery)

//	* Mostrar a consulta */
//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
//Activate Dialog oDlgMemo

If Select("CONT") != 0
	CONT->(dbCloseArea())
Endif

TCQUERY _cQuery NEW ALIAS "CONT"

_nTotal := CONT->TOT

return  _nTotal

//Função que faz uma breve verificação no saldo da SB2
Static Function VerSB2(_cod,_quant)                              
Local _ret := .t.

 SB2->(DbSetOrder(1))
 SB2->(DbGotop())

if SB2->(DbSeek(xfilial('SB2')+padr(alltrim(_cod),15,' ')+ '02'))
    if SB2->B2_QATU < _quant
       _ret := .f.
    endif         
else
 	_ret := .f.
endif
                             
return _ret


//Função para geração das requisições de embalagem ao almoxarifado
Static Function GeraMov(_cProd,_nQuant,_dData)    

Local _aRet    := {}
Local _cCorOri := ''
Local _cFarm   := ''
Local _cCC     := ''       

DbSelectArea('SB1')
_cCorOri := fBuscaCPO('SB1',1,xfilial('SB1')+_cProd,'B1_CORORI')
_cFarm   := fBuscaCPO('SB1',1,xfilial('SB1')+_cProd,'B1_FARM') 

if _cCorOri = 'M'
   _cCC := '1131010' //Miudos
elseif _cCorOri <> 'M' .and. _cFarm = 'S'
    _cCC := '1131009' //Charque
else
   _cCC := '1131006' //Embalagem
endif

lMsErroAuto := .f.

_cNumDoc := NextNumero("SD3",2,"D3_DOC",.T.)  

aMata240 :={{"D3_FILIAL",xfilial('SD3'),NIL},;
				{"D3_TM"      ,'502'       ,NIL},;
				{"D3_LOCAL"   ,'02'        ,NIL},;
				{"D3_COD"     ,_cProd      ,NIL},;
				{"D3_QUANT"   ,_nQuant     ,NIL},;
				{"D3_EMISSAO" ,_dData      ,NIL},;
				{"D3_PRDNUM"  ,'XXXXXX'    ,NIL},;
				{"D3_DOC"     ,_cNumDoc    ,NIL},;
				{"D3_UM"      ,'UN'        ,NIL},;
				{"D3_SEGUM"   ,'MI'        ,NIL},;
				{"D3_CC"      ,_cCC        ,NIL},;
				{"D3_PRDITEM" ,'XX'        ,NIL} }

DbSelectArea("SD3")
Begin Transaction

msExecAuto({|x,Y| Mata240(x,Y)},aMata240,3)  

If lMsErroAuto
//  	MostraErro()
	DisarmTransaction()
EndIf	    
	
End Transaction

AADD(_aRet,{iif(lMsErroAuto,'',_cNumdoc),.t.}) 
	
return _aRet



//Função para visualizar log de eventos
Static Function MostraLog(_aLog) 
Local i      := 0
Local cTexto := ''

if (len(_aLog)>0)

	for i := 1 to len(_aLog)
	 cTexto += _aLog[i,2] + '  ' + _aLog[i,3] + '  ' + _aLog[i,4] + '  ' + _aLog[i,5] + chr(13) + chr(10)  
	next

else
   cTexto := 'Sem processamento realizado!'
endif
@ 116,090 To 416,707 Dialog oDlgMemo Title "Histórico"
@ 055,005 Get cTexto Size 250,080 MEMO Object oMemo
Activate Dialog oDlgMemo CENTERED

return            


/* BLOCO REMOVIDO POR MAURICIO ROEHRS, A PEDIDO DO MATHEUS SILVA, DIA 27/05/2013
Static Function WorkFlow(_Cod,_Placa,_PesoE,_Tara,_Oper)
	_cMens := 'Esta é uma mensagem automática do sistema. Por favor não responda!' + chr(13) + chr(10)
	_cMens += 'Na data e hora da emissão deste email, houve tentativa de pesagem do caminhão abaixo:' + chr(13) + chr(10)
	_cMens +=   chr(13) + chr(10)                                    
	_cMens += 'Codigo Pesagem:' + alltrim(_Cod) + chr(13) + chr(10)
	_cMens += 'Placa Vaiculo: ' + alltrim(_Placa) + chr(13) + chr(10)
	_cMens += 'Tara Veículo:  ' + transform(_Tara,'@E 999,999.99') + chr(13) + chr(10)
	_cMens += 'Peso Veículo:  ' + transform(_PesoE,'@E 999,999.99') + chr(13) + chr(10)
	_cMens += 'Responsável:   ' + _Oper + chr(13) + chr(10)
	_cTit  := 'Workflow Frigorífico Silva: Aviso de pesagem inconsistente: Veiculo placa ' + _Placa
	
   _cDest := 'matheus@bestbeef.com.br'
	
	_aEmail := u_GJF54(_cMens,_cTit,_cDest)
	
	for i := 1 to len(_aEmail)
		if !_aEmail[i]
			alert('ERRO WORKFLOW ('+ str(i) +')')
		endif
	next
return                                                                                                                  
*/
