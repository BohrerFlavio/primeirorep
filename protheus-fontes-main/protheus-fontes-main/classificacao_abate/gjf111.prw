#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±   
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF111   º Autor ³ Giuliano Forgiariniº Data ³  30/03/11    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Rotina genérica para impressão de etiqueta testeira padrão  º±±
±±º          ³                                                            º±±
±±º 29/08/22 ³  Alteração solicitadao chamado 2717                        º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAPCP                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


//Etiqueta para produção normal em estações ( Miudos e reimpressão )
user function GJF111a(_modelo,_porta,_control,_cod,_quant,_pesob,_pesol,_tara,_predes,_classif,_TF,_datap,_etq,_dataval,_nNumEtq,_Lote,_IP,_seqPetq,_cLotePor,_Hora,_cReimp,_cNumPrev)
	/*                    1      2       3      4     5      6     7      8      9        10    11   12    13     14       15      16   17    18       19       20     21       22
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
	18 - Seq. Pré-etiqueta
	19 - Hora
	20 - Lote Porcionados
	21 - Reimpressão
	22 - OP da Embalagem
	*/

	//local dtAbate   := ''
	local _vTIP     := ''
	local _vDESCES  := ''
	local _vDINGLES := ''
	local _vDESCING := ''
	local _vDFRANCES:= ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vDESCFRA := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vTARAP   := 0.00
	local _vTARAS   := 0.00
	local _vMENETQ  := ''
	local _vFAM     := ''
	local _DESTINO  := ''
	local _CADMERC  := ''
	local _DESCTIPO := ''
	local _GLUTEM   := ''
	local _SEXO     := ''
	local _vNUMAM   := ''
	local _vDTABATE := ''
	local _vRASTRO  := ''
	//local _vTIP     := ''
	local _desing   := ''
	local _desfra   := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _despor   := ''
	local _descFAM  := ''
	local _dtPROD   := ''
	local _dtVALID  := ''
	local _nTS      := ''
	local _nTP      := ''
	local _cSeq     := ''  //Campo feito por Fabian Maurer para capturar o codigo da Pre-Etiqueta - 27/02/12
	local _cPesol   := strtran(cValtoChar(_pesol),'.','')
	local _codExp   := getMv('SI_CODEXP')

	Dbselectarea('SB1')
	SB1->(dbsetorder(1))
	SB1->(Msseek(Fwxfilial('SB1')+alltrim(_cod)))
	_vDINGLES := SB1->B1_DESCING //os dois campos abaixo estao invertidos de proposito para não
	_vDESCING := SB1->B1_DINGLES //precisar mexer no layout de impressao - B1_DINGLES é a do SIF
	_vDFRANCES:= SB1->B1_DESCFRA //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	_vDESCFRA := SB1->B1_DFRANCE //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	_vDESCES  := SB1->B1_DESCESP // e o B1_DESCING a descrição em ingles do produto
	_VDESPAN  := SB1->B1_DESPANH
	_vDESCSIF := SB1->B1_DESCSIF //
	_nTS      := SB1->B1_CTARASE
	_cGrupo   := SB1->B1_GRUPO
	_cFarm    := GetAdvFVal('SBM','BM_FARM',Fwxfilial('SBM')+_cGrupo,1)
	_vTARAS   := GetAdvFVal('ZAB','ZAB_TARA',Fwxfilial('ZAB')+alltrim(_nTS),1)  //Tara Secundária
	_nTP      := SB1->B1_CTARAP
	_vTARAP   := GetAdvFVal('ZAB','ZAB_TARA',Fwxfilial('ZAB')+alltrim(_nTP),1)   //Tara Primária
	_vMENETQ  := SB1->B1_MENETQ1 //Mensagem etiqueta 1
	_vFAM     := SB1->B1_FAM     //Família Silva
	_DESTINO  := SB1->B1_DESTINO //Destino
	_CADMERC  := SB1->B1_CADMERC
	_DESCTIPO := SB1->B1_MENETQ2
	_GLUTEM   := SB1->B1_MENETQ3
	_SEXO	   := SB1->B1_MENETQ4
	_nCodBar   := SB1->B1_CODBAR
	_nCdBarcli := SB1->B1_EANCLI
	_cUm      := SB1->B1_UM
	_cDun14   := SB1->B1_DUN14
	_nPesFix  := SB1->B1_PESFIX

	if _nPesFix <> 0
		_pesol := _nPesFix
		_pesob := _nPesFix + _tara
	endif

	if empty(_cNumPrev)
		_cNumPrev := GetAdvFVal('SZ8','Z8_NUMPREV',Fwxfilial('SZ8') + _control,3)
	endif
	_cNotImp  := GetAdvFVal('SZU','ZU_NOTIMP',Fwxfilial('SZU') + _cNumPrev,2)
	_cDtEstu  := dtoc(GetAdvFVal('SZU','ZU_DTEST',Fwxfilial('SZU') + _cNumPrev,2))

	if !empty(_predes) .and. substr(_predes,1,3) <> 'SIF'
		SZ2->(DbSetOrder(2))
		if  SZ2->(MsSeek(Fwxfilial('SZ2')+_predes))                          	// se houver o apontamento de OP...
			_vNUMAM   := SZ2->Z2_NUMAM //GetAdvFVal('SZ2',2,Fwxfilial('SZ2')+_predes,'Z2_NUMAM')  				//numero aviso de matança
			//_vDTABATE := dtoc(SZ2->Z2_DATAABT) //dtoc(GetAdvFVal('SZ2',2,Fwxfilial('SZ2')+_predes,'Z2_DATAABT'))//aviso de matança formatado em string			
			_vRASTRO  := GetMv("MV_NUMIF") + strtran(_vDTABATE,'/','') +'0000   (' + _classif + ')' //Rastro
			_vTIP     := SZ2->Z2_TIPIFI //GetAdvFVal('SZ2',2,Fwxfilial('SZ2')+_predes,'Z2_TIPIFI')  				//numero aviso de matança
			_vDTABATE := dtoc(SZ2->Z2_DATAABT)
		endif
	endif

	_desing  := alltrim(SB1->B1_DESCING)//_desing  := alltrim(_vDINGLES)
	_desfra  := alltrim(_vDFRANCES) //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	_despor  :=  " (" + alltrim(SB1->B1_DESCRED) + ")"         //Descrição reduzida em portugues
	_desesp  := alltrim(SB1->B1_DESCESP)//_desing  := alltrim(_vDINGLES)
	_cSeq    := _seqPetq//iif(empty(SZ8->Z8_SEQPETQ),_seqPetq,SZ8->Z8_SEQPETQ) //Campo feito por Fabian Maurer para capturar o codigo da Pre-Etiqueta - 27/02/12

	DbSelectArea('SX5')
	_descFAM := GetAdvFVal('SX5','X5_DESCRI',Fwxfilial("SX5")+'PS'+_vFAM,1)   //Descrição da família
	_dtPROD  := dtoc(_datap)   //data da produção
	_dtVALID := dtoc(_dataval) //data de validade

	/*************************** Etiqueta Padrão  ************************************************ */

	if(_etq='P')
		if !empty(_IP)
			MSCBPRINTER(_modelo,"IP",,,,,_IP)	
			//MSCBPRINTER(_modelo,"IP",,,,,"10.11.20.239")
		else
			MSCBPRINTER(_modelo,_porta)
		endif	
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(_nNumEtq,6,40)
		// Posição d codigo de barras
		fonte1  :="35,15"
		fonte1_1:="30,15"

		fonte2  :="35,30"
		fonte2_1:="60,60"
		fonte2_2:="25,35"
		fonte2_3:="20,23"
		fonte2_4:="35,30"
		fonte2_5:="25,20" // Trocando até acertar
		fonte3  :="45,15"
		fonte3_1:="40,45"
		f_extra :="30,22"
		fonte3_2:="84,90"
		fonte3_3:="24,15"
		fonte3_4:="45,30"
		fonte4  :="20,5"
		fonte4_1:="18,10"
		fsexo := "50,40"
		fonte5  :="25,25"
		//Novas fontes Criadas por Fabian Maurer - 07/06/12
		fonte_fab1 := "27,15"
		fonte_fab2 := "27,17"
		fonte_fab3 := "50,25"
		fonte_fab4 := "35,20"
		fonte_fab5 := "38,15"
		fonte_fab6 := "10,6"
		//Novas fontes para teste (Mauricio L. Roehrs)
		fonte_mlr1 := "25,10"
		fonte_mlr2 := "15,10"
		fonte_mlr3 := "45,20"
		fonte_mlr4 := "20,18"
		fonte_mlr5 := "60,18"
		fonte_mlr6 := "35,22"

		if !empty(_cReimp)
			MSCBSAY(32,110, _cReimp,"R","F",fonte_mlr3)
		endif

		IF SB1->B1_DESTINO == 'ME'

			//***************** 1º Bloco da Etiqueta ********************

			MSCBSAY(73,85,_control,"R","F",fonte_mlr1) 						//Numero de controle
			MSCBSAY(73,02,_vDESCSIF,"R","F",fonte_mlr2)
			IF _CADMERC = "A"
				MSCBSAY(69,02,_vDESCING,"R","F",fonte_mlr2)
			ELSEIF _CADMERC = "E"
				MSCBSAY(69,02,_VDESPAN,"R","F",fonte_mlr2)
			ENDIF
			MSCBBOX(68,01,68,180,4)                                     //Linha Divisoria

			//***************** 2º Bloco da Etiqueta ********************				
			/*
			MSCBSAY(64,05,"DATA DE EMBALAGEM / PACKING DATE:","R","F",fonte_mlr2)						
			MSCBSAY(64,80,DTOC(_datap),"R","F",fonte_mlr2)

			MSCBSAY(61,05,"DATA DE VALIDADE / EXPIRY DATE","R","F",fonte_mlr2)
			MSCBSAY(61,80,_dtVALID,"R","F",fonte_mlr2)

			iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,05,"DATA ABATE/PROD/LOTE / SLAUGHTER DATE","R","F",fonte_mlr2),)
			iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,80,_vDTABATE,"R","F",fonte_mlr2),)
			*/

			IF _CADMERC = "A"
				if _cFarm <> 'S'
					iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(64,02,"DATA ABATE/PROD/LOTE/SLAUGHTER DATE/PROD/LOT:","R","F",fonte_mlr2),)
					iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(64,93,_vDTABATE,"R","F",fonte_mlr2),)
				endif

				MSCBSAY(61,02,"DATA DE EMBALAGEM/PACKING DATE:","R","F",fonte_mlr2)
				MSCBSAY(61,93,DTOC(_datap),"R","F",fonte_mlr2)

				MSCBSAY(58,02,"DATA DE VALIDADE/EXPIRY DATE","R","F",fonte_mlr2)
				MSCBSAY(58,93,_dtVALID,"R","F",fonte_mlr2)
			ELSEIF _CADMERC = "E"
				if _cFarm <> 'S'
					iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(64,02,"DATA ABATE/PROD/LOTE/FECHA MATANZA/PROD/LOTE:","R","F",fonte_mlr2),)
					iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(64,93,_vDTABATE,"R","F",fonte_mlr2),)
				endif

				MSCBSAY(61,02,"DATA DE EMBALAGEM/DATA EMPAQUE:","R","F",fonte_mlr2)
				MSCBSAY(61,93,DTOC(_datap),"R","F",fonte_mlr2)

				MSCBSAY(58,02,"DATA DE VALIDADE/DATA DE VALIDAD:","R","F",fonte_mlr2)
				MSCBSAY(58,93,_dtVALID,"R","F",fonte_mlr2)
			ENDIF

			MSCBBOX(57,110,68,110,4)//MSCBBOX(57,105,68,105,4)
			MSCBSAY(62,115,_DESTINO,"R","F",fonte_mlr3)

			MSCBBOX(57,01,57,200,4)//MSCBBOX(57,01,57,180,4)

			//***************** 3º Bloco da Etiqueta ********************
			if  _cNotImp <> "P"
				IF SB1->B1_CADMERC = "A"
					_cPb := transform(_pesob,'@E 99.999')
					_cPesob := strtran(_cPb,',','.')
					MSCBSAY(53,02,"PESO BRUTO/GROSS WEIGHT:","R","F",fonte_mlr2)
					MSCBSAY(53,70,_cPesob + " Kg","R","F",fonte_mlr2)

					_cPl    := transform(_pesol,'@E ##.###')
					_cPesol := strtran(_cPl,',','.')
					MSCBSAY(46,02,"PESO LIQUIDO/NET WEIGHT:","R","F",fonte_mlr2)
					MSCBSAY(46,70,_cPesol + "Kg","R","F",fonte_mlr3)

					_cTp    := transform(_quant * _vTaraP,'@E ##.###')
					_cTaraP := strtran(_cTp,',','.')
					MSCBSAY(43,02,"TARA EMB.PRIM./INTERNAL TARE:","R","F",fonte_mlr2)
					MSCBSAY(43,70,_cTARAP + " Kg","R","F",fonte_mlr2)

					// Inclusão Para impressão Rastreada "RT". Dia 19/09/16 - Flávio
					iif(AllTrim(_classif) = 'RT',MSCBSAY(42,107,_classif,"R","0",fonte2_1),)  //VER SE ENTRA E COLOCAR EM NOVO BLOCO

					_cTs := transform(_vTaras,'@E ##.###')
					_cTaras := strtran(_cTs,',','.')
					MSCBSAY(40,02,"TARA EMB. SEC./TARE:","R","F",fonte_mlr2)
					MSCBSAY(40,70,_cTARAS + " Kg","R","F",fonte_mlr2)

					_cTa := transform(_tara,'@E #.###')
					_cTara := strtran(_cTa,',','.')
					MSCBSAY(37,02,"TARA TOTAL/TOTAL TARE:","R","F",fonte_mlr2)
					MSCBSAY(37,70,_cTara + " Kg","R","F",fonte_mlr2)
				ELSEIF  SB1->B1_CADMERC = "E"
					_cPb := transform(_pesob,'@E 99.999')
					_cPesob := strtran(_cPb,',','.')
					MSCBSAY(53,02,"PESO BRUTO/PESO BRUTO:","R","F",fonte_mlr2)
					MSCBSAY(53,70,_cPesob + " Kg","R","F",fonte_mlr2)

					_cPl    := transform(_pesol,'@E ##.###')
					_cPesol := strtran(_cPl,',','.')
					MSCBSAY(46,02,"PESO LIQUIDO/PESO NETO:","R","F",fonte_mlr2)
					MSCBSAY(46,70,_cPesol + "Kg","R","F",fonte_mlr3)

					_cTp    := transform(_quant * _vTaraP,'@E ##.###')
					_cTaraP := strtran(_cTp,',','.')
					MSCBSAY(43,02,"TARA EMB.PRIM./TARA DEL EMB. PRIM.:","R","F",fonte_mlr2)
					MSCBSAY(43,70,_cTARAP + " Kg","R","F",fonte_mlr2)

					// Inclusão Para impressão Rastreada "RT". Dia 19/09/16 - Flávio
					iif(AllTrim(_classif) = 'RT',MSCBSAY(42,107,_classif,"R","0",fonte2_1),)  //VER SE ENTRA E COLOCAR EM NOVO BLOCO

					_cTs := transform(_vTaras,'@E ##.###')
					_cTaras := strtran(_cTs,',','.')
					MSCBSAY(40,02,"TARA EMB. SEC./TARA DEL EMB. SEC:","R","F",fonte_mlr2)
					MSCBSAY(40,70,_cTARAS + " Kg","R","F",fonte_mlr2)

					_cTa := transform(_tara,'@E #.###')
					_cTara := strtran(_cTa,',','.')
					MSCBSAY(37,02,"TARA TOTAL/TARA TOTAL:","R","F",fonte_mlr2)
					MSCBSAY(37,70,_cTara + " Kg","R","F",fonte_mlr2)
				ENDIF				

				MSCBBOX(36,01,36,180,4)
			else
				MSCBSAY(53,05,"PESO BRUTO/GROSS WEIGHT:","R","F",fonte_mlr2)
				MSCBSAY(53,70,transform(_pesob,'@E ##.###')+" Kg","R","F",fonte_mlr2)

				MSCBSAY(46,05,"PESO LIQUIDO/NET WEIGHT:","R","F",fonte_mlr2)
				MSCBSAY(46,70,transform(_pesol,'@E ##.###')+"Kg","R","F",fonte_mlr3)

				MSCBSAY(43,05,"TARA EMB.PRIM./INTERNAL TARE:","R","F",fonte_mlr2)
				MSCBSAY(43,70,transform(_quant * _vTARAP,'@E ##.###')+" Kg","R","F",fonte_mlr2)

				// Inclusão Para impressão Rastreada "RT". Dia 19/09/16 - Flávio
				iif(AllTrim(_classif) = 'RT',MSCBSAY(42,107,_classif,"R","0",fonte2_1),)  //VER SE ENTRA E COLOCAR EM NOVO BLOCO		

				MSCBSAY(40,05,"TARA EMB./TARE SEC.:","R","F",fonte_mlr2)
				MSCBSAY(40,70,transform(_vTARAS,'@E ##.###')+" Kg","R","F",fonte_mlr2)

				MSCBSAY(37,05,"TARA TOTAL/TOTAL TARE:","R","F",fonte_mlr2)
				MSCBSAY(37,70,transform(_tara,'@E ##.###')+" Kg","R","F",fonte_mlr2)

				MSCBBOX(36,01,36,180,4)

			endif

			//***************** 4º Bloco da Etiqueta ********************

			MSCBSAY(33,02,_vMENETQ,"R","0",fonte_mlr4)

			MSCBSAY(30,02,ALLTRIM(_GLUTEM)  + " | INDÚSTRIA BRASILEIRA","R","0",fonte_mlr4)

			// Inclusão dia 19/09/16 - Para impressão de Produtos RT - Flávio 
			//iif(AllTrim(_classif) == 'RT',iif(!empty(_predes),MSCBSAY(29,05,"RASTREABILIDADE :" + _vRASTRO,"R","0",fonte_mlr4),),) 	// Descrição Rastreabilidade
			_vDta := substr(_vDTABATE,1,2)
			_vDta := _vDta + substr(_vDTABATE,4,2)
			_vDta := _vDta + substr(_vDTABATE,7,2)

			//return .T.
			//_cRastro := '1733' +  +'0000'
			_cRastro := '1733'+ _vDta  +'0000'
			MSCBSAY(27,65,"Rastreabilidade: "+ _cRastro,"R","0",fonte_mlr4)

			iif(!empty(_DESCTIPO),MSCBSAY(27,02,_DESCTIPO,"R","0",fonte_mlr4),) // Mensagem do Tipo

			iif (!empty(_Lote) .and. !empty(_predes).and. substr(_predes,1,3) <> 'SIF',MSCBBOX(26,105,36,105,4),)

			iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,106,"LOTE:","R","F",fonte_mlr2),)    //Lote
			iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,116,_Lote,"R","F",fonte_mlr2),)  //descricao do lote preenchido no lançamento da OP da embalagem

			MSCBSAY(30,100, _Hora,"R","0",fonte_mlr4)

			MSCBSAY(27,70,_SEXO,"R","0",fonte_mlr4) //descrição do sexo. preenche campo MENTETQ4 no cadastro de produtos

			MSCBBOX(26,01,26,180,4)

			//***************** 5º Bloco da Etiqueta ********************
			IF SB1->B1_CADMERC = "A"
				MSCBSAY(17,02,_despor+"/"+_desing,"R","F",fonte_mlr5)
			ELSEIF SB1->B1_CADMERC = "E"
				MSCBSAY(17,02,_despor+"/"+_desesp,"R","F",fonte_mlr5)
			ENDIF
			MSCBSAYBAR(06,62,_control,"R","C",10,.F.,.T.,,,2,1,.T.)

			//MSCBBOX(06,92,18,123,80,"B")                                          //Box preto onde fica o cod. do produto
			MSCBBOX(06,88,18,123,80,"B")                                          //Box preto onde fica o cod. do produto
			//MSCBSAYMEMO(03,92,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
			MSCBSAYMEMO(03,88,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
			MSCBSAY(01,94,"PE:"+_cSeq,"R","0","25,20")

		ELSE // MI
			//***************** 1º Bloco da Etiqueta ********************

			MSCBSAY(72,95,_control,"R","F",fonte_mlr1)         					// Numero de controle

			MSCBSAY(75,02,_vDESCSIF,"R","F",fonte_mlr2)   						//Descrição em ingles

			MSCBSAY(72,02,_vDESCING,"R","F",fonte_mlr2) 						//Descrição em Portugues

			MSCBBOX(71,01,71,125,4) 											// Linha Divisoria

			//************** 2º Bloco da Etiqueta *********************
			/*
			MSCBSAY(64,05,iif(_cFarm = 'S',"DATA PRODUCAO/","DATA EMBALAGEM/") + "PACKING DATE:","R","F",fonte_mlr2) //Descrição data de produção			
			MSCBSAY(64,80,DTOC(_datap),"R","F",fonte_mlr2)   

			MSCBSAY(61,05,"DATA VALIDADE/EXPIRY DATE:","R","F",fonte_mlr2)   // Descrição data de validade - Alterado por Fabian Maurer - 02/05/12 - Correção de Escrita
			MSCBSAY(61,80,_dtVALID,"R","F",fonte_mlr2)     						//Data de Validade
			
			MSCBSAY(67,05,"DATA ABATE/PROD/LOTE/SLAUGHTER DATE","R","F",fonte_mlr2)
			MSCBSAY(67,80,_vDTABATE,"R","F",fonte_mlr2)
			*/
			if _cFarm = 'S'
				MSCBSAY(67,02,"DATA DE ESTUFA/STOVE DATE:","R","F",fonte_mlr2)
				MSCBSAY(67,93,_cDtEstu,"R","F",fonte_mlr2)
			else
				MSCBSAY(67,02,"DATA ABATE/PROD/LOTE/SLAUGHTER DATE/PROD/LOT:","R","F",fonte_mlr2)
				MSCBSAY(67,93,_vDTABATE,"R","F",fonte_mlr2)
			endif

			MSCBSAY(64,02,iif(_cFarm = 'S',"DATA PROD./LOTE/PACKING DATE/LOT:","DATA EMBALAGEM/PACKING DATE:"),"R","F",fonte_mlr2) //Descrição data de produção			
			MSCBSAY(64,93,DTOC(_datap),"R","F",fonte_mlr2)

			MSCBSAY(61,02,"DATA VALIDADE/EXPIRY DATE:","R","F",fonte_mlr2)   // Descrição data de validade - Alterado por Fabian Maurer - 02/05/12 - Correção de Escrita
			MSCBSAY(61,93,_dtVALID,"R","F",fonte_mlr2)     						//Data de Validade
			
			//MSCBBOX(61,105,71,105,4)                                            // Linha Separa Tipo de Mercado
			MSCBBOX(61,110,71,110,4)//MSCBBOX(57,105,68,105,4)

			//MSCBSAY(62,110,_DESTINO,"R","F",fonte_mlr3)     					// Descrição Tipo de Mercado ( MI )
			MSCBSAY(62,115,_DESTINO,"R","F",fonte_mlr3)

			MSCBBOX(61,01,61,125,4) 											// Linha Divisoria

			//************** 3º Bloco da Etiqueta ************************

			if  _cNotImp <> "P"
				_cPb    := transform(_pesob,'@E 99.999')
				_cPesob := strtran(_cPb,',','.')
				MSCBSAY(57,02,"PESO BRUTO/GROSS WEIGHT:","R","F",fonte_mlr2) 		// Descrição peso bruto da caixa
				MSCBSAY(57,70,_cPesob + " Kg","R","F",fonte_mlr2) // Peso Bruto

				_cPl    := transform(_pesol,'@E ##.###')
				_cPesol := strtran(_cPl,',','.')
				MSCBSAY(51,02,"PESO LIQUIDO/NET WEIGHT:","R","F",fonte_mlr2)      // Descrição peso liquido
				MSCBSAY(51,70, _cPesol + " Kg","R","F",fonte_mlr3)   	// Peso liquido
				// Descrição KG

				_cTp    := transform(_quant * _vTaraP,'@E ##.###')
				_cTaraP := strtran(_cTp,',','.')
				MSCBSAY(48,02,"TARA EMB.PRIM./INTERNAL TARE:","R","F",fonte_mlr2) 	// Descrição tara primaria
				MSCBSAY(48,70,_cTaraP + " Kg","R","F",fonte_mlr2) // Tara primaria

				_cTs 	  := transform(_vTaras,'@E ##.###')
				_cTaras := strtran(_cTs,',','.')
				MSCBSAY(45,02,"TARA EMB SEC./TARE:","R","F",fonte_mlr2) 			// Descrição tara secundaria
				MSCBSAY(45,70,_cTaras + " Kg","R","F",fonte_mlr2) // Tara secundaria

				_cTa   := transform(_tara,'@E #.###')
				_cTara := strtran(_cTa,',','.')
				MSCBSAY(42,02,"TARA TOTAL/TOTAL TARE:","R","F",fonte_mlr2)   	// Descrição tara total da caixa0000422081
				MSCBSAY(42,70,_cTara + " Kg","R","F",fonte_mlr2) // Tara total

				MSCBBOX(41,01,41,125,4)

			else
				MSCBSAY(57,02,"PESO BRUTO/GROSS WEIGHT:","R","F",fonte_mlr2) 		// Descrição peso bruto da caixa
				MSCBSAY(57,70,transform(_pesob,'@E ##.###')+" Kg","R","F",fonte_mlr2) // Peso Bruto

				MSCBSAY(51,02,"PESO LIQUIDO/NET WEIGHT:","R","F",fonte_mlr2)      // Descrição peso liquido
				MSCBSAY(51,70, transform(_pesol,'@E ##.###')+" Kg","R","F",fonte_mlr3)   	// Peso liquido				

				MSCBSAY(48,02,"TARA EMB.PRIM./INTERNAL TARE:","R","F",fonte_mlr2) 	// Descrição tara primaria
				MSCBSAY(48,70,transform(_quant * _vTARAP,'@E ##.###')+" Kg","R","F",fonte_mlr2) // Tara primaria

				MSCBSAY(45,02,"TARA EMB SEC./TARE:","R","F",fonte_mlr2) 			// Descrição tara secundaria
				MSCBSAY(45,70,transform(_vTARAS,'@E ##.###')+" Kg","R","F",fonte_mlr2) // Tara secundaria

				MSCBSAY(42,02,"TARA TOTAL/TOTAL TARE:","R","F",fonte_mlr2)   	// Descrição tara total da caixa
				MSCBSAY(42,70,transform(_tara,'@E #.###')+" Kg","R","F",fonte_mlr2) // Tara total

				MSCBBOX(41,01,41,125,4) 											// Linha Divisoria

				// Linha Divisoria
			endif

			iif(_TF == 'S',MSCBSAY(33,105,"TF","R","0",fonte2_1),)

			//******************* 4º Bloco da Etiqueta ************************

			cPEAN14 := getMV('SI_CDEAN14')
			cPEan142 := getMV('SI_CEAN142')
			cPEan143 := getMV('SI_CEAN143')
			cPEan144 := getMV('SI_CEAN144')
			cPEan145 := getMV('SI_CEAN145')

			if (alltrim(_cod) $ (Alltrim(cPEan14)+Alltrim(cPEan142)+Alltrim(cPEan143)+Alltrim(cPEan144)+Alltrim(cPEan145)))
				MSCBSAYBAR(32,31,_cDun14,"R","C",8,.F.,.T.,,,3,1,.T.)  // produtos com DUN14 provenientes de clientes
			elseif _cUM = 'UN'
				if !empty(_nCdBarcli)//bloco para imprimir dun14 do cliente
					_cod13 := '1' + substr(_nCdBarcli,1,12)
				else
					_cod13 := '1' + substr(_nCodBar,1,12)
				endif
				_cDig    := EAN14(_cod13)
				_cod14   := _cod13 + _cDig
				MSCBSAYBAR(32,31,_cod14,"R","C",8,.F.,.T.,,,3,1,.T.)  //EAN 14 para Tubetes quantidade/peso padrão
			else
				MSCBSAYBAR(32,31,'010' + _nCodBar + '310200' + substr(_cPesol,1,2) + substr(_cPesol,3,2),"R","C",8,.F.,.T.,,,3,1,.T.)  //EAN exigido pelo walmart			
			endif			

			if !empty(_cReimp)
				MSCBSAY(32,110, _cReimp,"R","F",fonte_mlr3)
			endif

			MSCBSAY(35,100, _Hora,"R","0",fonte_mlr6)

			//******************* 5º Bloco da Etiqueta ************************

			MSCBBOX(28,01,28,125,4)												// Linha Divisoria

			MSCBSAY(25,04,_vMENETQ,"R","0",fonte_mlr4)                          // Mensagem da Agricultura
			MSCBSAY(22,04,ALLTRIM(_GLUTEM)  + " | INDÚSTRIA BRASILEIRA","R","0",fonte_mlr4)

			iif(!empty(_DESCTIPO),MSCBSAY(22,70,_DESCTIPO,"R","0",fonte_mlr4),) // Mensagem do Tipo

			if !empty(_cLotePor)//se for caixa de porcionados imprime esta frase.
				MSCBSAY(25,01,"REGISTRO NO MINISTERIO DA AGRICULTURA SIF/DIPOA SOB N "+alltrim(_SEXO),"R","0",fonte_mlr4)    
			endif

			if _cFarm = 'S'
				_vDTABATE := dtoc(_datap)
			endif
			_vDta := substr(_vDTABATE,1,2)
			_vDta := _vDta + substr(_vDTABATE,4,2)
			_vDta := _vDta + substr(_vDTABATE,7,2)
			_cRastro := '1733'+ _vDta  +'0000'
			MSCBSAY(25,75,"Rastreabilidade: "+ _cRastro,"R","0",fonte_mlr4)

			//******************* 6º Bloco da Etiqueta ************************

			MSCBBOX(21,01,21,125,4)  											// Linha Divisoria

			if len(_despor+"/"+_desing) > 40
				_cPrimFrase := substr(_despor+_desing,1,50)
				_cSegFrase  := substr(_despor+_desing,51,30)
				_cTercF  := substr(_despor+_desing,81,30)

				MSCBSAY(15,04,_cPrimFrase,"R","F",fonte_mlr2)
				MSCBSAY(12,04,_cSegFrase,"R","F",fonte_mlr2)
				MSCBSAY(9,04,_cTercF,"R","F",fonte_mlr2)
			else
				MSCBSAY(14,04,_despor + "/" + _desing ,"R","F",fonte_mlr2)
			endif

			MSCBSAYBAR(04,62,_control,"R","C",10,.F.,.T.,,,2,1,.T.)  			// Numero do controle da caixa código de barras

			//MSCBBOX(4,93,17,123,80,"B")    										// Box que fica o cod. Produto dentro
			MSCBBOX(4,88,17,123,80,"B")    										// Box que fica o cod. Produto dentro

			//MSCBSAYMEMO(2,93,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
			MSCBSAYMEMO(2,88,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
			If !empty(alltrim(_cSeq))
				MSCBSAY(01,100,"PE:"+_cSeq,"R","0","25,20")						// Numero da Pre-Etiqueta   01/100
			endif

			//******************* Não Utilizados ************************

			/* Bloco a Definir se aparece em Mercado Interno
			iif(AllTrim(_classif) == 'RT',iif(!empty(_predes),MSCBSAY(53,05,"RASTREABILIDADE :","R","0",fonte2),),) 	// Descrição Rastreabilidade
			iif(AllTrim(_classif) == 'RT',iif(!empty(_predes),MSCBSAY(53,37,_vRASTRO,"R","0",fonte2),),)             //
			iif(!empty(_predes),MSCBSAY(53,75,"DATA PRODUCAO: ","R","0",fonte2),)       //data de abate //usado por mauricio no ME
			iif(!empty(_predes),MSCBSAY(53,110,_vDTABATE,"R","0",fonte2),)
			iif(AllTrim(_classif) = 'RT',MSCBSAY(36,107,_classif,"R","0",fonte2_1),)  VER SE ENTRA E COLOCAR EM NOVO BLOCO
			iif(_TF == 'S',MSCBSAY(33,105,"TF","R","0",fonte2_1),)  	VER SE ENTRA E COLOCAR EM NOVO BLOCO
			iif(!empty(_SEXO),MSCBSAY(27,97,_SEXO,"R","0",fsexo),)   VERIFICAR SE ENTRA E COLOCAR E NOVO BLOCO
			iif(!empty(_vTIP),MSCBSAY(13,5,"Categoria","R","0",fonte2_3),)
			iif(!empty(_vTIP),MSCBSAY(2,5,_vTIP,"R","0",fonte3_2),)      //codigo tipificação  Categria
			MSCBSAY(15,5,_descFAM,"R","0",fonte2)   //descrição da família
			*/

		ENDIF

		MSCBEND()
		MSCBCLOSEPRINTER()

		//******************************** Inicio Etiqueta Espanhol ******************************\\
	elseif(_etq='E')

		if !empty(_IP)
			MSCBPRINTER(_modelo,'IP',,,,,_IP)	
		else
			MSCBPRINTER(_modelo,_porta)
		endif

		//modelo, 'IP' ,,,,,endereço ip do server de impressao(IP DA ZEBRA)
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(_nNumEtq,6,40)
		// Posição d codigo de barras
		fonte1  :="35,15"
		fonte1_1:="30,15"

		fonte2  :="35,30"
		fonte2_1:="60,60"
		fonte2_2:="25,35"
		fonte2_3:="20,23"
		fonte2_4:="35,30"
		fonte2_5:="25,20" // Trocando até acertar
		fonte3  :="45,15"
		fonte3_1:="40,45"
		f_extra :="30,22"
		fonte3_2:="84,90"
		fonte3_3:="24,15"
		fonte3_4:="45,30"
		fonte4  :="20,5"
		fonte4_1:="18,10"
		fsexo   :="50,40"
		fonte5  :="25,25"
		//Novas fontes Criadas por Fabian Maurer - 07/06/12
		fonte_fab1 := "27,15"
		fonte_fab2 := "27,17"
		fonte_fab3 := "50,25"
		fonte_fab4 := "35,20"
		fonte_fab5 := "38,15"
		fonte_fab6 := "10,6"
		//Novas fontes para teste (Mauricio L. Roehrs)
		fonte_mlr1 := "25,10"
		fonte_mlr2 := "15,10"
		fonte_mlr3 := "45,20"
		fonte_mlr4 := "20,18"
		fonte_mlr5 := "60,18"
		fonte_mlr6 := "35,22"

		if !empty(_cReimp)
			MSCBSAY(32,110, _cReimp,"R","F",fonte_mlr3)
		endif

		//***************** 1º Bloco da Etiqueta ********************

		MSCBSAY(73,85,_control,"R","F",fonte_mlr1) 						//Numero de controle
		MSCBSAY(73,05,_vDESCSIF,"R","F",fonte_mlr2)                 //Descricao em Ingles
		MSCBSAY(69,05,_vDESCING,"R","F",fonte_mlr2)                 //Descricao em Portugues
		MSCBBOX(68,01,68,180,4)                                     //Linha Divisoria

		//***************** 2º Bloco da Etiqueta ********************

		if alltrim(_cod) $ _codExp			
			MSCBSAY(64,05,"DATA PRODUCAO/LOTE/FECHA PRODUCCION/LOTE:","R","F",fonte_mlr2)
			MSCBSAY(64,80,_dtPROD,"R","F",fonte_mlr2)	
		else			
			MSCBSAY(64,05,iif(_cFarm = 'S',"DATA PRODUCAO/LOTE:","DATA EMBALAGEM:")+"FECHA PRODUCTION/LOTE:","R","F",fonte_mlr2)
			MSCBSAY(64,80,_dtPROD,"R","F",fonte_mlr2)
			iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,05,"DATA ABATE/LOTE/FECHA ABATE/LOTE:","R","F",fonte_mlr2),)
			iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,80,_vDTABATE,"R","F",fonte_mlr2),)	
		endif

		MSCBSAY(61,05,"DATA DE VALIDADE/FECHA DE VALIDAD:","R","F",fonte_mlr2)
		MSCBSAY(61,80,_dtVALID,"R","F",fonte_mlr2)

		MSCBBOX(57,105,68,105,4)
		MSCBSAY(62,110,_DESTINO,"R","F",fonte_mlr3)

		MSCBBOX(57,01,57,180,4)

		//***************** 3º Bloco da Etiqueta ********************
		if  _cNotImp <> "P"
			_cPb := transform(_pesob,'@E 99.999')
			_cPesob := strtran(_cPb,',','.')
			MSCBSAY(53,05,"PESO BRUTO/PESO BRUTO:","R","F",fonte_mlr2)
			MSCBSAY(53,70,_cPesob + " Kg","R","F",fonte_mlr2)

			_cPl    := transform(_pesol,'@E ##.###')
			_cPesol := strtran(_cPl,',','.')
			MSCBSAY(46,05,"PESO LIQUIDO/PESO NETO:","R","F",fonte_mlr2)
			MSCBSAY(46,70,_cPesol + "Kg","R","F",fonte_mlr3)

			_cTp    := transform(_quant * _vTaraP,'@E ##.###')
			_cTaraP := strtran(_cTp,',','.')
			MSCBSAY(43,05,"TARA EMB.PRIM./TARA ENV. PRIM.:","R","F",fonte_mlr2)
			MSCBSAY(43,70,_cTARAP + " Kg","R","F",fonte_mlr2)

			_cTs := transform(_vTaras,'@E ##.###')
			_cTaras := strtran(_cTs,',','.')
			MSCBSAY(40,05,"TARA EMB. SEC./TARA ENV. SEC.:","R","F",fonte_mlr2)
			MSCBSAY(40,70,_cTARAS + " Kg","R","F",fonte_mlr2)

			_cTa := transform(_tara,'@E #.###')
			_cTara := strtran(_cTa,',','.')
			MSCBSAY(37,05,"TARA TOTAL/TARA TOTAL:","R","F",fonte_mlr2)
			MSCBSAY(37,70,_cTara + " Kg","R","F",fonte_mlr2)

			MSCBBOX(36,01,36,180,4)
		else

			MSCBSAY(53,05,"PESO BRUTO/PESO BRUTO:","R","F",fonte_mlr2)
			MSCBSAY(53,70,transform(_pesob,'@E ##.###')+" Kg","R","F",fonte_mlr2)

			MSCBSAY(46,05,"PESO LIQUIDO/PESO NETO:","R","F",fonte_mlr2)
			MSCBSAY(46,70,transform(_pesol,'@E ##.###')+"Kg","R","F",fonte_mlr3)

			MSCBSAY(43,05,"TARA EMB.PRIM./TARA ENV. PRIM.:","R","F",fonte_mlr2)
			MSCBSAY(43,70,transform(_quant * _vTARAP,'@E ##.###')+" Kg","R","F",fonte_mlr2)

			MSCBSAY(40,05,"TARA EMB. SEC./TARA ENV. SEC.:","R","F",fonte_mlr2)
			MSCBSAY(40,70,transform(_vTARAS,'@E ##.###')+" Kg","R","F",fonte_mlr2)

			MSCBSAY(37,05,"TARA TOTAL/TARA TOTAL:","R","F",fonte_mlr2)
			MSCBSAY(37,70,transform(_tara,'@E ##.###')+" Kg","R","F",fonte_mlr2)

			MSCBBOX(36,01,36,180,4)

		endif

		//***************** 4º Bloco da Etiqueta ********************

		MSCBSAY(33,05,_vMENETQ,"R","0",fonte_mlr4)
		
		MSCBSAY(30,05,ALLTRIM(_GLUTEM)  + " | INDÚSTRIA BRASILEIRA","R","0",fonte_mlr4)

		iif(!empty(_DESCTIPO),MSCBSAY(27,05,_DESCTIPO,"R","0",fonte_mlr4),) // Mensagem do Tipo

		iif (!empty(_Lote) .and. !empty(_predes).and. substr(_predes,1,3) <> 'SIF',MSCBBOX(26,105,36,105,4),)

		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,106,"LOTE:","R","F",fonte_mlr2),)    //Lote
		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,116,_Lote,"R","F",fonte_mlr2),)  //descricao do lote preenchido no lançamento da OP da embalagem

		MSCBSAY(27,70,_SEXO,"R","0",fonte_mlr4) //descrição do sexo. preenche campo MENTETQ4 no cadastro de produtos

		MSCBBOX(26,01,26,180,4)
		MSCBSAY(30,110, _Hora,"R","0",fonte_mlr6)

		//***************** 5º Bloco da Etiqueta ********************

		MSCBSAY(17,05,_despor + _desing,"R","F",fonte_mlr5)

		MSCBSAYBAR(06,62,_control,"R","C",10,.F.,.T.,,,2,1,.T.)

		MSCBBOX(06,92,18,123,80,"B")                                          //Box preto onde fica o cod. do produto		
		MSCBSAYMEMO(03,88,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto

		If !empty(alltrim(_cSeq))
			MSCBSAY(01,88,"PE:"+_cSeq,"R","0","25,20")
		endif

		//***************** Bloco RT ********************
		// Inclusão Para impressão Rastreada "RT". Dia 19/09/16 - Flávio	
		iif(AllTrim(_classif) = 'RT',MSCBSAY(36,107,_classif,"R","0",fonte2_1),)
		iif(AllTrim(_classif) = 'RT',iif(!empty(_predes),MSCBSAY(30,05,"RASTREABILIDADE :" + _vRASTRO,"R","0",fonte_mlr4),),) 	// Descrição Rastreabilidade

		MSCBEND()
		MSCBCLOSEPRINTER()

		//******************************** Inicio Etiqueta Da Argentina ******************************\\
	elseif(_etq='A')

		if !empty(_IP)
			MSCBPRINTER(_modelo,'IP',,,,,_IP)	
		else
			MSCBPRINTER(_modelo,_porta)
		endif

		//modelo, 'IP' ,,,,,endereço ip do server de impressao(IP DA ZEBRA)
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(_nNumEtq,6,40)
		// Posição d codigo de barras
		fonte1  :="35,15"
		fonte1_1:="30,15"

		fonte2  :="35,30"
		fonte2_1:="60,60"
		fonte2_2:="25,35"
		fonte2_3:="20,23"
		fonte2_4:="35,30"
		fonte2_5:="25,20" // Trocando até acertar
		fonte3  :="45,15"
		fonte3_1:="40,45"
		f_extra :="30,22"
		fonte3_2:="84,90"
		fonte3_3:="24,15"
		fonte3_4:="45,30"
		fonte4  :="20,5"
		fonte4_1:="18,10"
		fsexo := "50,40"
		fonte5  :="25,25"
		//Novas fontes Criadas por Fabian Maurer - 07/06/12
		fonte_fab1 := "27,15"
		fonte_fab2 := "27,17"
		fonte_fab3 := "50,25"
		fonte_fab4 := "35,20"
		fonte_fab5 := "38,15"
		fonte_fab6 := "10,6"
		//Novas fontes para teste (Mauricio L. Roehrs)
		fonte_mlr1 := "25,10"
		fonte_mlr2 := "15,10"
		fonte_mlr3 := "45,20"
		fonte_mlr4 := "20,18"
		fonte_mlr5 := "60,18"
		fonte_mlr6 := "35,22"

		//***************** 1º Bloco da Etiqueta ********************

		MSCBSAY(73,85,_control,"R","F",fonte_mlr1) 						//Numero de controle
		MSCBSAY(73,05,_vDESCING,"R","F",fonte_mlr2)                 //Descricao em Ingles
		MSCBSAY(69,05,_vDESCSIF,"R","F",fonte_mlr2)                 //Descricao em Portugues
		MSCBBOX(68,01,68,180,4)                                     //Linha Divisoria

		//***************** 2º Bloco da Etiqueta ********************

		if alltrim(_cod) $ _codExp
			//MSCBSAY(64,05,"DATA DE PRODUCAO/FECHA DE BENEFICIO::","R","F",fonte_mlr2)
			MSCBSAY(64,05,"DATA DE PRODUCAO/PRODUCTION DATE:","R","F",fonte_mlr2)
			MSCBSAY(64,85,_dtPROD,"R","F",fonte_mlr2)	
		else
			//MSCBSAY(64,05,iif(_cFarm = 'S',"DATA DE PRODUCAO:","DATA DA EMBALAGEM:")+"FECHA DEL PRODUCCION:","R","F",fonte_mlr2)
			MSCBSAY(64,05,iif(_cFarm = 'S',"DATA DE PRODUCAO:","DATA DA EMBALAGEM:")+"PRODUCTION DATE:","R","F",fonte_mlr2)
			MSCBSAY(64,85,_dtPROD,"R","F",fonte_mlr2)

			iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,43,"FECHA DE BENEFICIO:","R","F",fonte_mlr2),)
			iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,85,_vDTABATE,"R","F",fonte_mlr2),)	
		endif

		//MSCBSAY(61,05,"DATA DE VALIDADE/FECHA DEL VENCIMENTO:","R","F",fonte_mlr2)
		MSCBSAY(61,05,"DATA DE VALIDADE/EXPIRY DATE:","R","F",fonte_mlr2)
		MSCBSAY(61,85,_dtVALID,"R","F",fonte_mlr2)		

		MSCBBOX(57,105,68,105,4)
		MSCBSAY(62,110,_DESTINO,"R","F",fonte_mlr3)

		MSCBBOX(57,01,57,180,4)

		//***************** 3º Bloco da Etiqueta ********************
		if  _cNotImp <> "P"
			_cPb := transform(_pesob,'@E 99.999')
			_cPesob := strtran(_cPb,',','.')
			//MSCBSAY(53,05,"PESO BRUTO/PESO BRUTO:","R","F",fonte_mlr2)
			MSCBSAY(53,05,"PESO BRUTO/GORSS WEIGHT:","R","F",fonte_mlr2)
			MSCBSAY(53,71,_cPesob + " Kg","R","F",fonte_mlr2)

			_cPl    := transform(_pesol,'@E ##.###')
			_cPesol := strtran(_cPl,',','.')
			//MSCBSAY(46,05,"PESO LIQUIDO/PESO NETO:","R","F",fonte_mlr2)
			MSCBSAY(46,05,"PESO LIQUIDO/NET WEIGHT:","R","F",fonte_mlr2)
			MSCBSAY(46,70,_cPesol + "Kg","R","F",fonte_mlr3)

			_cTp    := transform(_quant * _vTaraP,'@E ##.###')
			_cTaraP := strtran(_cTp,',','.')
			//MSCBSAY(43,05,"TARA EMB.PRIM./TARA DEL EMBALAGE:","R","F",fonte_mlr2)
			MSCBSAY(43,05,"TARA EMB.PRIM./INTERNAL TARE:","R","F",fonte_mlr2)
			MSCBSAY(43,71,_cTARAP + " Kg","R","F",fonte_mlr2)

			_cTs := transform(_vTaras,'@E ##.###')
			_cTaras := strtran(_cTs,',','.')
			//MSCBSAY(40,05,"TARA EMB. SEC.TARA DE LA CAJA:","R","F",fonte_mlr2)
			MSCBSAY(40,05,"TARA EMB. SEC./SECONDARY PACKAGING TARE:","R","F",fonte_mlr2)
			MSCBSAY(40,71,_cTARAS + " Kg","R","F",fonte_mlr2)

			_cTa := transform(_tara,'@E #.###')
			_cTara := strtran(_cTa,',','.')
			MSCBSAY(37,05,"TARA TOTAL/TOTAL TARE:","R","F",fonte_mlr2)
			MSCBSAY(37,71,_cTara + " Kg","R","F",fonte_mlr2)

			MSCBBOX(36,01,36,180,4)
		else

			//MSCBSAY(53,05,"PESO BRUTO/PESO BRUTO:","R","F",fonte_mlr2)
			MSCBSAY(53,05,"PESO BRUTO/GORSS WEIGHT:","R","F",fonte_mlr2)
			MSCBSAY(53,70,transform(_pesob,'@E ##.###')+" Kg","R","F",fonte_mlr2)

			//MSCBSAY(46,05,"PESO LIQUIDO/PESO NETO:","R","F",fonte_mlr2)
			MSCBSAY(46,05,"PESO LIQUIDO/NET WEIGHT:","R","F",fonte_mlr2)
			MSCBSAY(46,70,transform(_pesol,'@E ##.###')+"Kg","R","F",fonte_mlr3)

			//MSCBSAY(43,05,"TARA EMB.PRIM./TARA DEL EMBALAGE:","R","F",fonte_mlr2)
			MSCBSAY(43,05,"TARA EMB.PRIM./INTERNAL TARE:","R","F",fonte_mlr2)
			MSCBSAY(43,71,transform(_quant * _vTARAP,'@E ##.###')+" Kg","R","F",fonte_mlr2)

			//MSCBSAY(40,05,"TARA EMB. SEC./TARA DELA CAJA:","R","F",fonte_mlr2)
			MSCBSAY(40,05,"TARA EMB. SEC./SECONDARY PACKAGING TARE:","R","F",fonte_mlr2)
			MSCBSAY(40,71,transform(_vTARAS,'@E ##.###')+" Kg","R","F",fonte_mlr2)

			//MSCBSAY(37,05,"TARA TOTAL/TARA TOTAL:","R","F",fonte_mlr2)
			MSCBSAY(37,05,"TARA TOTAL/TOTAL TARE:","R","F",fonte_mlr2)
			MSCBSAY(37,71,transform(_tara,'@E ##.###')+" Kg","R","F",fonte_mlr2)

			MSCBBOX(36,01,36,180,4)

		endif

		//***************** 4º Bloco da Etiqueta ********************

		MSCBSAY(33,05,_vMENETQ,"R","0",fonte_mlr4)

		_cPrdArg := getMv('SI_PRDARG')

			If alltrim(_cod) $ _cPrdArg
				MSCBSAY(27,90,'VENTA AL PESO. No Recongelar',"R","0",fonte_mlr4)
			endif

		MSCBSAY(30,05,ALLTRIM(_GLUTEM)  + " | INDÚSTRIA BRASILEIRA","R","0",fonte_mlr4)

		iif(!empty(_DESCTIPO),MSCBSAY(27,05,_DESCTIPO,"R","0",fonte_mlr4),) // Mensagem do Tipo

		iif (!empty(_Lote) .and. !empty(_predes).and. substr(_predes,1,3) <> 'SIF',MSCBBOX(26,105,36,105,4),)

		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,106,"LOTE:","R","F",fonte_mlr2),)    //Lote
		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,116,_Lote,"R","F",fonte_mlr2),)  //descricao do lote preenchido no lançamento da OP da embalagem

		MSCBSAY(27,70,_SEXO,"R","0",fonte_mlr4) //descrição do sexo. preenche campo MENTETQ4 no cadastro de produtos

		MSCBBOX(26,01,26,180,4)
		MSCBSAY(30,110, _Hora,"R","0",fonte_mlr6)

		//***************** 5º Bloco da Etiqueta ********************

		MSCBSAY(17,05,_despor+_desing,"R","F",fonte_mlr5)

		MSCBSAYBAR(06,62,_control,"R","C",10,.F.,.T.,,,2,1,.T.)

		//MSCBBOX(06,92,18,123,80,"B")                                          //Box preto onde fica o cod. do produto
		MSCBBOX(06,88,18,123,80,"B")                                          //Box preto onde fica o cod. do produto
		//MSCBSAYMEMO(03,92,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
		MSCBSAYMEMO(03,88,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
		If !empty(alltrim(_cSeq))
			MSCBSAY(01,94,"PE:"+_cSeq,"R","0","25,20")
		endif

		//***************** Bloco RT ********************
		// Inclusão Para impressão Rastreada "RT". Dia 19/09/16 - Flávio	
		iif(AllTrim(_classif) = 'RT',MSCBSAY(36,107,_classif,"R","0",fonte2_1),)
		iif(AllTrim(_classif) = 'RT',iif(!empty(_predes),MSCBSAY(30,05,"RASTREABILIDADE :" + _vRASTRO,"R","0",fonte_mlr4),),) 	// Descrição Rastreabilidade

		MSCBEND()
		MSCBCLOSEPRINTER()	

		//******************************** Inicio Etiqueta Frances ******************************\\

	elseif(_etq='F')

		MSCBPRINTER(_modelo,_porta)
		//MSCBPRINTER(_modelo,'COM3:9600,n,8,1')
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(_nNumEtq,6,40)
		// Posição d codigo de barras
		fonte1  :="35,15"
		fonte1_1:="30,15"

		fonte2  :="35,30"
		fonte2_1:="60,60"
		fonte2_2:="25,35"
		fonte2_3:="20,23"
		fonte2_4:="35,30"
		fonte2_5:="25,20" // Trocando até acertar
		fonte3  :="45,15"
		fonte3_1:="40,45"
		f_extra :="30,22"
		fonte3_2:="84,90"
		fonte3_3:="24,15"
		fonte3_4:="45,30"
		fonte4  :="20,5"
		fonte4_1:="18,10"
		fsexo := "50,40"
		fonte5  :="25,25"
		//Novas fontes Criadas por Fabian Maurer - 07/06/12
		fonte_fab1 := "27,15"
		fonte_fab2 := "27,17"
		fonte_fab3 := "50,25"
		fonte_fab4 := "35,20"
		fonte_fab5 := "38,15"
		fonte_fab6 := "10,6"
		//Novas fontes para teste (Mauricio L. Roehrs)
		fonte_mlr1 := "25,10"
		fonte_mlr2 := "15,10"
		fonte_mlr3 := "45,20"
		fonte_mlr4 := "20,18"
		fonte_mlr5 := "60,18"
		fonte_mlr6 := "35,22"

		//***************** 1º Bloco da Etiqueta ********************

		MSCBSAY(73,85,_control,"R","F",fonte_mlr1) 						//Numero de controle
		MSCBSAY(73,05,_vDESCFRA,"R","F",fonte_mlr2)                 //Descricao em Ingles
		MSCBSAY(69,05,_vDESCSIF,"R","F",fonte_mlr2)                 //Descricao em Portugues
		MSCBBOX(68,01,68,180,4)                                     //Linha Divisoria

		//***************** 2º Bloco da Etiqueta ********************

		MSCBSAY(64,05,"DATE D' EMBALLAGE/DATA EMBALAGEM:","R","F",fonte_mlr2)
		MSCBSAY(64,70,_dtPROD,"R","F",fonte_mlr2)

		MSCBSAY(61,05,"DATE DE VALIDITE/DATA VALIDADE:","R","F",fonte_mlr2)
		MSCBSAY(61,70,_dtVALID,"R","F",fonte_mlr2)

		//MSCBSAY(58,05,"PIECE/PECA:","R","F",fonte_mlr2)
		//MSCBSAY(58,27,transform(_quant,'@E ######'),"R","F",fonte_mlr2)

		iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,38,"DATE DE PRODUCTION/DATA PRODUCAO:","R","F",fonte_mlr2),)
		iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,77,_vDTABATE,"R","F",fonte_mlr2),)

		MSCBBOX(57,105,68,105,4)
		MSCBSAY(62,110,_DESTINO,"R","F",fonte_mlr3)

		MSCBBOX(57,01,57,180,4)

		//***************** 3º Bloco da Etiqueta ********************

		MSCBSAY(53,05,"POIDS BRUT/PESO BRUTO(Kg):","R","F",fonte_mlr2)
		MSCBSAY(53,70,transform(_pesob,'@E ##.###')+" Kg","R","F",fonte_mlr2)

		MSCBSAY(46,05,"POIDS NET/PESO LIQUIDO(Kg):","R","F",fonte_mlr2)
		MSCBSAY(46,70,transform(_pesol,'@E ##.###')+"Kg","R","F",fonte_mlr3)

		MSCBSAY(43,05,"INTERNAL TARE/TARA EMB.PRIM.:","R","F",fonte_mlr2)
		MSCBSAY(43,70,transform(_vTARAP,'@E ##.###')+" Kg","R","F",fonte_mlr2)

		MSCBSAY(40,05,"TARE/TARA EMB. SEC.:","R","F",fonte_mlr2)
		MSCBSAY(40,70,transform(_vTARAS,'@E ##.###')+" Kg","R","F",fonte_mlr2)

		MSCBSAY(37,05,"TOTAL TARE/TARA TOTAL:","R","F",fonte_mlr2)
		MSCBSAY(37,70,transform(_tara,'@E ##.###')+" Kg","R","F",fonte_mlr2)

		MSCBBOX(36,01,36,180,4)

		//***************** 4º Bloco da Etiqueta ********************

		MSCBSAY(33,05,_vMENETQ,"R","0",fonte_mlr4)

		MSCBSAY(30,05,ALLTRIM(_GLUTEM)  + " | INDÚSTRIA BRASILEIRA","R","0",fonte_mlr4)

		iif(!empty(_DESCTIPO),MSCBSAY(27,05,_DESCTIPO,"R","0",fonte_mlr4),) // Mensagem do Tipo

		iif (!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBBOX(26,105,36,105,4),)

		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,106,"LOTE:","R","F",fonte_mlr2),)    //Lote
		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,116,_Lote,"R","F",fonte_mlr2),)  //descricao do lote preenchido no lançamento da OP da embalagem

		MSCBSAY(27,70,_SEXO,"R","0",fonte_mlr4) //descrição do sexo. preenche campo MENTETQ4 no cadastro de produtos

		MSCBBOX(26,01,26,180,4)
		MSCBSAY(30,110, _Hora,"R","0",fonte_mlr6)

		//***************** 5º Bloco da Etiqueta ********************

		MSCBSAY(17,05,_desfra+_despor,"R","F",fonte_mlr5)

		MSCBSAYBAR(06,62,_control,"R","C",10,.F.,.T.,,,2,1,.T.)

		//MSCBBOX(06,92,18,123,80,"B")                                          //Box preto onde fica o cod. do produto
		MSCBBOX(06,88,18,123,80,"B")                                          //Box preto onde fica o cod. do produto
		//MSCBSAYMEMO(03,92,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
		MSCBSAYMEMO(03,88,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
		If !Empty(alltrim(_cSeq))
			MSCBSAY(01,94,"PE:"+_cSeq,"R","0","25,20")
		Endif

		MSCBEND()
		MSCBCLOSEPRINTER()

	endif
return .t.

//Etiqueta para impressão na solução de automação
user function GJF111b(_modelo,_porta,_control,_cod,_quant,_pesob,_pesol,_tara,_predes,_classif,_TF,_datap,_etq,_dataval,_nNumEtq,_Lote,_IP,_cSeq,_Hora)
	/*                      1      2        3      4     5      6     7      8     9        10     11    12   13     14       15       16   17
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
	16 - Lote (exclusivo para exportação)
	17 - Endereço IP para conexão ethernet
	18 - Sequencial da Pré-etiqueta
	19 - Hora
	*/

	//local dtAbate   := ''
	local _vTIP     := ''
	local _vDESCES  := ''
	local _vDINGLES := ''
	local _vDESCING := ''
	local _vDFRANCES:= ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vDESCFRA := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vTARAP   := 0.00
	local _vTARAS   := 0.00
	local _vMENETQ  := ''
	local _vFAM     := ''
	local _DESTINO  := ''
	local _DESCTIPO := ''
	local _GLUTEM   := ''
	local _SEXO     := ''
	local _vNUMAM   := ''
	local _vDTABATE := ''
	local _vRASTRO  := ''
	//local _vTIP     := ''
	local _desing   := ''
	local _desfra   := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _despor   := ''
	local _descFAM  := ''
	local _dtPROD   := ''
	local _dtVALID  := ''
	local _nTS      := ''
	local _nTP      := ''
	//local _cSeq     := ''
	local _cPesol   := strtran(cValtoChar(_pesol),'.','')
	local	_codExp   := getMv('SI_CODEXP')		
	//local _cModo    := GETMV('SI_MIMPEMB')
	//local _cIpImp   := GETMV('SI_IPIMP')

	SB1->(dbsetorder(1))
	if SB1->(Msseek(Fwxfilial('SB1')+alltrim(_cod)))
		_vDINGLES := SB1->B1_DESCING //os dois campos abaixo estao invertidos de proposito para não
		_vDESCING := SB1->B1_DINGLES //precisar mexer no layout de impressao - B1_DINGLES é a do SIF
		_vDFRANCES:= SB1->B1_DESCFRA  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
		_vDESCFRA := SB1->B1_DFRANCE //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
		_vDESCES  := SB1->B1_DESCESP // e o B1_DESCING a descrição em ingles do produto
		_vDESCSIF := SB1->B1_DESCSIF
		_nTS      := SB1->B1_CTARASE
		_nTP      := SB1->B1_CTARAP  // Incluido por Fabian Maurer - 08/05/2012 - nao estava pegando certo a tara primaria
		_nCodBar  := SB1->B1_CODBAR
		_nCdBarcli := SB1->B1_EANCLI
		_cNotImp  := GetAdvFVal('SZU','ZU_NOTIMP',Fwxfilial('SZU') + SZ8->Z8_NUMPREV,2)
		_cGrupo   := SB1->B1_GRUPO
		_cFarm    := GetAdvFVal('SBM','BM_FARM',Fwxfilial('SBM')+_cGrupo,1)

		ZAB->(DbSetOrder(1))
		if ZAB->(MsSeek(Fwxfilial('ZAB')+alltrim(_nTS)))
			_vTARAS   := ZAB->ZAB_TARA
		endif

		if ZAB->(MsSeek(Fwxfilial('ZAB')+alltrim(_nTP)))
			_vTARAP   := ZAB->ZAB_TARA
		endif

		_vMENETQ  := SB1->B1_MENETQ1
		_vFAM     := SB1->B1_FAM
		_DESTINO  := SB1->B1_DESTINO
		_DESCTIPO := SB1->B1_MENETQ2
		_GLUTEM   := SB1->B1_MENETQ3
		_SEXO	    := SB1->B1_MENETQ4
	endif

	if !empty(_predes) .and. substr(_predes,1,3) <> 'SIF'
		SZ2->(DbSetOrder(2))
		if  SZ2->(MsSeek(Fwxfilial('SZ2')+_predes))                          	// se houver o apontamento de OP...
			_vNUMAM   := SZ2->Z2_NUMAM //GetAdvFVal('SZ2',2,Fwxfilial('SZ2')+_predes,'Z2_NUMAM')  				//numero aviso de matança
			_vDTABATE := dtoc(SZ2->Z2_DATAABT) //dtoc(GetAdvFVal('SZ2',2,Fwxfilial('SZ2')+_predes,'Z2_DATAABT'))//aviso de matança formatado em string
			_vRASTRO  := GetMv("MV_NUMIF") + strtran(_vDTABATE,'/','') +'0000   (' + _classif + ')'
			_vTIP     := SZ2->Z2_TIPIFI //GetAdvFVal('SZ2',2,Fwxfilial('SZ2')+_predes,'Z2_TIPIFI')  				//numero aviso de matança
		endif
	endif

	_desing  := alltrim(_vDINGLES)
	_desfra  := alltrim(_vDFRANCES)  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	_despor  :=  substr(alltrim(SB1->B1_DESCRED),1,17)
	//_cSeq    := SZ8->Z8_SEQPETQ

	DbSelectArea('SX5')
	_descFAM := GetAdvFVal('SX5','X5_DESCRI',Fwxfilial("SX5")+'PS'+_vFAM,1)
	_dtPROD  := dtoc(_datap)
	_dtVALID := dtoc(_dataval) //data da produção

	_linha := 5
	/*************************** Etiqueta Padrão  ************************************************ */

	if(_etq='P')
		_linP := -20//era 20

		MSCBPRINTER(_modelo,_porta,,,,,_IP)
		/*Inclusão para teste do Flávio*/
		//MSCBPRINTER(_modelo,"IP",,,,,'10.11.20.96')

		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(_nNumEtq,6,40)
		// Posição d codigo de barras
		fonte1  :="40,20"
		fonte1_1:="30,15"
		fonte1_2:="85,85" //100/50
		fonte1_3:="38,12"
		fonte2  :="35,30"
		fonte2_1:="100,100"
		fonte2_2:="25,35"
		fonte2_3:="20,23"
		fonte2_4:="35,30"
		fonte2_5:="25,20" // Trocando até acertar
		fonte3  :="35,12"//42
		fonte3_1:="40,45"
		f_extra :="30,22"
		fonte3_2:="84,90"
		fonte3_3:="24,15"
		fonte3_4:="45,30"
		fonte3_5 := "70,55"
		fonte4  :="20,5"
		fonte4_1:="16,8"
		fsexo   :="65,50"
		fonte4_2:="120,65"
		fonte5  :="25,25"
		fonte5_1 := "20,18"

		IF SB1->B1_DESTINO == 'MI'

			//******************* 1º Bloco da Etiqueta ************************

			_cDescSIF :=  substr(_vDESCSIF,1,35)
			MSCBSAY(7,88+_linha,_control,"I","0",fonte2_2)         	//numero de controle era 7
			MSCBSAY(72+_linP,88+_linha,_cDescSIF,"I","0",fonte2_2)   				//descrição do ingles
			MSCBSAY(42+_linP,85+_linha,_vDESCING,"I","0",fonte2_2) 					//descrição do SIF
			MSCBLineH(01,84+_linha,300,4,"B")                  //Linha Divisoria

			//******************* 2º Bloco da Etiqueta ************************

			MSCBSAY(54+_linP,80+_linha,"PACKING DATE/"+ iif(_cFarm = 'S',"DATA PRODUCAO","DATA EMBALAGEM:"),"I","0",fonte2_2)   //data de produção
			MSCBSAY(37+_linP,80+_linha,_dtPROD,"I","0",fonte2_2)

			MSCBSAY(62+_linP,77+_linha,"EXPIRY DATE/DATA VALIDADE:","I","0",fonte2_2)   //data de validade - Alterado por Fabian Maurer - 02/05/12 - Correção Escrita
			MSCBSAY(37+_linP,77+_linha,_dtVALID,"I","0",fonte2_2)
			
			iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(54+_linP,71+_linha,"SLAUGHTER DATE/DATA ABATE: ","I","0",fonte2_2),)       //data de abate
			iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(37+_linP,71+_linha,_vDTABATE,"I","0",fonte2_2),)

			MSCBBOX(15,70+_linha,15,84,5) //alterar até acertar
			MSCBSAY(06,68+_linha,_DESTINO,"I","0",fonte3_5)     // Destino do produto (mover para outro lugar)


			//******************* 3º Bloco da Etiqueta ************************
			if  _cNotImp <> "P"
				MSCBLineH(01,70+_linha,300,4,"B")

				_cPb    := transform(_pesob,'@E 99.999')
				_cPesob := strtran(_cPb,',','.')
				MSCBSAY(57+_linP,66+_linha,"GROSS WEIGHT/PESO BRUTO(Kg):","I","0",fonte2_2) //peso bruto da caixa
				MSCBSAY(35+_linP,66+_linha,_cPesob,"I","0",fonte2_2)
				//transform(_pesob,'@E ##.###')

				_cPl    := transform(_pesol,'@E ##.###')
				_cPesol := strtran(_cPl,',','.')
				MSCBSAY(59+_linP,57+_linha,"NET WEIGHT/PESO LIQUIDO(Kg):","I","0",fonte2_2)
				MSCBSAY(32+_linP,57+_linha,_cPesol,"I","0",fonte3_5)   //peso liquido da caixa
				//transform(_pesol,'@E ##.###')

				_cTp    := transform(_quant * _vTaraP,'@E ##.###')
				_cTaraP := strtran(_cTp,',','.')
				MSCBSAY(48+_linP,54+_linha,"INTERNAL TARE/TARA EMB.PRIM.(Kg):","I","0",fonte2_2) //tara primaria
				MSCBSAY(35+_linP,54+_linha,_cTARAP,"I","0",fonte2_2)
				//transform(_vTARAP,'@E ##.###')

				_cTs    := transform(_vTaras,'@E ##.###')
				_cTaras := strtran(_cTs,',','.')
				MSCBSAY(70+_linP,51+_linha,"TARE/TARA EMB SEC.(Kg):","I","0",fonte2_2) //tara secundaria
				MSCBSAY(35+_linP,51+_linha,_cTARAS,"I","0",fonte2_2)
				//transform(_vTARAS,'@E ##.###')

				_cTa := transform(_tara,'@E #.###')
				_cTara := strtran(_cTa,',','.')
				MSCBSAY(63+_linP,48+_linha,"TOTAL TARE/TARA TOTAL(Kg):","I","0",fonte2_2)   //tara total da caixa
				MSCBSAY(35+_linP,48+_linha,_cTara,"I","0",fonte2_2)
				//transform(_tara,'@E #.###')

				iif(_TF == 'S',MSCBSAY(01,51+_linha,"TF","I","0",fonte2_1),) // EM CONSTRUçÂO

				MSCBLineH(01,47+_linha,300,4,"B")
			else
				MSCBLineH(01,70+_linha,300,4,"B")
				MSCBSAY(57+_linP,66+_linha,"GROSS WEIGHT/PESO BRUTO(Kg):","I","0",fonte2_2) //peso bruto da caixa
				MSCBSAY(35+_linP,66+_linha,transform(_pesob,'@E ##.###'),"I","0",fonte2_2)

				MSCBSAY(59+_linP,57+_linha,"NET WEIGHT/PESO LIQUIDO(Kg):","I","0",fonte2_2)
				MSCBSAY(32+_linP,57+_linha,transform(_pesol,'@E ##.###'),"I","0",fonte3_5)   //peso liquido da caixa

				iif(AllTrim(_classif) = 'RT',MSCBSAY(01,63+_linha,_classif,"I","0",fonte2_1),) //Falta fazer a parte da Exportação da etiqueta

				MSCBSAY(47+_linP,54+_linha,"INTERNAL TARE/TARA EMB.PRIM.(Kg):","I","0",fonte2_2) //tara primaria
				MSCBSAY(35+_linP,54+_linha,transform(_quant * _vTARAP,'@E ##.###'),"I","0",fonte2_2)

				MSCBSAY(70+_linP,51+_linha,"TARE/TARA EMB SEC.(Kg):","I","0",fonte2_2) //tara secundaria
				MSCBSAY(35+_linP,51+_linha,transform(_vTARAS,'@E ##.###'),"I","0",fonte2_2)

				MSCBSAY(63+_linP,48+_linha,"TOTAL TARE/TARA TOTAL(Kg):","I","0",fonte2_2)   //tara total da caixa
				MSCBSAY(35+_linP,48+_linha,transform(_tara,'@E #.###'),"I","0",fonte2_2)

				iif(_TF == 'S',MSCBSAY(01,51+_linha,"TF","I","0",fonte2_1),) // EM CONSTRUçÂO

				MSCBLineH(01,47+_linha,300,4,"B")
			endif

			//******************* 4º Bloco da Etiqueta ************************

			MSCBSAYBAR(43+_linP,32+_linha,'010' + _nCodBar + '310200' + substr(_cPesol,1,2) + substr(_cPesol,3,2),"I","C",13,.F.,.T.,,,3,1,.T.)  //EAN exigido pelo walmart
			iif(AllTrim(_classif) = 'RT',MSCBSAY(28+_linP,33+_linha,_classif,"I","0",fonte3_5),) //Falta fazer a parte da Exportação da etiqueta
			MSCBSAY(65,20,_Hora,"B","B",fonte4)
			MSCBSAY(30,110, _Hora,"R","0",fonte_mlr6)

			//******************* 5º Bloco da Etiqueta ************************
			MSCBLineH(01,26+_linha,300,4,"B")
			MSCBSAY(40+_linP,24+_linha,_vMENETQ,"I","B",fonte4_1)
			iif(!empty(_DESCTIPO),MSCBSAY(70+_linP,22+_linha,_DESCTIPO,"I","B",fonte4_1),)    //mensagem da temperatura
			iif(!empty(_GLUTEM),MSCBSAY(100+_linP,20+_linha,_GLUTEM,"I","B",fonte4_1),)   //Mensagem do Glutem
			iif(!empty(_SEXO),MSCBSAY(07,21+_linha,_SEXO,"I","B",fonte4_1),)

			iif(AllTrim(_classif) == 'RT',iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(55+_linP,20+_linha,"RASTREABILIDADE:","I","B",fonte4_1),),) //numero de rastro M->Z8_CLASSIF =='RT'
			iif(AllTrim(_classif) == 'RT',iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(30+_linP,20+_linha,_vRASTRO,"I","B",fonte4_1),),)

			MSCBSAY(35,100, _Hora,"R","0",fonte_mlr4)

			//******************* 6º Bloco da Etiqueta ************************
			MSCBLineH(01,19+_linha,300,4,"B")
			MSCBSAYBAR(53+_linP,7+_linha,_control,"I","C",10,.F.,.T.,,,2,1,.T.)  //numero do controle da caixa   código de barras

			MSCBSAY(79+_linP,13+_linha,_desing,"I","0",fonte2_2)		
			MSCBSAY(77+_linP,07+_linha,_despor,"I","0",fonte2_2)		

			iif(!empty(_vTIP),MSCBSAY(12+_linP,1+_linha,_vTIP,"R","0",fonte3_2),)      //codigo tipificação  Categria

			MSCBSAY(07,1+_linha,alltrim(_cod),"I","0",fonte4_2)

			If !empty(alltrim(_cSeq))
				MSCBSAY(15,1+_linha,"PE:"+_cSeq,"I","0",fonte5)
			endif
		ELSE//se for ME 

			//******************* 1º Bloco da Etiqueta ************************

			_cDescSIF :=  substr(_vDESCSIF,1,35)
			MSCBSAY(7,85+_linha,_control,"I","B",fonte3)         	//numero de controle
			MSCBSAY(72+_linP,85+_linha,_cDescSIF,"I","0",fonte2_2)   				//descrição do ingles
			MSCBSAY(41+_linP,82+_linha,_vDESCING,"I","0",fonte2_2) 					//descrição do SIF
			MSCBLineH(01,81+_linha,300,4,"B")                  //Linha Divisoria

			//******************* 2º Bloco da Etiqueta ************************

			if alltrim(_cod) $ _codExp				
				MSCBSAY(53+_linP,77+_linha,"PROD.DATE/LOT /DATA PROD.LOTE","I","0",fonte2_2)   //data de produção
				MSCBSAY(37+_linP,77+_linha,_dtPROD,"I","0",fonte2_2)
			else
				MSCBSAY(53+_linP,77+_linha,"PACKING DATE/" + iif(_cFarm = 'S',"DATA PRODUCAO","DATA EMBALAGEM:"),"I","0",fonte2_2)   //data de produção
				MSCBSAY(37+_linP,77+_linha,_dtPROD,"I","0",fonte2_2)

				iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(54+_linP,64+_linha,"SLAUGHTER DATE/DATA ABATE: ","I","0",fonte2_2),)       //data de abate
				iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(37+_linP,64+_linha,_vDTABATE,"I","0",fonte2_2),)
			endif                        

			MSCBSAY(62+_linP,73+_linha,"EXPIRY DATE/DATA VALIDADE:","I","0",fonte2_2)   //data de validade - Alterado por Fabian Maurer - 02/05/12 - Correção Escrita
			MSCBSAY(37+_linP,73+_linha,_dtVALID,"I","0",fonte2_2)

			/*Removido a pedido do Sr. Matheus Silva*/
			/*Dia 02/11/16 - pedido (Angela com concentimento do Sr Matheus Silva) de recolocar para imprimir a quant. de peças*/
			//MSCBSAY(94+_linP,73,"PIECE/PECA :","I","0",fonte2_2)    //quantidade de peças dentro da caixa
			//MSCBSAY(90+_linP,73,transform(_quant,'@E ######'),"I","0",fonte2_2)     //Quantidade de peças

			iif(AllTrim(_classif) == 'RT',iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(78+_linP,60+_linha,"RASTREABILIDADE :","I","0",fonte2_2),),) //numero de rastro M->Z8_CLASSIF =='RT'
			iif(AllTrim(_classif) == 'RT',iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(36+_linP,60+_linha,_vRASTRO,"I","0",fonte2_2),),)

			MSCBSAY(35,100, _Hora,"R","0",fonte_mlr4)

			MSCBBOX(15,60+_linha,15,81,5) //alterar até acertar
			MSCBSAY(06,68+_linha,_DESTINO,"I","0",fonte3_5)     // Destino do produto (mover para outro lugar)

			//******************* 3º Bloco da Etiqueta ************************
			if  _cNotImp <> "P"
				MSCBLineH(01,60+_linha,300,4,"B")

				_cPb    := transform(_pesob,'@E 99.999')
				_cPesob := strtran(_cPb,',','.')
				MSCBSAY(57+_linP,54+_linha,"GROSS WEIGHT/PESO BRUTO(Kg):","I","0",fonte2_2) //peso bruto da caixa
				MSCBSAY(35+_linP,54+_linha,_cPesob,"I","0",fonte2_2)

				_cPl    := transform(_pesol,'@E ##.###')
				_cPesol := strtran(_cPl,',','.')
				MSCBSAY(59+_linP,44+_linha,"NET WEIGHT/PESO LIQUIDO(Kg):","I","0",fonte2_2)
				MSCBSAY(30+_linP,42+_linha,_cPesol,"I","0",fonte1_2)   //peso liquido da caixa

				_cTp    := transform(_quant * _vTaraP,'@E ##.###')
				_cTaraP := strtran(_cTp,',','.')
				MSCBSAY(48+_linP,40+_linha,"INTERNAL TARE/TARA EMB.PRIM.(Kg):","I","0",fonte2_2) //tara primaria
				MSCBSAY(35+_linP,40+_linha,_cTARAP,"I","0",fonte2_2)

				_cTs    := transform(_vTaras,'@E ##.###')
				_cTaras := strtran(_cTs,',','.')
				MSCBSAY(70+_linP,37+_linha,"TARE/TARA EMB SEC.(Kg):","I","0",fonte2_2) //tara secundaria
				MSCBSAY(35+_linP,37+_linha,_cTARAS,"I","0",fonte2_2)

				_cTa   := transform(_tara,'@E #.###')
				_cTara := strtran(_cTa,',','.')
				MSCBSAY(63+_linP,34+_linha,"TOTAL TARE/TARA TOTAL(Kg):","I","0",fonte2_2)   //tara total da caixa
				MSCBSAY(35+_linP,34+_linha,_cTara,"I","0",fonte2_2)

				iif(_TF == 'S',MSCBSAY(01,40+_linha,"TF","I","0",fonte2_1),) // EM CONSTRUçÂO
			else
				MSCBLineH(01,60+_linha,300,4,"B")
				MSCBSAY(57+_linP,54+_linha,"GROSS WEIGHT/PESO BRUTO(Kg):","I","0",fonte2_2) //peso bruto da caixa
				MSCBSAY(35+_linP,54+_linha,transform(_pesob,'@E ##.###'),"I","0",fonte2_2)

				MSCBSAY(59+_linP,44+_linha,"NET WEIGHT/PESO LIQUIDO(Kg):","I","0",fonte2_2)
				MSCBSAY(30+_linP,42+_linha,transform(_pesol,'@E ##.###'),"I","0",fonte1_2)   //peso liquido da caixa

				MSCBSAY(48+_linP,40+_linha,"INTERNAL TARE/TARA EMB.PRIM.(Kg):","I","0",fonte2_2) //tara primaria
				MSCBSAY(35+_linP,40+_linha,transform(_quant * _vTARAP,'@E ##.###'),"I","0",fonte2_2)

				MSCBSAY(70+_linP,37+_linha,"TARE/TARA EMB SEC.(Kg):","I","0",fonte2_2) //tara secundaria
				MSCBSAY(35+_linP,37+_linha,transform(_vTARAS,'@E ##.###'),"I","0",fonte2_2)

				MSCBSAY(63+_linP,34+_linha,"TOTAL TARE/TARA TOTAL(Kg):","I","0",fonte2_2)   //tara total da caixa
				MSCBSAY(35+_linP,34+_linha,transform(_tara,'@E #.###'),"I","0",fonte2_2)

				iif(_TF == 'S',MSCBSAY(01,40+_linha,"TF","I","0",fonte2_1),) // EM CONSTRUçÂO

				//MSCBLineH(01,30,300,4,"B")
			endif
			//******************* 4º Bloco da Etiqueta ************************
			MSCBLineH(01,32+_linha,300,4,"B")
			MSCBSAY(42+_linP,27+_linha,_vMENETQ,"I","0",fonte5_1)
			MSCBSAY(30,110, _Hora,"R","0",fonte_mlr6)

			_cPrdArg := getMv('SI_PRDARG')

			If alltrim(_cod) $ _cPrdArg
				MSCBSAY(05,20+_linha,'VENTA AL PESO. No Recongelar',"I","0",fonte5_1)
			endif

			iif(!empty(_DESCTIPO),MSCBSAY(72+_linP,24+_linha,_DESCTIPO,"I","0",fonte5_1),)    //mensagem da temperatura

			iif(!empty(_GLUTEM),MSCBSAY(97+_linP,21+_linha,_GLUTEM,"I","0",fonte5_1),)   //Mensagem do Glutem

			iif(!empty(_SEXO),MSCBSAY(65,21+_linha,_SEXO,"I","0",fonte5_1),)

			iif(AllTrim(_classif) = 'RT',MSCBSAY(25+_linP,21+_linha,_classif,"I","0",fonte3_5),) //Falta fazer a parte da Exportação da etiqueta

			//BLOCO REMOVIDO TEMPORARIAMENTE POIS PERDERAM A HABILITAÇÃO PARA A RUSSIA		
			/*if AllTrim(_classif) == 'RU'        
			MSCBBOX(17+_linP,21,30+_linP,25,80,"B")   //Box preto onde fica o EAC
			MSCBSAY(15+_linP,21,'EAC',"I","0","60,45",.t.)			
			endif*/

			iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBBOX(21+_linha,19+_linha,21,32,5),)

			iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(30+_linP,20+_linha,"LOTE:","I","0",fonte2_2),)    //Lote
			iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(23+_linP,20+_linha,_Lote,"I","0",fonte2_2),)  //descricao do lote preenchido no lançamento da OP da embalagem

			//******************* 5º Bloco da Etiqueta ************************
			MSCBLineH(01,19+_linha,300,4,"B")
			MSCBSAYBAR(53+_linP,7+_linha,_control,"I","C",10,.F.,.T.,,,2,1,.T.)  //numero do controle da caixa   código de barras

			MSCBSAY(79+_linP,13+_linha,_desing,"I","B",fonte3)
			MSCBSAY(77+_linP,07+_linha,_despor,"I","B",fonte3)

			iif(!empty(_vTIP),MSCBSAY(12+_linP,1+_linha,_vTIP,"R","0",fonte3_2),)      //codigo tipificação  Categria

			MSCBSAY(07,1+_linha,alltrim(_cod),"I","0",fonte4_2)

			If !empty(alltrim(_cSeq))
				MSCBSAY(15,1+_linha,"PE:"+_cSeq,"I","0",fonte5)
			endif
		ENDIF

		MSCBEND()
		MSCBCLOSEPRINTER()

		//**************************** Inicio Etiqueta França ****************************\\
	elseif(_etq='F')
		_linP := -20
		MSCBPRINTER(_modelo,_porta)
		//MSCBPRINTER(_modelo,'COM3:9600,n,8,1')
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(_nNumEtq,6,40)
		// Posição d codigo de barras
		fonte1  :="40,20"
		fonte1_1:="30,15"
		fonte1_2:="85,85" //100/50
		fonte1_3:="38,12"
		fonte2  :="35,30"
		fonte2_1:="100,100"
		fonte2_2:="25,35"
		fonte2_3:="20,23"
		fonte2_4:="35,30"
		fonte2_5:="25,20" // Trocando até acertar
		fonte3  :="35,12"//42
		fonte3_1:="40,45"
		f_extra :="30,22"
		fonte3_2:="84,90"
		fonte3_3:="24,15"
		fonte3_4:="45,30"
		fonte3_5 := "70,55"
		fonte4  :="20,5"
		fonte4_1:="16,8"
		fsexo   :="65,50"
		fonte4_2:="120,65"
		fonte5  :="25,25"
		fonte5_1 := "20,18"

		//******************* 1º Bloco da Etiqueta ************************

		_cDescSIF :=  substr(_vDESCSIF,1,35)

		MSCBSAY(7,85,_control,"I","B",fonte3)         	//numero de controle
		MSCBSAY(75+_linP,85,_vDESCFRA,"I","0",fonte2_2)   				//descrição do ingles

		MSCBSAY(44+_linP,82,_cDescSIF,"I","0",fonte2_2) 					//descrição do SIF

		MSCBLineH(01,81,300,4,"B")                  //Linha Divisoria

		//******************* 2º Bloco da Etiqueta ************************

		MSCBSAY(58+_linP,77,"DATE D' EMBALLAGE/DATA EMBALAGEM:","I","0",fonte2_2)   //data de produção
		MSCBSAY(37+_linP,77,_dtPROD,"I","0",fonte2_2)

		MSCBSAY(66+_linP,73,"DATE DE VALIDITE/DATA VALIDADE:","I","0",fonte2_2)   //data de validade - Alterado por Fabian Maurer - 02/05/12 - Correção Escrita
		MSCBSAY(37+_linP,73,_dtVALID,"I","0",fonte2_2)

		//MSCBSAY(97+_linP,68,"PIECE/PECA :","I","0",fonte2_2)    //quantidade de peças dentro da caixa
		//MSCBSAY(95+_linP,68,transform(_quant,'@E ######'),"I","0",fonte2_2)     //Quantidade de peças

		iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(88+_linP,64,"SLAUGHTER DATE/DATA ABATE: ","I","0",fonte2_2),)       //data de abate
		iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(37+_linP,64,_vDTABATE,"I","0",fonte2_2),)

		iif(AllTrim(_classif) == 'RT',iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(57+_linP,60,"RASTREABILIDADE :","I","0",fonte2_2),),) //numero de rastro M->Z8_CLASSIF =='RT'
		iif(AllTrim(_classif) == 'RT',iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(36+_linP,60,_vRASTRO,"I","0",fonte2_2),),)

		MSCBBOX(15,60,15,81,5) //alterar até acertar
		MSCBSAY(06,68,_DESTINO,"I","0",fonte3_5)     // Destino do produto (mover para outro lugar)

		//******************* 3º Bloco da Etiqueta ************************

		MSCBLineH(01,60,300,4,"B")
		MSCBSAY(60+_linP,54,"POIDS BRUT/PESO BRUTO(Kg):","I","0",fonte2_2) //peso bruto da caixa
		MSCBSAY(35+_linP,54,transform(_pesob,'@E ##.###'),"I","0",fonte2_2)

		MSCBSAY(62+_linP,44,"POIDS NET/PESO LIQUIDO(Kg):","I","0",fonte2_2)
		MSCBSAY(30+_linP,42,transform(_pesol,'@E ##.###'),"I","0",fonte1_2)   //peso liquido da caixa

		iif(AllTrim(_classif) = 'RT',MSCBSAY(01,44,_classif,"I","0",fonte2_1),) //Falta fazer a parte da Exportação da etiqueta

		MSCBSAY(51+_linP,40,"INTERNAL TARE/TARA EMB.PRIM.(Kg):","I","0",fonte2_2) //tara primaria
		MSCBSAY(35+_linP,40,transform(_vTARAP,'@E ##.###'),"I","0",fonte2_2)

		MSCBSAY(73+_linP,37,"TARE/TARA EMB SEC.(Kg):","I","0",fonte2_2) //tara secundaria
		MSCBSAY(35+_linP,37,transform(_vTARAS,'@E ##.###'),"I","0",fonte2_2)

		MSCBSAY(66+_linP,34,"TOTAL TARE/TARA TOTAL(Kg):","I","0",fonte2_2)   //tara total da caixa
		MSCBSAY(35+_linP,34,transform(_tara,'@E #.###'),"I","0",fonte2_2)

		iif(_TF == 'S',MSCBSAY(01,40,"TF","I","0",fonte2_1),) // EM CONSTRUçÂO

		//MSCBLineH(01,30,300,4,"B")

		//******************* 4º Bloco da Etiqueta ************************
		MSCBLineH(01,32,300,4,"B")
		MSCBSAY(43+_linP,27,_vMENETQ,"I","0",fonte5_1)

		iif(!empty(_DESCTIPO),MSCBSAY(75+_linP,24,_DESCTIPO,"I","0",fonte5_1),)    //mensagem da temperatura

		iif(!empty(_GLUTEM),MSCBSAY(100+_linP,21,_GLUTEM,"I","0",fonte5_1),)   //Mensagem do Glutem

		iif(!empty(_SEXO),MSCBSAY(65,21,_SEXO,"I","0",fonte5_1),)

		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBBOX(21,19,21,32,5),)

		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(30+_linP,20,"LOTE:","I","0",fonte2_2),)    //Lote
		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(23+_linP,20,_Lote,"I","0",fonte2_2),)  //descricao do lote preenchido no lançamento da OP da embalagem

		MSCBSAY(35,100, _Hora,"R","0",fonte_mlr4)

		//******************* 5º Bloco da Etiqueta ************************
		MSCBLineH(01,19,300,4,"B")
		MSCBSAYBAR(53+_linP,7,_control,"I","C",10,.F.,.T.,,,2,1,.T.)  //numero do controle da caixa   código de barras

		MSCBSAY(79+_linP,13,_desfra,"I","B",fonte3)
		MSCBSAY(77+_linP,07,_despor,"I","B",fonte3)

		iif(!empty(_vTIP),MSCBSAY(12+_linP,1,_vTIP,"R","0",fonte3_2),)      //codigo tipificação  Categria

		MSCBSAY(07,1,alltrim(_cod),"I","0",fonte4_2)

		If !empty(alltrim(_cSeq))
			MSCBSAY(15,1,"PE:"+_cSeq,"I","0",fonte5)
		endif

		MSCBEND()
		MSCBCLOSEPRINTER()

		//**************************** Inicio Etiqueta Espanha ****************************\\

	elseif(_etq='E')
		_linP := -20

		MSCBPRINTER(_modelo,_porta,,,,,_IP)

		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(_nNumEtq,6,40)
		// Posição d codigo de barras
		fonte1  :="40,20"
		fonte1_1:="30,15"
		fonte1_2:="85,85" //100/50
		fonte1_3:="38,12"
		fonte2  :="35,30"
		fonte2_1:="100,100"
		fonte2_2:="25,35"
		fonte2_3:="20,23"
		fonte2_4:="35,30"
		fonte2_5:="25,20" // Trocando até acertar
		fonte3  :="35,12"//42
		fonte3_1:="40,45"
		f_extra :="30,22"
		fonte3_2:="84,90"
		fonte3_3:="24,15"
		fonte3_4:="45,30"
		fonte3_5 := "70,55"
		fonte4  :="20,5"
		fonte4_1:="16,8"
		fsexo   :="65,50"
		fonte4_2:="120,65"
		fonte5  :="25,25"
		fonte5_1 := "20,18"
		fonte_mlr4 := "20,18"

		IF SB1->B1_DESTINO == 'MI'

			//******************* 1º Bloco da Etiqueta ************************

			_cDescSIF :=  substr(_vDESCSIF,1,35)

			MSCBSAY(7,88+_linha,_control,"I","0",fonte2_2)         	//numero de controle
			MSCBSAY(73+_linP,88+_linha,_cDescSIF,"I","0",fonte2_2)   				//descrição do ingles

			MSCBSAY(44+_linP,85+_linha,_vDESCING,"I","0",fonte2_2) 					//descrição do SIF

			MSCBLineH(01,84+_linha,300,4,"B")                  //Linha Divisoria

			//******************* 2º Bloco da Etiqueta ************************

			MSCBSAY(57+_linP,80+_linha,"FECHA DE ENVASE/"+ iif(_cFarm = 'S',"DATA PRODUCAO","DATA EMBALAGEM:"),"I","0",fonte2_2)   //data de produção
			MSCBSAY(37+_linP,80+_linha,_dtPROD,"I","0",fonte2_2)

			MSCBSAY(65+_linP,77+_linha,"FECHA DE VALIDAD/DATA VALIDADE:","I","0",fonte2_2)   //data de validade - Alterado por Fabian Maurer - 02/05/12 - Correção Escrita
			MSCBSAY(37+_linP,77+_linha,_dtVALID,"I","0",fonte2_2)

			//MSCBSAY(96+_linP,74+_linha,"PIEZA/PECA :","I","0",fonte2_2)    //quantidade de peças dentro da caixa
			//MSCBSAY(87+_linP,74+_linha,transform(_quant,'@E ######'),"I","0",fonte2_2)     //Quantidade de peças

			iif(AllTrim(_classif) = 'RT',MSCBSAY(06,48+_linha,_classif,"I","0",fonte3_5),) 
			iif(AllTrim(_classif) == 'RT',iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(39+_linP,71+_linha,"RASTREABILIDADE :"+_vRASTRO,"I","0",fonte2_2),),) //numero de rastro M->Z8_CLASSIF =='RT'

			MSCBBOX(15,70+_linha,15,84+_linha,5) //alterar até acertar
			MSCBSAY(06,68+_linha,_DESTINO,"I","0",fonte3_5)     // Destino do produto (mover para outro lugar)

			//******************* 3º Bloco da Etiqueta ************************
			if  _cNotImp <> "P"
				MSCBLineH(01,70+_linha,300,4,"B")

				_cPb    := transform(_pesob,'@E 99.999')
				_cPesob := strtran(_cPb,',','.')
				MSCBSAY(59+_linP,66+_linha,"PESO BRUTO/PESO BRUTO(Kg):","I","0",fonte2_2) //peso bruto da caixa
				MSCBSAY(35+_linP,66+_linha,_cPesob,"I","0",fonte2_2)
				//transform(_pesob,'@E ##.###')

				_cPl    := transform(_pesol,'@E ##.###')
				_cPesol := strtran(_cPl,',','.')
				MSCBSAY(61+_linP,57+_linha,"PESO NETO/PESO LIQUIDO(Kg):","I","0",fonte2_2)
				MSCBSAY(32+_linP,57+_linha,_cPesol,"I","0",fonte3_5)   //peso liquido da caixa
				//transform(_pesol,'@E ##.###')

				_cTp    := transform(_quant * _vTaraP,'@E ##.###')
				_cTaraP := strtran(_cTp,',','.')
				MSCBSAY(50+_linP,54+_linha,"TARA ENV.PRIM./TARA EMB.PRIM.(Kg):","I","0",fonte2_2) //tara primaria
				MSCBSAY(35+_linP,54+_linha,_cTARAP,"I","0",fonte2_2)
				//transform(_vTARAP,'@E ##.###')

				_cTs    := transform(_vTaras,'@E ##.###')
				_cTaras := strtran(_cTs,',','.')
				MSCBSAY(72+_linP,51+_linha,"TARA ENV.SEC./TARA EMB SEC.(Kg):","I","0",fonte2_2) //tara secundaria
				MSCBSAY(35+_linP,51+_linha,_cTARAS,"I","0",fonte2_2)
				//transform(_vTARAS,'@E ##.###')

				_cTa := transform(_tara,'@E #.###')
				_cTara := strtran(_cTa,',','.')
				MSCBSAY(65+_linP,48+_linha,"TARA TOTAL/TARA TOTAL(Kg):","I","0",fonte2_2)   //tara total da caixa
				MSCBSAY(35+_linP,48+_linha,_cTara,"I","0",fonte2_2)
				//transform(_tara,'@E #.###')

				iif(_TF == 'S',MSCBSAY(01,51+_linha,"TF","I","0",fonte2_1),) // EM CONSTRUçÂO

				MSCBLineH(01,47+_linha,300,4,"B")
			else
				MSCBLineH(01,70+_linha,300,4,"B")
				MSCBSAY(59+_linP,66+_linha,"PESO BRUTO/PESO BRUTO(Kg):","I","0",fonte2_2) //peso bruto da caixa
				MSCBSAY(35+_linP,66+_linha,transform(_pesob,'@E ##.###'),"I","0",fonte2_2)

				MSCBSAY(61+_linP,57+_linha,"PESO NETO/PESO LIQUIDO(Kg):","I","0",fonte2_2)
				MSCBSAY(32+_linP,57+_linha,transform(_pesol,'@E ##.###'),"I","0",fonte3_5)   //peso liquido da caixa

				iif(AllTrim(_classif) = 'RT',MSCBSAY(01,63+_linha,_classif,"I","0",fonte2_1),) //Falta fazer a parte da Exportação da etiqueta

				MSCBSAY(50+_linP,54+_linha,"TARA ENV.PRIM./TARA EMB.PRIM.(Kg):","I","0",fonte2_2) //tara primaria
				MSCBSAY(35+_linP,54+_linha,transform(_quant * _vTARAP,'@E ##.###'),"I","0",fonte2_2)

				MSCBSAY(72+_linP,51+_linha,"TARA ENV.SEC./TARA EMB SEC.(Kg):","I","0",fonte2_2) //tara secundaria
				MSCBSAY(35+_linP,51+_linha,transform(_vTARAS,'@E ##.###'),"I","0",fonte2_2)

				MSCBSAY(65+_linP,48+_linha,"TARA TOTAL/TARA TOTAL(Kg):","I","0",fonte2_2)   //tara total da caixa
				MSCBSAY(35+_linP,48+_linha,transform(_tara,'@E #.###'),"I","0",fonte2_2)

				iif(_TF == 'S',MSCBSAY(01,51+_linha,"TF","I","0",fonte2_1),) // EM CONSTRUçÂO

				MSCBLineH(01,47+_linha,300,4,"B")
			endif

			//******************* 4º Bloco da Etiqueta ************************

			MSCBSAYBAR(38+_linP,32+_linha,'010' + _nCodBar + '310200' + substr(_cPesol,1,2) + substr(_cPesol,3,2),"I","C",13,.F.,.T.,,,3,1,.T.)  //EAN exigido pelo walmart
			MSCBSAY(65,20,_Hora,"B","B",fonte4)
			MSCBSAY(30,110, _Hora,"R","0",fonte_mlr6)

			//******************* 5º Bloco da Etiqueta ************************
			MSCBLineH(01,26+_linha,300,4,"B")
			MSCBSAY(40+_linP,24+_linha,_vMENETQ,"I","B",fonte4_1)
			iif(!empty(_DESCTIPO),MSCBSAY(75+_linP,22+_linha,_DESCTIPO,"I","B",fonte4_1),)    //mensagem da temperatura
			iif(!empty(_GLUTEM),MSCBSAY(100+_linP,20+_linha,_GLUTEM,"I","B",fonte4_1),)   //Mensagem do Glutem
			iif(!empty(_SEXO),MSCBSAY(07,21+_linha,_SEXO,"I","B",fonte4_1),)

			_cPrdArg := getMv('SI_PRDARG')

			If alltrim(_cod) $ _cPrdArg
				MSCBSAY(40+_linP,24+_linha,'VENTA AL PESO. No Recongelar',"I","0",fonte5_1)
			endif

			//******************* 6º Bloco da Etiqueta ************************
			MSCBLineH(01,19+_linha,300,4,"B")
			MSCBSAYBAR(53+_linP,7+_linha,_control,"I","C",10,.F.,.T.,,,2,1,.T.)  //numero do controle da caixa   código de barras

			MSCBSAY(79+_linP,13+_linha,_desing,"I","B",fonte3)
			MSCBSAY(77+_linP,07+_linha,_despor,"I","B",fonte3)

			iif(!empty(_vTIP),MSCBSAY(12+_linP,1+_linha,_vTIP,"R","0",fonte3_2),)      //codigo tipificação  Categria

			MSCBSAY(07,1+_linha,alltrim(_cod),"I","0",fonte4_2)

			If !empty(alltrim(_cSeq))
				MSCBSAY(15,1+_linha,"PE:"+_cSeq,"I","0",fonte5)
			endif

			MSCBSAY(73+_linP,1+_linha,"CONTROLADO POR DETECTOR DE METALES","I","0",fonte_mlr4)
		ELSE//Se for ME
			//******************* 1º Bloco da Etiqueta ************************

			_cDescSIF :=  substr(_vDESCSIF,1,35)

			MSCBSAY(7,89+_linha,_control,"I","B",fonte3)         	//numero de controle
			MSCBSAY(41+_linP,85+_linha,_cDescSIF,"I","0",fonte2_2)   				//descrição do ingles

			MSCBSAY(43+_linP,82+_linha,_vDESCING,"I","0",fonte2_2) 					//descrição do SIF

			MSCBLineH(01,81+_linha,300,4,"B")                  //Linha Divisoria

			//******************* 2º Bloco da Etiqueta ************************		            		

			//MSCBSAY(53+_linP,77+_linha,"FECHA DE PRODUCCION/DT. PROD.:","I","0",fonte2_2)   //data de produção
			MSCBSAY(53+_linP,77+_linha,"FECHA EMBALJE/ DATA DE EMBALAGEM:","I","0",fonte2_2)   //data de produção
			MSCBSAY(37+_linP,77+_linha,_dtPROD,"I","0",fonte2_2)

			//MSCBSAY(57+_linP,73+_linha,"FECHA DE VALIDAD/DATA VALID.:","I","0",fonte2_2)   //data de validade - Alterado por Fabian Maurer - 02/05/12 - Correção Escrita
			MSCBSAY(57+_linP,73+_linha,"FECHA DE VALIDAD/DATA DE VALIDADE:","I","0",fonte2_2)   //data de validade - Alterado por Fabian Maurer - 02/05/12 - Correção Escrita
			MSCBSAY(37+_linP,73+_linha,_dtVALID,"I","0",fonte2_2)

			//MSCBSAY(93+_linP,68+_linha,"PIEZA/PECA :","I","0",fonte2_2)    //quantidade de peças dentro da caixa
			//MSCBSAY(90+_linP,68+_linha,transform(_quant,'@E ######'),"I","0",fonte2_2)     //Quantidade de peças

			//iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(85+_linP,64+_linha,"FECHA DE ABATE: ","I","0",fonte2_2),)       //data de abate
			iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(61+_linP,64+_linha,"FECHA PROD./ ABATE/ DATA DE PROD.: ","I","0",fonte2_2),)       //data de abate
			iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(37+_linP,64+_linha,_vDTABATE,"I","0",fonte2_2),)

			iif(AllTrim(_classif) = 'RT',MSCBSAY(06,32+_linha,_classif,"I","0",fonte3_5),) //Falta fazer a parte da Exportação da etiqueta
			iif(AllTrim(_classif) == 'RT',iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(39+_linP,60+_linha,"RASTREABILIDADE :"+_vRASTRO,"I","0",fonte2_2),),) //numero de rastro M->Z8_CLASSIF =='RT'

			MSCBSAY(35,100, _Hora,"R","0",fonte_mlr4)

			MSCBBOX(15,60+_linha,15,81+_linha,5) //alterar até acertar
			MSCBSAY(06,68+_linha,_DESTINO,"I","0",fonte3_5)     // Destino do produto (mover para outro lugar)

			//******************* 3º Bloco da Etiqueta ************************
			if  _cNotImp <> "P"
				MSCBLineH(01,60+_linha,300,4,"B")

				_cPb    := transform(_pesob,'@E 99.999')
				_cPesob := strtran(_cPb,',','.')
				MSCBSAY(61+_linP,54+_linha,"PESO BRUTO/PESO BRUTO(Kg):","I","0",fonte2_2) //peso bruto da caixa
				MSCBSAY(35+_linP,54+_linha,_cPesob,"I","0",fonte2_2)

				_cPl    := transform(_pesol,'@E ##.###')
				_cPesol := strtran(_cPl,',','.')
				MSCBSAY(61+_linP,44+_linha,"PESO NETO/PESO LIQUIDO(Kg):","I","0",fonte2_2)
				MSCBSAY(30+_linP,42+_linha,_cPesol,"I","0",fonte1_2)   //peso liquido da caixa

				_cTp    := transform(_quant * _vTaraP,'@E ##.###')
				_cTaraP := strtran(_cTp,',','.')
				MSCBSAY(46+_linP,40+_linha,"TARA ENV.PRIM./TARA EMB.PRIM.(Kg):","I","0",fonte2_2) //tara primaria
				MSCBSAY(35+_linP,40+_linha,_cTARAP,"I","0",fonte2_2)

				_cTs    := transform(_vTaras,'@E ##.###')
				_cTaras := strtran(_cTs,',','.')
				MSCBSAY(51+_linP,37+_linha,"TARA ENV.SEC./TARA EMB SEC.(Kg):","I","0",fonte2_2) //tara secundaria
				MSCBSAY(35+_linP,37+_linha,_cTARAS,"I","0",fonte2_2)

				_cTa   := transform(_tara,'@E #.###')
				_cTara := strtran(_cTa,',','.')
				MSCBSAY(62+_linP,34+_linha,"TARA TOTAL/TARA TOTAL(Kg):","I","0",fonte2_2)   //tara total da caixa
				MSCBSAY(35+_linP,34+_linha,_cTara,"I","0",fonte2_2)

				iif(_TF == 'S',MSCBSAY(01,40+_linha,"TF","I","0",fonte2_1),) // EM CONSTRUçÂO
			else
				MSCBLineH(01,60+_linha,300,4,"B")
				MSCBSAY(61+_linP,54+_linha,"PESO BRUTO/PESO BRUTO(Kg):","I","0",fonte2_2) //peso bruto da caixa
				MSCBSAY(35+_linP,54+_linha,transform(_pesob,'@E ##.###'),"I","0",fonte2_2)

				MSCBSAY(61+_linP,44+_linha,"PESO NETO/PESO LIQUIDO(Kg):","I","0",fonte2_2)
				MSCBSAY(30+_linP,42+_linha,transform(_pesol,'@E ##.###'),"I","0",fonte1_2)   //peso liquido da caixa

				iif(AllTrim(_classif) = 'RT',MSCBSAY(01,44+_linha,_classif,"I","0",fonte2_1),) //Falta fazer a parte da Exportação da etiqueta

				MSCBSAY(46+_linP,40+_linha,"TARA ENV.PRIM./TARA EMB.PRIM.(Kg):","I","0",fonte2_2) //tara primaria
				MSCBSAY(35+_linP,40+_linha,transform(_quant * _vTARAP,'@E ##.###'),"I","0",fonte2_2)

				MSCBSAY(51+_linP,37+_linha,"TARA ENV.SEC./TARA EMB SEC.(Kg):","I","0",fonte2_2) //tara secundaria
				MSCBSAY(35+_linP,37+_linha,transform(_vTARAS,'@E ##.###'),"I","0",fonte2_2)

				MSCBSAY(62+_linP,34+_linha,"TARA TOTAL/TARA TOTAL(Kg):","I","0",fonte2_2)   //tara total da caixa
				MSCBSAY(35+_linP,34+_linha,transform(_tara,'@E #.###'),"I","0",fonte2_2)

				iif(_TF == 'S',MSCBSAY(01,40+_linha,"TF","I","0",fonte2_1),) // EM CONSTRUçÂO

				//MSCBLineH(01,30,300,4,"B")
			endif
			//******************* 4º Bloco da Etiqueta ************************
			MSCBLineH(01,32+_linha,300,4,"B")
			MSCBSAY(41+_linP,27+_linha,_vMENETQ,"I","0",fonte5_1)
			MSCBSAY(30,110, _Hora,"R","0",fonte_mlr6)

			_cPrdArg := getMv('SI_PRDARG')

			If alltrim(_cod) $ _cPrdArg
				MSCBSAY(72+_linP,24+_linha,'VENTA AL PESO. No Recongelar',"I","0",fonte5_1)
			endif

			iif(!empty(_DESCTIPO),MSCBSAY(72+_linP,24+_linha,_DESCTIPO,"I","0",fonte5_1),)    //mensagem da temperatura

			iif(!empty(_GLUTEM),MSCBSAY(96+_linP,21+_linha,_GLUTEM,"I","0",fonte5_1),)   //Mensagem do Glutem

			iif(!empty(_SEXO),MSCBSAY(57,21+_linha,_SEXO,"I","0",fonte5_1),)

			iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBBOX(21,19+_linha,21,32+_linha,5),)

			iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(30+_linP,20+_linha,"LOTE:","I","0",fonte2_2),)    //Lote
			iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(23+_linP,20+_linha,_Lote,"I","0",fonte2_2),)  //descricao do lote preenchido no lançamento da OP da embalagem

			//******************* 5º Bloco da Etiqueta ************************
			MSCBLineH(01,19+_linha,300,4,"B")
			MSCBSAYBAR(53+_linP,7+_linha,_control,"I","C",10,.F.,.T.,,,2,1,.T.)  //numero do controle da caixa   código de barras

			MSCBSAY(79+_linP,13+_linha,_desing,"I","B",fonte3)
			MSCBSAY(77+_linP,07+_linha,_despor,"I","B",fonte3)

			iif(!empty(_vTIP),MSCBSAY(12+_linP,1+_linha,_vTIP,"R","0",fonte3_2),)      //codigo tipificação  Categria

			MSCBSAY(07,1+_linha,alltrim(_cod),"I","0",fonte4_2)

			If !empty(alltrim(_cSeq))
				MSCBSAY(15,2+_linha,"PE:"+_cSeq,"I","0",fonte5)
			endif

			MSCBSAY(60,4+_linha,"CONTROLADO POR DETECTOR DE METALES","I","0",fonte5_1)

			iif(AllTrim(_classif) = 'RT',MSCBSAY(36,107,_classif,"R","0",fonte2_1),)
			iif(AllTrim(_classif) == 'RT',iif(!empty(_predes),MSCBSAY(30,05,"RASTREABILIDADE :" + _vRASTRO,"R","0",fonte_mlr4),),) 	// Descrição Rastreabilidade
		ENDIF

		MSCBEND()
		MSCBCLOSEPRINTER()
	endif

	/*************************** Etiqueta Caixa 3  ************************************************ */

	if(_etq='3')
		MSCBPRINTER(_modelo,_porta)
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(_nNumEtq,6,40)

		fonte1  :="40,20"
		fonte1_1:="30,15"
		fonte1_2:="100,60"
		fonte1_3:="38,12"
		fonte2  :="35,30"
		fonte2_1:="75,75"
		fonte2_2:="25,35"
		fonte2_3:="20,23"
		fonte2_4:="35,30"
		fonte2_5:="25,20" // Trocando até acertar
		fonte3  :="42,12"
		fonte3_1:="40,45"
		f_extra :="30,22"
		fonte3_2:="84,90"
		fonte3_3:="24,15"
		fonte3_4:="45,30"
		fonte4  :="20,5"
		fonte4_1:="16,8"
		fsexo := "65,50"
		// Primeiro Bloco da Etiqueta

		_cDescSIF :=  substr(_vDESCSIF,1,35)
		//numero de controle da caixa    Parte de cima da etiqueta
		MSCBSAY(01,67,_control,"I","0",fonte3_1)         	//numero de controle
		MSCBSAY(60,68,_vDESCING,"I","B",fonte1_3)   				//descrição do ingles
		//MSCBSAY(90,61,_vDESCSIF,"I","B",fonte3) 					//descrição do SIF
		MSCBSAY(30,62,_cDescSIF,"I","B",fonte1_3) 					//descrição do SIF
		//MSCBSAY(68,115,"(s)","R","0",f_extra) 					// marcação de etiqueta para diferenciar das do controle
		MSCBLineH(01,61,300,5,"B")

		//*******Segundo Bloco da Etiqueta
		MSCBSAY(46,57,"PACKING DATE /"+ iif(_cFarm = 'S',"DATA PRODUCAO", "DATA EMBALAGEM :"),"I","0",fonte2_2)   //data de produção
		MSCBSAY(26,57,_dtPROD,"I","0",fonte2_2)
		//MSCBSAY(53,54,"BEST BEFORE / DATA VALIDADE :","I","0",fonte2_2)   //data de validade
		MSCBSAY(53,54,"EXPIRY DATE / DATA VALIDADE :","I","0",fonte2_2)   //data de validade - Alterado por Fabian Maurer - 02/05/12 - Correção Escrita
		MSCBSAY(26,54,_dtVALID,"I","0",fonte2_2)
		MSCBSAY(07,49,_DESTINO,"I","0",fonte2_1)     // Destino do produto
		iif(AllTrim(_classif) == 'RT',iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(77,50,"RASTREABILIDADE :","I","0",fonte2_2),),) //numero de rastro M->Z8_CLASSIF =='RT'
		iif(AllTrim(_classif) == 'RT',iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,50,_vRASTRO,"I","0",fonte2_2),),)
		iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(81,47,"DATA ABATE: ","I","0",fonte2_2),)       //data de abate
		iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(54,47,_vDTABATE,"I","0",fonte2_2),)
		//MSCBSAY(87,43,"PIECE / PECA :","I","0",fonte2_2)    //quantidade de peças dentro da caixa
		//MSCBSAY(83,43,transform(_quant,'@E ######'),"I","0",fonte2_2)     //Quantidade de peças
		iif(!empty(_DESCTIPO),MSCBSAY(01,44,_DESCTIPO,"I","0",fonte2_5),)

		//******Terceiro bloco da etiqueta
		MSCBLineH(01,42,300,5,"B")
		MSCBSAY(64,37,"GROSS WEIGHT / PESO BRUTO:","I","0",fonte2) //peso bruto da caixa
		MSCBSAY(32,37,transform(_pesob,'@E ##.###')+" Kg","I","0",fonte2)
		iif(!empty(_GLUTEM),MSCBSAY(01,38,_GLUTEM,"I","0",fonte2_5),)
		MSCBSAY(67,29,"NET WEIGHT / PESO LIQUIDO:","I","0",fonte2)
		MSCBSAY(22,28,_pesol,"I","0",fonte2_1)   //peso liquido da caixa
		MSCBSAY(17,30,'Kg',"I","0",fonte2_4)            // EM CONSTRUÇÃO
		iif(AllTrim(_classif) = 'RT',MSCBSAY(01,28,_classif,"I","0",fonte2_1),) //Falta fazer a parte da Exportação da etiqueta

		MSCBSAY(50,25,"INTERNAL TARE/TARA EMB.PRIM.:","I","0",fonte2_2) //tara primaria
		MSCBSAY(32,25,transform(_vTARAP,'@E ##.###')+" Kg","I","0",fonte2_2)
		iif(_TF == 'S',MSCBSAY(01,28,"TF","I","0",fonte2_1),) // EM CONSTRUçÂO
		MSCBSAY(70,22,"TARE / TARA EMB SEC.:","I","0",fonte2_2) //tara secundaria
		MSCBSAY(32,22,transform(_vTARAS,'@E ##.###')+" Kg","I","0",fonte2_2)
		MSCBSAY(62,19,"TOTAL TARE / TARA TOTAL :","I","0",fonte2_2)   //tara total da caixa
		MSCBSAY(32,19,transform(_tara,'@E #.###')+" Kg","I","0",fonte2_2)
		iif(!empty(_SEXO),MSCBSAY(01,19,_SEXO,"I","0",fsexo),)
		//********Quarto Bloco da etiqueta
		MSCBLineH(01,18,300,5,"B")
		MSCBSAYBAR(84,07,_control,"I","C",10,.F.,.T.,,,2,1,.T.)  //numero do controle da caixa   código de barras
		_cMens :=  substr(_desing+"("+_despor,1,25)+")"
		MSCBSAY(24,12,_cMens,"I","B",fonte3)
		MSCBSAY(34,1,_vMENETQ,"I","B",fonte4_1)
		//iif(!empty(_vTIP),MSCBSAY(13,5,"Categoria","R","0",fonte2_3),)
		iif(!empty(_vTIP),MSCBSAY(94,5,_vTIP,"R","0",fonte3_2),)      //codigo tipificação  Categria
		//MSCBSAY(15,5,_d0000escFAM,"R","0",fonte2)   //descrição da família

		MSCBSAY(01,03,alltrim(_cod),"I","0",fonte1_2)

		MSCBEND()
		MSCBCLOSEPRINTER()
	endif

return .t.

//Etiqueta para impressão na solução de automação
user function GJF111c(_modelo,_porta,_mens1, _mens2)
	/*                      1      2        3      4
	Paremetros da função
	1  - modelo da impressora
	2  - porta
	3  - Mensagem de motivo do rejeite
	4 - Mensagem de ajuste a ser feito
	*/

	_mens1 := "Mensagem 1"
	_mens1 := "Mensagem 2"
	/*************************** Etiqueta Padrão  ************************************************ */
	if(_etq='P')
		MSCBPRINTER(_modelo,_porta)
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(_nNumEtq,6,40)
		fonte3  :="45,15"

		MSCBSAY(5,10,_mens1,"I","B",fonte3)
		MSCBSAY(5,55,_mens2,"I","B",fonte3)
		MSCBEND()
		MSCBCLOSEPRINTER()
	endif

return .t.

//Impressão de etiqueta de pallet                                       
user function GJF111d(_modelo,_porta,_Pallet, _produto,_ip,_PesPallet)
	/*                      1      2        3      4
	Paremetros da função
	1  - modelo da impressora
	2  - porta
	3  - Codigo do Pallet
	4  - Codigo do Produto
	*/
	dbselectarea('SB1')
	_cDescri := substr(GetAdvFVal('SB1','B1_DESCRED',Fwxfilial('SB1')+_produto,1),1,25)
	_cData := dtoc(GetAdvFVal('SZP','ZP_DATA',Fwxfilial('SZP')+alltrim(_Pallet),1))
	
	if !empty(_ip)                
		MSCBPRINTER(_modelo,_porta,,,,,_ip)
	else                                  
		MSCBPRINTER(_modelo,_porta)        
	endif
	
	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(1,6,40)

	fonte1:="60,60"
	fonte2:="100,100"
	fonte3  :="45,15"
	fonte4  :="300,200"

	MSCBSAY(66,35,_Pallet,"R","0",fonte2)   				//Número do Pallet
	MSCBSAY(55,15,_produto,"R","0",fonte1)                  // Produto
	MSCBSAY(55,40,_cDescri,"R","0",fonte1)        			// descrição
	MSCBSAYBAR(30,30,_Pallet,"R","C",20,.F.,.T.,,,3,2,.F.)  //código de barras
	MSCBSAY(12,15,'Data Montagem:',"R","0",fonte1)
	MSCBSAY(12,65,_cData,"R","0",fonte1)	             	// Data Criação Pallet
	MSCBSAY(02,15,'Peso Pallet:',"R","0",fonte1)
	MSCBSAY(02,53,transform(_PesPallet,' @E 99.99'),"R","0",fonte1)	             	// Peso do Pallet
	MSCBEND()
	MSCBCLOSEPRINTER()

return .t.

//FUNÇÃO DESTINADA PARA ETIQUETADORA DA APLIPACK
//MODIFICAÇÃO DO LAYOUT DE IMPRESSÃO
user function GJF111e(_modelo,_porta,_control,_cod,_quant,_pesob,_pesol,_tara,_predes,_classif,_TF,_datap,_etq,_dataval,_nNumEtq,_Lote,_IP,_cSeq,_Hora)
	/*                      1      2        3      4     5      6     7      8     9        10     11    12   13     14       15       16   17
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
	16 - Lote (exclusivo para exportação)
	17 - Endereço IP para conexão ethernet
	18 - Sequencial da Pré-etiqueta
	19 - Hora
	*/

	//local dtAbate   := ''
	local _vTIP     := ''
	local _vDESCES  := ''
	local _vDINGLES := ''
	local _vDESCING := ''
	local _vDFRANCES:= ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vDESCFRA := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vTARAP   := 0.00
	local _vTARAS   := 0.00
	local _vMENETQ  := ''
	local _vFAM     := ''
	local _DESTINO  := ''
	local _DESCTIPO := ''
	local _GLUTEM   := ''
	local _SEXO     := ''
	local _vNUMAM   := ''
	local _vDTABATE := ''
	local _vRASTRO  := ''
	local _vTIP     := ''
	local _desing   := ''
	local _desfra   := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _despor   := ''
	local _descFAM  := ''
	local _dtPROD   := ''
	local _dtVALID  := ''
	local _nTS      := ''
	local _nTP      := ''
	//local _cSeq     := ''
	local _cPesol   := strtran(cValtoChar(_pesol),'.','')
	local	_codExp   := getMv('SI_CODEXP')		
	//local _cModo    := GETMV('SI_MIMPEMB')
	//local _cIpImp   := GETMV('SI_IPIMP')

	SB1->(dbsetorder(1))
	if SB1->(Msseek(Fwxfilial('SB1')+alltrim(_cod)))
		_vDINGLES := SB1->B1_DESCING //os dois campos abaixo estao invertidos de proposito para não
		_vDESCING := SB1->B1_DINGLES //precisar mexer no layout de impressao - B1_DINGLES é a do SIF
		_vDFRANCES:= SB1->B1_DESCFRA  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
		_vDESCFRA := SB1->B1_DFRANCE //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
		_vDESCES  := SB1->B1_DESCESP // e o B1_DESCING a descrição em ingles do produto
		_vDESCSIF := SB1->B1_DESCSIF
		_nTS      := SB1->B1_CTARASE
		_nTP      := SB1->B1_CTARAP  // Incluido por Fabian Maurer - 08/05/2012 - nao estava pegando certo a tara primaria
		_nCodBar  := SB1->B1_CODBAR
		_nCdBarcli := SB1->B1_EANCLI
		_cNotImp  := GetAdvFVal('SZU','ZU_NOTIMP',Fwxfilial('SZU') + SZ8->Z8_NUMPREV,2)
		_cGrupo   := SB1->B1_GRUPO
		_cFarm    := GetAdvFVal('SBM','BM_FARM',Fwxfilial('SBM')+_cGrupo,1)

		ZAB->(DbSetOrder(1))
		if ZAB->(MsSeek(Fwxfilial('ZAB')+alltrim(_nTS)))
			_vTARAS   := ZAB->ZAB_TARA
		endif

		if ZAB->(MsSeek(Fwxfilial('ZAB')+alltrim(_nTP)))
			_vTARAP   := ZAB->ZAB_TARA
		endif

		_vMENETQ  := SB1->B1_MENETQ1
		_vFAM     := SB1->B1_FAM
		_DESTINO  := SB1->B1_DESTINO
		_DESCTIPO := SB1->B1_MENETQ2
		_GLUTEM   := SB1->B1_MENETQ3
		_SEXO	    := SB1->B1_MENETQ4
	endif

	if !empty(_predes) .and. substr(_predes,1,3) <> 'SIF'
		SZ2->(DbSetOrder(2))
		if  SZ2->(MsSeek(Fwxfilial('SZ2')+_predes))                          	// se houver o apontamento de OP...
			_vNUMAM   := SZ2->Z2_NUMAM //GetAdvFVal('SZ2',2,Fwxfilial('SZ2')+_predes,'Z2_NUMAM')  				//numero aviso de matança
			_vDTABATE := dtoc(SZ2->Z2_DATAABT) //dtoc(GetAdvFVal('SZ2',2,Fwxfilial('SZ2')+_predes,'Z2_DATAABT'))//aviso de matança formatado em string
			_vRASTRO  := GetMv("MV_NUMIF") + strtran(_vDTABATE,'/','') +'0000   (' + _classif + ')'
			_vTIP     := SZ2->Z2_TIPIFI //GetAdvFVal('SZ2',2,Fwxfilial('SZ2')+_predes,'Z2_TIPIFI')  				//numero aviso de matança
		endif
	endif

	_desing  := alltrim(_vDINGLES)
	_desfra  := alltrim(_vDFRANCES)  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	_despor  :=  substr(alltrim(SB1->B1_DESCRED),1,17)
	//_cSeq    := SZ8->Z8_SEQPETQ

	DbSelectArea('SX5')
	_descFAM := GetAdvFVal('SX5','X5_DESCRI',Fwxfilial("SX5")+'PS'+_vFAM,1)
	_dtPROD  := dtoc(_datap)
	_dtVALID := dtoc(_dataval) //data da produção

	//*************************** Etiqueta Padrão  ************************************************

	if(_etq='P')
		_linP := -20

		MSCBPRINTER(_modelo,_porta,,,,,_IP)

		//	  	MSCBPRINTER(_modelo,_porta)	
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(_nNumEtq,6,40)
		// Posição d codigo de barras
		fonte1  :="40,20"
		fonte1_1:="30,15"
		fonte1_2:="85,85" //100/50
		fonte1_3:="38,12"
		fonte2  :="35,30"
		fonte2_1:="100,100"
		fonte2_2:="25,35"
		fonte2_3:="20,23"
		fonte2_4:="35,30"
		fonte2_5:="25,20" // Trocando até acertar
		fonte3  :="35,12"//42
		fonte3_1:="40,45"
		f_extra :="30,22"
		fonte3_2:="84,90"
		fonte3_3:="24,15"
		fonte3_4:="45,30"
		fonte3_5 := "70,55"
		fonte4  :="20,5"
		fonte4_1:="16,8"
		fsexo   :="65,50"
		fonte4_2:="120,65"
		fonte5  :="25,25"
		fonte5_1 := "20,18"

		IF SB1->B1_DESTINO == 'MI'

			//******************* 1º Bloco da Etiqueta ************************

			_cDescSIF :=  substr(_vDESCSIF,1,35)

			MSCBSAY(90,75,_control,"R","0",fonte2_2)         	//numero de controle

			MSCBSAY(87,05,_cDescSIF,"R","0",fonte2_2)   				//descrição do ingles

			MSCBSAY(84,05,_vDESCING,"R","0",fonte2_2) 					//descrição do SIF

			MSCBLineV(82,01,100,4,"B")                  //Linha Divisoria

			//******************* 2º Bloco da Etiqueta ************************

			MSCBSAY(77,05,"PACKING DATE/"+ iif(_cFarm = 'S',"DATA PRODUCAO","DATA EMBALAGEM:"),"R","0",fonte2_2)   //data de produção
			MSCBSAY(77,68,_dtPROD,"R","0",fonte2_2)

			MSCBSAY(74,05,"EXPIRY DATE/DATA VALIDADE:","R","0",fonte2_2)   //data de validade - Alterado por Fabian Maurer - 02/05/12 - Correção Escrita
			MSCBSAY(74,68,_dtVALID,"R","0",fonte2_2)			

			iif(AllTrim(_classif) == 'RT',iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(68,05,"RASTREABILIDADE :","R","0",fonte2_2),),) //numero de rastro M->Z8_CLASSIF =='RT'
			iif(AllTrim(_classif) == 'RT',iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(68,45,_vRASTRO,"R","0",fonte2_2),),)

			//MSCBBOX(15,70,15,84,5) //alterar até acertar
			MSCBLineH(67,88,82,4,"B")                  //Linha Divisoria
			MSCBSAY(70,90,_DESTINO,"R","0",fonte3_5)     // Destino do produto (mover para outro lugar)

			//******************* 3º Bloco da Etiqueta ************************
			if  _cNotImp <> "P"
				MSCBLineV(67,01,100,4,"B")

				_cPb    := transform(_pesob,'@E 99.999')
				_cPesob := strtran(_cPb,',','.')
				MSCBSAY(63,05,"GROSS WEIGHT/PESO BRUTO(Kg):","R","0",fonte2_2) //peso bruto da caixa
				MSCBSAY(63,75,_cPesob,"R","0",fonte2_2)

				_cPl    := transform(_pesol,'@E ##.###')
				_cPesol := strtran(_cPl,',','.')
				MSCBSAY(54,05,"NET WEIGHT/PESO LIQUIDO(Kg):","R","0",fonte2_2)
				MSCBSAY(53,73,_cPesol,"R","0",fonte3_5)   //peso liquido da caixa

				//iif(AllTrim(_classif) = 'RT',MSCBSAY(01,63,_classif,"I","0",fonte2_1),) //Falta fazer a parte da Exportação da etiqueta

				_cTp    := transform(_quant * _vTaraP,'@E ##.###')
				_cTaraP := strtran(_cTp,',','.')
				MSCBSAY(50,05,"INTERNAL TARE/TARA EMB.PRIM.(Kg):","R","0",fonte2_2) //tara primaria
				MSCBSAY(50,75,_cTARAP,"R","0",fonte2_2)

				_cTs    := transform(_vTaras,'@E ##.###')
				_cTaras := strtran(_cTs,',','.')
				MSCBSAY(47,05,"TARE/TARA EMB SEC.(Kg):","R","0",fonte2_2) //tara secundaria
				MSCBSAY(47,75,_cTARAS,"R","0",fonte2_2)

				_cTa := transform(_tara,'@E #.###')
				_cTara := strtran(_cTa,',','.')
				MSCBSAY(44,05,"TOTAL TARE/TARA TOTAL(Kg):","R","0",fonte2_2)   //tara total da caixa
				MSCBSAY(44,75,_cTara,"R","0",fonte2_2)

				iif(_TF == 'S',MSCBSAY(43,93,"TF","R","0",fonte3_5),) // EM CONSTRUçÂO

				MSCBLineV(42,01,100,4,"B")

			else
				MSCBLineV(67,01,100,4,"B")
				MSCBSAY(63,05,"GROSS WEIGHT/PESO BRUTO(Kg):","R","0",fonte2_2) //peso bruto da caixa
				MSCBSAY(63,75,transform(_pesob,'@E ##.###'),"R","0",fonte2_2)

				MSCBSAY(54,05,"NET WEIGHT/PESO LIQUIDO(Kg):","R","0",fonte2_2)
				MSCBSAY(53,73,transform(_pesol,'@E ##.###'),"R","0",fonte3_5)   //peso liquido da caixa

				//iif(AllTrim(_classif) = 'RT',MSCBSAY(01,63,_classif,"I","0",fonte2_1),) //Falta fazer a parte da Exportação da etiqueta

				MSCBSAY(50,05,"INTERNAL TARE/TARA EMB.PRIM.(Kg):","R","0",fonte2_2) //tara primaria
				MSCBSAY(50,75,transform(_quant * _vTARAP,'@E ##.###'),"R","0",fonte2_2)

				MSCBSAY(47,05,"TARE/TARA EMB SEC.(Kg):","R","0",fonte2_2) //tara secundaria
				MSCBSAY(47,75,transform(_vTARAS,'@E ##.###'),"R","0",fonte2_2)

				MSCBSAY(44,05,"TOTAL TARE/TARA TOTAL(Kg):","R","0",fonte2_2)   //tara total da caixa
				MSCBSAY(44,75,transform(_tara,'@E #.###'),"R","0",fonte2_2)

				iif(_TF == 'S',MSCBSAY(43,93,"TF","R","0",fonte3_5),) // EM CONSTRUçÂO

				MSCBLineV(42,01,100,4,"B")

			endif

			//******************* 4º Bloco da Etiqueta ************************

			MSCBSAYBAR(27,20,'010' + _nCodBar + '310200' + substr(_cPesol,1,2) + substr(_cPesol,3,2),"R","C",13,.F.,.T.,,,3,1,.T.)  //EAN exigido pelo walmart
			MSCBSAY(65,20,_Hora,"B","B",fonte4)
			MSCBSAY(30,110, _Hora,"R","0",fonte_mlr6)

			//******************* 5º Bloco da Etiqueta ************************

			MSCBLineV(23,01,100,4,"B")

			iif(!empty(_DESCTIPO),MSCBSAY(21,05,_DESCTIPO,"R","B",fonte4_1),)    //mensagem da temperatura
			MSCBSAY(19,05,_vMENETQ,"R","B",fonte4_1)
			iif(!empty(_GLUTEM),MSCBSAY(21,60,_GLUTEM,"R","B",fonte4_1),)   //Mensagem do Glutem
			iif(!empty(_SEXO),MSCBSAY(19,60,_SEXO,"R","B",fonte4_1),)

			//******************* 6º Bloco da Etiqueta ************************
			MSCBLineV(17,01,100,4,"B")

			MSCBSAYBAR(05,47,_control,"R","C",10,.F.,.T.,,,2,1,.T.)  //numero do controle da caixa   código de barras

			//MSCBSAY(10,08,_desing,"R","B",fonte3)
			//MSCBSAY(05,08,_despor,"R","B",fonte3)

			MSCBSAY(10,08,_desing,"R","0",fonte2_2)   				
			MSCBSAY(05,08,_despor,"R","0",fonte2_2)   						

			//iif(!empty(_vTIP),MSCBSAY(12+_linP,1,_vTIP,"R","0",fonte3_2),)      //codigo tipificação  Categria

			MSCBSAY(02,73,alltrim(_cod),"R","0",fonte4_2)
			MSCBSAY(01,73,"PE:"+_cSeq,"R","0",fonte5)

		ELSE //SENÃO Será MERCADO EXTERNO

			//******************* 1º Bloco da Etiqueta ************************

			_cDescSIF :=  substr(_vDESCSIF,1,35)

			MSCBSAY(90,75,_control,"R","0",fonte2_2)         	//numero de controle

			MSCBSAY(87,05,_cDescSIF,"R","0",fonte2_2)   				//descrição do ingles

			MSCBSAY(84,05,_vDESCING,"R","0",fonte2_2) 					//descrição do SIF

			MSCBLineV(82,01,100,4,"B")                  //Linha Divisoria

			//******************* 2º Bloco da Etiqueta ************************

			if alltrim(_cod) $ _codExp		
				MSCBSAY(77,05,"DATA PRODUCAO/PRODUCTION DATE","R","0",fonte2_2)   //data de produção
				MSCBSAY(77,68,_dtPROD,"R","0",fonte2_2)
			else
				MSCBSAY(77,05, iif(_cFarm = 'S',"DATA PRODUCAO","DATA EMBALAGEM:") + "PACKING DATE:","R","0",fonte2_2)   //data de produção
				MSCBSAY(77,68,_dtPROD,"R","0",fonte2_2)		
				
				iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(68,05,"DATA ABATE/SLAUGHTER DATE:","R","0",fonte2_2),)       //data de abate
				iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(68,70,_vDTABATE,"R","0",fonte2_2),)
			endif

			MSCBSAY(74,05,"DATA VALIDADE/EXPIRY DATE:","R","0",fonte2_2)   //data de validade - Alterado por Fabian Maurer - 02/05/12 - Correção Escrita
			MSCBSAY(74,68,_dtVALID,"R","0",fonte2_2)
			
			MSCBLineH(67,88,82,4,"B")                  //Linha Divisoria
			MSCBSAY(70,90,_DESTINO,"R","0",fonte3_5)     // Destino do produto (mover para outro lugar)

			//******************* 3º Bloco da Etiqueta ************************
			if  _cNotImp <> "P"
				MSCBLineV(67,01,100,4,"B")

				_cPb    := transform(_pesob,'@E 99.999')
				_cPesob := strtran(_cPb,',','.')
				MSCBSAY(63,05,"PESO BRUTO(Kg)/GROSS WEIGHT:","R","0",fonte2_2) //peso bruto da caixa
				MSCBSAY(63,75,_cPesob,"R","0",fonte2_2)

				_cPl    := transform(_pesol,'@E ##.###')
				_cPesol := strtran(_cPl,',','.')
				MSCBSAY(54,05,"PESO LIQUIDO(Kg)/NET WEIGHT:","R","0",fonte2_2)
				MSCBSAY(53,73,_cPesol,"R","0",fonte3_5)   //peso liquido da caixa

				_cTp    := transform(_quant * _vTaraP,'@E ##.###')
				_cTaraP := strtran(_cTp,',','.')
				MSCBSAY(50,05,"TARA EMB.PRIM.(Kg)/INTERNAL TARE:","R","0",fonte2_2) //tara primaria
				MSCBSAY(50,75,_cTARAP,"R","0",fonte2_2)

				_cTs    := transform(_vTaras,'@E ##.###')
				_cTaras := strtran(_cTs,',','.')
				MSCBSAY(47,05,"TARA EMB SEC.(Kg)/TARE:","R","0",fonte2_2) //tara secundaria
				MSCBSAY(47,75,_cTARAS,"R","0",fonte2_2)

				_cTa := transform(_tara,'@E #.###')
				_cTara := strtran(_cTa,',','.')
				MSCBSAY(44,05,"TARA TOTAL(Kg)/TOTAL TARE:","R","0",fonte2_2)   //tara total da caixa
				MSCBSAY(44,75,_cTara,"R","0",fonte2_2)

				iif(_TF == 'S',MSCBSAY(43,93,"TF","R","0",fonte3_5),) // EM CONSTRUçÂO
				
				iif(AllTrim(_classif) = 'RT',MSCBSAY(42,88,_classif,"R","0",fonte3_5),) 

				MSCBLineV(42,01,100,4,"B")

			else
				MSCBLineV(67,01,100,4,"B")
				MSCBSAY(63,05,"PESO BRUTO(Kg)/GROSS WEIGHT:","R","0",fonte2_2) //peso bruto da caixa
				MSCBSAY(63,75,transform(_pesob,'@E ##.###'),"R","0",fonte2_2)

				MSCBSAY(54,05,"PESO LIQUIDO(Kg)/NET WEIGHT:","R","0",fonte2_2)
				MSCBSAY(53,73,transform(_pesol,'@E ##.###'),"R","0",fonte3_5)   //peso liquido da caixa			

				MSCBSAY(50,05,"TARA EMB.PRIM.(Kg)/INTERNAL TARE:","R","0",fonte2_2) //tara primaria
				MSCBSAY(50,75,transform(_quant * _vTARAP,'@E ##.###'),"R","0",fonte2_2)

				MSCBSAY(47,05,"TARA EMB SEC.(Kg)/TARE:","R","0",fonte2_2) //tara secundaria
				MSCBSAY(47,75,transform(_vTARAS,'@E ##.###'),"R","0",fonte2_2)

				MSCBSAY(44,05,"TARA TOTAL(Kg)/TOTAL TARE:","R","0",fonte2_2)   //tara total da caixa
				MSCBSAY(44,75,transform(_tara,'@E #.###'),"R","0",fonte2_2)

				iif(_TF == 'S',MSCBSAY(43,93,"TF","R","0",fonte3_5),) // EM CONSTRUçÂO

				// Inclusão dia 20/09/16 - Flávio (Para Produtos Exportações RT)
				iif(AllTrim(_classif) = 'RT',MSCBSAY(42,88,_classif,"R","0",fonte3_5),)

				MSCBLineV(42,01,100,4,"B")
			endif

			//******************* 4º Bloco da Etiqueta ************************
			//MSCBLineH(01,32,300,4,"B")

			_cPrdArg := getMv('SI_PRDARG')

			If alltrim(_cod) $ _cPrdArg
				MSCBSAY(29,68,'VENTA AL PESO. No Recongelar',"R","0",fonte5_1)
			endif

			iif(!empty(_DESCTIPO),MSCBSAY(39,05,_DESCTIPO,"R","0",fonte5_1),)    //mensagem da temperatura

			MSCBSAY(36,05,_vMENETQ,"R","0",fonte5_1)

			iif(!empty(_GLUTEM),MSCBSAY(33,05,_GLUTEM,"R","0",fonte5_1),)   //Mensagem do Glutem

			iif(!empty(_SEXO),MSCBSAY(30,05,_SEXO,"R","0",fonte5_1),)

			//BLOCO REMOVIDO TEMPORARIAMENTE POIS PERDERAM A HABILITAÇÃO PARA A RUSSIA		
			/*if AllTrim(_classif) == 'RU'        
			MSCBBOX(30,83,40,96,80,"B")   //Box preto onde fica o EAC 88-75 
			MSCBSAY(30,85,'EAC',"R","0","60,45",.t.)			
			endif*/

			iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBLineH(28,76,42,4,"B"),)                  //Linha Divisoria
			iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(30,80,"LOTE:","R","0",fonte2_2),)    //Lote
			iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(30,90,_Lote,"R","0",fonte2_2),)  //descricao do lote preenchido no lançamento da OP da embalagem

			MSCBSAY(30,110, _Hora,"R","0",fonte_mlr6)

			//******************* 5º Bloco da Etiqueta ************************

			// Inclusão dia 20/09/16 - Flávio (Exportações RT)
			iif(AllTrim(_classif) == 'RT',iif(!empty(_predes),MSCBSAY(24,05,"RASTREABILIDADE :" + _vRASTRO,"R","0",fonte5_1),),)

			MSCBLineV(28,01,100,4,"B")
			MSCBLineV(17,01,100,4,"B")
			MSCBSAYBAR(05,47,_control,"R","C",10,.F.,.T.,,,2,1,.T.)  //numero do controle da caixa   código de barras

			MSCBSAY(10,08,_despor,"R","B",fonte3)
			MSCBSAY(05,08,_desing,"R","B",fonte3)

			//iif(!empty(_vTIP),MSCBSAY(12+_linP,1,_vTIP,"R","0",fonte3_2),)      //codigo tipificação  Categria

			MSCBSAY(02,73,alltrim(_cod),"R","0",fonte4_2)
			MSCBSAY(01,73,"PE:"+_cSeq,"R","0",fonte5)

		ENDIF
		MSCBEND()
		MSCBCLOSEPRINTER()
	endif

	//**************************** Inicio Etiqueta Espanha ****************************\\
	if(_etq='E')
		_linP := -20

		MSCBPRINTER(_modelo,_porta,,,,,_IP)

		//MSCBPRINTER(_modelo,_porta)
		//MSCBPRINTER(_modelo,_porta,,,,,'10.0.0.161')

		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(_nNumEtq,6,40)
		// Posição d codigo de barras
		fonte1  :="40,20"
		fonte1_1:="30,15"
		fonte1_2:="85,85" //100/50
		fonte1_3:="38,12"
		fonte2  :="35,30"
		fonte2_1:="100,100"
		fonte2_2:="25,35"
		fonte2_3:="20,23"
		fonte2_4:="35,30"
		fonte2_5:="25,20" // Trocando até acertar
		fonte3  :="35,12"//42
		fonte3_1:="40,45"
		f_extra :="30,22"
		fonte3_2:="84,90"
		fonte3_3:="24,15"
		fonte3_4:="45,30"
		fonte3_5 := "70,55"
		fonte4  :="20,5"
		fonte4_1:="16,8"
		fsexo   :="65,50"
		fonte4_2:="120,65"
		fonte5  :="25,25"
		fonte5_1 := "20,18"

		//******************* 1º Bloco da Etiqueta ************************

		_cDescSIF :=  substr(_vDESCSIF,1,35)

		MSCBSAY(90,75,_control,"R","0",fonte2_2)         	//numero de controle

		MSCBSAY(87,05,_cDescSIF,"R","0",fonte2_2)   				//descrição do ingles _cDescSIF

		MSCBSAY(84,05,_vDESCING,"R","0",fonte2_2) 					//descrição do SIF

		MSCBLineV(82,01,100,4,"B")                  //Linha Divisoria

		//******************* 2º Bloco da Etiqueta ************************

		MSCBSAY(77,05,"FECHA DE PRODUCCION/DT. PROD.:","R","0",fonte2_2)   //data de produção
		MSCBSAY(77,68,_dtPROD,"R","0",fonte2_2)

		MSCBSAY(74,05,"FECHA DE VALIDAD/DATA VALID.:","R","0",fonte2_2)   //data de validade - Alterado por Fabian Maurer - 02/05/12 - Correção Escrita
		MSCBSAY(74,68,_dtVALID,"R","0",fonte2_2)

		//MSCBSAY(71,05,"PIEZA/PECA :","R","0",fonte2_2)    //quantidade de peças dentro da caixa
		//MSCBSAY(71,35,transform(_quant,'@E ######'),"R","0",fonte2_2)     //Quantidade de peças

		iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(68,05,"FECHA DE MATANZA: ","R","0",fonte2_2),)       //data de abate
		iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(68,68,_vDTABATE,"R","0",fonte2_2),)

		//MSCBBOX(15,70,15,84,5) //alterar até acertar              
		MSCBLineH(67,87,82,4,"B")                  //Linha Divisoria
		MSCBSAY(70,89,_DESTINO,"R","0",fonte3_5)     // Destino do produto (mover para outro lugar)

		//******************* 3º Bloco da Etiqueta ************************
		if  _cNotImp <> "P"
			MSCBLineV(67,01,100,4,"B")

			_cPb    := transform(_pesob,'@E 99.999')
			_cPesob := strtran(_cPb,',','.')
			MSCBSAY(63,05,"PESO BRUTO/PESO BRUTO(Kg):","R","0",fonte2_2) //peso bruto da caixa
			MSCBSAY(63,75,_cPesob,"R","0",fonte2_2)

			_cPl    := transform(_pesol,'@E ##.###')
			_cPesol := strtran(_cPl,',','.')
			MSCBSAY(54,05,"PESO NETO/PESO LIQUIDO(Kg):","R","0",fonte2_2)
			MSCBSAY(53,70,_cPesol,"R","0",fonte1_2)   //peso liquido da caixa

			//iif(AllTrim(_classif) = 'RT',MSCBSAY(01,44,_classif,"I","0",fonte2_1),) //Falta fazer a parte da Exportação da etiqueta

			_cTp    := transform(_quant * _vTaraP,'@E ##.###')
			_cTaraP := strtran(_cTp,',','.')
			MSCBSAY(50,05,"TARA ENV.PRIM./TARA EMB.PRIM.(Kg):","R","0",fonte2_2) //tara primaria
			MSCBSAY(50,75,_cTARAP,"R","0",fonte2_2)

			_cTs    := transform(_vTaras,'@E ##.###')
			_cTaras := strtran(_cTs,',','.')
			MSCBSAY(47,05,"TARA ENV.SEC./TARA EMB SEC.(Kg):","R","0",fonte2_2) //tara secundaria
			MSCBSAY(47,75,_cTARAS,"R","0",fonte2_2)

			_cTa   := transform(_tara,'@E #.###')
			_cTara := strtran(_cTa,',','.')
			MSCBSAY(44,05,"TARA TOTAL/TARA TOTAL(Kg):","R","0",fonte2_2)   //tara total da caixa
			MSCBSAY(44,75,_cTara,"R","0",fonte2_2)

			iif(_TF == 'S',MSCBSAY(43,93,"TF","R","0",fonte2_1),) // EM CONSTRUçÂO

			MSCBLineV(42,01,100,4,"B")		
		else

			MSCBLineV(67,01,100,4,"B")

			MSCBSAY(63,05,"PESO BRUTO/PESO BRUTO(Kg):","R","0",fonte2_2) //peso bruto da caixa
			MSCBSAY(63,75,transform(_pesob,'@E ##.###'),"R","0",fonte2_2)

			MSCBSAY(54,05,"PESO NETO/PESO LIQUIDO(Kg):","R","0",fonte2_2)
			MSCBSAY(53,70,transform(_pesol,'@E ##.###'),"R","0",fonte3_5)   //peso liquido da caixa

			//iif(AllTrim(_classif) = 'RT',MSCBSAY(01,44,_classif,"I","0",fonte2_1),) //Falta fazer a parte da Exportação da etiqueta

			MSCBSAY(50,05,"TARA ENV.PRIM./TARA EMB.PRIM.(Kg):","R","0",fonte2_2) //tara primaria
			MSCBSAY(50,75,transform(_quant * _vTARAP,'@E ##.###'),"R","0",fonte2_2)

			MSCBSAY(47,05,"TARA ENV.SEC./TARA EMB SEC.(Kg):","R","0",fonte2_2) //tara secundaria
			MSCBSAY(47,75,transform(_vTARAS,'@E ##.###'),"R","0",fonte2_2)

			MSCBSAY(44,05,"TARA TOTAL/TARA TOTAL(Kg):","R","0",fonte2_2)   //tara total da caixa
			MSCBSAY(44,75,transform(_tara,'@E #.###'),"R","0",fonte2_2)

			iif(_TF == 'S',MSCBSAY(43,93,"TF","R","0",fonte3_5),) // EM CONSTRUçÂO

			MSCBLineV(42,01,100,4,"B")
		endif

		//******************* 4º Bloco da Etiqueta ************************
		//MSCBLineH(01,32,300,4,"B")
		MSCBSAY(36,08,_vMENETQ,"R","0",fonte5_1)
		MSCBSAY(30,110, _Hora,"R","0",fonte_mlr6)

		iif(!empty(_DESCTIPO),MSCBSAY(39,08,_DESCTIPO,"R","0",fonte5_1),)    //mensagem da temperatura

		iif(!empty(_GLUTEM),MSCBSAY(33,08,_GLUTEM,"R","0",fonte5_1),)   //Mensagem do Glutem

		iif(!empty(_SEXO),MSCBSAY(30,08,_SEXO,"R","0",fonte5_1),)

		//iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBBOX(21,19,21,32,5),)		

		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBLineH(28,76,42,4,"B"),)                  //Linha Divisoria		
		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(30,80,"LOTE:","R","0",fonte2_2),)    //Lote
		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(30,90,_Lote,"R","0",fonte2_2),)  //descricao do lote preenchido no lançamento da OP da embalagem

		//******************* 5º Bloco da Etiqueta ************************

		MSCBLineV(28,01,100,4,"B")
		MSCBLineV(17,01,100,4,"B")
		MSCBSAYBAR(05,47,_control,"R","C",10,.F.,.T.,,,2,1,.T.)  //numero do controle da caixa   código de barras

		MSCBSAY(10,08,_desing,"R","B",fonte3)
		MSCBSAY(05,08,_despor,"R","B",fonte3)

		//iif(!empty(_vTIP),MSCBSAY(12+_linP,1,_vTIP,"R","0",fonte3_2),)      //codigo tipificação  Categria

		MSCBSAY(02,73,alltrim(_cod),"R","0",fonte4_2)
		MSCBSAY(01,73,"PE:"+_cSeq,"R","0",fonte5)		
		MSCBSAY(01-_linP,01,"CONTROLADO POR DETECTOR DE METALES","R","0",fonte_mlr4)

		// Quando for Produto Rastreado 
		iif(AllTrim(_classif) = 'RT',MSCBSAY(43,88,_classif,"R","0",fonte3_5),)	
		iif(AllTrim(_classif) == 'RT',iif(!empty(_predes),MSCBSAY(24,05,"RASTREABILIDADE :" + _vRASTRO,"R","0",fonte5_1),),)

		MSCBSAY(35,100, _Hora,"R","0",fonte_mlr4)

		MSCBEND()
		MSCBCLOSEPRINTER()
	endif

return  .t.


//Etiqueta para produção normal(manual) em estações que utilizam impressoras de rede(manual)
user function GJF111f(_modelo,_porta,_control,_cod,_quant,_pesob,_pesol,_tara,_predes,_classif,_TF,_datap,_etq,_dataval,_nNumEtq,_Lote,_IP,_cSeq,_Hora,_cReimp)
	/*                   1      2        3      4     5      6     7      8     9        10     11    12   13     14       15      16    17   18   19     20
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
	18 - Seq. Pré-etiqueta
	19 - Hora
	20 - Reimpressão
	*/

	//local dtAbate   := ''
	local _vTIP     := ''
	local _vDESCES  := ''
	local _vDINGLES := ''
	local _vDESCING := ''
	local _vDFRANCES:= ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vDESCFRA := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vTARAP   := 0.00
	local _vTARAS   := 0.00
	local _vMENETQ  := ''
	local _vFAM     := ''
	local _DESTINO  := ''
	local _DESCTIPO := ''
	local _GLUTEM   := ''
	local _SEXO     := ''
	local _vNUMAM   := ''
	local _vDTABATE := ''
	local _vRASTRO  := ''	
	local _desing   := ''
	local _desesp   := ''
	local _desfra   := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _despor   := ''
	local _descFAM  := ''
	local _dtPROD   := ''
	local _dtVALID  := ''
	local _nTS      := ''
	local _nTP      := ''
	local _cPesol   := strtran(cValtoChar(_pesol),'.','')
	local _codExp   := getMv('SI_CODEXP')		
	Local _cQTD  	:= GetMV('SI_QTDIMP')//Parabetro de controle de reimpressão - Flávio 02/02/2018         SI_QTDIMP 

	fonte_mlr1 := "25,10"
	fonte_mlr2 := "15,10"
	fonte_mlr3 := "45,20"
	fonte_mlr4 := "20,18"
	fonte_mlr5 := "60,18"
	fonte_mlr6 := "35,22"


	Dbselectarea('SB1')
	SB1->(dbsetorder(1))
	SB1->(Msseek(Fwxfilial('SB1')+alltrim(_cod)))
	_vDINGLES := SB1->B1_DESCING //os dois campos abaixo estao invertidos de proposito para não
	_vDESCING := SB1->B1_DINGLES //precisar mexer no layout de impressao - B1_DINGLES é a do SIF
	_VDESPAN  := SB1->B1_DESPANH
	_vDFRANCES:= SB1->B1_DESCFRA //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	_vDESCFRA := SB1->B1_DFRANCE //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	_vDESCES  := SB1->B1_DESCESP // e o B1_DESCING a descrição em ingles do produto
	_vDESCSIF := SB1->B1_DESCSIF //
	_nTS      := SB1->B1_CTARASE
	_cGrupo   := SB1->B1_GRUPO
	_cFarm    := GetAdvFVal('SBM','BM_FARM',Fwxfilial('SBM')+_cGrupo,1)
	_vTARAS   := GetAdvFVal('ZAB','ZAB_TARA',Fwxfilial('ZAB')+alltrim(_nTS),1)  //Tara Secundária
	_nTP      := SB1->B1_CTARAP
	_vTARAP   := GetAdvFVal('ZAB','ZAB_TARA',Fwxfilial('ZAB')+alltrim(_nTP),1)   //Tara Primária
	_vMENETQ  := SB1->B1_MENETQ1 //Mensagem etiqueta 1
	_vFAM     := SB1->B1_FAM     //Família Silva
	_DESTINO  := SB1->B1_DESTINO //Destino
	_DESCTIPO := SB1->B1_MENETQ2
	_GLUTEM   := SB1->B1_MENETQ3
	_SEXO	  := SB1->B1_MENETQ4
	_nCodBar  := SB1->B1_CODBAR
	_nCdBarcli := SB1->B1_EANCLI
	_cNotImp  := GetAdvFVal('SZU','ZU_NOTIMP',Fwxfilial('SZU') + SZ8->Z8_NUMPREV,2)
	_nCadM := SB1->B1_CADMERC
	_c_TIPO := SB1->B1_TIPO
	//conout('linha 2656 - > Cod-'+_cod)
	if !empty(_predes) .and. substr(_predes,1,3) <> 'SIF'
		SZ2->(DbSetOrder(2))
		if  SZ2->(MsSeek(Fwxfilial('SZ2')+_predes)) // se houver o apontamento de OP...
			_vNUMAM   := SZ2->Z2_NUMAM //GetAdvFVal('SZ2',2,Fwxfilial('SZ2')+_predes,'Z2_NUMAM')  				//numero aviso de matança
			_vDTABATE := dtoc(SZ2->Z2_DATAABT) //dtoc(GetAdvFVal('SZ2',2,Fwxfilial('SZ2')+_predes,'Z2_DATAABT'))//aviso de matança formatado em string
			_vRASTRO  := GetMv("MV_NUMIF") + strtran(_vDTABATE,'/','') +'0000   (' + _classif + ')' //Rastro
			_vTIP     := SZ2->Z2_TIPIFI //GetAdvFVal('SZ2',2,Fwxfilial('SZ2')+_predes,'Z2_TIPIFI'  				//numero aviso de matança
			//conout('linha 2881 - > Abate -'+dtos(_vDTABATE))
			
		endif
	endif

	_desing  := alltrim(_vDINGLES)	
	_desfra  := alltrim(_vDFRANCES) //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	_despor  :=  alltrim(SB1->B1_DESCRED)        //Descrição reduzida em portugues
	_desesp  := alltrim(SB1->B1_DESCESP)

	DbSelectArea('SX5')
	_descFAM := GetAdvFVal('SX5','X5_DESCRI',Fwxfilial("SX5")+'PS'+_vFAM,1)   //Descrição da família
	_dtPROD  := dtoc(_datap)   //data da produção
	_dtVALID := dtoc(_dataval) //data de validade		

	If  alltrim(_cod) $ _cQTD // se for do código(conserva) x imprime + 1 etiqueta
		_nNumEtq:= _nNumEtq+1
	endif

	//conout('linha 2900 - > Passou aqui')
	/*************************** Etiqueta Padrão  *************************************************/
	// SZU->ZU_ETIQ = Se na previsão marcar como Portugues entra aqui
	if _nCadM = 'L'
		//Etiqueta para lingua inglesa EUA
		U_GJF111LI(_modelo,_porta,_control,_cod,_quant,_pesob,_pesol,_tara,_predes,_classif,_TF,_datap,_etq,_dataval,_nNumEtq,_Lote,_IP,_Hora)
		//conout('Linha 2883 - > Gerada Etiqueta para lingua inglesa para Libano')
	elseif _nCadM = 'A'
		//Etiqueta para lingua inglesa
		U_GJF111IN(_modelo,_porta,_control,_cod,_quant,_pesob,_pesol,_tara,_predes,_classif,_TF,_datap,_etq,_dataval,_nNumEtq,_Lote,_IP,_cSeq,_Hora)
	elseif _nCadM = 'U'
		U_EMBUSA(_modelo,_porta,_control,_cod,_quant,_pesob,_pesol,_tara,_predes,_classif,_TF,_datap,_etq,_dataval,_nNumEtq,_Lote,_IP,_cSeq,_Hora)
	elseif(_etq='P')
		MSCBPRINTER(_modelo,_porta,,,,,_IP)
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(_nNumEtq,6,40)
		// Posição d codigo de barras
		//conout('linha 2707 - > Cod-'+_cod)
		fonte1  :="35,15"
		fonte1_1:="30,15"
		fonte2  :="35,30"
		fonte2_1:="60,60"
		fonte2_2:="25,35"
		fonte2_3:="20,23"
		fonte2_4:="35,30"
		fonte2_5:="25,20" // Trocando até acertar
		fonte3  :="45,15"
		fonte3_1:="40,45"
		f_extra :="30,22"
		fonte3_2:="84,90"
		fonte3_3:="24,15"
		fonte3_4:="45,30"
		fonte4  :="20,5"
		fonte4_1:="18,10"
		fsexo 	:= "50,40"
		fonte5  :="25,25"
		//Novas fontes Criadas por Fabian Maurer - 07/06/12
		fonte_fab1 := "27,15"
		fonte_fab2 := "27,17"
		fonte_fab3 := "50,25"
		fonte_fab4 := "35,20"
		fonte_fab5 := "38,15"
		fonte_fab6 := "10,6"
		//Novas fontes para teste (Mauricio L. Roehrs)
		fonte_mlr1 := "25,10"
		fonte_mlr2 := "15,10"
		fonte_mlr3 := "45,20"
		fonte_mlr4 := "20,18"
		fonte_mlr5 := "60,18"
		fonte_mlr6 := "35,22"

		if !empty(_cReimp)
			MSCBSAY(32,110, _cReimp,"R","F",fonte_mlr3)
		endif

		IF SB1->B1_DESTINO == 'ME'

			//***************** 1º Bloco da Etiqueta ********************

			MSCBSAY(69,100,_control,"R","F",fonte_mlr1) 						//Numero de controle
			/*
			MSCBSAY(73,05,_vDESCSIF,"R","F",fonte_mlr2)                 //Descricao em Portugues
			MSCBSAY(69,05,_vDESCING,"R","F",fonte_mlr2)                 //Descricao em Ingles
			*/
			//conout("TESTE DTI 1")
			MSCBSAY(73,02,_vDESCSIF,"R","F",fonte_mlr2)
			IF _nCadM = "A"
				MSCBSAY(69,02,_vDESCING,"R","F",fonte_mlr2)
			ELSEIF _nCadM = "E"
				MSCBSAY(69,02,_VDESPAN,"R","F",fonte_mlr2)
			ENDIF
			MSCBBOX(68,01,68,180,4)                                     //Linha Divisoria

			//***************** 2º Bloco da Etiqueta ********************
			if alltrim(_cod) $ _codExp  
				if alltrim(_cod) $ ('003796/003797')
					MSCBSAY(61,05,"DATA PROD./LOTE | PRODUCTION DATE/LOT:","R","F",fonte_mlr2)
					MSCBSAY(61,70,_dtPROD,"R","F",fonte_mlr2)					
				else
					MSCBSAY(61,05,"DATA PROD./LOTE | PRODUCTION DATE/LOT:","R","F",fonte_mlr2)
					MSCBSAY(61,70,_dtPROD,"R","F",fonte_mlr2)
				endif
			else				
				MSCBSAY(61,05,"DATA PROD./LOTE | FECHA PRODUCCION/LOTE:" ,"R","F",fonte_mlr2)
				MSCBSAY(61,85,_dtPROD,"R","F",fonte_mlr2)		
				/*	remoção desta condição solicitada pela Nathiele da Qualidade
				if alltrim(_cod) $ ('003796/003797')					
					iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,05,"DATA PROD.:","R","F",fonte_mlr2),)
					iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,75,_vDTABATE,"R","F",fonte_mlr2),)
					iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,80,"HH/T","R","F",fonte_mlr2),)
				else
					//Dia 20/10/22 ajuste solicitado Pelo Gabriel para retirar Data de abate
					if alltrim(_cod) $ '018605/018606' 
						//Dia 11/11/22 - Solicitado pela adriana para que não imprima data de abate quando for esses códigos
					else						
						//iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,05,"FECHA ABATE / DATA DE ABATE:","R","F",fonte_mlr2),)
						//iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,75,_vDTABATE,"R","F",fonte_mlr2),)						
					Endif					
				endif
				*/
				MSCBSAY(64,05,"DATA DE ABATE | FECHA DE MATANZA:","R","F",fonte_mlr2)
				MSCBSAY(64,85,_vDTABATE,"R","F",fonte_mlr2)
			endif                                                                                                         
			
			MSCBSAY(58,05,"DATA DE VALIDADE | FECHA DE VALIDAD:","R","F",fonte_mlr2)
			MSCBSAY(58,85,_dtVALID,"R","F",fonte_mlr2)

			MSCBBOX(57,105,68,105,4)
			MSCBSAY(59,110,_DESTINO,"R","F",fonte_mlr3)

			MSCBBOX(57,01,57,180,4)

			//***************** 3º Bloco da Etiqueta ********************
			if  _cNotImp <> "P"
				_cPb := transform(_pesob,'@E 99.999')
				_cPesob := strtran(_cPb,',','.')				
				MSCBSAY(53,05,"PESO BRUTO | PESO BRUTO:","R","F",fonte_mlr2)
				MSCBSAY(53,70,_cPesob + " Kg","R","F",fonte_mlr2)

				_cPl    := transform(_pesol,'@E ##.###')
				_cPesol := strtran(_cPl,',','.')				
				MSCBSAY(46,05,"PESO LIQUIDO | PESO NETO:","R","F",fonte_mlr2)
				MSCBSAY(46,70,_cPesol + "Kg","R","F",fonte_mlr3)

				_cTp    := transform(_quant * _vTaraP,'@E ##.###')
				_cTaraP := strtran(_cTp,',','.')
				MSCBSAY(43,05,"TARA EMB PRIM. | TARA ENV PRIM:","R","F",fonte_mlr2)
				MSCBSAY(43,70,_cTARAP + " Kg","R","F",fonte_mlr2)

				_cTs := transform(_vTaras,'@E ##.###')
				_cTaras := strtran(_cTs,',','.')				
				MSCBSAY(40,05,"TARA EMB SEC. | TARA ENV SEC:","R","F",fonte_mlr2)
				MSCBSAY(40,70,_cTARAS + " Kg","R","F",fonte_mlr2)

				_cTa := transform(_tara,'@E #.###')
				_cTara := strtran(_cTa,',','.')				
				MSCBSAY(37,05,"TARA TOTAL | TARA TOTAL:","R","F",fonte_mlr2)
				MSCBSAY(37,70,_cTara + " Kg","R","F",fonte_mlr2)

				MSCBBOX(36,01,36,180,4)
			else				
				MSCBSAY(53,05,"PESO BRUTO | PESO BRUTO:","R","F",fonte_mlr2)
				MSCBSAY(53,70,transform(_pesob,'@E ##.###')+" Kg","R","F",fonte_mlr2)

				MSCBSAY(46,05,"PESO LIQUIDO | PESO NETO:","R","F",fonte_mlr2)

				MSCBSAY(46,70,transform(_pesol,'@E ##.###')+"Kg","R","F",fonte_mlr3)
				
				MSCBSAY(43,05,"TARA EMB PRIM. | TARA ENV PRIM:","R","F",fonte_mlr2)
				MSCBSAY(43,70,transform(_quant * _vTARAP,'@E ##.###')+" Kg","R","F",fonte_mlr2)

				MSCBSAY(40,05,"TARA EMB SEC. | TARA ENV SEC:","R","F",fonte_mlr2)
				MSCBSAY(40,70,transform(_vTARAS,'@E ##.###')+" Kg","R","F",fonte_mlr2)
				
				MSCBSAY(37,05,"TARA TOTAL | TARA TOTAL:","R","F",fonte_mlr2)
				MSCBSAY(37,70,transform(_tara,'@E ##.###')+" Kg","R","F",fonte_mlr2)

				MSCBBOX(36,01,36,180,4)

			endif

			//***************** 4º Bloco da Etiqueta ********************

			MSCBSAY(33,05,_vMENETQ,"R","0",fonte_mlr4)
			
			_dTdP := ""
			_dTdP := substr(_dtPROD,0,2)
			_dTdP := _dTdP + substr(_dtPROD,4,2)
			_dTdP := _dTdP + substr(_dtPROD,7,2)

			If _c_TIPO <> 'PR'
				MSCBSAY(33,85,'RASTREABILIDADE: 1733' +_dTdP+"0000","R","0",fonte_mlr4)
			Endif

			_cPrdArg := getMv('SI_PRDARG')
			If alltrim(_cod) $ _cPrdArg
				MSCBSAY(27,92,'VENTA AL PESO. No Recongelar',"R","0",fonte_mlr4)
			endif

			iif(!empty(_GLUTEM),MSCBSAY(30,05,ALLTRIM(_GLUTEM)  + " | INDÚSTRIA BRASILEIRA","R","0",fonte_mlr4),)     // Mensagem do Glutem

			iif(!empty(_DESCTIPO),MSCBSAY(27,05,_DESCTIPO,"R","0",fonte_mlr4),) //  B1_MENETQ2

			iif (!empty(_Lote) .and. !empty(_predes).and. substr(_predes,1,3) <> 'SIF',MSCBBOX(26,105,36,105,4),)

			iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,106,"LOTE:","R","F",fonte_mlr2),)    //Lote

			iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,116,_Lote,"R","F",fonte_mlr2),)  //descricao do lote preenchido no lançamento da OP da embalagem

			MSCBSAY(27,70,_SEXO,"R","0",fonte_mlr4) //descrição do sexo. preenche campo MENTETQ4 no cadastro de produtos
			
			MSCBSAY(27,110, _Hora,"R","0",fonte_mlr6)
			
			MSCBBOX(26,01,26,180,4)

			//***************** 5º Bloco da Etiqueta ********************
			//conout("TESTE DTI 2")
			//MSCBSAY(17,05,_despor + " / " + _desing,"R","F",fonte_mlr5)
			IF _nCadM = "A"
				MSCBSAY(17,02,_despor+"/"+_desing,"R","F",fonte_mlr5)
			ELSEIF _nCadM = "E"
				MSCBSAY(17,02,_despor+"/"+_desesp,"R","F",fonte_mlr5)
			ENDIF

			MSCBSAYBAR(06,62,_control,"R","C",10,.F.,.T.,,,2,1,.T.)

			MSCBBOX(06,88,18,123,80,"B")                                          //Box preto onde fica o cod. do produto

			MSCBSAYMEMO(03,88,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
			MSCBSAY(01,94,"PE:"+ _cSeq,"R","0","25,20")
		ELSE // Próxima parte MI

			//***************** 1º Bloco da Etiqueta ********************

			MSCBSAY(72,100,_control,"R","F",fonte_mlr1)         					// Numero de controle

			MSCBSAY(75,05,_vDESCSIF,"R","F",fonte_mlr2)   						//Descrição em Portugues do SIF

			MSCBSAY(72,05,_vDESCING,"R","F",fonte_mlr2) 						//Descrição em Ingles

			MSCBBOX(71,01,71,125,4) 											// Linha Divisoria

			//************** 2º Bloco da Etiqueta ***********************
			MSCBSAY(64,05,"DATA PROD./LOTE. |  " + "PRODUCTION DATE/LOT.:","R","F",fonte_mlr2) //Descrição data de produção			
			MSCBSAY(64,85,_dtPROD,"R","F",fonte_mlr2)             				// Data de Produção
			
			MSCBSAY(61,05,"DATA DE VALIDADE | EXPIRY DATE:","R","F",fonte_mlr2)
			MSCBSAY(61,85,_dtVALID,"R","F",fonte_mlr2) 
			
			iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(67,05,"DATA DE ABATE | SLAUGHTER DATE","R","F",fonte_mlr2),)
			iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(67,85,_vDTABATE,"R","F",fonte_mlr2),)
			
			MSCBBOX(61,105,71,105,4)                                            // Linha Separa Tipo de Mercado

			MSCBSAY(62,110,_DESTINO,"R","F",fonte_mlr3)  		// Descrição Tipo de Mercado (MI)   (ajuste na linha - retirada a verificação do TF - conforme contato com Matheus Ribeiro)    
			iif(_TF == 'S',MSCBSAY(33,105,"TF","R","0",fonte2_1),)  			//Incluido por Flávio - Dia 17/09/2016 a pedido da qualidade (stefânia)
			MSCBBOX(61,01,61,125,4) 											// Linha Divisoria

			//************** 3º Bloco da Etiqueta *************************

			if  _cNotImp <> "P"

				_cPb    := transform(_pesob,'@E 99.999')
				_cPesob := strtran(_cPb,',','.')
				MSCBSAY(57,05,"PESO BRUTO | GROSS WEIGHT:","R","F",fonte_mlr2) 		// Descrição peso bruto da caixa
				MSCBSAY(57,70,_cPesob + " Kg","R","F",fonte_mlr2) // Peso Bruto

				_cPl    := transform(_pesol,'@E ##.###')
				_cPesol := strtran(_cPl,',','.')
				MSCBSAY(51,05,"PESO LIQUIDO | NET WEIGHT:","R","F",fonte_mlr2)      // Descrição peso liquido
				MSCBSAY(51,70, _cPesol + " Kg","R","F",fonte_mlr3)   	// Peso liquido
				// Descrição KG

				_cTp    := transform(_quant * _vTaraP,'@E ##.###')
				_cTaraP := strtran(_cTp,',','.')
				MSCBSAY(48,05,"TARA EMB.PRIM. | INTERNAL TARE:","R","F",fonte_mlr2) 	// Descrição tara primaria
				MSCBSAY(48,70,_cTaraP + " Kg","R","F",fonte_mlr2) // Tara primaria

				_cTs 	  := transform(_vTaras,'@E ##.###')
				_cTaras := strtran(_cTs,',','.')
				MSCBSAY(45,05,"TARA EMB SEC. | TARE:","R","F",fonte_mlr2) 			// Descrição tara secundaria
				MSCBSAY(45,70,_cTaras + " Kg","R","F",fonte_mlr2) // Tara secundaria

				_cTa   := transform(_tara,'@E #.###')
				_cTara := strtran(_cTa,',','.')
				MSCBSAY(42,05,"TARA TOTAL | TOTAL TARE:","R","F",fonte_mlr2)   	// Descrição tara total da caixa
				MSCBSAY(42,70,_cTara + " Kg","R","F",fonte_mlr2) // Tara total

				MSCBBOX(41,01,41,125,4)

			else
				MSCBSAY(57,05,"PESO BRUTO | GROSS WEIGHT:","R","F",fonte_mlr2) 		// Descrição peso bruto da caixa
				MSCBSAY(57,70,transform(_pesob,'@E ##.###')+" Kg","R","F",fonte_mlr2) // Peso Bruto

				MSCBSAY(51,05,"PESO LIQUIDO | NET WEIGHT:","R","F",fonte_mlr2)      // Descrição peso liquido
				MSCBSAY(51,70, transform(_pesol,'@E ##.###')+" Kg","R","F",fonte_mlr3)   	// Peso liquido				

				MSCBSAY(48,05,"TARA EMB.PRIM. | INTERNAL TARE:","R","F",fonte_mlr2) 	// Descrição tara primaria
				MSCBSAY(48,70,transform(_quant * _vTARAP,'@E ##.###')+" Kg","R","F",fonte_mlr2) // Tara primaria

				MSCBSAY(45,05,"TARA EMB SEC. | TARE:","R","F",fonte_mlr2) 			// Descrição tara secundaria
				MSCBSAY(45,70,transform(_vTARAS,'@E ##.###')+" Kg","R","F",fonte_mlr2) // Tara secundaria

				MSCBSAY(42,05,"TARA TOTAL | TOTAL TARE:","R","F",fonte_mlr2)   	// Descrição tara total da caixa
				MSCBSAY(42,70,transform(_tara,'@E #.###')+" Kg","R","F",fonte_mlr2) // Tara total

				MSCBBOX(41,01,41,125,4) 											// Linha Divisoria

				// Linha Divisoria
			endif

			//******************* 4º Bloco da Etiqueta ************************			
			MSCBSAYBAR(32,31,'010' + _nCodBar + '310200' + substr(_cPesol,1,2) + substr(_cPesol,3,2),"R","C",8,.F.,.T.,,,3,1,.T.)  //EAN exigido pelo walmart
			//******************* 5º Bloco da Etiqueta ************************
			_dTdP := ""
			_dTdP := substr(_dtPROD,0,2)
			_dTdP := _dTdP + substr(_dtPROD,4,2)
			_dTdP := _dTdP + substr(_dtPROD,7,2)

			MSCBBOX(28,01,28,125,4)												// Linha Divisoria
			MSCBSAY(20,110, _Hora,"R","0",fonte_mlr6)

			//Alteração Solicitada pela Karine para realocar as mensagens da etiqueta somente para produtos Salgados
			//Alteração feita por Mauricio Roehrs

			if _cFarm <> 'S' //se for diferente de "Salgados" imprime padrão
				MSCBSAY(25,04,_vMENETQ,"R","0",fonte_mlr4)                          // Mensagem da Agricultura
				If _c_TIPO <> 'PR'
					MSCBSAY(25,85,'RASTREABILIDADE: 1733' +_dTdP+"0000","R","0",fonte_mlr4)
				Endif

				iif(!empty(_GLUTEM),MSCBSAY(22,04,ALLTRIM(_GLUTEM)  + " | INDÚSTRIA BRASILEIRA","R","0",fonte_mlr4),)     // Mensagem do Glutem

				iif(!empty(_DESCTIPO),MSCBSAY(19,04,_DESCTIPO,"R","0",fonte_mlr4),) // Mensagem do Tipo

				//MSCBSAY(22,100,'Lote/Lot: ' + SZ8->Z8_PREDES,"R","0",fonte_mlr4)
				//Fim da inclusão

			else //senão imprime com alterações Solicitadas
				MSCBSAY(25,04,_vMENETQ,"R","0",fonte_mlr4)                          // Mensagem da Agricultura ok
				If _c_TIPO <> 'PR'
					MSCBSAY(25,85,'RASTREABILIDADE: 1733' +_dTdP+"0000","R","0",fonte_mlr4)
				Endif

				iif(!empty(_GLUTEM),MSCBSAY(22,04,ALLTRIM(_GLUTEM)  + " | INDÚSTRIA BRASILEIRA","R","0",fonte_mlr4),)     // Mensagem do Glutem ok

				iif(!empty(_DESCTIPO),MSCBSAY(19,04,_DESCTIPO,"R","0",fonte_mlr4),) // Mensagem do Tipo

				iif(!empty(_SEXO),MSCBSAY(22,60,_SEXO,"R","0",fonte_mlr4),) // Mensagem Utilizada para "SEXO" alterada por solicitação da Karine
				
				//MSCBSAY(22,100,'Lote/Lot: ' + SZ8->Z8_PREDES,"R","0",fonte_mlr4)
				//Fim da inclusão
			endif

			//******************* 6º Bloco da Etiqueta ************************

			MSCBBOX(18,01,18,125,4)  											// Linha Divisoria			
			
			if len(_despor + _desing) > 40
				_cPrimFrase := substr(_despor + _desing,1,50)
				_cSegFrase  := substr(_despor + _desing,51,30)
				_cTercF  := substr(_despor + _desing,81,30)
				MSCBSAY(15,04,_cPrimFrase,"R","F",fonte_mlr2)
				MSCBSAY(12,04,_cSegFrase,"R","F",fonte_mlr2)
				MSCBSAY(9,04,_cTercF,"R","F",fonte_mlr2)
			else
				MSCBSAY(14,04, _despor + " (" + _desing + ")" ,"R","F",fonte_mlr2)
			endif

			MSCBSAYBAR(04,62,_control,"R","C",10,.F.,.T.,,,2,1,.T.)  			// Numero do controle da caixa código de barras			
			MSCBBOX(4,88,17,123,80,"B")    										// Box que fica o cod. Produto dentro			
			MSCBSAYMEMO(2,88,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
			MSCBSAY(01,95,"PE:"+ _cSeq,"R","0","25,20")						// Numero da Pre-Etiqueta

			// Inclusão dia 20/09/16 - Flávio 
			iif(AllTrim(_classif) = 'RT',MSCBSAY(42,107,_classif,"R","0",fonte2_1),)
			iif(AllTrim(_classif) == 'RT',iif(!empty(_predes),MSCBSAY(55,05,"RASTREABILIDADE :" + _vRASTRO,"R","0",fonte_mlr4),),)

			//******************* Não Utilizados ************************

			/* Bloco a Definir se aparece em Mercado Interno
			iif(AllTrim(_classif) == 'RT',iif(!empty(_predes),MSCBSAY(53,05,"RASTREABILIDADE :","R","0",fonte2),),) 	// Descrição Rastreabilidade
			iif(AllTrim(_classif) == 'RT',iif(!empty(_predes),MSCBSAY(53,37,_vRASTRO,"R","0",fonte2),),)             //
			iif(!empty(_predes),MSCBSAY(53,75,"DATA PRODUCAO: ","R","0",fonte2),)       //data de abate //usado por mauricio no ME
			iif(!empty(_predes),MSCBSAY(53,110,_vDTABATE,"R","0",fonte2),)
			iif(AllTrim(_classif) = 'RT',MSCBSAY(36,107,_classif,"R","0",fonte2_1),)  VER SE ENTRA E COLOCAR EM NOVO BLOCO
			iif(_TF == 'S',MSCBSAY(33,105,"TF","R","0",fonte2_1),)  	VER SE ENTRA E COLOCAR EM NOVO BLOCO
			iif(!empty(_SEXO),MSCBSAY(27,97,_SEXO,"R","0",fsexo),)   VERIFICAR SE ENTRA E COLOCAR E NOVO BLOCO
			iif(!empty(_vTIP),MSCBSAY(13,5,"Categoria","R","0",fonte2_3),)
			iif(!empty(_vTIP),MSCBSAY(2,5,_vTIP,"R","0",fonte3_2),)      //codigo tipificação  Categria
			MSCBSAY(15,5,_descFAM,"R","0",fonte2)   //descrição da família
			*/
		ENDIF
		//conout('linha 3122 -> final de impressão- > Cod-'+_cod)
		MSCBEND()
		MSCBCLOSEPRINTER()

		//******************************** Inicio Etiqueta Espanhol ******************************\\
	elseif(_etq='E')
		MSCBPRINTER(_modelo,_porta,,,,,_IP)		
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(_nNumEtq,6,40)
		// Posição d codigo de barras
		fonte1  :="35,15"
		fonte1_1:="30,15"
		fonte2  :="35,30"
		fonte2_1:="60,60"
		fonte2_2:="25,35"
		fonte2_3:="20,23"
		fonte2_4:="35,30"
		fonte2_5:="25,20" // Trocando até acertar
		fonte3  :="45,15"
		fonte3_1:="40,45"
		f_extra :="30,22"
		fonte3_2:="84,90"
		fonte3_3:="24,15"
		fonte3_4:="45,30"
		fonte4  :="20,5"
		fonte4_1:="18,10"
		fsexo := "50,40"
		fonte5  :="25,25"
		//Novas fontes Criadas por Fabian Maurer - 07/06/12
		fonte_fab1 := "27,15"
		fonte_fab2 := "27,17"
		fonte_fab3 := "50,25"
		fonte_fab4 := "35,20"
		fonte_fab5 := "38,15"
		fonte_fab6 := "10,6"
		//Novas fontes para teste (Mauricio L. Roehrs)
		fonte_mlr1 := "25,10"
		fonte_mlr2 := "15,10"
		fonte_mlr3 := "45,20"
		fonte_mlr4 := "20,18"
		fonte_mlr5 := "60,18"

		if !empty(_cReimp)
			MSCBSAY(32,110, _cReimp,"R","F",fonte_mlr3)
		endif

		//***************** 1º Bloco da Etiqueta ********************

		MSCBSAY(69,100,_control,"R","F",fonte_mlr1) 						//Numero de controle
		MSCBSAY(73,05,_vDESCSIF,"R","F",fonte_mlr2)                 //Descricao em Portugues
		MSCBSAY(69,05,_vDESCES,"R","F",fonte_mlr2)	//MSCBSAY(69,05,_vDESCING,"R","F",fonte_mlr2)                 //Descricao em Ingles
		MSCBBOX(68,01,68,180,4)                                     //Linha Divisoria

		//***************** 2º Bloco da Etiqueta ********************
		
		MSCBSAY(61,05,"DATA PROD/LOTE | FECHA PRODUCCION/LOTE:","R","F",fonte_mlr2)			
		MSCBSAY(61,87,_dtPROD,"R","F",fonte_mlr2)

		MSCBSAY(58,05,"DATA DE VALIDADE|FECHA DE VALIDAD:","R","F",fonte_mlr2)
		MSCBSAY(58,87,_dtVALID,"R","F",fonte_mlr2)
		/*
		if _cod = '003796' .or. _cod = '003797'
			//iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,5,"FECHA PROD./ ABATE/ DATA DE PROD.:","R","F",fonte_mlr2),)
			iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(64,5,"FECHA ABATE/LOTE /DATA ABATE/LOTE:","R","F",fonte_mlr2),)
			iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(64,80,_vDTABATE,"R","F",fonte_mlr2),)
			iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(64,97,'HH/T',"R","F",fonte_mlr2),)
		else			
			iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(64,5,"FECHA ABATE/LOTE /DATA ABATE/LOTE:","R","F",fonte_mlr2),)
			iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(64,80,_vDTABATE,"R","F",fonte_mlr2),)
		endif
		*/
		MSCBSAY(64,05,"DATA DE ABATE | FECHA DE MATANZA:","R","F",fonte_mlr2)
		MSCBSAY(64,87,_vDTABATE,"R","F",fonte_mlr2)
		MSCBBOX(57,105,68,105,4)
		MSCBSAY(62,110,_DESTINO,"R","F",fonte_mlr3)

		MSCBBOX(57,01,57,180,4)

		//***************** 3º Bloco da Etiqueta ********************
		if  _cNotImp <> "P"
			_cPb := transform(_pesob,'@E 99.999')
			_cPesob := strtran(_cPb,',','.')
			MSCBSAY(53,05,"PESO BRUTO | PESO BRUTO:","R","F",fonte_mlr2)
			MSCBSAY(53,75,_cPesob + " Kg","R","F",fonte_mlr2)

			_cPl    := transform(_pesol,'@E ##.###')
			_cPesol := strtran(_cPl,',','.')
			MSCBSAY(46,05,"PESO LIQUIDO | PESO NETO:","R","F",fonte_mlr2)
			MSCBSAY(46,75,_cPesol + "Kg","R","F",fonte_mlr3)

			_cTp    := transform(_quant * _vTaraP,'@E ##.###')
			_cTaraP := strtran(_cTp,',','.')
			MSCBSAY(43,05,"TARA EMB.PRIM. | TARA ENV. PRIM.:","R","F",fonte_mlr2)
			MSCBSAY(43,75,_cTARAP + " Kg","R","F",fonte_mlr2)

			_cTs := transform(_vTaras,'@E ##.###')
			_cTaras := strtran(_cTs,',','.')
			MSCBSAY(40,05,"TARA EMB. SEC. | TARA ENV. SEC.:","R","F",fonte_mlr2)
			MSCBSAY(40,75,_cTARAS + " Kg","R","F",fonte_mlr2)

			_cTa := transform(_tara,'@E #.###')
			_cTara := strtran(_cTa,',','.')
			MSCBSAY(37,05,"TARA TOTAL | TARA TOTAL:","R","F",fonte_mlr2)
			MSCBSAY(37,75,_cTara + " Kg","R","F",fonte_mlr2)

			MSCBBOX(36,01,36,180,4)
		else
			MSCBSAY(53,05,"PESO BRUTO | PESO BRUTO:","R","F",fonte_mlr2)
			MSCBSAY(53,75,transform(_pesob,'@E ##.###')+" Kg","R","F",fonte_mlr2)

			MSCBSAY(46,05,"PESO LIQUIDO | PESO NETO:","R","F",fonte_mlr2)
			MSCBSAY(46,75,transform(_pesol,'@E ##.###')+"Kg","R","F",fonte_mlr3)

			MSCBSAY(43,05,"TARA EMB.PRIM. | TARA ENV.PRIM.:","R","F",fonte_mlr2)
			MSCBSAY(43,75,transform(_quant * _vTARAP,'@E ##.###')+" Kg","R","F",fonte_mlr2)

			MSCBSAY(40,05,"TARA EMB. SEC. | TARA ENV. SEC.:","R","F",fonte_mlr2)
			MSCBSAY(40,75,transform(_vTARAS,'@E ##.###')+" Kg","R","F",fonte_mlr2)

			MSCBSAY(37,05,"TARA TOTAL | TARA TOTAL:","R","F",fonte_mlr2)
			MSCBSAY(37,75,transform(_tara,'@E ##.###')+" Kg","R","F",fonte_mlr2)			

			MSCBBOX(36,01,36,180,4)

		endif
		
		//MSCBSAY(39,100, _Hora,"R","F",fonte_mlr2)
		//***************** 4º Bloco da Etiqueta ********************
		_dTdP := ""
		_dTdP := substr(_dtPROD,0,2)
		_dTdP := _dTdP + substr(_dtPROD,4,2)
		_dTdP := _dTdP + substr(_dtPROD,7,2)

		MSCBSAY(33,85,'RASTREABILIDADE: 1733' +_dTdP+"0000","R","0",fonte_mlr4)
		MSCBSAY(27,100, _Hora,"R","0",fonte_mlr6)
		MSCBSAY(33,05,_vMENETQ,"R","0",fonte_mlr4)

		iif(!empty(_GLUTEM),MSCBSAY(30,05,ALLTRIM(_GLUTEM)  + " | INDÚSTRIA BRASILEIRA","R","0",fonte_mlr4),)     // Mensagem do Glutem

		iif(!empty(_DESCTIPO),MSCBSAY(27,05,_DESCTIPO,"R","0",fonte_mlr4),) // Mensagem do Tipo

		iif (!empty(_Lote) .and. !empty(_predes).and. substr(_predes,1,3) <> 'SIF',MSCBBOX(26,105,36,105,4),)

		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,106,"LOTE:","R","F",fonte_mlr2),)//Lote
		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,116,_Lote,"R","F",fonte_mlr2),)  //descricao do lote preenchido no lançamento da OP da embalagem

		MSCBSAY(27,70,_SEXO,"R","0",fonte_mlr4) //descrição do sexo. preenche campo MENTETQ4 no cadastro de produtos

		MSCBBOX(26,01,26,180,4)
		
		_cPrdArg := getMv('SI_PRDARG')

			If alltrim(_cod) $ _cPrdArg
				MSCBSAY(05,20+_linha,'VENTA AL PESO. No Recongelar',"I","0",fonte5_1)
			endif

		//***************** 5º Bloco da Etiqueta ********************

		MSCBSAY(17,05,_despor + " | " + _desing,"R","F",fonte_mlr5)

		MSCBSAYBAR(06,62,_control,"R","C",10,.F.,.T.,,,2,1,.T.)

		//MSCBBOX(06,92,18,123,80,"B")                                          //Box preto onde fica o cod. do produto
		MSCBBOX(06,88,18,123,80,"B")                                          //Box preto onde fica o cod. do produto
		//MSCBSAYMEMO(03,92,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
		MSCBSAYMEMO(03,88,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
		MSCBSAY(01,94,"PE:"+_cSeq,"R","0","25,20")

		// Inclusão feita por Flávio dia 21/10 - a Pedido da Qualidade ,pois foi informado que temos códigos que precisam sair com etiqueta em Espanhol
		//iif(_AllTrim(classif) = 'RT',MSCBSAY(42,107,_classif,"R","0",fonte2_1),)  - - -vlotar
		iif(AllTrim(_classif) == 'RT',iif(!empty(_predes),MSCBSAY(30,05,"RASTREABILIDADE :" + _vRASTRO,"R","0",fonte_mlr4),),)

		MSCBEND()
		MSCBCLOSEPRINTER()	  

		//******************************** Inicio Etiqueta Frances ******************************\\

	elseif(_etq='F')
		MSCBPRINTER(_modelo,_porta,,,,,_IP)
		//MSCBPRINTER(_modelo,_porta)
		//MSCBPRINTER(_modelo,'COM3:9600,n,8,1')
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(_nNumEtq,6,40)
		// Posição d codigo de barras
		fonte1  :="35,15"
		fonte1_1:="30,15"
		fonte2  :="35,30"
		fonte2_1:="60,60"
		fonte2_2:="25,35"
		fonte2_3:="20,23"
		fonte2_4:="35,30"
		fonte2_5:="25,20" // Trocando até acertar
		fonte3  :="45,15"
		fonte3_1:="40,45"
		f_extra :="30,22"
		fonte3_2:="84,90"
		fonte3_3:="24,15"
		fonte3_4:="45,30"
		fonte4  :="20,5"
		fonte4_1:="18,10"
		fsexo := "50,40"
		fonte5  :="25,25"
		//Novas fontes Criadas por Fabian Maurer - 07/06/12
		fonte_fab1 := "27,15"
		fonte_fab2 := "27,17"
		fonte_fab3 := "50,25"
		fonte_fab4 := "35,20"
		fonte_fab5 := "38,15"
		fonte_fab6 := "10,6"
		//Novas fontes para teste (Mauricio L. Roehrs)
		fonte_mlr1 := "25,10"
		fonte_mlr2 := "15,10"
		fonte_mlr3 := "45,20"
		fonte_mlr4 := "20,18"
		fonte_mlr5 := "60,18"

		//***************** 1º Bloco da Etiqueta ********************

		MSCBSAY(73,85,_control,"R","F",fonte_mlr1) 						//Numero de controle
		MSCBSAY(73,05,_vDESCFRA,"R","F",fonte_mlr2)                 //Descricao em Ingles
		MSCBSAY(69,05,_vDESCSIF,"R","F",fonte_mlr2)                 //Descricao em Portugues
		MSCBBOX(68,01,68,180,4)                                     //Linha Divisoria

		//***************** 2º Bloco da Etiqueta ********************

		MSCBSAY(64,05,"DATE D' EMBALLAGE/DATA EMBALAGEM:","R","F",fonte_mlr2)
		MSCBSAY(64,70,_dtPROD,"R","F",fonte_mlr2)

		MSCBSAY(61,05,"DATE DE VALIDITE/DATA VALIDADE:","R","F",fonte_mlr2)
		MSCBSAY(61,70,_dtVALID,"R","F",fonte_mlr2)

		//MSCBSAY(58,05,"PIECE/PECA:","R","F",fonte_mlr2)
		//MSCBSAY(58,27,transform(_quant,'@E ######'),"R","F",fonte_mlr2)

		iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,38,"DATE DE PRODUCTION/DATA PRODUCAO:","R","F",fonte_mlr2),)
		iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,77,_vDTABATE,"R","F",fonte_mlr2),)

		MSCBBOX(57,105,68,105,4)
		MSCBSAY(62,110,_DESTINO,"R","F",fonte_mlr3)

		MSCBBOX(57,01,57,180,4)

		//***************** 3º Bloco da Etiqueta ********************

		MSCBSAY(53,05,"POIDS BRUT/PESO BRUTO(Kg):","R","F",fonte_mlr2)
		MSCBSAY(53,70,transform(_pesob,'@E ##.###')+" Kg","R","F",fonte_mlr2)

		MSCBSAY(46,05,"POIDS NET/PESO LIQUIDO(Kg):","R","F",fonte_mlr2)
		MSCBSAY(46,70,transform(_pesol,'@E ##.###')+"Kg","R","F",fonte_mlr3)

		MSCBSAY(43,05,"INTERNAL TARE/TARA EMB.PRIM.:","R","F",fonte_mlr2)
		MSCBSAY(43,70,transform(_vTARAP,'@E ##.###')+" Kg","R","F",fonte_mlr2)

		MSCBSAY(40,05,"TARE/TARA EMB. SEC.:","R","F",fonte_mlr2)
		MSCBSAY(40,70,transform(_vTARAS,'@E ##.###')+" Kg","R","F",fonte_mlr2)

		MSCBSAY(37,05,"TOTAL TARE/TARA TOTAL:","R","F",fonte_mlr2)
		MSCBSAY(37,70,transform(_tara,'@E ##.###')+" Kg","R","F",fonte_mlr2)

		MSCBBOX(36,01,36,180,4)

		//***************** 4º Bloco da Etiqueta ********************

		MSCBSAY(33,05,_vMENETQ,"R","0",fonte_mlr4)
		MSCBSAY(30,110, _Hora,"R","0",fonte_mlr6)
		//Inicio Inclusão por Fabian Maurer 27/08/2019
		//MSCBSAY(33,100,'Lot/Lote: ' + SZ8->Z8_PREDES,"R","0",fonte_mlr4)
		MSCBSAY(31,100,'Lot/Lote: ' + SZ8->Z8_PREDES,"R","0",fonte_mlr4)
		// Fim da Inclusão
		MSCBSAY(30,05,ALLTRIM(_GLUTEM)  + " | INDÚSTRIA BRASILEIRA","R","0",fonte_mlr4)

		iif(!empty(_DESCTIPO),MSCBSAY(27,05,_DESCTIPO,"R","0",fonte_mlr4),) // Mensagem do Tipo

		iif (!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBBOX(26,105,36,105,4),)

		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,106,"LOTE:","R","F",fonte_mlr2),)    //Lote
		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,116,_Lote,"R","F",fonte_mlr2),)  //descricao do lote preenchido no lançamento da OP da embalagem

		MSCBSAY(27,70,_SEXO,"R","0",fonte_mlr4) //descrição do sexo. preenche campo MENTETQ4 no cadastro de produtos

		MSCBBOX(26,01,26,180,4)

		//***************** 5º Bloco da Etiqueta ********************

		MSCBSAY(17,05,_desfra+_despor,"R","F",fonte_mlr5)

		MSCBSAYBAR(06,62,_control,"R","C",10,.F.,.T.,,,2,1,.T.)

		//MSCBBOX(06,92,18,123,80,"B")                                          //Box preto onde fica o cod. do produto
		MSCBBOX(06,88,18,123,80,"B")                                          //Box preto onde fica o cod. do produto
		//MSCBSAYMEMO(03,92,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
		MSCBSAYMEMO(03,88,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
		MSCBSAY(01,94,"PE:"+_cSeq,"R","0","25,20")

		MSCBEND()
		MSCBCLOSEPRINTER()
	endif
return .t.


//Etiqueta para impressão na solução de automação
user function GJF111g(_modelo,_porta,_control,_cod,_pesob,_pesol,_tara,_predes,_datap,_dataval,_nNumEtq,_IP)
	/*                     1      2      3      4     5      6     7      8     9        10     11    12   13     14       15       16   17
	Paremetros da função
	1  - modelo da impressora
	2  - porta
	3  - sequencial da caixa
	4  - codigo do produto
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
	16 - Lote (exclusivo para exportação)
	17 - Endereço IP para conexão ethernet
	*/

	//local dtAbate   := ''
	local _vDESCES  := ''
	local _vDINGLES := ''
	local _vDESCING := ''
	local _vDFRANCES:= ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vDESCFRA := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vTARAP   := 0.00
	local _vTARAS   := 0.00
	local _vMENETQ  := ''
	local _vFAM     := ''
	local _DESTINO  := ''
	local _DESCTIPO := ''
	local _GLUTEM   := ''
	local _SEXO     := ''
	local _vNUMAM   := ''
	local _vDTABATE := ''
	//local _vRASTRO  := ''
	local _desing   := ''
	//local _desfra   := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _despor   := ''
	local _descFAM  := ''
	local _dtPROD   := ''
	local _dtVALID  := ''
	local _nTS      := ''
	local _nTP      := ''
	local _cSeq     := ''
	//local _cPesol   := strtran(cValtoChar(_pesol),'.','')
	//local _cModo    := GETMV('SI_MIMPEMB')
	//local _cIpImp   := GETMV('SI_IPIMP')

	SB1->(dbsetorder(1))
	if SB1->(Msseek(Fwxfilial('SB1')+alltrim(_cod)))
		_vDINGLES := SB1->B1_DESCING //os dois campos abaixo estao invertidos de proposito para não
		_vDESCING := SB1->B1_DINGLES //precisar mexer no layout de impressao - B1_DINGLES é a do SIF
		_vDFRANCES:= SB1->B1_DESCFRA  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
		_vDESCFRA := SB1->B1_DFRANCE //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
		_vDESCES  := SB1->B1_DESCESP // e o B1_DESCING a descrição em ingles do produto
		_vDESCSIF := SB1->B1_DESCSIF
		_nTS      := SB1->B1_CTARASE
		_nTP      := SB1->B1_CTARAP  // Incluido por Fabian Maurer - 08/05/2012 - nao estava pegando certo a tara primaria
		_nCodBar  := SB1->B1_CODBAR
		_nCdBarcli := SB1->B1_EANCLI
		_cGrupo   := SB1->B1_GRUPO
		_cFarm    := GetAdvFVal('SBM','BM_FARM',Fwxfilial('SBM')+_cGrupo,1)

		ZAB->(DbSetOrder(1))
		if ZAB->(MsSeek(Fwxfilial('ZAB')+alltrim(_nTS)))
			_vTARAS   := ZAB->ZAB_TARA
		endif

		if ZAB->(MsSeek(Fwxfilial('ZAB')+alltrim(_nTP)))
			_vTARAP   := ZAB->ZAB_TARA
		endif

		_vMENETQ  := SB1->B1_MENETQ1
		_vFAM     := SB1->B1_FAM
		_DESTINO  := SB1->B1_DESTINO
		_DESCTIPO := SB1->B1_MENETQ2
		_GLUTEM   := SB1->B1_MENETQ3
		_SEXO	    := SB1->B1_MENETQ4
	endif

	if !empty(_predes) .and. substr(_predes,1,3) <> 'SIF'
		SZ2->(DbSetOrder(2))
		if  SZ2->(MsSeek(Fwxfilial('SZ2')+_predes))                          	// se houver o apontamento de OP...
			_vNUMAM   := SZ2->Z2_NUMAM //GetAdvFVal('SZ2',2,Fwxfilial('SZ2')+_predes,'Z2_NUMAM')  				//numero aviso de matança
			_vDTABATE := dtoc(SZ2->Z2_DATAABT) //dtoc(GetAdvFVal('SZ2',2,Fwxfilial('SZ2')+_predes,'Z2_DATAABT'))//aviso de matança formatado em string
		endif
	endif

	_despor  :=  substr(alltrim(SB1->B1_DESCRED),1,17)
	_cSeq    := ZAS->ZAS_SEQPET

	DbSelectArea('SX5')
	_descFAM := GetAdvFVal('SX5','X5_DESCRI',Fwxfilial("SX5")+'PS'+_vFAM,1)
	_dtPROD  := dtoc(_datap)
	_dtVALID := dtoc(_dataval) //data da produção

	/*************************** Etiqueta Padrão  ************************************************ */

	_linP := -20

	MSCBPRINTER(_modelo,_porta,,,,,_IP)

	//	  	MSCBPRINTER(_modelo,_porta)
	//MSCBPRINTER(_modelo,_porta,,,,,'10.7.0.103')

	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(_nNumEtq,6,40)
	// Posição d codigo de barras
	fonte1  :="40,20"
	fonte1_1:="30,15"
	fonte1_2:="85,85" //100/50
	fonte1_3:="38,12"
	fonte2  :="35,30"
	fonte2_1:="100,100"
	fonte2_2:="25,35"
	fonte2_3:="20,23"
	fonte2_4:="35,30"
	fonte2_5:="25,20" // Trocando até acertar
	fonte3  :="35,12"//42
	fonte3_1:="40,45"
	f_extra :="30,22"
	fonte3_2:="84,90"
	fonte3_3:="24,15"
	fonte3_4:="45,30"
	fonte3_5 := "70,55"
	fonte4  :="20,5"
	fonte4_1:="16,8"
	fsexo   :="65,50"
	fonte4_2:="120,65"
	fonte5  :="25,25"
	fonte5_1 := "20,18"

	//******************* 1º Bloco da Etiqueta ************************	

	_cDescSIF :=  substr(_vDESCSIF,1,35)

	MSCBSAY(7,88,_control,"I","0",fonte2_2)         	//numero de controle

	MSCBSAY(62+_linP,85,'MATERIA-PRIMA PORCIONADOS',"I","0",fonte2_2) 					//descrição do SIF

	MSCBLineH(01,84,300,4,"B")                  //Linha Divisoria

	//******************* 2º Bloco da Etiqueta ************************

	MSCBSAY(54+_linP,80,"PACKING DATE/DATA EMBALAGEM:","I","0",fonte2_2)   //data de produção
	MSCBSAY(37+_linP,80,_dtPROD,"I","0",fonte2_2)

	MSCBSAY(62+_linP,77,"EXPIRY DATE/DATA VALIDADE:","I","0",fonte2_2)   //data de validade - Alterado por Fabian Maurer - 02/05/12 - Correção Escrita
	MSCBSAY(37+_linP,77,_dtVALID,"I","0",fonte2_2)
	
	iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(54+_linP,71,"SLAUGHTER DATE /DATA ABATE:","I","0",fonte2_2),)       //data de abate
	iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(37+_linP,71,_vDTABATE,"I","0",fonte2_2),)

	//******************* 3º Bloco da Etiqueta ************************

	MSCBLineH(01,70,300,4,"B")
	MSCBSAY(57+_linP,66,"GROSS WEIGHT/PESO BRUTO(Kg):","I","0",fonte2_2) //peso bruto da caixa
	MSCBSAY(35+_linP,66,transform(_pesob,'@E ##.###'),"I","0",fonte2_2)

	MSCBSAY(59+_linP,57,"NET WEIGHT/PESO LIQUIDO(Kg):","I","0",fonte2_2)
	MSCBSAY(32+_linP,57,transform(_pesol,'@E ##.###'),"I","0",fonte3_5)   //peso liquido da caixa

	MSCBSAY(47+_linP,54,"INTERNAL TARE/TARA EMB.PRIM.(Kg):","I","0",fonte2_2) //tara primaria
	MSCBSAY(35+_linP,54,transform(_vTARAP,'@E ##.###'),"I","0",fonte2_2)

	MSCBSAY(70+_linP,51,"TARE/TARA EMB SEC.(Kg):","I","0",fonte2_2) //tara secundaria
	MSCBSAY(35+_linP,51,transform(_vTARAS,'@E ##.###'),"I","0",fonte2_2)

	MSCBSAY(63+_linP,48,"TOTAL TARE/TARA TOTAL(Kg):","I","0",fonte2_2)   //tara total da caixa
	MSCBSAY(35+_linP,48,transform(_tara,'@E #.###'),"I","0",fonte2_2)

	MSCBLineH(01,47,300,4,"B")

	//******************* 4º Bloco da Etiqueta ************************

	_cLote   := GetAdvFVal('ZAS','ZAS_LOTE',FwxFilial('ZAS') + _control,1)	
	_cPrepor := GetAdvFVal('ZAS','ZAS_PREPOR',FwxFilial('ZAS') + _control,1)	
	MSCBSAYBAR(38+_linP,32,'010' + _nCodBar + '310200' + substr(_cPesol,1,2) + substr(_cPesol,3,2),"I","C",13,.F.,.T.,,,3,1,.T.)  //EAN exigido pelo walmart
	MSCBSAY(38+_linP,30,'PREV. PORCIONADO: ' + alltrim(_cPrepor) ,"I","0",fonte2_2) 
	//MSCBSAY(38+_linP,34,'LOTE PORCIONADO: ' + alltrim(_cLote) ,"I","0",fonte2_2)  
	MSCBSAY(30,110, _Hora,"R","0",fonte_mlr6)

	//******************* 5º Bloco da Etiqueta ************************
	MSCBLineH(01,26,300,4,"B")
	MSCBSAY(40+_linP,24,_vMENETQ,"I","B",fonte4_1)
	iif(!empty(_DESCTIPO),MSCBSAY(70+_linP,22,_DESCTIPO,"I","B",fonte4_1),)    //mensagem da temperatura
	iif(!empty(_GLUTEM),MSCBSAY(100+_linP,20,_GLUTEM,"I","B",fonte4_1),)   //Mensagem do Glutem
	iif(!empty(_SEXO),MSCBSAY(07,21,_SEXO,"I","B",fonte4_1),)

	//******************* 6º Bloco da Etiqueta ************************
	MSCBLineH(01,19,300,4,"B")
	MSCBSAYBAR(53+_linP,7,_control,"I","C",10,.F.,.T.,,,2,1,.T.)  //numero do controle da caixa   código de barras

	MSCBSAY(79+_linP,13,_desing,"I","B",fonte3)
	MSCBSAY(77+_linP,07,_despor,"I","B",fonte3)


	MSCBSAY(07,1,alltrim(_cod),"I","0",fonte4_2)
	MSCBSAY(15,1,"PE:"+_cSeq,"I","0",fonte5)

	MSCBEND()
	MSCBCLOSEPRINTER()

return .t.


//Etiqueta para impressão da produção de porcionados na etiquetadora 02
user function GJF111h (_modelo,_porta,_control,_cod,_pesob,_pesol,_tara,_predes,_datap,_dataval,_lote,_nNumEtq,_IP,_hora)
	/*                      1       2        3      4     5      6      7       8     9     10    11    12  13  14
	Paremetros da função
	1  - modelo da impressora
	2  - porta
	3  - sequencial da caixa
	4  - codigo do produto
	5  - descricao do produto
	6  - data de producao
	7  - dias de validade
	8  - previsao de producao porcionados
	9  - ip da impressora
	*/

	//local dtAbate   := ''
	local _vTIP     := ''
	local _vDESCES  := ''
	local _vDINGLES := ''
	local _vDESCING := ''
	local _vDFRANCES:= ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vDESCFRA := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vTARAP   := 0.00
	local _vTARAS   := 0.00
	local _vMENETQ  := ''
	local _vFAM     := ''
	local _DESTINO  := ''
	local _DESCTIPO := ''
	local _GLUTEM   := ''
	local _SEXO     := ''
	local _vNUMAM   := ''
	local _vDTABATE := ''
	//local _vRASTRO  := ''
	local _vTIP     := ''
	local _desing   := ''
	//local _desfra   := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _despor   := ''
	local _descFAM  := ''
	local _dtPROD   := ''
	local _dtVALID  := ''
	local _nTS      := ''
	local _nTP      := ''
	local _cSeq     := ''
	//local _cPesol   := strtran(cValtoChar(_pesol),'.','')
	//local _cModo    := GETMV('SI_MIMPEMB')
	//local _cIpImp   := GETMV('SI_IPIMP')

	SB1->(dbsetorder(1))
	if SB1->(Msseek(Fwxfilial('SB1')+alltrim(_cod)))
		_vDINGLES := SB1->B1_DESCING //os dois campos abaixo estao invertidos de proposito para não
		_vDESCING := SB1->B1_DINGLES //precisar mexer no layout de impressao - B1_DINGLES é a do SIF
		_vDFRANCES:= SB1->B1_DESCFRA  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
		_vDESCFRA := SB1->B1_DFRANCE //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
		_vDESCES  := SB1->B1_DESCESP // e o B1_DESCING a descrição em ingles do produto
		_vDESCSIF := SB1->B1_DESCSIF
		_nTS      := SB1->B1_CTARASE
		_nTP      := SB1->B1_CTARAP  // Incluido por Fabian Maurer - 08/05/2012 - nao estava pegando certo a tara primaria
		_nCodBar  := SB1->B1_CODBAR
		_nCdBarcli := SB1->B1_EANCLI
		_cGrupo   := SB1->B1_GRUPO
		_cFarm    := GetAdvFVal('SBM','BM_FARM',Fwxfilial('SBM')+_cGrupo,1)

		ZAB->(DbSetOrder(1))
		if ZAB->(MsSeek(Fwxfilial('ZAB')+alltrim(_nTS)))
			_vTARAS   := ZAB->ZAB_TARA
		endif

		if ZAB->(MsSeek(Fwxfilial('ZAB')+alltrim(_nTP)))
			_vTARAP   := ZAB->ZAB_TARA
		endif

		_vMENETQ  := SB1->B1_MENETQ1
		_vFAM     := SB1->B1_FAM
		_DESTINO  := SB1->B1_DESTINO
		_DESCTIPO := SB1->B1_MENETQ2
		_GLUTEM   := SB1->B1_MENETQ3
		_SEXO	    := SB1->B1_MENETQ4
	endif

	if !empty(_predes) .and. substr(_predes,1,3) <> 'SIF'
		SZ2->(DbSetOrder(2))
		if  SZ2->(MsSeek(Fwxfilial('SZ2')+_predes))                          	// se houver o apontamento de OP...
			_vNUMAM   := SZ2->Z2_NUMAM //GetAdvFVal('SZ2',2,Fwxfilial('SZ2')+_predes,'Z2_NUMAM')  				//numero aviso de matança
			_vDTABATE := dtoc(SZ2->Z2_DATAABT) //dtoc(GetAdvFVal('SZ2',2,Fwxfilial('SZ2')+_predes,'Z2_DATAABT'))//aviso de matança formatado em string
		endif
	endif

	_desing  := alltrim(_vDINGLES)
	_despor  :=  substr(alltrim(SB1->B1_DESCRED),1,17)
	_cSeq    := ZAS->ZAS_SEQPET

	DbSelectArea('SX5')
	_descFAM := GetAdvFVal('SX5','X5_DESCRI',Fwxfilial("SX5")+'PS'+_vFAM,1)
	_dtPROD  := dtoc(_datap)
	_dtVALID := dtoc(_dataval) //data da produção

	//*************************** Etiqueta Padrão  ************************************************

	_linP := -20

	MSCBPRINTER(_modelo,_porta,,,,,_IP)

	//	  	MSCBPRINTER(_modelo,_porta)
	//MSCBPRINTER(_modelo,_porta,,,,,'10.7.0.103')

	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(_nNumEtq,6,40)
	// Posição d codigo de barras
	fonte1  :="40,20"
	fonte1_1:="30,15"
	fonte1_2:="85,85" //100/50
	fonte1_3:="38,12"
	fonte2  :="35,30"
	fonte2_1:="100,100"
	fonte2_2:="25,35"
	fonte2_3:="20,23"
	fonte2_4:="35,30"
	fonte2_5:="25,20" // Trocando até acertar
	fonte3  :="35,12"//42
	fonte3_1:="40,45"
	f_extra :="30,22"
	fonte3_2:="84,90"
	fonte3_3:="24,15"
	fonte3_4:="45,30"
	fonte3_5 := "70,55"
	fonte4  :="20,5"
	fonte4_1:="16,8"
	fsexo   :="65,50"
	fonte4_2:="120,65"
	fonte5  :="25,25"
	fonte5_1 := "20,18"
	fonte_mlr4 := "20,18"

	//******************* 1º Bloco da Etiqueta ************************

	_cDescSIF :=  substr(_vDESCSIF,1,35)

	MSCBSAY(90,75,_control,"R","0",fonte2_2)         	//numero de controle

	MSCBSAY(87,05,'MATERIA-PRIMA PORCIONADOS',"R","0",fonte2_2)   				//descrição do ingles

	MSCBSAY(84,05,_cDescSIF,"R","0",fonte2_2) 					//descrição do SIF

	MSCBLineV(82,01,100,4,"B")                  //Linha Divisoria

	//******************* 2º Bloco da Etiqueta ************************

	// Ajuste de string solicitado Pelo Matheus PCP  e Tamilles Dia 06/07/2017  - Por Flávio
	MSCBSAY(77,05,"PACKING DATE/"+ iif(_cFarm = 'S',"DATA PRODUCAO","DATA EMBALAGEM:"),"R","0",fonte2_2)   //data de produção
	//MSCBSAY(77,05,"PACKING DATE/"+ iif(_cFarm = 'S',"PROD.DATE/LOT /DATA PROD./LOTE:","DATA EMBALAGEM:"),"R","0",fonte2_2)   //data de produção
	MSCBSAY(77,72,_dtPROD,"R","0",fonte2_2)

	MSCBSAY(74,05,"EXPIRY DATE/DATA VALIDADE:","R","0",fonte2_2)   //data de validade - Alterado por Fabian Maurer - 02/05/12 - Correção Escrita
	MSCBSAY(74,72,_dtVALID,"R","0",fonte2_2)

	/*Removido a pedido do Sr. Matheus Silva*/
	//MSCBSAY(71,05,"PIECE/PECA :","R","0",fonte2_2)    //quantidade de peças dentro da caixa
	//MSCBSAY(71,35,transform(_quant,'@E ######'),"R","0",fonte2_2)     //Quantidade de peças

	iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(68,05,"SLAUGHTER DATE/DATA ABATE: ","R","0",fonte2_2),)       //data de abate
	iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(68,72,_vDTABATE,"R","0",fonte2_2),)

	//******************* 3º Bloco da Etiqueta ************************

	MSCBLineV(67,01,100,4,"B")
	MSCBSAY(63,05,"GROSS WEIGHT/PESO BRUTO(Kg):","R","0",fonte2_2) //peso bruto da caixa
	MSCBSAY(63,75,transform(_pesob,'@E ##.###'),"R","0",fonte2_2)

	MSCBSAY(54,05,"NET WEIGHT/PESO LIQUIDO(Kg):","R","0",fonte2_2)
	MSCBSAY(53,73,transform(_pesol,'@E ##.###'),"R","0",fonte3_5)   //peso liquido da caixa

	MSCBSAY(50,05,"INTERNAL TARE/TARA EMB.PRIM.(Kg):","R","0",fonte2_2) //tara primaria
	MSCBSAY(50,75,transform(_vTARAP,'@E ##.###'),"R","0",fonte2_2)

	MSCBSAY(47,05,"TARE/TARA EMB SEC.(Kg):","R","0",fonte2_2) //tara secundaria
	MSCBSAY(47,75,transform(_vTARAS,'@E ##.###'),"R","0",fonte2_2)

	MSCBSAY(44,05,"TOTAL TARE/TARA TOTAL(Kg):","R","0",fonte2_2)   //tara total da caixa
	MSCBSAY(44,75,transform(_tara,'@E #.###'),"R","0",fonte2_2)

	MSCBLineV(42,01,100,4,"B")

	//******************* 4º Bloco da Etiqueta ************************

	MSCBSAYBAR(27,20,'010' + _nCodBar + '310200' + substr(_cPesol,1,2) + substr(_cPesol,3,2),"R","C",13,.F.,.T.,,,3,1,.T.)  //EAN exigido pelo walmart
	_cLote   := GetAdvFVal('ZAS','ZAS_LOTE',FwxFilial('ZAS') + _control,1)	
	_cPrepor := GetAdvFVal('ZAS','ZAS_PREPOR',FwxFilial('ZAS') + _control,1)               
	MSCBSAY(29,20,"PREV. PORCIONADO: "+_cPrepor,"R","0",fonte2_2)  
	//MSCBSAY(25,20,"LOTE PORCIONADO:  "+_cLote,"R","0",fonte2_2)  
	MSCBSAY(29,100, _Hora,"R","0",fonte_mlr4)

	MSCBLineV(23,01,100,4,"B")

	iif(!empty(_DESCTIPO),MSCBSAY(21,05,_DESCTIPO,"R","B",fonte4_1),)    //mensagem da temperatura
	MSCBSAY(19,05,_vMENETQ,"R","B",fonte4_1)
	iif(!empty(_GLUTEM),MSCBSAY(21,70,_GLUTEM,"R","B",fonte4_1),)   //Mensagem do Glutem
	iif(!empty(_SEXO),MSCBSAY(19,60,_SEXO,"R","B",fonte4_1),)

	//******************* 6º Bloco da Etiqueta ************************
	MSCBLineV(17,01,100,4,"B")

	MSCBSAYBAR(05,47,_control,"R","C",10,.F.,.T.,,,2,1,.T.)  //numero do controle da caixa   código de barras

	MSCBSAY(10,08,_desing,"R","B",fonte3)
	MSCBSAY(05,08,_despor,"R","B",fonte3)

	MSCBSAY(02,73,alltrim(_cod),"R","0",fonte4_2)
	MSCBSAY(01,73,"PE:"+_cSeq,"R","0",fonte5)

	MSCBEND()
	MSCBCLOSEPRINTER()

return  .t.


//Etiqueta para rotina de porcionados
User Function GJF111i(_modelo,_porta,_ip,_cControl)

	Local _cProd 	:= ''
	Local _cDscPrd	:= ''
	Local _dDtProd  := stod('')
	Local _dDtvalid := stod('')
	Local _nPesoL   := 0
	Local _nPesoB   := 0
	Local _nTara    := 0
	Local _cTerc    := ''
	Local _cPreemb  := ''
	Local _cTipo 	:= ''
	Local _cPrepor  := ''
	Local _dDtValidTer := stod('')
    Local _dDtProdTer :=''

	//*************************** Etiqueta Padrão  ************************************************

	_linP := -20

	MSCBPRINTER(_modelo,_porta,,,,,_ip)
	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(1,6,40)
	// Posição d codigo de barras
	fonte1  		:= "35,15"
	fonte1_1		:= "30,15"	
	fonte2  		:= "35,30"
	fonte2_1		:= "60,60"
	fonte2_2		:= "25,35"
	fonte2_3		:= "20,23"
	fonte2_4		:= "35,30"
	fonte2_5		:= "25,20" 
	fonte3  		:= "45,15"
	fonte3_1		:= "40,45"
	f_extra 		:= "30,22"
	fonte3_2		:= "84,90"
	fonte3_3		:= "24,15"
	fonte3_4		:= "45,30"
	fonte4  		:= "20,5"
	fonte4_1		:= "18,10"
	fsexo 		    := "50,40"
	fonte5  		:= "25,25"
	//Novas fontes Criadas por Fabian Maurer - 07/06/12
	fonte_fab1 	:= "27,15"
	fonte_fab2 	:= "27,17"
	fonte_fab3 	:= "50,25"
	fonte_fab4 	:= "35,20"
	fonte_fab5 	:= "38,15"
	fonte_fab6 	:= "10,6"
	//Novas fontes (Mauricio L. Roehrs)
	fonte_mlr1 	:= "25,10"
	fonte_mlr2 	:= "15,10"
	fonte_mlr3 	:= "45,20"
	fonte_mlr4 	:= "20,18"
	fonte_mlr5 	:= "60,18"

	ZAS->(dbSetOrder(1))
	ZAS->(dbGoTop())
	if ZAS->(MsSeek(FwxFilial('ZAS') + _cControl))

		_cProd 	 := ZAS->ZAS_COD
		_cDscPrd	 := ZAS->ZAS_DESC
		_dDtProd  := ZAS->ZAS_DTPROD

		_dDtValid := IIF(!Empty(ZAS->ZAS_DTABAT),ZAS->ZAS_DTABAT + ZAS->ZAS_VALID,ZAS->ZAS_DTPROD + ZAS->ZAS_VALID)
		_dDtValidTer := ZAS->ZAS_DTABAT + ZAS->ZAS_VALID
		_dDtProdTer  := ZAS->ZAS_DTABAT
		_nPesoL   := ZAS->ZAS_PESOL
		_nPesoB   := ZAS->ZAS_PESOB
		_nTara    := ZAS->ZAS_TARA
		_cTerc    := ZAS->ZAS_TERC
		_cPreemb  := ZAS->ZAS_PREEMB
		_cTipo 	 := ZAS->ZAS_TIPO
		_cPrepor  := ZAS->ZAS_PREPOR
		_cLote    := ZAS->ZAS_LOTE
		_cDestin  := ZAS->ZAS_DESTIN
		_cDescDest := GetAdvFVal('SX5','X5_DESCRI',FwxFilial('SX5')+'ZP'+_cDestin,1)
		_dtAbate  := ZAS->ZAS_DTABAT	

		//******************* 1º Bloco da Etiqueta ************************
		MSCBSAY(73,65,_cControl,"R","F",fonte_mlr1) 						//Numero de controle	era85

		MSCBSAY(69,05,_cDscPrd,"R","F",fonte_mlr2)                 //Descricao em Portugues
		MSCBBOX(68,01,68,180,4)                                     //Linha Divisoria

		//***************** 2º Bloco da Etiqueta ********************

		if _cTerc <> 'S'
			MSCBSAY(64,05,"DATA DA EMBALAGEM:","R","F",fonte_mlr2)
			MSCBSAY(64,70,dtoc(_dDtProd),"R","F",fonte_mlr2)

			MSCBSAY(61,05,"DATA DE VALIDADE:","R","F",fonte_mlr2)
			MSCBSAY(61,70,dtoc(_dDtValid),"R","F",fonte_mlr2)           

			MSCBSAY(58,05,"DATA DE PRODUCAO:","R","F",fonte_mlr2) 				
			MSCBSAY(58,70,dtoc(_dtAbate),"R","F",fonte_mlr2)

			MSCBBOX(57,01,57,180,4)
		else
			MSCBSAY(63,05,"DATA DE VALIDADE:","R","F",fonte_mlr2)
			MSCBSAY(63,70,dtoc(_dDtValidTer),"R","F",fonte_mlr2)

			MSCBSAY(58,05,"DATA DE PRODUCAO:","R","F",fonte_mlr2) 				
			MSCBSAY(58,70,dtoc(_dDtProdTer),"R","F",fonte_mlr2)
		endif 

		//***************** 3º Bloco da Etiqueta ********************

		MSCBSAY(52,05,"PESO BRUTO:","R","F",fonte_mlr2)
		MSCBSAY(52,70,transform(_nPesob,'@E #,###.###')+" kg","R","F",fonte_mlr2)

		MSCBSAY(46,05,"PESO LIQUIDO:","R","F",fonte_mlr2)
		MSCBSAY(46,70,transform(_nPesol,'@E #,###.###')+"kg","R","F",fonte_mlr3)

		MSCBSAY(43,05,"TARA:","R","F",fonte_mlr2)
		MSCBSAY(43,70,transform(_nTara,'@E ##.###')+" kg","R","F",fonte_mlr2)

		MSCBBOX(42,01,42,180,4)

		//***************** 4º Bloco da Etiqueta ********************

		//se o tipo do produto for MP ou PA		                 
		if !empty(_cTipo) .and. (_cTipo $ 'MP/PA' )
			if !empty(_cPrepor)
				MSCBSAY(38,05,"PREV. PORCIONADOS:","R","F",fonte_mlr2)
				MSCBSAY(38,70,_cPrepor,"R","F",fonte_mlr2)		
			endif                  

			if !empty(_cTerc)		                                          
				MSCBSAY(35,05,"TERCEIRO:","R","0",fonte_mlr4)
				MSCBSAY(35,70,iif(_cTerc = 'S', 'SIM','NAO'),"R","0",fonte_mlr4)
			endif

			if !empty(_cPreEmb)
				MSCBSAY(32,05,"PREV. EMB.:","R","0",fonte_mlr4)
				MSCBSAY(32,70,_cPreEmb,"R","0",fonte_mlr4)					
			endif	                      

			if !empty(_cTipo)
				MSCBSAY(29,05,"TIPO:","R","0",fonte_mlr4)
				MSCBSAY(29,70,iif(_cTipo = 'MP', 'MAT. PRIMA',iif(_cTipo = 'PA','PROD. ACABADO',iif(_cTipo = 'QR','QUEBRA REFIL.',iif(_cTipo = 'QF', 'QUEBRA FATIAD','PROD EM PROCES')))),"R","0",fonte_mlr4)					
			endif
		else //senão será QR, QF ou PP
			if !empty(_cLote)
				MSCBSAY(38,05,"LOTE DE PRODUCAO:","R","F",fonte_mlr2)
				MSCBSAY(38,70,_cLote,"R","F",fonte_mlr2)						
			endif		

			if !empty(_cTipo)
				MSCBSAY(29,05,"TIPO DE PRODUTO:","R","F",fonte_mlr5)
				MSCBSAY(29,70,iif(_cTipo = 'QR','QUEBRA REFILE',iif(_cTipo = 'QF', 'QUEBRA FATIADORA','CARNE REFILADA')),"R","F",fonte_mlr5)					
			endif
		endif			

		MSCBBOX(28,01,28,180,4)

		//***************** 5º Bloco da Etiqueta ********************

		if !empty(_cDestin)
			// Ajuste inclusão Destino "Moida" conforme pedido Lucineia dia 12/07/2016 - Flávio Fez
			MSCBSAY(17,05,"DESTINO: " + alltrim(_cDescDest),"R","F",fonte_mlr5)
		else
			MSCBSAY(17,05,_cDscPrd,"R","F",fonte_mlr5) 				
		endif

		MSCBSAYBAR(06,62,_cControl,"R","C",10,.F.,.T.,,,2,1,.T.)
		MSCBBOX(06,88,18,123,80,"B")                                          //Box preto onde fica o cod. do produto
		MSCBSAYMEMO(03,88,58,1,alltrim(_cProd),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto

	endif                                        

	MSCBEND()
	MSCBCLOSEPRINTER()

return


//FUNÇÃO DESTINADA PARA ETIQUETADORA DA DIMEL Linha 4 automática
//MODIFICAÇÃO DO LAYOUT DE IMPRESSÃO
User Function GJF111j(_modelo,_porta,_control,_cod,_pesob,_pesol,_tara,_datap,_dataval,_nNumEtq,_lote,_IP,_hora)
	/*                       1      2        3      4     5      6     7      8     9        10       11   12
	Paremetros da função
	1  - modelo da impressora
	2  - porta
	3  - sequencial da caixa
	4  - codigo do produto
	5  - peso bruto
	6  - peso liquido
	7  - tara
	8  - previsão de produção da desossa
	9 - data de produção
	10 - data de validade
	11 - numero de etiquetas a serem impressas
	12 - Lotes
	13 - Endereço IP para conexão ethernet
	*/

	//local dtAbate   := ''
	local _vTIP     := ''
	local _vDESCES  := ''
	local _vDINGLES := ''
	local _vDESCING := ''
	local _vDFRANCES:= ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vDESCFRA := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vTARAP   := 0.00
	local _vTARAS   := 0.00
	local _vMENETQ  := ''
	local _vFAM     := ''
	local _DESTINO  := ''
	local _DESCTIPO := ''
	local _GLUTEM   := ''
	//local _SEXO     := ''
	//local _vNUMAM   := ''
	local _vDTABATE := ''
	local _vRASTRO  := ''
	local _vTIP     := ''
	local _desing   := ''
	local _desfra   := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _despor   := ''
	local _descFAM  := ''
	local _dtPROD   := ''
	local _dtVALID  := ''
	local _nTS      := ''
	local _nTP      := ''
	local _classif  := ''

	//local _cSeq     := ''
	local _cPesol   := strtran(cValtoChar(_pesol),'.','')
	//local _cModo    := GETMV('SI_MIMPEMB')
	//local _cIpImp   := GETMV('SI_IPIMP')
	DbselectArea('SB1')
	SB1->(dbsetorder(1))
	if SB1->(Msseek(Fwxfilial('SB1')+alltrim(_cod)))
		_vDINGLES := SB1->B1_DESCING //os dois campos abaixo estao invertidos de proposito para não
		_vDESCING := SB1->B1_DINGLES //precisar mexer no layout de impressao - B1_DINGLES é a do SIF
		_vDFRANCES:= SB1->B1_DESCFRA  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
		_vDESCFRA := SB1->B1_DFRANCE //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
		_vDESCES  := SB1->B1_DESCESP // e o B1_DESCING a descrição em ingles do produto
		_vDESCSIF := SB1->B1_DESCSIF
		_nTS      := SB1->B1_CTARASE
		_nTP      := SB1->B1_CTARAP  // Incluido por Fabian Maurer - 08/05/2012 - nao estava pegando certo a tara primaria
		_nCodBar  := SB1->B1_CODBAR
		_nCdBarcli := SB1->B1_EANCLI
		_nPesFix  := SB1->B1_PESFIX
		_quant    := SB1->B1_QCAIX
		_cUm      := SB1->B1_UM
		_cDun14   := SB1->B1_DUN14
		_cGrupo   := SB1->B1_GRUPO
		_cFarm    := GetAdvFVal('SBM','BM_FARM',Fwxfilial('SBM')+_cGrupo,1)

		ZAB->(DbSetOrder(1))
		if ZAB->(MsSeek(Fwxfilial('ZAB')+alltrim(_nTS)))
			_vTARAS   := ZAB->ZAB_TARA
		endif

		if ZAB->(MsSeek(Fwxfilial('ZAB')+alltrim(_nTP)))
			_vTARAP   := ZAB->ZAB_TARA
		endif

		_vMENETQ  := SB1->B1_MENETQ1
		_vFAM     := SB1->B1_FAM
		_DESTINO  := SB1->B1_DESTINO
		_DESCTIPO := SB1->B1_MENETQ2
		_GLUTEM   := SB1->B1_MENETQ3
		_ROTULO   := SB1->B1_MENETQ4
	endif

	dbSelectArea('ZAU')
	ZAU->(DbSetOrder(1))
	if ZAU->(MsSeek(FwxFilial('ZAU') + alltrim(_lote)))
		_vDTABATE := dtoc(ZAU->ZAU_DTABAT)//aviso de matança formatado em string
	endif

	_desing  := alltrim(_vDINGLES)
	_desfra  := alltrim(_vDFRANCES)  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	_despor  :=  substr(alltrim(SB1->B1_DESC),1,18)

	DbSelectArea('SX5')
	_descFAM := GetAdvFVal('SX5','X5_DESCRI',Fwxfilial("SX5")+'PS'+_vFAM,1)
	_dtPROD  := dtoc(_datap)
	_dtVALID := dtoc(_dataval) //data da produção

	//*************************** Etiqueta Padrão  ************************************************

	_linP := -20

	MSCBPRINTER(_modelo,_porta,,,,,_IP)

	//MSCBPRINTER(_modelo,_porta)
	//MSCBPRINTER(_modelo,_porta,,,,,'10.7.0.103')

	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(_nNumEtq,6,40)
	// Posição d codigo de barras
	fonte1  :="40,20"
	fonte1_1:="30,15"
	fonte1_2:="85,85" //100/50
	fonte1_3:="38,12"
	fonte2  :="35,30"
	fonte2_1:="100,100"
	fonte2_2:="25,35"
	fonte2_3:="20,23"
	fonte2_4:="35,30"
	fonte2_5:="25,20" // Trocando até acertar
	fonte3  :="35,12"//42
	fonte3_1:="40,45"
	f_extra :="30,22"
	fonte3_2:="84,90"
	fonte3_3:="24,15"
	fonte3_4:="45,30"
	fonte3_5 := "70,55"
	fonte4  :="20,5"
	fonte4_1:="16,8"
	fsexo   :="65,50"
	fonte4_2:="120,65"
	fonte5  :="25,25"
	fonte5_1 := "20,18"
	fonte_fab7 := "70,40"
	_pos := 20

	//verificado se no cadastro do produto está preenchido o peso fixo do produto
	//se estiver recalcula os dados da etiqueta
	if _nPesFix <> 0		
		_pesol := _nPesFix		
		_pesob := _nPesFix + _tara			
	endif

	IF SB1->B1_DESTINO == 'MI'

		//******************* 1º Bloco da Etiqueta ************************

		_cDescSIF :=  substr(_vDESCSIF,1,35)

		MSCBSAY(10,10,_control,"B","0",fonte2_2)         	//numero de controle
		
		MSCBSAY(14,12,_cDescSIF,"B","0",fonte2_2)   				//descrição do ingles
		MSCBSAY(17,16,_vDESCING,"B","0",fonte2_2)  					//descrição do SIF

		MSCBLineV(20,01,100,4,"B")                  //Linha Divisoria

		//******************* 2º Bloco da Etiqueta ************************

		_cCostPrc := getMV('SI_COSTPRC')

		if (alltrim(_cod) $ _cCostPrc)		

			_diasval := GetAdvFVal('ZAS','ZAS_VALID',FwxFilial('ZAS') + _control,1)
			MSCBSAY(22,43,"DATA EMBALAGEM/PACKING DATE:","B","0",fonte2_2)   //data de produção
			MSCBSAY(22,16,_dtPROD,"B","0",fonte2_2)

			MSCBSAY(25,43,"DATA VALIDADE/EXPIRY DATE:","B","0",fonte2_2)   //data de validade - Alterado por Fabian Maurer - 02/05/12 - Correção Escrita
			MSCBSAY(25,16,dtoc(ZAU->ZAU_DTABAT + _diasval),"B","0",fonte2_2)
			
			MSCBSAY(28,30,"DATA PRODUCAO/PRODUCTION DATE:","B","0",fonte2_2)   //data de produção
			MSCBSAY(28,16,_vDTABATE,"B","0",fonte2_2)
		else
			MSCBSAY(22,30,"DATA PRODUCAO/PRODUCTION DATE:","B","0",fonte2_2)   //data de produção
			MSCBSAY(22,16,_dtPROD,"B","0",fonte2_2)
			
			MSCBSAY(25,38,"DATA VALIDADE/EXPIRY DATE:","B","0",fonte2_2)   //data de validade - Alterado por Fabian Maurer - 02/05/12 - Correção Escrita
			MSCBSAY(25,16,_dtVALID,"B","0",fonte2_2)
		endif		

		MSCBLineH(20,14,36,4,"B")                  //Linha Divisoria
		MSCBSAY(24,04,_DESTINO,"B","0",fonte3_5)     // Destino do produto (mover para outro lugar)
		MSCBSAY(29,48,alltrim(_vMENETQ),"B","0",fonte_fab7)

		//******************* 3º Bloco da Etiqueta ************************

		MSCBLineV(36,01,100,4,"B")

		_cPb    := transform(_pesob,'@E 99.999')
		_cPesob := strtran(_cPb,',','.')
		
		MSCBSAY(38,33,"PESO BRUTO(Kg)/GROSS WEIGHT:","B","0",fonte2_2) //peso bruto da caixa
		MSCBSAY(38,14,_cPesob,"B","0",fonte2_2)

		_cPl    := transform(_pesol,'@E ##.###')
		_cPesol := strtran(_cPl,',','.')
		
		MSCBSAY(47,33,"PESO LIQUIDO(Kg)/NET WEIGHT:","B","0",fonte2_2)
		MSCBSAY(43,10,_cPesol,"B","0",fonte3_5)   //peso liquido da caixa

		_cTp    := transform(_quant * _vTaraP,'@E ##.###')
		_cTaraP := strtran(_cTp,',','.')
		
		MSCBSAY(51,27,"TARA EMB.PRIM.(Kg)/INTERNAL TARE:","B","0",fonte2_2) //tara primaria
		MSCBSAY(51,16,_cTARAP,"B","0",fonte2_2)

		_cTs    := transform(_vTaras,'@E ##.###')
		_cTaras := strtran(_cTs,',','.')

		MSCBSAY(54,33,"TARA EMB SEC.(Kg)/TARE:","B","0",fonte2_2) //tara secundaria
		MSCBSAY(54,16,_cTARAS,"B","0",fonte2_2)

		_cTa := transform(_tara,'@E #.###')
		_cTara := strtran(_cTa,',','.')
		
		MSCBSAY(57,33,"TARA TOTAL(Kg)/TOTAL TARE:","B","0",fonte2_2)   //tara total da caixa
		MSCBSAY(57,16,_cTara,"B","0",fonte2_2)

		MSCBLineV(60,01,100,4,"B")

		//******************* 4º Bloco da Etiqueta ************************

		MSCBSAY(65,10,_Hora,"B","B",fonte4)

		cPEAN14  := getMV('SI_CDEAN14')
		cPEan142 := getMV('SI_CEAN142')
		cPEan143 := getMV('SI_CEAN143')
		cPEan144 := getMV('SI_CEAN144')
		cPEan145 := getMV('SI_CEAN145')

		if (alltrim(_cod) $ (Alltrim(cPEan14)+Alltrim(cPEan142)+Alltrim(cPEan143)+Alltrim(cPEan144)+Alltrim(cPEan145)))
			MSCBSAYBAR(61,20,_cDun14,"B","C",13,.F.,.T.,,,3,1,.T.)  // produtos com DUN14 provenientes de clientes
			MSCBSAY(65,20,_Hora,"B","B",fonte4)
		elseif _cUM = 'UN'
			if !empty(_nCdBarcli)//bloco para imprimir dun14 do cliente
				_cod13 := '1' + substr(_nCdBarcli,1,12)
			else
				_cod13 := '1' + substr(_nCodBar,1,12)
			endif
			_cDig    := EAN14(_cod13)
			_cod14   := _cod13 + _cDig
			MSCBSAYBAR(61,20,_cod14,"B","C",13,.F.,.T.,,,3,1,.T.)  //EAN 14 para Tubetes quantidade/peso padrão
			MSCBSAY(65,20,_Hora,"B","B",fonte4)
		endif

		//******************* 5º Bloco da Etiqueta ************************

		MSCBLineV(78,01,100,4,"B")

		iif(!empty(_DESCTIPO),MSCBSAY(80,52,_DESCTIPO,"B","B",fonte4_1),)    //mensagem da temperatura

		MSCBSAYBAR(80,27,_control,"B","C",10,.F.,.T.,,,2,1,.T.)  //numero do controle da caixa   código de barras
		MSCBSAY(80,03,alltrim(_cod),"B","0",fonte4_2)
		
		MSCBSAY(85,56,substr(_despor,1,18),"B","B",fonte3)

		iif(!empty(_GLUTEM),MSCBSAY(90,72,_GLUTEM,"B","B",fonte4_1),)   //Mensagem do Glutem B1_MENETQ3

		MSCBSAY(92,72,'lote: ' + alltrim(_lote),"B","B",fonte4_1)  //LOTE

		MSCBSAY(94,10,"REGISTRO NO MINISTERIO DA AGRICULTURA SIF/DIPOA SOB N "+alltrim(_ROTULO)+"/1733","B","B",fonte4_1)

	ELSE //SENÃO SERÁ MERCADO EXTERNO

		//******************* 1º Bloco da Etiqueta ************************

		_cDescSIF :=  substr(_vDESCSIF,1,35)

		MSCBSAY(10,10,_control,"B","0",fonte2_2)         	//numero de controle

		MSCBSAY(14,24,substr(_cDescSIF,1,35),"B","0",fonte2_2)   				//descrição do ingles

		MSCBSAY(17,23,_vDESCING,"B","0",fonte2_2)  					//descrição do SIF

		MSCBLineV(20,01,100,4,"B")                  //Linha Divisoria

		//******************* 2º Bloco da Etiqueta ************************

		MSCBSAY(22,43,"DATA PRODUCAO/PRODUCTION DATE:","B","0",fonte2_2)   //data de produção
		MSCBSAY(22,16,_dtPROD,"B","0",fonte2_2)

		MSCBSAY(25,43,"DATA VALIDADE/EXPIRY DATE:","B","0",fonte2_2)   //data de validade - Alterado por Fabian Maurer - 02/05/12 - Correção Escrita
		MSCBSAY(25,16,_dtVALID,"B","0",fonte2_2)

		MSCBLineH(20,14,36,4,"B")                  //Linha Divisoria
		MSCBSAY(24,04,substr(_DESTINO,1,2),"B","0",fonte3_5)     // Destino do produto (mover para outro lugar)
		MSCBSAY(29,48,alltrim(_vMENETQ),"B","0",fonte_fab7)

		//******************* 3º Bloco da Etiqueta ************************

		MSCBLineV(36,01,100,4,"B")

		_cPb    := transform(_pesob,'@E 99.999')
		_cPesob := strtran(_cPb,',','.')
		MSCBSAY(38,43,"PESO BRUTO(Kg)/GROSS WEIGHT:","B","0",fonte2_2) //peso bruto da caixa
		MSCBSAY(38,16,_cPesob,"B","0",fonte2_2)

		_cPl    := transform(_pesol,'@E ##.###')
		_cPesol := strtran(_cPl,',','.')
		MSCBSAY(47,43,"PESO LIQUIDO(Kg)/NET WEIGHT:","B","0",fonte2_2)
		MSCBSAY(43,16,_cPesol,"B","0",fonte3_5)   //peso liquido da caixa

		_cTp    := transform(_quant * _vTaraP,'@E ##.###')
		_cTaraP := strtran(_cTp,',','.')
		MSCBSAY(51,43,"TARA EMB.PRIM.(Kg)/INTERNAL TARE:","B","0",fonte2_2) //tara primaria
		MSCBSAY(51,16,_cTARAP,"B","0",fonte2_2)

		_cTs    := transform(_vTaras,'@E ##.###')
		_cTaras := strtran(_cTs,',','.')
		MSCBSAY(54,43,"TARA EMB SEC.(Kg)/TARE:","B","0",fonte2_2) //tara secundaria
		MSCBSAY(54,16,_cTARAS,"B","0",fonte2_2)

		_cTa := transform(_tara,'@E #.###')
		_cTara := strtran(_cTa,',','.')
		MSCBSAY(57,43,"TARA TOTAL(Kg)/TOTAL TARE:","B","0",fonte2_2)   //tara total da caixa
		MSCBSAY(57,16,_cTara,"B","0",fonte2_2)

		MSCBLineV(60,01,100,4,"B")

		//******************* 4º Bloco da Etiqueta ************************

		iif(!empty(_DESCTIPO),MSCBSAY(78,52,_DESCTIPO,"B","B",fonte4_1),)    //mensagem da temperatura

		MSCBSAYBAR(80,27,_control,"B","C",10,.F.,.T.,,,2,1,.T.)  //numero do controle da caixa   código de barras
		MSCBSAY(80,03,alltrim(_cod),"B","0",fonte4_2)
		MSCBSAY(30,110, _Hora,"R","0",fonte_mlr6)
		MSCBSAY(85,60,substr(_despor,1,18),"B","B",fonte3)		

		MSCBSAY(65,20,_Hora,"B","B",fonte4)

		iif(!empty(_GLUTEM),MSCBSAY(90,78,_GLUTEM,"B","B",fonte4_1),)   //Mensagem do Glutem B1_MENETQ3

		iif(AllTrim(_classif) = 'RT',MSCBSAY(42,107,_classif,"R","0",fonte2_1),)
		iif(AllTrim(_classif) == 'RT',iif(!empty(_predes),MSCBSAY(29,05,"RASTREABILIDADE :" + _vRASTRO,"R","0",fonte4_2),),)

	ENDIF
	MSCBEND()
	MSCBCLOSEPRINTER()

return  .t.


//Etiqueta para produção normal(manual) em estações que utilizam impressoras de rede(manual) NOS PORCIONADOS

user function GJF111k(_modelo,_porta,_control,_cod,_pesob,_pesol,_tara,_predes,_datap,_dataval,_nNumEtq,_IP,_Hora)					 
	/*                      1      2        3      4     5      6     7      8     9        10     11    12   13
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
	*/

	//local dtAbate   := ''
	local _vTIP     := ''
	local _vDESCES  := ''
	local _vDINGLES := ''
	local _vDESCING := ''
	local _vDFRANCES:= ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vDESCFRA := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vTARAP   := 0.00
	local _vTARAS   := 0.00
	local _vMENETQ  := ''
	local _vFAM     := ''
	local _DESTINO  := ''
	local _DESCTIPO := ''
	local _GLUTEM   := ''
	local _SEXO     := ''
	local _vNUMAM   := ''
	local _vDTABATE := ''
	//local _vRASTRO  := ''
	local _vTIP     := ''
	local _desing   := ''
	local _desfra   := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _despor   := ''
	local _descFAM  := ''
	local _dtPROD   := ''
	local _dtVALID  := ''
	local _nTS      := ''
	local _nTP      := ''
	local _cSeq     := ''  //Campo feito por Fabian Maurer para capturar o codigo da Pre-Etiqueta - 27/02/12
	//local _cPesol   := strtran(cValtoChar(_pesol),'.','')

	Dbselectarea('SB1')
	SB1->(dbsetorder(1))
	SB1->(Msseek(Fwxfilial('SB1')+alltrim(_cod)))
	_vDINGLES := SB1->B1_DESCING //os dois campos abaixo estao invertidos de proposito para não
	_vDESCING := SB1->B1_DINGLES //precisar mexer no layout de impressao - B1_DINGLES é a do SIF
	_vDFRANCES:= SB1->B1_DESCFRA //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	_vDESCFRA := SB1->B1_DFRANCE //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	_vDESCES  := SB1->B1_DESCESP // e o B1_DESCING a descrição em ingles do produto
	_vDESCSIF := SB1->B1_DESCSIF //
	_nTS      := SB1->B1_CTARASE
	_cGrupo   := SB1->B1_GRUPO
	_cFarm    := GetAdvFVal('SBM','BM_FARM',Fwxfilial('SBM')+_cGrupo,1)
	_vTARAS   := GetAdvFVal('ZAB','ZAB_TARA',Fwxfilial('ZAB')+alltrim(_nTS),1)  //Tara Secundária
	_nTP      := SB1->B1_CTARAP
	_vTARAP   := GetAdvFVal('ZAB','ZAB_TARA',Fwxfilial('ZAB')+alltrim(_nTP),1)   //Tara Primária
	_vMENETQ  := SB1->B1_MENETQ1 //Mensagem etiqueta 1
	_vFAM     := SB1->B1_FAM     //Família Silva
	_DESTINO  := SB1->B1_DESTINO //Destino
	_DESCTIPO := SB1->B1_MENETQ2
	_GLUTEM   := SB1->B1_MENETQ3
	_SEXO	    := SB1->B1_MENETQ4
	_nCodBar  := SB1->B1_CODBAR
	_nCdBarcli := SB1->B1_EANCLI

	if !empty(_predes) .and. substr(_predes,1,3) <> 'SIF'
		SZ2->(DbSetOrder(2))
		if  SZ2->(MsSeek(Fwxfilial('SZ2')+_predes))                          	// se houver o apontamento de OP...
			_vNUMAM   := SZ2->Z2_NUMAM //GetAdvFVal('SZ2',2,Fwxfilial('SZ2')+_predes,'Z2_NUMAM')  				//numero aviso de matança
			_vDTABATE := dtoc(SZ2->Z2_DATAABT) //dtoc(GetAdvFVal('SZ2',2,Fwxfilial('SZ2')+_predes,'Z2_DATAABT'))//aviso de matança formatado em string
		endif
	endif

	_desing  := alltrim(_vDINGLES)
	_desfra  := alltrim(_vDFRANCES) //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	_despor  :=  alltrim(SB1->B1_DESCRED)         //Descrição reduzida em portugues
	_cSeq    := ZAS->ZAS_SEQPET //Campo feito por Fabian Maurer para capturar o codigo da Pre-Etiqueta - 27/02/12

	DbSelectArea('SX5')
	_descFAM := GetAdvFVal('SX5','X5_DESCRI',Fwxfilial("SX5")+'PS'+_vFAM,1)   //Descrição da família
	_dtPROD  := dtoc(_datap)   //data da produção
	_dtVALID := dtoc(_dataval) //data de validade

	/*************************** Etiqueta Padrão  ************************************************ */

	MSCBPRINTER(_modelo,_porta,,,,,_IP)
	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(_nNumEtq,6,40)
	// Posição d codigo de barras
	fonte1  :="35,15"
	fonte1_1:="30,15"
	fonte2  :="35,30"
	fonte2_1:="60,60"
	fonte2_2:="25,35"
	fonte2_3:="20,23"
	fonte2_4:="35,30"
	fonte2_5:="25,20" // Trocando até acertar
	fonte3  :="45,15"
	fonte3_1:="40,45"
	f_extra :="30,22"
	fonte3_2:="84,90"
	fonte3_3:="24,15"
	fonte3_4:="45,30"
	fonte4  :="20,5"
	fonte4_1:="18,10"
	fsexo := "50,40"
	fonte5  :="25,25"
	//Novas fontes Criadas por Fabian Maurer - 07/06/12
	fonte_fab1 := "27,15"
	fonte_fab2 := "27,17"
	fonte_fab3 := "50,25"
	fonte_fab4 := "35,20"
	fonte_fab5 := "38,15"
	fonte_fab6 := "10,6"
	//Novas fontes para teste (Mauricio L. Roehrs)
	fonte_mlr1 := "25,10"
	fonte_mlr2 := "15,10"
	fonte_mlr3 := "45,20"
	fonte_mlr4 := "20,18"
	fonte_mlr5 := "60,18"

	//***************** 1º Bloco da Etiqueta ********************

	MSCBSAY(75,85,_control,"R","F",fonte_mlr1)         					// Numero de controle

	MSCBSAY(75,05,'MATERIA-PRIMA PORCIONADOS',"R","F",fonte_mlr2)   						//Descrição em ingles

	MSCBSAY(72,05,_vDESCSIF,"R","F",fonte_mlr2) 						//Descrição em Portugues

	MSCBBOX(71,01,71,125,4) 											// Linha Divisoria

	//************** 2º Bloco da Etiqueta ***********************
	/*Dia 19/04/23 - incluido data de abate porque voltamos com data de abate em todos os produtos (avisado ariane / adriana / valezka)*/
	iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(61,05,"SLAUGHTER DATE /DATA ABATE","R","F",fonte_mlr2),)
	iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(61,70,_vDTABATE,"R","F",fonte_mlr2),)
	//conout('linha 4952 - > Cod-'+_cod +'_predes'+_predes)	

	MSCBSAY(67,05, iif(_cFarm = 'S',"DATA PRODUCAO:","DATA EMBALAGEM:"),"R","F",fonte_mlr2) //Descrição data de produção
	MSCBSAY(67,70,_dtPROD,"R","F",fonte_mlr2)             				// Data de Produção

	MSCBSAY(64,05,"DATA VALIDADE/EXPIRY DATE:","R","F",fonte_mlr2)   // Descrição data de validade - Alterado por Fabian Maurer - 02/05/12 - Correção de Escrita
	MSCBSAY(64,70,_dtVALID,"R","F",fonte_mlr2)     						//Data de Validade	

	MSCBBOX(61,01,61,125,4) 											// Linha Divisoria
	//************** 3º Bloco da Etiqueta ************************

	MSCBSAY(57,05,"PESO BRUTO/GROSS WEIGHT:","R","F",fonte_mlr2) 		// Descrição peso bruto da caixa
	MSCBSAY(57,70,transform(_pesob,'@E ##.###')+" Kg","R","F",fonte_mlr2) // Peso Bruto

	MSCBSAY(51,05,"PESO LIQUIDO/NET WEIGHT:","R","F",fonte_mlr2)      // Descrição peso liquido
	MSCBSAY(51,70, transform(_pesol,'@E ##.###')+" Kg","R","F",fonte_mlr3)   	// Peso liquido

	MSCBSAY(48,05,"TARA EMB.PRIM./INTERNAL TARE:","R","F",fonte_mlr2) 	// Descrição tara primaria
	MSCBSAY(48,70,transform(_vTARAP,'@E ##.###')+" Kg","R","F",fonte_mlr2) // Tara primaria

	MSCBSAY(45,05,"TARA EMB SEC./TARE:","R","F",fonte_mlr2) 			// Descrição tara secundaria
	MSCBSAY(45,70,transform(_vTARAS,'@E ##.###')+" Kg","R","F",fonte_mlr2) // Tara secundaria

	MSCBSAY(42,05,"TARA TOTAL/TOTAL TARE:","R","F",fonte_mlr2)   	// Descrição tara total da caixa
	MSCBSAY(42,70,transform(_tara,'@E #.###')+" Kg","R","F",fonte_mlr2) // Tara total

	MSCBBOX(41,01,41,125,4) 											// Linha Divisoria

	// Linha Divisoria

	//******************* 4º Bloco da Etiqueta ************************

	_cLote   := GetAdvFVal('ZAS','ZAS_LOTE',FwxFilial('ZAS') + _control,1)			               
	_cPrepor := GetAdvFVal('ZAS','ZAS_PREPOR',FwxFilial('ZAS') + _control,1)	
    
	MSCBSAY(30,100,_Hora,"R","0",fonte_mlr4)
	
	MSCBSAYBAR(32,31,'010' + _nCodBar + '310200' + substr(cValtoChar(_pesol),1,2) + substr(cValtoChar(_pesol),3,2),"R","C",8,.F.,.T.,,,3,1,.T.)  //EAN exigido pelo walmart

	//******************* 5º Bloco da Etiqueta ************************

	MSCBBOX(28,01,28,125,4)												// Linha Divisoria

	MSCBSAY(25,04,_vMENETQ,"R","0",fonte_mlr4)                          // Mensagem da Agricultura

	iif(!empty(_GLUTEM),MSCBSAY(22,04,_GLUTEM,"R","0",fonte_mlr4),)     // Mensagem do Glutem

	iif(!empty(_DESCTIPO),MSCBSAY(22,26,_DESCTIPO,"R","0",fonte_mlr4),) // Mensagem do Tipo

	//******************* 6º Bloco da Etiqueta ************************

	MSCBBOX(21,01,21,125,4)  											// Linha Divisoria

	MSCBSAY(14,04,_despor+_desing,"R","F",fonte_mlr2) 					// Descrição Ingles/Portugues 05

	MSCBSAYBAR(04,62,_control,"R","C",10,.F.,.T.,,,2,1,.T.)  			// Numero do controle da caixa código de barras
	
	MSCBBOX(4,88,17,123,80,"B") 

	MSCBSAYMEMO(2,88,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto

	MSCBSAY(01,100,"PE:"+_cSeq,"R","0","25,20")						// Numero da Pre-Etiqueta

	MSCBEND()
	MSCBCLOSEPRINTER()
	/*Variável de controle de quantidade de impressão*/

return .t.	  


//IMPRESSÃO DE ERRO PARA LINHAS ISHIDA
User Function GJF111L(_modelo,_porta,_IP,_linha,_lote,_falha)
	/*                       1      2     3 
	Paremetros da função
	1  - modelo da impressora
	2  - porta
	3  - IP da impressora
	*/	

	MSCBPRINTER(_modelo,_porta,,,,,_IP)

	//MSCBPRINTER(_modelo,_porta)
	//MSCBPRINTER(_modelo,_porta,,,,,'10.7.0.103')

	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(1,6,40)
	// Posição d codigo de barras
	fonte1   :="100,100"
	fonte2   :="70,70" 

	MSCBSAY(14,20,'CAIXA REJEITADA',"B","0",fonte2)
	MSCBSAY(34,69,'FALHA: ',"B","0",fonte2)
	MSCBSAY(44,10,substr(_falha,1,20),"B","0",fonte2)
	MSCBSAY(54,56,'LINHA: ' + _linha,"B","0",fonte2)
	MSCBSAY(64,31,'LOTE: '  + _lote,"B","0",fonte2)
	MSCBSAY(74,41,'DATA: '  + dtoc(date()),"B","0",fonte2)	             
	MSCBSAY(84,40,'HORA: '  + cValtoChar(time()),"B","0",fonte2)	             	
	//		MSCBSAY(14,53,_vDESCING,"B","0",fonte2_2)   				//descrição do ingles
	//		MSCBSAY(17,23,_cDescSIF,"B","0",fonte2_2)  					//descrição do SIF			

	MSCBEND()
	MSCBCLOSEPRINTER()

return  .t.


//FUNÇÃO DESTINADA PARA ETIQUETADORAS DA ISHIDA PARA PRODUTO ACABADO
//MODIFICAÇÃO DO LAYOUT DE IMPRESSÃO
User Function GJF111m(_modelo,_porta,_control,_cod,_pesob,_pesol,_tara,_datap,_dataval,_nNumEtq,_lote,_IP)
	/*                       1      2        3      4     5      6     7      8     9        10       11   12
	Paremetros da função
	1  - modelo da impressora
	2  - porta
	3  - sequencial da caixa
	4  - codigo do produto
	5  - peso bruto
	6  - peso liquido
	7  - tara
	8  - previsão de produção da desossa
	9 - data de produção
	10 - data de validade
	11 - numero de etiquetas a serem impressas
	12 - Lotes
	13 - Endereço IP para conexão ethernet
	*/

	//local dtAbate   := ''
	local _vTIP     := ''
	local _vDESCES  := ''
	local _vDINGLES := ''
	local _vDESCING := ''
	//local _vDANCES:= ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vDESCFRA := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vTARAP   := 0.00
	local _vTARAS   := 0.00
	local _vMENETQ  := ''
	local _vFAM     := ''
	local _DESTINO  := ''
	local _DESCTIPO := ''
	local _GLUTEM   := ''
	//local _SEXO     := ''
	//local _vNUMAM   := ''
	local _vDTABATE := ''
	//local _vRASTRO  := ''
	local _vTIP     := ''
	local _desing   := ''
	local _desfra   := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _despor   := ''
	local _descFAM  := ''
	local _dtPROD   := ''
	local _dtVALID  := ''
	local _nTS      := ''
	local _nTP      := ''
	//local _cSeq     := ''
	local _cPesol   := strtran(cValtoChar(_pesol),'.','')

	DbselectArea('SB1')
	SB1->(dbsetorder(1))
	if SB1->(Msseek(Fwxfilial('SB1')+alltrim(_cod)))
		_vDINGLES := SB1->B1_DESCING //os dois campos abaixo estao invertidos de proposito para não
		_vDESCING := SB1->B1_DINGLES //precisar mexer no layout de impressao - B1_DINGLES é a do SIF
		_vDFRANCES:= SB1->B1_DESCFRA  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
		_vDESCFRA := SB1->B1_DFRANCE //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
		_vDESCES  := SB1->B1_DESCESP // e o B1_DESCING a descrição em ingles do produto
		_vDESCSIF := SB1->B1_DESCSIF
		_nTS      := SB1->B1_CTARASE
		_nTP      := SB1->B1_CTARAP  // Incluido por Fabian Maurer - 08/05/2012 - nao estava pegando certo a tara primaria
		_nCodBar  := SB1->B1_CODBAR
		_nCdBarcli := SB1->B1_EANCLI
		_nPesFix  := SB1->B1_PESFIX
		_quant    := SB1->B1_QCAIX
		_cUm      := SB1->B1_UM
		_cDun14   := SB1->B1_DUN14
		_cGrupo   := SB1->B1_GRUPO
		_cFarm    := GetAdvFVal('SBM','BM_FARM',Fwxfilial('SBM')+_cGrupo,1)

		ZAB->(DbSetOrder(1))
		if ZAB->(MsSeek(Fwxfilial('ZAB')+alltrim(_nTS)))
			_vTARAS   := ZAB->ZAB_TARA
		endif

		if ZAB->(MsSeek(Fwxfilial('ZAB')+alltrim(_nTP)))
			_vTARAP   := ZAB->ZAB_TARA
		endif

		_vMENETQ  := SB1->B1_MENETQ1
		_vFAM     := SB1->B1_FAM
		_DESTINO  := SB1->B1_DESTINO
		_DESCTIPO := SB1->B1_MENETQ2
		_GLUTEM   := SB1->B1_MENETQ3
		_ROTULO   := SB1->B1_MENETQ4
	endif

	dbSelectArea('ZAU')
	ZAU->(DbSetOrder(1))
	if ZAU->(MsSeek(FwxFilial('ZAU') + alltrim(_lote)))	
		_vDTABATE := dtoc(ZAU->ZAU_DTABAT)//aviso de matança formatado em string
	endif		

	_desing  := alltrim(_vDINGLES)
	_desfra  := alltrim(_vDFRANCES)  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	_despor  :=  substr(alltrim(SB1->B1_DESC),1,18)

	DbSelectArea('SX5')
	_descFAM := GetAdvFVal('SX5','X5_DESCRI',Fwxfilial("SX5")+'PS'+_vFAM,1)
	_dtPROD  := dtoc(_datap)
	_dtVALID := dtoc(_dataval) //data da produção

	//*************************** Etiqueta Padrão  ************************************************

	_linP := -20
	//_IP := '10.7.21.132'	
	MSCBPRINTER(_modelo,_porta,,,,,_IP)

	//MSCBPRINTER(_modelo,_porta)
	//MSCBPRINTER(_modelo,_porta,,,,,'10.7.0.103')

	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(_nNumEtq,6,40)
	// Posição d codigo de barras
	fonte1  :="40,20"
	fonte1_1:="30,15"
	fonte1_2:="85,85" //100/50
	fonte1_3:="38,12"
	fonte2  :="35,30"
	fonte2_1:="100,100"
	fonte2_2:="40,50"//25,35
	fonte2_3:="20,23"
	fonte2_4:="35,30"
	fonte2_5:="25,20" // Trocando até acertar
	fonte3  :="70,55"//35,12
	fonte3_1:="40,45"
	f_extra :="30,22"
	fonte3_2:="84,90"
	fonte3_3:="24,15"
	fonte3_4:="45,30"
	fonte3_5 := "85,70"
	fonte4  :="20,5"
	fonte4_1:="20,30"//16,8
	fsexo   :="65,50"
	fonte4_2:="135,80"//120,80
	fonte5  :="25,25"
	fonte5_1 := "20,18"
	fonteT:="30,40"
	vPos := 7         

	//verificado se no cadastro do produto está preenchido o peso fixo do produto
	//se estiver recalcula os dados da etiqueta
	if _nPesFix <> 0		
		_pesol := _nPesFix		
		_pesob := _nPesFix + _tara			
	endif
	IF SB1->B1_DESTINO = 'MI'

	//******************* 1º Bloco da Etiqueta ************************

		_cDescSIF :=  substr(_vDESCSIF,1,35)		

		MSCBSAY(111 - vPos,100,_control,"R","0",fonteT)		
		MSCBSAY(106 - vPos,05,_cDescSIF,"R","0",fonteT)  					//descrição do SIF

		MSCBLineV(105 - vPos,01,150,6,"B")                  //Linha Divisoria

		//******************* 2º Bloco da Etiqueta ************************

		MSCBSAY(100 - vPos,05,"DATA PRODUCAO/PRODUCTION DATE:","R","0",fonteT)		
		MSCBSAY(100 - vPos,103,_dtPROD,"R","0",fonteT)

		MSCBSAY(95 - vPos,05,"DATA VALIDADE/EXPIRY DATE:","R","0",fonteT)   
		MSCBSAY(95 - vPos,103,_dtVALID,"R","0",fonteT)		

		MSCBLineH(93 - vPos,126,106 - vPos,8,"B")
		MSCBSAY(94 - vPos,133,_DESTINO,"R","0",fonte3_5)     // Destino do produto (mover para outro lugar)		

		//******************* 3º Bloco da Etiqueta ************************

		MSCBLineV(93 - vPos,01,150,6,"B")

		_cPb    := transform(_pesob,'@E 99.999')
		_cPesob := strtran(_cPb,',','.')

		MSCBSAY(89 - vPos,05,"PESO BRUTO(Kg)/GROSS WEIGHT:","R","0",fonteT) //peso bruto da caixa
		MSCBSAY(89 - vPos,107,_cPesob,"R","0",fonteT)	

		_cPl    := transform(_pesol,'@E ##.###')
		_cPesol := strtran(_cPl,',','.')

		MSCBSAY(80 - vPos,05,"PESO LIQUIDO(Kg)/NET WEIGHT:","R","0",fonteT)
		MSCBSAY(78 - vPos,107,_cPesol,"R","0",fonte3_5)   //peso liquido da caixa

		_cTp    := transform(_quant * _vTaraP,'@E ##.###')
		_cTaraP := strtran(_cTp,',','.')

		MSCBSAY(74 - vPos,05,"TARA EMB.PRIM.(Kg)/INTERNAL TARE:","R","0",fonteT) //tara primaria
		MSCBSAY(74 - vPos,107,_cTARAP,"R","0",fonteT)		

		_cTs    := transform(_vTaras,'@E ##.###')
		_cTaras := strtran(_cTs,',','.')

		MSCBSAY(70 - vPos,05,"TARA EMB SEC.(Kg)/TARE:","R","0",fonteT) //tara secundaria
		MSCBSAY(70 - vPos,107,_cTARAS,"R","0",fonteT)

		_cTa := transform(_tara,'@E #.###')
		_cTara := strtran(_cTa,',','.')

		MSCBSAY(66 - vPos,05,"TARA TOTAL(Kg)/TOTAL TARE:","R","0",fonteT)   //tara total da caixa
		MSCBSAY(66 - vPos,107,_cTara,"R","0",fonteT)
		MSCBLineV(66 - vPos,01,150,6,"B")

		//******************* 4º Bloco da Etiqueta ************************		                             		

		cPEAN14 := getMV('SI_CDEAN14')
		cPEan142 := getMV('SI_CEAN142')
		cPEan143 := getMV('SI_CEAN143')
		cPEan144 := getMV('SI_CEAN144')
		cPEan145 := getMV('SI_CEAN145')

		if (alltrim(_cod) $ (Alltrim(cPEan14)+Alltrim(cPEan142)+Alltrim(cPEan143)+Alltrim(cPEan144)+Alltrim(cPEan145)))
			MSCBSAYBAR(52 - vPos,25,_cDun14,"R","C",13,.F.,.T.,,,5,1,.T.)  // produtos com DUN14 provenientes de clientes
			MSCBSAY(30,110, _Hora,"R","0",fonte_mlr6)
		elseif _cUM = 'UN'
			if !empty(_nCdBarcli)//bloco para imprimir dun14 do cliente
				_cod13 := '1' + substr(_nCdBarcli,1,12)
			else
				_cod13 := '1' + substr(_nCodBar,1,12)
			endif
			_cDig    := EAN14(_cod13)
			_cod14   := _cod13 + _cDig
			MSCBSAYBAR(52 - vPos,25,_cod14,"R","C",13,.F.,.T.,,,5,1,.T.)  //EAN 14 para Tubetes quantidade/peso padrão
			MSCBSAY(30,110, _Hora,"R","0",fonte_mlr6)
		endif

		//******************* 5º Bloco da Etiqueta ************************

		MSCBLineV(45 - vPos,01,150,6,"B")

		iif(!empty(_DESCTIPO),MSCBSAY(40 - vPos,05,_DESCTIPO,"R","0",fonte4_1),)    //mensagem da temperatura		

		MSCBSAY(26 - vPos,117,alltrim(_cod),"R","0",fonte4_2)
		MSCBSAYBAR(32 - vPos,82,_control,"R","C",12,.F.,.T.,,,3,1,.T.)  //numero do controle da caixa   código de barras

		MSCBSAY(30 - vPos,05,substr(_despor,1,18),"R","0",fonte3)						

		iif(!empty(_GLUTEM),MSCBSAY(28 - vPos,05,_GLUTEM,"R","0",fonte4_1),)   //Mensagem do Glutem B1_MENETQ3

		MSCBSAY(25 - vPos,05,'LOTE: ' + alltrim(_lote),"R","0",fonte4_1)   		
		MSCBSAY(22 - vPos,05,"REGISTRO NO MINISTERIO DA AGRICULTURA SIF/DIPOA SOB N "+alltrim(_ROTULO),"R","0",fonte4_1)

	ELSE //SENÃO É MERCADO EXTERNO

		//******************* 1º Bloco da Etiqueta ************************

		_cDescSIF :=  substr(_vDESCSIF,1,35)

		MSCBSAY(10,10,_control,"B","0",fonte2_2)         	//numero de controle

		MSCBSAY(14,24,substr(_cDescSIF,1,35),"B","0",fonte2_2)   				//descrição do ingles

		MSCBSAY(17,23,_vDESCING,"B","0",fonte2_2)  					//descrição do SIF

		MSCBLineV(20,01,100,4,"B")                  //Linha Divisoria

		//******************* 2º Bloco da Etiqueta ************************
		
		MSCBSAY(22,35,"DATA PRODUCAO/PRODUCTION DATE:","B","0",fonte2_2)   //data de produção
		MSCBSAY(22,16,_dtPROD,"B","0",fonte2_2)

		MSCBSAY(25,43,"DATA VALIDADE/EXPIRY DATE:","B","0",fonte2_2)   //data de validade - Alterado por Fabian Maurer - 02/05/12 - Correção Escrita
		MSCBSAY(25,16,_dtVALID,"B","0",fonte2_2)
		
		MSCBLineH(20,14,36,4,"B")                  //Linha Divisoria
		MSCBSAY(24,04,substr(_DESTINO,1,2),"B","0",fonte3_5)     // Destino do produto (mover para outro lugar)

		//******************* 3º Bloco da Etiqueta ************************

		MSCBLineV(36,01,100,4,"B")

		_cPb    := transform(_pesob,'@E 99.999')
		_cPesob := strtran(_cPb,',','.')
		MSCBSAY(38,38,"GROSS WEIGHT/PESO BRUTO(Kg):","B","0",fonte2_2) //peso bruto da caixa
		MSCBSAY(38,14,_cPesob,"B","0",fonte2_2)

		_cPl    := transform(_pesol,'@E ##.###')
		_cPesol := strtran(_cPl,',','.')
		MSCBSAY(47,40,"NET WEIGHT/PESO LIQUIDO(Kg):","B","0",fonte2_2)
		MSCBSAY(43,10,_cPesol,"B","0",fonte3_5)   //peso liquido da caixa

		_cTp    := transform(_quant * _vTaraP,'@E ##.###')
		_cTaraP := strtran(_cTp,',','.')
		MSCBSAY(51,29,"INTERNAL TARE/TARA EMB.PRIM.(Kg):","B","0",fonte2_2) //tara primaria
		MSCBSAY(51,16,_cTARAP,"B","0",fonte2_2)

		_cTs    := transform(_vTaras,'@E ##.###')
		_cTaras := strtran(_cTs,',','.')
		MSCBSAY(54,51,"TARE/TARA EMB SEC.(Kg):","B","0",fonte2_2) //tara secundaria
		MSCBSAY(54,16,_cTARAS,"B","0",fonte2_2)

		_cTa := transform(_tara,'@E #.###')
		_cTara := strtran(_cTa,',','.')
		MSCBSAY(57,44,"TOTAL TARE/TARA TOTAL(Kg):","B","0",fonte2_2)   //tara total da caixa
		MSCBSAY(57,16,_cTara,"B","0",fonte2_2)

		//iif(_TF == 'S',MSCBSAY(43,93,"TF","B","0",fonte3_5),) // EM CONSTRUçÂO

		MSCBLineV(60,01,100,4,"B")

		//******************* 4º Bloco da Etiqueta ************************

		iif(!empty(_DESCTIPO),MSCBSAY(78,52,_DESCTIPO,"B","0",fonte4_1),)    //mensagem da temperatura

		//iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(80,93,"LOTE:","B","B",fonte4_1),)    //Lote	
		//iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(80,88,_Lote,"B","B",fonte4_1),)  //descricao do lote preenchido no lançamento da OP da embalagem
		//iif(!empty(_SEXO),MSCBSAY(80,79,_SEXO,"B","B",fonte4_1),)//está sendo usando para mensagem adicional do lote

		//MSCBSAY(82,68,"USO EXCLUSIVO INSTITUCIONAL","B","B",fonte4_1)

		MSCBSAYBAR(80,27,_control,"B","C",10,.F.,.T.,,,2,1,.T.)  //numero do controle da caixa   código de barras
		MSCBSAY(80,03,alltrim(_cod),"B","0",fonte4_2)

		MSCBSAY(85,60,substr(_despor,1,18),"B","B",fonte3)						

		iif(!empty(_GLUTEM),MSCBSAY(90,78,_GLUTEM,"B","0",fonte4_1),)   //Mensagem do Glutem B1_MENETQ3

		MSCBSAY(30,110, _Hora,"R","0",fonte_mlr6)
		//MSCBSAY(96,16,"REGISTRO NO MINISTERIO DA AGRICULTURA SIF/DIPOA SOB N 0123/1733","B","B",fonte4_1)		

	ENDIF
	MSCBEND()
	MSCBCLOSEPRINTER()

return  .t.


static function EAN14(cCod13)
	Local nOdd := 0
	Local nEven := 0 
	Local nI
	Local nDig  
	Local nMul := 10 
	For nI := 1 to 13
		If (nI%2) == 0
			nEven += val(substr(cCod13,nI,1))
		Else
			nOdd += val(substr(cCod13,nI,1))
		Endif
	Next
	nDig := nEven + (nOdd*3)
	While nMul<nDig
		nMul += 10 
	Enddo
Return strzero(nMul-nDig,1)

//Etiqueta para pallets do Grupo Pão de Açucar
User Function GJF111n(_modelo,_porta,_ip,_cControl,_pesoPallet,_taraStrech)

	Local i
	Local j
	//*************************** Etiqueta Padrão  ************************************************

	_linP := -20

	MSCBPRINTER(_modelo,_porta,,,,,_ip)
	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(1,6,40)
	// Posição d codigo de barras
	fonte1  		:= "35,15"
	fonte1_1		:= "30,15"	
	fonte2  		:= "35,30"
	fonte2_1		:= "60,60"
	fonte2_2		:= "25,35"
	fonte2_3		:= "20,23"
	fonte2_4		:= "35,30"
	fonte2_5		:= "25,20" 
	fonte3  		:= "45,15"
	fonte3_1		:= "40,45"
	f_extra 		:= "30,22"
	fonte3_2		:= "84,90"
	fonte3_3		:= "24,15"
	fonte3_4		:= "45,30"
	fonte4  		:= "20,5"
	fonte4_1		:= "18,10"
	fsexo 	    	:= "50,40"
	fonte5  		:= "25,25"
	//Novas fontes Criadas por Fabian Maurer - 07/06/12
	fonte_fab1 	:= "27,15"
	fonte_fab2 	:= "27,17"
	fonte_fab3 	:= "50,25"
	fonte_fab4 	:= "35,20"
	fonte_fab5 	:= "38,15"
	fonte_fab6 	:= "10,6"
	//Novas fontes (Mauricio L. Roehrs)
	fonte_mlr1 	:= "25,10"
	fonte_mlr2 	:= "15,10"
	fonte_mlr3 	:= "45,20"
	fonte_mlr4 	:= "20,18"
	fonte_mlr5 	:= "60,18"
	fonte_max1  :=	"60,60"
	fonte_max2  :=	"16,18"
	fonte_max3  :=	"25,18"

	SZP->(dbSetOrder(1))
	SZP->(dbGoTop())
	if SZP->(MsSeek(FwxFilial('SZP') + _cControl))

		_cProd 	 := SZP->ZP_PRODUTO

		//_aTags := {"02","3102","3302","37","15","11","7030","10","00"}    
		_aTags := {"01","3102","3302","37","15","11","7030","10","00"}                 

		_cDigExt := getmv('SI_PADIGEX')
		_cGln    := getmv('SI_GLN')
		_cSeqPa  := getmv('SI_PASEQ')		
		_cNumero := alltrim(_cDigExt + _cGln + _cSeqPa)				    
		_nSoma   := 0   
		_nMult   := 3 

		for i:=1 to len(_cNumero)
			if _nMult == 3        			
				_nSoma += val(substr(_cNumero,i,1)) * _nMult
				_nMult := 1				
			else 
				_nSoma += val(substr(_cNumero,i,1)) * _nMult
				_nMult := 3
			endif	        		
		next              

		For j := 0 to 9
			If (_nSoma + j) % 10 == 0 
				fncMult := _nSoma + j
				exit
			EndIf
		Next

		_nDigVerif := (fncMult - _nSoma)
		//Se o resultado obtido for igual a “dez” (exemplo: 160-150=10) o dígito verificador será “zero”
		if _nDigVerif == 10
			_nDigVerif := 0		
		endif

		//codigo de serie da unidade logistica, utilizado na rastreabilidade do palete              		           
		_cSSCC   := _cDigExt + _cGln + _cSeqPa + alltrim(str(_nDigVerif))

		//Identificador do Produto
		_cod13    	:= GetAdvFVal('SB1','B1_CODBAR',FwxFilial('SB1') + alltrim(_cProd),1)
		_cDescSif 	:= GetAdvFVal('SB1','B1_DESCSIF',FwxFilial('SB1') + alltrim(_cProd),1)
		_cDescri  	:= GetAdvFVal('SB1','B1_DESCRED',FwxFilial('SB1') + alltrim(_cProd),1)
		_cCdBarcli	:= GetAdvFVal('SB1','B1_EANCLI',FwxFilial('SB1') + alltrim(_cProd),1)
		_cUM  		:= GetAdvFVal('SB1','B1_UM',FwxFilial('SB1') + alltrim(_cProd),1)
		_cDun14 	:= GetAdvFVal('SB1','B1_DUN14',FwxFilial('SB1') + alltrim(_cProd),1)

		cPEAN14 := getMV('SI_CDEAN14')
		cPEan142 := getMV('SI_CEAN142')
		cPEan143 := getMV('SI_CEAN143')
		cPEan144 := getMV('SI_CEAN144')
		cPEan145 := getMV('SI_CEAN145')

		if (alltrim(_cProd) $ (Alltrim(cPEan14)+Alltrim(cPEan142)+Alltrim(cPEan143)+Alltrim(cPEan144)+Alltrim(cPEan145)))
			_cCodBar := _cDun14
		elseif _cUM = 'UN'
			if !empty(_cCdBarcli)//bloco para imprimir dun14 do cliente
				_cod13 := '1' + substr(_cCdBarcli,1,12)
			else
				_cod13 := '1' + substr(_cod13,1,12)
			endif
			_cDig := EAN14(_cod13)
			_cCodBar := _cod13 + _cDig
		else
			_cCodBar := _cod13
		endif

		//aglutina pesos e soma quantidades
		SZ8->(dbSetOrder(19))
		SZ8->(dbGoTop())
		if SZ8->(MsSeek(FwxFilial('SZ8') + cFilAnt + SZP->ZP_COD))   
			_nPesLiq  := 0.00
			_nPesBrt  := 0.00
			_nQtdCx   := 0 
			_nTaraEmb := 0.00 			
			_dDtValid := SZ8->Z8_DATAVAL				
			_dDtProd  := SZ8->Z8_DATAP    
			cProd := SZ8->Z8_COD
			While SZ8->(!eof()) .and. SZ8->(Z8_FILIAL+Z8_FIL+Z8_PALLET) = (Fwxfilial('SZ8') + cFilAnt + alltrim(SZP->ZP_COD)) 			                
				_nPesLiq += SZ8->Z8_PESO 			   
				_nPesBrt += SZ8->Z8_PESOBR
				_nTaraEmb+= SZ8->Z8_TARA
				_nQtdCx++
				SZ8->(dbSkip())			
			enddo		
		endif 	

		//Peso Liquido		  
		_cPesLiq := alltrim(strtran(str(_nPesLiq),'.',''))

		//Peso Bruto
		_nPesBrt += _pesoPallet + _taraStrech                                       
		_cPesBrt := alltrim(strtran(str(_nPesBrt),'.',''))

		//Total de Caixas no Pallet
		_cTotCx := strzero(_nQtdCx,3)

		//Tara Total
		_nTotTara := _nTaraEmb + _pesoPallet + _taraStrech

		//Data de validade      
		_sDtValid := dtos(_dDtValid)		      
		_cDtValid := alltrim(substr(_sDtValid,3,6))

		//Data de produção
		_sDtProd := dtos(_dDtProd)
		_cDtProd := alltrim(substr(_sDtProd,3,6))   
		//alert('Linha 5557  _sDtProd ->'+_sDtProd)

		//Nº de registro de processador - Nº do Registro do Fornecedor no Sif com Iso do Pais(076+1733)
		_cIf := getMv('MV_NUMIF')
		_cIa7030 := '076' + alltrim(_cIf)

		//Lote das caixas do palete		
		_cLote := alltrim(cProd) + alltrim(dtos(_dDtProd))

		//Quando esgotar o campo serial (9999999) muda o dígito de extensão pra 1 e recomeça o campo serial do 0000001. 
		_nCntSeq := val(_cSeqPa) + 1 		
		if _nCntSeq > 9999999
			_cDigExt := str(val(_cDigExt) + 1)
			putmv('SI_PADIGEX',alltrim(_cDigExt))		
			putmv('SI_PASEQ','0000001')		
		else
			putmv('SI_PASEQ',strzero(_nCntSeq,7))					
		endif

		//******************* 1º Bloco da Etiqueta ************************
		//alert('Linha 5578  _dDtProd ->')
		//alert(_dDtProd)
		MSCBSAY(76,78,'SSCC',"R","0",fonte_max3)
		MSCBSAY(76,85,_cSSCC,"R","0",fonte_max3)
		MSCBSAY(72,78,'Nr. Palete:',"R","0",fonte_max2)
		MSCBSAY(72,91,_cSeqPa,"R","0",fonte_max2) //numero do palete
		MSCBSAY(70,78,_cDescSif,"R","0",fonte_max2) //tipo de carne
		MSCBSAY(68,78,'CONTENT/CONTEUDO:.',"R","0",fonte_max2)
		MSCBSAY(64,78,_cDescri,"R","0",fonte_max3)   //corte de carne
		MSCBSAY(60,78,'BATCH/LOTE.',"R","0",fonte_max2)
		MSCBSAY(60,93,_cLote,"R","0",fonte_max2)
		MSCBSAY(57,78,'COUNT/QUANTIDADE.',"R","0",fonte_max2)
		MSCBSAY(57,113,transform(_nQtdCx,'@E 999'),"R","0",fonte_max2)
		MSCBSAY(55,78,'PROD. DATE/DATA DE PRODUÇÃO:',"R","0",fonte_max2)
		MSCBSAY(55,113,dtoc(_dDtProd),"R","0",fonte_max2)
		MSCBSAY(53,78,'SELL BY/DATA DE VALIDADE:',"R","0",fonte_max2)
		MSCBSAY(53,113,dtoc(_dDtValid),"R","0",fonte_max2)
		MSCBSAY(51,78,'PACKING TARE/TARA EMBALAGEM:',"R","0",fonte_max2)
		MSCBSAY(51,113,transform(_nTaraEmb,"@E 99.999") + 'kg',"R","0",fonte_max2)	   
		MSCBSAY(49,78,'PALLET TARE/TARA DO PALLET:',"R","0",fonte_max2)
		MSCBSAY(49,113,transform(_pesoPallet,'@E 99.99') + 'kg',"R","0",fonte_max2)
		MSCBSAY(47,78,'RACK TARE/TARA DO RACK:',"R","0",fonte_max2)
		MSCBSAY(47,113,'0,000 KG',"R","0",fonte_max2)
		MSCBSAY(45,78,'STRECH TARE/TARA DO STRECH:',"R","0",fonte_max2)
		MSCBSAY(45,113,transform(_taraStrech,'@E 99.99') + 'kg',"R","0",fonte_max2)
		MSCBSAY(43,78,'CORNER TARE/TARA DA CANTONEIRA:',"R","0",fonte_max2)
		MSCBSAY(43,113,'0,000 kg',"R","0",fonte_max2)
		MSCBSAY(41,78,'TOTAL TARE/TARA TOTAL:',"R","0",fonte_max2)
		MSCBSAY(41,113,transform(_nTotTara,'@E 999,999.99') + 'kg',"R","0",fonte_max2)
		MSCBSAY(36,78,'GROSS WEIGHT/PESO BRUTO:',"R","0",fonte_max3)
		MSCBSAY(36,109,transform(_nPesBrt,'@E 999,999.99') + 'kg',"R","0",fonte_max3)
		MSCBSAY(33,78,'IET WEIGHT/PESO LIQUIDO:.',"R","0",fonte_max3)
		MSCBSAY(33,109,transform(_nPesLiq,'@E 999,999.99') + 'kg',"R","0",fonte_max3)		
		MSCBSAY(30,78,'PROCESSOR/PROCESSADOR:',"R","0",fonte_mlr4)
		MSCBSAY(30,109,_cIa7030,"R","0",fonte_mlr4)		
		_codBar1 := (_aTags[1] + alltrim(_cCodBar)) + (_aTags[2] + strzero(val(_cPesLiq),6)) + (_aTags[3] + strzero(val(_cPesBrt),6)) + (_aTags[4] + _cTotCx)
		_codBar2 := (_aTags[5] + _cDtValid) + (_aTags[6] + _cDtProd) + (_aTags[7] + _cIa7030) + (_aTags[8] + _cLote)
		_CodBar3 := _aTags[9]  + _cSSCC

	endif                                        

	MSCBEND()
	MSCBCLOSEPRINTER()
return


//Etiqueta para produção normal(manual) em estações que utilizam impressoras de rede(manual) NOS PORCIONADOS linhas 001, 002 , 003 e 004
//user function GJF111O(_modelo,_porta,_control,_cod,_pesob,_pesol,_tara,_datap,_dataval,_nNumEtq,_lote,_Hora,_IP)
user function GJF111O(_modelo,_porta,_control,_cod,_pesob,_pesol,_tara,_datap,_dataval,_nNumEtq,_lote,_IP,_Hora,_cReimp)
	/*                    1      2       3      4     5      6     7      8     9        10       11   12   13    14
	Paremetros da função
	1  - modelo da impressora
	2  - porta
	3  - sequencial da caixa
	4  - codigo do produto
	5  - peso bruto
	6  - peso liquido
	7  - tara
	8  - data de produção
	9  - data de validade
	10 - numero de etiquetas a serem impressas
	11 - Lotes
	12 - Endereço IP para conexão ethernet
	13 - Hora
	14 - Reimpressão
	*/

	//local dtAbate   := ''
	local _vTIP     := ''
	local _vDESCES  := ''
	local _vDINGLES := ''
	local _vDESCING := ''
	local _vDFRANCES:= ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vDESCFRA := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vTARAP   := 0.00
	local _vTARAS   := 0.00
	local _vMENETQ  := ''
	local _vFAM     := ''
	local _DESTINO  := ''
	local _DESCTIPO := ''
	local _GLUTEM   := ''
	local _SEXO     := ''
	//local _vNUMAM   := ''
	local _vDTABATE := ''
	//local _vRASTRO  := ''
	local _cNotImp     := ''
	local _desing   := ''
	local _desfra   := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _despor   := ''
	local _descFAM  := ''
	local _dtPROD   := ''
	local _dtVALID  := ''
	local _nTS      := ''
	local _nTP      := ''
	//local _cSeq     := ''
	local _cPesol   := strtran(cValtoChar(_pesol),'.','')
	//local _cModo    := GETMV('SI_MIMPEMB')
	//local _cIpImp   := GETMV('SI_IPIMP')
	DbselectArea('SB1')
	SB1->(dbsetorder(1))
	if SB1->(Msseek(Fwxfilial('SB1')+alltrim(_cod)))
		_vDINGLES := SB1->B1_DESCING //os dois campos abaixo estao invertidos de proposito para não
		_vDESCING := SB1->B1_DINGLES //precisar mexer no layout de impressao - B1_DINGLES é a do SIF
		_vDFRANCES:= SB1->B1_DESCFRA  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
		_vDESCFRA := SB1->B1_DFRANCE //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
		_vDESCES  := SB1->B1_DESCESP // e o B1_DESCING a descrição em ingles do produto
		_vDESCSIF := SB1->B1_DESCSIF
		_nTS      := SB1->B1_CTARASE
		_nTP      := SB1->B1_CTARAP  // Incluido por Fabian Maurer - 08/05/2012 - nao estava pegando certo a tara primaria
		_nCodBar  := SB1->B1_CODBAR
		_nCdBarcli := SB1->B1_EANCLI                                               
		_nPesFix  := SB1->B1_PESFIX
		_quant    := SB1->B1_QCAIX
		_cUm      := SB1->B1_UM
		_cDun14   := SB1->B1_DUN14
		_cGrupo   := SB1->B1_GRUPO
		_cFarm    := GetAdvFVal('SBM','BM_FARM',Fwxfilial('SBM')+_cGrupo,1)

		ZAB->(DbSetOrder(1))
		if ZAB->(MsSeek(Fwxfilial('ZAB')+alltrim(_nTS)))
			_vTARAS   := ZAB->ZAB_TARA
		endif

		if ZAB->(MsSeek(Fwxfilial('ZAB')+alltrim(_nTP)))
			_vTARAP   := ZAB->ZAB_TARA
		endif

		_vMENETQ  := SB1->B1_MENETQ1
		_vFAM     := SB1->B1_FAM
		_DESTINO  := SB1->B1_DESTINO
		_DESCTIPO := SB1->B1_MENETQ2
		_GLUTEM   := SB1->B1_MENETQ3
		_ROTULO   := SB1->B1_MENETQ4
	endif

	dbSelectArea('ZAU')
	ZAU->(DbSetOrder(1))
	if ZAU->(MsSeek(FwxFilial('ZAU') + alltrim(_lote)))
		_vDTABATE := dtoc(ZAU->ZAU_DTABAT)//aviso de matança formatado em string
	endif

	_desing  := alltrim(_vDINGLES)
	_desfra  := alltrim(_vDFRANCES)  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	_despor  :=  substr(alltrim(SB1->B1_DESC),1,30)

	DbSelectArea('SX5')
	_descFAM := GetAdvFVal('SX5','X5_DESCRI',Fwxfilial("SX5")+'PS'+_vFAM,1)
	_dtPROD  := dtoc(_datap)
	_dtVALID := dtoc(_dataval) //data da produção

	/*************************** Etiqueta Padrão  ************************************************ */

	MSCBPRINTER(_modelo,_porta,,,,,_IP)

	//MSCBPRINTER(_modelo,_porta)
	//MSCBPRINTER(_modelo,_porta,,,,,'10.0.0.129')
	//modelo, 'IP' ,,,,,endereço ip do server de impressao(IP DA ZEBRA)
	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(_nNumEtq,6,40)
	// Posição d codigo de barras
	fonte1  :="35,15"
	fonte1_1:="30,15"
	fonte2  :="35,30"
	fonte2_1:="60,60"
	fonte2_2:="25,35"
	fonte2_3:="20,23"
	fonte2_4:="35,30"
	fonte2_5:="25,20" // Trocando até acertar
	fonte3  :="45,15"
	fonte3_1:="40,45"
	f_extra :="30,22"
	fonte3_2:="84,90"
	fonte3_3:="24,15"
	fonte3_4:="45,30"
	fonte4  :="20,5"
	fonte4_1:="18,10"
	fsexo := "50,40"
	fonte5  :="25,25"
	//Novas fontes Criadas por Fabian Maurer - 07/06/12
	fonte_fab1 := "27,15"
	fonte_fab2 := "27,17"
	fonte_fab3 := "50,25"
	fonte_fab4 := "35,20"
	fonte_fab5 := "38,15"
	fonte_fab6 := "10,6"
	fonte_fab7 := "80,40"
	//Novas fontes para teste (Mauricio L. Roehrs)
	fonte_mlr1 := "25,10"
	fonte_mlr2 := "15,10"
	fonte_mlr3 := "45,20"
	fonte_mlr4 := "20,18"
	fonte_mlr5 := "60,18"

	//verificado se no cadastro do produto está preenchido o peso fixo do produto
	//se estiver recalcula os dados da etiqueta
	if _nPesFix <> 0		
		_pesol := _nPesFix		
		_pesob := _nPesFix + _tara			
	endif

	if !empty(_cReimp)
		MSCBSAY(32,110, _cReimp,"R","F",fonte_mlr3)
	endif

	IF SB1->B1_DESTINO == 'ME'

		//***************** 1º Bloco da Etiqueta ********************

		MSCBSAY(69,90,_control,"R","F",fonte_mlr1) 					//Numero de controle
		MSCBSAY(73,05,_vDESCSIF,"R","F",fonte_mlr2)                 //Descricao em Ingles
		MSCBSAY(69,05,_vDESCING,"R","F",fonte_mlr2)                 //Descricao em Portugues
		MSCBBOX(68,01,68,180,4)                                     //Linha Divisoria

		//***************** 2º Bloco da Etiqueta ********************
		
		MSCBSAY(64,05,"DATA PRODUCAO/LOTE/PRODUCTION DATE/LOT:","R","F",fonte_mlr2)
		MSCBSAY(64,85,_dtPROD,"R","F",fonte_mlr2)

		MSCBSAY(61,05,"DATA DE VALIDADE/EXPIRY DATE:","R","F",fonte_mlr2)
		MSCBSAY(61,85,_dtVALID,"R","F",fonte_mlr2)		

		MSCBBOX(57,105,68,105,4)
		MSCBSAY(62,110,_DESTINO,"R","F",fonte_mlr3)

		MSCBBOX(57,01,57,180,4)

		//***************** 3º Bloco da Etiqueta ********************
		if  _cNotImp <> "P"
			_cPb := transform(_pesob,'@E 99.999')
			_cPesob := strtran(_cPb,',','.')
			MSCBSAY(53,05,"PESO BRUTO/GROSS WEIGHT:","R","F",fonte_mlr2)
			MSCBSAY(53,70,_cPesob + " Kg","R","F",fonte_mlr2)			
			
			_cPl    := transform(_pesol,'@E ##.###')
			_cPesol := strtran(_cPl,',','.')
			//conout('linha 5826 - Peso Liquido : ' + _cPesol)
			MSCBSAY(46,05,"PESO LIQUIDO/NET WEIGHT:","R","F",fonte_mlr2)
			MSCBSAY(46,70,_cPesol + "Kg","R","F",fonte_mlr3)

			_cTp    := transform(_quant * _vTaraP,'@E ##.###')
			_cTaraP := strtran(_cTp,',','.')
			MSCBSAY(43,05,"TARA EMB.PRIM./INTERNAL TARE:","R","F",fonte_mlr2)
			MSCBSAY(43,70,_cTARAP + " Kg","R","F",fonte_mlr2)

			_cTs := transform(_vTaras,'@E ##.###')
			_cTaras := strtran(_cTs,',','.')
			MSCBSAY(40,05,"TARA EMB. SEC./TARE:","R","F",fonte_mlr2)
			MSCBSAY(40,70,_cTARAS + " Kg","R","F",fonte_mlr2)

			_cTa := transform(_tara,'@E #.###')
			_cTara := strtran(_cTa,',','.')
			MSCBSAY(37,05,"TARA TOTAL/TOTAL TARE:","R","F",fonte_mlr2)
			MSCBSAY(37,70,_cTara + " Kg","R","F",fonte_mlr2)

			MSCBBOX(36,01,36,180,4)
		else

			MSCBSAY(53,05,"PESO BRUTO/GROSS WEIGHT:","R","F",fonte_mlr2)
			MSCBSAY(53,70,transform(_pesob,'@E ##.###')+" Kg","R","F",fonte_mlr2)
			
			MSCBSAY(46,05,"PESO LIQUIDO/NET WEIGHT:","R","F",fonte_mlr2)
			MSCBSAY(46,70,transform(_pesol,'@E ##.###')+"Kg","R","F",fonte_mlr3)
			
			MSCBSAY(43,05,"TARA EMB.PRIM./INTERNAL TARE:","R","F",fonte_mlr2)
			MSCBSAY(43,70,transform(_quant * _vTARAP,'@E ##.###')+" Kg","R","F",fonte_mlr2)

			MSCBSAY(40,05,"TARA EMB. SEC./TARE:","R","F",fonte_mlr2)
			MSCBSAY(40,70,transform(_vTARAS,'@E ##.###')+" Kg","R","F",fonte_mlr2)

			MSCBSAY(37,05,"TARA TOTAL/TOTAL TARE:","R","F",fonte_mlr2)
			MSCBSAY(37,70,transform(_tara,'@E ##.###')+" Kg","R","F",fonte_mlr2)

			MSCBBOX(36,01,36,180,4)
		endif

		//***************** 4º Bloco da Etiqueta ********************

		MSCBSAY(33,05,_vMENETQ,"R","0",fonte_mlr4)

		MSCBSAY(30,05,ALLTRIM(_GLUTEM)  + " | INDÚSTRIA BRASILEIRA","R","0",fonte_mlr4)

		iif(!empty(_DESCTIPO),MSCBSAY(27,05,_DESCTIPO,"R","0",fonte_mlr4),) // Mensagem do Tipo		

		MSCBSAY(27,70,_SEXO,"R","0",fonte_mlr4) //descrição do sexo. preenche campo MENTETQ4 no cadastro de produtos

		MSCBSAY(30,100, _Hora,"R","0",fonte_mlr4)

		MSCBBOX(26,01,26,180,4)

		//***************** 5º Bloco da Etiqueta ********************

		MSCBSAY(17,05,_despor+_desing,"R","F",fonte_mlr5)

		MSCBSAYBAR(06,62,_control,"R","C",10,.F.,.T.,,,2,1,.T.)		
		MSCBBOX(06,88,18,123,80,"B")                                          //Box preto onde fica o cod. do produto		
		MSCBSAYMEMO(03,88,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto		
	ELSE

		//***************** 1º Bloco da Etiqueta ********************

		MSCBSAY(72,85,_control,"R","F",fonte_mlr1) 	// Numero de controle

		MSCBSAY(75,05,_vDESCSIF,"R","F",fonte_mlr2)   						//Descrição em ingles

		MSCBSAY(72,05,_vDESCING,"R","F",fonte_mlr2) 	//Descrição em Portugues

		MSCBBOX(71,01,71,125,4) 											// Linha Divisoria

		//************** 2º Bloco da Etiqueta ***********************

		_cCostPrc := getMV('SI_COSTPRC')

		if (alltrim(_cod) $ _cCostPrc)
			MSCBSAY(67,05,"DATA EMBALAGEM/PACKING DATE:","R","F",fonte_mlr2) //Descrição data de produção
			MSCBSAY(67,70,_dtPROD,"R","F",fonte_mlr2)             				// Data de Produção

			_diasval := GetAdvFVal('ZAS','ZAS_VALID',FwxFilial('ZAS') + _control,1)
			MSCBSAY(64,05,"DATA VALIDADE/EXPIRY DATE:","R","F",fonte_mlr2)   
			MSCBSAY(64,85,dtoc(ZAU->ZAU_DTABAT + _diasval),"R","F",fonte_mlr2)     			
		else
			MSCBSAY(67,05,"DATA PRODUCAO/LOTE/PRODUCTION DATE/LOT:","R","F",fonte_mlr2) //Descrição data de produção
			MSCBSAY(67,85,_dtPROD,"R","F",fonte_mlr2)             				// Data de Produção

			MSCBSAY(64,05,"DATA VALIDADE/EXPIRY DATE:","R","F",fonte_mlr2)   // Descrição data de validade - Alterado por Fabian Maurer - 02/05/12 - Correção de Escrita
			MSCBSAY(64,85,_dtVALID,"R","F",fonte_mlr2)  	//Data de Validade
		endif

		MSCBBOX(61,105,71,105,4)                                            // Linha Separa Tipo de Mercado

		MSCBSAY(62,110,_DESTINO,"R","F",fonte_mlr3) 	// Descrição Tipo de Mercado (ME/MI)

		MSCBBOX(61,01,61,125,4) 	// Linha Divisoria

		//************** 3º Bloco da Etiqueta ************************

		_cPb    := transform(_pesob,'@E 99.999')
		_cPesob := strtran(_cPb,',','.')
		MSCBSAY(57,05,"PESO BRUTO/GROSS WEIGHT:","R","F",fonte_mlr2) 		// Descrição peso bruto da caixa
		MSCBSAY(57,70,_cPesob + " Kg","R","F",fonte_mlr2) // Peso Bruto

		_cPl    := transform(_pesol,'@E ##.###')
		_cPesol := strtran(_cPl,',','.')
		MSCBSAY(51,05,"PESO LIQUIDO/NET WEIGHT:","R","F",fonte_mlr2)      // Descrição peso liquido
		MSCBSAY(51,70, _cPesol + " Kg","R","F",fonte_mlr3)   	// Peso liquido
		// Descrição KG

		_cTp    := transform(_quant * _vTaraP,'@E ##.###')
		_cTaraP := strtran(_cTp,',','.')
		MSCBSAY(48,05,"TARA EMB.PRIM./INTERNAL TARE:","R","F",fonte_mlr2) 	// Descrição tara primaria
		MSCBSAY(48,70,_cTaraP + " Kg","R","F",fonte_mlr2) // Tara primaria

		_cTs 	  := transform(_vTaras,'@E ##.###')
		_cTaras := strtran(_cTs,',','.')
		MSCBSAY(45,05,"TARA EMB SEC./TARE:","R","F",fonte_mlr2) 			// Descrição tara secundaria
		MSCBSAY(45,70,_cTaras + " Kg","R","F",fonte_mlr2) // Tara secundaria

		_cTa   := transform(_tara,'@E #.###')
		_cTara := strtran(_cTa,',','.')
		MSCBSAY(42,05,"TARA TOTAL/TOTAL TARE:","R","F",fonte_mlr2)   	// Descrição tara total da caixa
		MSCBSAY(42,70,_cTara + " Kg","R","F",fonte_mlr2) // Tara total

		MSCBBOX(41,01,41,125,4)

		// Linha Divisoria

		//******************* 4º Bloco da Etiqueta ************************

		cPEAN14 := getMV('SI_CDEAN14')
		cPEan142 := getMV('SI_CEAN142')
		cPEan143 := getMV('SI_CEAN143')
		cPEan144 := getMV('SI_CEAN144')
		cPEan145 := getMV('SI_CEAN145')

		if (alltrim(_cod) $ (Alltrim(cPEan14)+Alltrim(cPEan142)+Alltrim(cPEan143)+Alltrim(cPEan144)+Alltrim(cPEan145)))
			MSCBSAYBAR(32,31,_cDun14,"R","C",8,.F.,.T.,,,3,1,.T.)  // produtos com DUN14 provenientes de clientes
		elseif _cUM = 'UN'
			if !empty(_nCdBarcli)//bloco para imprimir dun14 do cliente
				_cod13 := '1' + substr(_nCdBarcli,1,12)
			else
				_cod13 := '1' + substr(_nCodBar,1,12)
			endif
			_cDig    := EAN14(_cod13)
			_cod14   := _cod13 + _cDig
			MSCBSAYBAR(32,31,_cod14,"R","C",8,.F.,.T.,,,3,1,.T.)  //EAN exigido pelo walmart
		endif

		MSCBSAY(30,100, _Hora,"R","0",fonte_mlr4)

		//******************* 5º Bloco da Etiqueta ************************

		MSCBBOX(28,01,28,125,4)												// Linha Divisoria

		MSCBSAY(25,04,"REGISTRO NO MINISTERIO DA AGRICULTURA SIF/DIPOA SOB N "+alltrim(_ROTULO),"R","0",fonte_mlr4)                          // Mensagem da Agricultura ok

		//iif(!empty(_GLUTEM),MSCBSAY(22,04,_GLUTEM,"R","0",fonte_mlr4),)     ///Mensagem do Glutem B1_MENETQ3
		MSCBSAY(22,04,ALLTRIM(_GLUTEM)  + " | INDÚSTRIA BRASILEIRA","R","0",fonte_mlr4)

		//iif(!empty(_DESCTIPO),MSCBSAY(22,26,_DESCTIPO,"R","0",fonte_mlr4),) // Mensagem da temperatura
		iif(!empty(_DESCTIPO),MSCBSAY(22,75,_DESCTIPO,"R","0",fonte_mlr4),) // Mensagem da temperatura		

		_dTdP := ""
		_dTdP := substr(_dtPROD,0,2)
		_dTdP := _dTdP + substr(_dtPROD,4,2)
		_dTdP := _dTdP + substr(_dtPROD,7,2)

		MSCBSAY(25,75,'RASTREABILIDADE: 1733' +_dTdP+"0000","R","0",fonte_mlr4)		

		//******************* 6º Bloco da Etiqueta ************************

		MSCBBOX(21,01,21,125,4)  											// Linha Divisoria

		MSCBSAY(14,04,_despor,"R","F",fonte_mlr5) 					// Descrição Ingles/Portugues 05

		MSCBSAYBAR(04,62,_control,"R","C",10,.F.,.T.,,,2,1,.T.)  // Numero do controle da caixa código de barras

		MSCBBOX(4,88,17,123,80,"B")    								   // Box que fica o cod. Produto dentro

		MSCBSAY(18,100,'OP: ' + alltrim(_lote),"R","0",fonte_mlr4)
		
		//MSCBSAY(3,4,alltrim(_vMENETQ),"R","0",fonte_fab7)
		MSCBSAY(4,04,alltrim(_vMENETQ),"R","0",fonte_fab7)
		
		MSCBSAYMEMO(2,88,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto

	ENDIF


	MSCBEND()
	MSCBCLOSEPRINTER()
return .t.


//Etiqueta para caixas do Grupo Pão de Açucar / Carrefour - 25/11/21
User Function GJF111P(_modelo,_porta,_ip,_cControl,_pesoPallet,_taraStrech)

	Local cPrinter  := ''
	Private _sPl 	:= Chr(13) + Chr(10)
	Private _cCmd   := ""   
	Private _cgrp := getMv('SI_POR0001')

	SZ8->(dbSetOrder(3))
	SZ8->(dbGoTop())
	if SZ8->(MsSeek(FwxFilial('SZ8') + alltrim(_cControl)))
		_nPesLiq  := 0.00
		_nPesBrt  := 0.00
		_nQtdCx   := 0
		_nTaraEmb := 0.00
		_dDtValid := SZ8->Z8_DATAVAL
		cProd := SZ8->Z8_COD

		SB1->(DbSetOrder(1))
		SB1->(MsSeek(FWxfilial('SB1')+cProd))

		/* Dia 24/05/22 Ajuste da regra solicitado por Lucinéia para quando produtos forem dos porcionados imprimam só a data produção do Z8_DATAP */
		_cGRUPO := SB1->B1_GRUPO
		If _cgrp $ alltrim(_cGRUPO)
			// se for produtos dos porcionados (conforme grupo)
			_dDtProd  := SZ8->Z8_DATAP
		else
			if !empty(SZ8->Z8_PREDES)
				SZ2->(DbSetOrder(2))
				if  SZ2->(MsSeek(Fwxfilial('SZ2')+SZ8->Z8_PREDES))
					//_dDtProd := SZ2->Z2_DATAABT
					/* Dia 06/12/22 - Tratando no chamado 2927 , Fizemos essa troca para impressão da etiqueta */
					_dDtProd  := SZ8->Z8_DATAP
				endif
			else	
				_dDtProd  := SZ8->Z8_DATAP
			endif
		Endif

		//verfica se o campo do peso fixo possui valor
		//se tiver faz os calculos de acordo com o peso informado
		//esse valor é preenchido de acordo com o valor preenchido no cadastro do produto (B1_PESFIX) 
		if SZ8->Z8_PESFIX <> 0
			_nPesLiq  := SZ8->Z8_PESFIX
			_nPesBrt  := SZ8->Z8_PESFIX + SZ8->Z8_TARA
		else
			_nPesLiq  := SZ8->Z8_PESO
			_nPesBrt  := SZ8->Z8_PESOBR
		endif

		_nTaraTot := SZ8->Z8_TARA

		_nQtdCx   := SZ8->Z8_QUANT

		_cEst := getComputerName()
		/*if _cEst == 'CAM04'
			cPrinter	:= AllTrim(GetMv("PM_ETQZBR")) // \\printserver\gpa - 
		elseif _cEst == 'PEX02'
			cPrinter	:= AllTrim(GetMv("PM_ETQZB5"))// \\printserver\gpapex - 10.7.20.50
		elseif _cEst == 'EXP04' .or. _cEst == 'EXP11'
			cPrinter	:= AllTrim(GetMv("PM_ETQZB6"))// \\printserver\gpaexp04 - 10.6.20.37
		elseif _cEst == 'PORC17'
			cPrinter	:= AllTrim(GetMv("PM_ETQZB7"))//	\\printserver\tstdti - 10.7.20.57
		elseif _cEst == 'DTI08'  .or. _cEst == 'DTI13' .or. _cEst == 'DTI30'	.or. _cEst == 'DTI03'
			cPrinter	:= "\\printserver\impsala" //- 10.7.20.57
		else
			cPrinter	:= AllTrim(GetMv("PM_ETQZB2"))// \\printserver\gpa2 - 10.6.20.1
		endif*/
		cPrinter := Alltrim(GetAdvFVal('ZAM','ZAM_PATHPS',FWxFilial('ZAM')+_cEst,1))

		//codigo de serie da unidade logistica, utilizado na rastreabilidade do palete
		_cSSCC := GetAdvFVal('SZP','ZP_SSCC',FwxFilial('SZP') + alltrim(SZ8->Z8_PALLET),1)
		//_cSSCC := GetAdvFVal('SZ8','Z8_SSCC',FwxFilial('SZ8') + alltrim(SZ8->Z8_CONTROL),3)

		// IdentIficador do Produto
		_cCodBar  	:= SB1->B1_CODBAR
		_cDescSif 	:= SB1->B1_DESCSIF
		_cDescri    := SB1->B1_DESCRED
		_codTrEmb   := SB1->B1_CTARAP
		_codTrCx    := SB1->B1_CTARASE
		_cMensTemp  := SB1->B1_MENETQ2
		_nTrEmb 	:= GetAdvFVal('ZAB','ZAB_TARA',FwxFilial('ZAB') + alltrim(_codTrEmb),1)
		_nTaraCx  	:= GetAdvFVal('ZAB','ZAB_TARA',FwxFilial('ZAB') + alltrim(_codTrCx),1)
		_cCod13  	:= SB1->B1_CODBAR
		_cDun14		:= SB1->B1_DUN14
		_cUm		:= SB1->B1_UM

		_nTaraEmb   := _nQtdCx * _nTrEmb

		//Peso Liquido
		//_cPesLiq := alltrim(strtran(str(_nPesLiq),'.',''))
		_cPesLiq := alltrim(strtran(transform(_nPesLiq,'@E 99.99'),',',''))

		//Peso Bruto
		//_cPesBrt := alltrim(strtran(str(_nPesBrt),'.',''))
		_cPesBrt := alltrim(strtran(transform(_nPesBrt,'@E 99.99'),',',''))

		//Total de Caixas no Pallet
		_cTotCx := transform(_nQtdCx,'@E 99') //strzero(_nQtdCx,3)

		//Tara Total
		_nTotTara := _nTaraTot

		//Data de validade
		_sDtValid := dtos(_dDtValid)
		_cDtValid := alltrim(substr(_sDtValid,3,6))

		//Data de produção
		_sDtProd := dtos(_dDtProd)
		_cDtProd := alltrim(substr(_sDtProd,3,6))

		//Nº de registro de processador - Nº do Registro do Fornecedor no Sif com Iso do Pais(076+1733)
		_cIf := getMv('MV_NUMIF')
		_cIa7030 := '0760' + alltrim(_cIf)

		//Lote das caixas do palete
		_cLote := alltrim(_cDtProd)

		/*cPEAN14 := getMV('SI_CDEAN14')
		cPEan142 := getMV('SI_CEAN142')
		cPEan143 := getMV('SI_CEAN143')
		cPEan144 := getMV('SI_CEAN144')
		cPEan145 := getMV('SI_CEAN145')

		//verifica se é um produto que possui DUN14
		//se for gera etiqueta com padrao peso fixo
		if !(alltrim(cProd) $ (Alltrim(cPEan14)+Alltrim(cPEan142)+Alltrim(cPEan143)+Alltrim(cPEan144)+Alltrim(cPEan145)))
			_cEan13  := '1' + substr(_cCod13,1,12)
			_cDig    := EAN14(_cEan13)
			_cod14   := _cEan13 + _cDig
			_cCodBar := _cod14
		endif*/

		//if _cUm = 'UN'
			//etiqueta caixa peso fixo
			//etqCxPf()
		//else
			//etiqueta caixa peso variavel
			etqCxPv()
		//endif

		reclock('SZ8',.f.)
		SZ8->Z8_SSCC := _cSSCC
		msunlock()

		// Arquivo da etiqueta
		Memowrite("\etiquetas\etq601com.tmp",_cCmd)

		// Executa .bat
		//cComando := "P:\etq601com.bat "+ 'LPT1'
		//cComando := "P:\etq601com.bat "+ AllTrim(cPrinter)
		//cComando := "P:\TOTVS11\Protheus12_Oficial\protheus_data\etiquetas\etq601com.bat "+ AllTrim(cPrinter)
		cComando := "I:\etq601com.bat "+ AllTrim(cPrinter)
		//MemoWrite("C:\TEMP\cComando.txt", cComando)

		WinExec(cComando)
		sleep(1000)

	endif

return

static function refazEan(cCod13)
	Local nOdd := 0
	Local nEven := 0 
	Local nI
	Local nDig  
	Local nMul := 10 
	For nI := 1 to 13
		If (nI%2) == 0
			nEven += val(substr(cCod13,nI,1))
		Else
			nOdd += val(substr(cCod13,nI,1))
		Endif
	Next
	nDig := nEven + (nOdd*3)
	While nMul<nDig
		nMul += 10 
	Enddo
Return strzero(nMul-nDig,1)

//função para gerar etiqueta da caixa peso variavel pão de açucar
Static Function etqCxPv()
	Local _cDmatrix1 := ""
	Local _cDmatrix2 := ""
	Local _cDmatrix3 := ""
	Local _cDmatrix4 := ""

	_cTotCx := '01'

	_cDmatrix1 := "01"+AllTrim(_cDun14)+"17"+_cDtValid+"11"+_cDtProd+"30"+_cTotCx
	_cDmatrix2 := "3102"+StrZero(Val(_cPesLiq),6)+"3302"+StrZero(Val(_cPesBrt),6)+"10"+_cLote
	_cDmatrix3 := "7030"+_cIa7030
	_cDmatrix4 := "00"+AllTrim(_cSSCC)
	_cNumPrev  := SZ8->Z8_NUMPREV
	_dDtAbt    := GetAdvFVal('SZU','ZU_DTABT',FWxFilial('SZU')+_cNumPrev,2)
	_cSIF      := GetAdvFVal('ZZ7','ZZ7_MSIF',FWxFilial('ZZ7')+SZ8->Z8_COD,1)
	_cGrpProd  := GetAdvFval('SB1','B1_GRUPO',FWxFilial('SB1')+SZ8->Z8_COD,1)

	_cCmd += "" + _sPl

	// Setup Etiqueta em ZPL
	_cCmd += "CT~~CD,~CC^~CT~" + _sPl
	_cCmd += "^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR2,2~SD15^JUS^LRN^CI27^PA0,1,1,0^XZ" + _sPl
	_cCmd += "^XA" + _sPl
	_cCmd += "^MMT" + _sPl
	_cCmd += "^PW831" + _sPl
	_cCmd += "^LL1678" + _sPl
	_cCmd += "^LS0" + _sPl

	//#1: (01)
	_cCmd += "^BY2,3,100^FT375,1296^BCB,,N,N,,N" + _sPl
	_cCmd += "^FD>;>801" + AllTrim(_cDun14) + "3102" + StrZero(Val(_cPesLiq),6) + "3302" + StrZero(Val(_cPesBrt),6) + "30>6" + _cTotCx +"^FS" + _sPl
	_cCmd += "^FT405,1296^A0B,25,24^FD(01)" + AllTrim(_cDun14) + "(3102)" + StrZero(Val(_cPesLiq),6) + "(3302)" + StrZero(Val(_cPesBrt),6) + "(30)" + _cTotCx + "^FS" + _sPl	

	//#2: (17)
	_cCmd += "^BY2,3,97^FT520,1296^BCB,,N,N,,N" + _sPl
	_cCmd += "^FD>;>817" + _cDtValid + "11" + _cDtProd + "7030" + _cIa7030 + ">810>6" + _cLote + "^FS" + _sPl
	_cCmd += "^FT545,1296^A0B,25,24^FD(17)" + _cDtValid + "(11)" + _cDtProd + "(7030)" + _cIa7030 + "(10)" + _cLote + "^FS" + _sPl

	//#3: (00)
	_cCmd += "^BY2,3,107^FT675,1296^BCB,,N,N,,N" + _sPl
	_cCmd += "^FD>;>800" + AllTrim(_cSSCC) + "^FS" + _sPl
	_cCmd += "^FT700,1296^A0B,25,24^FD(00)" + AllTrim(_cSSCC) + "^FS" + _sPl

	//#4: GTIN
	_cCmd += "^BY3,3,60^FT770,1296^BCB,,N,N,,N^FD>;" + AllTrim(_cDun14) + "^FS" + _sPl
	_cCmd += "^FT795,1296^A0B,28,28^FH\^FDGTIN: " + AllTrim(_cDun14) + "^FS" + _sPl

	//#5: Matrix
	_cCmd += "^FT570,907^BXN,6,200,0,0,1,_,1" + _sPl
	_cCmd += "^FH\^FD_1" + _cDmatrix1 + "_1" + _cDmatrix2 + "_1" + _cDmatrix3 + "_1" + _cDmatrix4 + "^FS" + _sPl

	_cCmd += "^BY2,3,60^FT785,277^BCB,,Y,N,,N^FD>;" + SZ8->Z8_CONTROL + "^FS" + _sPl

	_cCmd += "^FT715,232^A0B,20,19^FH\^FDPE:" + SZ8->Z8_SEQPETQ + "^FS" + _sPl

	_cCmd += "^FT65,1296^A0B,25,24^FH\^FD" + _cDescSif + "^FS" + _sPl
	_cCmd += "^FT95,1296^A0B,25,24^FH\^FD" + _cDescri + "^FS" + _sPl	
	_cCmd += "^FT125,1296^A0B,25,24^FH\^FD" + AllTrim(_cMensTemp) + "^FS" + _sPl
	_cCmd += "^FT155,1296^A0B,25,24^FH\^FDREGISTRO NO MINISTÉRIO DA AGRICULTURA SIF/DIPOA" + "^FS" + _sPl	
	_cCmd += "^FT185,1296^A0B,25,24^FH\^FDSOB Nº " + AllTrim(_cSIF) + "^FS" + _sPl	
	_cCmd += "^FT215,1296^A0B,25,24^FH\^FDINDÚSTRIA BRASILEIRA | NÃO CONTÉM GLÚTEN" + "^FS" + _sPl
	_cCmd += "^FT245,1296^A0B,25,24^FH\^FDRastreabilidade:" + "1733" + STRTRAN(DToC(_dDtProd),"/", "",) + "0000" + "^FS"+ _sPl

	if !_cGrpProd $ GetMV('MV_GRPPORC')
		_cCmd += "^FT65,611^A0B,25,24^FH\^FDData de abate / Slaughter date: " + DToC(_dDtAbt) + "^FS" + _sPl
		_cCmd += "^FT95,611^A0B,25,24^FH\^FDData de producao/Lote / Production date/Batch: " + DToC(_dDtProd) + "^FS" + _sPl
		_cCmd += "^FT125,611^A0B,25,24^FH\^FDData de validade/Expiry date: " + DToC(_dDtValid) + "^FS" + _sPl
	else
		_cCmd += "^FT65,611^A0B,25,24^FH\^FDData de producao/Lote / Production date/Batch: " + DToC(_dDtProd) + "^FS" + _sPl
		_cCmd += "^FT95,611^A0B,25,24^FH\^FDData de validade/Expiry date: " + DToC(_dDtValid) + "^FS" + _sPl
	endif

	_cCmd += "^FT200,611^A0B,25,24^FH\^FDPeso bruto/Gross weight:^FS" + _sPl
	_cCmd += "^FT255,611^A0B,50,49^FH\^FD" + AllTrim(Transform(_nPesBrt,"@E 999,999.99")) + " Kg" + "^FS" + _sPl
	_cCmd += "^FT300,611^A0B,25,24^FH\^FDPeso liquido/Net weight:^FS" + _sPl
	_cCmd += "^FT355,611^A0B,50,49^FH\^FD" + AllTrim(Transform(_nPesLiq,"@E 999,999.99")) + " Kg" + "^FS" + _sPl

	_cCmd += "^FT400,611^A0B,25,24^FH\^FDTara primária/Primary packing tare:^FS" + _sPl
	_cCmd += "^FT455,611^A0B,50,49^FH\^FD"  + AllTrim(Transform(_nTaraEmb,"@E 999.999")) + " Kg" + "^FS" + _sPl
	_cCmd += "^FT500,611^A0B,25,24^FH\^FDTara da caixa/Carton tare:^FS" + _sPl
	_cCmd += "^FT555,611^A0B,50,49^FH\^FD"  + AllTrim(Transform(_nTaraCx,"@E 999.999")) + " Kg" + "^FS" + _sPl
	_cCmd += "^FT600,611^A0B,25,24^FH\^FDTara total/Total tare:^FS" + _sPl
	_cCmd += "^FT655,611^A0B,50,49^FH\^FD" + AllTrim(Transform(_nTotTara,"@E 999,999.999")) + " Kg" + "^FS" + _sPl

	_cCmd += "^FT670,261^A0B,50,49^FH\^FD" + SZ8->Z8_COD + "^FS" + _sPl
	_cCmd += "^FT710,611^A0B,25,24^FH\^FDPROCESSOR/Processador:" + _cIa7030 + "^FS" + _sPl
	_cCmd += "^FT740,611^A0B,25,24^FH\^FDSSCC" + AllTrim(_cSSCC) + "^FS" + _sPl
	_cCmd += "^FT770,611^A0B,25,24^FH\^FDHora: " + AllTrim(SZ8->Z8_HORA) + "^FS" + _sPl
	
	_cCmd += "^FO155,131^GB0,493,3^FS" + _sPl
	_cCmd += "^FO685,131^GB0,493,3^FS" + _sPl
	
	_cCmd += "^PQ1,0,1,Y^XZ" + _sPl
return


//função para gerar etiqueta da caixa peso fixo pão de açucar
Static Function etqCxPf()

	Local _cDmatrix := "01"+AllTrim(_cDun14)+"17"+_cDtValid+"11"+_cDtProd+"30"+_cTotCx+Chr(29)+"3102"+StrZero(Val(_cPesLiq),6)+"3302"+StrZero(Val(_cPesBrt),6)
	_cDmatrix += "10"+_cLote+Chr(29)+"7030"+_cIa7030+Chr(29)+"00"+AllTrim(_cSSCC)

	_cCmd += "" + _sPl

	// Setup Etiqueta em ZPL
	_cCmd += "CT~~CD,~CC^~CT~" + _sPl
	_cCmd += "^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR2,2~SD15^JUS^LRN^CI0^XZ" + _sPl
	_cCmd += "^XA" + _sPl
	_cCmd += "^MMT" + _sPl
	_cCmd += "^PW831" + _sPl
	_cCmd += "^LL1678" + _sPl
	_cCmd += "^LS0" + _sPl

	// Código GS1-128
	_cCmd += "^BY3,3,200^FT233,1575^BCB,,N,N,,N" + _sPl//1589
	//_cCmd += "^FD>;>802" + AllTrim(_cCodBar) + "15" + _cDtValid +  "11>6" + _cDtProd +"^FS" + _sPl
	_cCmd += "^FD>;>801" + AllTrim(_cCodBar)/*iif(_cUm = 'UN', AllTrim(_cCodBar),  AllTrim(_cDun14))*/ + "15" + _cDtValid +  "11>6" + _cDtProd +"^FS" + _sPl
	_cCmd += "^FT268,1575^A0B,25,24^FD(01)" + AllTrim(_cCodBar)/*iif(_cUm = 'UN', AllTrim(_cCodBar),  AllTrim(_cDun14))*/ + "(17)" + _cDtValid + "(11)" + _cDtProd + "^FS" + _sPl

	//_cCmd += "^FD>;>802" + AllTrim(_cCodBar) + "3102" + StrZero(Val(_cPesLiq),6) + "3302" + StrZero(Val(_cPesBrt),6) + "37>6" + _cTotCx +"^FS" + _sPl
	//_cCmd += "^FT268,1589^A0B,25,24^FD(02)" + AllTrim(_cCodBar) + "(3102)" + StrZero(Val(_cPesLiq),6) + "(3302)" + StrZero(Val(_cPesBrt),6) + "(37)" + _cTotCx + "^FS" + _sPl

	_cCmd += "^BY3,3,197^FT496,1575^BCB,,N,N,,N" + _sPl
	_cCmd += "^FD>;>87030" + alltrim(_cIa7030) + ">810>6" + _cLote + "^FS" + _sPl
	_cCmd += "^FT531,1575^A0B,25,24^FD(7030)" + _cIa7030 + "(10)" + _cLote + "^FS" + _sPl

	//_cCmd += "^FD>;>815" + _cDtValid + "11" + _cDtProd + "7030" + _cIa7030 + ">810>6" + _cLote + "^FS" + _sPl
	//_cCmd += "^FT531,1589^A0B,25,24^FD(17)" + _cDtValid + "(11)" + _cDtProd + "(7030)" + _cIa7030 + "(10)" + _cLote + "^FS" + _sPl

	_cCmd += "^BY5,3,207^FT769,1575^BCB,,N,N,,N" + _sPl
	_cCmd += "^FD>;>800" + AllTrim(_cSSCC) + "^FS" + _sPl
	_cCmd += "^FT802,1575^A0B,25,24^FD(00)" + AllTrim(_cSSCC) + "^FS" + _sPl

	// GS1 Datamatrix
	_cCmd += "^FT575,725^BXN,6,200,0,0,1,_,1^FH\^FD" + _cDmatrix + "^FS" + _sPl

	// Detalhes
	_cCmd += "^FT65,491^A0B,22,19^FH\^FDSSCC" + AllTrim(_cSSCC) + "^FS" + _sPl
	_cCmd += "^FT102,492^A0B,20,19^FH\^FD" + _cDescSIf + "^FS" + _sPl
	_cCmd += "^FT133,492^A0B,17,16^FH\^FDCONTENT/CONTEUDO:^FS" + _sPl
	_cCmd += "^FT174,492^A0B,25,24^FH\^FD" + _cDescri + "^FS" + _sPl

	// Detalhes 2
	_cCmd += "^FT234,497^A0B,20,19^FH\^FDBATCH/LOTE: " + _cLote + "^FS" + _sPl
	_cCmd += "^FT267,497^A0B,20,19^FH\^FDCOUNT/QUANTIDADE: " + TransForm(_nQtdCx,'@E 999') + "^FS" + _sPl
	_cCmd += "^FT301,497^A0B,20,19^FH\^FDPROD.DATE/DATA DE PRODUCAO :  " + DToC(_dDtProd) + "^FS" + _sPl
	_cCmd += "^FT335,498^A0B,20,19^FH\^FDSELL  BY  /  DATA  DE  VALIDADE :  " + DToC(_dDtValid) + "^FS" + _sPl

	// Pesos
	_cCmd += "^FT381,504^A0B,17,16^FH\^FDPACKING TARE/TARA EMBALAGEM:^FS" + _sPl
	_cCmd += "^FT383,176^A0B,20,19^FH\^FD"  + Transform(_nTaraEmb,"@E 999.999") + "^FS" + _sPl
	_cCmd += "^FT430,504^A0B,20,19^FH\^FDBOX TARE/TARA DA CAIXA:^FS" + _sPl
	_cCmd += "^FT429,231^A0B,23,24^FH\^FD"  + Transform(_nTaraCx,"@E 999.999") + "^FS" + _sPl

	_cCmd += "^FT479,504^A0B,20,19^FH\^FDTOTAL TARE/TARA TOTAL:^FS" + _sPl
	_cCmd += "^FT479,231^A0B,23,24^FH\^FD" + Transform(_nTotTara,"@E 999,999.999") + "^FS" + _sPl
	_cCmd += "^FT527,504^A0B,20,16^FH\^FDGROSS WEIGHT/PESO BRUTO:^FS" + _sPl
	_cCmd += "^FT527,234^A0B,23,24^FH\^FD" + Transform(_nPesBrt,"@E 999,999.99") + "^FS" + _sPl
	_cCmd += "^FT576,504^A0B,20,19^FH\^FDNET WEIGHT/PESO LIQUIDO:^FS" + _sPl
	_cCmd += "^FT575,234^A0B,23,24^FH\^FD" + Transform(_nPesLiq,"@E 999,999.99") + "^FS" + _sPl

	_cCmd += "^FT633,505^A0B,25,24^FH\^FDPROCESSOR/Processador: " + _cIa7030 +" ^FS" + _sPl
	_cCmd += "^FT681,505^A0B,28,28^FH\^FDGTIN: " + AllTrim(_cCodBar)/*iif(_cUm = 'UN', AllTrim(_cCodBar),  AllTrim(_cDun14))*/ + "^FS" + _sPl

	_cCmd += "^FT722,505^A0B,20,19^FH\^FD" + AllTrim(_cMensTemp) + "^FS" + _sPl

	//_cCmd += "^FT575,67^A0B,23,24^FH\^FDkg^FS" + _sPl
	_cCmd += "^FT384,67^A0B,20,19^FH\^FDkg^FS" + _sPl
	_cCmd += "^FT431,70^A0B,23,24^FH\^FDkg^FS" + _sPl
	_cCmd += "^FT479,67^A0B,23,24^FH\^FDkg^FS" + _sPl
	//_cCmd += "^FT527,67^A0B,23,24^FH\^FDkg^FS" + _sPl
	_cCmd += "^FO595,30^GB0,493,3^FS" + _sPl
	_cCmd += "^FO349,30^GB0,493,2^FS" + _sPl
	_cCmd += "^FO202,30^GB0,493,3^FS" + _sPl

	_cCmd += "^PQ1,0,1,Y^XZ" + _sPl

return  

user function GJF111q(_modelo,_porta,_cIp,_cNum,_dData,_cHora,_nPeso)
	/*                      1      2   3     4     5      6      7
	Paremetros da função
	1  - modelo da impressora
	2  - porta
	3  - Ip impressora
	4  - Numero do pallet
	5  - Data da pesagem
	6  - hora da pesagem
	7  - peso do pallet
	*/

	_cDescri := "ETIQUETA DE IDENTIFICAÇÃO DO PALLET"
	_cData := dtoc(_dData)	

	MSCBPRINTER(_modelo,_porta,,,,,_cIp)
	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(1,6,40)

	fonte1:="60,60"
	fonte2:="100,100"
	fonte3  :="45,15"
	fonte4 := "52,52"

	MSCBSAY(66,35,_cNum,"R","0",fonte2)   				//Número do Pallet
	MSCBSAY(55,10,_cDescri,"R","0",fonte4)        			// descrição
	//MSCBSAYBAR(30,30,_cNum,"R","C",20,.F.,.T.,,,3,2,.F.)  //código de barras
	MSCBSAYBAR(30,5,_cNum,"R","C",18,.F.,.T.,,,6,2,.F.)  //MSCBSAYBAR(30,5,_cNum,"R","C",20,.F.,.T.,,,6,2,.F.)  //código de barras
	MSCBSAY(12,15,'Data de Criação:',"R","0",fonte1)
	MSCBSAY(12,65,_cData,"R","0",fonte1)	 
	MSCBSAY(02,15,'Peso Pallet:',"R","0",fonte1)
	MSCBSAY(02,53,transform(_nPeso,' @E 99.99'),"R","0",fonte1)	             	// Peso do Pallet
	MSCBEND()
	MSCBCLOSEPRINTER()

return .t.


/* Histórico de Alterações
1 - Alteração feita em 07/01/17 -  por Flávio, 
OBS - Ajuste feito a pedido da Adriana para que saisse em todos produtos dos miudos
em vez de somente "DATA PRODUCAO" , Sair "PRODUCTION DATE/DATA DE PRODUCAO"  
*/
//Etiqueta para reimpressão normal em estações do POrcionados , tipo sem data de abate
user function GJF111u(_modelo,_porta,_control,_cod,_quant,_pesob,_pesol,_tara,_predes,_classif,_TF,_datap,_etq,_dataval,_nNumEtq,_Lote,_IP,_seqPetq,_cLotePor)
	/*                   1      2        3      4     5      6     7      8     9        10     11    12   13     14       15      16    17    18       19       20
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
	*/

	//local dtAbate   := ''
	local _vTIP     := ''
	local _vDESCES  := ''
	local _vDINGLES := ''
	local _vDESCING := ''
	local _vDFRANCES:= ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vDESCFRA := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vTARAP   := 0.00
	local _vTARAS   := 0.00
	local _vMENETQ  := ''
	local _vFAM     := ''
	local _DESTINO  := ''
	local _DESCTIPO := ''
	local _GLUTEM   := ''
	local _SEXO     := ''
	local _vNUMAM   := ''
	local _vDTABATE := ''
	local _vRASTRO  := ''
	//local _vTIP     := ''
	local _desing   := ''
	local _desfra   := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _despor   := ''
	local _descFAM  := ''
	local _dtPROD   := ''
	local _dtVALID  := ''
	local _nTS      := ''
	local _nTP      := ''
	local _cSeq     := ''  //Campo feito por Fabian Maurer para capturar o codigo da Pre-Etiqueta - 27/02/12
	local _cPesol   := strtran(cValtoChar(_pesol),'.','')
	local	_codExp   := getMv('SI_CODEXP')		

	//alert('72-Control-'+_control+' - Cod:'+_cod)
	Dbselectarea('SB1')
	SB1->(dbsetorder(1))
	SB1->(Msseek(Fwxfilial('SB1')+alltrim(_cod)))
	_vDINGLES := SB1->B1_DESCING //os dois campos abaixo estao invertidos de proposito para não
	_vDESCING := SB1->B1_DINGLES //precisar mexer no layout de impressao - B1_DINGLES é a do SIF
	_vDFRANCES:= SB1->B1_DESCFRA //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	_vDESCFRA := SB1->B1_DFRANCE //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	_vDESCES  := SB1->B1_DESCESP // e o B1_DESCING a descrição em ingles do produto
	_vDESCSIF := SB1->B1_DESCSIF //
	_nTS      := SB1->B1_CTARASE
	_cGrupo   := SB1->B1_GRUPO
	_cFarm    := GetAdvFVal('SBM','BM_FARM',Fwxfilial('SBM')+_cGrupo,1)
	_vTARAS   := GetAdvFVal('ZAB','ZAB_TARA',Fwxfilial('ZAB')+alltrim(_nTS),1)  //Tara Secundária
	_nTP      := SB1->B1_CTARAP
	_vTARAP   := GetAdvFVal('ZAB','ZAB_TARA',Fwxfilial('ZAB')+alltrim(_nTP),1)   //Tara Primária
	_vMENETQ  := SB1->B1_MENETQ1 //Mensagem etiqueta 1
	_vFAM     := SB1->B1_FAM     //Família Silva
	_DESTINO  := SB1->B1_DESTINO //Destino
	_DESCTIPO := SB1->B1_MENETQ2
	_GLUTEM   := SB1->B1_MENETQ3
	_SEXO	    := SB1->B1_MENETQ4
	_nCodBar   := SB1->B1_CODBAR
	_nCdBarcli := SB1->B1_EANCLI
	_cUm      := SB1->B1_UM
	_cDun14   := SB1->B1_DUN14
	_cNotImp  := GetAdvFVal('SZU','ZU_NOTIMP',Fwxfilial('SZU') + SZ8->Z8_NUMPREV,2)

	if !empty(_predes) .and. substr(_predes,1,3) <> 'SIF'
		SZ2->(DbSetOrder(2))
		if  SZ2->(MsSeek(Fwxfilial('SZ2')+_predes))                          	// se houver o apontamento de OP...
			_vNUMAM   := SZ2->Z2_NUMAM //GetAdvFVal('SZ2',2,Fwxfilial('SZ2')+_predes,'Z2_NUMAM')  				//numero aviso de matança
			_vDTABATE := dtoc(SZ2->Z2_DATAABT) //dtoc(GetAdvFVal('SZ2',2,Fwxfilial('SZ2')+_predes,'Z2_DATAABT'))//aviso de matança formatado em string
			_vRASTRO  := GetMv("MV_NUMIF") + strtran(_vDTABATE,'/','') +'0000   (' + _classif + ')' //Rastro
			_vTIP     := SZ2->Z2_TIPIFI //GetAdvFVal('SZ2',2,Fwxfilial('SZ2')+_predes,'Z2_TIPIFI')  				//numero aviso de matança
		endif
	endif

	_desing  := alltrim(_vDINGLES)
	_desfra  := alltrim(_vDFRANCES) //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	_despor  :=  " (" + alltrim(SB1->B1_DESCRED) + ")"         //Descrição reduzida em portugues
	_cSeq    := _seqPetq//iif(empty(SZ8->Z8_SEQPETQ),_seqPetq,SZ8->Z8_SEQPETQ) //Campo feito por Fabian Maurer para capturar o codigo da Pre-Etiqueta - 27/02/12

	DbSelectArea('SX5')
	_descFAM := GetAdvFVal('SX5','X5_DESCRI',Fwxfilial("SX5")+'PS'+_vFAM,1)   //Descrição da família
	_dtPROD  := dtoc(_datap)   //data da produção
	_dtVALID := dtoc(_dataval) //data de validade


	/*************************** Etiqueta Padrão  ************************************************ */
	//_IP := "10.11.20.5" 
	//alert(_IP+' - 121')
	if(_etq='P')                  
		if !empty(_IP)
			MSCBPRINTER(_modelo,"IP",,,,,_IP)	
		else
			MSCBPRINTER(_modelo,_porta)
		endif	
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(_nNumEtq,6,40)
		// Posição d codigo de barras
		fonte1  :="35,15"
		fonte1_1:="30,15"

		fonte2  :="35,30"
		fonte2_1:="60,60"
		fonte2_2:="25,35"
		fonte2_3:="20,23"
		fonte2_4:="35,30"
		fonte2_5:="25,20" // Trocando até acertar
		fonte3  :="45,15"
		fonte3_1:="40,45"
		f_extra :="30,22"
		fonte3_2:="84,90"
		fonte3_3:="24,15"
		fonte3_4:="45,30"
		fonte4  :="20,5"
		fonte4_1:="18,10"
		fsexo := "50,40"
		fonte5  :="25,25"
		//Novas fontes Criadas por Fabian Maurer - 07/06/12
		fonte_fab1 := "27,15"
		fonte_fab2 := "27,17"
		fonte_fab3 := "50,25"
		fonte_fab4 := "35,20"
		fonte_fab5 := "38,15"
		fonte_fab6 := "10,6"
		//Novas fontes para teste (Mauricio L. Roehrs)
		fonte_mlr1 := "25,10"
		fonte_mlr2 := "15,10"
		fonte_mlr3 := "45,20"
		fonte_mlr4 := "20,18"
		fonte_mlr5 := "60,18"

		IF SB1->B1_DESTINO == 'ME'

			//***************** 1º Bloco da Etiqueta ********************

			MSCBSAY(73,85,_control,"R","F",fonte_mlr1) 						//Numero de controle
			MSCBSAY(73,05,_vDESCING,"R","F",fonte_mlr2)                 //Descricao em Ingles
			MSCBSAY(69,05,_vDESCSIF,"R","F",fonte_mlr2)                 //Descricao em Portugues
			MSCBBOX(68,01,68,180,4)                                     //Linha Divisoria

			//***************** 2º Bloco da Etiqueta ********************  

			MSCBSAY(64,05,"PACKING DATE/ "+ iif(_cFarm = 'S',"DATA DE PRODUCAO:","DATA DA EMBALAGEM:"),"R","F",fonte_mlr2)
			MSCBSAY(64,70,_dtPROD,"R","F",fonte_mlr2)                                                       
			//iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,05,"PROD.DATE/LOT /DATA PROD./LOTE:","R","F",fonte_mlr2),)
			//iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,70,_vDTABATE,"R","F",fonte_mlr2),)
			MSCBSAY(61,05,"EXPIRY DATE/DATA DE VALIDADE:","R","F",fonte_mlr2)
			MSCBSAY(61,70,_dtVALID,"R","F",fonte_mlr2)

			MSCBBOX(57,105,68,105,4)
			MSCBSAY(62,110,_DESTINO,"R","F",fonte_mlr3)

			MSCBBOX(57,01,57,180,4)

			//***************** 3º Bloco da Etiqueta ********************
			if  _cNotImp <> "P"
				_cPb := transform(_pesob,'@E 99.999')
				_cPesob := strtran(_cPb,',','.')
				MSCBSAY(53,05,"PESO BRUTO/GROSS WEIGHT:","R","F",fonte_mlr2)
				MSCBSAY(53,70,_cPesob + " Kg","R","F",fonte_mlr2)

				_cPl    := transform(_pesol,'@E ##.###')
				_cPesol := strtran(_cPl,',','.')
				MSCBSAY(46,05,"PESO LIQUIDO/NET WEIGHT:","R","F",fonte_mlr2)
				MSCBSAY(46,70,_cPesol + "Kg","R","F",fonte_mlr3)

				_cTp    := transform(_quant * _vTaraP,'@E ##.###')
				_cTaraP := strtran(_cTp,',','.')
				MSCBSAY(43,05,"TARA EMB.PRIM./INTERNAL TARE:","R","F",fonte_mlr2)
				MSCBSAY(43,70,_cTARAP + " Kg","R","F",fonte_mlr2)

				// Inclusão Para impressão Rastreada "RT". Dia 19/09/16 - Flávio
				iif(AllTrim(_classif) = 'RT',MSCBSAY(42,107,_classif,"R","0",fonte2_1),)  //VER SE ENTRA E COLOCAR EM NOVO BLOCO

				_cTs := transform(_vTaras,'@E ##.###')
				_cTaras := strtran(_cTs,',','.')
				MSCBSAY(40,05,"TARA EMB. SEC./TARE:","R","F",fonte_mlr2)
				MSCBSAY(40,70,_cTARAS + " Kg","R","F",fonte_mlr2)

				_cTa := transform(_tara,'@E #.###')
				_cTara := strtran(_cTa,',','.')
				MSCBSAY(37,05,"TARA TOTAL/TOTAL TARE:","R","F",fonte_mlr2)
				MSCBSAY(37,70,_cTara + " Kg","R","F",fonte_mlr2)

				MSCBBOX(36,01,36,180,4)
			else

				MSCBSAY(53,05,"PESO BRUTO/GROSS WEIGHT:","R","F",fonte_mlr2)
				MSCBSAY(53,70,transform(_pesob,'@E ##.###')+" Kg","R","F",fonte_mlr2)

				MSCBSAY(46,05,"PESO LIQUIDO/NET WEIGHT:","R","F",fonte_mlr2)
				MSCBSAY(46,70,transform(_pesol,'@E ##.###')+"Kg","R","F",fonte_mlr3)

				MSCBSAY(43,05,"TARA EMB.PRIM./INTERNAL TARE:","R","F",fonte_mlr2)
				MSCBSAY(43,70,transform(_quant * _vTARAP,'@E ##.###')+" Kg","R","F",fonte_mlr2)

				// Inclusão Para impressão Rastreada "RT". Dia 19/09/16 - Flávio
				iif(AllTrim(_classif) = 'RT',MSCBSAY(42,107,_classif,"R","0",fonte2_1),)  //VER SE ENTRA E COLOCAR EM NOVO BLOCO		

				MSCBSAY(40,05,"TARA EMB. SEC./TARE:","R","F",fonte_mlr2)
				MSCBSAY(40,70,transform(_vTARAS,'@E ##.###')+" Kg","R","F",fonte_mlr2)

				MSCBSAY(37,05,"TARA TOTAL/TOTAL TARE:","R","F",fonte_mlr2)
				MSCBSAY(37,70,transform(_tara,'@E ##.###')+" Kg","R","F",fonte_mlr2)

				MSCBBOX(36,01,36,180,4)

			endif

			//***************** 4º Bloco da Etiqueta ********************

			MSCBSAY(33,05,_vMENETQ,"R","0",fonte_mlr4)

			MSCBSAY(30,05,ALLTRIM(_GLUTEM)  + " | INDÚSTRIA BRASILEIRA","R","0",fonte_mlr4)

			// Inclusão dia 19/09/16 - Para impressão de Produtos RT - Flávio 
			//iif(AllTrim(_classif) == 'RT',iif(!empty(_predes),MSCBSAY(29,05,"RASTREABILIDADE :" + _vRASTRO,"R","0",fonte_mlr4),),) 	// Descrição Rastreabilidade

			_cRastro := '1733' + strtran(_vDTABATE,'/','') +'0000'
			MSCBSAY(27,53,"Rastreabilidade: "+ _cRastro,"R","0",fonte_mlr4)

			//MSCBSAY(35,100, _Hora,"R","0",fonte_mlr4)
			
			iif(!empty(_DESCTIPO),MSCBSAY(27,05,_DESCTIPO,"R","0",fonte_mlr4),) // Mensagem do Tipo

			iif(!empty(_Lote) .and. !empty(_predes).and. substr(_predes,1,3) <> 'SIF',MSCBBOX(26,105,36,105,4),)

			iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,106,"LOTE:","R","F",fonte_mlr2),)    //Lote
			iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,116,_Lote,"R","F",fonte_mlr2),)  //descricao do lote preenchido no lançamento da OP da embalagem

			MSCBSAY(27,70,_SEXO,"R","0",fonte_mlr4) //descrição do sexo. preenche campo MENTETQ4 no cadastro de produtos

			MSCBBOX(26,01,26,180,4)

			//***************** 5º Bloco da Etiqueta ********************

			MSCBSAY(17,05,_despor+_desing,"R","F",fonte_mlr5)

			MSCBSAYBAR(06,62,_control,"R","C",10,.F.,.T.,,,2,1,.T.)

			//MSCBBOX(06,92,18,123,80,"B")                                          //Box preto onde fica o cod. do produto
			MSCBBOX(06,88,18,123,80,"B")                                          //Box preto onde fica o cod. do produto
			//MSCBSAYMEMO(03,92,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
			MSCBSAYMEMO(03,88,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
			MSCBSAY(01,94,"PE:"+_cSeq,"R","0","25,20")
		ELSE // MI

			//***************** 1º Bloco da Etiqueta ********************

			MSCBSAY(75,85,_control,"R","F",fonte_mlr1)         					// Numero de controle

			MSCBSAY(75,05,_vDESCSIF,"R","F",fonte_mlr2)   						//Descrição em ingles

			MSCBSAY(72,05,_vDESCING,"R","F",fonte_mlr2) 						//Descrição em Portugues

			MSCBBOX(71,01,71,125,4) 											// Linha Divisoria

			//************** 2º Bloco da Etiqueta ***********************

			MSCBSAY(67,05,"PACKING DATE/ "+ iif(_cFarm = 'S',"DATA PRODUCAO:","DATA EMBALAGEM:"),"R","F",fonte_mlr2) //Descrição data de produção
			MSCBSAY(67,70,_dtPROD,"R","F",fonte_mlr2)             				// Data de Produção

			MSCBSAY(64,05,"DATA VALIDADE/EXPIRY DATE:","R","F",fonte_mlr2)   // Descrição data de validade - Alterado por Fabian Maurer - 02/05/12 - Correção de Escrita
			MSCBSAY(64,70,_dtVALID,"R","F",fonte_mlr2)     						//Data de Validade			

			MSCBBOX(61,105,71,105,4)                                            // Linha Separa Tipo de Mercado

			MSCBSAY(62,110,_DESTINO,"R","F",fonte_mlr3)     					// Descrição Tipo de Mercado ( MI )

			MSCBBOX(61,01,61,125,4) 											// Linha Divisoria

			//************** 3º Bloco da Etiqueta ************************

			if  _cNotImp <> "P"

				_cPb    := transform(_pesob,'@E 99.999')
				_cPesob := strtran(_cPb,',','.')
				MSCBSAY(57,05,"PESO BRUTO/GROSS WEIGHT:","R","F",fonte_mlr2) 		// Descrição peso bruto da caixa
				MSCBSAY(57,70,_cPesob + " Kg","R","F",fonte_mlr2) // Peso Bruto

				_cPl    := transform(_pesol,'@E ##.###')
				_cPesol := strtran(_cPl,',','.')
				MSCBSAY(51,05,"PESO LIQUIDO/NET WEIGHT:","R","F",fonte_mlr2)      // Descrição peso liquido
				MSCBSAY(51,70, _cPesol + " Kg","R","F",fonte_mlr3)   	// Peso liquido
				// Descrição KG

				_cTp    := transform(_quant * _vTaraP,'@E ##.###')
				_cTaraP := strtran(_cTp,',','.')
				MSCBSAY(48,05,"TARA EMB.PRIM./INTERNAL TARE:","R","F",fonte_mlr2) 	// Descrição tara primaria
				MSCBSAY(48,70,_cTaraP + " Kg","R","F",fonte_mlr2) // Tara primaria

				_cTs 	  := transform(_vTaras,'@E ##.###')
				_cTaras := strtran(_cTs,',','.')
				MSCBSAY(45,05,"TARA EMB SEC./TARE:","R","F",fonte_mlr2) 			// Descrição tara secundaria
				MSCBSAY(45,70,_cTaras + " Kg","R","F",fonte_mlr2) // Tara secundaria

				_cTa   := transform(_tara,'@E #.###')
				_cTara := strtran(_cTa,',','.')
				MSCBSAY(42,05,"TARA TOTAL/TOTAL TARE:","R","F",fonte_mlr2)   	// Descrição tara total da caixa0000422081
				MSCBSAY(42,70,_cTara + " Kg","R","F",fonte_mlr2) // Tara total

				MSCBBOX(41,01,41,125,4)

			else
				MSCBSAY(57,05,"PESO BRUTO/GROSS WEIGHT:","R","F",fonte_mlr2) 		// Descrição peso bruto da caixa
				MSCBSAY(57,70,transform(_pesob,'@E ##.###')+" Kg","R","F",fonte_mlr2) // Peso Bruto

				MSCBSAY(51,05,"PESO LIQUIDO/NET WEIGHT:","R","F",fonte_mlr2)      // Descrição peso liquido
				MSCBSAY(51,70, transform(_pesol,'@E ##.###')+" Kg","R","F",fonte_mlr3)   	// Peso liquido				

				MSCBSAY(48,05,"TARA EMB.PRIM./INTERNAL TARE:","R","F",fonte_mlr2) 	// Descrição tara primaria
				MSCBSAY(48,70,transform(_quant * _vTARAP,'@E ##.###')+" Kg","R","F",fonte_mlr2) // Tara primaria

				MSCBSAY(45,05,"TARA EMB SEC./TARE:","R","F",fonte_mlr2) 			// Descrição tara secundaria
				MSCBSAY(45,70,transform(_vTARAS,'@E ##.###')+" Kg","R","F",fonte_mlr2) // Tara secundaria

				MSCBSAY(42,05,"TARA TOTAL/TOTAL TARE:","R","F",fonte_mlr2)   	// Descrição tara total da caixa
				MSCBSAY(42,70,transform(_tara,'@E #.###')+" Kg","R","F",fonte_mlr2) // Tara total

				MSCBBOX(41,01,41,125,4) 											// Linha Divisoria

				// Linha Divisoria
			endif

			iif(_TF == 'S',MSCBSAY(33,105,"TF","R","0",fonte2_1),)

			//******************* 4º Bloco da Etiqueta ************************

			cPEAN14 := getMV('SI_CDEAN14')
			cPEan142 := getMV('SI_CEAN142')
			cPEan143 := getMV('SI_CEAN143')
			cPEan144 := getMV('SI_CEAN144')
			cPEan145 := getMV('SI_CEAN145')

			if (alltrim(_cod) $ (Alltrim(cPEan14)+Alltrim(cPEan142)+Alltrim(cPEan143)+Alltrim(cPEan144)+Alltrim(cPEan145)))
				MSCBSAYBAR(32,31,_cDun14,"R","C",8,.F.,.T.,,,3,1,.T.)  // produtos com DUN14 provenientes de clientes
			elseif _cUM = 'UN'
				if !empty(_nCdBarcli)//bloco para imprimir dun14 do cliente
					_cod13 := '1' + substr(_nCdBarcli,1,12)
				else
					_cod13 := '1' + substr(_nCodBar,1,12)
				endif
				_cDig    := EAN14(_cod13)
				_cod14   := _cod13 + _cDig
				MSCBSAYBAR(32,31,_cod14,"R","C",8,.F.,.T.,,,3,1,.T.)  //EAN exigido pelo walmart
			else
				MSCBSAYBAR(32,31,'010' + _nCodBar + '310200' + substr(_cPesol,1,2) + substr(_cPesol,3,2),"R","C",8,.F.,.T.,,,3,1,.T.)  //EAN exigido pelo walmart			
			endif

			//MSCBSAYBAR(32,31,'010' + _nCodBar + '310200' + substr(_cPesol,1,2) + substr(_cPesol,3,2),"R","C",8,.F.,.T.,,,3,1,.T.)  //EAN exigido pelo walmart

			//******************* 5º Bloco da Etiqueta ************************

			MSCBBOX(28,01,28,125,4)												// Linha Divisoria

			//Alteração Solicitada pela Karine para realocar as mensagens da etiqueta somente para produtos Salgados
			//Alteração feita por Mauricio Roehrs

			if _cFarm <> 'S' //se for diferente de "Salgados" imprime padrão
				MSCBSAY(25,04,_vMENETQ,"R","0",fonte_mlr4)                          // Mensagem da Agricultura

				iif(!empty(_GLUTEM),MSCBSAY(22,04,_GLUTEM,"R","0",fonte_mlr4),)     // Mensagem do Glutem

				//iif(!empty(_DESCTIPO),MSCBSAY(22,26,_DESCTIPO,"R","0",fonte_mlr4),) // Mensagem do Tipo
				iif(!empty(_DESCTIPO),MSCBSAY(22,40,_DESCTIPO,"R","0",fonte_mlr4),) // Mensagem do Tipo

				if !empty(_cLotePor)//se for caixa de porcionados imprime esta frase.
					MSCBSAY(25,01,"REGISTRO NO MINISTERIO DA AGRICULTURA SIF/DIPOA SOB N "+alltrim(_SEXO),"R","0",fonte_mlr4)    
				endif
			else //senão imprime com alterações Solicitadas
				MSCBSAY(25,04,_vMENETQ,"R","0",fonte_mlr4)                          // Mensagem da Agricultura ok

				iif(!empty(_GLUTEM),MSCBSAY(22,04,_GLUTEM,"R","0",fonte_mlr4),)     // Mensagem do Glutem ok

				iif(!empty(_DESCTIPO),MSCBSAY(22,26,_DESCTIPO,"R","0",fonte_mlr4),) // Mensagem do Tipo

				iif(!empty(_SEXO),MSCBSAY(22,60,_SEXO,"R","0",fonte_mlr4),) // Mensagem Utilizada para "SEXO" alterada por solicitação da Karine
			endif

			//******************* 6º Bloco da Etiqueta ************************

			MSCBBOX(21,01,21,125,4)  											// Linha Divisoria

			if len(_despor+_desing) > 40

				_cPrimFrase := substr(_despor+_desing,1,50)
				_cSegFrase  := substr(_despor+_desing,51,30)
				_cTercF  := substr(_despor+_desing,81,30)

				MSCBSAY(15,04,_cPrimFrase,"R","F",fonte_mlr2)
				MSCBSAY(12,04,_cSegFrase,"R","F",fonte_mlr2)
				MSCBSAY(9,04,_cTercF,"R","F",fonte_mlr2)

			else
				MSCBSAY(14,04,_despor + " (" + _desing + ")" ,"R","F",fonte_mlr2)
			endif

			MSCBSAYBAR(04,62,_control,"R","C",10,.F.,.T.,,,2,1,.T.)  			// Numero do controle da caixa código de barras

			//MSCBBOX(4,93,17,123,80,"B")    										// Box que fica o cod. Produto dentro
			MSCBBOX(4,88,17,123,80,"B")    										// Box que fica o cod. Produto dentro

			//MSCBSAYMEMO(2,93,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
			MSCBSAYMEMO(2,88,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto

			MSCBSAY(01,100,"PE:"+_cSeq,"R","0","25,20")						// Numero da Pre-Etiqueta   01/100

			//******************* Não Utilizados ************************

		ENDIF

		MSCBEND()
		MSCBCLOSEPRINTER()

		//******************************** Inicio Etiqueta Espanhol ******************************\\
	elseif(_etq='E')
		if !empty(_IP)
			MSCBPRINTER(_modelo,'IP',,,,,_IP)	
		else
			MSCBPRINTER(_modelo,_porta)
		endif

		//modelo, 'IP' ,,,,,endereço ip do server de impressao(IP DA ZEBRA)
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(_nNumEtq,6,40)
		// Posição d codigo de barras
		fonte1  :="35,15"
		fonte1_1:="30,15"

		fonte2  :="35,30"
		fonte2_1:="60,60"
		fonte2_2:="25,35"
		fonte2_3:="20,23"
		fonte2_4:="35,30"
		fonte2_5:="25,20" // Trocando até acertar
		fonte3  :="45,15"
		fonte3_1:="40,45"
		f_extra :="30,22"
		fonte3_2:="84,90"
		fonte3_3:="24,15"
		fonte3_4:="45,30"
		fonte4  :="20,5"
		fonte4_1:="18,10"
		fsexo := "50,40"
		fonte5  :="25,25"
		//Novas fontes Criadas por Fabian Maurer - 07/06/12
		fonte_fab1 := "27,15"
		fonte_fab2 := "27,17"
		fonte_fab3 := "50,25"
		fonte_fab4 := "35,20"
		fonte_fab5 := "38,15"
		fonte_fab6 := "10,6"
		//Novas fontes para teste (Mauricio L. Roehrs)
		fonte_mlr1 := "25,10"
		fonte_mlr2 := "15,10"
		fonte_mlr3 := "45,20"
		fonte_mlr4 := "20,18"
		fonte_mlr5 := "60,18"

		//***************** 1º Bloco da Etiqueta ********************

		MSCBSAY(73,85,_control,"R","F",fonte_mlr1) 						//Numero de controle
		MSCBSAY(73,05,_vDESCSIF,"R","F",fonte_mlr2)                 //Descricao em Ingles
		MSCBSAY(69,05,_vDESCING,"R","F",fonte_mlr2)                 //Descricao em Portugues
		MSCBBOX(68,01,68,180,4)                                     //Linha Divisoria

		//***************** 2º Bloco da Etiqueta ********************

		if alltrim(_cod) $ _codExp

			MSCBSAY(64,05,"FECHA DE PRODUCCION:/ DATA DE PRODUCAO:","R","F",fonte_mlr2)
			MSCBSAY(64,80,_dtPROD,"R","F",fonte_mlr2)	
		else
			MSCBSAY(64,05,"FECHA DE ENVASE/ "+ iif(_cFarm = 'S',"DATA DE PRODUCAO:","DATA DA EMBALAGEM:"),"R","F",fonte_mlr2)
			MSCBSAY(64,80,_dtPROD,"R","F",fonte_mlr2)

			//iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,38,"FECHA DE PRODUCCION:","R","F",fonte_mlr2),)
			//iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,80,_vDTABATE,"R","F",fonte_mlr2),)	
		endif

		MSCBSAY(61,05,"FECHA DE VALIDAD/DATA DE VALIDADE:","R","F",fonte_mlr2)
		MSCBSAY(61,80,_dtVALID,"R","F",fonte_mlr2)

		//MSCBSAY(58,05,"PIEZA/PECA:","R","F",fonte_mlr2)
		//MSCBSAY(58,35,transform(_quant,'@E ######'),"R","F",fonte_mlr2)

		MSCBBOX(57,105,68,105,4)
		MSCBSAY(62,110,_DESTINO,"R","F",fonte_mlr3)

		MSCBBOX(57,01,57,180,4)

		//***************** 3º Bloco da Etiqueta ********************
		if  _cNotImp <> "P"
			_cPb := transform(_pesob,'@E 99.999')
			_cPesob := strtran(_cPb,',','.')
			MSCBSAY(53,05,"PESO BRUTO/PESO BRUTO:","R","F",fonte_mlr2)
			MSCBSAY(53,70,_cPesob + " Kg","R","F",fonte_mlr2)

			_cPl    := transform(_pesol,'@E ##.###')
			_cPesol := strtran(_cPl,',','.')
			MSCBSAY(46,05,"PESO NETO/PESO LIQUIDO:","R","F",fonte_mlr2)
			MSCBSAY(46,70,_cPesol + "Kg","R","F",fonte_mlr3)

			_cTp    := transform(_quant * _vTaraP,'@E ##.###')
			_cTaraP := strtran(_cTp,',','.')
			MSCBSAY(43,05,"TARA ENV. PRIM./TARA EMB.PRIM.:","R","F",fonte_mlr2)
			MSCBSAY(43,70,_cTARAP + " Kg","R","F",fonte_mlr2)

			_cTs := transform(_vTaras,'@E ##.###')
			_cTaras := strtran(_cTs,',','.')
			MSCBSAY(40,05,"TARA ENV. SEC./TARA EMB. SEC.:","R","F",fonte_mlr2)
			MSCBSAY(40,70,_cTARAS + " Kg","R","F",fonte_mlr2)

			_cTa := transform(_tara,'@E #.###')
			_cTara := strtran(_cTa,',','.')
			MSCBSAY(37,05,"TARA TOTAL/TARA TOTAL:","R","F",fonte_mlr2)
			MSCBSAY(37,70,_cTara + " Kg","R","F",fonte_mlr2)

			MSCBBOX(36,01,36,180,4)
		else
			MSCBSAY(53,05,"PESO BRUTO/PESO BRUTO:","R","F",fonte_mlr2)
			MSCBSAY(53,70,transform(_pesob,'@E ##.###')+" Kg","R","F",fonte_mlr2)

			MSCBSAY(46,05,"PESO NETO/PESO LIQUIDO:","R","F",fonte_mlr2)
			MSCBSAY(46,70,transform(_pesol,'@E ##.###')+"Kg","R","F",fonte_mlr3)

			MSCBSAY(43,05,"TARA ENV. PRIM./TARA EMB.PRIM.:","R","F",fonte_mlr2)
			MSCBSAY(43,70,transform(_quant * _vTARAP,'@E ##.###')+" Kg","R","F",fonte_mlr2)

			MSCBSAY(40,05,"TARA ENV. SEC./TARA EMB. SEC.:","R","F",fonte_mlr2)
			MSCBSAY(40,70,transform(_vTARAS,'@E ##.###')+" Kg","R","F",fonte_mlr2)

			MSCBSAY(37,05,"TARA TOTAL/TARA TOTAL:","R","F",fonte_mlr2)
			MSCBSAY(37,70,transform(_tara,'@E ##.###')+" Kg","R","F",fonte_mlr2)

			MSCBBOX(36,01,36,180,4)
		endif

		//***************** 4º Bloco da Etiqueta ********************

		MSCBSAY(33,05,_vMENETQ,"R","0",fonte_mlr4)

		MSCBSAY(30,05,ALLTRIM(_GLUTEM)  + " | INDÚSTRIA BRASILEIRA","R","0",fonte_mlr4)

		iif(!empty(_DESCTIPO),MSCBSAY(27,05,_DESCTIPO,"R","0",fonte_mlr4),) // Mensagem do Tipo

		iif(!empty(_Lote) .and. !empty(_predes).and. substr(_predes,1,3) <> 'SIF',MSCBBOX(26,105,36,105,4),)

		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,106,"LOTE:","R","F",fonte_mlr2),)    //Lote
		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,116,_Lote,"R","F",fonte_mlr2),)  //descricao do lote preenchido no lançamento da OP da embalagem

		MSCBSAY(27,70,_SEXO,"R","0",fonte_mlr4) //descrição do sexo. preenche campo MENTETQ4 no cadastro de produtos

		MSCBBOX(26,01,26,180,4)
		MSCBSAY(30,110, _Hora,"R","0",fonte_mlr6)

		//***************** 5º Bloco da Etiqueta ********************

		MSCBSAY(17,05,_desing+_despor,"R","F",fonte_mlr5)

		MSCBSAYBAR(06,62,_control,"R","C",10,.F.,.T.,,,2,1,.T.)

		MSCBBOX(06,92,18,123,80,"B")                                          //Box preto onde fica o cod. do produto
		//MSCBSAYMEMO(03,92,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
		MSCBSAYMEMO(03,88,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
		//MSCBSAY(01,94,"PE:"+_cSeq,"R","0","25,20")
		MSCBSAY(01,88,"PE:"+_cSeq,"R","0","25,20")

		//***************** Bloco RT ********************
		// Inclusão Para impressão Rastreada "RT". Dia 19/09/16 - Flávio	
		iif(AllTrim(_classif) = 'RT',MSCBSAY(36,107,_classif,"R","0",fonte2_1),)
		iif(AllTrim(_classif) == 'RT',iif(!empty(_predes),MSCBSAY(30,05,"RASTREABILIDADE :" + _vRASTRO,"R","0",fonte_mlr4),),) 	// Descrição Rastreabilidade

		MSCBEND()
		MSCBCLOSEPRINTER()

		//******************************** Inicio Etiqueta Da Argentina ******************************\\
	elseif(_etq='A')
		if !empty(_IP)
			MSCBPRINTER(_modelo,'IP',,,,,_IP)	
		else
			MSCBPRINTER(_modelo,_porta)
		endif

		//modelo, 'IP' ,,,,,endereço ip do server de impressao(IP DA ZEBRA)
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(_nNumEtq,6,40)
		// Posição d codigo de barras
		fonte1  :="35,15"
		fonte1_1:="30,15"
		fonte2  :="35,30"
		fonte2_1:="60,60"
		fonte2_2:="25,35"
		fonte2_3:="20,23"
		fonte2_4:="35,30"
		fonte2_5:="25,20" // Trocando até acertar
		fonte3  :="45,15"
		fonte3_1:="40,45"
		f_extra :="30,22"
		fonte3_2:="84,90"
		fonte3_3:="24,15"
		fonte3_4:="45,30"
		fonte4  :="20,5"
		fonte4_1:="18,10"
		fsexo := "50,40"
		fonte5  :="25,25"
		//Novas fontes Criadas por Fabian Maurer - 07/06/12
		fonte_fab1 := "27,15"
		fonte_fab2 := "27,17"
		fonte_fab3 := "50,25"
		fonte_fab4 := "35,20"
		fonte_fab5 := "38,15"
		fonte_fab6 := "10,6"
		//Novas fontes para teste (Mauricio L. Roehrs)
		fonte_mlr1 := "25,10"
		fonte_mlr2 := "15,10"
		fonte_mlr3 := "45,20"
		fonte_mlr4 := "20,18"
		fonte_mlr5 := "60,18"

		//***************** 1º Bloco da Etiqueta ********************

		MSCBSAY(73,85,_control,"R","F",fonte_mlr1) 						//Numero de controle
		MSCBSAY(73,05,_vDESCSIF,"R","F",fonte_mlr2)                 //Descricao em Ingles
		MSCBSAY(69,05,_vDESCING,"R","F",fonte_mlr2)                 //Descricao em Portugues
		MSCBBOX(68,01,68,180,4)                                     //Linha Divisoria

		//***************** 2º Bloco da Etiqueta ********************

		if alltrim(_cod) $ _codExp

			MSCBSAY(64,05,"FECHA DE BENEFICIO:/DATA DE PRODUCAO:","R","F",fonte_mlr2)
			MSCBSAY(64,85,_dtPROD,"R","F",fonte_mlr2)	

		else

			MSCBSAY(64,05,"FECHA DEL PRODUCCION/"+ iif(_cFarm = 'S',"DATA DE PRODUCAO:","DATA DA EMBALAGEM:"),"R","F",fonte_mlr2)
			MSCBSAY(64,85,_dtPROD,"R","F",fonte_mlr2)

			//iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,43,"FECHA DE BENEFICIO:","R","F",fonte_mlr2),)
			//iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,85,_vDTABATE,"R","F",fonte_mlr2),)	
		endif

		MSCBSAY(61,05,"FECHA DEL VENCIMENTO/DATA DE VALIDADE:","R","F",fonte_mlr2)
		MSCBSAY(61,85,_dtVALID,"R","F",fonte_mlr2)

		//MSCBSAY(58,05,"PIEZA/PECA:","R","F",fonte_mlr2)
		//MSCBSAY(58,35,transform(_quant,'@E ######'),"R","F",fonte_mlr2)

		MSCBBOX(57,105,68,105,4)
		MSCBSAY(62,110,_DESTINO,"R","F",fonte_mlr3)

		MSCBBOX(57,01,57,180,4)

		//***************** 3º Bloco da Etiqueta ********************
		if  _cNotImp <> "P"
			_cPb := transform(_pesob,'@E 99.999')
			_cPesob := strtran(_cPb,',','.')
			MSCBSAY(53,05,"PESO BRUTO/PESO BRUTO:","R","F",fonte_mlr2)
			MSCBSAY(53,71,_cPesob + " Kg","R","F",fonte_mlr2)

			_cPl    := transform(_pesol,'@E ##.###')
			_cPesol := strtran(_cPl,',','.')
			MSCBSAY(46,05,"PESO NETO/PESO LIQUIDO:","R","F",fonte_mlr2)
			MSCBSAY(46,70,_cPesol + "Kg","R","F",fonte_mlr3)

			_cTp    := transform(_quant * _vTaraP,'@E ##.###')
			_cTaraP := strtran(_cTp,',','.')
			MSCBSAY(43,05,"TARA DEL EMBALAGE/TARA EMB.PRIM.:","R","F",fonte_mlr2)
			MSCBSAY(43,71,_cTARAP + " Kg","R","F",fonte_mlr2)

			_cTs := transform(_vTaras,'@E ##.###')
			_cTaras := strtran(_cTs,',','.')
			MSCBSAY(40,05,"TARA DE LA CAJA/TARA EMB. SEC.:","R","F",fonte_mlr2)
			MSCBSAY(40,71,_cTARAS + " Kg","R","F",fonte_mlr2)

			_cTa := transform(_tara,'@E #.###')
			_cTara := strtran(_cTa,',','.')
			MSCBSAY(37,05,"TARA TOTAL/TARA TOTAL:","R","F",fonte_mlr2)
			MSCBSAY(37,71,_cTara + " Kg","R","F",fonte_mlr2)

			MSCBBOX(36,01,36,180,4)
		else
			MSCBSAY(53,05,"PESO BRUTO/PESO BRUTO:","R","F",fonte_mlr2)
			MSCBSAY(53,70,transform(_pesob,'@E ##.###')+" Kg","R","F",fonte_mlr2)

			MSCBSAY(46,05,"PESO NETO/PESO LIQUIDO:","R","F",fonte_mlr2)
			MSCBSAY(46,70,transform(_pesol,'@E ##.###')+"Kg","R","F",fonte_mlr3)

			MSCBSAY(43,05,"TARA DEL EMBALAGE/TARA EMB.PRIM.:","R","F",fonte_mlr2)
			MSCBSAY(43,71,transform(_quant * _vTARAP,'@E ##.###')+" Kg","R","F",fonte_mlr2)

			MSCBSAY(40,05,"TARA DELA CAJA/TARA EMB. SEC.:","R","F",fonte_mlr2)
			MSCBSAY(40,71,transform(_vTARAS,'@E ##.###')+" Kg","R","F",fonte_mlr2)

			MSCBSAY(37,05,"TARA TOTAL/TARA TOTAL:","R","F",fonte_mlr2)
			MSCBSAY(37,71,transform(_tara,'@E ##.###')+" Kg","R","F",fonte_mlr2)

			MSCBBOX(36,01,36,180,4)
		endif

		//***************** 4º Bloco da Etiqueta ********************

		MSCBSAY(33,05,_vMENETQ,"R","0",fonte_mlr4)
		
		_cPrdArg := getMv('SI_PRDARG')
			
			If alltrim(_cod) $ _cPrdArg
				MSCBSAY(27,90,'VENTA AL PESO. No Recongelar',"R","0",fonte_mlr4)
			endif

		MSCBSAY(30,05,ALLTRIM(_GLUTEM)  + " | INDÚSTRIA BRASILEIRA","R","0",fonte_mlr4)

		iif(!empty(_DESCTIPO),MSCBSAY(27,05,_DESCTIPO,"R","0",fonte_mlr4),) // Mensagem do Tipo

		iif(!empty(_Lote) .and. !empty(_predes).and. substr(_predes,1,3) <> 'SIF',MSCBBOX(26,105,36,105,4),)

		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,106,"LOTE:","R","F",fonte_mlr2),)    //Lote
		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,116,_Lote,"R","F",fonte_mlr2),)  //descricao do lote preenchido no lançamento da OP da embalagem

		MSCBSAY(27,70,_SEXO,"R","0",fonte_mlr4) //descrição do sexo. preenche campo MENTETQ4 no cadastro de produtos

		MSCBBOX(26,01,26,180,4)
		MSCBSAY(30,110, _Hora,"R","0",fonte_mlr6)

		//***************** 5º Bloco da Etiqueta ********************

		MSCBSAY(17,05,_desing+_despor,"R","F",fonte_mlr5)

		MSCBSAYBAR(06,62,_control,"R","C",10,.F.,.T.,,,2,1,.T.)

		//MSCBBOX(06,92,18,123,80,"B")                                          //Box preto onde fica o cod. do produto
		MSCBBOX(06,88,18,123,80,"B")                                          //Box preto onde fica o cod. do produto
		//MSCBSAYMEMO(03,92,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
		MSCBSAYMEMO(03,88,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
		MSCBSAY(01,94,"PE:"+_cSeq,"R","0","25,20")

		//***************** Bloco RT ********************
		// Inclusão Para impressão Rastreada "RT". Dia 19/09/16 - Flávio	
		iif(AllTrim(_classif) = 'RT',MSCBSAY(36,107,_classif,"R","0",fonte2_1),)
		iif(AllTrim(_classif) == 'RT',iif(!empty(_predes),MSCBSAY(30,05,"RASTREABILIDADE :" + _vRASTRO,"R","0",fonte_mlr4),),) 	// Descrição Rastreabilidade

		MSCBEND()
		MSCBCLOSEPRINTER()	

		//******************************** Inicio Etiqueta Frances ******************************\\

	elseif(_etq='F')
		MSCBPRINTER(_modelo,_porta)
		//MSCBPRINTER(_modelo,'COM3:9600,n,8,1')
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(_nNumEtq,6,40)
		// Posição d codigo de barras
		fonte1  :="35,15"
		fonte1_1:="30,15"
		fonte2  :="35,30"
		fonte2_1:="60,60"
		fonte2_2:="25,35"
		fonte2_3:="20,23"
		fonte2_4:="35,30"
		fonte2_5:="25,20" // Trocando até acertar
		fonte3  :="45,15"
		fonte3_1:="40,45"
		f_extra :="30,22"
		fonte3_2:="84,90"
		fonte3_3:="24,15"
		fonte3_4:="45,30"
		fonte4  :="20,5"
		fonte4_1:="18,10"
		fsexo := "50,40"
		fonte5  :="25,25"
		//Novas fontes Criadas por Fabian Maurer - 07/06/12
		fonte_fab1 := "27,15"
		fonte_fab2 := "27,17"
		fonte_fab3 := "50,25"
		fonte_fab4 := "35,20"
		fonte_fab5 := "38,15"
		fonte_fab6 := "10,6"
		//Novas fontes para teste (Mauricio L. Roehrs)
		fonte_mlr1 := "25,10"
		fonte_mlr2 := "15,10"
		fonte_mlr3 := "45,20"
		fonte_mlr4 := "20,18"
		fonte_mlr5 := "60,18"

		//***************** 1º Bloco da Etiqueta ********************

		MSCBSAY(73,85,_control,"R","F",fonte_mlr1) 						//Numero de controle
		MSCBSAY(73,05,_vDESCFRA,"R","F",fonte_mlr2)                 //Descricao em Ingles
		MSCBSAY(69,05,_vDESCSIF,"R","F",fonte_mlr2)                 //Descricao em Portugues
		MSCBBOX(68,01,68,180,4)                                     //Linha Divisoria

		//***************** 2º Bloco da Etiqueta ********************

		MSCBSAY(64,05,"DATE D' EMBALLAGE/DATA EMBALAGEM:","R","F",fonte_mlr2)
		MSCBSAY(64,70,_dtPROD,"R","F",fonte_mlr2)

		MSCBSAY(61,05,"DATE DE VALIDITE/DATA VALIDADE:","R","F",fonte_mlr2)
		MSCBSAY(61,70,_dtVALID,"R","F",fonte_mlr2)

		//MSCBSAY(58,05,"PIECE/PECA:","R","F",fonte_mlr2)
		//MSCBSAY(58,27,transform(_quant,'@E ######'),"R","F",fonte_mlr2)

		iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,38,"DATE DE PRODUCTION/DATA PRODUCAO:","R","F",fonte_mlr2),)
		iif(!empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(58,77,_vDTABATE,"R","F",fonte_mlr2),)

		MSCBBOX(57,105,68,105,4)
		MSCBSAY(62,110,_DESTINO,"R","F",fonte_mlr3)

		MSCBBOX(57,01,57,180,4)

		//***************** 3º Bloco da Etiqueta ********************

		MSCBSAY(53,05,"POIDS BRUT/PESO BRUTO(Kg):","R","F",fonte_mlr2)
		MSCBSAY(53,70,transform(_pesob,'@E ##.###')+" Kg","R","F",fonte_mlr2)

		MSCBSAY(46,05,"POIDS NET/PESO LIQUIDO(Kg):","R","F",fonte_mlr2)
		MSCBSAY(46,70,transform(_pesol,'@E ##.###')+"Kg","R","F",fonte_mlr3)

		MSCBSAY(43,05,"INTERNAL TARE/TARA EMB.PRIM.:","R","F",fonte_mlr2)
		MSCBSAY(43,70,transform(_vTARAP,'@E ##.###')+" Kg","R","F",fonte_mlr2)

		MSCBSAY(40,05,"TARE/TARA EMB. SEC.:","R","F",fonte_mlr2)
		MSCBSAY(40,70,transform(_vTARAS,'@E ##.###')+" Kg","R","F",fonte_mlr2)

		MSCBSAY(37,05,"TOTAL TARE/TARA TOTAL:","R","F",fonte_mlr2)
		MSCBSAY(37,70,transform(_tara,'@E ##.###')+" Kg","R","F",fonte_mlr2)

		MSCBBOX(36,01,36,180,4)

		//***************** 4º Bloco da Etiqueta ********************

		MSCBSAY(33,05,_vMENETQ,"R","0",fonte_mlr4)

		MSCBSAY(30,05,ALLTRIM(_GLUTEM)  + " | INDÚSTRIA BRASILEIRA","R","0",fonte_mlr4)

		iif(!empty(_DESCTIPO),MSCBSAY(27,05,_DESCTIPO,"R","0",fonte_mlr4),) // Mensagem do Tipo

		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBBOX(26,105,36,105,4),)

		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,106,"LOTE:","R","F",fonte_mlr2),)    //Lote
		iif(!empty(_Lote) .and. !empty(_predes) .and. substr(_predes,1,3) <> 'SIF',MSCBSAY(29,116,_Lote,"R","F",fonte_mlr2),)  //descricao do lote preenchido no lançamento da OP da embalagem

		MSCBSAY(27,70,_SEXO,"R","0",fonte_mlr4) //descrição do sexo. preenche campo MENTETQ4 no cadastro de produtos

		MSCBBOX(26,01,26,180,4)
		MSCBSAY(30,110, _Hora,"R","0",fonte_mlr6)

		//***************** 5º Bloco da Etiqueta ********************

		MSCBSAY(17,05,_desfra+_despor,"R","F",fonte_mlr5)

		MSCBSAYBAR(06,62,_control,"R","C",10,.F.,.T.,,,2,1,.T.)

		//MSCBBOX(06,92,18,123,80,"B")                                          //Box preto onde fica o cod. do produto
		MSCBBOX(06,88,18,123,80,"B")                                          //Box preto onde fica o cod. do produto

		MSCBSAYMEMO(03,88,58,1,alltrim(_cod),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto
		MSCBSAY(01,94,"PE:"+_cSeq,"R","0","25,20")

		MSCBEND()
		MSCBCLOSEPRINTER()

	endif
return .t.


//FUNÇÃO DESTINADA PARA ETIQUETADORA DA DIMEL Linha 4 automática
//MODIFICAÇÃO DO LAYOUT DE IMPRESSÃO para EXPORTACAO URUGUAY
User Function GJF111v(_modelo,_porta,_control,_cod,_pesob,_pesol,_tara,_datap,_dataval,_nNumEtq,_lote,_IP,_hora)
	/*                     1     2      3      4     5      6      7      8     9        10       11   12   13
	Paremetros da função
	1  - modelo da impressora
	2  - porta
	3  - sequencial da caixa
	4  - codigo do produto
	5  - peso bruto
	6  - peso liquido
	7  - tara
	8  - data de produção
	9 - data de validade
	10 - numero de etiquetas a serem impressas
	11 - Lotes
	12 - Endereço IP para conexão ethernet
	13 - Hora de impressão
	*/

	local _vDESCES  := ''
	local _vDINGLES := ''
	local _vDESCING := ''
	local _vDFRANCES:= ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vDESCFRA := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _vTARAP   := 0.00
	local _vTARAS   := 0.00
	local _vMENETQ  := ''
	local _vFAM     := ''
	local _DESTINO  := ''
	local _DESCTIPO := ''
	local _GLUTEM   := ''
	local _vDTABATE := ''
	local _vRASTRO  := ''
	local _desing   := ''
	local _desfra   := ''  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	local _despor   := ''
	local _descFAM  := ''
	local _dtPROD   := ''
	local _dtVALID  := ''
	local _nTS      := ''
	local _nTP      := ''
	local _classif  := ''	
	local _cPesol   := strtran(cValtoChar(_pesol),'.','')

	DbselectArea('SB1')
	SB1->(dbsetorder(1))
	if SB1->(Msseek(Fwxfilial('SB1')+alltrim(_cod)))
		_vDINGLES := SB1->B1_DESCING //os dois campos abaixo estao invertidos de proposito para não
		_vDESCING := SB1->B1_DINGLES //precisar mexer no layout de impressao - B1_DINGLES é a do SIF
		_vDFRANCES:= SB1->B1_DESCFRA  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
		_vDESCFRA := SB1->B1_DFRANCE //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
		_vDESCES  := SB1->B1_DESCESP // e o B1_DESCING a descrição em ingles do produto
		_vDESCSIF := SB1->B1_DESCSIF
		_nTS      := SB1->B1_CTARASE
		_nTP      := SB1->B1_CTARAP  // Incluido por Fabian Maurer - 08/05/2012 - nao estava pegando certo a tara primaria
		_nCodBar  := SB1->B1_CODBAR
		_nCdBarcli := SB1->B1_EANCLI
		_nPesFix  := SB1->B1_PESFIX
		_quant    := SB1->B1_QCAIX

		_cGrupo   := SB1->B1_GRUPO
		_cFarm    := GetAdvFVal('SBM','BM_FARM',Fwxfilial('SBM')+_cGrupo,1)

		ZAB->(DbSetOrder(1))
		if ZAB->(MsSeek(Fwxfilial('ZAB')+alltrim(_nTS)))
			_vTARAS   := ZAB->ZAB_TARA
		endif

		if ZAB->(MsSeek(Fwxfilial('ZAB')+alltrim(_nTP)))
			_vTARAP   := ZAB->ZAB_TARA
		endif

		_vMENETQ  := SB1->B1_MENETQ1
		_vFAM     := SB1->B1_FAM
		_DESTINO  := SB1->B1_DESTINO
		_DESCTIPO := SB1->B1_MENETQ2
		_GLUTEM   := SB1->B1_MENETQ3
		_ROTULO   := SB1->B1_MENETQ4
	endif

	dbSelectArea('ZAU')
	ZAU->(DbSetOrder(1))
	if ZAU->(MsSeek(FwxFilial('ZAU') + alltrim(_lote)))
		_vDTABATE := dtoc(ZAU->ZAU_DTABAT)//aviso de matança formatado em string . 
	endif

	_desing  := alltrim(_vDINGLES)
	_desfra  := alltrim(_vDFRANCES)  //Campo feito por Fabian Maurer para etiqueta da França - 27/02/12
	_despor  :=  substr(alltrim(SB1->B1_DESC),1,18)

	DbSelectArea('SX5')
	_descFAM := GetAdvFVal('SX5','X5_DESCRI',Fwxfilial("SX5")+'PS'+_vFAM,1)
	_dtPROD  := dtoc(_datap)
	_dtVALID := dtoc(_dataval) //data da produção

	//*************************** Etiqueta Padrão  ************************************************

	_linP := -20

	MSCBPRINTER(_modelo,_porta,,,,,_IP)

	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(_nNumEtq,6,40)
	// Posição d codigo de barras
	fonte1  :="40,20"
	fonte1_1:="30,15"
	fonte1_2:="85,85" //100/50
	fonte1_3:="38,12"
	fonte2  :="35,30"
	fonte2_1:="100,100"
	fonte2_2:="25,35"
	fonte2_3:="20,23"
	fonte2_4:="35,30"
	fonte2_5:="25,20" // Trocando até acertar
	fonte3  :="35,12"//42
	fonte3_1:="40,45"
	f_extra :="30,22"
	fonte3_2:="84,90"
	fonte3_3:="24,15"
	fonte3_4:="45,30"
	fonte3_5 := "70,55"
	fonte4  :="20,5"
	fonte4_1:="16,8"
	fsexo   :="65,50"
	fonte4_2:="120,65"
	fonte5  :="25,25"
	fonte5_1 := "20,18"
	fonte_fab7 := "70,40"
	_pos := 20

	//verificado se no cadastro do produto está preenchido o peso fixo do produto
	//se estiver recalcula os dados da etiqueta
	if _nPesFix <> 0		
		_pesol := _nPesFix		
		_pesob := _nPesFix + _tara			
	endif

		//******************* 1º Bloco da Etiqueta ************************

		_cDescSIF :=  substr(_vDESCSIF,1,35)

		MSCBSAY(8,10,_control,"B","0",fonte2_2)         	//numero de controle
		MSCBSAY(11,24,substr(_cDescSIF,1,35),"B","0",fonte2_2)  //descrição em espanhol
		MSCBSAY(14,23,_vDESCING,"B","0",fonte2_2)  					//descrição do SIF

		MSCBLineV(20,01,100,4,"B")                  //Linha Divisoria

		//******************* 2º Bloco da Etiqueta ************************

		MSCBSAY(21,43,"FECHA DE ENVASE:","B","0",fonte2_2)   //data de Embalagem
		MSCBSAY(21,16,_dtPROD,"B","0",fonte2_2)

		MSCBSAY(24,43,"FECHA DE PRODUCCION:","B","0",fonte2_2)   //data de produção
		MSCBSAY(24,16,_dtPROD,"B","0",fonte2_2)

		MSCBSAY(27,43,"FECHA DE VATIDAD:","B","0",fonte2_2)   //data de validade - Alterado por Fabian Maurer - 02/05/12 - Correção Escrita
		MSCBSAY(27,16,_dtVALID,"B","0",fonte2_2)

		MSCBLineH(20,14,36,4,"B")                  //Linha Divisoria
		MSCBSAY(24,06,substr(_DESTINO,1,2),"B","0",fonte3_5)     // Destino do produto (mover para outro lugar)

		//******************* 3º Bloco da Etiqueta ************************

		MSCBLineV(36,01,100,4,"B")

		_cPb    := transform(_pesob,'@E 99.999')
		_cPesob := strtran(_cPb,',','.')
		MSCBSAY(38,43,"PESO BRUTO/PESO BRUTO:","B","0",fonte2_2) //peso bruto da caixa
		MSCBSAY(38,16,_cPesob,"B","0",fonte2_2)

		_cPl    := transform(_pesol,'@E ##.###')
		_cPesol := strtran(_cPl,',','.')
		MSCBSAY(47,43,"PESO NETO/PESO LIQUIDO(Kg):","B","0",fonte2_2)
		MSCBSAY(43,16,_cPesol,"B","0",fonte3_5)   //peso liquido da caixa

		_cTp    := transform(_quant * _vTaraP,'@E ##.###')
		_cTaraP := strtran(_cTp,',','.')
		MSCBSAY(51,28,"TARA ENV. PRIM./TARA EMB.PRIM.(Kg):","B","0",fonte2_2) //tara primaria
		MSCBSAY(51,16,_cTARAP,"B","0",fonte2_2)

		_cTs    := transform(_vTaras,'@E ##.###')
		_cTaras := strtran(_cTs,',','.')
		MSCBSAY(54,32,"TARA ENV. SEC./TARA EMB SEC.(Kg):","B","0",fonte2_2) //tara secundaria
		MSCBSAY(54,16,_cTARAS,"B","0",fonte2_2)

		_cTa := transform(_tara,'@E #.###')
		_cTara := strtran(_cTa,',','.')
		MSCBSAY(57,32,"TARA TOTAL/TARA TOTAL(Kg):","B","0",fonte2_2)   //tara total da caixa
		MSCBSAY(57,16,_cTara,"B","0",fonte2_2)

		MSCBLineV(60,01,100,4,"B")

		//******************* 4º Bloco da Etiqueta ************************

		MSCBLineV(76,01,100,4,"B")
		iif(!empty(_DESCTIPO),MSCBSAY(78,52,_DESCTIPO,"B","B",fonte4_1),)    //mensagem da temperatura

		MSCBSAYBAR(80,27,_control,"B","C",10,.F.,.T.,,,2,1,.T.)  //numero do controle da caixa   código de barras
		MSCBSAY(80,03,alltrim(_cod),"B","0",fonte4_2)

		MSCBSAY(85,60,substr(_despor,1,18),"B","B",fonte3)

		MSCBSAY(65,20,_Hora,"B","B",fonte4)

		iif(!empty(_GLUTEM),MSCBSAY(90,78,_GLUTEM,"B","B",fonte4_1),)   //Mensagem do Glutem B1_MENETQ3

		//MSCBSAY(92,85,'lote: ' + alltrim(_lote),"B","B",fonte4_1)  //LOTE
		MSCBSAY(92,78,'lote: ' + alltrim(_lote),"B","B",fonte4_1)  //LOTE

		iif(AllTrim(_classif) = 'RT',MSCBSAY(42,107,_classif,"R","0",fonte2_1),)
		iif(AllTrim(_classif) == 'RT',iif(!empty(_predes),MSCBSAY(29,05,"RASTREABILIDADE :" + _vRASTRO,"R","0",fonte4_2),),)

		MSCBSAY(94,15,"REGISTRO NO MINISTERIO DA AGRICULTURA SIF/DIPOA SOB N "+alltrim(_ROTULO),"B","B",fonte4_1)
		/*   Futuramente vamos implantar o ena14 */

	MSCBEND()
	MSCBCLOSEPRINTER()

return  .t.


//MODIFICAÇÃO DO LAYOUT DE IMPRESSÃO para EXPORTACAO URUGUAY
User Function GJF111x(_cContro)

	Dbselectarea('ZAS')
	ZAS->(DbSetOrder(1))
	ZAS->(MsSeek(Fwxfilial('ZAS')+alltrim(_cContro)))

	Dbselectarea('SB1')
	SB1->(dbsetorder(1))
	SB1->(Msseek(Fwxfilial('SB1')+alltrim(ZAS->ZAS_COD)))

	_desing  := alltrim(SB1->B1_DESCING)	
	_despor  := alltrim(SB1->B1_DESCRED)         //Descrição reduzida em portugues
	_cFamRX  := alltrim(SB1->B1_FAMRX)

	_cIp  := ''
	_cEst := getComputerName()
	dbselectarea('ZAM')
	ZAM->(dbSetOrder(2))
	if ZAM->(MsSeek(FwxFilial('ZAM') + alltrim(_cEst)))
		_cIp := alltrim(ZAM->ZAM_IP)
	endif

	if empty(_cIp)
		MSCBPRINTER('S600','LPT1')
	else
		MSCBPRINTER('S600','IP',,,,,_cIp) //Impressão por IP
	endif

	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(1,4,50)
	fDesc2_1		:=  "60,33"
	fDesc2_2		:=  "90,60"
	fDesc2_3		:=  "70,50"
	fDesc2_4		:=  "150,100"
	fonte_mlr2 		:= 	"15,10"

	MSCBBOX(18,01,18,125,4)  											// Linha Divisoria
	MSCBSAY(14,04,_desing+_despor,"R","F",fonte_mlr2) 	

	MSCBSAY(02,07,alltrim(substr(ZAS->ZAS_STRRX,37,14)) ,"R","0",fDesc2_2)	
	MSCBSAYBAR(07,62,alltrim(ZAS->ZAS_CONTRO),"R","C",10,.F.,.T.,,,2,1,.T.)  			// Numero do controle da caixa código de barras		
	MSCBSAYMEMO(2,88,58,1,alltrim(ZAS->ZAS_COD),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto da caixa original

	MSCBEND()
	MSCBCLOSEPRINTER()

Return  .t.


User Function GJF111w(_cContro,_ctabela)

	_cIp  := ''
	_cEst := getComputerName()
	dbselectarea('ZAM')
	ZAM->(dbSetOrder(2))
	
	if ZAM->(MsSeek(FwxFilial('ZAM') + alltrim(_cEst)))
		_cIp := alltrim(ZAM->ZAM_IP)
	endif

	if empty(_cIp)
		MSCBPRINTER('S600','LPT1')
	else
		MSCBPRINTER('S600','IP',,,,,_cIp) //Impressão por IP
	endif
	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(1,4,50)
	fDesc2_1		:=  "60,33"
	fDesc2_2		:=  "90,60"
	fDesc2_3		:=  "70,50"
	fDesc2_4		:=  "150,100"
	fonte_mlr2 		:= 	"15,10"
	MSCBBOX(18,01,18,125,4)  // Linha Divisoria

	if _ctabela = 'SZ8'
		Dbselectarea('SZ8')
		SZ8->(DbSetOrder(3))
		SZ8->(MsSeek(Fwxfilial('SZ8')+alltrim(_cContro)))	

		Dbselectarea('SB1')
		SB1->(dbsetorder(1))
		SB1->(Msseek(Fwxfilial('SB1')+alltrim(SZ8->Z8_COD)))
		_desing  := alltrim(SB1->B1_DESCING)	
		_despor  := alltrim(SB1->B1_DESCRED)         //Descrição reduzida em portugues
		_cFamRX  := alltrim(SB1->B1_FAMRX)

		MSCBSAY(14,04,_desing+_despor,"R","F",fonte_mlr2) 	

		MSCBSAY(02,07,alltrim(substr(SZ8->Z8_STRRX,37,14)) ,"R","0",fDesc2_2)	
		MSCBSAYBAR(07,62,alltrim(SZ8->Z8_CONTROL),"R","C",10,.F.,.T.,,,2,1,.T.)  			// Numero do controle da caixa código de barras		
		MSCBSAYMEMO(2,88,58,1,alltrim(SZ8->Z8_COD),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto da caixa original

		MSCBEND()
		MSCBCLOSEPRINTER()

	Elseif _ctabela = 'ZAS'
		Dbselectarea('ZAS')
		ZAS->(DbSetOrder(1))
		ZAS->(MsSeek(Fwxfilial('ZAS')+alltrim(_cContro)))

		Dbselectarea('SB1')
		SB1->(dbsetorder(1))
		SB1->(Msseek(Fwxfilial('SB1')+alltrim(ZAS->ZAS_COD)))

		_desing  := alltrim(SB1->B1_DESCING)	
		_despor  := alltrim(SB1->B1_DESCRED)         //Descrição reduzida em portugues
		_cFamRX  := alltrim(SB1->B1_FAMRX)

		MSCBSAY(14,04,_desing+_despor,"R","F",fonte_mlr2) 	

		MSCBSAY(02,07,alltrim(substr(ZAS->ZAS_STRRX,37,14)) ,"R","0",fDesc2_2)	
		MSCBSAYBAR(07,62,alltrim(ZAS->ZAS_CONTRO),"R","C",10,.F.,.T.,,,2,1,.T.)  			// Numero do controle da caixa código de barras		
		MSCBSAYMEMO(2,88,58,1,alltrim(ZAS->ZAS_COD),"R","0","110,80",.t.,"J")  		// Numero do codigo do produto da caixa original

		MSCBEND()
		MSCBCLOSEPRINTER()

	endif

Return  .t.
