#include 'protheus.ch'

/*/{Protheus.doc} MpUsers
(long_description)
@author Wyllian
@since 17/07/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
class MpUsers
	DATA cEntid
	DATA cUrlBase
	DATA cAppToken
	DATA cEmpToken
	DATA cId

	method New() constructor
	method GetUser(cId)							// Obtem

endclass

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} new
Metodo construtor
@author Wyllian
@since 17/07/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
method new() class MpUsers
	::cEntid	:= "usuarios"
	::cAppToken	:= SuperGetMV('DH_APTOKEN')
	::cEmpToken	:= SuperGetMV('DH_CPTOKEN')
	::cUrlBase	:= AllTrim(SuperGetMV('DH_URLMP')) + ::cEntid

return

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} GetUser
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined

@type function
/*/
method GetUser(cId) class MpUsers
	Local oJson
	Local oRet	:= {}

	Default cId	:= ''

	oRestUser := FWRest():New(::cUrlBase + IIF(Empty(cId),'','/' + AllTrim(cId)))

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	oRestUser:setPath("")

	If oRestUser:Get(aHeader)
		U_DH05A00L("usuarios","GET",oRestUser:cHost,oRestUser:cResult)

		If FWJsonDeserialize(oRestUser:cResult, @oJson)
			oRet := oJson
		EndIf
	Else

	EndIf

return oRet
