#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF134    º Autor ³Giuliano Forgiarini º Data ³  13/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função para registrar na tabela ZAE (movimentações de      º±±
±±º          ³ tranferencias) a movimentação das caixas                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF134(_oper,_caixa,_movim,_datam,_cod,_peso,_precar,_filial,_preped,_item,_data,_FilDes)

	DbSelectArea('ZAE') 
	DbSetOrder(3)

	if _oper = 1
		
		if !DbSeek(xfilial('ZAE')+_filial+_precar+_preped+_item+_movim+_caixa)
			reclock('ZAE',.t.)
			ZAE->ZAE_DATA    := _data
			ZAE->ZAE_DATAM   := _datam
			ZAE->ZAE_MOVIM   := _movim
			ZAE->ZAE_CONTRO  := _caixa
			ZAE->ZAE_FIL     := _filial
			ZAE->ZAE_COD     := _cod
			ZAE->ZAE_PESO    := _peso
			ZAE->ZAE_PRECAR  := _precar
			ZAE->ZAE_PREPED  := _preped
			ZAE->ZAE_ITEM    := _item
			ZAE->ZAE_FILDES  := _FilDes
			msunlock()
		endif
	else
		
		ZAE->(DbSetOrder(1))
		if ZAE->(DbSeek(xfilial('ZAE') + dtos(_datam) + _caixa + _movim + _precar + _filial))
			reclock('ZAE',.f.)
			DbDelete()
			msunlock()
		endif
	endif

	ZAE->(DbCloseArea())

Return 

User Function GJF134B()
	ZAE->(DbSetOrder(1))   
	ZAE->(DbGoTop())
	while ZAE->(!eof())
		SZ8->(DbSetOrder(3))
		if SZ8->(DbSeek(xfilial('SZ8')+ZAE->ZAE_CONTRO))
			reclock('SZ8',.f.)
			SZ8->Z8_DTRANSF := ZAE->ZAE_DATAM
			msunlock()
		endif
		ZAE->(DbSkip())
	enddo
return
