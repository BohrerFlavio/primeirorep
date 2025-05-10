#INCLUDE "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT010VLD  ºAutor  ³Giuliano Forgiarini º Data ³  12/10/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada para Validação de inclusao do Cadastro do  º±±
±±º          ³ produto. Usado par workflow para a contabilidade           º±±
±±             º                                                           ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT010VLD()
	Local _ret := .t.

	/*
	Grupo de Produto: 5000 até 5999 (Menos 5311, 5313, 5321, 5322, 5400, 5420)
	Grupo de Produto: 7000 até 7999 (Menos 7311, 7312, 7313, 7321, 7322, 7400)
	*/

	_cIniGrp := substr(SB1->B1_GRUPO,1,1)

	//Condição específica para produtos a serem utilizados no FCI
	if _cIniGrp $ '5/7' .and. !(SB1->B1_GRUPO $ '5311/5313/5321/5322/5400/5420/7311/7312/7313/7321/7322/7400')  
		_WFlow(SB1->B1_COD,SB1->B1_DESC,SB1->B1_TIPO,SB1->B1_GRUPO) 
	endif

return _ret         


//Rotina de WorkFlow para envio a contabilidade (FCI)
Static Function _WFlow(_Cod,_Desc,_Tipo,_Grupo)
	local _area
	Local _cDest := 'contabilidade@frigorificosilva.com.br'
	local _DescGrp := fBuscaCPO('SBM',1,xfilial('SBM')+_Grupo,'BM_DESC')
	local i
	
	_area := GetArea()

	_cMens := 'Esta é uma mensagem automática do sistema. Por favor não responda!' + chr(13) + chr(10)
	_cMens += 'Na data e hora da emissão deste email, o produto abaixo sofreu inclusão' + chr(13) + chr(10)
	_cMens += 'ou alteração, sendo este pertencendte aos grupos de produtos elencados' + chr(13) + chr(10)
	_cMens += 'no processo de geração da FCI.' + chr(13) + chr(10)
	_cMens +=   chr(13) + chr(10)
	_cMens += 'Código:   ' + alltrim(_Cod) + chr(13) + chr(10)
	_cMens += 'Descrição:' + Alltrim(_Desc) + chr(13) + chr(10)
	_cMens += 'Tipo:     ' + _Tipo + chr(13) + chr(10)
	_cMens += 'Grupo:    ' + _Grupo + chr(13) + chr(10)
	_cMens += 'Descricao:' + _DescGrp+ chr(13) + chr(10)

	_cTit  := 'Workflow Frigorífico Silva: Controle de inclusão e alteração de Cadastro de Produto (FCI)'

	_aEmail := u_GJF54(_cMens,_cTit,_cDest)

	for i := 1 to len(_aEmail)
		if !_aEmail[i]
			alert('ERRO WORKFLOW ('+ str(i) +')')
		endif
	next

	restarea(_area)

return
