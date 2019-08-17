#include 'protheus.ch'

/*/{Protheus.doc} MpTitulos
(long_description)
@author Wyllian
@since 17/07/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
class MpTitulos
	DATA cEntid
	DATA cUrlBase
	DATA cAppToken
	DATA cEmpToken
	DATA cId

	method New() constructor
	method PostTit()							// Incluir
	method PutTit(cId)							// Alterar

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
method new() class MpTitulos
	::cEntid	:= "titulos_vencidos"
	::cAppToken	:= SuperGetMV('DH_APTOKEN')
	::cEmpToken	:= SuperGetMV('DH_CPTOKEN')
	::cUrlBase	:= AllTrim(SuperGetMV('DH_URLMP')) + ::cEntid

return

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PostTit
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined

@type function
/*/
method PostTit() class MpTitulos
	Local oJson
	Local cJson		:= ""
	Local cNewId	:= ""
	Local cNewUrl	:= ""
	Local _y		:= 0
	Local aTit		:= {}

	oRestTit := FWRest():New(::cUrlBase)

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadTit() )

	oRestTit:setPath("")
	oRestTit:SetPostParams(cJson)

	If oRestTit:Post(aHeader)
		For _y:= 1 to len(oRestTit:oResponseH:aHeaderFields)
			if alltrim(oRestTit:oResponseH:aHeaderFields[_y][1]) == "MeusPedidosID"
				if !empty(oRestTit:oResponseH:aHeaderFields[_y][2])
					cNewId := alltrim(oRestTit:oResponseH:aHeaderFields[_y][2])
				endif
			endif

			if alltrim(oRestTit:oResponseH:aHeaderFields[_y+1][1]) == "MeusPedidosURL"
				if !empty(oRestTit:oResponseH:aHeaderFields[_y+1][2])
					cNewUrl := alltrim(oRestTit:oResponseH:aHeaderFields[_y+1][2])
				endif
			endif

			if !empty(cNewId) .and. !empty(cNewUrl) 
				exit
			endif
		next

		aTit := { Val(cNewId), cNewUrl }
	Else
		aTit := { 0, cNewUrl }
	EndIf

return aTit

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PutTit
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined

@type function
/*/
method PutTit(cId) class MpTitulos
	Local oJson
	Local cJson		:= ""
	Local cNewId	:= ""
	Local cNewUrl	:= ""
	Local aTit		:= {}
	Local _y		:= 0

	oRestTit := FWRest():New(::cUrlBase + '/' + AllTrim(cValToChar(cId)))

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadTit() )

	oRestTit:setPath("")
	oRestTit:SetPostParams(cJson)

	If oRestTit:Post(aHeader)
		For _y:= 1 to len(oRestTit:oResponseH:aHeaderFields)
			if alltrim(oRestTit:oResponseH:aHeaderFields[_y][1]) == "MeusPedidosID"
				if !empty(oRestTit:oResponseH:aHeaderFields[_y][2])
					cNewId := alltrim(oRestTit:oResponseH:aHeaderFields[_y][2])
				endif
			endif

			if alltrim(oRestTit:oResponseH:aHeaderFields[_y+1][1]) == "MeusPedidosURL"
				if !empty(oRestTit:oResponseH:aHeaderFields[_y+1][2])
					cNewUrl := alltrim(oRestTit:oResponseH:aHeaderFields[_y+1][2])
				endif
			endif

			if !empty(cNewId) .and. !empty(cNewUrl) 
				exit
			endif
		Next _y

		aTit := { Val(cNewId), cNewUrl }
	Else
		aTit := { 0, cNewUrl}
	EndIf

return aTit

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} LoadTit
//TODO Descrição auto-gerada.
@author Wyllian
@since 31/07/2017
@version undefined

@type function
/*/
Static Function LoadTit()
	Local aRet := {}

	cIdCli		:= AllTrim(SA1->A1_IDMP)
	cNumDoc		:= AllTrim(GetNumDoc())
	cVlrTit		:= cValToChar(GetVlrTit())
	cDtTit		:= ''
	cInfAd		:= ''
	cDel		:= 'false'

	AADD(aRet,{ "cliente_id"		, cIdCli							, "Integer"	, 0})
	AADD(aRet,{ "numero_documento"	, cNumDoc							, "Double"	, 18})
	AADD(aRet,{ "data_vencimento"	, cDtTit							, "String"	, 10})
	AADD(aRet,{ "valor"				, cVlrTit							, "Double"	, 0})
	AADD(aRet,{ "observacao"		, cInfAd							, "String"	, 500})
	AADD(aRet,{ "excluido"			, cDel								, "Boolean"	, 0})

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
