#include 'protheus.ch'

/*/{Protheus.doc} MpCondPag
(long_description)
@author Wyllian
@since 17/07/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
class MpCondPag
	DATA cEntid
	DATA cUrlBase
	DATA cAppToken
	DATA cEmpToken
	DATA cId

	method New() constructor
	method GetCdPag(cId)							// Obtem
	method PostCdPag()								// Incluir
	method PutCdPag(cId)							// Alterar

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
method new() class MpCondPag
	::cEntid	:= "condicoes_pagamento"
	::cAppToken	:= SuperGetMV('DH_APTOKEN')
	::cEmpToken	:= SuperGetMV('DH_CPTOKEN')
	::cUrlBase	:= AllTrim(SuperGetMV('DH_URLMP')) + ::cEntid

return

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} GetCdPag
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined

@type function
/*/
method GetCdPag(cId) class MpCondPag
	Local oJson
	Local oRet	:= {}

	Default cId	:= ''

	oRestCdPag := FWRest():New(::cUrlBase + IIF(Empty(cId),'','/' + AllTrim(cId)))

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	oRestCdPag:setPath("")

	If oRestCdPag:Get(aHeader)
		If FWJsonDeserialize(oRestCdPag:cResult, @oJson)
			oRet := oJson
		EndIf
	EndIf	

return oRet

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PostCdPag
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined

@type function
/*/
method PostCdPag() class MpCondPag
	Local oJson
	Local cJson		:= ""
	Local cNewId	:= ""
	Local cNewUrl	:= ""
	Local _y		:= 0
	Local aCdPag		:= {}

	oRestCdPag := FWRest():New(::cUrlBase)

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadCdPag() )

	oRestCdPag:setPath("")
	oRestCdPag:SetPostParams(cJson)

	If oRestCdPag:Post(aHeader)
		For _y:= 1 to len(oRestCdPag:oResponseH:aHeaderFields)
			if alltrim(oRestCdPag:oResponseH:aHeaderFields[_y][1]) == "MeusPedidosID"
				if !empty(oRestCdPag:oResponseH:aHeaderFields[_y][2])
					cNewId := alltrim(oRestCdPag:oResponseH:aHeaderFields[_y][2])
				endif
			endif

			if alltrim(oRestCdPag:oResponseH:aHeaderFields[_y+1][1]) == "MeusPedidosURL"
				if !empty(oRestCdPag:oResponseH:aHeaderFields[_y+1][2])
					cNewUrl := alltrim(oRestCdPag:oResponseH:aHeaderFields[_y+1][2])
				endif
			endif

			if !empty(cNewId) .and. !empty(cNewUrl) 
				exit
			endif
		next

		aCdPag := { Val(cNewId), cNewUrl }
	Else
		aCdPag := { 0, cNewUrl }
	EndIf

return aCdPag

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PutCdPag
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined

@type function
/*/
method PutCdPag(cId) class MpCondPag
	Local oJson
	Local cJson		:= ""
	Local cNewId	:= ""
	Local cNewUrl	:= ""
	Local aCdPag	:= {}
	Local _y		:= 0

	oRestCdPag := FWRest():New(::cUrlBase + '/' + AllTrim(cValToChar(cId)))

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadCdPag() )

	oRestCdPag:setPath("")
	oRestCdPag:SetPostParams(cJson)

	If oRestCdPag:Post(aHeader)
		For _y:= 1 to len(oRestCdPag:oResponseH:aHeaderFields)
			if alltrim(oRestCdPag:oResponseH:aHeaderFields[_y][1]) == "MeusPedidosID"
				if !empty(oRestCdPag:oResponseH:aHeaderFields[_y][2])
					cNewId := alltrim(oRestCdPag:oResponseH:aHeaderFields[_y][2])
				endif
			endif

			if alltrim(oRestCdPag:oResponseH:aHeaderFields[_y+1][1]) == "MeusPedidosURL"
				if !empty(oRestCdPag:oResponseH:aHeaderFields[_y+1][2])
					cNewUrl := alltrim(oRestCdPag:oResponseH:aHeaderFields[_y+1][2])
				endif
			endif

			if !empty(cNewId) .and. !empty(cNewUrl) 
				exit
			endif
		next

		aCdPag := { Val(cNewId), cNewUrl }
	Else
		aCdPag := { 0, cNewUrl}
	EndIf

return aCdPag

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} LoadCdPag
//TODO Descrição auto-gerada.
@author Wyllian
@since 31/07/2017
@version undefined

@type function
/*/
Static Function LoadCdPag()
	Local aRet := {}

	cNome		:= AllTrim(SE4->E4_DESCRI)
	cValorMin	:= '0.00'
	cDel		:= 'false'

	AADD(aRet,{ "nome"			, cNome										, "String"	, 100})
	AADD(aRet,{ "valor_minimo"	, cValorMin									, "Double"	, 0})
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
