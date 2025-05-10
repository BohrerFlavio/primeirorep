#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

#INCLUDE "vkey.ch"
#INCLUDE "colors.ch"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI158            º Autor ³ Lucas Bolzan º Data ³ 15/12/22  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao de etiqueta interna MI e ME                      º±±
±±º          ³ Best Beef,Novilho, Angus e Hereford                        º±±
±±º          ³ Substitui FBF01, DTI41 e DTI91                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Costela/Desossa/Porcionados                                º±±
±±ºUso       ³ OBS- Fonte nosso aqui 02/05/23                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER FUNCTION DTI158()
	//PARAMETROS COM CODIGO DOS USUÁRIOS QUE PODEM IMPRIMIR ETIQUETAS COM DATAS DIFERENTES A DATABASE
	Private _cUsrEtq  := getMv('SI_USRETQ') //parametro com os codigos dos usuarios que podem imprimir ETQ interna com data maior que DATABASE
	Private _cUsrPorc := getMv('SI_ETQPRC') //parametro com os codigos de usuarios que podem imprimir com um intervalo de datas bem grande
	Private _cCodUser := retCodUsr()
	Private _cOper    := UsrRetName(_cCodUser)
	Private _cProdMDS := GetMV('MV_GRPMDS')
	Private _cProdPORC := GetMV('MV_GRPPORC')
	Private _cProdCharque := GetMV('MV_GRPCHRQ')

    Dbselectarea('SB1')
	Dbsetorder(1)
	DbSelectArea('ZAB')
	ZAB->(dbsetorder(1))

	//VARIAVEIS DOS CAMPOS ONDE VALORES SERÃO INSERIDOS
	campoCodProduto  := Space(6)
	campoDataProducao   := SToD("")
	campoDataAbate   := SToD("")
	campoDescCorte := Space(40)
	campoTara := 0
	campoQtdCaixas :=0
	campoQtdEtiquetas :=0
	cpLotePrd := space(25)
	oLotePrd := nil
	oSay := nil
	_cTPCadMerc := ''
	valor1 	:= Space(6)   	// Codigo do Produto	
	valor2 	:= SToD("")   	// Data de Abate
	valor7 	:= SToD("")     // Data de Produção
	valor3 := Space(40)	  	// Descrição do Corte
	valor4 := 0.000	      	// Tara
	valor5 := 0 			//Quantidade de Caixas
	valor6 := 0 			//Quantidade de Etiquetas
	cLotePrd := space(25)

	//PARAMETROS COM CODIGO DOS PRODUTOS TEM INFORMAÇÕES DE TABELA NUTRICIONAL OCULTA
	_cParTabNut := GetMV( 'MV_PARTNEI' )

	IF alltrim(_cCodUser) $ _cUsrEtq
		_dDTMaior   := date() + 7
		_dDTMenor	:= date() - 7

	ELSEIF alltrim(_cCodUser) $ _cUsrPorc
		_dDTMaior   := date() + 365
		_dDTMenor	:= date() - 365

	ELSE
		_dDTMaior   := date()
		_dDTMenor	:= date() - 7
	ENDIF

	//CRIA A INTERFACE GRAFICA
	DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "IMPRESSAO DE ETIQUETA INTERNA"
	
	InterfaceGrafica()

	@ 200,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action Imprime()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()
	
	ACTIVATE MSDIALOG telaimp CENTERED
RETURN

STATIC FUNCTION Imprime()

	Processa({||ETIQUETA() },"IMPRESSAO DE ETIQUETA","Realizando envio à impressora...")

RETURN

STATIC FUNCTION Clear()

	valor1 	:= Space(6)
	valor2 	:= date()
	valor3 := Space(40)
	valor4 := 0.000
	valor5 := 0
	valor6 := 0
	cpLotePrd := space(25)

	telaimp:refresh()
RETURN

