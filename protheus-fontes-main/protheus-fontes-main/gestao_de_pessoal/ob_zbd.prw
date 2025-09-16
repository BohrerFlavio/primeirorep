#INCLUDE "rwmake.ch"
#INCLUDE "colors.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF


/*
Integração correção de ponto
*/

User Function OB_ZBD()

	Local _aSaveArea := GetArea()
	Local aCores     := {}
	Private _dInicio:=STOD(SUBSTR(GETMV("MV_PONMES"),1,8))
	Private _dFim   :=STOD(SUBSTR(GETMV("MV_PONMES"),10,8))
	Private _cPaPonta:= alltrim(replace(GETMV("MV_PONMES"),"/",""))

	cExprFilTop := "ZBD_DATA between '"+dtos(_dInicio)+"' AND '"+dtos(_dFim)+"' "

	Private _lOk := .F.


	if !SM0->M0_CODIGO $ "01"
		MsgAlert("Rotina não disponível para essa empresa.")
		return
	endif
	
	Dbselectarea("ZBE")
	dBSetOrder(1)
	if DbSeek(xFilial("ZBE")+RetCodUsr(), .T.)
		if ZBE->ZBE_TIPO <> '2'
			MsgAlert("Somente líderes do tipo DP podem acessar esta rotina, verifique.")
			return
		endif
		if ZBE->ZBE_ATIVO <> '1'
			MsgAlert("Somente líderes ativos podem acessar esta rotina, verifique.")
			return
		endif
	else
		MsgAlert("Usuário não cadastrado nos líderes, acesso não permitido.")
		return
	endif

	Private aRotina  := MenuDef()
	Private cCadastro := "Correção do ponto eletrônico"


	Dbselectarea("ZBD")
	dBSetOrder(1)
	DbGoTop()

	aCores := {{"ZBD_SAPROV==' ' ",'DISABLE' },;
	{"ZBD_1E==0.AND.ZBD_1S==0.AND.ZBD_2E==0.AND.ZBD_2S==0.AND.ZBD_3E==0.AND.ZBD_3S==0.AND.ZBD_4E==0.AND.ZBD_4S==0",'BR_AZUL'},;
	{"ZBD_SAPROV=='S' .AND. ZBD_SIMPOR==' '",'BR_AMARELO'},;
	{"ZBD_SAPROV=='S' .AND. ZBD_SIMPOR=='S'",'ENABLE'}}		//NF Autorizada

	MBrowse( 06, 01, 22, 75,"ZBD",,,,,,aCores,,,,,.F.,,,cExprFilTop)
	//mBrowse(   ,   ,   ,   ,     ,,,,,,      ,,,,, <lNoMnuFilter>, <lSeeAll>, <lChgAll>, <cExprFilTop>, <nInterval>, <uPar22>, <uPar23> )

	Dbselectarea("ZBD")
	Set Filter To
	DbGoTop()

	RestArea(_aSaveArea)
Return

Static Function MenuDef()
	Local aRetorno:= {{ "Legenda"          , "U_OB_ZBDLEG"    , 0, 2, 0, NIL},;  //"Legenda"
	{ "Integrar"         , 'u_OB_IZBD()'  , 0, 3, 0, NIL},;
	{ "Int.todos"        , 'u_OB_IZBDT()' , 0, 3, 0, NIL},;
	{ "Relat.Incons"     , 'u_OB_RELZBD()', 0, 3, 0, NIL},;
	{ "Alterar"          , "AxAltera"     , 0, 4, 0, NIL}}

	//{ "Visualizar"			, "AxVisual"	    , 0, 2, 0, NIL},; //"Visualizar"
	//{ "Alterar"          , "AxAltera"       , 0, 4, 0, NIL}} //"Alterar"
Return aRetorno

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³legenda														 ³
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
user function OB_ZBDLEG ()

	BrwLegenda (cCadastro, "Legenda", {{"BR_AZUL"  , "Justificado"},;
	{"BR_AMARELO"  , "Aprovado"},;
	{"BR_VERDE"    , "Importado" }})
	/*
	BrwLegenda (cCadastro, "Legenda", {{"BR_VERMELHO"   , "Não aprovado" },;
	{"BR_AZUL"  , "Justificado"},;
	{"BR_AMARELO"  , "Aprovado"},;
	{"BR_VERDE"    , "Importado" }})
	*/

Return()

