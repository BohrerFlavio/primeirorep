#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF61     º Autor Giuliano Forgiarini    Data ³  05/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Workflow para recebimento de materiais. Ao lançar pré-nota º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Estoque e Compras                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


User Function GJF61()

	_area := getarea()

	//Bloco para chamar função personalizada de workflow
	SC7->(DbSetOrder(1))
	if  SC7->(MsSeek(FWxfilial('SC7')+SD1->(D1_PEDIDO + D1_ITEMPC)))
		SC1->(DbSetOrder(6))
		if SC1->(MsSeek(FWxfilial('SC1')+SC7->(C7_NUM+C7_ITEM)))
			//Função de workflow para lançamento da pre nota de enrada
			u_gjf61wfw(SC1->C1_USER,SC1->C1_PRODUTO,SC1->C1_QUANT,SC1->C1_DESCRI,SC7->C7_NUM)
		endif
	endif

	restarea(_area)

return


User Function gjf61wfw(_user,_prod,_quant,_descri,_pedido) 

	local _data    := ''
	local _hora    := ''
	//local _usuario := '' 
	local i
	//_cEmails += 'compras3@frigorificosilva.com.br,wf.manutencao@frigorificosilva.com.br,'
	//_cEmails += 'vitor.costa@frigorificosilva.com.br,wf.producao@frigorificosilva.com.br, '
	Local _cEmails := 'compras@frigorificosilva.com.br,compras2@frigorificosilva.com.br,compras4@frigorificosilva.com.br,'		
		  _cEmails += 'compras3@frigorificosilva.com.br,compras1@frigorificosilva.com.br,'
		  _cEmails += 'flavio.flores@frigorificosilva.com.br,carlos.walter@frigorificosilva.com.br'

	_data  := dtoc(date())
	_hora  := time()

	_cMens := 'Esta é uma mensagem automática do sistema. Por favor não responda!' + chr(13) + chr(10)
	_cMens += 'Na data e hora da emissão deste email, o setor de Almoxarifado recebeu material solicitado por você:' + chr(13) + chr(10)
	_cMens +=  chr(13) + chr(10)
	_cMens += 'Produto: (' + _prod  + ') ' + _descri + chr(13) + chr(10)
	_cMens += 'Quantidade: ' + transform(_quant,'@E 999,999.999')  + _descri + chr(13) + chr(10)
	_cMens += 'Pedido de Compra Nº: ' + _pedido
	_cTit  := 'Workflow Frigorífico Silva: Aviso de Recebimento de Material Solicitado no Almoxarifado'
	_cDest := _cEmails + u_gjf54USR(_user)

	if !empty(_cDest)
		_aEmail := u_GJF54(_cMens,_cTit,_cDest)
	endif

	for i := 1 to len(_aEmail)
		if !_aEmail[i]
			alert('ERRO WORKFLOW ('+ str(i) +')')
		endif
	next

return
