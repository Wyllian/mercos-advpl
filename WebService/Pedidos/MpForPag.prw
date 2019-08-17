#include 'protheus.ch'

/*/{Protheus.doc} MpForPag
(long_description)
@author Wyllian
@since 17/07/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
class MpForPag
	DATA cEntid
	DATA cUrlBase
	DATA cAppToken
	DATA cEmpToken
	DATA cId

	method New() constructor
	method GetFrPag(cId)							// Obtem
	method PostFrPag()								// Incluir
	method PutFrPag(cId)							// Alterar

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
method new() class MpForPag
	::cEntid	:= "formas_pagamento"
	::cAppToken	:= SuperGetMV('DH_APTOKEN')
	::cEmpToken	:= SuperGetMV('DH_CPTOKEN')
	::cUrlBase	:= AllTrim(SuperGetMV('DH_URLMP')) + ::cEntid

return

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} GetFrPag
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined

@type function
/*/
method GetFrPag(cId) class MpForPag
	Local oJson
	Local oRet	:= {}

	Default cId	:= ''

	oRestFrPag := FWRest():New(::cUrlBase + IIF(Empty(cId),'','/' + AllTrim(cId)))

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	oRestFrPag:setPath("")

	If oRestFrPag:Get(aHeader)
		If FWJsonDeserialize(oRestFrPag:cResult, @oJson)
			oRet := oJson
		EndIf
	EndIf	

return oRet

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PostFrPag
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined

@type function
/*/
method PostFrPag() class MpForPag
	Local oJson
	Local cJson		:= ""
	Local cNewId	:= ""
	Local cNewUrl	:= ""
	Local _y		:= 0
	Local aFrPag		:= {}

	oRestFrPag := FWRest():New(::cUrlBase)

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadFrPag() )

	oRestFrPag:setPath("")
	oRestFrPag:SetPostParams(cJson)

	If oRestFrPag:Post(aHeader)
		For _y:= 1 to len(oRestFrPag:oResponseH:aHeaderFields)
			if alltrim(oRestFrPag:oResponseH:aHeaderFields[_y][1]) == "MeusPedidosID"
				if !empty(oRestFrPag:oResponseH:aHeaderFields[_y][2])
					cNewId := alltrim(oRestFrPag:oResponseH:aHeaderFields[_y][2])
				endif
			endif

			if alltrim(oRestFrPag:oResponseH:aHeaderFields[_y+1][1]) == "MeusPedidosURL"
				if !empty(oRestFrPag:oResponseH:aHeaderFields[_y+1][2])
					cNewUrl := alltrim(oRestFrPag:oResponseH:aHeaderFields[_y+1][2])
				endif
			endif

			if !empty(cNewId) .and. !empty(cNewUrl) 
				exit
			endif
		next

		aFrPag := { Val(cNewId), cNewUrl }
	Else
		aFrPag := { 0, cNewUrl }
	EndIf

return aFrPag

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PutFrPag
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined

@type function
/*/
method PutFrPag(cId) class MpForPag
	Local oJson
	Local cJson		:= ""
	Local cNewId	:= ""
	Local cNewUrl	:= ""
	Local aFrPag	:= {}
	Local _y		:= 0

	oRestFrPag := FWRest():New(::cUrlBase + '/' + AllTrim(cValToChar(cId)))

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadFrPag() )

	oRestFrPag:setPath("")
	oRestFrPag:SetPostParams(cJson)

	If oRestFrPag:Post(aHeader)
		For _y:= 1 to len(oRestFrPag:oResponseH:aHeaderFields)
			if alltrim(oRestFrPag:oResponseH:aHeaderFields[_y][1]) == "MeusPedidosID"
				if !empty(oRestFrPag:oResponseH:aHeaderFields[_y][2])
					cNewId := alltrim(oRestFrPag:oResponseH:aHeaderFields[_y][2])
				endif
			endif

			if alltrim(oRestFrPag:oResponseH:aHeaderFields[_y+1][1]) == "MeusPedidosURL"
				if !empty(oRestFrPag:oResponseH:aHeaderFields[_y+1][2])
					cNewUrl := alltrim(oRestFrPag:oResponseH:aHeaderFields[_y+1][2])
				endif
			endif

			if !empty(cNewId) .and. !empty(cNewUrl) 
				exit
			endif
		next

		aFrPag := { Val(cNewId), cNewUrl }
	Else
		aFrPag := { 0, cNewUrl}
	EndIf

return aFrPag

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} LoadFrPag
//TODO Descrição auto-gerada.
@author Wyllian
@since 31/07/2017
@version undefined

@type function
/*/
Static Function LoadFrPag()
	Local aRet := {}

	cNome		:= ''			// A Definir
	cDel		:= 'false'

	AADD(aRet,{ "nome"			, cNome										, "String"	, 100})
	AADD(aRet,{ "excluido"		, cDel										, "Boolean"	, 0})

Return aRet

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} MontaJson
//TODO Descrição auto-gerada.
@author Wyllian
@since 31/07/2017
@version undefined
@param aDados, array, descricao
@type function
/*/
Static Function MontaJson( aDados )
	Local cJson	:= ""
	Local x		:= 0 

	cJson := '{'

	For x := 1 to Len(aDados)
		cJson += '"' + aDados[x][1] + '": '

		if aDados[x][3] == 'String'
			if len(aDados[x][2]) > aDados[x][4] .And. aDados[x][4] <> 0
				cJson += '"' + SubStr(aDados[x][2], 1, aDados[x][4]) + '"'
			else
				cJson += '"' + aDados[x][2] + '"'
			endif

		elseif aDados[x][3] == 'Array'
			cJson += aDados[x][2]

		elseif aDados[x][3] == 'Boolean'
			cJson += aDados[x][2]

		elseif aDados[x][3] == 'Double'
			cJson += aDados[x][2]

		elseif aDados[x][3] == 'Integer'
			cJson += aDados[x][2]

		endif

		if x < Len(aDados)
			cJson += ', '
		endif

	Next x

	cJson += '}'

Return cJson
