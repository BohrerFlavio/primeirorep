#INCLUDE "topconn.ch"         
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"                                                                                  
#INCLUDE "topconn.ch"                       
/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMLR36     บAutor  ณMauricio Roehrs บ Data ณ  27/05/14       บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณapontamento dos vales transportes e gera็ใo do arquivo textoบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Sigagpe - Frigorifico Silva                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MLR36()
	Local _aArqTrb      := {}
	Private cIPerg  	:= "MLR36"                       
	Private cIPerg2  	:= "MLR36B"                       
	Private _aTexto 	:= {}
	Private _cTexto 	:= ''      
	Private aTela    	:= {}     
	Private aStru    	:= {}
	Private aCampos  	:= {}
	Private cArq
	Private _cFolMes 	:= GETMV('MV_FOLMES')
	Private _nMesPerg 	:= 0
	Private _nAnoPerg 	:= 0
	aObjects            := {}
	aPosObj             := {}
	aInfo               := {}
	aSizeAut            := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )


	if !pergunte(cIPerg2,.t.)
		return
	endif


	
	_nMesPerg := val(substr(mv_par06,1,2))
	_nAnoPerg := val(substr(mv_par06,4,4))
	_nAnoFol  := val(substr(_cFolMes,1,4))    
	_nMesFol  := val(substr(_cFolMes,5,2))


	//alert('Ano  pergunta'+substr(mv_par06,4,4))
	//alert('Ano Folha'+substr(_cFolMes,1,4))
	if _nAnoPerg < _nAnoFol //verifica o ano de competencia da folha
		alert('Ano de referencia no parametro inferior ao ano de compet๊ncia da folha!!')
		return
	elseif _nMesPerg < _nMesFol .and. _nAnoPerg == _nAnoFol //verifica o mes de competencia da folha
		alert('Mes de referencia no parametro inferior ao mes de compet๊ncia da folha!!')
		return		
	endif

	_nQuant := contagem()

	Processa({||montabrow()} ,"PROCESSAMENTO DE REGISTROS","montando tela com os funcionarios...")

	DbSelectArea('TMP')                                                                                     
	DEFINE MSDIALOG oDlg TITLE 'Apontamento dos valores de vale transporte' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	@ 010,005 To 220,800 Browse "TMP" fields aCampos object oBrow

	oBrow:oBrowse:bldBlClick :=  {|| apontaVale()}

	@aPosObj[2,3]-5,aPosObj[2,1] BUTTON btn01 PROMPT "Salvar" 		   	OF oDlg 	SIZE 40,15 PIXEL ACTION GravVal()                                                                                             
	@aPosObj[2,3]-5,aPosObj[2,1]+50 BUTTON btn02 PROMPT "Gerar Arquivo" 	OF oDlg  SIZE 40,15 PIXEL ACTION GeraArq() 
	@aPosObj[2,3]-5,aPosObj[2,1]+100 BUTTON btn03 PROMPT "Sair" 			OF oDlg  SIZE 40,15 PIXEL ACTION oDlg:end()

	ACTIVATE MSDIALOG oDlg CENTERED

	TMP->(DbCloseArea())     
	
	// ProcData 04/2023 - Chamada para fechar arquivo de trabalho
	u_arqtrb ("FechaTodos",,,, @_aArqTrb) 	

Return


