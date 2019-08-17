#include 'protheus.ch'

/*/{Protheus.doc} MpCdPgXClie
(long_description)
@author Wyllian
@since 17/07/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
class MpCdPgXClie
	DATA cEntid
	DATA cAppToken
	DATA cEmpToken
	DATA cId
	DATA cUrlBase

	method new() constructor
	method PostCPgCli()							// Incluir Produto

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
method new() class MpCdPgXClie
	::cEntid	:= "clientes_condicoes_pagamento"
	::cAppToken	:= SuperGetMV('DH_APTOKEN')
	::cEmpToken	:= SuperGetMV('DH_CPTOKEN')
	::cUrlBase	:= AllTrim(SuperGetMV('DH_URLMP')) + ::cEntid

return

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PostCdPgXCli
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined
@type function
/*/
method PostCPgCli() class MpCdPgXClie
	Local cJson		:= ""
	Local cNewId	:= ""
	Local cNewUrl	:= ""
	Local _y		:= 0
	Local aCdPgXCli		:= {}

	oRestXClie := FWRest():New(::cUrlBase)

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadCPgCli() )

	oRestXClie:setPath("")
	oRestXClie:SetPostParams(cJson)

	If oRestXClie:Post(aHeader)
		For _y:= 1 to len(oRestXClie:oResponseH:aHeaderFields)
			if alltrim(oRestXClie:oResponseH:aHeaderFields[_y][1]) == "MeusPedidosID"
				if !empty(oRestXClie:oResponseH:aHeaderFields[_y][2])
					cNewId := alltrim(oRestXClie:oResponseH:aHeaderFields[_y][2])
				endif
			endif

			if alltrim(oRestXClie:oResponseH:aHeaderFields[_y+1][1]) == "MeusPedidosURL"
				if !empty(oRestXClie:oResponseH:aHeaderFields[_y+1][2])
					cNewUrl := alltrim(oRestXClie:oResponseH:aHeaderFields[_y+1][2])
				endif
			endif

			if !empty(cNewId) .and. !empty(cNewUrl)
				exit
			endif
		next

		aCdPgXCli := { Val(cNewId), cNewUrl }
	Else
		aCdPgXCli := { 0, cNewUrl }

	EndIf

return aCdPgXCli

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} LoadCdPgXCli
//TODO Descrição auto-gerada.
@author Wyllian
@since 31/07/2017
@version undefined

@type function
/*/
Static Function LoadCPgCli()
	Local aRet := {}

	cIdClie		:= cValToChar(SA1->A1_IDMP)
	cCdPagLib	:= ""		 							// a Definir

	AADD(aRet,{ "cliente_id"					, IIF(!Empty(cIdClie), cIdClie, 'null')		, "Integer"	, 0})
	AADD(aRet,{ "condicoes_pagamento_liberadas"	, IIF(!Empty(cCdPagLib), cCdPagLib, 'null')	, "Array"	, 0})

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
