#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±   
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF111IN   º Autor ³ Flávio Bohrer Flôresº Data ³  21/11/22 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Rotina genérica para impressão de etiqueta testeira em      º±±
±±º          ³ Inglês                                                     º±±
±±º          ³ Alteração solicitadao chamado 2858                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAPCP                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

user function GJF111in(_modelo,_porta,_control,_cod,_quant,_pesob,_pesol,_tara,_predes,_classif,_TF,_datap,_etq,_dataval,_nNumEtq,_Lote,_IP,_seqPetq,_Hora)
	/*                      1      2        3      4     5      6     7      8     9        10   11  12    13     14       15      16    17     18	   19 
	Paremetros da função
	1  - modelo da impressora
	2  - porta
	3  - sequencial da caixa
	4  - codigo do produto
	5  - quantidade de peças na caixa
	6  - peso bruto
	7  - peso liquido
	8  - tara
	9  - previsão de produção da desossa
	10 - classificação
	11 - TF
	12 - data de produção
	13 - tipo de etiqueta
	14 - data de validade
	15 - numero de etiquetas a serem impressas
	16 - lote (para exportação)
	17 - Endereço IP para conexão ethernet
	18 - Seq. da Pré-Etiqueta
	19 - _Hora
	20 - _cLotePor
	*/
	
	local _dtPROD   := ''
	local _cSeq     := '' 
	local _despor   := ''
	local _desing   := ''
	local _SEXO     := ''
	local _GLUTEM   := ''
	local _vMENETQ  := ''
	local _vDINGLES := ''
	local _vTARAP   := 0.00
	local _nTS      := ''
	local _nTP      := ''
	local _DESCTIPO := ''
	local _vDTABATE := ''

	fonte_mlr1 	:= "25,10"
	fonte_mlr2 	:= "15,10"
	fonte_mlr3 	:= "45,20"
	fonte_mlr4 	:= "20,18"
	fonte_mlr5 	:= "60,18"

	Dbselectarea('SB1')
	SB1->(dbsetorder(1))
	SB1->(MsSeek(FWxfilial('SB1')+alltrim(_cod)))
	_vDESCING := SB1->B1_DINGLES 
	_vDESCSIF := SB1->B1_DESCSIF
	_dtPROD  := dtoc(_datap)   
	_despor  :=  alltrim(SB1->B1_DESCRED)  
	_desing  := SB1->B1_DESCING//alltrim(_vDINGLES)
	_SEXO	 := SB1->B1_MENETQ4
	_GLUTEM   := SB1->B1_MENETQ3
	_vMENETQ  := SB1->B1_MENETQ1 
	_cNotImp  := GetAdvFVal('SZU','ZU_NOTIMP',FWxfilial('SZU') + SZ8->Z8_NUMPREV,2)
	_DESTINO  := SB1->B1_DESTINO
	_DESCTIPO := SB1->B1_MENETQ2
	_dtVALID := dtoc(_dataval) 

	_nTS      := SB1->B1_CTARASE
	_cGrupo   := SB1->B1_GRUPO
	_nTP      := SB1->B1_CTARAP
	_cFarm    := GetAdvFVal('SBM','BM_FARM',FWxfilial('SBM')+_cGrupo,1) //forma de armazenamento
	_vTARAS   := GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_nTS),1)  //Tara Secundária	
	_vTARAP   := GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_nTP),1)

	if !empty(_predes) .and. substr(_predes,1,3) <> 'SIF'
		SZ2->(DbSetOrder(2))
		if  SZ2->(MsSeek(FWxfilial('SZ2')+_predes))                          	// se houver o apontamento de OP...
			_vNUMAM   := SZ2->Z2_NUMAM //GetAdvFVal('SZ2',2,FWxfilial('SZ2')+_predes,'Z2_NUMAM')  				//numero aviso de matança
			_vDTABATE := dtoc(SZ2->Z2_DATAABT) //dtoc(GetAdvFVal('SZ2',2,FWxfilial('SZ2')+_predes,'Z2_DATAABT'))//aviso de matança formatado em string
			_vRASTRO  := GetMv("MV_NUMIF") + strtran(_vDTABATE,'/','') +'0000   (' + _classif + ')' //Rastro
			_vTIP     := SZ2->Z2_TIPIFI //GetAdvFVal('SZ2',2,FWxfilial('SZ2')+_predes,'Z2_TIPIFI'  				//numero aviso de matança
		endif
	endif
	_cSeq := _seqPetq//SZ8->Z8_SEQPETQ

	IF SB1->B1_DESTINO == 'ME'
		MSCBPRINTER(_modelo,_porta,,,,,_IP)    
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(_nNumEtq,6,40)

		//***************** 1º Bloco da Etiqueta ********************

		MSCBSAY(69,100,_control,"R","F",fonte_mlr1) 						//Numero de controle
		MSCBSAY(73,05,_vDESCSIF,"R","F",fonte_mlr2)                 //Descricao em Portugues
		MSCBSAY(69,05,_vDESCING,"R","F",fonte_mlr2)                 //Descricao em Ingles
		MSCBBOX(68,01,68,180,4)                                     //Linha Divisoria

		//***************** 2º Bloco da Etiqueta ********************
		// dia 15/04/23 - flavio inseriu, Solicitado para parocesso de exportação (Adriana/Valeska)
		iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(64,05,"DATA DE ABATE | SLAUGHTER DATE:","R","F",fonte_mlr2),)
		iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(64,85,_vDTABATE,"R","F",fonte_mlr2),)

		MSCBSAY(61,05,"DATA PROD./LOTE | PRODUCTION DATE/LOT:","R","F",fonte_mlr2)
		MSCBSAY(61,85,_dtPROD,"R","F",fonte_mlr2)	
		MSCBSAY(58,05,"DATA DE VALIDADE | EXPIRY DATE:","R","F",fonte_mlr2)			
		MSCBSAY(58,85,_dtVALID,"R","F",fonte_mlr2)
		MSCBBOX(57,105,68,105,4)
		MSCBSAY(59,110,_DESTINO,"R","F",fonte_mlr3)
		MSCBBOX(57,01,57,180,4)
		//***************** 3º Bloco da Etiqueta ********************
		_cPb := transform(_pesob,'@E 99.999')
		_cPesob := strtran(_cPb,',','.')
		MSCBSAY(53,05,"PESO BRUTO | GROSS WEIGHT:","R","F",fonte_mlr2)		
		MSCBSAY(53,70,_cPesob + " Kg","R","F",fonte_mlr2)

		_cPl    := transform(_pesol,'@E ##.###')
		_cPesol := strtran(_cPl,',','.')
		MSCBSAY(46,05,"PESO LIQUIDO | NET WEIGHT:","R","F",fonte_mlr2)		
		MSCBSAY(46,70,_cPesol + "Kg","R","F",fonte_mlr3)

		_cTp    := transform(_quant * _vTaraP,'@E ##.###')
		_cTaraP := strtran(_cTp,',','.')
		MSCBSAY(43,05,"TARA EMB.PRIM. | INTERNAL TARE:","R","F",fonte_mlr2)		
		MSCBSAY(43,70,_cTaraP + " Kg","R","F",fonte_mlr2)

		_cTs := transform(_vTaras,'@E ##.###')
		_cTaras := strtran(_cTs,',','.')
		MSCBSAY(40,05,"TARA EMB. SEC. | TARE:","R","F",fonte_mlr2)
		MSCBSAY(40,70,_cTaras + " Kg","R","F",fonte_mlr2)

		_cTa := transform(_tara,'@E #.###')
		_cTara := strtran(_cTa,',','.')
		MSCBSAY(37,05,"TARA TOTAL | TOTAL TARE:","R","F",fonte_mlr2)		
		MSCBSAY(37,70,_cTara + " Kg","R","F",fonte_mlr2)
		MSCBBOX(36,01,36,180,4)

		//***************** 4º Bloco da Etiqueta ********************
		MSCBSAY(33,05,_vMENETQ,"R","0",fonte_mlr4)
		_dTdP := ""
		_dTdP := substr(_dtPROD,0,2)		
		_dTdP := _dTdP + substr(_dtPROD,4,2)
		_dTdP := _dTdP + substr(_dtPROD,7,2)
		MSCBSAY(33,85,'RASTREABILIDADE: 1733' +_dTdP+"0000","R","0",fonte_mlr4)
		
		iif(!empty(_GLUTEM),MSCBSAY(30,05,alltrim(_GLUTEM)+' - INDÚSTRIA BRASILEIRA',"R","0",fonte_mlr4),)     // Mensagem do Glutem
		iif(!empty(_DESCTIPO),MSCBSAY(27,05,_DESCTIPO,"R","0",fonte_mlr4),) //  B1_MENETQ2
		iif(!empty(_Lote) .and. !empty(_predes).and. substr(_predes,1,3) <> 'SIF',MSCBBOX(26,105,36,105,4),)
		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,106,"LOTE:","R","F",fonte_mlr2),)    //Lote
		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,116,_Lote,"R","F",fonte_mlr2),)  //descricao do lote preenchido no lançamento da OP da embalagem

		MSCBSAY(27,70,_SEXO,"R","0",fonte_mlr4) //descrição do sexo. preenche campo MENTETQ4 no cadastro de produtos

		MSCBSAY(30,100, _Hora,"R","0",fonte_mlr4)				
		MSCBBOX(26,01,26,180,4)
		//***************** 5º Bloco da Etiqueta ********************
		MSCBSAY(17,05,_despor + " / " + _desing,"R","F",fonte_mlr5)
		MSCBSAYBAR(06,62,_control,"R","C",10,.F.,.T.,,,2,1,.T.)
		MSCBBOX(06,88,18,123,80,"B")                                          //Box preto onde fica o cod. do produto
		MSCBSAYMEMO(03,88,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
		MSCBSAY(01,94,"PE:"+_cSeq,"R","0","25,20")
		MSCBEND()
		MSCBCLOSEPRINTER()
	else
		// aviso de produto mal cadastrado
		//	conout('417 - Inicio da Leitura ******* ')
		/*
		_me1 := 'Produto->'+alltrim(_cod)+'no campo B1_DESTINO'
		_me2 := 'Rejeite acionado'		
		rej(_emb)
		RegEv(_me1,'FA',_me2,1,_cString,_cCodPro,_emb,0,0)
		*/
	Endif

return .t.

//Função destinada a gravar os eventos da automação
Static Function RegEv(_desc,_status,_resp,_cod,_string,_prod,_emb,_pesob,_tara)

	Local _nID := ZA9->(RecCount()) + 1

	ZA9->(DbSetOrder(1))

	reclock('ZA9',.t.)
	ZA9->ZA9_FILIAL := FWxfilial('ZA9')
	ZA9->ZA9_ID     := _nID
	ZA9->ZA9_DESC   := _desc
	ZA9->ZA9_DATA   := date()
	ZA9->ZA9_HORA   := time()
	ZA9->ZA9_STATUS := _status
	ZA9->ZA9_COD    := _cod
	ZA9->ZA9_RESP   := _resp
	ZA9->ZA9_STRING := _String
	ZA9->ZA9_PROD   := _prod
	ZA9->ZA9_EMB    := _emb
	ZA9->ZA9_PESOB  := _pesob
	ZA9->ZA9_TARA   := _tara
	msunlock()

return