Static Function montabrow()

	local _nDias    	:= mv_par01
	local _nVLval  		:= mv_par02
	local _nQtVale  	:= mv_par03 
	local _nVlrVale   	:= 0.00
	local _cTpVal     	:= ''
	local _cMesRef    	:= substr(mv_par06,1,2)
	local _cAnoRef    	:= substr(mv_par06,4,4)
	local _mat			:= mv_par07

	_aArqTrb    := {}
	//cArq  := CriaTrab( Nil, .F. )    
	
	//alert(mv_par04)
	//alert(mv_par05)
	if mv_par04 < 5
		_cTpVal     := 	iif(mv_par04 = 1,'A',;
					iif(mv_par04 = 2,'F',;
					iif(mv_par04 = 3,'S',;	
					iif(mv_par04 = 4,'B',''))))
	elseif mv_par05 < 3
		_cTpVal     := 	iif(mv_par05 = 1,'V',;						
					iif(mv_par05 = 2,'T',''))
	endif
	
	aadd(aCampos,{"MAT" 		,"Matricula"  							,""})
	aadd(aCampos,{"NOME"   	,"Nome"									,""})
	aadd(aCampos,{"VALOR"  	,"VAlor do Vale Transporte"   	,"@E 999.99"})
	aadd(aCampos,{"MAT_ATU" ,"Matricula ATU"  					,""})
	aadd(aCampos,{"TP_VAL"  ,"Tipo de Vale"      				,""})
	aadd(aCampos,{"TP_DESC" ,"Descri. do Tipo  de Vale" 		,""})
	aadd(aCampos,{"MES_REF" ,"Mes de Referencia"  				,""})
	aadd(aCampos,{"ANO_REF" ,"Ano de Referencia"  				,""})


	aadd(aStru,{"MAT"  		, "C",  06,  0,   "@!"         , 'Matricula  				  '})
	aadd(aStru,{"NOME"   	, "C",  60,  0,   "@!"         , 'Nome    					  '})
	aadd(aStru,{"VALOR" 	, "N",  06,  2,   "@E 999.99"  , 'Valor do Vale Transporte '})
	aadd(aStru,{"MAT_ATU"   , "C",  15,  0,   "@!"         , 'Matricula ATU				  '})
	aadd(aStru,{"TP_VAL"    , "C",  01,  0,   "@!"         , 'Tipo de Vale      		  '})
	aadd(aStru,{"TP_DESC"   , "C",  15,  0,   "@!"         , 'Descri. do Tipo de Vale  '})
	aadd(aStru,{"MES_REF"   , "C",  02,  0,   "@!"         , 'Mes de Referencia		  '})
	aadd(aStru,{"ANO_REF"   , "C",  04,  0,   "@!"         , 'Ano de Referencia		  '})


	//dbcreate(cArq,aStru) 
	// ProcData 04/2023 - Chamada para cria็ใo do arquivo de trabalho
	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	If Select("TMP") != 0
		TMP->(DbCloseArea())
	endif

	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	TMP->(DbGotop())

	SRA->(DbSetOrder(1))
	SRA->(DbGoTop())

	ProcRegua(_nQuant)	
	While SRA->(!eof()) .and. SRA->RA_FILIAL = xfilial('SRA')

		IncProc('Processando dados da matricula n.บ: ' + SRA->RA_MAT)

		if SRA->RA_RECVALE <> 'S'
			ZZQ->(DbSetOrder(1))
			ZZQ->(DbGoTop())
			if ZZQ->(DbSeek(xFilial('ZZQ')+ SRA->RA_MAT +_cMesRef + _cAnoRef ))					
				reclock('ZZQ',.f.)
				DBdelete()
				msunlock()
			endif          
			SRA->(DbSkip())
			loop
		endif


		if empty(SRA->RA_TPVAL)
			SRA->(DbSkip())
			loop	     	                  		
		endif                            

		if empty(_cTpVal)         		
			SRA->(DbSkip())
			loop	     	   	
		endif

		if !empty(_cTpVal)         		
			if _cTpVal <> SRA->RA_TPVAL
				SRA->(DbSkip())
				loop		
			endif					      							
		endif                      

		if !empty(_mat)
			if SRA->RA_MAT <> _mat
				SRA->(DbSkip())
				loop		
			endif	
		endif

		ZZQ->(DbSetOrder(1))
		ZZQ->(DbGoTop())
		if ZZQ->(DbSeek(xFilial('ZZQ')+ SRA->RA_MAT +_cMesRef + _cAnoRef ))		
			_nVlrVale := ZZQ->ZZQ_VLVAL		                                    
		else
			_nVlrVale := (_nVLval * _nQtVale) * _nDias 						                                                     
		endif
		//alert(_mat)
		//alert(_cTpVal)

		reclock('TMP',.t.)
		TMP->MAT	   	:= SRA->RA_MAT
		TMP->NOME		:= SRA->RA_NOME
		TMP->MAT_ATU  	:= SRA->RA_MATATU
		TMP->VALOR		:= _nVlrVale
		TMP->TP_VAL    := SRA->RA_TPVAL
		TMP->TP_DESC   := iif(SRA->RA_TPVAL = 'A','ATU',;
		iif(SRA->RA_TPVAL = 'F','Formigueiro',;
		iif(SRA->RA_TPVAL = 'S','Sao Sepe',;
		iif(SRA->RA_TPVAL = 'V','Fretado',;
		iif(SRA->RA_TPVAL = 'T','ATU/Fretado',;
		iif(SRA->RA_TPVAL = 'B','Vila Block',''))))))
		TMP->MES_REF   := _cMesRef
		TMP->ANO_REF   := _cAnoRef
		msunlock()

		SRA->(DbSkip())
	enddo

	TMP->(DbGoTop())    

