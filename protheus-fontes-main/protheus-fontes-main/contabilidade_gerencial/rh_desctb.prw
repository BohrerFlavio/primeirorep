#INCLUDE "rwmake.ch"

User Function rh_desctb()

cAlias:=Alias()


mdprod:=space(20)
miprod:=space(20)
mdadmi:=space(20)
mdvend:=space(20)
_xVerba:=SRZ->RZ_PD
_xCC:=ALLTRIM(SRZ->RZ_CC)
_xhist:=space(40)


DbSelectArea("SRV")
DBSetorder(1)
DbSeek(xFilial("SRV")+_xVerba,.f.)


If Found()
	_xhist:=SRV->RV_DESLCTO 
  
Endif

DbSelectArea(cAlias)
Return _xhist
