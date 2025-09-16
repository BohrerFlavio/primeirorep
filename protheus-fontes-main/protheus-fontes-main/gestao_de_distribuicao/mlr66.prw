#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch" 
#INCLUDE "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR66     ºAutor  ³Mauricio Roehrs     º Data ³  12/02/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Fonte desenvolvido para apontamento da transportadora    º±±
±±º          ³   para um determinado carregamento                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function mlr66()


	Private cIPerg  	:= "MLR66"                       
	Private _lOk 	   := .f.

	if !pergunte(cIPerg,.t.)
		return
	endif


	Processa({|| _lOk := processar(mv_par01,mv_par02)} ,"PROCESSAMENTO DE REGISTROS","Definindo transportadora...")


	if _lOk
		msgbox('Processo finalizado com sucesso!','Processamento','INFO')
	else
		msgbox('Atenção, a nota já foi gerada, impossivel realizar o processo!','Processamento','STOP')
	endif

return

//C5_PRECAR,C5_TRANSP
Static Function processar(_cCar,_cTransp)

	_cQuery := " SELECT C5_NUM
	_cQuery += " FROM  " + retSqlTab('SC5')
	_cQuery += " WHERE " + retSqlFil('SC5') 
	_cQuery += " AND C5_PRECAR = '" + _cCar + "'"
	_cQuery += " AND " + retSqlDel('SC5') 
	_cQuery += " ORDER BY C5_NUM


	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

	_nRegs := contagem()

	ProcRegua(_nRegs)
	TMP->(dbGoTop())
	while TMP->(!eof())

		IncProc("Gravando registros...Pedido de venda: "+Alltrim(TMP->C5_NUM))

		SC5->(dbSetOrder(1))
		SC5->(dbGoTop())		
		if SC5->(dbSeek(xFilial('SC5') + TMP->C5_NUM))
			if !empty(SC5->C5_NOTA)				
				return .f.			   
			endif
			reclock('SC5',.f.)
			SC5->C5_TRANSP := _cTransp      	               
			msunlock()
		endif             

		TMP->(dbSkip())   
	enddo	

return .t.

static function contagem()

	local _nCont := 0   

	TMP->(dbGoTop())
	while TMP->(!eof())

		_nCont++

		TMP->(dbSkip())
	enddo

return _nCont