STATIC FUNCTION ETIQUETA()
	LOCAL _DtAbt   := valor2

	DbSelectArea('ZAB')
	ZAB->(dbsetorder(1))

	_cCodTar := GetAdvFval('SB1','B1_CTARAP',FWxFilial('SB1') + alltrim(valor1),1)
	_cCodGrpProd := GetAdvFval('SB1','B1_GRUPO',FWxFilial('SB1') + alltrim(valor1),1)
	_nValTar := GetAdvFval('ZAB','ZAB_TARA',FWxFilial('ZAB') + _cCodTar,1)
	_cTPMerc := GetAdvFval('SB1','B1_DESTINO',FWxFilial('SB1') + alltrim(valor1),1)
    _cTPCadMerc := GetAdvFval('SB1','B1_CADMERC',FWxFilial('SB1') + alltrim(valor1),1)

	btn1:disable()
	telaimp:refresh()

	ProcRegua(valor5)

	DbSelectArea('SB1')
	SB1->(dbsetorder(1))
	DbSelectArea('ZZ7')
	ZZ7->(dbsetorder(1))
	DbSelectArea('SZ2')	
	SB1->(dbSeek(FWxfilial('SB1')+ valor1))
	ZZ7->(dbSeek(FWxfilial('ZZ7')+ valor1))	

	//CONDIÇÃO PARA VERIFICAR SE PRODUTO FOR DO MIUDOS OU FOR DA EMBALAGEM
	IF(alltrim(_cCodGrpProd) $ _cProdMDS)
		_DtVal  := valor2 + SB1->B1_VALID
	ELSE
		_DtVal  := valor7 + SB1->B1_VALID
	ENDIF

	_DtEmb := valor7
	_nQtdCx := GetAdvFval('SB1','B1_QCAIX',FWxFilial('SB1') + alltrim(valor1),1)
	_nQetq  := _nQtdCx * valor5
	valor6  := _nQetq

	incproc()

	_cEst := getComputerName()
	_cIp  := ''

	//U_QtPrev(alltrim(valor3),valor2,valor1,valor7)
	_cCadasM := GetAdvFVal('SB1','B1_CADMERC',FWXFilial('SB1')+AllTrim(valor1),1)
	IF (_cCadasM <> "U")
		U_QtPrev(alltrim(valor3),valor2,valor1,valor7)
	ENDIF

	dbselectarea('ZAM')
	ZAM->(dbSetOrder(2))
	if ZAM->(dbSeek(FWxFilial('ZAM') + alltrim(_cEst)))
		_cIp := alltrim(ZAM->ZAM_IP)
	endif

	if empty(_cIp)
		MSCBPRINTER('S600','LPT1')
	else
		MSCBPRINTER('S600','IP',,,,,_cIp) //Impressão por IP
	endif

	//COMEÇO DA CONSTRUÇÃO DOS BLOCOS A SEREM IMPRESSOS NA ETIQUETA 
	MSCBBEGIN(_nQetq,6,15)	// Usar variavel no primeiro campo, para a quantidade de etiquetas

	//DEFINE TAMANHO DOS TIPOS DE FONTES
	fonteTipoA_1 := "17.99"
	fonteTipoA_2 := "17.50"
	fonteTipoA_3 := "17.00"

	fonteTipoB_1 := "18.99"
	fonteTipoB_2 := "18.50"
	fonteTipoB_3 := "18.00"

	fonteTipoC_1 := "19.99"
	fonteTipoC_2 := "19.50"
	fonteTipoC_3 := "19.00"

	fonteTipoD_1 := "20.99"
	fonteTipoD_2 := "20.50"
	fonteTipoD_3 := "20.00"

	fonteTipoE_1 := "21.99"
	fonteTipoE_2 := "21.50"
	fonteTipoE_3 := "21.99"

	fonteTipoF_1 := "22.99"
	fonteTipoF_2 := "22.50"
	fonteTipoF_3 := "22.00"

	fonteTipoG_1 := "23.99"
	fonteTipoG_2 := "23.50"
	fonteTipoG_3 := "23.00"

	fonteTipoH_1 := "24.99"
	fonteTipoH_2 := "24.50"
	fonteTipoH_3 := "24.00"

	fonteTipoI_1 := "25.99"
	fonteTipoI_2 := "25.50"
	fonteTipoI_3 := "25.00"

	// Se For Mercado Interno
	IF (_cTPMerc = "MI" .or. (_cTPMerc = "ME" .and. _cTPCadMerc = ' '))

		MSCBSAY(1,6,ZZ7->ZZ7_DESC,"N","0",fonteTipoG_1)
		MSCBSAY(10,10,ZZ7->ZZ7_CORTE,"N","0",fonteTipoG_1)			
		MSCBSAY(1,14,SB1->B1_MENETQ2,"N","0",fonteTipoE_1)
		//CONDIÇÃO PARA VERIFICAR SE PRODUTO FOR DO MIUDOS OU FOR DA EMBALAGEM
		IF(alltrim(_cCodGrpProd) $ _cProdMDS)
			MSCBSAY(1,18,"DATA DE ABATE/PRODUCAO/LOTE","N","0",fonteTipoC_1)
			MSCBSAY(1,21,"DATA DA EMBALAGEM","N","0",fonteTipoC_1)
		ELSE
			/*
			if !(alltrim(_cCodGrpProd) $ _cProdPORC)
				MSCBSAY(1,18,"DATA DE ABATE","N","0",fonteTipoC_1)
				//alert('Linha 220')
			endif
			if !(alltrim(_cCodGrpProd) $ _cProdCharque)
				MSCBSAY(1,18,"DATA DE ABATE","N","0",fonteTipoC_1)
				alert('Linha 224')
			endif
			*/
			
			//if !(alltrim(_cCodGrpProd) $ _cProdPORC) .or. !(alltrim(_cCodGrpProd) $ _cProdCharque)
			if (alltrim(_cCodGrpProd) $ _cProdPORC) .or. (alltrim(_cCodGrpProd) $ _cProdCharque)
				
				//Sistema não deve imprimir a descrição da DATA DE ABATE.
			else
				MSCBSAY(1,18,"DATA DE ABATE","N","0",fonteTipoE_1)
				//alert('Linha 235 - Entrou aqui')
			endif
			MSCBSAY(1,21,"DATA DE PRODUÇÃO/LOTE","N","0",fonteTipoE_1)
		ENDIF

		//if !(alltrim(_cCodGrpProd) $ _cProdPORC)
		if (alltrim(_cCodGrpProd) $ _cProdPORC) .or. (alltrim(_cCodGrpProd) $ _cProdCharque)
			/*Sistema não deve imprimir a descrição da DATA DE ABATE.*/
		Else
			MSCBSAY(37,18,DtoC(_DtAbt),"N","0",fonteTipoE_1)
		endif
		MSCBSAY(37,21,DToC(_DtEmb),"N","0",fonteTipoE_1)
		MSCBSAY(1,24,"DATA DE VALIDADE","N","0",fonteTipoE_1)
		MSCBSAY(37,24,DtoC(_DtVal),"N","0",fonteTipoE_1)
		MSCBSAY(1,27,"PESO DA EMBALAGEM:","N","0",fonteTipoE_1)
		MSCBSAY(37,27,transform(valor4,'@E 99') + "g","N","0",fonteTipoE_1)
		MSCBSAY(1,37,"REGISTRO NO MINISTERIO DA AGRICULTURA SIF/DIPOA","N","0",fonteTipoC_1)
		MSCBSAY(20,40,"SOB N" + ZZ7->ZZ7_MSIF,"N","0",fonteTipoC_1)
		//MSCBSAY(1,30,"SIF de Origem XXXXXX","N","0",fonteTipoF_1)
		//MSCBSAY(1,33,alltrim(ZZ7->ZZ7_OBS),"N","0",fonteTipoA_1)
		/*													RETIRADO A PEDIDO DO CHAMADO 3500
		IF !(alltrim(valor1) $ _cParTabNut)
			MSCBSAY(1,36,"INFORMACOES NUTRICIONAIS PORCAO DE 100G (BIFE):","N","0",fonteTipoA_1)
			MSCBSAY(1,39,"Valor Energetico " + Alltrim(ZZ7->ZZ7_CALQTP) + "(" + Alltrim(ZZ7->ZZ7_CALVD) + ");" + "Carboidratos " + Alltrim(ZZ7->ZZ7_CARQTP) + "(" + Alltrim(ZZ7->ZZ7_CARVD) + ");","N","0",fonteTipoA_1)
			MSCBSAY(1,42,"Proteinas " + Alltrim(ZZ7->ZZ7_PROQTP) + "(" + Alltrim(ZZ7->ZZ7_PROVD) + ");" + "Gorduras Totais " + Alltrim(ZZ7->ZZ7_GTQTP) + "(" + Alltrim(ZZ7->ZZ7_GTVD) + ");","N","0",fonteTipoA_1)
			MSCBSAY(1,45,"Gorduras Saturadas " + Alltrim(ZZ7->ZZ7_GSQTP) + "(" + Alltrim(ZZ7->ZZ7_GSVD) + ");" + "Gorduras Trans 0g(0%VD);","N","0",fonteTipoA_1)
			MSCBSAY(1,48,"Fibra Alimentar " + Alltrim(ZZ7->ZZ7_FIAQTP) + "(" + Alltrim(ZZ7->ZZ7_FIAVD) + ");" + "Sodio " + Alltrim(ZZ7->ZZ7_SODQTP) + "(" + Alltrim(ZZ7->ZZ7_SODVD) + ");","N","0",fonteTipoA_1)

			MSCBSAY(1,51,"% Valores diarios de referencia com base em uma dieta" ,"N","0",fonteTipoA_1)
			MSCBSAY(1,54,"de 2.000Kcal ou 8.400kJ Seus valores diarios podem" ,"N","0",fonteTipoA_1)
			MSCBSAY(1,57,"ser maiores ou menores dependendo de suas " ,"N","0",fonteTipoA_1)
			MSCBSAY(1,60,"necessidades energeticas.","N","0",fonteTipoA_1)
		ENDIF
		*/
		//PARÂMETROS PARA MOSTRAR OU OCULTAR A MENSAGEM "APÓS ABERTO CONSUMIR EM xx DIAS -
		//_exmetq   := GetMV('SI_EXMETQ')
		_cod      := ZZ7->ZZ7_CODPRO
		/*Dia 22/12/22 - Ajuste para que cadastro de produto controle aviso de mensagem - ZZ7_CONSU*/
		//IF (_cod $ _exmetq)
		If ZZ7->ZZ7_CONSU = '1'
			MSCBSAY(1,46,"Apos aberto consumir em ate 2 dias.","N","0",fonteTipoC_1)
		ENDIF
		
		//MSCBSAYBAR(42,57,ZZ7->ZZ7_CODPRO,"N","C",10,,.t.,,,2,2,.t.)
		MSCBSAYBAR(35,53,ZZ7->ZZ7_CODPRO,"N","C",10,,.f.,,,2,2,.t.)	
		MSCBSAY(05,60,ZZ7->ZZ7_CODPRO,"N","0",'40.00')
	
	ELSEIF (_cTPMerc = "ME" .and. _cTPCadMerc = 'L')    //SE FOR MERCADO EXTERNO E PARA O LIBANO

		MSCBSAY(05,06,ZZ7->ZZ7_DESC,"N","0",fonteTipoF_1)
		MSCBSAY(15,10,ZZ7->ZZ7_DESCE,"N","0",fonteTipoF_1)
		MSCBSAY(05,14,alltrim(ZZ7->ZZ7_CORTE) + "|" + alltrim(ZZ7->ZZ7_CORTEE),"N","0",fonteTipoE_1)
		MSCBSAY(1,24,"SLAUGHTER DATE:|DATA DE ABATE	:","N","0",fonteTipoC_1)
		MSCBSAY(55,24,DtoC(_DtAbt),"N","0",fonteTipoC_1)
		MSCBSAY(1,28,"PRODUCTION DATE/LOT:|DATA DE PRODUÇÃO/LOTE:","N","0",fonteTipoC_1)
		MSCBSAY(55,28,DtoC(_DtEmb),"N","0",fonteTipoC_1)			
		MSCBSAY(1,32,"EXPIRY DATE:|DATA DE VALIDADE:","N","0",fonteTipoC_1)
		MSCBSAY(55,32,DtoC(_DtVal),"N","0",fonteTipoC_1)
		MSCBSAY(1,36,"PACKAGE WEIGHT:|PESO DA EMBALAGEM:","N","0",fonteTipoC_1)
		MSCBSAY(55,36,transform(valor4,'@E 99') + "g","N","0",fonteTipoC_1)
		MSCBSAY(20,42,"HALAL PRODUCTS","N","0",fonteTipoA_1)
		MSCBSAY(1,45,"REGISTRO NO MINISTERIO DA AGRICULTURA SIF/DIPOA","N","0",fonteTipoA_1)
		MSCBSAY(20,48,"SOB N" + ZZ7->ZZ7_MSIF,"N","0",fonteTipoA_1)	
		MSCBSAY(1,52,SB1->B1_MENETQ5,"N","0",fonteTipoC_1)
		MSCBSAY(1,56,SB1->B1_MENETQ2,"N","0",fonteTipoC_1)		
		MSCBSAY(1,60,"CARNE CERTIFICADA PELA ASSOCIAÇÃO BRASILEIRA DE ANGUS","N","0",fonteTipoA_1)	
		MSCBSAY(1,55,alltrim(ZZ7->ZZ7_OBS),"N","0",fonteTipoA_1)

	ELSEIF (_cTPMerc = "ME" .and. _cTPCadMerc = 'A')    //SE FOR MERCADO EXTERNO E PARA EUA

		MSCBSAY(05,06,ZZ7->ZZ7_DESC,"N","0",fonteTipoF_1)
		MSCBSAY(15,10,ZZ7->ZZ7_DESCE,"N","0",fonteTipoF_1)
		MSCBSAY(05,14,alltrim(ZZ7->ZZ7_CORTE) + "|" + alltrim(ZZ7->ZZ7_CORTEE),"N","0",fonteTipoE_1)
		MSCBSAY(1,20,SB1->B1_MENETQ2,"N","0",fonteTipoC_1)
		MSCBSAY(1,24,"PRODUCTION DATE/LOT:|DATA PROD./LOTE:","N","0",fonteTipoC_1)
		MSCBSAY(47,24,DtoC(_DtEmb),"N","0",fonteTipoC_1)
		MSCBSAY(1,28,"EXPIRY DATE:|DATA DE VALIDADE:","N","0",fonteTipoC_1)
		MSCBSAY(47,28,DtoC(_DtVal),"N","0",fonteTipoC_1)
		MSCBSAY(1,32,"SLAUGHTER DATE:|DATA DE ABATE:","N","0",fonteTipoC_1)
		MSCBSAY(47,32,DtoC(_DtAbt),"N","0",fonteTipoC_1)
		MSCBSAY(1,36,"PACKAGE WEIGHT:|PESO DA EMBALAGEM:","N","0",fonteTipoC_1)
		MSCBSAY(47,36,transform(valor4,'@E 99') + "g","N","0",fonteTipoC_1)
		MSCBSAY(1,45,"REGISTRO NO MINISTERIO DA AGRICULTURA SIF/DIPOA","N","0",fonteTipoA_1)
		MSCBSAY(20,48,"SOB N" + ZZ7->ZZ7_MSIF,"N","0",fonteTipoA_1)
		//MSCBSAY(1,52,SB1->B1_MENETQ2,"N","0",fonteTipoC_1)
		MSCBSAY(1,55,alltrim(ZZ7->ZZ7_OBS),"N","0",fonteTipoA_1)
		//MSCBSAY(1,50,"IMPORTADOR:","N","0",fonteTipoA_3)
		//MSCBSAY(1,53,alltrim(ZZ7-> ZZ7_IMPOR),"N","0",fonteTipoA_3)
		//MSCBSAY(1,56,(ZZ7-> ZZ7_ENDIMP),"N","0",fonteTipoA_3)
		//MSCBSAY(1,59,("CNPJ:" + ZZ7-> ZZ7_RUT),"N","0",fonteTipoA_3)
		MSCBSAY(05,65,ZZ7->ZZ7_CODPRO,"N","0",'40.00')
		MSCBSAYBAR(42,60,ZZ7->ZZ7_CODPRO,"N","C",10,,.f.,,,2,2,.t.)	

	ELSEIF (_cTPMerc = "ME" .and. _cTPCadMerc = 'E')    //SE FOR MERCADO EXTERNO E PARA URUGUAI

		MSCBSAY(01,06,ZZ7->ZZ7_DESC,"N","0",fonteTipoA_1)	//DESCRIÇÃO DO PRODUTO EM PORTUGUES
		MSCBSAY(01,10,ZZ7->ZZ7_DESCE,"N","0",fonteTipoA_1)	//DESCRIÇÃO DO PRODUTO EM ESPANHOL
		MSCBSAY(07,13,alltrim(ZZ7->ZZ7_CORTE) + " / " + alltrim(ZZ7->ZZ7_CORTEE),"N","0",fonteTipoB_1) //DESCRIÇÃO DO CORTE EM PORTUGUES E ESPANHOL
		MSCBSAY(1,18,SB1->B1_MENETQ2,"N","0",fonteTipoC_1)	//MENSAGEM ETIQUETA DOIS
		MSCBSAY(1,22,"FECHA DE MATANZA / DATA DE ABATE:","N","0",fonteTipoC_1)
		MSCBSAY(49,22,DtoC(_DtAbt),"N","0",fonteTipoC_1) 	// DATA DA PRODUÇÃO
		MSCBSAY(1,25,"FECHA DE PRODUCCIÓN / DATA DE PRODUÇÃO:","N","0",fonteTipoC_1)
		MSCBSAY(49,25,DToC(_DtEmb),"N","0",fonteTipoC_1)
		MSCBSAY(1,28,"FECHA DE VALIDAD / DATA DE VALIDADE","N","0",fonteTipoC_1)
		MSCBSAY(49,28,DtoC(_DtVal),"N","0",fonteTipoC_1) 	// DATA DA VALIDADE
		MSCBSAY(1,31,"PESO DA EMBALAGEM:","N","0",fonteTipoC_1)
		MSCBSAY(49,31,transform(valor4,'@E 99') + "g","N","0",fonteTipoC_1)
		MSCBSAY(1,34,"REGISTRO NO MINISTERIO DA AGRICULTURA SIF/DIPOA","N","0",fonteTipoD_1)
		MSCBSAY(20,37,"SOB N" + ZZ7->ZZ7_MSIF,"N","0",fonteTipoF_1)
		//MSCBSAY(1,52,SB1->B1_MENETQ2,"N","0",fonteTipoC_1)
		MSCBSAY(1,45,alltrim(ZZ7->ZZ7_OBS),"N","0",fonteTipoF_1)
		MSCBSAY(1,45,"IMPORTADOR:","N","0",fonteTipoA_3)
		MSCBSAY(1,48,alltrim(ZZ7-> ZZ7_IMPOR),"N","0",fonteTipoA_3)
		MSCBSAY(1,51,(ZZ7-> ZZ7_ENDIMP),"N","0",fonteTipoA_3)
		MSCBSAY(1,54,("N RUT" + ZZ7-> ZZ7_RUT),"N","0",fonteTipoA_3)
		IF(empty(ZZ7->ZZ7_RROTU))
			MSCBSAY(1,57,("N Reg. " + ZZ7-> ZZ7_RMONO),"N","0",fonteTipoA_3)
		ELSE
			MSCBSAY(1,57,("N Reg. Monografia " + ZZ7-> ZZ7_RMONO),"N","0",fonteTipoA_3)
			MSCBSAY(1,60,("N Reg. Rótulo " + ZZ7-> ZZ7_RROTU),"N","0",fonteTipoA_3)
		ENDIF
		MSCBSAYBAR(42,60,ZZ7->ZZ7_CODPRO,"N","C",10,,.f.,,,2,2,.t.)
		MSCBSAY(10,65,ZZ7->ZZ7_CODPRO,"N","0",'40.00')

	ELSEIF (_cTPMerc = "ME" .and. _cTPCadMerc = 'U')    //Produção EUA com controle de lote

		MSCBSAY(05,06,ZZ7->ZZ7_DESC,"N","0",fonteTipoF_1)
		MSCBSAY(15,10,ZZ7->ZZ7_DESCE,"N","0",fonteTipoF_1)
		MSCBSAY(05,14,alltrim(ZZ7->ZZ7_CORTE) + "|" + alltrim(ZZ7->ZZ7_CORTEE),"N","0",fonteTipoE_1)
		MSCBSAY(1,20,SB1->B1_MENETQ5,"N","0",fonteTipoC_1)
		MSCBSAY(1,24,"PRODUCTION DATE/LOT:|DATA DE PRODUÇÃO/LOTE:","N","0",fonteTipoC_1)
		MSCBSAY(55,24,DtoC(_DtEmb),"N","0",fonteTipoC_1)
		MSCBSAY(1,28,"SLAUGHTER DATE:|DATA DE ABATE	:","N","0",fonteTipoC_1)
		MSCBSAY(55,28,DtoC(_DtAbt),"N","0",fonteTipoC_1)
		MSCBSAY(1,32,"EXPIRY DATE:|DATA DE VALIDADE:","N","0",fonteTipoC_1)
		MSCBSAY(55,32,DtoC(_DtVal),"N","0",fonteTipoC_1)
		MSCBSAY(1,36,"PACKAGE WEIGHT:|PESO DA EMBALAGEM:","N","0",fonteTipoC_1)
		MSCBSAY(55,36,transform(valor4,'@E 99') + "g","N","0",fonteTipoC_1)
		MSCBSAY(1,45,"REGISTRO NO MINISTERIO DA AGRICULTURA SIF/DIPOA","N","0",fonteTipoA_1)
		MSCBSAY(20,48,"SOB N" + ZZ7->ZZ7_MSIF,"N","0",fonteTipoA_1)
		MSCBSAY(1,52,SB1->B1_MENETQ2,"N","0",fonteTipoC_1)
		MSCBSAY(1,55,alltrim(ZZ7->ZZ7_OBS),"N","0",fonteTipoA_1)
		MSCBSAY(05,60,ZZ7->ZZ7_CODPRO,"N","0",'40.00')
		MSCBSAY(05,66,cLotePrd,"N","0",fonteTipoC_1)

	ELSE
		//MsgAlert("CADASTRO COM PENDÊNCIAS. ENTRE EM CONTATO COM PCP.", "AVISO")		
		MsgAlert("CAMPO -Merc. Destino- Precisa ser preenchido ENTRE EM CONTATO COM PCP.", "AVISO")		
	ENDIF

	MSCBEND()
	MSCBCLOSEPRINTER()

	Clear()

	msgbox('Impressão de Etiquetas em Andamento!','Impressão','INFO')

	btn1:enable()
	telaimp:refresh()