/*
Integra com SP8
*/
user function OB_IZBD()

	if EMPTY(ZBD->ZBD_SAPROV)
		MsgAlert("Não é possível importar, correção não aprovada.")
		return
	endif
	if !EMPTY(ZBD->ZBD_SIMPOR)
		MsgAlert("Não é possível importar, correção já importada.")
		return
	endif

	if ZBD->ZBD_DATA < _dInicio .AND. ZBD->ZBD_DATA > _dFim
		MsgAlert("Não é possível importar, data da correção não confere com período do ponto.")
		return
	endif

	if ZBD->ZBD_1E == 0 .and. ZBD->ZBD_1S == 0 .and. ZBD->ZBD_2E == 0 .and. ZBD->ZBD_2S == 0;
	.and. ZBD->ZBD_3E == 0 .and. ZBD->ZBD_3S == 0 .and. ZBD->ZBD_4E == 0 .and. ZBD->ZBD_4S == 0 .and. !empty(ZBD->ZBD_JUST)
		MsgAlert("Não é possível importar, somente justificativa.")
		return
	endif

	OB_impZBD()

return


/*
Importa todos aprovados
*/
user function OB_IZBDT()

	Dbselectarea("ZBD")
	dBSetOrder(1)
	DbGoTop()
	do while !eof()
		if ZBD->ZBD_SAPROV == "S" .and. EMPTY(ZBD->ZBD_SIMPOR)
			OB_impZBD()
		endif
		dbSkip()
	enddo
	DbGoTop()
return

