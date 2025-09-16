#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "totvs.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  INTBRA   บ Autor ณ Lucas Bolzan         บ Data ณ  19/03/24   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Envia e-mail de workflows relacionadas a produ็ใo          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Produ็ใo                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER FUNCTION WFWETQ(cCodPro,cCadMer,cDestin,cTipEtq,cRaca)

    cCodPro := iif(Empty(cCodPro),'Sem valor definido',cCodPro)
    cCadMer := iif(Empty(cCadMer),'Sem valor definido',cCadMer)
    cDestin := iif(Empty(cDestin),'Sem valor definido',cDestin)
    cTipEtq := iif(Empty(cTipEtq),'Sem valor definido',cTipEtq)
    cRaca := iif(Empty(cRaca),'Sem valor definido',cRaca)
    cDesMail := GetMV('SI_WFWETQ ')

    cTit := 'Ocorr๊ncia em etiquetas'

    cMsg := 'Esta ้ uma mensagem automแtica do sistema. Por favor nใo responda!' + chr(13) + chr(10)
    cMsg += 'O usuแrio ' + UsrRetName(RetCodUsr()) + ' tentou imprimir uma etiqueta auto colante no computador ' + getComputerName() + ' no dia ' + DToS(Date()) + ' เs ' + Time() + ' por้m ela' + chr(13) + chr(10)
    cMsg += 'nใo se enquadrou em nenhuma das regras definidas. Segue abaixo os dados para conferencia no cadastro de produtos e no cadastro de etiquetas internas.' + chr(13) + chr(10)
    cMsg += 'C๓digo do Produto: ' + cCodPro + chr(13) + chr(10)
    cMsg += 'Cadastro Mercadoria: ' + cCadMer + chr(13) + chr(10)
    cMsg += 'Destino: ' + cDestin + chr(13) + chr(10)
    cMsg += 'Tipo de etiqueta: ' + cTipEtq + chr(13) + chr(10)
    cMsg += 'Ra็a: ' + cRaca

    cDes := 'workflow@frigorificosilva.com.br'
    cDest := AllTrim(cDesMail)

    _aEmail := u_GJF54(cMsg,cTit,cDes+';'+cDest)

RETURN

USER FUNCTION WFWOPE(cCodPro,dDtaAbt)    
    cDesMail := GetMV('SI_WFWOPE')

    cTit := 'Ocorr๊ncia na gera็ใo de OPs automaticas'

    cMsg := 'Esta ้ uma mensagem automแtica do sistema. Por favor nใo responda!' + chr(13) + chr(10)
    cMsg += 'O usuแrio ' + UsrRetName(RetCodUsr()) + ' gerou uma pr้-etiqueta ou etiqueta interna no computador ' + getComputerName() + ' no dia ' + DToS(Date()) + ' เs ' + Time() + chr(13) + chr(10)
    cMsg += 'por้m nใo foi gerada OP (ordem de prdou็ใo) da embalagem automaticamente pois nใo localizou previsใo de dessossa.' + chr(13) + chr(10)
    cMsg += 'C๓digo do Produto: ' + cCodPro + chr(13) + chr(10)
    cMsg += 'Data de abate: ' + DToC(dDtaAbt)
    

    cDes := 'workflow@frigorificosilva.com.br'
    cDest := AllTrim(cDesMail)

    _aEmail := u_GJF54(cMsg,cTit,cDes+';'+cDest)

RETURN

