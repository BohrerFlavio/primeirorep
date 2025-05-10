#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMTA105LIN บ Autor Giuliano forgiarini  บ Data ณ  27/02/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Ponto de entrada na solicita็ใo ao armazem para que sejam  บฑฑ
ฑฑบ          ณ validados os campos de funcionแrio e Centro de Custo       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Seguran็a do Trabalho                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function MTA105LIN()
	Local _lRet   := .t.
	Local _cUsers := GetMV('SI_USERSTR')
	Local _cUsr   := RetCodUsr()
	Local _cCC    := GDFieldGet("CP_CC",n) 
	Local _cCC1   := GDFieldGet("CP_CC",1)
	Local _cFunc  := GDFieldGet("CP_FUNC",n)
	Local _cFunc1 := GDFieldGet("CP_FUNC",1)
	Local _cGrupo := GDFieldGet("CP_GRUPO",n)
	Local _cLocal := GDFieldGet("CP_LOCAL",n)

	if _cUsr $ _cUsers
		if empty(_cCC) .or. empty(_cFunc)
			alert('Necessแrio prencher Centro de Custo e Codigo do Funcionแrio')
			_lRet := .f.
		endif    
		if  _cFunc <> _cFunc1
			alert('Solicita็ใo ao armazem deve ser apenas para um unico funcionแrio!')
			_lRet := .f.	
		endif
		if  _cCC <> _cCC1
			alert('Solicita็ใo ao armazem deve ser apenas para um unico centro de custo!')
			_lRet := .f.	
		endif
	else
		if _cGrupo = '1301' .and. _cLocal = '04'
			alert('Usuario nใo autorizado a movimentar produtos deste grupo!')
			_lRet := .f.	
		endif
	endif

Return _lRet 