return      

//Fun็ใo que chama a telinha de altera็ใo dos vales-transporte
Static Function apontaVale()
	Local 	_nValor := TMP->VALOR	
	Local 	_Campo1 := 0.00
	Local 	_Campo2 := space(6)
	Private  _cMat   := TMP->MAT

	DEFINE MSDIALOG oDlg2 TITLE 'Valor de Vales-Transporte' from 000,000 To 150,200 OF oMainWnd PIXEL  

	@ 015,002 SAY  'Matricula' Object oSay1
	@ 001,005 MSGET _Campo2 VAR _cMat SIZE 35,11 VALID Completa() OF oDlg2

	@ 030,002 SAY  'Valor' Object oSay2
	@ 002,005 MSGET _Campo1 VAR _nValor SIZE 35,11  PICTURE "@E 999.99"  OF oDlg2


	@ 060,008 BMPBUTTON TYPE 1 ACTION CnfVal(_nValor) Object Obtn1     
	@ 060,040 BMPBUTTON TYPE 3 ACTION DesVal(_nValor) Object Obtn2 
	@ 060,073 BMPBUTTON TYPE 2 ACTION oDlg2:end() Object Obtn3 

	ACTIVATE MSDIALOG oDlg2 CENTERED  

return              

Static Function Completa()

	if !empty(_cMat)
		_cMat  := padl(alltrim(_cMat),6,'0')
	endif  

	oDlg2:refresh() 
return .t.

Static Function contagem()

	Local _quant := 0        
	SRA->(DbGoTop())
	while SRA->(!eof()) .and. SRA->RA_FILIAL = xFilial('SRA')  
		if SRA->RA_RECVALE <> 'S'
			SRA->(DbSkip())
			loop		
		endif
		_quant++	
		SRA->(DbSkip())
	enddo

return _quant 


//Fun็ใo que confirma a inser็ใo dos vales
Static Function CnfVal(_nVal)

	if  (_nVal < 0.00)
		alert('Valor do vale-transporte invแlido!')
		return .f.
	endif

	TMP->(DbGoTop())
	while TMP->(!eof())

		if _cMat = TMP->MAT
			reclock('TMP',.f.)
			TMP->VALOR := _nVAl		
			msunlock()
			exit	   
		else   
			TMP->(DbSkip())
		endif

	enddo

	oBrow:oBrowse:refresh()
	oDlg:refresh() 
	odlg2:end()
return  .t.


Static Function DesVal(_nVal)

	reclock('TMP',.f.)
	TMP->VALOR := 0.00
	msunlock()                                

	oBrow:oBrowse:refresh()
	oDlg:refresh() 
	odlg2:end()
return  .t.     


Static Function GravVal() 
	Processa({||Gravar()} ,"PROCESSAMENTO DE REGISTROS","Efetivando a grava็ใo da digita็ใo dos Vales-Transporte...")
return     