RETURN

STATIC FUNCTION DadosProducao()
	local _lFlag := .t.

	ZZ7->(dbsetorder(1))
	IF ZZ7->(dbseek(FWxfilial('ZZ7')+valor1))
		valor3 := ZZ7->ZZ7_CORTE
	ENDIF

	if !(valor1 $ ZZ7->ZZ7_CODPRO)
		MsgAlert("Produto informado não existe, favor cadastrar Et. Interna. Corrija o código inserido", "AVISO")
		_lFlag := .f.
		Clear()		
		btn1:enable()
	endif	
	_nTaraP := GetAdvFval('SB1','B1_CTARAP',FWxfilial('SB1')+ alltrim(valor1),1)     // Linhas inserias para buscar"_NTARAp"
	_nTP    := GetAdvFval('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_nTaraP),1)  	// os campos de codigo das taras primarias
	valor4  := (_nTP * 1000)
	_cTPCadMerc := GetAdvFval('SB1','B1_CADMERC',FWxFilial('SB1') + alltrim(valor1),1)

	if _cTPCadMerc == 'U'
		@ 010, 01 SAY oSay PROMPT "Lote de Producao:" SIZE 025, 007 OF telaimp
		@ 010, 10 MSGET oLotePrd VAR cLotePrd SIZE 100, 010 valid regrad(_cTPCadMerc,valor1,cLotePrd) F3 "ZULOTE" OF telaimp 
	else
		if _lflag //flag para evitar error.log
			@ 010, 01 SAY oSay PROMPT "" SIZE 025, 007 OF telaimp
			@ 010, 10 MSGET oLotePrd VAR cLotePrd SIZE 100, 010 valid regrad(_cTPCadMerc,valor1,cLotePrd) F3 "ZULOTE" OF telaimp
			cLotePrd := space(25)
			oSay:disable()
			oSay:hide()
			oLotePrd:disable()
			oLotePrd:hide()
		endif
	endif

	telaimp:refresh()

RETURN

STATIC FUNCTION QuantEtq()

	_nQTD   := 0
	_nQtdCx := GetAdvFval('SB1','B1_QCAIX',FWxFilial('SB1') + alltrim(valor1),1)
	_nQetq  := _nQtdCx * valor5
	valor6   := _nQetq

RETURN 

// Validação da data de abate. Data deve coincidir com alguma data de abate ou carregamento de terceiros e no máximo 14 dias no passado
STATIC FUNCTION DTABT()

	_dDtAb := GetAdvFval('SZG','ZG_DATA',FWxFilial('SZG') + DTOS(valor2),2)
	_dDtAb2 := GetAdvFval('ZAP','ZAP_DATAP',FWxFilial('ZAP') + DTOS(valor2),4)
	IF (_dDtAb = DDATABASE .and. !(GetAdvFval('SB1','B1_GRUPO',FWxFilial('SB1') + valor1,1) $ _cProdMDS))
		FWAlertError('A data de abate informada não pode ser a data do dia atual  ', 'DATA DE ABATE ERRADA !!')
		campoDataAbate:setFocus()
		return .f.
	ENDIF

	IF empty(_dDtAb) .and. empty(_dDtAb2)
		FWAlertError('Não teve abate neste Dia  !! Colocar outra data de abate!!!  ', 'DATA DE ABATE ERRADA !!')
		campoDataAbate:setFocus()
		return .f.
	elseif valor2 < (DDATABASE-15) .and. (_cCodUser != "000883")
		FWAlertError('Data de abate muito antiga!! (Mais de 15 dias antes da data atual) ', 'ENTRAR EM CONTATO COM PCP!!')
		campoDataAbate:setFocus()
		return .F.
	else
		return .T.
	endif

RETURN

// Validação da data de produção. Data deve ser maior ou igual à database e no máximo 7 dias no futuro, a não ser que seja uma usuários dos 2 parâmetros(SI_USRETQ e SI_ETQPRC).
// Nesse caso, os usuários pode avançar ou retroceder até 20 dias. Usuário Devolução pode avançar ou retroceder até 365 dias
STATIC FUNCTION DTPROD()

	if _cCodUser = "000883"	// Devolução
		if valor7 > (DDATABASE + 365) .or. valor7 < (DDATABASE - 365)
			FWAlertError('Data de Produção além do permitido!', 'PROIBIDO!')
			campoDataProducao:setFocus()
			return .F.
		else
			return .T.
		endif
	elseif ( _cCodUser $ _cUsrPorc) .or. (_cCodUser $ _cUsrEtq)
		if valor7 > (DDATABASE + 20) .or. valor7 < (DDATABASE - 20)
			FWAlertError('Data de Produção além do permitido!', 'PROIBIDO!')
			campoDataProducao:setFocus()
			return .F.
		else
			return .T.
		endif
	elseif valor7 < DDATABASE
		FWAlertError('Data de Produção anterior a Data Base!', 'PROIBIDO!')
		campoDataProducao:setFocus()
		return .F.
	elseif valor7 > (DDATABASE + 7)
		FWAlertError('Data de Produção posterior a 7 dias da Data Base!', 'PROIBIDO!')
		campoDataProducao:setFocus()
		return .F.
	else
		return .T.
	endif

RETURN


Static Function ProdProc()

	_grp := GetAdvFval('SB1','B1_GRUPO',FWxfilial('SB1')+alltrim(valor1),1)

	if alltrim(_grp) $ (alltrim(_cProdPORC)+alltrim(_cProdCharque))
		campoDataAbate:disable()
		campoDataAbate:hide()
		Return .T.
	else
		campoDataAbate:enable()
		campoDataAbate:show()
		campoDataAbate:setFocus()
		Return .T.
	Endif

Return

STATIC FUNCTION InterfaceGrafica()

	@ 01,01 SAY "Produto:" of telaimp
	@ 02,01 SAY "Data de Abate:" of telaimp
	@ 03,01 SAY "Data de Produção:" of telaimp
	@ 04,01 SAY "Descrição do Corte" of telaimp
	@ 06,01 SAY "Tara:" of telaimp
	@ 07,01 SAY "Quant. Caixas:" of telaimp
	@ 08,01 SAY "Qtd.Etiquetas:" of telaimp
	@ 01,10 MSGET campoCodProduto VAR valor1 SIZE 30,10 F3 'ZZ7' OF telaimp VALID !VAZIO() .and. ProdProc()
	@ 02,10 MSGET campoDataAbate VAR valor2 SIZE 40,10 OF telaimp valid (DTABT() .and. !VAZIO())
	@ 03,10 MSGET campoDataProducao VAR valor7 SIZE 40,10 OF telaimp valid (DTPROD() .and. !VAZIO())
	@ 04,10 SAY valor3 OF telaimp
	@ 06,10 SAY transform(valor4,'@E 99') + ' g' of telaimp
	@ 07,10 MSGET campoQtdCaixas VAR valor5 SIZE 40,10 OF telaimp picture '@E 999' VALID QuantEtq()
	@ 08,10 SAY	transform(valor6,'@E 999') OF telaimp

	campoCodProduto:bLostFocus := {|| DadosProducao() }

RETURN

STATIC FUNCTION regra(_data)

	_dDTMaior := date()
	_dDTMenor := date() - 30

	IF empty(_data)
		MsgAlert('Favor preencher campo da Data de Produção!!', 'PREENCHIMENTO PROIBIDO!!')	
			return .f.
	ENDIF
	/* Devemos cadastrar o usuário somente em um dos  parâmetros, ou no SI_USRETQ ou no SI_ETQPRC*/
	if alltrim(_cCodUser) $ _cUsrEtq
		/* Regra para campo - Data Abate - Parametro SI_USRETQ */
		regraa(_data)
	ELSEIF alltrim(_cCodUser) $ _cUsrPorc
		/* Regra para campo - Data Abate - Parametro SI_ETQPRC - Porcionados */
		regrac(_data)
	ELSE 
		/* Se não estiver nos parâmetros então cai aqui */
		//IF _data = _dDTMaior  .or. _data = _dDTMenor
		IF _data = _dDTMaior
			// Ajuste para que se o usuário não estiver cadastrado nos parâmetros só pode produzir
			// no campo  "Data de Produção " com data do dia - Dia 08/05/23 ajustada regra
			return .t.
		ELSE
			MsgAlert('Data de Produção Não permitida, Usar data de Produção do Dia Atual !! ', 'DATA PROIBIDA !!')
			return .f.
		ENDIF
	ENDIF
	//DTABT()
RETURN .t.

STATIC FUNCTION regraa(_data1)

	_dDTMaior := date() - 1
	_dDTMenor := date() - 15

	if _data1 = _dDTMaior
		return .t.
	elseif _data1 <= _dDTMaior

		if _data1 >= _dDTMenor
			return .t.
		else
			MsgAlert('Data de Produção Não permitida para usuário '+_cOper+', Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')
			campoDataAbate:SETFOCUS()
			return .f.
		endif

	elseif 	_data1 <= _dDTMaior + 4
		// Regra nova implementada para o novo calculo da validade pela data de embalagem
		if _data1 >= _dDTMenor
			return .t.
		else
			MsgAlert('Data de Produção Não permitida para o usuário '+_cOper+', Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')
			campoDataAbate:SETFOCUS()
			return .f.
		endif
	else
		//MsgAlert('2 - Data do Abate Não permitida, Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')
		MsgAlert('Data de Embalagem Não permitida, Entrar em contato com PCP!! ', 'DATA PROIBIDA!!')
		campoDataAbate:SETFOCUS()
		return .f.
	endif
RETURN

STATIC FUNCTION regrac(_data2)

	_dDTMaior   := date() + 365
	_dDTMenor   := date() - 365

	/*Regras do campo "Data do Abate" para usuários Porcionados - SI_ETQPRC*/

	if _data2 <= _dDTMaior
		
		if _data2 >= _dDTMenor 
			return .t.
		else
			//MsgAlert('1 - Data do  Abate Não permitida, Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')
			MsgAlert('1006 - Data de Produção não permitida para Usuário '+_cOper+', Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')
			campoDataAbate:SETFOCUS()
			return .f.
		endif
	else
		MsgAlert('1011 - Data de Produção não permitida  para Usuário '+_cOper+', Entrar em contato com PCP !! ', 'DATA PROIBIDA !!')
		campoDataAbate:SETFOCUS()
		return .f.
	endif
RETURN

/*/{Protheus.doc} regrad
	(Função destinada para validar o lote de produção informado)
	@type  Static Function
	@author user
	@since 03/02/2023
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function regrad(_cCadMerc, _cCodProd,_cLote)

	if _cCadMerc == 'U'
		if empty(_cLote)
			MsgAlert('Atenção, é obrigatório o preenchimento do lote para produtos de exportação para os EUA', 'Lote de Produção em Branco!')
			oLotePrd:setFocus()
			return .f.
		endif
	endif
	
Return .t.

//ADD FUNÇõES DE PREVISÃO
STATIC FUNCTION dti158wfw(_nProd,_nNvinc,_cDes,_dDtEmb)
			
	Local _cMens := ''
	Local _cAtivaR := GetMV('SI_LIBR88')

		_cMens := 'Esta é uma mensagem automática do sistema. Por favor não responda!' + chr(13) + chr(10)

		If  _nNvinc = 999
			IF _cAtivaR = '1'
				// Gera a previsão de produção Automática da Embalagem
				U_DTI88PPE(1,_nProd,_dDtEmb, valor2, _predes)
			Endif			
			_cMens += 'O Produto :'+_nProd+' - '+_cDes+' Produto não possui previsão de Embalagem Lançada  !!'+ chr(13) + chr(10)
		Elseif _nNvinc > 0
			//Alert('562 ENTROU')
			//_cMens += 'O Produto :'+_nProd+' - '+_cDes+' esta com '+cValtoChar(_nNvinc)+' Previsões da Enbalagem NÃO vinculada com Prev. da Desossa   !!'+ chr(13) + chr(10)
			//Se já houver ordem de produção com data de produção e data de abate iguais não será gerada uma nova. Porém a etiqueta será impressa normalmente.
			_cQuery3 := " SELECT ZU_COD,ZU_DTPROD,ZU_DTABT "
			_cQuery3 += " FROM " + retSqlTab('SZU')
			_cQuery3 += " WHERE " + retSqlFil('SZU')
			_cQuery3 += " AND " + retSqlDel('SZU')
			_cQuery3 += " AND ZU_DTPROD = '" + alltrim(dtos(valor7)) + "' "
			_cQuery3 += " AND ZU_COD = '" + valor1 + "' "

			_cQuery3  := ChangeQuery(_cQuery3)
			//	* Mostrar a consulta */
			//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
			//@ 055,005 Get _cQuery3 Size 250,080 MEMO Object oMemo
			//Activate Dialog oDlgMemo

			GeraQUE2()

			TMP3->(dbGoTop())
			WHILE TMP3->(!EOF())
				//IF(TMP3->ZU_DTABT = dtos(valor2))
				IF(TMP3->ZU_DTABT = dtos(valor2) .and. TMP3->ZU_DTPROD = dtos(valor7))
					return .f.
				ENDIF
				TMP3->(DBSKIP())
			END
			//U_DTI88PPE(1,_nProd,_dDtEmb, valor2, _predes)
			//U_DTI88PPE(1,_nProd,valor7, valor2, _predes)
		Endif

		_cMens +=   chr(13) + chr(10)
		_cTit  := 'Workflow Frigorífico Silva: Aviso de Produção na EMBALAGEM/DESOSSA  ' 
		//u_GJF54(_cMens,_cTit,_cDest)

return

USER FUNCTION  QtPrev(_cDescri,_dDtABT,_cCodP,_dDtProd)
	LOCAL _nCont := 0
	LOCAL _nCont2 := 0
	LOCAL _nNvinc := 0
	//LOCAL _nDABT := 0
	LOCAL _nMark := 'N'

	_cQuery := " SELECT ZU_NUM,ZU_COD,ZU_DTPROD,ZU_PREDES AS PREDES "
	_cQuery += " FROM " + retSqlTab('SZU')
	_cQuery += " WHERE " + retSqlFil('SZU')
	_cQuery += " AND " + retSqlDel('SZU')
	_cQuery += " AND ZU_DTPROD = '" + dtos(_dDtProd) + "' "
	_cQuery += " AND ZU_COD = '" + alltrim(_cCodP) + "' "
	
	_cQuery  := ChangeQuery(_cQuery)

	_cQuery2 := "SELECT Z2_NUM AS NUM"
	_cQuery2 += " FROM " + retSqlTab('SZ2')
	_cQuery2 += " WHERE " + retSqlFil('SZ2')
	_cQuery2 += " AND " + retSqlDel('SZ2')
	_cQuery2 += " AND Z2_DATAABT = '" + dtos(_dDtABT) + "' "
	_cQuery2 += " AND Z2_CORORI IN ('C','T') AND Z2_CLASSIF = 'HK' ORDER BY Z2_NUMAM DESC"
	_cQuery2  := ChangeQuery(_cQuery2)

	GeraQUE()
	
	SZ2->(DbGoTop()) 
	SZ2->(dbSetOrder(2))

	TMP->(dbGoTop())
	While TMP->(!EOF())
		_cPrevde := alltrim(TMP->PREDES)	
		if  !empty(alltrim(_cPrevde)) .AND. !empty(SZ2->(dbSeek(FWxFilial('SZ2') + alltrim(_cPrevde))))
				//alert('Data do Abate diferente da Data lançada na produção das Etiqueta Internas  !! Enviado e-mail para o PCP')
				_nCont2++
				//_nDABT++
				_nNvinc++
		else
			// Se prev embalagem  não tiver prev desossa vinculada cai aqui
			//alert('Prev. da Enbalagem não vinculada com Prev. da Desossa  !! Enviado e-mail para o PCP')
			////_nCont2++
			////_nNvinc++
		End

		_nCont++
		TMP->(dbSkip())
	Enddo

	TMP2->(dbGoTop())		
	//While TMP2->(!EOF())
		_predes := TMP2->NUM	
	//ENDDO
	// caso não tenha previsão
	If _nMark = 'N'
		If _nCont = 0 .AND. _nCont2 = 0
			//alert('Produto não possui previsão de Embalagem Lançada !! Enviado e-mail para o PCP')
			// aviso de SZU não lançada 
			_nNvinc:= 999

			dti158wfw(_cCodP,_nNvinc,_cDescri,Valor7)

		elseif _nCont > 0
		 	// caso não tenha previsão correta ,  descrever no e-mail situações visualizadas
			if _nCont =_nCont2
				dti158wfw(_cCodP,_nNvinc,_cDescri,Valor7)
			Endif
		Endif
	Endif
return

Static Function GeraQUE()

	_cQuery  := ChangeQuery(_cQuery)

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

	_cQuery2  := ChangeQuery(_cQuery2)

	If Select("TMP2") != 0
		TMP2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "TMP2"
return

Static Function GeraQUE2()

	_cQuery3  := ChangeQuery(_cQuery3)

	If Select("TMP3") != 0
		TMP3->(dbCloseArea())
	Endif

	TCQUERY _cQuery3 NEW ALIAS "TMP3"
return