/*
Função que importa o ZBD posicionado
*/
static function OB_impZBD()
	Local _cSP8 := ""
	Local _cZBD := ""
	Local _aSP8   := {}
	Local _aZBD   := {}
	Local _i
	Local _i2
	Local _i3
	
	dbSelectArea("SP8")
	/*
	dBSetOrder(2)
	DbGoTop()
	DbSeek(ZBD->ZBD_FILFUN+ZBD->ZBD_MAT+DTOS(ZBD->ZBD_DATA))
	*/
	dBSetOrder(1)
	DbGoTop()
	DbSeek(ZBD->ZBD_FILFUN+ZBD->ZBD_MAT+ZBD->ZBD_ORDEM)
	If Found()
		do while !eof() .AND. ZBD->ZBD_MAT == SP8->P8_MAT .AND. ZBD->ZBD_ORDEM == SP8->P8_ORDEM
			if EMPTY(SP8->P8_TPMCREP) .AND. alltrim(SP8->P8_PAPONTA) == _cPaPonta
				aadd(_aSP8, SP8->P8_HORA)
			endif
			dbSkip()
		enddo
	endif

	For _i:=1 to Len(_aSP8)
		_cSP8 += TransForm(_aSP8 [_i],"@E 99.99") +  '  |  '
	next

	if ZBD->ZBD_1E > 0
		aadd(_aZBD, {ZBD->ZBD_DATA, ZBD->ZBD_1E, "1E"})
	endif
	if ZBD->ZBD_1S > 0
		if ZBD->ZBD_1S < ZBD->ZBD_1E
			aadd(_aZBD, {ZBD->ZBD_DATA+1, ZBD->ZBD_1S, "1S"})
		else
			aadd(_aZBD, {ZBD->ZBD_DATA, ZBD->ZBD_1S, "1S"})
		endif
	endif
	if ZBD->ZBD_2E > 0
		if ZBD->ZBD_2E < ZBD->ZBD_1E
			aadd(_aZBD, {ZBD->ZBD_DATA+1, ZBD->ZBD_2E, "2E"})
		else
			aadd(_aZBD, {ZBD->ZBD_DATA, ZBD->ZBD_2E, "2E"})
		endif
	endif
	if ZBD->ZBD_2S > 0
		if ZBD->ZBD_2S < ZBD->ZBD_1E
			aadd(_aZBD, {ZBD->ZBD_DATA+1, ZBD->ZBD_2S, "2S"})
		else
			aadd(_aZBD, {ZBD->ZBD_DATA, ZBD->ZBD_2S, "2S"})
		endif
	endif
	if ZBD->ZBD_3E > 0
		if ZBD->ZBD_3E < ZBD->ZBD_1E
			aadd(_aZBD, {ZBD->ZBD_DATA+1, ZBD->ZBD_3E, "3E"})
		else
			aadd(_aZBD, {ZBD->ZBD_DATA, ZBD->ZBD_3E, "3E"})
		endif
	endif
	if ZBD->ZBD_3S > 0
		if ZBD->ZBD_3S < ZBD->ZBD_1E
			aadd(_aZBD, {ZBD->ZBD_DATA+1, ZBD->ZBD_3S, "3S"})
		else
			aadd(_aZBD, {ZBD->ZBD_DATA, ZBD->ZBD_3S, "3S"})
		endif
	endif
	if ZBD->ZBD_4E > 0
		if ZBD->ZBD_4E < ZBD->ZBD_1E
			aadd(_aZBD, {ZBD->ZBD_DATA+1, ZBD->ZBD_4E, "4E"})
		else
			aadd(_aZBD, {ZBD->ZBD_DATA, ZBD->ZBD_4E, "4E"})
		endif
	endif
	if ZBD->ZBD_4S > 0
		if ZBD->ZBD_4S < ZBD->ZBD_1E
			aadd(_aZBD, {ZBD->ZBD_DATA+1, ZBD->ZBD_4S, "4S"})
		else
			aadd(_aZBD, {ZBD->ZBD_DATA, ZBD->ZBD_4S, "4S"})
		endif
	endif

	For _i2:=1 to Len(_aZBD)
		_cZBD += TransForm(_aZBD [_i2][2],"@E 99.99") +  '  |  '
	next

	dbSelectArea("ZBD")

	Define msdialog _oDlgY from 0, 0 to 320, 500 pixel title 'Integração correção do ponto'
	@  10, 020 say "Funcionário: "+ZBD->ZBD_MAT+"-"+ALLTRIM(iIF(SRA->(DBSEEK(ZBD->ZBD_FILFUN+ZBD->ZBD_MAT)),SRA->RA_NOME," ")) OF _oDlgY PIXEL
	@  20, 020 say "Data:  "+dtoc(ZBD->ZBD_DATA) OF _oDlgY PIXEL

	@  40, 020 say "Antes da correção" OF _oDlgY PIXEL
	//@  40, 020 say _c1ESP8 +' | '+ _c1SSP8 +' | '+ _c2ESP8 +' | '+ _c2SSP8 +' | '+ _c3ESP8 +' | '+ _c3SSP8+' | '+ _c4ESP8 +' | '+ _c4SSP8 OF _oDlgY PIXEL
	@  50, 060 say _cSP8 OF _oDlgY PIXEL
	@  70, 020 say "Correção" OF _oDlgY PIXEL
	@  80, 060 say _cZBD OF _oDlgY PIXEL

	@  100, 020 say "Justificativa:  "+alltrim(ZBD->ZBD_JUST) OF _oDlgY PIXEL
	//@  110, 020 say "Banco de horas:  "+iif(alltrim(ZBD->ZBD_BHORAS)=='S',"Sim","Não")  OF _oDlgY PIXEL
	@  110, 020 say "Aprovador:  "+alltrim(UsrRetName(ZBD->ZBD_CODAPR)) OF _oDlgY PIXEL
	@  120, 020 say "Data aprov.: "+dtoc(ZBD->ZBD_DTAPRO) OF _oDlgY PIXEL

	@ 135,075  bmpbutton type 1 Action (_lOk := .T.,Close(_oDlgY))
	@ 135,150  bmpbutton type 2 Action (_lOk := .F.,Close(_oDlgY))
	Activate dialog _oDlgY centered

	if _lOk
		For _i3:=1 to Len(_aZBD)
			_nPos := ASCAN(_aSP8,_aZBD [_i3][2])
			if _nPos > 0 .and. ! _nPos == _i3
				dbSelectArea("SP8")
				/*
				dBSetOrder(3)
				DbGoTop()
				DbSeek(ZBD->ZBD_FILFUN+ZBD->ZBD_MAT+DTOS(ZBD->ZBD_DATA))
				*/
				dBSetOrder(1)
				DbGoTop()			
				DbSeek(ZBD->ZBD_FILFUN+ZBD->ZBD_MAT+ZBD->ZBD_ORDEM)
				If Found()
					do while !eof() .AND. ZBD->ZBD_MAT == SP8->P8_MAT .AND. ZBD->ZBD_ORDEM == SP8->P8_ORDEM
						if EMPTY(SP8->P8_TPMCREP) .and. _aZBD [_i3][2] == SP8->P8_HORA .and. alltrim(SP8->P8_PAPONTA) == _cPaPonta
							Reclock("SP8",.F.)
							SP8->P8_TPMARCA := _aZBD [_i3][3]
							msunlock()
						endif
						DbSelectArea("SP8")
						DbSkip()
					EndDo
				endif
			elseif _nPos == 0
				Reclock("SP8",.T.)
				sp8->p8_filial:= ZBD->ZBD_FILFUN
				sp8->p8_data  := _aZBD [_i3][1]
				sp8->p8_turno := POSICIONE("SRA",1,ZBD->ZBD_FILFUN+ZBD->ZBD_MAT,"RA_TNOTRAB")
				sp8->p8_mat   := ZBD->ZBD_MAT
				sp8->p8_hora  := _aZBD [_i3][2]
				sp8->p8_ordem := ZBD->ZBD_ORDEM
				sp8->p8_FLAG  :="I"
				sp8->p8_CC    :=POSICIONE("SRA",1,ZBD->ZBD_FILFUN+ZBD->ZBD_MAT,"RA_CC")
				SP8->P8_TPMARCA := _aZBD [_i3][3]
				msunlock()
			endif
		next

		Reclock("ZBD",.F.)
		ZBD->ZBD_SIMPOR := "S"
		ZBD->ZBD_DTIMPO := date()
		msunlock()
		MsgAlert("Registro confirmado.")
	else
		MsgAlert("Registro não confirmado.")
	endif

