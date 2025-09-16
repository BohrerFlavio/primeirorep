#INCLUDE "rwmake.ch"
#INCLUDE "Fileio.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGJF150    บAutor  ณMicrosiga           บ Data ณ  22/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Arquivo de leitura do pedido de compra para complementa็ใoบฑฑ
ฑฑบ          ณ  de opera็ใo de venda - LogFrio                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Comercial                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function GJF150()

	Private nTamFile := 0
	Private _cCabec  := ''
	Private _cSum    := ''
	Private _cTipo   := ''
	Private _nlin    := 0
	Private aItens   := {}
	Private cPerg    := "GJF150"
	Private cArq


	if !pergunte(cPerg,.t.)
		return
	endif

	Private _lOK  := .t.

	OkLeTxt(mv_par01)

return


//Fun็ใo para ler TXT
Static Function OkLeTxt(_cArquivo)

	if !file(alltrim(_cArquivo))
		MsgAlert("Arquivo TXT nใo foi encontrado! Verifique os parametros.","Atencao!")
		Return
	endif

	nHandle := FOPEN(alltrim(_cArquivo),FO_READ)
	cString := ''

	nTamFile := fSeek(nHandle,0,FS_END)

	if nTamFile  = 0
		MsgAlert("O arquivo estแ em branco!","Atencao!")
		return
	endif

	Processa({|| RunCont()  },"Realizando leitura do arquivo...")
	Processa({|| ProcCont() },"Realizando processamento dos pedidos...")

	FCLOSE(nHandle)

	if _lOK
		alert('Processamento automแtico do Pre-Pedido realizado com sucesso!')
	endif


Return

Static Function RunCont()

	ProcRegua(nTamFile)

	fseek(nHandle,0,FS_SET)

	//Leitura da linha do cabe็alho

	//L๊ as primeiras 274 posi็๕es do arquivo setado
	cString := FREADSTR(nHandle,207)

	If nHandle == -1
		MsgAlert("O arquivo nao pode ser aberto! Verifique os parametros.","Atencao!")
		Return
	Endif

	//Verifica as duas ultimas posi็๕es do cabe็alho caputradas anteriormente
	//verificando se ้ quebra de linha
	if substr(cString,206,2) <> CHR(13)+CHR(10)
		MsgAlert("Falha na estrutura do arquivo! Verifique sua estrutura.","Atencao!")
		_lOK := .f.
		Return
	endif

	fseek(nHandle,0,FS_SET)

	_nlin := 0
	_cTipo := FREADSTR(nHandle,2)

	while _cTipo = '3'

		_nlin++

		cString := FREADSTR(nHandle,205)

		if substr(cString,204,2) <> CHR(13)+CHR(10)
			MsgAlert("Falha na estrutura da linha "+ str(_nlin) + "! Verifique sua estrutura.","Atencao!")
			_lOK := .f.
			Return
		else
			AADD(aItens,cString)
		endif
		_cTipo := FREADSTR(nHandle,2)
	enddo

Return

Static Function ProcCont()
	local _NumPP    := ''
	local _nBuffer  := 0
	local _Nome     := ''
	local _cCodProd := ''
	local _cDescPro := ''
	local _nQuantPL := 0
	local _nQuantPB := 0
	local _nQuantC  := 0
	Local i

	if !_lOK
		return
	endif

	_nBuffer := len(aItens)


	if !_lOK
		return
	endif


	for i := 1 to len(aItens)
		ProcRegua(_nBuffer) 
		_NumPP   := substr(aItens[i],87,6)	          
		_cCodProd := substr(aItens[i],108,6) 
		_nQuantPL := val(substr(aItens[i],77,10))/1000
		_nQuantPB := val(substr(aItens[i],194,10))/1000
		_nQuantC  := val(substr(aItens[i],60,4))

		ZZ4->(DbSetOrder(2))
		if ZZ4->(DbSeek(xfilial('ZZ4')+_NumPP))
			if ZZ4->ZZ4_STATUS <> 'L'
				MsgAlert("Status do Pre-Pedido " + str(i) +" impede opera็ใo!","Atencao!")  
				_lOk := .f.
				Return  
			endif
		else 
			MsgAlert("Pedido inconsistente da linha " + str(i) + " !","Atencao!")
			_lOk := .f.
			Return
		endif   

		ZZ5->(DbsetOrder(2))
		if ZZ5->(DbSeek(xfilial('ZZ5') + _NumPP + _cCodProd))
			reclock('ZZ5',.f.)
			ZZ5->ZZ5_QRPESO := _nQuantPL
			ZZ5->ZZ5_QRCAIX := _nQuantC
			ZZ5->ZZ5_QRPESB := _nQuantPB
			msunlock()
		endif		
	next

	for i := 1 to len(aItens)
		_NumPP   := substr(aItens[i],87,6)	          
		ZZ4->(DbSetOrder(2))
		if ZZ4->(DbSeek(xfilial('ZZ4')+_NumPP))
			reclock('ZZ4',.f.)
			ZZ4->ZZ4_STATUS := 'E'
			ZZ4->ZZ4_DTFIM  := ddatabase
			ZZ4->ZZ4_HFIM   := time()
			msunlock()
		endif                                  
	next

Return