Static Function Gravar()

	TMP->(DbGoTop())   

	ProcRegua(_nQuant)

	while TMP->(!eof())

		incproc('Processando registro da matricula: ' + TMP->MAT)

		if TMP->VALOR <= 0.00
			TMP->(DbSkip())
			loop
		endif


		ZZQ->(DbSetOrder(1))
		ZZQ->(DbGoTop())

		if ZZQ->(DbSeek(xFilial('ZZQ') + TMP->(MAT + MES_REF + ANO_REF)))
			reclock('ZZQ',.f.)      
			ZZQ->ZZQ_VLVAL := TMP->VALOR  
			ZZQ->ZZQ_TPVAL := TMP->TP_VAL
		else
			reclock('ZZQ',.t.)           
			ZZQ->ZZQ_FILIAL	:= xFilial('ZZQ')
			ZZQ->ZZQ_MAT 		:= TMP->MAT
			ZZQ->ZZQ_VLVAL 	:= TMP->VALOR
			ZZQ->ZZQ_TPVAL 	:= TMP->TP_VAL
			ZZQ->ZZQ_MES		:= TMP->MES_REF
			ZZQ->ZZQ_ANO   	:= TMP->ANO_REF  
		endif                             
		msunlock()                   

		TMP->(DbSkip())
	enddo   

	TMP->(DbGoTop()) 

	alert('Apontamentos dos Vales-Transporte Salvos com Sucesso!!')
return 


Static Function GeraArq() 
	Processa({||listaDados()} ,"PROCESSAMENTO DE REGISTROS","Efetivando a listagem dos dados para gerar o arquivo...")
return 


Static Function listaDados()		


	ProcRegua(_nQuant)

	_cont 	:= 0          
	_lGerado := .f.   
	_cMat := '' 

	if !pergunte(cIPerg,.t.)
		return
	endif

	TMP->(DbGoTop())  
	ProcRegua(_nQuant)

	while TMP->(!eof())
		//_cMat := TRB->MAT            		
		incproc('Listando matricula:' + TMP->MAT + ' para o arquivo...')

		if TMP->VALOR <= 0
			TMP->(DbSkip())
			loop
		endif

		if !empty(TMP->MAT_ATU)
			_Matricula := alltrim(TMP->MAT_ATU)+';'
		else                                             
			_subsMat:= substr(TMP->MAT,1,2)
			Do case                                   			
				case at("00",_subsMat) > 0
				_Matricula := substr(alltrim(TMP->MAT),at("00",_subsMat)+2,4)+';'			  					  
				//alert("case1 -> " + _Matricula)					
				case at("0",_subsMat) > 0
				_Matricula := substr(alltrim(TMP->MAT),at("0",_subsMat)+1,5)+';'			    
				//alert("case2 -> " + _Matricula)									
			endcase			
		endif

		//_Matricula := iif(!empty(TMP->MAT_ATU),alltrim(TMP->MAT_ATU),alltrim(TMP->MAT))+';'
		_Nome		  := alltrim(TMP->NOME) + ';'
		_Valor	  := alltrim(strTran(transform(TMP->VALOR,'@E 999.99'),'.',',') + ';')

		_cTexto :=  alltrim(_Matricula) + alltrim(_Nome) + alltrim(_Valor)
		Aadd(_aTexto,_cTexto) 	  

		TMP->(DbSkip())		
	EndDo

	MsgRun("Aguarde... Gerando arquivo texto...",,{||  arquivo() })	

Return 



Static Function arquivo()

	Local nTamLin, cLin, cCpo 
	Local _x
	Private cString  := ""
	//Private cArqTxt := "C:\vales-transporte.txt"
	Private cArqTxt := alltrim(mv_par01) + ".txt"
	Private nHdl    := fCreate(cArqTxt)
	Private cEOL    := "CHR(13)+CHR(10)"


	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif 

	cCpo 	:= ""  

	For _X := 1 to Len(_aTexto)
		cCpo  := _aTexto[_X]+cEOL
		fWrite(nHdl,cCpo,Len(cCpo))
	Next 

	fClose(nHdl)

	msgbox('Arquivo gerado com sucesso!','FIM DE PROCESSAMENTO','INFO')

	_aTexto := {}               
	TMP->(DbGoTop()) 
	oBrow:oBrowse:refresh()
	oDlg:refresh()  
Return       



/*			case at("00",alltrim(TMP->MAT)) > 0
_Matricula := substr(alltrim(TMP->MAT),at("00",alltrim(TMP->MAT))+2,4)+';'			  					  
//alert("case1 -> " + _Matricula)					
case at("0",alltrim(TMP->MAT)) > 0
_Matricula := substr(alltrim(TMP->MAT),at("0",alltrim(TMP->MAT))+1,5)+';'			    
//alert("case2 -> " + _Matricula*/