return

/*
Impressão do relatório de justificativas
*/

User Function ob_relzbd()                                             
Local wnrel
Local cString  := "ZBD"
Local titulo   := "Relatorio de justificativa do ponto eletrônico"
Local NomeProg := "ob_relzbd"                               
Local Tamanho := "M"
Private cPerg := "ob_relzbd"
PRIVATE aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
wnrel:=SetPrint(cString,NomeProg,cPerg,@titulo,"", "", "",.F.,.F.,.F.,Tamanho,,.F.)

SetDefault(aReturn,cString)
RptStatus({|lEnd| U_OB_IMPZBD(@lEnd,wnRel,cString,Tamanho,NomeProg)},titulo)
Return 

User Function OB_IMPZBD(lEnd,WnRel,cString,Tamanho,NomeProg)
LOCAL cabec1,cabec2
LOCAL cRodaTxt := oemtoansi("Rodapé")
Local nCntImpr 
Local nTipo                  
nCntImpr := 0
li := 80 
m_pag := 1//³ Inicializa os codigos de caracter Comprimido da impressora ³
nTipo := 15//³ Monta os Cabecalhos                                          ³
titulo:= oemtoansi("Lista de justificativas")
cabec1:= oemtoansi("FIL  MAT     NOME                                     ")
cabec2:=""        
ValidPerg()
Pergunte(cPerg,.F.)      // Pergunta no SX1
_cMat := ""
ob_lezbd()

do while ! _trba -> (eof ())    
	 //IncRegua()    
	 If Li > 60		
		 cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)		
		 //@ Li,0 PSAY __PrtThinLine()					
	 Endif    
	 nCntImpr++   	
	 Li++    
	if _cMat <> _trba ->RA_MAT 
		@ li, 000 PSAY _trba->RA_FILIAL + " - "+_trba->RA_MAT + " - "+LEFT(_trba->RA_NOME,45)
		li++	   
	endif

	@ li, 002 PSAY "Data: "+ DTOC(STOD(_trba->ZBD_DATA)) + "       - Líder: " +UsrRetName(_trba->ZBD_CODAPR) 
	li++
	@ li, 004 PSAY "Problema: " +alltrim(_trba->ZBD_PROBLE)
	li++
	@ li, 004 PSAY "Justif.:  " +alltrim(_trba->ZBD_JUST)
		
	_cMat := _trba ->RA_MAT
	If Li > 60        
		Li:=66    
	Endif		  
	dbSelectArea("_trba")
	dbSkip()
enddo
dbSelectArea("_trba")
_trba->(DbCloseArea())	

 If li != 80   	
 	Roda(nCntImpr,cRodaTxt,Tamanho)
 EndIf
 Set Device to Screen
 If aReturn[5] = 1   	
	 Set Printer To    	
	 dbCommitAll()   	
	 OurSpool(wnrel)
 Endif
 MS_FLUSH()
 Return
 
 static function ob_lezbd()
	_cQuery := " SELECT RA_FILIAL, RA_MAT, RA_NOME, ZBD_DATA, ZBD_JUST, ZBD_PROBLE, ZBD_CODAPR "
	_cQuery += " FROM " + RETSQLNAME ("ZBD") +" AS ZBD "
	_cQuery += " INNER JOIN " + RETSQLNAME ("SRA") +" AS SRA ON RA_FILIAL = ZBD_FILFUN AND RA_MAT = ZBD_MAT AND SRA.D_E_L_E_T_ = '' "
	_cQuery += " WHERE ZBD.D_E_L_E_T_ = '' AND ZBD_JUST <> '' "
	_cQuery += " AND ZBD_DATA BETWEEN '"+dtos(MV_PAR01) +"' AND  '"+dtos(MV_PAR02) +"' "
	_cQuery += " AND ZBD_1E = 0 AND ZBD_1S = 0 AND ZBD_2E = 0 AND ZBD_2S = 0 "
	_cQuery += " AND ZBD_3E = 0 AND ZBD_3S = 0 AND ZBD_4E = 0 AND ZBD_4S = 0 "
	_cQuery += " ORDER BY RA_FILIAL, RA_MAT, ZBD_DATA "

	tcquery _cQuery new alias _trba

return

Static Function ValidPerg()
	Local i
	Local j
	
	cAlias := Alias()
	aRegs  :={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	AADD(aRegs,{cPerg,"01","Data de         ?","Data de            ?","Data de           ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})	
	AADD(aRegs,{cPerg,"02","Data ate        ?","Data Ate           ?","Data ate          ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})

	DbSelectArea("SX1")
	DbSetOrder(1)
	For i:=1 to Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j<=Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
	DbSelectArea(cAlias)
Return
