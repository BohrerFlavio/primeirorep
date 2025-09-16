#INCLUDE "APVT100.CH"
#INCLUDE "Protheus.ch"
#INCLUDE "Totvs.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "Topconn.ch"

USER FUNCTION MRVT23(_usuario)
    Private cModelo := ' '
    Private lTela   := .T.
    Private cPGCX   := alltrim(GetMV("SI_PRODGRX"))
    Private nPGCX   := 0

	_cModelo = VTModelo()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

    DbSelectArea('ZAS')
    ZAS->(DBSetOrder(1))
    ZAS->(DBGoTop())

	VTClear()
	VTClearBuffer()

    WHILE lTela
        cCodCxa := Space(11)
        cTxtImp := ''

        @ 01,01 VTSay "Cód. da Caixa:"
		@ 02,01 VTGet cCodCxa Pict "@!"

        VTRead

        if ZAS->(MsSeek(FWxFilial('ZAS')+AllTrim(cCodCxa)))
            if (!Empty(ZAS_STRRX))
                nPGCX   := 100-ZAS->ZAS_PERCCX
                if (alltrim(ZAS->ZAS_COD) $ cPGCX)
                    if(nPGCX <= 20)
                        cTxtImp := '20-'
                        Imprime(cTxtImp)
                        VTAlert('Etiqueta a ser usada: 20-','Aviso',.T.,1000,1)
                    elseif (nPGCX >= 21 .AND. nPGCX <= 25)
                        cTxtImp := '20/25'
                        Imprime(cTxtImp)
                        VTAlert('Etiqueta a ser usada: 20/25','Aviso',.T.,1000,1)
                    else
                        cTxtImp := '25+'
                        Imprime(cTxtImp)
                        VTAlert('Etiqueta a ser usada: 25+','Aviso',.T.,1000,1)
                    endif
                else
                    if(nPGCX < 25)
                        cTxtImp := '25-'
                        Imprime(cTxtImp)
                        VTAlert('Etiqueta a ser usada: 25-','Aviso',.T.,1000,1)
                    elseif (nPGCX >= 25 .AND. nPGCX <= 33)
                        cTxtImp := '25/33'
                        Imprime(cTxtImp)
                        VTAlert('Etiqueta a ser usada: 25/33','Aviso',.T.,1000,1)
                    else
                        cTxtImp := '33+'
                        Imprime(cTxtImp)
                        VTAlert('Etiqueta a ser usada: 33+','Aviso',.T.,1000,1)
                    endif
                endif
            else
                VTAlert('Caixa sem dados relacionados ao Raio-X.','Aviso',.T.,2000,1)
            endif
        else
            VTAlert('CAIXA ' +  AllTrim(cCodCxa) + ' NÃO LOCALIZADA','Aviso',.T.,2000,1)
        endif
    endDO

    VTClear()
	VTClearBuffer()
RETURN

STATIC FUNCTION Imprime(cTxtImp)
    LOCAL _cIpEst := GetAdvFval('ZAM','ZAM_IP',FWxFilial('ZAM') + AllTrim("EXP11"),1)
	LOCAL _cIp    := AllTrim(_cIpEst)

    MSCBPRINTER('S600','IP',,,,,_cIp)
    MSCBCHKSTATUS(.T.)
    MSCBBEGIN(1,6,15)
    MSCBSAY(15,15,cTxtImp,"N","0","105.20")
    MSCBend()
	MSCBCLOSEPRINTER()
RETURN
