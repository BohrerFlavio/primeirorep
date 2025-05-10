#INCLUDE "Protheus.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TbiCode.ch"

User Function PMXML002()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ PMXML002 ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Importa os arquivos XML para a rotina de geracao NF Entrada³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³ Especifico para clientes TOTVS                             ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   Data   ³ Programador   ³Manutencao Efetuada                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	Local _aArea   		:= FWGetArea()
	Local lWeb          := .F.
	Local aFiles        := {}
	Local nX            := 0     
	Local _i           
	Private aContas     := {}
	Private cIniFile    := GetAdv97()
	Private cStartPath  := "" //GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile ) + "NFE\ENTRADA\"
	Private cStartLido  := "" //Trim(cStartPath) + "OLD\"
	Private c2StartPath := "" //Trim(cStartLido) + AllTrim(Str(Year(Date()))) + "\" 
	Private c3StartPath := "" //Trim(c2StartPath) + AllTrim(Str(Month(Date()))) + "\"
	Private cStartError := "" //Trim(cStartPath) + "ERRO\"

	// Verifica se está rodando via menu ou schedule
	If Select("SX6") == 0
		lWeb := .T.
		RpcSetType(3)
		RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
	EndIf                  

	MakeDir(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFE\')
	//alert(cEmpAnt)
	If cEmpAnt == '01'
		MakeDir(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFE\01\')	
		cStartPath  := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile ) + "NFE\01\ENTRADA\"	
	ElseIf cEmpAnt == '07'
		MakeDir(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFE\07\')	
		cStartPath  := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile ) + "NFE\07\ENTRADA\"	
	ElseIf cEmpAnt == '08'                                                           
		MakeDir(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFE\08\')	
		cStartPath  := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile ) + "NFE\08\ENTRADA\"	
	Else
		Alert("Rotina não será executada para a empresa selecionada.")
		Return
	Endif

	cStartLido  := Trim(cStartPath) + "OLD\"
	c2StartPath := Trim(cStartLido) + AllTrim(Str(Year(Date()))) + "\" 
	c3StartPath := Trim(c2StartPath) + AllTrim(Str(Month(Date()))) + "\"
	cStartError := Trim(cStartPath) + "ERRO\"

	// Cria Diretórios
	MakeDir(Trim(cStartPath))		  // Cria Diretório ENTRADA
	MakeDir(cStartLido)             // Cria Diretório ARQUIVOS IMPORTADOS
	MakeDir(c2StartPath)            // Cria Diretório ANO
	MakeDir(c3StartPath)            // Cria Diretório MES
	MakeDir(cStartError)            // Cria Diretório ERRO

	//aFiles := Directory(GetSrvProfString("RootPath","") + "\" + cStartPath + "*.xml")
	aNotFiles := Directory(cStartPath+"*.*")
	For _i := 1 to len(aNotFiles)
		If Upper(right(alltrim(aNotFiles[_i,1]),4)) <> '.XML'	
			FErase(cStartPath+aNotFiles[_i,1])
		Endif
	Next _i

	aFiles := Directory(cStartPath + "*.xml")
	nXml   := 0
	//alert()
	For nX := 1 To Len(aFiles)
		nXml++
		cFilBk := cFilAnt
		cEmpBk := cEmpAnt
		nRegSM0 := SM0->(Recno())
		MsAguarde({|| U_ReadXML(aFiles[nX,1],.T.)},"Aguarde","Importando dados do arquivo XML...",.F.)
		SM0->(DbGoTo(nRegSM0))
		cEmpant := cEmpBk	
		cFilant := cFilBk	

		// Quando tiver 500 XML sai da rotina, senão estoura o array do XML
		If nXml == 500
			Return
		EndIf
	Next nX

	If lWeb
		RpcClearEnv()
	Endif

	FWRestArea(_aArea)

Return
