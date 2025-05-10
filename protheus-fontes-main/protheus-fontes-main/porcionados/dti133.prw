#INCLUDE "rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "apvt100.ch"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI133    º Autor ³Mateus Escobarº Data ³  06/10/2021   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao de etiqueta para Refile com etiqueta do Abateº±±
±±º          ³produção do Refile                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Porcionados                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DTI133(_modelo,_porta,_ip,_cControl)
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
     
	 _nPeso   := 0.00	 
	_Fonte01 	:= "43,15"
	_Fonte02 := "37,12"

		//************************Impressão das Etiquetas***************************
		
	_linP := -20

	MSCBPRINTER('S600','IP',,,,,_Ip)
	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(1,6)

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
	//Fontes (Mateus Escobar)
	_Fonte01 := "43,15"
	_Fonte02 := "37,12"
	_Fonte03 := "55,20"
	
	ZAS->(dbSetOrder(1))
	ZAS->(dbGoTop())
	if ZAS->(dbSeek(xFilial('ZAS') + _cControl))
 
		_cProd 	  := ZAS->ZAS_COD
		_cDscPrd  := ZAS->ZAS_DESC
		_dDtProd  := ZAS->ZAS_DTPROD
		_dDtValid := IIF(!Empty(ZAS->ZAS_DTABAT),ZAS->ZAS_DTABAT + ZAS->ZAS_VALID,ZAS->ZAS_DTPROD + ZAS->ZAS_VALID)
		_dDtValidTer := ZAS->ZAS_DTABAT + ZAS->ZAS_VALID
		_dDtProdTer  := ZAS->ZAS_DTABAT
		_nPesoL   := ZAS->ZAS_PESOL
		_nPesoB   := ZAS->ZAS_PESOB
		_nTara    := ZAS->ZAS_TARA
		_cTerc    := ZAS->ZAS_TERC
		_cPreemb  := ZAS->ZAS_PREEMB
		_cTipo 	  := ZAS->ZAS_TIPO
		_cPrepor  := ZAS->ZAS_PREPOR
		_cLote    := ZAS->ZAS_LOTE
		_cDestin  := ZAS->ZAS_DESTIN
		_cDescDest := fBuscaCpo('SX5',1,xFilial('SX5')+'ZP'+_cDestin,'X5_DESCRI')
		_dtAbate  := ZAS->ZAS_DTABAT
			
			//******************* 1º Bloco da Etiqueta ************************
	    MSCBSAY(58,47,_cControl,"R","F",_Fonte02) 						//Numero de controle	era85

		MSCBSAY(50,06,_cDscPrd,"R","F",_Fonte01)                 //Descricao em Portugues
		
		
		MSCBBOX(48,4,48,69)
		MSCBBOX(1,69,200,69) //barra do meio
		//***************** 2º Bloco da Etiqueta ********************

		  if _cTerc <> 'S'
			MSCBSAY(43, 6,'DATA DA EMBALAGEM:',"R","F",_Fonte02)
			MSCBSAY(43,43,dtoc(_dDtProd),"R","F",fonte_mlr2)
			
			MSCBSAY(38, 6,'DATA DE VALIDADE:',"R","F",_Fonte02)
			MSCBSAY(38,43,dtoc(_dDtValid),"R","F",fonte_mlr2)
			
			MSCBSAY(32, 6,"DATA DE PRODUCAO:","R","F",_Fonte02) 				
			MSCBSAY(32, 43,dtoc(_dDtProdTer),"R","F",_Fonte02)

        else
		 	MSCBSAY(38, 6,"DATA DE VALIDADE:","R","F",_Fonte02)
			MSCBSAY(38, 43,dtoc(_dDtValidTer),"R","F",_Fonte02)

		 	MSCBSAY(32, 6,"DATA DE PRODUCAO:","R","F",_Fonte02) 				
			MSCBSAY(32, 43,dtoc(_dDtProdTer),"R","F",_Fonte02) 
        endif
		    MSCBBOX(30,4,30,69)					
	     
		//***************** 3º Bloco da Etiqueta ********************


		MSCBSAY(26, 6,'PESO BRUTO:',"R","F",_Fonte02) 
		MSCBSAY(26,43,transform(_nPesob,'@E #,###.###')+" kg","R","F",_Fonte02)

		MSCBSAY(19, 6,'PESO LIQUIDO:',"R","F",_Fonte02)
		MSCBSAY(15,35,transform(_nPesol,'@E #,###.###')+"kg","R","F",_Fonte03)

		MSCBSAY(6, 6,'TARA:',"R","F",_Fonte02)
		MSCBSAY(6,43,transform(_nTara,'@E ##.###')+" kg","R","F",_Fonte02)

		//***************** 4º Bloco da Etiqueta ********************

		//se o tipo do produto for MP ou PA		                 
		if !empty(_cTipo) .and. (_cTipo $ 'MP/PA' )
			if !empty(_cPrepor)
				MSCBSAY(46,71,"PREV. PORCIONADOS:","R","F",_Fonte01)
				MSCBSAY(46,107,_cPrepor,"R","F",_Fonte01)		
			endif                 

			if !empty(_cTerc)		                                          
				MSCBSAY(39,71,"TERCEIRO:","R","F",_Fonte01)
				MSCBSAY(39,92,iif(_cTerc = 'S', 'SIM','NAO'),"R","F",_Fonte01)
			endif

			if !empty(_cPreEmb)
				MSCBSAY(39,124,"PREV. EMB.:","R","F",_Fonte01)
				MSCBSAY(39,146,_cPreEmb,"R","F",_Fonte01)					
			endif	                      

			
			if !empty(_cTipo)
				MSCBSAY(54,71,"TIPO:","R","F",_Fonte01)
				MSCBSAY(54,81,iif(_cTipo = 'MP', 'MAT. PRIMA',iif(_cTipo = 'PA','PROD. ACABADO',iif(_cTipo = 'QR','QUEBRA REFIL.',iif(_cTipo = 'QF', 'QUEBRA FATIAD','PROD EM PROCES')))),"R","F",_Fonte01)					
			endif	                                                         

		    else//senão será QR, QF ou PP
			if !empty(_cLote)
				MSCBSAY(49,71,"LOTE DE PRODUCAO:","R","F",_Fonte01)
				MSCBSAY(49,103,_cLote,"R","F",_Fonte01)						
			endif		

			if !empty(_cTipo)
				MSCBSAY(37,71,"TIPO DE PRODUTO:","R","F",_Fonte01)
				MSCBSAY(37,103,iif(_cTipo = 'QR','QUEBRA REFILE',iif(_cTipo = 'QF', 'QUEBRA FATIADORA','CARNE REFILADA')),"R","F",_Fonte01)					
			endif	           

		endif			

		 MSCBBOX(38,69,38,200)     
 

		//***************** 5º Bloco da Etiqueta ********************

		if !empty(_cDestin)
			// Ajuste inclusão Destino "Moida" conforme pedido Lucineia dia 12/07/2016 - Flávio Fez
			MSCBSAY(29,71,"DESTINO:"+ iif(_cDestin = 'M1','MOIDA PRIM.',iif(_cDestin = 'M2', 'MOIDA SEGUN.',iif(_cDestin = 'TU', 'TUBETE', iif(_cDestin = 'GR','GRAXARIA','')))),"R","F",_Fonte01)
			MSCBSAY(29,71,"DESTINO:"+ iif(_cDestin = 'M1','MOIDA PRIM.',iif(_cDestin = 'M2', 'MOIDA SEGUN.',iif(_cDestin = 'M3', 'MOIDA',iif(_cDestin = 'TU', 'TUBETE', iif(_cDestin = 'GR','GRAXARIA',''))))),"R","F",_Fonte01)
			MSCBSAY(29,71,"DESTINO: " + alltrim(_cDescDest),"R","F",_Fonte01)
		else
			MSCBSAY(29,71,_cDscPrd,"R","F",_Fonte01) 				
		endif


			MSCBSAYBAR(06,94,_cControl,"R","C",13,.F.,.T.,,,3,1,.T.) 
		
			MSCBBOX(04,142,18,177,80,"B") //Box preto onde fica o cod. do produto
			MSCBSAYMEMO(06,147,58,1,alltrim(_cProd),"R","F",_Fonte03,.t.,"J") //código do produto
				
	endif	
		
		MSCBEND()
		MSCBCLOSEPRINTER()


RETURN .t.




